"""Offline native Engine conformance and separate production-module consumer.

Uses the exact Windows x86_64 compiler/SDK. No cross-platform runtime claim.
New empty evidence directories preserve failures and all earlier receipts.
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


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def qualify(root, scratch, zig):
    scratch.mkdir(parents=True, exist_ok=True)
    if any(scratch.iterdir()):
        raise ValueError('use a new empty work directory; preserve existing evidence')
    lock = json.loads((root/'backend-lock.json').read_text(encoding='utf-8-sig'))
    if (os.name != 'nt' or platform.machine().lower() not in ('amd64', 'x86_64') or
            lock['target'] != 'x86_64-windows-gnu' or lock['sdk_root'] != 'deps/openssl-install'):
        raise RuntimeError('current native Engine qualification is Windows x86_64 only')
    version = subprocess.check_output([zig, 'version'], text=True, timeout=30).strip()
    if version != lock['zig']:
        raise RuntimeError('unqualified compiler: '+version)
    paths = ['build.zig', 'build.zig.zon', 'backend-lock.json', 'tests/quic_contract.zig',
             'tests/quic/reference_peer.c', 'tools/probe-quic-pair.c',
             'tools/qualify-quic-engine.py', 'tools/verify-backend.py']
    paths += [p.relative_to(root).as_posix() for directory in ('src', 'tests/fixtures')
              for p in (root/directory).rglob('*') if p.is_file()]
    paths += ['examples/quic-engine/'+name for name in ('build.zig', 'build.zig.zon', 'main.zig')]
    inputs = {p: digest(root/p) for p in sorted(set(paths))}
    sdk = root/lock['sdk_root']
    env = os.environ.copy()
    env.update(ZIG_GLOBAL_CACHE_DIR=str(root/'.zig-global-cache'),
               OPENSSL_CONF=str(sdk/'ssl/openssl.cnf'),
               OPENSSL_MODULES=str(sdk/'lib/ossl-modules'), PYTHONDONTWRITEBYTECODE='1')
    commands = [('sdk', root, [sys.executable, 'tools/verify-backend.py'], 'host-tool')]
    for mode in ('Debug', 'ReleaseSafe'):
        commands.append(('engine-'+mode, root, [zig, 'build', 'quic-engine-test',
                        '-Doptimize='+mode, '-j1', '--summary', 'all'], mode))
        commands.append(('consumer-'+mode, root/'examples/quic-engine', [zig, 'build', 'run',
                        '-Doptimize='+mode, '-j1', '--summary', 'all'], mode))
    commands.append(('sdk-after', root, [sys.executable, 'tools/verify-backend.py'], 'host-tool'))
    report = dict(scope='Native owning Engine, direct same-OpenSSL peer, protected packet decryption, production external consumer',
                  target=lock['target'], zig=version, source_inputs=inputs,
                  sdk_lock_sha256=digest(root/'backend-lock.json'), runs=[], passed=False)
    for label, cwd, command, mode in commands:
        started = datetime.datetime.now(datetime.timezone.utc).isoformat()
        try:
            result = subprocess.run(command, cwd=cwd, env=env, capture_output=True, timeout=300)
            code, stdout, stderr = result.returncode, result.stdout, result.stderr
        except subprocess.TimeoutExpired as exc:
            code, stdout, stderr = -1, exc.stdout or b'', (exc.stderr or b'')+b'\nTIMEOUT 300 seconds\n'
        logs = {}
        for stream, body in [('stdout', stdout), ('stderr', stderr)]:
            path = scratch/(label+'.'+stream+'.log')
            path.write_bytes(body)
            logs[stream] = dict(path=path.name, sha256=digest(path))
        adequate = code == 0
        if label.startswith('engine-'):
            adequate = adequate and b'All 10 tests passed.' in stderr
        if label.startswith('consumer-'):
            adequate = adequate and b'recordless consumer: both roles completed authenticated policy/key custody' in stderr
        report['runs'].append(dict(id=label, command=command, cwd=cwd.relative_to(root).as_posix(),
                                  mode=mode, started_utc=started, exit_code=code,
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
