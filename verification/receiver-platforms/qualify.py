"""Source-bound execution/build records; never call an SDK failure a success."""
from pathlib import Path
import datetime,hashlib,json,subprocess,time
root=Path(__file__).resolve().parents[2]
out=Path(__file__).with_name('qualified');out.mkdir(exist_ok=True)
sources=['build.zig','src/security/peer_policy.zig','src/runtime/channel_admission.zig',
         'tests/integration/peer_policy.zig','src/host/audio_device.zig','src/app/main.zig']
hashes={p:hashlib.sha256((root/p).read_bytes()).hexdigest() for p in sources}
(out/'sources.json').write_text(json.dumps(hashes,indent=2)+'\n',encoding='utf-8')
rows=[]
for name,args,expected,marker in [
 ('windows-debug',['audio-test','policy-test','app'],0,'20/20 tests passed'),
 ('windows-safe',['audio-test','policy-test','app','-Doptimize=ReleaseSafe'],0,'20/20 tests passed'),
 ('policy-monterey',['policy-check','-Dtarget=x86_64-macos.12.0'],0,'steps succeeded'),
 ('policy-linux',['policy-check','-Dtarget=x86_64-linux-musl'],0,'steps succeeded'),
 ('policy-ios-object',['policy-object-check','-Dtarget=aarch64-ios.16.0'],0,'steps succeeded'),
 ('policy-ios-link',['policy-check','-Dtarget=aarch64-ios.16.0'],1,'unable to find libSystem system library'),
 ('ios-native-unavailable',['app','-Dtarget=aarch64-ios.16.0'],1,'Native audio/application profile is not implemented for this target'),
]:
 cmd=['zig','build',*args,'--summary','all'];start=time.monotonic()
 with (out/(name+'.log')).open('wb') as log:r=subprocess.run(cmd,cwd=root,stdout=log,stderr=subprocess.STDOUT,timeout=240)
 text=(out/(name+'.log')).read_text(encoding='utf-8',errors='replace')
 row=dict(name=name,command=cmd,exit_code=r.returncode,expected_exit=expected,expected_marker=marker,matched=r.returncode==expected and marker in text,seconds=round(time.monotonic()-start,3),at_utc=datetime.datetime.now(datetime.timezone.utc).isoformat())
 if name.startswith('windows'):row['binary_sha256']=hashlib.sha256((root/'zig-out/bin/lan-audio.exe').read_bytes()).hexdigest()
 rows.append(row);(out/'runs.json').write_text(json.dumps(rows,indent=2)+'\n',encoding='utf-8');print(json.dumps(row),flush=True)
 assert row['matched'],name
exe=root/'zig-out/bin/lan-audio.exe'
for name,args,expected in [('help',['help'],0),('version',['version'],0),('invalid',['devices','--invalid'],2),('devices-1',['devices','--json'],0),('devices-2',['devices','--json'],0)]:
 start=time.monotonic();r=subprocess.run([str(exe),*args],cwd=root,capture_output=True,timeout=30)
 (out/(name+'.stdout')).write_bytes(r.stdout);(out/(name+'.stderr')).write_bytes(r.stderr)
 assert r.returncode==expected,(name,r.stderr)
 row=dict(name=name,command=[str(exe),*args],exit_code=r.returncode,expected_exit=expected,matched=True,seconds=round(time.monotonic()-start,3),binary_sha256=hashlib.sha256(exe.read_bytes()).hexdigest())
 if name.startswith('devices'):
  data=json.loads(r.stdout);assert data['schema']==1 and isinstance(data['devices'],list)
  assert all(isinstance(x['name'],str) and isinstance(x['is_default'],bool) and isinstance(x['selectable_by_name'],bool) for x in data['devices'])
  row['reported_devices']=len(data['devices'])
 rows.append(row);(out/'runs.json').write_text(json.dumps(rows,indent=2)+'\n',encoding='utf-8');print(json.dumps(row),flush=True)
assert all(hashlib.sha256((root/p).read_bytes()).hexdigest()==h for p,h in hashes.items())
