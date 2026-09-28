"""Isolated broken implementations; require the intended executed test to fail."""
import concurrent.futures, hashlib, json, pathlib, re, subprocess, time

root = pathlib.Path(__file__).resolve().parents[2]
out = pathlib.Path(__file__).with_name('mutations')
out.mkdir(exist_ok=False)
sources = {name: (root / ('src/runtime/' + name + '.zig')).read_text() for name in ('lifecycle', 'receive_drain', 'send_drain')}
cases = [
    ('commit_rejected', 'send_drain', 'const copied = result == .write_copied or result == .end_copied;', 'const copied = result == .write_copied or result == .end_copied or result == .write_rejected;', 'sender rejection preserves bytes'),
    ('ignore_source_fault', 'send_drain', 'if (self.source_fault.load(.acquire)) {', 'if (false) {', 'sender sticky source fault'),
    ('forget_uncertain_frames', 'send_drain', 'self.uncertain_frames = self.assembler.pending_frames;', 'self.uncertain_frames = 0;', 'sender uncertain write'),
    ('accept_wrong_ack', 'send_drain', 'candidate.apply(.incoming, message)', 'candidate.apply(.incoming, .{ .kind = .ack, .stream = self.gate.stream, .position = self.gate.next_frame, .frames = message.frames, .body = message.body })', 'sender wrong ACK'),
    ('duplicate_dispatch', 'lifecycle', 'if (self.pending != null or self.cleanup_blocked) return null;', 'if (self.cleanup_blocked) return null;', 'cancel before each dispatch'),
    ('lose_late_success', 'lifecycle', 'self.held[@backingInt(token.resource)] = true;', 'if (self.first_cause == null) self.held[@backingInt(token.resource)] = true;', 'cancel during every acquisition'),
    ('ignore_token_fields', 'lifecycle', 'if (!std.meta.eql(pending, token)) return error.InvalidToken;', 'if (pending.generation != token.generation) return error.InvalidToken;', 'every token field'),
    ('release_live_worker', 'lifecycle', '.kind = if (self.worker_joined) .release else .join_worker', '.kind = .release', 'cancel before each dispatch'),
    ('release_unfenced_device', 'lifecycle', '.kind = if (self.device_fenced) .release else .fence_device', '.kind = .release', 'cancel before each dispatch'),
    ('forget_pending', 'lifecycle', 'empty and self.pending == null', 'empty', 'cancel during every acquisition'),
    ('drop_pending_suffix', 'receive_drain', 'try self.pending.advance(accepted);', 'try self.pending.advance(block.frames);', 'receiver short tail and maximum block'),
    ('require_full_tail', 'receive_drain', '(queued < self.prefill and self.gate.phase != .draining)', '(queued < self.prefill)', 'receiver short tail and maximum block'),
    ('skip_callback_fence', 'lifecycle', 'if (!self.device_fenced) return .{ .executor = .native, .kind = .fence_device, .resource = .device };', '// Deliberately omit native fence.', 'receiver zero END'),
    ('fence_before_publication_closed', 'lifecycle', 'if (!r.publication_closed) return null;', '// Deliberately omit publication closure.', 'receiver short tail and maximum block'),
]

def run(case):
    name, module, before, after, test = case
    source = sources[module]
    assert source.count(before) == 1, name
    mutant = out / (name + '.zig')
    mutant.write_text(source.replace(before, after))
    modules = {n: str(mutant if n == module else root / ('src/runtime/' + n + '.zig')) for n in sources}
    cmd = ['zig', 'test', '-ODebug', '--test-filter', test,
           '--dep', 'lifecycle', '--dep', 'lan_audio', '--dep', 'receive_drain', '--dep', 'send_drain', '-Mroot=' + str(root / 'tests/integration/runtime_lifecycle.zig'),
           '--dep', 'lifecycle', '--dep', 'lan_audio', '-Msend_drain=' + modules['send_drain'], '-Mlifecycle=' + modules['lifecycle'], '-Mlan_audio=' + str(root / 'src/root.zig'),
           '--dep', 'lan_audio', '--dep', 'pending_audio', '--dep', 'lifecycle', '-Mreceive_drain=' + modules['receive_drain'],
           '--dep', 'lan_audio', '-Mpending_audio=' + str(root / 'src/runtime/pending_block.zig')]
    start = time.monotonic()
    result = subprocess.run(cmd, cwd=root, capture_output=True, text=True, timeout=180)
    output = result.stdout + result.stderr
    log = out / (name + '.log'); log.write_text(output)
    blocks = re.split(r'(?m)(?=^\d+/\d+ runtime_lifecycle\.test\.)', output)
    witness = next((b.splitlines()[:2] for b in blocks if test in b.split('\n', 1)[0] and re.search(r'(?:^|\.\.\.)FAIL \((TestExpectedEqual|TestExpectedError|TestUnexpectedResult)\)', b, re.M)), None)
    row = dict(mutation=name, command=cmd, exit_code=result.returncode, seconds=time.monotonic()-start, expected_test=test, witness=witness, detected=result.returncode != 0 and witness is not None, source_sha256=hashlib.sha256(mutant.read_bytes()).hexdigest(), log_sha256=hashlib.sha256(log.read_bytes()).hexdigest())
    print(name, 'detected=' + str(row['detected']), flush=True)
    return row

with concurrent.futures.ThreadPoolExecutor(max_workers=3) as pool:
    results = list(pool.map(run, cases))
(out / 'results.json').write_text(json.dumps({'tests_sha256': hashlib.sha256((root / 'tests/integration/runtime_lifecycle.zig').read_bytes()).hexdigest(), 'sources': {n: hashlib.sha256((root / ('src/runtime/' + n + '.zig')).read_bytes()).hexdigest() for n in sources}, 'results': results, 'passed': all(r['detected'] for r in results)}, indent=2)+'\n')
raise SystemExit(0 if all(r['detected'] for r in results) else 1)
