"""Independent Python peer for the product Socket/TLS/authorization connection.

Public test identities, loopback only, finite synthetic words; no devices. Both TLS
roles and both media roles, fragmented/coalesced v2 records, bounded child/socket
lifetimes. Rejections require named host errors AND revoked TLS/permission. Success
requires independent exact bytes, actual mutual verification and clean close.
"""
import argparse
import hashlib
import json
import os
from pathlib import Path
import queue
import socket
import ssl
import subprocess
import sys
import threading
import time
from protocol_v2_reference import profile, record, samples
from protocol_v2_peer import receive_record, fragmented_send

ROOT = Path(__file__).resolve().parents[2]
TLS = ROOT.parent / 'tls-zig'
FIXTURES = TLS / 'tests/fixtures'
sys.path.insert(0, str(ROOT / 'tools'))
from check_transport import verify
SIZES = (1, 17, 240, 1024, 3)


def fingerprint(name):
    return hashlib.sha256(ssl.PEM_cert_to_DER_cert((FIXTURES / name).read_text())).hexdigest()


def run_case(tls_role, role, mode='valid', family='ipv4', errors=()):
    server = tls_role == 'server'
    context = ssl.SSLContext(ssl.PROTOCOL_TLS_CLIENT if server else ssl.PROTOCOL_TLS_SERVER)
    context.minimum_version = context.maximum_version = ssl.TLSVersion.TLSv1_3
    if mode != 'missing-client':
        name = 'client' if server else 'server'
        context.load_cert_chain(FIXTURES / f'{name}.pem', FIXTURES / f'{name}.key')
    context.load_verify_locations(FIXTURES / 'ca.pem')
    context.verify_mode = ssl.CERT_REQUIRED
    context.set_alpn_protocols(['jcr-audio/1' if mode == 'wrong-alpn' else 'jcr-audio/2'])
    address = '::1' if family == 'ipv6' else '127.0.0.1'
    native_family = socket.AF_INET6 if family == 'ipv6' else socket.AF_INET
    listener = None
    port = 0
    if not server:
        listener = socket.socket(native_family)
        listener.bind((address, 0))
        listener.listen(1)
        listener.settimeout(5)
        port = listener.getsockname()[1]
    env = dict(os.environ, OPENSSL_CONF=str(TLS / 'deps/openssl-install/ssl/openssl.cnf'),
               OPENSSL_MODULES=str(TLS / 'deps/openssl-install/lib/ossl-modules'))
    command = [str(ROOT / 'zig-out/bin/audio-verified-probe.exe'), tls_role, role, mode,
               str(port), fingerprint('client.pem' if server else 'server.pem'), family]
    child = subprocess.Popen(command, cwd=TLS, env=env, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
    ready = ''
    peer = dict(authenticated=False, fingerprint=None, frames=0, clean_close=False, error=None,
                application_received=0)

    def serve():
        connection = raw = None
        try:
            if server:
                raw = socket.socket(native_family)
                raw.settimeout(5)
                raw.connect((address, port))
            else:
                raw, _ = listener.accept()
            raw.settimeout(5)
            if mode == 'deadline':
                time.sleep(1.1)
                return
            connection = context.wrap_socket(raw, server_side=not server,
                                             server_hostname='localhost' if server else None)
            peer['authenticated'] = bool(connection.getpeercert())
            peer['fingerprint'] = hashlib.sha256(connection.getpeercert(binary_form=True)).hexdigest()
            if connection.selected_alpn_protocol() != 'jcr-audio/2':
                connection.recv(1)
                return
            if mode in ('wrong-peer', 'wrong-role', 'unapproved', 'cancel', 'revoke', 'revision', 'before-handshake', 'expired', 'wrong-name', 'missing-client'):
                peer['application_received'] += len(connection.recv(1))
                return
            if role == 'sender':
                offered, _ = receive_record(connection)
                peer['application_received'] += len(offered)
                if offered != profile():
                    raise ValueError('wrong OFFER bytes')
                fragmented_send(connection, profile(2, rate=96000 if mode == 'bad-accept' else 48000))
                if mode == 'cancel-wait':
                    time.sleep(1.1)
                    return
                if mode == 'raw-eof':
                    descriptor = connection.detach()
                    socket.socket(fileno=descriptor).close()
                    connection = None
                    return
                if mode == 'current-revision':
                    peer['application_received'] += len(connection.recv(1))
                    return
                position = 0
                for count in SIZES:
                    data, _ = receive_record(connection)
                    peer['application_received'] += len(data)
                    if data != record(3, position, count, samples(position, count)):
                        raise ValueError('wrong AUDIO bytes or frontier')
                    position += count
                ended, _ = receive_record(connection)
                if ended != record(4, position):
                    raise ValueError('wrong END bytes')
                peer['frames'] = position
                acknowledgement = record(5, position + (mode == 'wrong-ack'))
                if mode == 'after-ack':
                    acknowledgement += record(5, position)
                fragmented_send(connection, acknowledgement)
            else:
                if mode == 'truncated':
                    fragmented_send(connection, profile()[:19])
                    connection.unwrap().close()
                    connection = None
                    return
                fragmented_send(connection, profile())
                accepted, _ = receive_record(connection)
                peer['application_received'] += len(accepted)
                if accepted != profile(2):
                    raise ValueError('wrong ACCEPT bytes')
                if mode == 'cancel-wait':
                    time.sleep(1.1)
                    return
                if mode == 'current-revision':
                    peer['application_received'] += len(connection.recv(1))
                    return
                position = 0
                batch = bytearray()
                for index, count in enumerate(SIZES):
                    start = 0 if mode == 'duplicate' and index == 1 else position
                    batch.extend(record(3, start, count, samples(position, count)))
                    position += count
                batch.extend(record(4, position))
                if mode == 'after-end':
                    batch.extend(record(3, position, 1, samples(position, 1)))
                fragmented_send(connection, batch)
                acknowledgement, _ = receive_record(connection)
                if acknowledgement != record(5, position):
                    raise ValueError('wrong ACK bytes')
                peer['frames'] = position
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
            if listener is not None:
                listener.close()

    started = time.monotonic()
    thread = None
    try:
        if server:
            lines = queue.Queue()
            reader = threading.Thread(target=lambda: lines.put(child.stdout.readline()), daemon=True)
            reader.start()
            ready = lines.get(timeout=5)
            if not ready.startswith('READY '):
                raise ValueError(f'missing ready endpoint: {ready!r}')
            port = int(ready.split()[1])
            reader.join(1)
        thread = threading.Thread(target=serve, daemon=True)
        thread.start()
        stdout, stderr = child.communicate(timeout=12)
        output = ready + stdout + stderr
    except Exception as error:
        child.kill()
        stdout, stderr = child.communicate(timeout=3)
        output = ready + stdout + stderr + f'\nHARNESS {type(error).__name__}: {error}'
    finally:
        if thread is not None:
            thread.join(6)
        if listener is not None:
            listener.close()
    expected_fingerprint = fingerprint('server.pem' if server else 'client.pem')
    if errors:
        matched = child.returncode != 0 and any(f'REJECT {e} revoked=true tls_released=true' in output for e in errors)
        if mode in ('wrong-peer', 'wrong-role', 'unapproved', 'cancel', 'revoke', 'revision', 'before-handshake'):
            matched = matched and peer['application_received'] == 0
    else:
        matched = (child.returncode == 0 and 'PASS verified frames=1285 exact_words=true clean_close=true repeat=32 stale=7' in output
                   and peer['authenticated'] and peer['fingerprint'] == expected_fingerprint
                   and peer['frames'] == 1285 and peer['clean_close'] and peer['error'] is None)
    matched = matched and (thread is None or not thread.is_alive()) and 'HARNESS ' not in output
    return dict(tls_role=tls_role, audio_role=role, mode=mode, family=family, expected_errors=errors,
                exit_code=child.returncode, matched=matched, seconds=round(time.monotonic()-started, 3), peer=peer, output=output)


def cases():
    for tls_role in ('client', 'server'):
        for role in ('sender', 'receiver'):
            for family in ('ipv4', 'ipv6'):
                yield tls_role, role, 'valid', family, ()
        for mode, errors in (
            ('wrong-peer', ('WrongPeer',)), ('wrong-role', ('WrongRole',)),
            ('unapproved', ('UnauthorizedPeer',)), ('cancel', ('Canceled',)),
            ('revoke', ('Revoked',)), ('revision', ('AuthorizationChanged',)),
            ('cancel-wait', ('Canceled',)), ('raw-eof', ('TlsFailure', 'TransportFailure')),
            ('current-revision', ('AuthorizationChanged',)),
            ('before-handshake', ('InvalidState',)), ('wrong-alpn', (('TlsFailure',) if tls_role == 'server' else ('AlpnMismatch',))),
            ('expired', ('PeerAuthentication',)), ('deadline', ('Deadline', 'OperationDeadline')),
        ):
            yield tls_role, 'sender', mode, 'ipv4', errors
    yield 'client', 'sender', 'wrong-name', 'ipv4', ('PeerAuthentication',)
    yield 'server', 'receiver', 'missing-client', 'ipv4', ('PeerAuthentication', 'TlsFailure')
    for mode, errors in (('bad-accept', ('FormatMismatch',)), ('wrong-ack', ('Discontinuous',)), ('after-ack', ('DataAfterEnd',))):
        yield 'client', 'sender', mode, 'ipv4', errors
    for mode, errors in (('truncated', ('Truncated',)), ('duplicate', ('Discontinuous',)), ('after-end', ('DataAfterEnd',))):
        yield 'server', 'receiver', mode, 'ipv4', errors


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--output', type=Path, required=True)
    parser.add_argument('--only', help='Run a single named mode for bounded diagnosis')
    args = parser.parse_args()
    args.output = (ROOT / args.output).resolve()
    if not args.output.is_relative_to((ROOT / 'verification').resolve()) or args.output.exists():
        parser.error('Output must be a new report under verification')
    verify(staged=True)
    results = []
    for spec in cases():
        if args.only and spec[2] != args.only:
            continue
        result = run_case(*spec)
        results.append(result)
        print(f"{'PASS' if result['matched'] else 'FAIL'} {spec[:4]}", flush=True)
    verify(staged=True)
    args.output.parent.mkdir(parents=True, exist_ok=True)
    with args.output.open('x', encoding='utf-8') as report:
        json.dump(dict(python_ssl=ssl.OPENSSL_VERSION,
            executable_sha256=hashlib.sha256((ROOT/'zig-out/bin/audio-verified-probe.exe').read_bytes()).hexdigest(),
            fixture_fingerprints={name:fingerprint(name+'.pem') for name in ('client','server')}, results=results), report, indent=2)
    if not results or not all(r['matched'] for r in results):
        raise SystemExit(1)


if __name__ == '__main__':
    main()
