"""Record requested fresh native runs after mutation restoration."""
from pathlib import Path
import datetime
import hashlib
import json
import subprocess
import time

root = Path(__file__).resolve().parents[2]
out = Path(__file__).with_name('qualified')
out.mkdir(exist_ok=True)
sources = ['build.zig', 'src/host/audio_device.zig', 'src/host/net/native.c',
           'src/host/net/native.h', 'src/host/net/socket.zig',
           'tests/integration/network_host.zig', 'tests/integration/audio_device.zig']
hashes = {p: hashlib.sha256((root/p).read_bytes()).hexdigest() for p in sources}
(out/'sources.json').write_text(json.dumps(hashes, indent=2)+'\n', encoding='utf-8')
runs = []
for name, args in [
    ('windows-debug', ['audio-test', 'network-test']),
    ('windows-safe', ['audio-test', 'network-test', '-Doptimize=ReleaseSafe']),
    ('linux-compile', ['network-check', '-Dtarget=x86_64-linux-musl']),
    ('monterey-compile', ['network-check', '-Dtarget=x86_64-macos.12.0']),
    ('macos-26-compile', ['network-check', '-Dtarget=x86_64-macos.26.0']),
]:
    command = ['zig','build',*args,'--summary','all']
    start = time.monotonic()
    with (out/(name+'.log')).open('wb') as log:
        run = subprocess.run(command, cwd=root, stdout=log, stderr=subprocess.STDOUT, timeout=240)
    row = dict(name=name, command=command, exit_code=run.returncode,
               seconds=round(time.monotonic()-start,3),
               at_utc=datetime.datetime.now(datetime.timezone.utc).isoformat())
    runs.append(row)
    (out/'runs.json').write_text(json.dumps(runs,indent=2)+'\n',encoding='utf-8')
    print(json.dumps(row),flush=True)
    assert run.returncode == 0, name
assert all(hashlib.sha256((root/p).read_bytes()).hexdigest()==h for p,h in hashes.items())
