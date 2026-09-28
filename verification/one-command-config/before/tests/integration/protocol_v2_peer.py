"""Independent Python mTLS peer for test-only Zig v2 application roles.

Both Zig programs are TLS clients, with distinct application sender/receiver roles.
Ephemeral loopback, public credentials, synthetic finite words, bounded processes
and sockets. No devices, LAN peers or production authorization are involved.
"""
import argparse
import hashlib
import json
import os
import re
from pathlib import Path
import socket
import ssl
import struct
import subprocess
import sys
import threading
import time
from protocol_v2_reference import MAX_RECORD, STREAM, decode, profile, record, samples

ROOT = Path(__file__).resolve().parents[2]
TLS = ROOT / 'third_party/tls-zig'
FIXTURES = TLS / 'tests/fixtures'
sys.path.insert(0, str(ROOT / 'tools'))
from check_transport import verify
SIZES = (1, 17, 240, 1024, 3)
FRAMES = sum(SIZES)

def receive_exact(connection, size):
    result = bytearray()
    while len(result) < size:
        data = connection.recv(size - len(result))
        if not data:
            raise ValueError('EOF before full record')
        result.extend(data)
    return bytes(result)

def receive_record(connection):
    header = receive_exact(connection, 48)
    length = struct.unpack_from('>I', header, 8)[0]
    if length > MAX_RECORD - 48:
        raise ValueError('unbounded peer length')
    data = header + receive_exact(connection, length)
    return data, decode(data)

def fragmented_send(connection, data):
    offset = part = 0
    pieces = (1, 7, 47, 2048, 113)
    while offset < len(data):
        count = min(pieces[part % len(pieces)], len(data) - offset)
        connection.sendall(data[offset:offset + count])
        offset += count
        part += 1

def run_case(role, case, expected_errors):
    context = ssl.SSLContext(ssl.PROTOCOL_TLS_SERVER)
    context.minimum_version = context.maximum_version = ssl.TLSVersion.TLSv1_3
    context.load_cert_chain(FIXTURES / 'server.pem', FIXTURES / 'server.key')
    context.load_verify_locations(FIXTURES / 'ca.pem')
    context.verify_mode = ssl.CERT_REQUIRED
    context.set_alpn_protocols(['jcr-audio/1' if case == 'wrong-alpn' else 'jcr-audio/2'])
    listener = socket.socket()
    listener.bind(('127.0.0.1', 0))
    listener.listen(1)
    listener.settimeout(6)
    port = listener.getsockname()[1]
    peer = dict(authenticated=False, alpn=None, verified_frames=0, ack=False, clean_close=False, error=None)

    def serve():
        connection = raw = None
        try:
            raw, _ = listener.accept()
            raw.settimeout(14)
            connection = context.wrap_socket(raw, server_side=True)
            peer['authenticated'] = bool(connection.getpeercert())
            peer['alpn'] = connection.selected_alpn_protocol()
            if case in ('wrong-name', 'wrong-alpn'):
                connection.recv(1)
                return
            if role == 'receiver':
                if case == 'stalled':
                    time.sleep(12.4)
                    return
                offer = profile(rate=123 if case == 'bad-profile' else 48000)
                if case == 'audio-before-offer':
                    offer = record(3, 0, 1, samples(0, 1))
                if case == 'truncated':
                    fragmented_send(connection, offer[:19])
                    connection.unwrap().close()
                    connection = None
                    return
                fragmented_send(connection, offer)
                accepted, _ = receive_record(connection)
                if accepted != profile(2):
                    raise ValueError('ACCEPT did not echo offered bytes')
                position = 0
                data = bytearray()
                if case != 'empty':
                    for index, count in enumerate(SIZES):
                        body = samples(position, count)
                        stream = b'\x99' * 16 if case == 'wrong-stream' and index == 1 else STREAM
                        start = 0 if case == 'duplicate' and index == 1 else position
                        if case == 'gap' and index == 1:
                            start += 1
                        if case == 'nonfinite' and index == 1:
                            body = body[:-4] + struct.pack('<I', 0x7f800001)
                        data.extend(record(3, start, count, body, stream))
                        position += count
                if case != 'missing-end':
                    data.extend(record(4, position))
                if case == 'after-end':
                    data.extend(record(3, position, 1, samples(position, 1)))
                fragmented_send(connection, data)
                if case == 'missing-end':
                    connection.unwrap().close()
                    connection = None
                    return
                if case == 'raw-eof':
                    fd = connection.detach()
                    socket.socket(fileno=fd).close()
                    connection = None
                    return
                ack, _ = receive_record(connection)
                if ack != record(5, position):
                    raise ValueError('wrong ACK frontier')
                peer['ack'] = True
                peer['verified_frames'] = position  # Peer sent these; Zig verifies exact words.
            else:
                offered, _ = receive_record(connection)
                if offered != profile():
                    raise ValueError('unexpected sender OFFER')
                accept = profile(2, rate=96000 if case == 'bad-accept' else 48000,
                                 stream=b'\x77' * 16 if case == 'wrong-stream-accept' else STREAM)
                if case == 'early-ack':
                    accept = record(5)
                fragmented_send(connection, accept)
                position = 0
                for expected_count in SIZES:
                    data, message = receive_record(connection)
                    if data != record(3, position, expected_count, samples(position, expected_count)):
                        raise ValueError('sender words/count/position differ from independent bytes')
                    position += message['frames']
                data, _ = receive_record(connection)
                if data != record(4, position):
                    raise ValueError('wrong END')
                peer['verified_frames'] = position
                if case == 'missing-ack':
                    connection.unwrap().close()
                    connection = None
                    return
                acknowledgement = record(5, position + (case == 'wrong-ack'))
                if case == 'after-ack':
                    acknowledgement += record(5, position)
                fragmented_send(connection, acknowledgement)
                peer['ack'] = True
            connection.unwrap().close()
            connection = None
            peer['clean_close'] = True
        except Exception as error:
            peer['error'] = f'{type(error).__name__}: {error}'
        finally:
            if connection is not None:
                connection.close()
            if raw is not None:
                raw.close()
            listener.close()

    thread = threading.Thread(target=serve, daemon=True)
    thread.start()
    executable = ROOT / f'zig-out/bin/audio-v2-{role}-probe.exe'
    env = dict(os.environ, TLS_DEMO_PORT=str(port), TLS_DEMO_NAME='wrong.example' if case == 'wrong-name' else 'localhost',
               OPENSSL_CONF=str(TLS / 'deps/openssl-install/ssl/openssl.cnf'),
               OPENSSL_MODULES=str(TLS / 'deps/openssl-install/lib/ossl-modules'))
    try:
        run = subprocess.run([str(executable)], cwd=TLS, env=env, capture_output=True, text=True, timeout=18)
        code, output = run.returncode, run.stdout + run.stderr
    except subprocess.TimeoutExpired:
        code, output = None, 'harness subprocess deadline exceeded'
    thread.join(15)
    if expected_errors is None:
        expected_frames = 0 if case == 'empty' else FRAMES
        marker = f'PASS v2 role={role} frames={expected_frames} exact_words=true clean_close=true'
        passed = code == 0 and marker in output and peer['authenticated'] and peer['alpn'] == 'jcr-audio/2' and peer['ack'] and peer['clean_close'] and peer['verified_frames'] == expected_frames and peer['error'] is None
        if role == 'receiver':
            queue = re.search(r'^QUEUE frames=(\d+) short_writes=(\d+) zero_writes=(\d+)$', output, re.MULTILINE)
            queue_counts = tuple(map(int, queue.groups())) if queue else None
            peer['queue_observation'] = queue_counts
            passed = passed and queue_counts is not None and queue_counts[0] == expected_frames
            if case == 'roundtrip':
                passed = passed and queue_counts is not None and queue_counts[1] > 0 and queue_counts[2] > 0
    else:
        passed = code is not None and code != 0 and any(f'error: {e}\n' in output for e in expected_errors) and 'PASS v2' not in output
        if case not in ('wrong-name', 'wrong-alpn'):
            passed = passed and peer['authenticated'] and peer['alpn'] == 'jcr-audio/2'
    return dict(role=role, case=case, passed=bool(passed and not thread.is_alive()), exit_code=code,
                expected_errors=expected_errors, peer=peer, output=output, peer_terminated=not thread.is_alive())

def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--output', required=True, type=Path)
    args = parser.parse_args()
    destination = (ROOT / args.output).resolve()
    if not destination.is_relative_to((ROOT / 'verification').resolve()):
        parser.error('Report must stay under verification')
    if destination.exists():
        parser.error('Refusing to overwrite existing evidence')
    print(f'Custody: {verify(staged=True)} pins plus private DLLs verified', flush=True)
    binaries = {role: ROOT / f'zig-out/bin/audio-v2-{role}-probe.exe' for role in ('sender', 'receiver')}
    identities = {role: hashlib.sha256(path.read_bytes()).hexdigest() for role, path in binaries.items()}
    cases = [('receiver', 'roundtrip', None), ('receiver', 'empty', None), ('sender', 'roundtrip', None)]
    cases += [('receiver', case, errors) for case, errors in [
        ('bad-profile', ['InvalidProfile']), ('audio-before-offer', ['InvalidState']),
        ('wrong-stream', ['WrongStream']), ('duplicate', ['Discontinuous']), ('gap', ['Discontinuous']),
        ('nonfinite', ['InvalidSamples']), ('truncated', ['Truncated']), ('missing-end', ['MissingEnd']),
        ('after-end', ['DataAfterEnd']), ('raw-eof', ['TlsFailure', 'TransportFailure']),
        ('stalled', ['OperationDeadline']), ('wrong-alpn', ['AlpnMismatch']), ('wrong-name', ['PeerAuthentication'])]]
    cases += [('sender', case, errors) for case, errors in [
        ('bad-accept', ['FormatMismatch']), ('wrong-stream-accept', ['WrongStream']),
        ('early-ack', ['InvalidState']), ('wrong-ack', ['Discontinuous']),
        ('missing-ack', ['MissingAck']), ('after-ack', ['DataAfterEnd'])]]
    results = []
    for role, case, errors in cases:
        result = run_case(role, case, errors)
        results.append(result)
        print(f'{role}/{case}: {"PASS" if result["passed"] else "FAIL"}', flush=True)
    destination.parent.mkdir(parents=True, exist_ok=True)
    with destination.open('x', encoding='utf-8') as report:
        json.dump(dict(python_ssl=ssl.OPENSSL_VERSION, binary_sha256=identities, results=results), report, indent=2)
        report.write('\n')
    return 0 if all(x['passed'] for x in results) else 1

if __name__ == '__main__':
    raise SystemExit(main())
