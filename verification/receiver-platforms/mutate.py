"""Preserve compiled counterexamples and restore source before qualification."""
from pathlib import Path
import hashlib,json,re,subprocess,time
root=Path(__file__).resolve().parents[2]
out=Path(__file__).with_name('mutations');out.mkdir(exist_ok=True)
cases=[
 ('skip-mutual-auth','src/security/peer_policy.zig',
  'if (!evidence.mutually_authenticated) return error.Unauthenticated;',
  '// Deliberate missing mutual authentication check.',
  'independent 128-case authorization table requires every binding condition'),
 ('skip-selected-peer','src/security/peer_policy.zig',
  'if (!std.mem.eql(u8, &evidence.verified_leaf, &expected_peer)) return error.WrongPeer;',
  '_ = expected_peer; // Deliberate missing selected-peer binding.',
  'independent 128-case authorization table requires every binding condition'),
 ('repeat-resets-stream','src/runtime/channel_admission.zig',
  'return .unchanged; // Preserve negotiated stream, format and frontier.',
  'self.gate = core.Negotiation.init(self.gate.role); try self.gate.authorizeChannel(); return .unchanged;',
  'repeated authorization preserves an actual negotiated frame frontier'),
 ('stale-revokes-replacement','src/runtime/channel_admission.zig',
  'pub fn revoke(self: *Channel, generation: u64) Error!void {\n        if (generation != self.generation) return error.StaleGeneration;',
  'pub fn revoke(self: *Channel, generation: u64) Error!void {\n        _ = generation;',
  'stale platform events cannot change a replacement and repeated revocation converges'),
]
rows=[]
for name,relative,old,new,witness in cases:
 p=root/relative;original=p.read_bytes();source=original.decode('utf-8');assert source.count(old)==1,name
 changed=source.replace(old,new).encode('utf-8');(out/(name+'.source')).write_bytes(changed)
 start=time.monotonic();cmd=['zig','build','policy-test','--summary','all']
 try:
  p.write_bytes(changed)
  with (out/(name+'.log')).open('wb') as log:r=subprocess.run(cmd,cwd=root,stdout=log,stderr=subprocess.STDOUT,timeout=180)
  text=(out/(name+'.log')).read_text(encoding='utf-8',errors='replace')
  detected=r.returncode!=0 and bool(re.search(r"error: '[^'\n]*"+re.escape(witness)+r"' failed:",text)) and bool(re.search(r'run test \d+ pass, [1-9]\d* fail',text)) and 'compile test debug native success' in text
  row=dict(name=name,source_path=relative,original_sha256=hashlib.sha256(original).hexdigest(),mutant_sha256=hashlib.sha256(changed).hexdigest(),log_sha256=hashlib.sha256((out/(name+'.log')).read_bytes()).hexdigest(),command=cmd,exit_code=r.returncode,seconds=round(time.monotonic()-start,3),witness=witness,detected=detected)
  rows.append(row);(out/'results.json').write_text(json.dumps(rows,indent=2)+'\n',encoding='utf-8');print(json.dumps(row),flush=True)
 finally:
  p.write_bytes(original);assert p.read_bytes()==original
assert len(rows)==4 and all(r['detected'] for r in rows)
