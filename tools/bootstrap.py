"""Clone-local tool/build bootstrap. Downloads are pinned; secrets live outside Git.

The launcher is control-plane only. Native workers remain the audio data path.
See docs/runtime/repository-launcher.md for trust, recovery and qualification.
"""
import argparse
from contextlib import contextmanager
import hashlib
import json
import os
from pathlib import Path
import platform
import shutil
import subprocess
import sys
import tarfile
import tempfile
import urllib.request
import uuid
import zipfile

sys.path.insert(0, str(Path(__file__).resolve().parent))
from create_pair import private_directory
from setup_desktop import host_target, read_json, install, TARGET_FILES

ROOT = Path(__file__).resolve().parents[1]
ASSETS = read_json(ROOT/'tools/bootstrap_assets.json')


def digest(path):
    h = hashlib.sha256()
    with path.open('rb') as stream:
        for block in iter(lambda: stream.read(1024*1024), b''):
            h.update(block)
    return h.hexdigest()


@contextmanager
def exclusive(path):
    """OS releases the advisory byte lock after a crash; no stale PID guessing."""
    if path.is_symlink():
        raise ValueError('lock must not be a symbolic link')
    with path.open('a+b') as stream:
        stream.seek(0)
        if os.name == 'nt':
            import msvcrt
            if path.stat().st_size == 0:
                stream.write(b'0'); stream.flush(); stream.seek(0)
            try:
                msvcrt.locking(stream.fileno(), msvcrt.LK_NBLCK, 1)
            except OSError:
                raise ValueError('LAN Audio is already running or being prepared here') from None
        else:
            import fcntl
            try:
                fcntl.flock(stream.fileno(), fcntl.LOCK_EX | fcntl.LOCK_NB)
            except OSError:
                raise ValueError('LAN Audio is already running or being prepared here') from None
        try:
            yield
        finally:
            stream.seek(0)
            if os.name == 'nt':
                msvcrt.locking(stream.fileno(), msvcrt.LK_UNLCK, 1)
            else:
                fcntl.flock(stream.fileno(), fcntl.LOCK_UN)


def atomic_json(path, value):
    if path.is_symlink():
        raise ValueError('configuration must not be a symbolic link')
    temporary = path.with_name('.'+path.name+'.'+uuid.uuid4().hex)
    try:
        with temporary.open('x', encoding='utf-8') as stream:
            json.dump(value, stream, indent=2); stream.write('\n')
            stream.flush(); os.fsync(stream.fileno())
        os.replace(temporary, path)
    finally:
        temporary.unlink(missing_ok=True)


def verify_dependencies():
    # This large, checked-in manifest is deliberately separate from 64 KiB user JSON.
    lock = json.loads((ROOT/'third_party/lock.json').read_text(encoding='utf-8'))
    base = (ROOT/'third_party').resolve()
    for name, expected in lock['files'].items():
        p = base/name
        if p.is_symlink() or not p.resolve().is_relative_to(base) or digest(p) != expected:
            raise ValueError('reviewed dependency changed: '+name)
    from check_transport import verify
    verify()


def download(asset, cache):
    destination = cache/(asset['sha256']+'.'+asset['archive'])
    if destination.is_symlink():
        raise ValueError('download cache must not be linked')
    if destination.exists():
        if digest(destination) != asset['sha256']:
            raise ValueError('cached archive changed; remove that archive and retry: '+str(destination))
        return destination
    errors = []
    for url in asset['urls']:
        if not url.startswith('https://'):
            raise ValueError('downloads require HTTPS')
        temporary = cache/('download-'+uuid.uuid4().hex)
        try:
            print('Downloading '+url.split('?')[0], flush=True)
            with urllib.request.urlopen(url, timeout=45) as response, temporary.open('xb') as stream:
                if not response.geturl().startswith('https://'):
                    raise ValueError('insecure download redirect')
                total = 0
                while block := response.read(1024*1024):
                    total += len(block)
                    if total > asset['size']:
                        raise ValueError('archive exceeds pinned size limit')
                    stream.write(block)
            if digest(temporary) != asset['sha256']:
                raise ValueError('download SHA256 mismatch')
            temporary.rename(destination)
            return destination
        except (OSError, ValueError) as error:
            errors.append(str(error))
        finally:
            temporary.unlink(missing_ok=True)
    raise ValueError('All pinned download locations failed: '+'; '.join(errors))


def extract(archive, destination, kind):
    """Only ordinary files/directories; no links, traversal, duplicate or device members."""
    seen = set()
    def target(name):
        parts = name.rstrip('/').split('/')
        if not parts or any(p in ('', '.', '..') for p in parts) or '\\' in name or ':' in name:
            raise ValueError('unsafe archive member')
        key = name.rstrip('/').casefold()
        if key in seen:
            raise ValueError('duplicate archive member')
        seen.add(key)
        return destination.joinpath(*parts)
    total = 0
    if kind == 'zip':
        with zipfile.ZipFile(archive) as source:
            for item in source.infolist():
                path = target(item.filename)
                mode = item.external_attr >> 16
                if mode & 0o170000 == 0o120000:
                    raise ValueError('archive symlink rejected')
                total += item.file_size
                if total > 1024*1024*1024:
                    raise ValueError('archive expansion exceeds 1 GiB')
                if item.is_dir():
                    path.mkdir(parents=True, exist_ok=True)
                else:
                    path.parent.mkdir(parents=True, exist_ok=True)
                    with source.open(item) as src, path.open('xb') as dst:
                        shutil.copyfileobj(src, dst)
    else:
        with tarfile.open(archive) as source:
            for item in source:
                path = target(item.name)
                total += item.size
                if total > 1024*1024*1024:
                    raise ValueError('archive expansion exceeds 1 GiB')
                if item.isdir():
                    path.mkdir(parents=True, exist_ok=True)
                elif item.isfile():
                    path.parent.mkdir(parents=True, exist_ok=True)
                    with source.extractfile(item) as src, path.open('xb') as dst:
                        shutil.copyfileobj(src, dst)
                    path.chmod(0o755 if item.mode & 0o111 else 0o644)
                else:
                    raise ValueError('archive link/device rejected')


def run(command, **kwargs):
    env = dict(os.environ, LANG='C', LC_ALL='C', ZIG_GLOBAL_CACHE_DIR=str(ROOT/'.lan-audio/zig-global'))
    subprocess.run(list(map(str, command)), cwd=ROOT, env=env, check=True, **kwargs)


def compiler(cache, target):
    asset = ASSETS['zig-'+target]
    archive = download(asset, cache)
    folder = cache/('zig-'+asset['sha256'][:16])
    binary = 'zig.exe' if target.startswith('windows') else 'zig'
    if not folder.exists():
        with tempfile.TemporaryDirectory(prefix='zig-stage-', dir=cache) as text:
            stage = Path(text)
            extract(archive, stage, asset['archive'])
            roots = list(stage.iterdir())
            if len(roots) != 1 or not (roots[0]/binary).is_file():
                raise ValueError('unexpected compiler archive layout')
            roots[0].rename(folder)
    path = folder/binary
    actual = subprocess.check_output([str(path), 'version'], text=True, timeout=20).strip()
    if actual != ASSETS['zig_version']:
        raise ValueError('compiler differs from the pinned version')
    return path


def source_key(target):
    h = hashlib.sha256(target.encode())
    paths = [ROOT/'build.zig', ROOT/'build.zig.zon', ROOT/'third_party/lock.json', ROOT/'tools/bootstrap_assets.json', ROOT/'tools/build_mac_candidate.py', ROOT/'tools/bootstrap.py']
    paths += sorted(p for p in (ROOT/'src').rglob('*') if p.is_file())
    for path in paths:
        h.update(path.relative_to(ROOT).as_posix().encode()); h.update(path.read_bytes())
    return h.hexdigest()[:24]


def prepare(cache, target):
    verify_dependencies()
    prefix = cache/'builds'/source_key(target)
    receipt = prefix/'ready.json'
    if receipt.exists():
        value = read_json(receipt)
        if all(digest(prefix/'bin'/name) == expected for name, expected in value['files'].items()) and set(value['files']) == set(TARGET_FILES[target]):
            print('Using the verified local build.', flush=True)
            return prefix/'bin'
        raise ValueError('cached build changed; use a clean clone/cache to rebuild')
    if target == 'macos-x86_64' and int(platform.mac_ver()[0].split('.')[0]) < 14:
        from desktop_release import fetch
        return fetch(cache, target, prefix)
    zig = compiler(cache, target)
    arguments = []
    if target == 'macos-x86_64':
        if subprocess.run(['xcrun', '--find', 'clang'], capture_output=True).returncode:
            raise ValueError('Apple developer tools are required. Run xcode-select --install, finish installation, then rerun sh start.')
        sdk_record = cache/'mac-sdk.json'
        if sdk_record.exists():
            sdk = Path(read_json(sdk_record)['path'])
            evidence = json.loads((sdk.parent/'sdk.json').read_text())
            if any(digest(sdk/p) != h for p,h in evidence['files'].items()):
                raise ValueError('cached Mac SDK changed')
        else:
            archive = download(ASSETS['openssl'], cache)
            attempt = cache/('mac-build-'+uuid.uuid4().hex)
            print('Building and testing OpenSSL for this Mac. Logs: '+str(attempt), flush=True)
            run([sys.executable, ROOT/'tools/build_mac_candidate.py', '--openssl-archive', archive, '--output', attempt, '--zig', zig])
            sdk = attempt/'openssl-static'
            atomic_json(sdk_record, dict(path=str(sdk)))
        arguments = ['-Dstreaming=true', '-Dtarget=x86_64-macos.12.0', '-Dmac-openssl-root='+str(sdk)]
    print('Building LAN Audio (one build job).', flush=True)
    run([zig, 'build', 'app', '-j1', '-Doptimize=ReleaseSafe', '--prefix', prefix,
         '--cache-dir', cache/'zig-local', *arguments])
    run([prefix/'bin'/TARGET_FILES[target][0], 'help'], stdout=subprocess.DEVNULL)
    atomic_json(receipt, dict(files={name:digest(prefix/'bin'/name) for name in TARGET_FILES[target]}))
    return prefix/'bin'


def default_state():
    if os.name == 'nt':
        return Path(os.environ['LOCALAPPDATA'])/'LAN Audio'
    return Path.home()/'Library/Application Support/LAN Audio'


def main():
    parser = argparse.ArgumentParser(description='Build, pair once, and start LAN Audio.')
    parser.add_argument('--prepare', action='store_true', help='Download/build only; do not pair or open audio')
    parser.add_argument('--config', type=Path, help='Use a specific launcher JSON; otherwise use lan-audio.launch.json beside start')
    args = parser.parse_args()
    try:
        target = host_target()
        from launcher_config import resolve
        config_path = args.config or ROOT/'lan-audio.launch.json'
        configuration = resolve(config_path, target)
        state = configuration.get('state_directory', default_state())
        if state.resolve().is_relative_to(ROOT) or state.resolve() == Path.home().resolve():
            raise ValueError('private state must be a dedicated directory outside the source checkout')
        cache = ROOT/'.lan-audio'
        if cache.is_symlink() or not cache.resolve().is_relative_to(ROOT):
            raise ValueError('checkout cache must not redirect outside the source directory')
        cache.mkdir(exist_ok=True)
        print('Settings: '+str(config_path.resolve()), flush=True)
        print('Preparing '+('Windows sender' if target == 'windows-x86_64' else 'Mac receiver')+'...', flush=True)
        with exclusive(cache/'bootstrap.lock'):
            application = prepare(cache, target)
        if args.prepare:
            print('Build ready: '+str(application)); return
        if not state.exists():
            state.parent.mkdir(parents=True, exist_ok=True); private_directory(state)
        if state.is_symlink():
            raise ValueError('state directory must not be a link')
        from local_pairing import connect_and_run
        with exclusive(state/'session.lock'):
            connect_and_run(state, application, target, configuration.get('receiver_address'), configuration['audio'])
    except KeyboardInterrupt:
        print('\nStopped. Run the same command to retry.'); sys.exit(130)
    except EOFError:
        parser.exit(1, 'First pairing needs an interactive terminal. Run the same start command there; saved identities were retained.\n')
    except (OSError, ValueError, KeyError, TypeError, subprocess.SubprocessError) as error:
        parser.exit(1, f'LAN Audio stopped: {error}\nYour saved pair was not rotated. Fix the reported issue and rerun the same command.\n')


if __name__ == '__main__':
    main()
