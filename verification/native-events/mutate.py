"""Break native event/custody behavior in isolated copies; require test witnesses."""
import concurrent.futures
import hashlib
import json
import os
import pathlib
import re
import shutil
import subprocess
import time

root = pathlib.Path(__file__).resolve().parents[2]
out = pathlib.Path(__file__).with_name('mutations')
out.mkdir(exist_ok=False)
cases = [
    ('ignore_reroute', 'src/host/audio_device.zig',
     'c.ma_device_notification_type_rerouted => self.rerouted.store(true, .release),',
     'c.ma_device_notification_type_rerouted => return,',
     'installed native notifications invalidate both directions without consuming media'),
    ('consume_failed_output', 'src/audio/callback_bridge.zig',
     'const available = if (self.playback_failed.load(.acquire)) 0 else self.playback.read(output);',
     'const available = self.playback.read(output);',
     'installed native notifications invalidate both directions without consuming media'),
    ('fault_expected_stop', 'src/host/audio_device.zig',
     'if (self.expected_stop.load(.acquire)) return;',
     '// Deliberately classify every normal stop as a fault.',
     'installed native notifications invalidate both directions without consuming media'),
    ('resume_failed_generation', 'src/host/audio_device.zig',
     '=> return, // Resuming/unlocking never clears an earlier fault.',
     '=> { self.bridge.capture_failed.store(false, .release); self.bridge.playback_failed.store(false, .release); return; },',
     'installed native notifications invalidate both directions without consuming media'),
]


def run(case):
    name, file, before, after, expected = case
    work = out / name
    work.mkdir()
    for directory in ['src', 'tests']:
        shutil.copytree(root / directory, work / directory)
    for file_name in ['build.zig', 'AGENTS.md', 'README.md']:
        shutil.copyfile(root / file_name, work / file_name)
    manifest = (root / 'build.zig.zon').read_text(encoding='utf-8')
    for dependency in ['miniaudio-zig', 'tls-zig']:
        manifest = manifest.replace('../' + dependency, pathlib.Path(os.path.relpath(root.parent / dependency, work)).as_posix())
    (work / 'build.zig.zon').write_text(manifest, encoding='utf-8')
    path = work / file
    source = path.read_text(encoding='utf-8')
    assert source.count(before) == 1, name
    path.write_text(source.replace(before, after), encoding='utf-8')
    command = ['zig', 'build', 'audio-test', '--summary', 'all', '--cache-dir', str(root / '.zig-cache/native-events-mutations')]
    start = time.monotonic()
    log = out / (name + '.log')
    with log.open('w', encoding='utf-8') as f:
        result = subprocess.run(command, cwd=work, stdout=f, stderr=subprocess.STDOUT, timeout=240)
    output = log.read_text(encoding='utf-8')
    witness = re.search(r"error: '[^'\n]*\.test\." + re.escape(expected) + r"' failed", output)
    row = dict(name=name, command=command, cwd=str(work), exit_code=result.returncode,
               seconds=time.monotonic()-start, expected_test=expected,
               witness=witness.group(0) if witness else None,
               detected=result.returncode != 0 and witness is not None,
               source_sha256=hashlib.sha256(path.read_bytes()).hexdigest(),
               log_sha256=hashlib.sha256(log.read_bytes()).hexdigest())
    print(name, row['detected'], flush=True)
    return row


with concurrent.futures.ThreadPoolExecutor(max_workers=2) as pool:
    results = list(pool.map(run, cases))
(out / 'results.json').write_text(json.dumps(dict(results=results, passed=all(row['detected'] for row in results)), indent=2)+'\n', encoding='utf-8')
raise SystemExit(0 if all(row['detected'] for row in results) else 1)
