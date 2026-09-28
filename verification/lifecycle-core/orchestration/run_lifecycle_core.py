import hashlib, json, os, subprocess, sys, time
from datetime import datetime, timezone
from pathlib import Path
root=Path('C:/Projects/lan-audio')
phase=root/'verification/lifecycle-core'
name=sys.argv[1]
command=sys.argv[2:]
log=phase/(name+'.log'); record=phase/(name+'.json')
if log.exists() or record.exists(): raise SystemExit('Refusing to overwrite evidence')
start=time.monotonic()
run=subprocess.run(command,cwd=root,capture_output=True,text=True,encoding='utf-8',errors='replace',timeout=600,env={**os.environ,'PYTHONUTF8':'1'})
log.write_text(run.stdout+run.stderr,encoding='utf-8')
row={'command':command,'cwd':str(root),'observed_at_utc':datetime.now(timezone.utc).isoformat(),'elapsed_seconds':time.monotonic()-start,'exit_code':run.returncode,'log':log.name,'log_sha256':hashlib.sha256(log.read_bytes()).hexdigest()}
record.write_text(json.dumps(row,indent=2)+'\n',encoding='utf-8')
print(json.dumps(row),flush=True)
print(run.stdout+run.stderr,flush=True)
raise SystemExit(run.returncode)
