"""Bounded, sequential source mutations; restore exact bytes even on failure."""
from pathlib import Path
import hashlib
import json
import subprocess
import time

root = Path(__file__).resolve().parents[2]
out = Path(__file__).with_name('mutations')
out.mkdir(exist_ok=True)
cases = [
    ('start-error-ready', 'src/host/audio_device.zig',
     'self.state = .failed;\n                return error.DeviceStart;',
     'self.state = .ready;\n                return error.DeviceStart;',
     'audio-test', 'native API failures preserve ownership cleanup and reconstruction'),
    ('stop-error-ready', 'src/host/audio_device.zig',
     'self.state = .failed;\n                return error.DeviceStop;',
     'self.state = .ready;\n                return error.DeviceStop;',
     'audio-test', 'native API failures preserve ownership cleanup and reconstruction'),
    ('writable-means-connected', 'src/host/net/socket.zig',
     'if (c.la_net_finish_connect(&self.native) != c.LA_NET_OK) return self.fail();',
     '// Deliberate defect: skip SO_ERROR.',
     'network-test', 'refused connect never becomes connected merely because the socket is writable'),
    ('eof-closes-both-directions', 'src/host/net/socket.zig',
     'if (count == 0) self.read_eof = true;',
     'if (count == 0) { self.read_eof = true; self.write_closed = true; }',
     'network-test', 'IPv4 and IPv6 preserve byte prefixes and independent half close after listener release'),
]
results = []
for name, relative, old, new, step, witness in cases:
    path = root / relative
    original = path.read_bytes()
    source = original.decode('utf-8')
    assert source.count(old) == 1, name
    changed = source.replace(old, new).encode('utf-8')
    (out / (name + '.source')).write_bytes(changed)
    command = ['zig', 'build', step, '--summary', 'all']
    start = time.monotonic()
    try:
        path.write_bytes(changed)
        with (out / (name + '.log')).open('wb') as log:
            run = subprocess.run(command, cwd=root, stdout=log, stderr=subprocess.STDOUT, timeout=180)
        text = (out / (name + '.log')).read_text(encoding='utf-8', errors='replace')
        # A compile failure is not detection. Require the executed test name,
        # a failed-test summary, and a runtime assertion/error witness.
        detected = run.returncode != 0 and witness in text and 'test failure' in text and ('FAIL' in text or 'expected' in text or 'InvalidState' in text)
        row = dict(name=name, command=command, source_path=relative,
                   original_sha256=hashlib.sha256(original).hexdigest(),
                   mutant_sha256=hashlib.sha256(changed).hexdigest(),
                   log_sha256=hashlib.sha256((out / (name + '.log')).read_bytes()).hexdigest(),
                   exit_code=run.returncode, seconds=round(time.monotonic()-start,3),
                   witness=witness, detected=detected)
        results.append(row)
        (out / 'results.json').write_text(json.dumps(results, indent=2)+'\n', encoding='utf-8')
        print(json.dumps(row), flush=True)
    finally:
        path.write_bytes(original)
        assert path.read_bytes() == original
assert all(r['detected'] for r in results), 'Inspect raw failure witnesses; do not count compiler failures.'
