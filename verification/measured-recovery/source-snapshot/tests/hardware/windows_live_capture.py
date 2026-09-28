"""Explicit physical Windows capture -> product CLI -> independent TLS discard peer.

Requires --run. Never plays/records audio or writes PCM to disk. Only aggregate
frame/nonzero counts and lifecycle diagnostics are retained by the caller.
"""
import argparse
import ctypes
from ctypes import wintypes
import json
import os
from pathlib import Path
import socket
import ssl
import subprocess
import sys
import tempfile
import time

ROOT = Path(__file__).resolve().parents[2]
sys.path[:0] = [str(ROOT / 'tools'), str(ROOT / 'tests/integration')]
from create_pair import create
from protocol_v2_reference import profile, record
from protocol_v2_peer import receive_record


def exercise(seconds, from_config=False):
    if os.name != 'nt':
        raise RuntimeError('physical WASAPI check requires Windows')
    with tempfile.TemporaryDirectory(prefix='lan-audio-physical-') as temporary:
        pairing = Path(temporary) / 'pair with spaces'
        manifest = create(pairing, ROOT.parent / 'tls-zig/deps/openssl-install/bin/openssl.exe')
        receiver, sender = pairing / 'receiver', pairing / 'sender'
        context = ssl.SSLContext(ssl.PROTOCOL_TLS_SERVER)
        context.minimum_version = context.maximum_version = ssl.TLSVersion.TLSv1_3
        context.load_cert_chain(receiver / 'identity.pem', receiver / 'identity.key')
        context.load_verify_locations(receiver / 'ca.pem')
        context.verify_mode = ssl.CERT_REQUIRED
        context.set_alpn_protocols(['jcr-audio/2'])
        frames = nonzero_bytes = 0
        started = time.monotonic()
        with socket.socket() as listener:
            listener.bind(('127.0.0.1', 0))
            listener.listen(1)
            listener.settimeout(8)
            command = [str(ROOT / 'zig-out/bin/lan-audio.exe'), 'send', '--address', '127.0.0.1', '--port', str(listener.getsockname()[1]),
                       '--ca', str(sender/'ca.pem'), '--cert', str(sender/'identity.pem'), '--key', str(sender/'identity.key'),
                       '--peer-name', 'lan-audio-receiver', '--peer-fingerprint', manifest['fingerprints']['receiver'], '--seconds', str(seconds)]
            if from_config:
                path = sender / 'lan-audio.json'
                document = json.loads(path.read_text())
                document['profiles'][0]['settings'].update(address='127.0.0.1', port=listener.getsockname()[1],
                                                           seconds=seconds, reconnect=False)
                path.write_text(json.dumps(document), encoding='utf-8')
                command = [str(ROOT / 'zig-out/bin/lan-audio.exe'), 'run', '--config', str(path), '--profile', 'home']
            child = subprocess.Popen(command, cwd=ROOT, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
            failure = None
            try:
                raw, _ = listener.accept()
                raw.settimeout(seconds + 5)
                raw.setsockopt(socket.IPPROTO_TCP, socket.TCP_NODELAY, 1)
                with context.wrap_socket(raw, server_side=True) as connection:
                    offered, offer = receive_record(connection)
                    stream = offer['stream']
                    assert offered == profile(maximum=240, stream=stream)
                    connection.sendall(profile(2, maximum=240, stream=stream))
                    while True:
                        data, message = receive_record(connection)
                        if message['kind'] == 4:
                            assert data == record(4, frames, stream=stream)
                            connection.sendall(record(5, frames, stream=stream))
                            break
                        assert message['kind'] == 3 and message['stream'] == stream and message['position'] == frames
                        frames += message['frames']
                        nonzero_bytes += sum(byte != 0 for byte in message['body'])
                    connection.unwrap().close()
            except Exception as error:
                failure = f'{type(error).__name__}: {error}'
            finally:
                try:
                    stdout, stderr = child.communicate(timeout=6)
                except subprocess.TimeoutExpired:
                    child.kill()
                    stdout, stderr = child.communicate(timeout=3)
                    failure = 'product CLI failed to stop before watchdog'
        lines = [line for line in stdout.splitlines() if line.startswith('{')]
        report = json.loads(lines[-1]) if lines else None
        passed = bool(failure is None and child.returncode == 0 and report and report['failure'] is None
                      and frames >= seconds*48000*.8 and report['clock_keepalive'] is True
                      and report['frames'] == frames and report['audio']['captured_frames'] == frames
                      and report['audio']['dropped_frames'] == 0 and report['lifecycle']['held'] == [False]*3)
        elapsed = time.monotonic()-started
        kernel32 = ctypes.WinDLL('kernel32', use_last_error=True)
        get_times = kernel32.GetProcessTimes
        get_times.argtypes = [wintypes.HANDLE] + [ctypes.POINTER(wintypes.FILETIME)]*4
        get_times.restype = wintypes.BOOL
        times = [wintypes.FILETIME() for _ in range(4)]
        cpu_seconds = None
        if get_times(int(child._handle), *[ctypes.byref(value) for value in times]):
            cpu_seconds = sum((value.dwHighDateTime << 32) | value.dwLowDateTime for value in times[2:])/10_000_000
        return dict(passed=passed, from_config=from_config, seconds=round(elapsed, 3), process_cpu_seconds=cpu_seconds,
                    percent_of_one_cpu=100*cpu_seconds/elapsed if cpu_seconds is not None else None,
                    frames=frames, nonzero_bytes=nonzero_bytes,
                    observed_non_silent_audio=nonzero_bytes > 0, error=failure, exit_code=child.returncode, report=report, stderr=stderr)


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('--run', action='store_true')
    parser.add_argument('--seconds', type=int, default=3)
    parser.add_argument('--from-config', action='store_true', help='Exercise generated profile and config-relative credential paths')
    args = parser.parse_args()
    if not args.run or not 1 <= args.seconds <= 30:
        parser.error('explicit --run and 1..30 seconds required')
    result = exercise(args.seconds, args.from_config)
    print(json.dumps(result, indent=2))
    if not result['passed']:
        raise SystemExit(1)
