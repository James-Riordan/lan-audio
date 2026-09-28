"""Qualify the current host's C/Zig ABI across four profiles and deliberate faults.

Writes only to a new evidence directory and its build cache. All native tests use
an explicit null device or no device. Never changes source, vendor pins or another
project. A compiler/linker failure cannot count as a successful mutation rejection.
See docs/verification/abi.md for coverage, test IDs and remaining native targets.
"""
from __future__ import annotations

import argparse
from datetime import datetime, timezone
import hashlib
import json
import os
from pathlib import Path
import platform
import re
import subprocess
import sys
import time

from check_docs import inventory


def classify(returncode, output, fault='none', consumer=False):
    """Accept runtime assertion failures with exact expected witnesses, never any failure."""
    if fault == 'none':
        total = 1 if consumer else 8
        return returncode == 0 and f'{total}/{total} tests passed' in output
    expected = {'size': (4, 1), 'profile': (3, 2)}
    if fault not in expected:
        return False
    passed, failed = expected[fault]
    # Optimized Zig tests omit Debug stack frames/error symbol names. The named
    # runtime test failure, explicit ABI witnesses and summary survive both modes.
    common = (returncode == 1
              and "error: 'abi.test.C and Zig object sizes and alignments agree' failed:" in output
              and 'ABI size ma_device:' in output
              and f'{passed}/5 tests passed ({failed} failed)' in output)
    if fault == 'profile':
        return (common and 'ABI size ma_device_info:' in output and 'ABI offset #10 isDefault:' in output
                and "error: 'abi.test.C and Zig callback userdata and endpoint field offsets agree' failed:" in output)
    return common


def source_hashes(root):
    files, errors = inventory(root)
    if errors:
        raise ValueError('; '.join(errors))
    return {rel: hashlib.sha256((root / rel).read_bytes()).hexdigest() for rel in sorted(files)}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--zig', default='zig', help='Pinned Zig executable')
    parser.add_argument('--output', type=Path, required=True, help='New evidence directory; never overwritten')
    parser.add_argument('--timeout', type=float, default=240, help='Seconds per compiler/test command')
    args = parser.parse_args()
    root = Path(__file__).resolve().parents[1]
    output = args.output.resolve()
    if args.timeout <= 0:
        parser.error('--timeout must be positive')
    if output.exists():
        parser.error('--output already exists; choose a new phase directory')
    if output.is_relative_to(root) and not output.is_relative_to(root / 'verification'):
        parser.error('in-project evidence must be beneath verification/')
    expected_version = re.search(r'\.minimum_zig_version\s*=\s*"([^"]+)"',
                                 (root / 'build.zig.zon').read_text()).group(1)
    # Qualification is deliberately for this exact development compiler. The
    # package's compiler floor alone does not prove compatibility with later ones.
    env = dict(os.environ, LC_ALL='C', LANG='C')
    try:
        version_run = subprocess.run([args.zig, 'version'], capture_output=True, text=True,
                                     encoding='utf-8', errors='replace', env=env, timeout=args.timeout)
    except (OSError, subprocess.TimeoutExpired) as exc:
        parser.error(f'cannot identify compiler: {exc}')
    if version_run.returncode != 0 or version_run.stdout.strip() != expected_version:
        parser.error(f'qualification requires Zig {expected_version}; got {version_run.stdout.strip()!r}')
    original = source_hashes(root)
    output.mkdir(parents=True)
    cache = output / 'cache'
    receipt = {
        'schema': 1, 'phase': 'independent-abi', 'started_utc': datetime.now(timezone.utc).isoformat(),
        'source_root': str(root), 'sources': original, 'platform': platform.platform(),
        'architecture': platform.machine(), 'python': sys.version,
        'zig_version': version_run.stdout.strip(), 'commands': [],
        'limits': ['Native evidence applies only to this host/profile/compiler.',
                   'No physical audio, OS callbacks or real-time scheduling qualification.',
                   'No claim of complete upstream ABI coverage or arbitrary caller memory safety.'],
    }

    def seal():
        (output / 'receipt.json').write_text(json.dumps(receipt, indent=2) + '\n', encoding='utf-8')

    seal()
    for optimize in ('Debug', 'ReleaseSafe'):
        for null_only in (False, True):
            profile = f'{optimize}-{"null" if null_only else "native"}'
            options = [f'-Doptimize={optimize}', f'-Dnull-backend={str(null_only).lower()}']
            for fault, consumer in (('none', False), ('size', False), ('profile', False), ('none', True)):
                label = profile + ('-consumer' if consumer else '-' + fault)
                cwd = root / 'tests/consumer' if consumer else root
                command = [args.zig, 'build', 'test' if fault == 'none' else 'test-abi', '-j1',
                           '--cache-dir', str(cache), '--summary', 'all', *options]
                if fault != 'none':
                    command.append(f'-Dabi-test-fault={fault}')
                at = datetime.now(timezone.utc).isoformat()
                start = time.monotonic()
                timed_out = False
                try:
                    result = subprocess.run(command, cwd=cwd, env=env, capture_output=True,
                                            text=True, encoding='utf-8', errors='replace', timeout=args.timeout)
                    text = result.stdout + result.stderr
                    returncode = result.returncode
                except subprocess.TimeoutExpired as exc:
                    # A timeout is a harness failure, never mutation success.
                    def decode(value):
                        return value.decode('utf-8', errors='replace') if isinstance(value, bytes) else value or ''
                    text = decode(exc.stdout) + decode(exc.stderr) + '\nCOMMAND TIMEOUT\n'
                    returncode = None
                    timed_out = True
                except OSError as exc:
                    text = f'COMMAND LAUNCH ERROR: {exc}\n'
                    returncode = None
                accepted = returncode is not None and classify(returncode, text, fault, consumer)
                log = output / (label + '.log')
                log.write_text(text, encoding='utf-8')
                receipt['commands'].append({
                    'label': label, 'command': command, 'cwd': str(cwd), 'started_utc': at,
                    'elapsed_seconds': round(time.monotonic() - start, 3),
                    'returncode': returncode, 'timed_out': timed_out,
                    'expected': 'runtime assertion rejection' if fault != 'none' else 'all tests pass',
                    'accepted': accepted, 'log': log.name,
                    'log_sha256': hashlib.sha256(log.read_bytes()).hexdigest(),
                })
                seal()
                print(f'{label}: {"PASS" if accepted else "FAIL"}', flush=True)
                if not accepted:
                    receipt['complete'] = False
                    receipt['failure'] = 'Unexpected command result; remaining profiles were not run.'
                    seal()
                    return 1
    receipt['source_unchanged'] = source_hashes(root) == original
    receipt['complete'] = receipt['source_unchanged']
    receipt['completed_utc'] = datetime.now(timezone.utc).isoformat()
    seal()
    print(f'Qualification {"PASS" if receipt["complete"] else "FAIL: source changed"}: {output}', flush=True)
    return 0 if receipt['complete'] else 1


if __name__ == '__main__':
    raise SystemExit(main())
