"""Offline native qualification for the actual recordless C adapter and C/Zig ABI.

Requires a new empty --work-dir and the exact locked Windows x86_64 SDK/compiler.
Native results are Windows-only; Mac/LP64 and CI qualification remain open.
"""
from pathlib import Path
import argparse
import datetime
import hashlib
import json
import os
import platform
import subprocess
import sys

CASES = ('full', 'fragmented', 'backpressure', 'combined', 'mutual', 'missing-client',
         'wrong-host', 'wrong-ca', 'alpn', 'fail-send', 'fail-receive', 'fail-release',
         'fail-secret', 'fail-params', 'fail-alert', 'budgeted', 'zero-budget',
         'overconsume', 'overlease', 'null-lease', 'params-overflow', 'reentrant',
         'validation', 'config-copy', 'ip')


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def qualify(root, scratch, zig):
    scratch.mkdir(parents=True, exist_ok=True)
    if any(scratch.iterdir()):
        raise ValueError('use a new empty work directory; preserve existing evidence')
    if os.name != 'nt' or platform.machine().lower() not in ('amd64', 'x86_64'):
        raise RuntimeError('current native provider qualification is Windows x86_64 only')
    lock = json.loads((root/'backend-lock.json').read_text(encoding='utf-8-sig'))
    if lock['target'] != 'x86_64-windows-gnu' or lock['sdk_root'] != 'deps/openssl-install':
        raise RuntimeError('unqualified SDK target or owning-build root')
    version = subprocess.check_output([zig, 'version'], text=True, timeout=30).strip()
    if version != lock['zig']:
        raise RuntimeError('unqualified compiler: ' + version)
    source_paths = ['build.zig', 'build.zig.zon', 'backend-lock.json', 'src/backend/quic.h',
                    'src/backend/quic.c', 'src/backend/quic.zig', 'tests/quic/backend.c', 'tests/quic/backend_abi.c',
                    'tests/quic/backend_abi.zig', 'tools/qualify-quic-backend.py', 'tools/verify-backend.py']
    source_paths += [p.relative_to(root).as_posix() for p in (root/'tests/fixtures').iterdir() if p.is_file()]
    inputs = {p: digest(root/p) for p in source_paths}
    sdk = root/lock['sdk_root']
    env = os.environ.copy()
    env['ZIG_GLOBAL_CACHE_DIR'] = str(root/'.zig-global-cache')
    env['OPENSSL_CONF'] = str(sdk/'ssl/openssl.cnf')
    env['OPENSSL_MODULES'] = str(sdk/'lib/ossl-modules')
    env['PYTHONDONTWRITEBYTECODE'] = '1'
    commands = [('sdk', [sys.executable, 'tools/verify-backend.py'], 'host-tool')]
    commands += [('backend-'+mode, [zig, 'build', 'quic-backend-test', '-Doptimize='+mode,
                                    '-j1', '--summary', 'all'], mode) for mode in ('Debug', 'ReleaseSafe')]
    commands.append(('sdk-after', [sys.executable, 'tools/verify-backend.py'], 'host-tool'))
    report = dict(scope='Actual native C adapter and independent C/Zig ABI; same-provider TLS pair, no QUIC packets',
                  zig=version, target=lock['target'], source_inputs=inputs,
                  sdk_lock_sha256=digest(root/'backend-lock.json'), runs=[], passed=False)
    for label, command, mode in commands:
        started = datetime.datetime.now(datetime.timezone.utc).isoformat()
        try:
            result = subprocess.run(command, cwd=root, env=env, capture_output=True, timeout=240)
            code, stdout, stderr = result.returncode, result.stdout, result.stderr
        except subprocess.TimeoutExpired as exc:
            code, stdout, stderr = -1, exc.stdout or b'', (exc.stderr or b'')+b'\nTIMEOUT 240 seconds\n'
        logs = {}
        for stream, body in [('stdout', stdout), ('stderr', stderr)]:
            path = scratch/(label+'.'+stream+'.log');path.write_bytes(body)
            logs[stream] = dict(path=path.name, sha256=digest(path))
        observed = []
        adequate = code == 0
        if label.startswith('backend-') and adequate:
            for line in stdout.splitlines():
                if line.startswith(b'{'):
                    observed.append(json.loads(line))
            adequate = (len(observed) == len(CASES) and
                        {r.get('case') for r in observed} == set(CASES) and
                        all(r.get('passed') is True for r in observed) and
                        b'All 2 tests passed.' in stderr)
        report['runs'].append(dict(id=label, command=command, cwd='.', mode=mode,
                                   started_utc=started, exit_code=code, observed=observed,
                                   adequate=adequate, **logs))
        (scratch/'runs.json').write_text(json.dumps(report, indent=2)+'\n', encoding='utf-8')
        print(label, code, 'observations-complete' if adequate else 'FAILED', flush=True)
        if not adequate:
            print(stderr.decode(errors='replace'), flush=True)
            return False
    if any(digest(root/p) != sha for p, sha in inputs.items()):
        raise RuntimeError('source changed during qualification; evidence cannot close a package')
    report['passed'] = True
    (scratch/'runs.json').write_text(json.dumps(report, indent=2)+'\n', encoding='utf-8')
    return True


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--work-dir', type=Path, required=True)
    parser.add_argument('--zig', default='zig')
    args = parser.parse_args()
    try:
        return 0 if qualify(Path(__file__).resolve().parents[1], args.work_dir.resolve(), args.zig) else 1
    except (OSError, ValueError, KeyError, TypeError, RuntimeError, subprocess.SubprocessError) as exc:
        print(str(exc), file=sys.stderr)
        return 1


if __name__ == '__main__':
    raise SystemExit(main())
