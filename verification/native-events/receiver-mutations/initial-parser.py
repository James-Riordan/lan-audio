"""Require executed receiver fault-gate counterexamples in isolated source files."""
import hashlib
import json
import pathlib
import re
import subprocess
import time

root = pathlib.Path(__file__).resolve().parents[2]
out = pathlib.Path(__file__).with_name('receiver-mutations')
out.mkdir(exist_ok=False)
source = (root / 'src/runtime/receive_drain.zig').read_text(encoding='utf-8')
cases = [
    ('ignore_output_fault', 'if (self.output_fault.load(.acquire)) {', 'if (false) {',
     'receiver output failure blocks admission publication start and drain'),
    ('prepare_ack_after_fault', 'try self.live(token.generation);', '// Deliberately skip the output-fault gate.',
     'receiver output fault blocks new ACK but reconciles an issued late copy'),
]
results = []
for name, before, after, test in cases:
    assert source.count(before) == 1
    mutant = out / (name + '.zig')
    mutant.write_text(source.replace(before, after), encoding='utf-8')
    command = ['zig', 'test', '-ODebug', '--test-filter', test,
               '--dep', 'lifecycle', '--dep', 'lan_audio', '--dep', 'receive_drain', '--dep', 'send_drain', '-Mroot='+str(root/'tests/integration/runtime_lifecycle.zig'),
               '--dep', 'lifecycle', '--dep', 'lan_audio', '-Msend_drain='+str(root/'src/runtime/send_drain.zig'),
               '-Mlifecycle='+str(root/'src/runtime/lifecycle.zig'), '-Mlan_audio='+str(root/'src/root.zig'),
               '--dep', 'lan_audio', '--dep', 'pending_audio', '--dep', 'lifecycle', '-Mreceive_drain='+str(mutant),
               '--dep', 'lan_audio', '-Mpending_audio='+str(root/'src/runtime/pending_block.zig')]
    start = time.monotonic()
    run = subprocess.run(command, cwd=root, capture_output=True, text=True, encoding='utf-8', timeout=180)
    output = run.stdout + run.stderr
    log = out/(name+'.log');log.write_text(output, encoding='utf-8')
    witness = re.search(re.escape(test)+r'\.\.\.FAIL \((TestExpectedEqual|TestExpectedError|TestUnexpectedResult)\)', output)
    row = dict(name=name, command=command, exit_code=run.returncode, seconds=time.monotonic()-start,
               witness=witness.group(0) if witness else None, detected=run.returncode != 0 and witness is not None,
               source_sha256=hashlib.sha256(mutant.read_bytes()).hexdigest(), log_sha256=hashlib.sha256(log.read_bytes()).hexdigest())
    results.append(row);print(name, row['detected'], flush=True)
(out/'results.json').write_text(json.dumps(dict(results=results, passed=all(row['detected'] for row in results)), indent=2)+'\n', encoding='utf-8')
raise SystemExit(0 if all(row['detected'] for row in results) else 1)
