"""Qualify Zig's exact source selection and a relocated public consumer.

Uses a new evidence directory, controlled cache noise and a self-created tar.
Never edits source, expands package paths, fetches a remote URL or opens a device.
See docs/verification/source-package.md for scope and receipt interpretation.
"""
from __future__ import annotations
import argparse
from datetime import datetime, timezone
import hashlib
import io
import json
import os
from pathlib import Path, PurePosixPath
import re
import shutil
import subprocess
import sys
import tarfile
import time

from check_docs import check, inventory


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def parse_fetch(output):
    """Pinned compiler debug output is a version-specific test interface."""
    files = []
    identities = []
    for line in output.splitlines():
        if line.startswith('file: '):
            match = re.fullmatch(r'file: [0-9a-f]{64}: (.+)', line)
            if not match:
                raise ValueError('malformed compiler file record')
            path = match.group(1)
            pure = PurePosixPath(path)
            if pure.is_absolute() or '..' in pure.parts or '\\' in path or ':' in path or pure.as_posix() != path:
                raise ValueError('noncanonical compiler path')
            files.append(path)
        elif re.fullmatch(r'miniaudio_zig-0\.1\.0-[A-Za-z0-9_-]+', line):
            identities.append(line)
    if not files or len(files) != len(set(files)) or len(identities) != 1:
        raise ValueError('missing/duplicate package evidence')
    return set(files), identities[0]


def require_selection(observed, expected):
    if observed != set(expected):
        raise ValueError(f'package selection mismatch: missing={sorted(set(expected)-observed)}, extra={sorted(observed-set(expected))}')


def consumer_pass(returncode, output):
    return (returncode == 0 and '1/1 tests passed' in output
            and re.search(r'\brun test 1 pass \(1 total\)', output) is not None)


def write_archive(root, files, target):
    """Deterministic metadata for this platform-independent source tar profile."""
    with tarfile.open(target, 'w', format=tarfile.USTAR_FORMAT) as archive:
        for rel in sorted(files):
            data = (root/rel).read_bytes()
            info = tarfile.TarInfo('miniaudio-zig/'+rel)
            info.size, info.mode, info.mtime = len(data), 0o644, 0
            info.uid = info.gid = 0
            info.uname = info.gname = ''
            archive.addfile(info, io.BytesIO(data))


def extract_own_archive(archive_path, expected, destination, prefix='miniaudio-zig/'):
    """Bound extraction to the exact known manifest; links/extra members fail."""
    with tarfile.open(archive_path, 'r:*') as archive:
        members = archive.getmembers()
        names = [prefix+p for p in expected]
        if len(members) != len(names) or {m.name for m in members} != set(names):
            raise ValueError('archive members differ from source closure')
        for member in members:
            if not member.isfile():
                raise ValueError('archive member is not a regular file')
            rel = member.name.removeprefix(prefix)
            pure = PurePosixPath(rel)
            if pure.is_absolute() or '..' in pure.parts or ':' in rel or '\\' in rel or pure.as_posix() != rel:
                raise ValueError('unsafe archive member')
            content = archive.extractfile(member).read()
            if hashlib.sha256(content).hexdigest() != expected[rel]:
                raise ValueError('archive bytes differ: '+rel)
            target = destination/rel
            target.parent.mkdir(parents=True, exist_ok=True)
            target.write_bytes(content)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--output', type=Path, required=True)
    parser.add_argument('--zig', default='zig')
    parser.add_argument('--timeout', type=float, default=300)
    args = parser.parse_args()
    root = Path(__file__).resolve().parents[1]
    output = args.output.resolve()
    if args.timeout <= 0 or output.exists():
        parser.error('positive timeout and a new output directory are required')
    if output.is_relative_to(root) and not output.is_relative_to(root/'verification'):
        parser.error('in-project output must be under verification/')
    errors = check(root)
    if errors:
        parser.error('; '.join(errors))
    paths, errors = inventory(root)
    if errors:
        parser.error('; '.join(errors))
    sources = {p:digest(root/p) for p in sorted(paths)}
    compiler = re.search(r'\.minimum_zig_version\s*=\s*"([^"]+)"', (root/'build.zig.zon').read_text()).group(1)
    output.mkdir(parents=True)
    env = dict(os.environ, LC_ALL='C', LANG='C', PYTHONDONTWRITEBYTECODE='1',
               ZIG_GLOBAL_CACHE_DIR=str(output/'global-cache'),
               ZIG_LOCAL_CACHE_DIR=str(output/'local-cache'))
    receipt = dict(schema=1, phase='source-package', started_utc=datetime.now(timezone.utc).isoformat(),
                   source_root=str(root), sources=sources, commands=[], complete=False,
                   limits=['Source closure and two native consumer configurations only.',
                           'No clean-machine runtime, physical audio, Mac or public release qualification.',
                           'Compiler debug-file format is qualified only for the pinned compiler.',
                           'Timeout kills the direct process; inspect descendants before any cleanup.'])

    def save():
        (output/'receipt.json').write_text(json.dumps(receipt,indent=2)+'\n',encoding='utf-8')

    def run(name, command, cwd):
        start = time.monotonic()
        try:
            result = subprocess.run(command,cwd=cwd,env=env,capture_output=True,text=True,
                encoding='utf-8',errors='replace',timeout=args.timeout)
            code, logtext = result.returncode, result.stdout+result.stderr
        except (OSError,subprocess.TimeoutExpired) as exc:
            code, logtext = None, str(exc)
        log = output/(name+'.log')
        log.write_text(logtext,encoding='utf-8')
        receipt['commands'].append(dict(name=name,command=command,cwd=str(cwd),returncode=code,
            elapsed_seconds=round(time.monotonic()-start,3),log=log.name,log_sha256=digest(log)))
        save()
        if code != 0:
            raise ValueError(name+' did not execute successfully')
        return code, logtext

    save()
    try:
        _, version = run('compiler',[args.zig,'version'],root)
        if version.strip() != compiler:
            raise ValueError('exact qualification compiler required: '+compiler)
        receipt['compiler_version'] = version.strip()
        run('package-format',[args.zig,'fmt','--check',str(root/'build.zig.zon')],root)
        _, text = run('live-selection',[args.zig,'fetch','--debug-hash',str(root)],root)
        selected, identity = parse_fetch(text)
        require_selection(selected,sources)
        receipt['package_identity'] = identity

        staged = output/'source space \u03a9'/'miniaudio-zig'
        for rel in sources:
            dest=staged/rel;dest.parent.mkdir(parents=True,exist_ok=True)
            shutil.copy2(root/rel,dest)
        noise = ['tests/__pycache__/probe.pyc','tests/consumer/.zig-cache/probe.bin',
                 'tools/__pycache__/probe.pyc','docs/unreviewed.tmp','verification/probe.log']
        for rel in noise:
            dest=staged/rel;dest.parent.mkdir(parents=True,exist_ok=True)
            dest.write_bytes(b'UNREVIEWED GENERATED TEST NOISE\n')
        _, text = run('noisy-selection',[args.zig,'fetch','--debug-hash',str(staged)],staged)
        noisy_files, noisy_id = parse_fetch(text)
        require_selection(noisy_files,sources)
        if noisy_id != identity:
            raise ValueError('location/cache noise changed package identity')

        archive=output/'miniaudio-zig-source.tar'
        repeat=output/'repeat-source.tar'
        write_archive(staged,sources,archive)
        write_archive(staged,sources,repeat)
        if digest(archive) != digest(repeat):
            raise ValueError('archive metadata is not deterministic')
        receipt['archive_sha256']=digest(archive)
        _, text = run('archive-selection',[args.zig,'fetch','--debug-hash',str(archive)],root)
        archive_files, archive_id = parse_fetch(text)
        require_selection(archive_files,sources)
        if archive_id != identity:
            raise ValueError('archive source identity differs')

        relocated=output/'relocated space \u03a9'/'miniaudio-zig'
        cached=output/'global-cache'/'p'/(identity+'.tar.gz')
        receipt['compiler_package_archive_sha256']=digest(cached)
        extract_own_archive(cached,sources,relocated,prefix=identity+'/miniaudio-zig/')
        run('relocated-docs',[sys.executable,str(relocated/'tools/check_docs.py')],relocated)
        run('relocated-vendor',[sys.executable,str(relocated/'tools/check_vendor.py')],relocated)
        for mode,null_only in [('Debug',False),('ReleaseSafe',True)]:
            label=mode.lower()+('-null' if null_only else '-native')
            code,text=run('consumer-'+label,[args.zig,'build','test','--summary','all',
                '-Doptimize='+mode,'-Dnull-backend='+str(null_only).lower(),
                '--cache-dir',str(output/('build-cache-'+label))],relocated/'tests/consumer')
            if not consumer_pass(code,text):
                raise ValueError('consumer did not report one freshly executed test')
        if sources != {p:digest(root/p) for p in sources}:
            raise ValueError('source bytes changed during qualification')
        current_paths,current_errors=inventory(root)
        if current_errors or current_paths != set(sources):
            raise ValueError('authored source inventory changed during qualification')
        for rel,value in sources.items():
            if digest(relocated/rel) != value:
                raise ValueError('relocated authored input changed: '+rel)
        receipt.update(complete=True,source_unchanged=True,relocated_source_unchanged=True,
            noise_excluded=noise,completed_utc=datetime.now(timezone.utc).isoformat())
        save()
        print('PASS: exact source selection, deterministic tar, relocation and two fresh public consumers')
        return 0
    except (ValueError,OSError,tarfile.TarError) as exc:
        receipt['failure']=str(exc);save()
        print('FAIL:',exc)
        return 1


if __name__ == '__main__':
    raise SystemExit(main())
