"""Bounded independent v2 oracle campaign against a test-only Zig C ABI.

Reproducible seed, record/count bounds and a killable child deadline. Invalid
records must agree on rejection and leave output untouched. Accepted records
must re-encode byte-for-byte. No sockets/devices/credentials or dependency changes.
"""
import argparse
import base64
import ctypes
import hashlib
import json
from pathlib import Path
import random
import subprocess
import sys
import tempfile
import time

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / 'tests/integration'))
from protocol_v2_reference import MAX_RECORD, decode, profile, record, samples

SEED = 0x4A435232
RANDOM_CASES = 4000
MAX_CASES = 14000

def corpus():
    """Stream cases; never retain a growing corpus in process memory."""
    valid = [profile(kind, rate, maximum) for kind in (1, 2)
             for rate in (44100, 48000, 96000) for maximum in (1, 240, 1024)]
    valid += [record(3, position, frames, samples(position, frames))
              for frames in (1, 17, 240, 1024) for position in (0, 7, (1 << 64) - 1 - frames)]
    valid += [record(kind, position) for kind in (4, 5) for position in (0, (1 << 64) - 1)]
    for data in valid:
        for fragment in (1, 7, 47, 48, 49, 113, MAX_RECORD + 1):
            yield data, fragment
    largest = record(3, 0, 1024, samples(0, 1024))
    for length in range(len(largest)):
        yield largest[:length], 113
    yield largest + b'\0', MAX_RECORD + 1
    for base in (profile(), record(3, 0, 1, samples(0, 1)), record(4)):
        for byte in range(48):
            for bit in range(8):
                data = bytearray(base)
                data[byte] ^= 1 << bit
                yield bytes(data), 7
    rng = random.Random(SEED)
    for _ in range(RANDOM_CASES):
        data = bytearray(rng.choice(valid))
        mutation = rng.randrange(4)
        if mutation == 0:
            for _ in range(rng.randint(1, 8)):
                data[rng.randrange(len(data))] = rng.randrange(256)
        elif mutation == 1:
            del data[rng.randrange(len(data) + 1):]
        elif mutation == 2:
            data.extend(rng.randbytes(rng.randrange(1, min(32, MAX_RECORD + 1 - len(data)) + 1)))
        else:
            data = bytearray(rng.randbytes(rng.randrange(MAX_RECORD + 2)))
        yield bytes(data), rng.choice((1, 47, 113, MAX_RECORD + 1))

def worker(library, folder):
    lib = ctypes.CDLL(str(library))
    probe = lib.jcr_v2_probe
    probe.argtypes = [ctypes.c_void_p, ctypes.c_size_t, ctypes.c_size_t, ctypes.c_void_p, ctypes.c_size_t]
    probe.restype = ctypes.c_int
    accepted = rejected = 0
    digest = hashlib.sha256()
    current = None
    started = time.monotonic()
    try:
        for index, (data, fragment) in enumerate(corpus()):
            if index >= MAX_CASES or len(data) > MAX_RECORD + 1:
                raise RuntimeError('campaign bound exceeded')
            current = {'index': index, 'fragment': fragment, 'base64': base64.b64encode(data).decode('ascii')}
            # Last in-flight case is recoverable even after a native crash/hang.
            (folder / 'inflight.json').write_text(json.dumps(current), encoding='utf-8')
            digest.update(len(data).to_bytes(4, 'big') + fragment.to_bytes(4, 'big') + data)
            try:
                decode(data)
                expected = True
            except ValueError:
                expected = False
            source = ctypes.create_string_buffer(data)
            target = ctypes.create_string_buffer(b'\xa5' * MAX_RECORD, MAX_RECORD)
            result = probe(source, len(data), fragment, target, MAX_RECORD)
            if result < 0 or (result > 0) != expected:
                raise AssertionError(f'oracle mismatch: expected={expected}, result={result}')
            if expected:
                if result != len(data) or target.raw[:result] != data:
                    raise AssertionError('accepted record did not preserve exact bytes')
                accepted += 1
            else:
                if target.raw != b'\xa5' * MAX_RECORD:
                    raise AssertionError('rejected input mutated output')
                rejected += 1
        report = dict(passed=True, cases=accepted + rejected, accepted=accepted, rejected=rejected,
                      corpus_sha256=digest.hexdigest(), seconds=time.monotonic() - started)
    except Exception as error:
        report = dict(passed=False, cases=accepted + rejected, error=f'{type(error).__name__}: {error}', reproducer=current)
    (folder / 'worker.json').write_text(json.dumps(report, indent=2), encoding='utf-8')
    return 0 if report['passed'] else 1

def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--output', type=Path)
    parser.add_argument('--library', type=Path, default=ROOT / 'zig-out/bin/audio-v2-codec-probe.dll')
    parser.add_argument('--worker', type=Path, help=argparse.SUPPRESS)
    args = parser.parse_args()
    if args.worker is not None:
        return worker(args.library.resolve(), args.worker)
    if args.output is None:
        parser.error('--output is required')
    destination = (ROOT / args.output).resolve()
    if not destination.is_relative_to((ROOT / 'verification').resolve()):
        parser.error('Report must stay under this project verification directory')
    if destination.exists():
        parser.error('Refusing to overwrite existing evidence')
    library = args.library.resolve()
    if not library.is_relative_to((ROOT / 'zig-out').resolve()):
        parser.error('Test library must come from this project zig-out directory')
    if not library.is_file():
        parser.error('Build the v2-codec-probe test library first')
    library_digest = hashlib.sha256(library.read_bytes()).hexdigest()
    destination.parent.mkdir(parents=True, exist_ok=True)
    # Reserve this run without replacing a completed report; leave lock on failure
    # to reserve, but remove our own empty lock after the recorded result exists.
    lock = destination.with_suffix(destination.suffix + '.running')
    lock.mkdir()
    with tempfile.TemporaryDirectory(prefix='jcr-v2-oracle-') as scratch:
        folder = Path(scratch)
        command = [sys.executable, str(Path(__file__).resolve()), '--library', str(library), '--worker', str(folder)]
        try:
            run = subprocess.run(command, capture_output=True, text=True, timeout=120)
            child = json.loads((folder / 'worker.json').read_text(encoding='utf-8')) if (folder / 'worker.json').exists() else {'passed': False, 'error': 'child terminated before result'}
            if run.returncode != 0 and child.get('passed'):
                child = {'passed': False, 'error': 'child exit contradicts success'}
            child.update(exit_code=run.returncode, stdout=run.stdout, stderr=run.stderr)
        except subprocess.TimeoutExpired:
            child = {'passed': False, 'error': '120-second child deadline exceeded'}
        if not child['passed'] and (folder / 'inflight.json').exists():
            child['reproducer'] = json.loads((folder / 'inflight.json').read_text(encoding='utf-8'))
        report = {'seed': SEED, 'random_cases': RANDOM_CASES, 'maximum_cases': MAX_CASES,
                  'maximum_input_bytes': MAX_RECORD + 1, 'child_deadline_seconds': 120,
                  'python': sys.version, 'library': str(library),
                  'library_sha256': library_digest, 'result': child}
        with destination.open('x', encoding='utf-8') as output:
            json.dump(report, output, indent=2)
            output.write('\n')
    lock.rmdir()
    print(json.dumps({k: v for k, v in child.items() if k not in {'reproducer', 'stdout', 'stderr'}}))
    return 0 if child['passed'] else 1

if __name__ == '__main__':
    raise SystemExit(main())
