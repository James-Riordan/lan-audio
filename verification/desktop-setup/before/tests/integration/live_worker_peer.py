"""Independent mTLS/v2 peer exercising real media threads and null callbacks.

Public test credentials, loopback only. Measures frame conservation and actual
cleanup, not speaker quality or acoustic latency. Never opens physical audio.
"""
import argparse
import hashlib
import json
import os
import queue
import re
from pathlib import Path
import socket
import ssl
import subprocess
import time
import threading
from protocol_v2_reference import profile, record
from protocol_v2_peer import receive_record
from verified_channel_peer import fingerprint, ROOT, TLS, FIXTURES


def run_case(role, mode):
    server = mode == 'listener'
    context = ssl.SSLContext(ssl.PROTOCOL_TLS_CLIENT if server else ssl.PROTOCOL_TLS_SERVER)
    context.minimum_version = context.maximum_version = ssl.TLSVersion.TLSv1_3
    identity = 'client' if server else 'server'
    context.load_cert_chain(FIXTURES / f'{identity}.pem', FIXTURES / f'{identity}.key')
    context.load_verify_locations(FIXTURES / 'ca.pem')
    context.verify_mode = ssl.CERT_REQUIRED
    context.set_alpn_protocols(['jcr-audio/2'])
    peer = dict(frames=0, authenticated=False, clean_close=False, error=None)
    env = dict(os.environ, OPENSSL_CONF=str(TLS / 'deps/openssl-install/ssl/openssl.cnf'),
               OPENSSL_MODULES=str(TLS / 'deps/openssl-install/lib/ossl-modules'))
    started = time.monotonic()
    child = None
    with socket.socket() as listener:
        listener.bind(('127.0.0.1', 0))
        listener.listen(1)
        listener.settimeout(8)
        command = [str(ROOT / 'zig-out/bin/audio-worker-probe.exe'), role,
                   '0' if server else str(listener.getsockname()[1]), fingerprint(f'{identity}.pem'), mode]
        child = subprocess.Popen(command, cwd=TLS, env=env, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
        ready = ''
        try:
            if server:
                lines = queue.Queue()
                reader = threading.Thread(target=lambda: lines.put(child.stderr.readline()), daemon=True)
                reader.start()
                ready = lines.get(timeout=5)
                reader.join(1)
                port = int(re.search(r'Listening on 127.0.0.1:(\d+);', ready).group(1))
                raw = socket.create_connection(('127.0.0.1', port), timeout=5)
            else:
                raw, _ = listener.accept()
            raw.settimeout(6)
            with context.wrap_socket(raw, server_side=not server, server_hostname='localhost' if server else None) as connection:
                peer['authenticated'] = hashlib.sha256(connection.getpeercert(binary_form=True)).hexdigest() == fingerprint('server.pem' if server else 'client.pem')
                assert connection.selected_alpn_protocol() == 'jcr-audio/2'
                if role == 'sender':
                    offered, _ = receive_record(connection)
                    assert offered == profile(maximum=240)
                    connection.sendall(profile(2, maximum=240))
                    while True:
                        data, message = receive_record(connection)
                        if message['kind'] == 4:
                            assert data == record(4, peer['frames'])
                            connection.sendall(record(5, peer['frames'] + (mode == 'wrong-ack')))
                            break
                        assert data == record(3, peer['frames'], message['frames'], bytes(message['frames'] * 8))
                        peer['frames'] += message['frames']
                        if mode == 'disconnect' and peer['frames'] >= 960:
                            break
                else:
                    connection.sendall(profile(maximum=240))
                    accepted, _ = receive_record(connection)
                    assert accepted == profile(2, maximum=240)
                    total = {'empty': 0, 'short': 17}.get(mode, 48000)
                    base = time.monotonic()
                    while peer['frames'] < total:
                        count = min(240, total - peer['frames'])
                        position = 0 if mode == 'duplicate' and peer['frames'] else peer['frames']
                        connection.sendall(record(3, position, count, bytes(count * 8)))
                        peer['frames'] += count
                        if mode == 'duplicate' and peer['frames'] == 480:
                            break
                        if mode == 'stall' and peer['frames'] == 960:
                            time.sleep(2.5)
                            break
                        # Real-time producer, so callback scheduling and FIFO are exercised.
                        remaining = base + peer['frames'] / 48000 - time.monotonic()
                        # An overdue record should catch up, not yield another
                        # Windows time slice through sleep(0).
                        if remaining > 0:
                            time.sleep(remaining)
                    if mode not in ('duplicate', 'stall'):
                        connection.sendall(record(4, peer['frames']))
                        acknowledged, _ = receive_record(connection)
                        assert acknowledged == record(5, peer['frames'])
                if mode in ('valid', 'empty', 'short', 'listener'):
                    connection.unwrap().close()
                    peer['clean_close'] = True
        except Exception as error:
            peer['error'] = f'{type(error).__name__}: {error}'
        finally:
            try:
                stdout, stderr = child.communicate(timeout=8)
            except subprocess.TimeoutExpired:
                child.kill()
                stdout, stderr = child.communicate(timeout=3)
                peer['error'] = 'worker did not exit before watchdog'
    try:
        result = json.loads(stdout)
    except (ValueError, TypeError):
        result = None
    good = bool(result and result['lifecycle']['phase'] == 'stopped'
                and result['lifecycle']['held'] == [False] * 3 and result['lifecycle']['pending'] is None
                and result['lifecycle']['worker_joined'] and result['lifecycle']['device_fenced'])
    if mode in ('valid', 'empty', 'short', 'listener'):
        good = good and child.returncode == 0 and result['failure'] is None and peer['clean_close'] and peer['authenticated'] and peer['error'] is None
        if good:
            counters = result['audio']
            good = counters['counters_exact'] and result['frames'] == peer['frames'] and counters['dropped_frames'] == 0
            if role == 'sender':
                good = good and counters['captured_frames'] == peer['frames'] and peer['frames'] >= 48000
            else:
                good = good and counters['rendered_frames'] == peer['frames']
    else:
        expected = {'wrong-ack': ['Discontinuous'], 'duplicate': ['Discontinuous'],
                    'stall': ['Deadline', 'OperationDeadline'], 'cancel': ['Canceled'], 'disconnect': ['TransportFailure', 'TlsFailure', 'ChannelClosed', 'IoFailure']}[mode]
        good = good and child.returncode != 0 and result['failure'] in expected
    return dict(role=role, mode=mode, matched=bool(good), seconds=round(time.monotonic()-started, 3),
                exit_code=child.returncode, peer=peer, result=result, stderr=ready+stderr, stdout=stdout if result is None else None)


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--output', required=True, type=Path)
    parser.add_argument('--only')
    args = parser.parse_args()
    output = (ROOT / args.output).resolve()
    if output.exists() or not output.is_relative_to(ROOT / 'verification'):
        parser.error('output must be a new file under verification')
    cases = [('sender', 'valid'), ('receiver', 'valid'), ('receiver', 'short'), ('receiver', 'empty'),
             ('sender', 'wrong-ack'), ('sender', 'disconnect'), ('receiver', 'duplicate'), ('receiver', 'stall'),
             ('sender', 'cancel'), ('receiver', 'cancel'), ('sender', 'listener'), ('receiver', 'listener')]
    results = []
    for role, mode in cases:
        if args.only and mode != args.only:
            continue
        result = run_case(role, mode)
        results.append(result)
        print(f"{'PASS' if result['matched'] else 'FAIL'} {role} {mode}: {result['result']}", flush=True)
    output.parent.mkdir(parents=True, exist_ok=True)
    output.write_text(json.dumps(dict(executable_sha256=hashlib.sha256((ROOT/'zig-out/bin/audio-worker-probe.exe').read_bytes()).hexdigest(), python_ssl=ssl.OPENSSL_VERSION, results=results), indent=2)+'\n')
    if not results or not all(case['matched'] for case in results):
        raise SystemExit(1)


if __name__ == '__main__':
    main()
