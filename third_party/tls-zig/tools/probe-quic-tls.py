"""Windows SDK capability probe; no sockets or authenticated peer handshake.

Run: python tools/probe-quic-tls.py --work-dir <dedicated-scratch-directory>
Creates a compiled probe and copies the two locked runtime DLLs into that scratch.
Verifies the exact SDK file set and hashes before compiling or loading native code.
Returns JSON, exit 0 only when every bounded probe case passes. No lock is rewritten.
"""
from pathlib import Path, PurePosixPath
import argparse
import datetime
import hashlib
import json
import os
import shutil
import subprocess
import sys


def digest(p):
    return hashlib.sha256(p.read_bytes()).hexdigest()


def run(root, scratch, zig, sdk_override=None):
    if os.name != 'nt':
        raise RuntimeError('This probe qualifies the existing Windows SDK only.')
    scratch.mkdir(parents=True, exist_ok=True)
    # A dedicated empty directory avoids replacing unrelated binaries or loading stale DLLs.
    if any(scratch.iterdir()):
        raise RuntimeError('Use a new empty scratch directory for this probe.')
    lock = json.loads((root/'backend-lock.json').read_text(encoding='utf-8-sig'))
    sdk = sdk_override.resolve() if sdk_override else root/'deps/openssl-install'
    if lock['sdk_root'] != 'deps/openssl-install':
        raise RuntimeError('Unexpected SDK root in lock.')
    files = {}
    for row in lock['sdk_files']:
        rel = row['path']
        if not isinstance(rel, str) or '\\' in rel or ':' in rel or PurePosixPath(rel).is_absolute() or '..' in PurePosixPath(rel).parts:
            raise RuntimeError('Unsafe SDK lock path.')
        if rel in files:
            raise RuntimeError('Duplicate SDK lock path.')
        p = sdk/rel
        if not p.resolve().is_relative_to(sdk.resolve()) or not p.is_file() or digest(p) != row['sha256']:
            raise RuntimeError('SDK hash/path mismatch: '+rel)
        files[rel] = row['sha256']
    if set(files) != {p.relative_to(sdk).as_posix() for p in sdk.rglob('*') if p.is_file()}:
        raise RuntimeError('SDK file set mismatch.')
    version = subprocess.check_output([zig,'version'],text=True).strip()
    if version != lock['zig']:
        raise RuntimeError('Unqualified Zig version: '+version)
    for dll in ('libcrypto-3-x64.dll','libssl-3-x64.dll'):
        shutil.copy2(sdk/'bin'/dll,scratch/dll)
        if digest(scratch/dll) != files['bin/'+dll]:
            raise RuntimeError('Staged runtime mismatch.')
    exe = scratch/'probe-quic-tls.exe'
    command = [zig,'cc','-std=c11','-Wall','-Wextra','-Werror','-I'+str(sdk/'include'),
               str(root/'tools/probe-quic-tls.c'),str(sdk/'lib/libssl.dll.a'),str(sdk/'lib/libcrypto.dll.a'),'-o',str(exe)]
    compilation = subprocess.run(command,capture_output=True,text=True,timeout=120)
    (scratch/'compile.log').write_text(compilation.stdout+compilation.stderr,encoding='utf-8')
    if compilation.returncode:
        raise RuntimeError('Probe compilation failed: '+compilation.stderr)
    env=os.environ.copy()
    env['OPENSSL_CONF']=str(sdk/'ssl/openssl.cnf')
    env['OPENSSL_MODULES']=str(sdk/'lib/ossl-modules')
    report={'scope':'headers/linkage and initial external QUIC TLS callbacks; not completed peer handshake',
            'date_utc':datetime.datetime.now(datetime.timezone.utc).isoformat(),'sdk_lock_sha256':digest(root/'backend-lock.json'),
            'source_sha256':digest(root/'tools/probe-quic-tls.c'),'runner_sha256':digest(Path(__file__)),
            'zig':version,'compile_command':command,'compile_exit':compilation.returncode,
            'sdk_files_verified':len(files),'staged_runtime_sha256':{dll:digest(scratch/dll) for dll in ('libcrypto-3-x64.dll','libssl-3-x64.dll')},'cases':[]}
    for case in ('full','backpressure','fatal-send'):
        result=subprocess.run([str(exe),case,str(root/'tests/fixtures/ca.pem')],cwd=scratch,env=env,capture_output=True,text=True,timeout=10)
        (scratch/(case+'.log')).write_text(result.stdout+result.stderr,encoding='utf-8')
        parsed=json.loads(result.stdout)
        parsed['exit_code']=result.returncode
        report['cases'].append(parsed)
        if result.returncode or not parsed['passed']:
            report['passed']=False
            return report
    report['passed']=True
    return report


def main():
    ap=argparse.ArgumentParser(description=__doc__)
    ap.add_argument('--work-dir',type=Path,required=True)
    ap.add_argument('--zig',default='zig')
    ap.add_argument('--sdk-root',type=Path,help='Optional external exact locked SDK; verified read-only.')
    args=ap.parse_args()
    root=Path(__file__).resolve().parents[1]
    try:
        result=run(root,args.work_dir.resolve(),args.zig,args.sdk_root)
    except (OSError,ValueError,KeyError,TypeError,RuntimeError,subprocess.SubprocessError) as exc:
        result={'passed':False,'error':str(exc)}
    print(json.dumps(result,indent=2))
    raise SystemExit(0 if result['passed'] else 1)


if __name__=='__main__':
    main()
