"""Create fresh mutually authenticated desktop identities and launchers.

Writes only a new private directory; never rotates/replaces an existing pairing.
Repeat runs verify the manifest and return the same pair. No fixture identities,
network requests, firewall changes, certificate-store changes or listening service.
"""
import argparse
import ctypes
import errno
import hashlib
import ipaddress
import json
import os
from pathlib import Path
import shutil
import ssl
import subprocess
import sys
import tempfile
import uuid

ROOT = Path(__file__).resolve().parents[1]


def private_directory(path):
    path.mkdir(mode=0o700)
    if os.name == 'nt':
        # Apply an explicit current-user ACL before any private key is written.
        sid = subprocess.check_output(['whoami', '/user', '/fo', 'csv', '/nh'], text=True).strip().split(',')[-1].strip('"')
        subprocess.run(['icacls', str(path), '/inheritance:r', '/grant:r', f'*{sid}:(OI)(CI)F'], check=True, capture_output=True)


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def publish_directory(source, destination):
    """Atomically publish without replacing even an existing empty directory."""
    if sys.platform == 'win32':
        source.rename(destination)  # Windows rename refuses an existing target.
    elif sys.platform == 'darwin':
        # Plain POSIX rename can replace an empty destination: that is unsafe
        # here. Apple's 10.12+ API provides an explicit no-replacement operation.
        # bsd/sys/stdio.h: RENAME_EXCL = 0x00000004. Unsupported volumes fail.
        native = ctypes.CDLL(None, use_errno=True).renamex_np
        native.argtypes = [ctypes.c_char_p, ctypes.c_char_p, ctypes.c_uint]
        native.restype = ctypes.c_int
        if native(os.fsencode(source), os.fsencode(destination), 4) != 0:
            code = ctypes.get_errno()
            raise OSError(code, os.strerror(code), str(destination))
    else:
        raise ValueError('exclusive directory publication is currently defined for Windows and macOS only')


def verify_pair(output):
    """Verify both old and new pair manifests without rewriting existing files."""
    if (output / 'pair.json').stat().st_size > 32768:
        raise ValueError('pairing manifest is too large')
    manifest = json.loads((output / 'pair.json').read_text(encoding='utf-8'))
    if manifest.get('schema') != 1:
        raise ValueError('unsupported pairing manifest')
    files = manifest.get('files')
    required = {f'{role}/{name}' for role in ('sender', 'receiver')
                for name in ('identity.pem', 'identity.key', 'ca.pem')}
    required.update(('sender/Send.ps1', 'receiver/Receive.command'))
    if not isinstance(files, dict) or not required <= files.keys() or len(files) > 32:
        raise ValueError('incomplete pairing manifest')
    for name, expected in files.items():
        if not isinstance(name, str) or '\\' in name or ':' in name or any(p in ('', '.', '..') for p in name.split('/')):
            raise ValueError('unsafe pairing manifest path')
        path = output / name
        if path.is_symlink() or not path.resolve().is_relative_to(output) or digest(path) != expected:
            raise ValueError(f'pairing was changed: {name}')
    for role in ('sender', 'receiver'):
        actual = hashlib.sha256(ssl.PEM_cert_to_DER_cert((output / role / 'identity.pem').read_text())).hexdigest()
        if manifest.get('fingerprints', {}).get(role) != actual:
            raise ValueError(f'pairing fingerprint was changed: {role}')
    return manifest


def create(output, openssl, receiver_address=None):
    """Publish only a complete private pair; an existing pair is never rotated."""
    if receiver_address is not None:
        receiver_address = str(ipaddress.ip_address(receiver_address))
    if output.is_symlink():
        raise ValueError('pair directory must not be a symbolic link')
    output = output.resolve()
    if output.exists():
        manifest = verify_pair(output)
        if receiver_address is not None:
            configuration = json.loads((output/'sender/lan-audio.json').read_text(encoding='utf-8'))
            home = next((p for p in configuration.get('profiles', []) if p['name'] == 'home'), None)
            if home is None or home['settings'].get('address', configuration.get('defaults', {}).get('address')) != receiver_address:
                raise ValueError('existing address differs; edit the saved profile explicitly instead of recreating the pair')
        return manifest
    if not output.parent.is_dir():
        raise ValueError('output parent must already exist')
    stage = output.parent / ('.' + output.name + '.pair-' + uuid.uuid4().hex)
    try:
        manifest = _create(stage, openssl, receiver_address)
        try:
            publish_directory(stage, output)
        except OSError as error:
            if error.errno not in (errno.EEXIST, errno.ENOTEMPTY) and not isinstance(error, FileExistsError):
                raise
            # Another complete creator won. Adopt only a valid published pair.
            return create(output, openssl, receiver_address)
        return manifest
    finally:
        # This exact, uniquely generated sibling is the only cleanup target.
        if stage.exists():
            if stage.is_symlink() or stage.resolve().parent != output.parent or not stage.name.startswith('.' + output.name + '.pair-'):
                raise ValueError('unsafe staging cleanup target')
            shutil.rmtree(stage)


def _create(output, openssl, receiver_address):
    private_directory(output)
    # Unpublished staging is private. Issuer keys are removed before publication.
    env = dict(os.environ, OPENSSL_CONF=os.devnull)
    def call(*args):
        return subprocess.run([str(openssl), *map(str, args)], env=env, check=True, capture_output=True).stdout
    with tempfile.TemporaryDirectory(prefix='issuer-', dir=output) as issuer_text:
        issuer = Path(issuer_text)
        ca_key, ca_cert = issuer / 'ca.key', issuer / 'ca.pem'
        call('req', '-x509', '-newkey', 'rsa:3072', '-nodes', '-sha256', '-days', '3650',
             '-subj', '/CN=LAN Audio private pair CA', '-keyout', ca_key, '-out', ca_cert,
             '-addext', 'basicConstraints=critical,CA:TRUE,pathlen:0', '-addext', 'keyUsage=critical,keyCertSign,cRLSign')
        fingerprints = {}
        for role in ('sender', 'receiver'):
            directory = output / role
            directory.mkdir(mode=0o700)
            shutil.copyfile(ca_cert, directory / 'ca.pem')
            request = issuer / f'{role}.csr'
            extensions = issuer / f'{role}.ext'
            extensions.write_text('basicConstraints=critical,CA:FALSE\nkeyUsage=critical,digitalSignature\n'
                                  f'extendedKeyUsage={"clientAuth" if role == "sender" else "serverAuth"}\n'
                                  f'subjectAltName=DNS:lan-audio-{role}\n', encoding='ascii')
            call('req', '-new', '-newkey', 'ec', '-pkeyopt', 'ec_paramgen_curve:P-256', '-nodes',
                 '-subj', f'/CN=lan-audio-{role}', '-keyout', directory / 'identity.key', '-out', request)
            call('x509', '-req', '-in', request, '-CA', ca_cert, '-CAkey', ca_key, '-set_serial',
                 '0x' + os.urandom(16).hex(), '-days', '825', '-sha256', '-extfile', extensions, '-out', directory / 'identity.pem')
            call('verify', '-CAfile', ca_cert, '-purpose', 'sslclient' if role == 'sender' else 'sslserver', directory / 'identity.pem')
            fingerprints[role] = hashlib.sha256(ssl.PEM_cert_to_DER_cert((directory / 'identity.pem').read_text())).hexdigest()
            (directory / 'identity.key').chmod(0o600)
    (output / 'sender' / 'Send.ps1').write_text(
        'param([Parameter(Mandatory=$true)][string]$ReceiverAddress, [int]$Seconds = 0)\n'
        '$ErrorActionPreference = "Stop"\n'
        '& (Join-Path $PSScriptRoot "lan-audio.exe") send --address $ReceiverAddress '
        '--ca (Join-Path $PSScriptRoot "ca.pem") --cert (Join-Path $PSScriptRoot "identity.pem") '
        '--key (Join-Path $PSScriptRoot "identity.key") --peer-name lan-audio-receiver '
        f'--peer-fingerprint {fingerprints["receiver"]} --seconds $Seconds\nexit $LASTEXITCODE\n', encoding='utf-8')
    (output / 'receiver' / 'Receive.command').write_text(
        '#!/bin/sh\nset -eu\ncd -- "$(dirname -- "$0")"\nchmod 600 identity.key\n'
        'exec ./lan-audio receive --address "${1:-0.0.0.0}" --ca ./ca.pem '
        '--cert ./identity.pem --key ./identity.key '
        f'--peer-fingerprint {fingerprints["sender"]}\n', encoding='utf-8')
    (output / 'receiver' / 'Receive.command').chmod(0o700)
    for role, peer in [('sender', 'receiver'), ('receiver', 'sender')]:
        settings = dict(role='send' if role == 'sender' else 'receive',
                        address=(receiver_address or 'RECEIVER_IP') if role == 'sender' else '0.0.0.0',
                        ca='ca.pem', cert='identity.pem', key='identity.key',
                        peer_fingerprint=fingerprints[peer])
        if role == 'sender':
            settings.update(peer_name='lan-audio-receiver', capture='system_output')
        configuration = dict(schema=1, defaults=dict(buffer_ms=40, max_buffer_ms=120, reconnect=True),
                             profiles=[dict(name='home', settings=settings)])
        (output / role / 'lan-audio.json').write_text(json.dumps(configuration, indent=2)+'\n', encoding='utf-8')
        identity = dict(schema=1, role=role, fingerprint=fingerprints[role], peer_fingerprint=fingerprints[peer],
                        files={name: digest(output/role/name) for name in ('ca.pem', 'identity.pem', 'identity.key')})
        (output/role/'identity.json').write_text(json.dumps(identity, indent=2)+'\n', encoding='utf-8')
    # Operation profiles are intentionally editable. Reusing a pair validates
    # identity/launcher custody, preserves profile edits, and never rewrites them.
    files = {str(path.relative_to(output)).replace('\\', '/'): digest(path) for path in sorted(output.rglob('*')) if path.is_file() and path.name != 'lan-audio.json'}
    manifest = dict(schema=1, fingerprints=fingerprints, files=files,
                    configuration_files=['sender/lan-audio.json', 'receiver/lan-audio.json'],
                    note='Keep each identity key private. Copy only the receiver folder to the Mac. CA signing key was discarded. Certificates expire after 825 days; create a new explicit pair then.')
    (output / 'pair.json').write_text(json.dumps(manifest, indent=2)+'\n', encoding='utf-8')
    return manifest


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--output', type=Path, required=True)
    parser.add_argument('--openssl', type=Path, default=ROOT/'third_party/tls-zig/deps/openssl-install/bin/openssl.exe')
    parser.add_argument('--receiver-address', help='Numeric receiver IP for a new pair; existing profiles are never overwritten')
    args = parser.parse_args()
    try:
        manifest = create(args.output, args.openssl.resolve(), args.receiver_address)
    except (OSError, ValueError, subprocess.SubprocessError) as error:
        parser.exit(1, f'Pairing failed: {error}\nNo existing identity was replaced.\n')
    print(json.dumps(dict(directory=str(args.output.resolve()), fingerprints=manifest['fingerprints']), indent=2))


if __name__ == '__main__':
    main()
