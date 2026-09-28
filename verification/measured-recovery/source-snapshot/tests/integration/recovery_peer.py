"""Independent authenticated impairment peer for the actual recovery supervisor.

Loopback/null audio only. Pauses/drops are deliberate; no NIC settings changed.
Reports contain public fixture identities and counts, never recorded audio.
"""
import argparse
import hashlib
import json
import os
from pathlib import Path
import queue
import re
import socket
import ssl
import subprocess
import threading
import time
from protocol_v2_reference import profile, record
from protocol_v2_peer import receive_record
from verified_channel_peer import ROOT, TLS, FIXTURES, fingerprint


def run_case(role, mode, serving=False):
    context = ssl.SSLContext(ssl.PROTOCOL_TLS_CLIENT if serving else ssl.PROTOCOL_TLS_SERVER)
    context.minimum_version = context.maximum_version = ssl.TLSVersion.TLSv1_3
    identity = 'client' if serving else 'server'
    context.load_cert_chain(FIXTURES/f'{identity}.pem', FIXTURES/f'{identity}.key')
    context.load_verify_locations(FIXTURES/'ca.pem')
    context.verify_mode = ssl.CERT_REQUIRED
    context.set_alpn_protocols(['jcr-audio/2'])
    expected = fingerprint(identity+'.pem')
    if mode == 'wrong-peer':
        expected = '00'*32
    events, peers, ready = [], [], ''
    err = None
    start = time.monotonic()
    with socket.socket() as listener:
        listener.bind(('127.0.0.1', 0))
        listener.listen(3)
        listener.settimeout(5)
        port = 0 if serving else listener.getsockname()[1]
        command = [str(ROOT/'zig-out/bin/audio-recovery-probe.exe'), role, str(port), expected, 'listener' if serving else mode]
        env = dict(os.environ, OPENSSL_CONF=str(TLS/'deps/openssl-install/ssl/openssl.cnf'), OPENSSL_MODULES=str(TLS/'deps/openssl-install/lib/ossl-modules'))
        child = subprocess.Popen(command, cwd=TLS, env=env, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
        try:
            if serving:
                lines = queue.Queue()
                reader = threading.Thread(target=lambda: lines.put(child.stderr.readline()), daemon=True)
                reader.start()
                ready = lines.get(timeout=5)
                reader.join(1)
                port = int(re.search(r'Listening on 127.0.0.1:(\d+);', ready).group(1))
            attempts = 1 if mode in ('wrong-peer', 'cancel-backoff', 'cancel-handshake', 'jitter') else 2
            for attempt in range(attempts):
                if serving:
                    raw = socket.create_connection(('127.0.0.1', port), timeout=5)
                else:
                    raw, _ = listener.accept()
                raw.settimeout(4)
                raw.setsockopt(socket.IPPROTO_TCP, socket.TCP_NODELAY, 1)
                if mode == 'cancel-handshake':
                    time.sleep(.8)
                    raw.close()
                    break
                peer = dict(frames=0, clean=False, authenticated=False, stream=None)
                peers.append(peer)
                if mode == 'missing-client' and attempt == 0:
                    unauthenticated = ssl.create_default_context(cafile=FIXTURES/'ca.pem')
                    unauthenticated.minimum_version = ssl.TLSVersion.TLSv1_3
                    unauthenticated.set_alpn_protocols(['jcr-audio/2'])
                    try:
                        with unauthenticated.wrap_socket(raw, server_hostname='localhost') as rejected:
                            rejected.sendall(b'no client identity')
                            assert rejected.recv(1) == b''
                    except (ssl.SSLError, ConnectionError):
                        pass
                    continue
                with context.wrap_socket(raw, server_side=not serving, server_hostname='localhost' if serving else None) as conn:
                    peer['authenticated'] = hashlib.sha256(conn.getpeercert(binary_form=True)).hexdigest() == fingerprint('server.pem' if serving else 'client.pem')
                    if mode == 'wrong-peer':
                        try:
                            assert conn.recv(1) == b''
                        except (ssl.SSLError, ConnectionError):
                            pass
                        break
                    impaired = attempt == 0 and attempts == 2
                    if role == 'sender':
                        offered, message = receive_record(conn)
                        stream = message['stream']
                        peer['stream'] = stream.hex()
                        assert offered == profile(maximum=240, stream=stream)
                        conn.sendall(profile(2, maximum=240, stream=stream))
                        while True:
                            data, message = receive_record(conn)
                            if message['kind'] == 4:
                                assert data == record(4, peer['frames'], stream=stream)
                                conn.sendall(record(5, peer['frames'], stream=stream))
                                break
                            assert data == record(3, peer['frames'], message['frames'], bytes(message['frames']*8), stream=stream)
                            peer['frames'] += message['frames']
                            threshold = 4800
                            if (impaired or mode == 'cancel-backoff') and peer['frames'] >= threshold:
                                break
                        if impaired or mode == 'cancel-backoff':
                            continue
                    else:
                        stream = bytes([attempt+1])*16
                        peer['stream'] = stream.hex()
                        conn.sendall(profile(maximum=240, stream=stream))
                        accepted, _ = receive_record(conn)
                        assert accepted == profile(2, maximum=240, stream=stream)
                        base = time.monotonic()
                        last_send = base
                        peer['max_send_gap_ms'] = 0
                        peer['max_send_call_ms'] = 0
                        target = 4800 if impaired else 48000
                        if mode == 'backlog' and impaired:
                            # Real callbacks cannot drain a one-second burst instantly.
                            target = 24000
                        for position in range(0, target, 240):
                            current = time.monotonic()
                            peer['max_send_gap_ms'] = max(peer['max_send_gap_ms'], round((current-last_send)*1000, 3))
                            last_send = current
                            try:
                                conn.sendall(record(3, position, 240, bytes(240*8), stream=stream))
                            except OSError:
                                if not (impaired and mode == 'backlog'):
                                    raise
                                break
                            peer['max_send_call_ms'] = max(peer['max_send_call_ms'], round((time.monotonic()-current)*1000, 3))
                            peer['frames'] += 240
                            if not (impaired and mode == 'backlog'):
                                # Request 5 ms jitter with explicit 60 ms reserve;
                                # max_send_gap_ms records actual OS scheduling.
                                delay = .005 if mode == 'jitter' and position % 4800 == 0 else 0
                                time.sleep(max(0, base + peer['frames']/48000 + delay - time.monotonic()))
                        if impaired:
                            if mode == 'starve':
                                time.sleep(.12)
                            try:
                                assert conn.recv(1) == b''
                            except (ssl.SSLError, ConnectionError):
                                pass
                            continue
                        # END can be delayed by the harness scheduler too. Audio
                        # send-gap maxima alone previously hid this final gap.
                        peer['end_send_gap_ms'] = round((time.monotonic()-last_send)*1000, 3)
                        conn.sendall(record(4, peer['frames'], stream=stream))
                        ack, _ = receive_record(conn)
                        assert ack == record(5, peer['frames'], stream=stream)
                    conn.unwrap().close()
                    peer['clean'] = True
            stdout, stderr = child.communicate(timeout=7)
        except Exception as error:
            if mode == 'wrong-peer' and isinstance(error, (ConnectionError, ssl.SSLError)):
                # The approved-name handshake can finish locally before the app
                # rejects the leaf digest; Python can observe reset in wrap_socket.
                stdout, stderr = child.communicate(timeout=3)
            else:
                err = f'{type(error).__name__}: {error}'
                # Let quiescent cleanup publish the actual fault before enforcing
                # the watchdog; immediate kill used to hide its diagnostic.
                try:
                    stdout, stderr = child.communicate(timeout=1)
                except subprocess.TimeoutExpired:
                    child.kill()
                    stdout, stderr = child.communicate(timeout=3)
    try:
        events = [json.loads(line) for line in stdout.splitlines() if line.startswith('{')]
    except ValueError as error:
        err = str(error)
    good = bool(err is None and events)
    for event in events:
        ledger = event['lifecycle']
        good &= ledger['held'] == [False]*3 and ledger['pending'] is None and ledger['phase'] == 'stopped'
        # Internal fault cancellation must never become a persistent user-stop flag.
        if event['audio']:
            good &= ledger['worker_joined'] and ledger['device_fenced']
    if mode == 'wrong-peer':
        good &= len(events) == 1 and child.returncode != 0 and events[0]['failure'] == 'WrongPeer'
    elif mode.startswith('cancel'):
        good &= child.returncode == 0 and len(events) == 1 and time.monotonic()-start < 5
        if mode == 'cancel-backoff':
            good &= bool(events) and events[0]['failure'] in ('TransportFailure', 'TlsFailure', 'ChannelClosed') and 'retrying in 250 ms' in stderr
    elif mode == 'jitter':
        good &= (child.returncode == 0 and len(events) == 1 and bool(peers)
                 and peers[-1]['clean'] and events[-1]['failure'] is None
                 and not events[-1]['starved'] and events[0]['prefill_frames'] == 2880)
    else:
        good &= child.returncode == 0 and len(events) == 2 and peers[-1]['clean'] and events[-1]['failure'] is None
        if len(events) == 2:
            good &= peers[0]['stream'] != peers[1]['stream'] and events[-1]['frames'] == peers[-1]['frames']
            if mode == 'starve':
                timing = events[0]['delivery_timing']
                gap = max(timing['max_publication_gap_ms'], timing['starvation_gap_ms'])
                callback = events[0]['audio']['max_output_request_frames']
                # Independent unit conversion: seconds -> frames, then ceil to
                # one 5 ms block, with at least the legacy 20 ms increase.
                required_ms = min(gap, 240) + 1 + 2 * callback / 48
                import math
                expected = min(5760, max(1920, math.ceil(required_ms / 5) * 240))
                good &= events[0]['failure'] == 'PlaybackStarved' and events[1]['prefill_frames'] == expected
            elif mode == 'backlog':
                good &= events[0]['failure'] == 'PlaybackBacklog' and events[1]['prefill_frames'] == 960
            elif mode == 'missing-client':
                good &= events[0]['failure'] in ('PeerAuthentication', 'TlsFailure') and events[0]['audio'] is None and events[0]['frames'] == 0
            else:
                good &= events[0]['failure'] in ('TlsFailure', 'TransportFailure', 'ChannelClosed')
    return dict(role=role, mode=mode, listener=serving, matched=bool(good), seconds=round(time.monotonic()-start, 3),
                exit_code=child.returncode, error=err, events=events, peers=peers, stderr=ready+stderr)


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--output', type=Path, required=True)
    parser.add_argument('--only')
    args = parser.parse_args()
    output = (ROOT/args.output).resolve()
    if output.exists() or not output.is_relative_to(ROOT/'verification'):
        parser.error('choose a new report under verification')
    specs = [('receiver','starve',False),('receiver','starve',True),('receiver','backlog',False),
             ('receiver','jitter',False),('sender','drop',False),('sender','drop',True),
             ('sender','wrong-peer',False),('sender','cancel-backoff',False),('sender','cancel-handshake',False),
             ('receiver','missing-client',True)]
    results=[]
    for spec in specs:
        if args.only and args.only != spec[1]:
            continue
        result=run_case(*spec); results.append(result)
        print(('PASS' if result['matched'] else 'FAIL'), spec, result['error'], [e['failure'] for e in result['events']], flush=True)
    output.parent.mkdir(parents=True,exist_ok=True)
    output.write_text(json.dumps(dict(binary_sha256=hashlib.sha256((ROOT/'zig-out/bin/audio-recovery-probe.exe').read_bytes()).hexdigest(),results=results),indent=2)+'\n')
    if not results or not all(r['matched'] for r in results):
        raise SystemExit(1)


if __name__ == '__main__':
    main()
