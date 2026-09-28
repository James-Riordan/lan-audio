"""Qualify the fake-owner oracle against isolated corruptions of real Zig code."""
import hashlib,json,re,subprocess,sys,time
from pathlib import Path
r=Path('C:/Projects/lan-audio');p=r/'verification/lifecycle-core'/(sys.argv[1] if len(sys.argv)>1 else 'mutations-3')
p.mkdir(exist_ok=False)
source=(r/'src/runtime/lifecycle.zig').read_text(encoding='utf-8')
mutations=[
 ('duplicate_dispatch','if (self.pending != null or self.cleanup_blocked) return null;','if (self.cleanup_blocked) return null;', 'cancel before each dispatch'),
 ('lose_late_success','self.held[@backingInt(token.resource)] = true;','if (self.first_cause == null) self.held[@backingInt(token.resource)] = true;', 'cancel during every acquisition'),
 ('ignore_token_fields','if (!std.meta.eql(pending, token)) return error.InvalidToken;','if (pending.generation != token.generation) return error.InvalidToken;', 'every token field'),
 ('release_live_worker','.kind = if (self.worker_joined) .release else .join_worker','.kind = .release', 'cancel before each dispatch'),
 ('release_unfenced_device','.kind = if (self.device_fenced) .release else .fence_device','.kind = .release', 'cancel before each dispatch'),
 ('forget_pending_at_terminal','empty and self.pending == null','empty', 'cancel during every acquisition'),
]
results=[]
for name,before,after,test_name in mutations:
    assert source.count(before)==1,(name,source.count(before))
    mutant=p/(name+'.zig'); mutant.write_text(source.replace(before,after),encoding='utf-8')
    command=['zig','test','-ODebug','--dep','lifecycle','-Mroot='+str(r/'tests/integration/runtime_lifecycle.zig'),'-Mlifecycle='+str(mutant),'--cache-dir',str(Path.cwd()/'work/lifecycle-mutation-cache')]
    start=time.monotonic(); run=subprocess.run(command,cwd=r,capture_output=True,text=True,encoding='utf-8',errors='replace',timeout=180)
    output=run.stdout+run.stderr; log=p/(name+'.log');log.write_text(output,encoding='utf-8')
    # Require a named executed test failure, not just a compilation/nonzero exit.
    blocks=re.split(r'(?m)(?=^\d+/\d+ runtime_lifecycle\.test\.)',output)
    witness=next((block.splitlines()[:2] for block in blocks if test_name in block.split('\n',1)[0] and re.search(r'(?m)(?:^|\.\.\.)FAIL \((TestExpectedEqual|TestExpectedError|TestUnexpectedResult)\)',block)),None)
    row={'mutation':name,'command':command,'exit_code':run.returncode,'seconds':time.monotonic()-start,'expected_test':test_name,'witness':witness,'detected':run.returncode!=0 and witness is not None,'source_sha256':hashlib.sha256(mutant.read_bytes()).hexdigest(),'log_sha256':hashlib.sha256(log.read_bytes()).hexdigest()}
    results.append(row);print(json.dumps(row),flush=True)
(p/'results.json').write_text(json.dumps({'production_sha256':hashlib.sha256((r/'src/runtime/lifecycle.zig').read_bytes()).hexdigest(),'tests_sha256':hashlib.sha256((r/'tests/integration/runtime_lifecycle.zig').read_bytes()).hexdigest(),'results':results,'passed':all(x['detected'] for x in results)},indent=2)+'\n',encoding='utf-8')
raise SystemExit(0 if all(x['detected'] for x in results) else 1)
