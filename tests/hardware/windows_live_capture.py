"""Explicit physical Windows capture -> product CLI -> independent TLS discard peer.

Requires --run. Optional --test-tone plays a quiet generated 1 kHz tone; captured
PCM is never written to disk. Only aggregate counts, signal metrics and lifecycle
diagnostics are retained. The generated temporary WAV is not a recording.
"""
import argparse
import ctypes
from contextlib import contextmanager
from ctypes import wintypes
import json
import math
import os
from pathlib import Path
import socket
import ssl
import subprocess
import struct
import sys
import tempfile
import time
import wave

ROOT = Path(__file__).resolve().parents[2]
sys.path[:0] = [str(ROOT / 'tools'), str(ROOT / 'tests/integration')]
from create_pair import create
from protocol_v2_reference import profile, record
from protocol_v2_peer import receive_record


class ToneMeter:
    """Bounded streaming quadrature check, independent of the product audio code."""
    def __init__(self):
        self.frames = 0
        self.energy = 0.0
        self.quadrature = [0.0] * 4
        self.finite = True
        self.table = [(math.sin(2*math.pi*n/48), math.cos(2*math.pi*n/48)) for n in range(48)]

    def add(self, payload):
        for left, right in struct.iter_unpack('<ff', payload):
            sine, cosine = self.table[self.frames % 48]
            self.frames += 1
            if not (math.isfinite(left) and math.isfinite(right)):
                self.finite = False
                continue
            self.energy += left*left + right*right
            for channel, sample in enumerate((left, right)):
                self.quadrature[channel*2] += sample*sine
                self.quadrature[channel*2+1] += sample*cosine

    def result(self):
        count = max(1, self.frames)
        amplitudes = [2*math.hypot(*self.quadrature[i:i+2])/count for i in (0, 2)]
        fraction = (2*sum(x*x for x in self.quadrature)/count/self.energy) if self.energy else 0.0
        return dict(frames=self.frames, finite=self.finite, rms=math.sqrt(self.energy/(2*count)),
                    tone_amplitudes=amplitudes, tone_energy_fraction=fraction,
                    detected=self.finite and self.frames >= 4800 and min(amplitudes) > .001 and fraction > .5)


@contextmanager
def stimulus(directory, enabled):
    if not enabled:
        yield
        return
    import winsound
    path = Path(directory)/'generated-test-tone.wav'
    # -30 dBFS nominal peak, one exact second, identical stereo channels.
    pcm = bytearray()
    for n in range(48000):
        value = round(1024*math.sin(2*math.pi*n/48))
        pcm.extend(struct.pack('<hh', value, value))
    with wave.open(str(path), 'wb') as output:
        output.setnchannels(2); output.setsampwidth(2); output.setframerate(48000)
        output.writeframes(pcm)
    try:
        winsound.PlaySound(str(path), winsound.SND_FILENAME | winsound.SND_ASYNC | winsound.SND_LOOP | winsound.SND_NODEFAULT)
        yield
    finally:
        winsound.PlaySound(None, 0)


def meter_self_test():
    results = []
    for frequency, amplitude in ((1000, .125), (500, .125), (1500, .125), (1000, 0)):
        meter = ToneMeter()
        pcm = b''.join(struct.pack('<ff', value, -value) for n in range(4800)
                       for value in [amplitude*math.sin(2*math.pi*frequency*n/48000 + .71)])
        # 137-frame chunks exercise phase continuity independently of records.
        for offset in range(0, len(pcm), 137*8): meter.add(pcm[offset:offset+137*8])
        result = meter.result()
        expected = frequency == 1000 and amplitude > 0
        assert result['detected'] == expected
        if expected:
            assert all(abs(a-amplitude) < 1e-7 for a in result['tone_amplitudes'])
            assert abs(result['tone_energy_fraction']-1) < 1e-7
        else: assert result['tone_energy_fraction'] < 1e-7
        results.append(dict(frequency=frequency, amplitude=amplitude, passed=True))
    meter.add(struct.pack('<ff', float('nan'), 0))
    assert not meter.result()['detected'] and not meter.result()['finite']
    return dict(passed=True, analytic_cases=results, nonfinite_rejected=True)


def exercise(seconds, from_config=False, with_tone=False):
    if os.name != 'nt':
        raise RuntimeError('physical WASAPI check requires Windows')
    with tempfile.TemporaryDirectory(prefix='lan-audio-physical-') as temporary:
        pairing = Path(temporary) / 'pair with spaces'
        manifest = create(pairing, ROOT / 'third_party/tls-zig/deps/openssl-install/bin/openssl.exe')
        receiver, sender = pairing / 'receiver', pairing / 'sender'
        context = ssl.SSLContext(ssl.PROTOCOL_TLS_SERVER)
        context.minimum_version = context.maximum_version = ssl.TLSVersion.TLSv1_3
        context.load_cert_chain(receiver / 'identity.pem', receiver / 'identity.key')
        context.load_verify_locations(receiver / 'ca.pem')
        context.verify_mode = ssl.CERT_REQUIRED
        context.set_alpn_protocols(['jcr-audio/2'])
        frames = nonzero_bytes = 0
        meter = ToneMeter() if with_tone else None
        started = time.monotonic()
        with socket.socket() as listener, stimulus(temporary, with_tone):
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
                        if meter: meter.add(message['body'])
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
        signal = meter.result() if meter else None
        if signal: passed &= signal['detected'] and signal['frames'] == frames
        elapsed = time.monotonic()-started
        kernel32 = ctypes.WinDLL('kernel32', use_last_error=True)
        get_times = kernel32.GetProcessTimes
        get_times.argtypes = [wintypes.HANDLE] + [ctypes.POINTER(wintypes.FILETIME)]*4
        get_times.restype = wintypes.BOOL
        times = [wintypes.FILETIME() for _ in range(4)]
        cpu_seconds = None
        if get_times(int(child._handle), *[ctypes.byref(value) for value in times]):
            cpu_seconds = sum((value.dwHighDateTime << 32) | value.dwLowDateTime for value in times[2:])/10_000_000
        return dict(passed=passed, from_config=from_config, test_tone=with_tone, signal=signal, seconds=round(elapsed, 3), process_cpu_seconds=cpu_seconds,
                    percent_of_one_cpu=100*cpu_seconds/elapsed if cpu_seconds is not None else None,
                    frames=frames, nonzero_bytes=nonzero_bytes,
                    observed_non_silent_audio=nonzero_bytes > 0, error=failure, exit_code=child.returncode, report=report, stderr=stderr)


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('--run', action='store_true')
    parser.add_argument('--seconds', type=int, default=3)
    parser.add_argument('--from-config', action='store_true', help='Exercise generated profile and config-relative credential paths')
    parser.add_argument('--test-tone', action='store_true', help='Play a quiet generated 1 kHz tone and require its detection in received PCM')
    parser.add_argument('--self-test', action='store_true', help='Check the signal meter against analytic signals without hardware or sockets')
    args = parser.parse_args()
    if args.self_test:
        print(json.dumps(meter_self_test(), indent=2))
        raise SystemExit(0)
    if not args.run or not 1 <= args.seconds <= 30:
        parser.error('explicit --run and 1..30 seconds required')
    result = exercise(args.seconds, args.from_config, args.test_tone)
    print(json.dumps(result, indent=2))
    if not result['passed']:
        raise SystemExit(1)
