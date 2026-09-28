"""Repeat-safe private desktop installation from explicit local build and pair inputs.

Stages immutable runtime/identity files plus an editable profile, checks the real
CLI, and publishes a complete directory. Existing installations are verified, never
silently updated. No downloads, firewall edits, services, PATH edits or audio starts.
See docs/runtime/desktop-setup.md for trust, publication and recovery boundaries.
"""
import argparse
import errno
import hashlib
import ipaddress
import json
import os
from pathlib import Path
import platform
import shutil
import ssl
import subprocess
import sys
import uuid

from create_pair import create, private_directory, publish_directory, verify_pair

ROOT = Path(__file__).resolve().parents[1]
IDENTITY_FILES = {'ca.pem', 'identity.pem', 'identity.key'}
TARGET_FILES = {
    'windows-x86_64': ('lan-audio.exe', 'libssl-3-x64.dll', 'libcrypto-3-x64.dll'),
    'macos-x86_64': ('lan-audio',),
}


def unique_object(pairs):
    result = {}
    for key, value in pairs:
        if key in result:
            raise ValueError(f'duplicate JSON field: {key}')
        result[key] = value
    return result


def read_json(path):
    if path.is_symlink() or not path.is_file() or path.stat().st_size > 65536:
        raise ValueError(f'expected a regular JSON file of at most 64 KiB: {path.name}')
    with path.open(encoding='utf-8') as stream:
        value = json.load(stream, object_pairs_hook=unique_object)
    if not isinstance(value, dict):
        raise ValueError('expected a JSON object')
    return value


def sha(data):
    return hashlib.sha256(data).hexdigest()


def host_target():
    if platform.machine().lower() not in ('amd64', 'x86_64'):
        raise ValueError('desktop setup currently needs an x86_64 Windows PC or Intel Mac')
    if sys.platform == 'win32':
        return 'windows-x86_64'
    if sys.platform == 'darwin':
        return 'macos-x86_64'
    raise ValueError('desktop setup currently supports Windows and Intel macOS')


def snapshot(folder, names):
    files = {}
    for name in names:
        path = folder/name
        if path.is_symlink() or not path.is_file() or not path.resolve().is_relative_to(folder):
            raise ValueError(f'missing or linked input: {name}')
        if path.stat().st_size > 64*1024*1024:
            raise ValueError(f'input exceeds setup size limit: {name}')
        files[name] = path.read_bytes()
    return files


def identity(folder):
    value = read_json(folder/'identity.json')
    if set(value) != {'schema', 'role', 'fingerprint', 'peer_fingerprint', 'files'} or type(value['schema']) is not int or value['schema'] != 1:
        raise ValueError('unsupported identity metadata; use a complete freshly generated role folder')
    if value['role'] not in ('sender', 'receiver') or not isinstance(value['files'], dict) or set(value['files']) != IDENTITY_FILES:
        raise ValueError('invalid identity role or file set')
    for field in ('fingerprint', 'peer_fingerprint'):
        text = value[field]
        if not isinstance(text, str) or len(text) != 64 or any(c not in '0123456789abcdef' for c in text):
            raise ValueError('invalid identity fingerprint')
    files = snapshot(folder, IDENTITY_FILES)
    if {name: sha(data) for name, data in files.items()} != value['files']:
        raise ValueError('identity files differ from their pairing metadata')
    actual = sha(ssl.PEM_cert_to_DER_cert(files['identity.pem'].decode('ascii')))
    if actual != value['fingerprint']:
        raise ValueError('identity certificate fingerprint differs')
    files['identity.json'] = (json.dumps(value, indent=2)+'\n').encode('utf-8')
    return value, files


def check_binding(configuration, selected):
    """Pair authority is fixed; operational settings remain editable."""
    profiles = configuration.get('profiles')
    defaults = configuration.get('defaults', {})
    if not isinstance(profiles, list) or not profiles or not isinstance(defaults, dict):
        raise ValueError('invalid operation profiles')
    home = None
    for profile in profiles:
        if not isinstance(profile, dict) or not isinstance(profile.get('settings'), dict):
            raise ValueError('invalid profile')
        settings = {**defaults, **profile['settings']}
        expected = dict(role='send' if selected['role'] == 'sender' else 'receive',
                        ca='ca.pem', cert='identity.pem', key='identity.key', peer_fingerprint=selected['peer_fingerprint'])
        if selected['role'] == 'sender':
            expected['peer_name'] = 'lan-audio-receiver'
        if any(settings.get(key) != value for key, value in expected.items()):
            raise ValueError('configuration does not match the selected private pair')
        if profile.get('name') == 'home':
            if home is not None:
                raise ValueError('duplicate home profile')
            home = settings
    if home is None:
        raise ValueError('setup requires a home profile')
    return home


def check_credentials(folder):
    # Uses the platform Python TLS parser to catch malformed CA data and a
    # mismatched private key. This is not an expiry/purpose/remote-trust check.
    context = ssl.SSLContext(ssl.PROTOCOL_TLS_CLIENT)
    context.load_verify_locations(cafile=str(folder/'ca.pem'))
    context.load_cert_chain(str(folder/'identity.pem'), str(folder/'identity.key'))


def validate(folder, target):
    binary = folder/TARGET_FILES[target][0]
    result = subprocess.run([str(binary), 'check'], cwd=folder.parent, capture_output=True, timeout=20)
    if result.returncode != 0:
        detail = result.stderr.decode('utf-8', errors='replace').strip()
        raise ValueError(f'application settings check failed: {detail or result.returncode}')
    report = json.loads(result.stdout)
    if report.get('valid') is not True or report.get('profile') != 'home':
        raise ValueError('application did not confirm the home profile')
    return report


def install(pair, application, output, receiver_address=None, check_only=False):
    """A successful rerun preserves every byte of an existing installation."""
    target = host_target()
    if any(path.is_symlink() for path in (pair, application, output)):
        raise ValueError('setup directories must not be symbolic links')
    pair, application, output = pair.resolve(), application.resolve(), output.resolve()
    if any(output.is_relative_to(source) or source.is_relative_to(output) for source in (pair, application)):
        raise ValueError('installation must be separate from pair and build inputs')
    if not output.parent.is_dir():
        raise ValueError('installation parent directory must already exist')
    selected, files = identity(pair)
    if selected['role'] == 'sender' and target != 'windows-x86_64':
        raise ValueError('system-output sending is currently Windows-only')
    files.update(snapshot(application, TARGET_FILES[target]))
    configuration = read_json(pair/'lan-audio.json')
    check_binding(configuration, selected)
    if receiver_address is not None:
        if selected['role'] != 'sender':
            raise ValueError('receiver-address applies only to a sender installation')
        receiver_address = str(ipaddress.ip_address(receiver_address))
        for profile in configuration['profiles']:
            if profile['name'] == 'home':
                profile['settings']['address'] = receiver_address
    expected = dict(schema=1, target=target, role=selected['role'],
                    files={name: sha(data) for name, data in files.items()})
    if output.exists():
        recorded = read_json(output/'installation.json')
        if recorded != expected:
            raise ValueError('installation differs from these build/pair inputs; use a new destination for an update')
        installed = snapshot(output, files.keys())
        if {name: sha(data) for name, data in installed.items()} != expected['files']:
            raise ValueError('installed application or identity was changed; nothing was overwritten')
        home = check_binding(read_json(output/'lan-audio.json'), selected)
        if receiver_address is not None and home.get('address') != receiver_address:
            raise ValueError('saved address differs; edit lan-audio.json explicitly, then repeat setup')
        check_credentials(output)
        validate(output, target)
        return dict(status='verified-existing', directory=str(output), target=target, role=selected['role'])
    if check_only:
        raise ValueError('installation does not exist; check mode does not create it')
    stage = output.parent / ('.' + output.name + '.setup-' + uuid.uuid4().hex)
    try:
        private_directory(stage)
        for name, data in files.items():
            (stage/name).write_bytes(data)
            (stage/name).chmod(0o700 if name in TARGET_FILES[target] else 0o600)
        (stage/'lan-audio.json').write_text(json.dumps(configuration, indent=2)+'\n', encoding='utf-8')
        check_credentials(stage)
        validate(stage, target)
        (stage/'installation.json').write_text(json.dumps(expected, indent=2)+'\n', encoding='utf-8')
        try:
            publish_directory(stage, output)
        except OSError as error:
            if error.errno not in (errno.EEXIST, errno.ENOTEMPTY) and not isinstance(error, FileExistsError):
                raise
            return install(pair, application, output, receiver_address, check_only=True)
        return dict(status='installed', directory=str(output), target=target, role=selected['role'])
    finally:
        if stage.exists():
            if stage.is_symlink() or stage.resolve().parent != output.parent or not stage.name.startswith('.' + output.name + '.setup-'):
                raise ValueError('unsafe staging cleanup target')
            shutil.rmtree(stage)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--config', type=Path, help='Declarative setup JSON; paths are relative to this file')
    parser.add_argument('--pair', type=Path, help='One sender or receiver folder from a fresh private pair')
    parser.add_argument('--application', type=Path, help='Built executable/runtime folder (default: source zig-out/bin)')
    parser.add_argument('--output', type=Path, help='Private destination (default: ~/LAN Audio)')
    parser.add_argument('--receiver-address', help='Set the sender home address on first installation only')
    parser.add_argument('--create-pair', action='store_true', help='Windows: create/verify a full pair at --pair and install its sender')
    parser.add_argument('--check', action='store_true', help='Verify an existing installation without writing it')
    args = parser.parse_args()
    try:
        if args.config:
            if any((args.pair, args.application, args.output, args.receiver_address, args.create_pair)):
                raise ValueError('--config cannot be combined with setup overrides')
            document = read_json(args.config)
            if type(document.get('schema')) is not int or document['schema'] != 1 or not {'pair', 'application', 'output'} <= document.keys() or set(document) - {'schema', 'pair', 'application', 'output', 'receiver_address', 'create_pair'}:
                raise ValueError('setup schema 1 requires pair, application, output and optional receiver_address')
            base = args.config.resolve().parent
            for name in ('pair', 'application', 'output'):
                if not isinstance(document[name], str) or not document[name].strip():
                    raise ValueError(f'invalid setup path: {name}')
                setattr(args, name, base/document[name])
            args.receiver_address = document.get('receiver_address')
            if args.receiver_address is not None and not isinstance(args.receiver_address, str):
                raise ValueError('receiver_address must be a numeric IP string')
            args.create_pair = document.get('create_pair', False)
            if type(args.create_pair) is not bool:
                raise ValueError('create_pair must be a boolean')
        if args.pair is None:
            raise ValueError('provide --pair or --config; private identities are never guessed')
        receiver_folder = None
        if args.create_pair:
            if host_target() != 'windows-x86_64':
                raise ValueError('create-pair is the Windows sender bootstrap; use --pair receiver on the Mac')
            if args.receiver_address is None:
                raise ValueError('create-pair needs the Mac numeric --receiver-address')
            # Catch missing builds before provisioning. Publication remains split:
            # a valid pair survives later installation failure and is reused.
            snapshot((args.application or ROOT/'zig-out/bin').resolve(), TARGET_FILES['windows-x86_64'])
            if args.check:
                verify_pair(args.pair.resolve())
            else:
                create(args.pair, ROOT.parent/'tls-zig/deps/openssl-install/bin/openssl.exe', args.receiver_address)
            receiver_folder = str(args.pair.resolve()/'receiver')
            args.pair = args.pair/'sender'
        result = install(args.pair, args.application or ROOT/'zig-out/bin', args.output or Path.home()/'LAN Audio', args.receiver_address, args.check)
        if receiver_folder:
            result['transfer_to_mac'] = receiver_folder
        print(json.dumps(result, indent=2))
        binary = Path(result['directory']) / TARGET_FILES[result['target']][0]
        # Both OSs use the same native verbs; no Python process stays in the audio path.
        if os.name == 'nt':
            quoted = str(binary).replace("'", "''")
            print(f"Ready. In PowerShell: & '{quoted}' start")
        else:
            import shlex
            print(f'Ready. In Terminal: {shlex.quote(str(binary))} start')
        print('Start the receiver first. Ctrl+C on the sender stops the stream.')
    except (OSError, ValueError, KeyError, TypeError, subprocess.SubprocessError) as error:
        parser.exit(1, f'Setup stopped: {error}\nExisting application files and private identities were not replaced.\n')


if __name__ == '__main__':
    main()
