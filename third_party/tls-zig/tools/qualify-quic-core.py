"""Qualify the pure recordless core; native execution and cross-build evidence stay separate.

Requires a new empty --work-dir. No TLS provider, network peer or SDK is qualified.
"""
from pathlib import Path
import argparse
import datetime
import hashlib
import json
import os
import subprocess


def qualify(root, scratch, zig, cross=False):
    scratch.mkdir(parents=True, exist_ok=True)
    if any(scratch.iterdir()):
        raise ValueError('use a new empty work directory; preserve previous evidence')
    version = subprocess.check_output([zig, 'version'], text=True).strip()
    if version != '0.17.0-dev.1859+dcceb318e':
        raise ValueError('unqualified compiler: ' + version)
    env = os.environ.copy()
    env['ZIG_GLOBAL_CACHE_DIR'] = str(root / '.zig-global-cache')
    env['PYTHONDONTWRITEBYTECODE'] = '1'
    runs = []
    for mode in ('Debug', 'ReleaseSafe'):
        for label, cwd, args in [('core', root, ['quic-test']), ('consumer', root/'examples/quic-contract', ['run'])]:
            runs.append((label+'-'+mode, cwd, [zig, 'build', *args, '-Doptimize='+mode, '-j1', '--summary', 'all'], 'native-run'))
    if cross:
        for target in ('x86-windows-gnu', 'aarch64-windows-gnu', 'x86_64-linux-musl', 'aarch64-linux-musl', 'x86_64-macos', 'aarch64-macos', 'x86_64-freebsd'):
            runs.append(('cross-'+target, root/'examples/quic-contract', [zig, 'build', '-Doptimize=ReleaseSafe', '-Dtarget='+target, '-j1', '--summary', 'all'], 'compile-only'))
    records = []
    for label, cwd, command, scope in runs:
        started = datetime.datetime.now(datetime.timezone.utc).isoformat()
        try:
            run = subprocess.run(command, cwd=cwd, env=env, capture_output=True, timeout=240)
            code, stdout, stderr = run.returncode, run.stdout, run.stderr
        except subprocess.TimeoutExpired as exc:
            code, stdout, stderr = -1, exc.stdout or b'', (exc.stderr or b'') + b'\nTIMEOUT 240 seconds\n'
        logs = {}
        for name, body in [('stdout',stdout), ('stderr',stderr)]:
            p = scratch/(label+'.'+name+'.log')
            p.write_bytes(body)
            logs[name] = dict(path=p.name, sha256=hashlib.sha256(body).hexdigest())
        records.append(dict(id=label, scope=scope, command=command, cwd=str(cwd), started_utc=started, exit_code=code, **logs))
        (scratch/'runs.json').write_text(json.dumps(records,indent=2)+'\n',encoding='utf-8')
        print(label, code, flush=True)
        if code:
            print(stderr.decode(errors='replace'), flush=True)
    return all(r['exit_code']==0 for r in records)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--work-dir', type=Path, required=True)
    parser.add_argument('--zig', default='zig')
    parser.add_argument('--cross', action='store_true')
    args = parser.parse_args()
    return 0 if qualify(Path(__file__).resolve().parents[1], args.work_dir.resolve(), args.zig, args.cross) else 1


if __name__ == '__main__':
    raise SystemExit(main())
