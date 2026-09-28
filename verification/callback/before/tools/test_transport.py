"""Independent Python TLS peer for the Windows audio receiver probe.

Uses only loopback, public synthetic credentials and generated PCM, never devices.
Every socket/process has a deadline. Failures must occur for the expected reason;
an unrelated crash does not qualify a negative case. Requires stdlib Python 3.10+.
"""
import json
import os
from pathlib import Path
import socket
import ssl
import struct
import subprocess
import threading
import time
from check_transport import verify

ROOT = Path(__file__).resolve().parents[1]
TLS = ROOT.parent / 'tls-zig'
EXE = ROOT / 'zig-out/bin/audio-tls-probe.exe'
FIXTURES = TLS / 'tests/fixtures'
STREAM = bytes(range(1, 17))  # Test-only deterministic identity; production needs freshness.
PROFILE = struct.pack('>IHHHH', 48000, 2, 240, 1, 0)
VALUES = (-32768, -16384, -1, 0, 1, 16384, 32767)

def record(kind, sequence=0, body=b'', stream=STREAM):
    return struct.pack('>4sBBHIQ16s', b'JCRA', 1, kind, 36, len(body), sequence, stream) + body

def pcm(sequence):
    values = [VALUES[(sequence + i) % len(VALUES)] for i in range(480)]
    return struct.pack('<480h', *values), sum(values)

def peer_context(case):
    context = ssl.SSLContext(ssl.PROTOCOL_TLS_SERVER)
    context.minimum_version = ssl.TLSVersion.TLSv1_3
    context.maximum_version = ssl.TLSVersion.TLSv1_3
    cert = 'expired' if case == 'expired' else 'server'
    context.load_cert_chain(FIXTURES / (cert + '.pem'), FIXTURES / (cert + '.key'))
    context.load_verify_locations(FIXTURES / ('other-ca.pem' if case == 'untrusted-client' else 'ca.pem'))
    context.verify_mode = ssl.CERT_REQUIRED
    if case != 'missing-alpn':
        context.set_alpn_protocols(['http/1.1' if case == 'wrong-alpn' else 'jcr-audio/1'])
    return context

def receive_exact(sock, size):
    result = bytearray()
    while len(result) < size:
        chunk = sock.recv(size - len(result))
        if not chunk:
            raise RuntimeError('EOF before acknowledgement')
        result.extend(chunk)
    return bytes(result)

def run_case(case, expected_error=None):
    peer = {'authenticated': False, 'ack': False, 'clean_close': False, 'error': None}
    context = peer_context(case)
    listener = socket.socket()
    listener.bind(('127.0.0.1', 0))
    listener.listen(1)
    listener.settimeout(6)
    port = listener.getsockname()[1]
    block_count = 20
    expected_sum = sum(pcm(i)[1] for i in range(block_count))

    def serve():
        connection = None
        try:
            raw, _ = listener.accept()
            raw.settimeout(6)
            connection = context.wrap_socket(raw, server_side=True)
            peer['authenticated'] = bool(connection.getpeercert())
            if case in ('wrong-name', 'wrong-alpn', 'missing-alpn', 'expired', 'untrusted-client'):
                connection.recv(1)  # Observe rejection/closure rather than call it success.
                return
            if case == 'stalled':
                time.sleep(4.5)
                return
            data = bytearray(record(1, body=PROFILE))
            if case == 'oversized':
                data[8:12] = struct.pack('>I', 0xffffffff)
            elif case == 'bad-profile':
                data[36:40] = struct.pack('>I', 44100)
            elif case == 'audio-before-start':
                data = bytearray(record(2, body=pcm(0)[0]))
            elif case == 'truncated-frame':
                data = data[:17]
            else:
                for i in range(block_count):
                    stream = bytes([99]) * 16 if case == 'wrong-stream' and i == 1 else STREAM
                    sequence = 0 if case == 'duplicate' and i == 1 else i
                    data.extend(record(2, sequence, pcm(i)[0], stream))
                if case != 'missing-end':
                    data.extend(record(3, block_count))
                if case == 'after-end':
                    data.extend(record(2, block_count, pcm(block_count)[0]))
            # Different TLS/application/transport boundaries; alternate one byte and
            # coalesced chunks, not a copy of the Zig framing implementation.
            offset = 0
            fragments = (1, 7, 37, 2048, 113)
            part = 0
            while offset < len(data):
                size = fragments[part % len(fragments)]
                connection.sendall(data[offset:offset+size])
                offset += size
                part += 1
            if case in ('truncated-frame', 'missing-end'):
                connection.unwrap().close()
                connection = None
                return
            if case == 'raw-eof':
                fd = connection.detach()
                socket.socket(fileno=fd).close()
                connection = None
                return
            ack = receive_exact(connection, 36)
            if ack != record(4, block_count):
                raise RuntimeError('bad acknowledgement')
            peer['ack'] = True
            connection.unwrap().close()
            connection = None
            peer['clean_close'] = True
        except Exception as error:
            peer['error'] = f'{type(error).__name__}: {error}'
        finally:
            if connection is not None:
                connection.close()
            listener.close()

    thread = threading.Thread(target=serve, daemon=True)
    thread.start()
    env = dict(os.environ, TLS_DEMO_PORT=str(port), TLS_DEMO_NAME='wrong.example' if case == 'wrong-name' else 'localhost',
               OPENSSL_CONF=str(TLS / 'deps/openssl-install/ssl/openssl.cnf'),
               OPENSSL_MODULES=str(TLS / 'deps/openssl-install/lib/ossl-modules'))
    run = subprocess.run([str(EXE)], cwd=TLS, env=env, capture_output=True, text=True, timeout=10)
    thread.join(7)
    output = run.stdout + run.stderr
    if thread.is_alive():
        raise RuntimeError(f'{case}: peer did not terminate')
    if expected_error is None:
        marker = f'blocks={block_count} samples={block_count*480} checksum={expected_sum} clean_close=true'
        passed = run.returncode == 0 and marker in output and peer['authenticated'] and peer['ack'] and peer['clean_close'] and peer['error'] is None
    else:
        passed = run.returncode != 0 and any(f'error: {value}' in output for value in expected_error) and 'PASS audio TLS probe' not in output
    return {'case': case, 'passed': passed, 'exit_code': run.returncode, 'peer': peer, 'output': output}

if __name__ == '__main__':
    print(f'Dependency custody: {verify(staged=True)} pinned files and both staged DLLs verified', flush=True)
    cases = [
        ('fragmented-roundtrip', None),
        ('wrong-name', ['PeerAuthentication']),
        ('wrong-alpn', ['AlpnMismatch']),
        ('missing-alpn', ['AlpnMismatch']),
        ('expired', ['PeerAuthentication']),
        ('untrusted-client', ['TlsFailure']),
        ('oversized', ['InvalidLength']),
        ('bad-profile', ['InvalidProfile']),
        ('audio-before-start', ['UnexpectedMessage']),
        ('wrong-stream', ['WrongStream']),
        ('duplicate', ['Late']),
        ('truncated-frame', ['Truncated']),
        ('missing-end', ['MissingEnd']),
        ('after-end', ['Ended', 'DataAfterEnd']),
        ('raw-eof', ['TlsFailure', 'TransportFailure']),
        ('stalled', ['OperationDeadline']),
    ]
    results = []
    for case, expected in cases:
        result = run_case(case, expected)
        results.append(result)
        print(f"{case}: {'PASS' if result['passed'] else 'FAIL'}", flush=True)
    folder = ROOT / 'verification/transport'
    folder.mkdir(parents=True, exist_ok=True)
    (folder / 'interop.json').write_text(json.dumps({'python_ssl': ssl.OPENSSL_VERSION, 'results': results}, indent=2), encoding='utf-8')
    raise SystemExit(0 if all(row['passed'] for row in results) else 1)
