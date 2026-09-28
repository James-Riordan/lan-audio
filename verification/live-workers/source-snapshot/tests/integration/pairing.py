"""Independent TLS validation of fresh pairing material; never saves private keys."""
import hashlib
import json
import os
from pathlib import Path
import socket
import ssl
import subprocess
import sys
import tempfile
import threading

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / 'tools'))
from create_pair import create


def exercise():
    openssl = ROOT.parent / 'tls-zig/deps/openssl-install/bin/openssl.exe'
    with tempfile.TemporaryDirectory(prefix='lan-audio-pair-test-') as temporary:
        output = Path(temporary) / 'pair with spaces'
        original = create(output, openssl)
        repeated = create(output, openssl)
        assert original == repeated
        assert not list(output.glob('issuer-*'))
        receiver, sender = output / 'receiver', output / 'sender'
        server = ssl.SSLContext(ssl.PROTOCOL_TLS_SERVER)
        server.minimum_version = ssl.TLSVersion.TLSv1_3
        server.load_cert_chain(receiver / 'identity.pem', receiver / 'identity.key')
        server.load_verify_locations(receiver / 'ca.pem')
        server.verify_mode = ssl.CERT_REQUIRED
        server.set_alpn_protocols(['jcr-audio/2'])
        client = ssl.create_default_context(cafile=sender / 'ca.pem')
        client.minimum_version = ssl.TLSVersion.TLSv1_3
        client.load_cert_chain(sender / 'identity.pem', sender / 'identity.key')
        client.set_alpn_protocols(['jcr-audio/2'])
        observations = []
        def serve(listener):
            try:
                raw, _ = listener.accept()
                raw.settimeout(5)
                with server.wrap_socket(raw, server_side=True) as channel:
                    observations.append(hashlib.sha256(channel.getpeercert(binary_form=True)).hexdigest())
                    assert channel.recv(4) == b'pair'
                    channel.sendall(b'pass')
                    channel.unwrap().close()
            except Exception as error:
                observations.append(str(error))
        with socket.socket() as listener:
            listener.bind(('127.0.0.1', 0))
            listener.listen(1)
            listener.settimeout(5)
            thread = threading.Thread(target=serve, args=(listener,))
            thread.start()
            with socket.create_connection(listener.getsockname(), timeout=5) as raw:
                with client.wrap_socket(raw, server_hostname='lan-audio-receiver') as channel:
                    assert hashlib.sha256(channel.getpeercert(binary_form=True)).hexdigest() == original['fingerprints']['receiver']
                    assert channel.selected_alpn_protocol() == 'jcr-audio/2'
                    channel.sendall(b'pair')
                    assert channel.recv(4) == b'pass'
                    channel.unwrap().close()
            thread.join(6)
            assert not thread.is_alive() and observations == [original['fingerprints']['sender']]
        # A second request must not silently repair/rotate changed credentials.
        (sender / 'identity.pem').write_text('changed', encoding='ascii')
        try:
            create(output, openssl)
        except ValueError:
            pass
        else:
            raise AssertionError('changed pairing was silently accepted')
    executable = ROOT / 'zig-out/bin/lan-audio.exe'
    rejected = []
    for args in [['send'], ['receive', '--unknown', 'x'], ['send', '--address', '127.0.0.1', '--address', '127.0.0.1'], ['send', '--peer-fingerprint', 'bad']]:
        result = subprocess.run([str(executable), *args], capture_output=True, text=True, timeout=5)
        assert result.returncode != 0 and 'Stream stopped:' in result.stderr and 'Listening' not in result.stderr
        rejected.append(result.stderr.strip())
    return dict(fresh_mtls_exchange=True, repeat_preserved=True, changed_pair_rejected=True, issuer_key_removed=True,
                path_with_spaces=True, invalid_cli=rejected, platform=os.name)


if __name__ == '__main__':
    print(json.dumps(exercise(), indent=2))
