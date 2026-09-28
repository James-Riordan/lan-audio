"""Create fresh mutually authenticated desktop identities and launchers.

Writes only a new private directory; never rotates/replaces an existing pairing.
Repeat runs verify the manifest and return the same pair. No fixture identities,
network requests, firewall changes, certificate-store changes or listening service.
"""
import argparse
import hashlib
import json
import os
from pathlib import Path
import shutil
import ssl
import subprocess
import tempfile

ROOT = Path(__file__).resolve().parents[1]


def private_directory(path):
    path.mkdir(mode=0o700)
    if os.name == 'nt':
        # Apply an explicit current-user ACL before any private key is written.
        sid = subprocess.check_output(['whoami', '/user', '/fo', 'csv', '/nh'], text=True).strip().split(',')[-1].strip('"')
        subprocess.run(['icacls', str(path), '/inheritance:r', '/grant:r', f'*{sid}:(OI)(CI)F'], check=True, capture_output=True)


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def create(output, openssl):
    output = output.resolve()
    if output.exists():
        manifest = json.loads((output / 'pair.json').read_text(encoding='utf-8'))
        if manifest.get('schema') != 1:
            raise ValueError('unsupported pairing manifest')
        for name, expected in manifest['files'].items():
            path = (output / name).resolve()
            if not path.is_relative_to(output) or digest(path) != expected:
                raise ValueError(f'pairing was changed: {name}')
        return manifest
    if not output.parent.is_dir():
        raise ValueError('output parent must already exist')
    private_directory(output)
    # Failure leaves an incomplete directory for inspection; no automatic retry
    # replaces it. CA key exists only within this private temporary directory.
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
    files = {str(path.relative_to(output)).replace('\\', '/'): digest(path) for path in sorted(output.rglob('*')) if path.is_file()}
    manifest = dict(schema=1, fingerprints=fingerprints, files=files,
                    note='Keep each identity key private. Copy only the receiver folder to the Mac. CA signing key was discarded. Certificates expire after 825 days; create a new explicit pair then.')
    (output / 'pair.json').write_text(json.dumps(manifest, indent=2)+'\n', encoding='utf-8')
    return manifest


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--output', type=Path, required=True)
    parser.add_argument('--openssl', type=Path, default=ROOT.parent/'tls-zig/deps/openssl-install/bin/openssl.exe')
    args = parser.parse_args()
    manifest = create(args.output, args.openssl.resolve())
    print(json.dumps(dict(directory=str(args.output.resolve()), fingerprints=manifest['fingerprints']), indent=2))


if __name__ == '__main__':
    main()
