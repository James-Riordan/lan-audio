"""Seal completed files. Return stdout to the terminal; do not redirect it here."""
from pathlib import Path
import datetime,hashlib,json,platform,subprocess,sys,time
root=Path(__file__).resolve().parents[2];out=Path(__file__).parent
sys.path.insert(0,str(root/'tools'))
from build_reference import inventory
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def read(p):return json.loads(p.read_text(encoding='utf-8'))
before=read(out/'before.json');prior=root/'verification/native-failures/receipt.json'
assert sha(prior)==before['prior_receipt_sha256']
baseline=read(prior);old={str(Path(r['path'])):r for r in baseline['sources_and_installed_assets']}
qualified=read(out/'qualified/sources.json');runs=read(out/'qualified/runs.json');mutations=read(out/'mutations/results.json')
assert len(runs)==12 and all(r['matched'] for r in runs)
assert [(r['name'],r['exit_code']) for r in runs if r['exit_code']!=0]==[('policy-ios-link',1),('ios-native-unavailable',1),('invalid',2)]
for name in ['windows-debug','windows-safe']:
 text=(out/'qualified'/(name+'.log')).read_text(encoding='utf-8')
 assert '20/20 tests passed' in text and text.count('run test 7 pass (7 total)')==2
for p,h in qualified.items():assert sha(root/p)==h,p
assert len(mutations)==4 and all(r['detected'] for r in mutations)
for r in mutations:
 assert sha(root/r['source_path'])==r['original_sha256']
 assert sha(out/'mutations'/(r['name']+'.log'))==r['log_sha256']
for r in baseline['sources_and_installed_assets']:
 p=Path(r['path'])
 if 'miniaudio-zig' in p.parts and p.suffix in {'.zig','.c','.h','.zon'}:assert sha(p)==r['sha256'],str(p)
for name in ['src/root.zig','build.zig.zon','transport-lock.json','src/runtime/lifecycle.zig',
             'src/runtime/send_drain.zig','src/runtime/receive_drain.zig','src/host/net/socket.zig',
             'src/host/net/native.c','src/host/net/native.h','docs/reference/miniaudio-zig.md',
             'docs/reference/tls-zig.md','docs/reference/upstream-assets.md','docs/reference/evidence.md']:
 assert sha(root/name)==old[str(root/name)]['sha256'],name
checks=[]
for name,cmd in [
 ('reference',['python','tools/build_reference.py','--application-only']),
 ('docs',['python','tools/check_docs.py','--application-only']),
 ('handoff',['python','tools/check_handoff.py','--application-only']),
 ('transport-custody',['python','tools/check_transport.py']),
]:
 start=time.monotonic()
 with (out/(name+'.log')).open('w',encoding='utf-8') as log:r=subprocess.run(cmd,cwd=root,stdout=log,stderr=subprocess.STDOUT)
 checks.append(dict(name=name,command=cmd,exit_code=r.returncode,seconds=round(time.monotonic()-start,3)))
 (out/'checks.json').write_text(json.dumps(checks,indent=2)+'\n',encoding='utf-8');print(name,r.returncode,flush=True)
 if name!='transport-custody':assert r.returncode==0,name
lock=read(root/'transport-lock.json');dependency=(root/lock['root']).resolve();mismatches=[]
for row in lock['files']:
 p=(dependency/row['path']).resolve();assert p.is_relative_to(dependency)
 observed=sha(p) if p.is_file() else None
 if observed!=row['sha256']:mismatches.append(dict(path=str(p),reviewed_sha256=row['sha256'],observed_sha256=observed))
assert (checks[-1]['exit_code']==0)==(len(mismatches)==0)
observations=[];changes=[];unadopted=[]
for project,relative,p in inventory():
 digest=sha(p);previous=old.get(str(p))
 reviewed=previous and previous.get('adoption')!='unadopted_observation' and previous['sha256']==digest
 adoption='application' if project=='lan-audio' else 'reviewed_unchanged' if reviewed else 'unadopted_observation'
 row=dict(path=str(p),sha256=digest,bytes=p.stat().st_size,adoption=adoption);observations.append(row)
 if project=='lan-audio':
  if previous is None or previous['sha256']!=digest:changes.append(relative)
  snapshot=out/'source-snapshot'/relative;snapshot.parent.mkdir(parents=True,exist_ok=True)
  with snapshot.open('xb') as f:f.write(p.read_bytes())
  assert sha(snapshot)==digest
 if adoption=='unadopted_observation':unadopted.append(row)
binary=root/'zig-out/bin/lan-audio.exe';binary_sha=sha(binary)
safe=next(r for r in runs if r['name']=='windows-safe');assert binary_sha==safe['binary_sha256']
receipt=dict(
 phase='receiver-platforms',observed_at_utc=datetime.datetime.now(datetime.timezone.utc).isoformat(),
 host=platform.platform(),zig=subprocess.check_output(['zig','version'],text=True).strip(),
 prior_receipt=dict(path=str(prior),sha256=sha(prior)),initial_application_files_verified=len(before['application']),
 scope='Shared peer/channel authorization, copied discovery, foreground inspection, required MacBook/iPhone targets. Streaming/native iPhone app not implemented.',
 current_qualified_source_hashes=qualified,runs=runs,mutations=mutations,checks=checks,
 command_passthrough=read(out/'qualified/run-step.json'),
 inspected_executable=dict(path=str(binary),sha256=binary_sha,configuration='ReleaseSafe',purpose='Development device-inspection command only'),
 transport_custody_status='FAILED: unadopted dependency revision' if mismatches else 'passed',
 transport_custody_mismatches=mismatches,sources_and_installed_assets=observations,
 changed_or_added_application_paths=changes,unadopted_dependency_observations=unadopted,
 application_snapshot='source-snapshot: exact current authored/support application bytes; dependency sources remain separately pinned',
 evidence_files=[dict(path=str(p.relative_to(out)),sha256=sha(p),bytes=p.stat().st_size) for p in sorted(out.rglob('*')) if p.is_file() and p.name!='receipt.json'],
 limits=['Policy tests use synthetic host evidence, not real verified-peer TLS export or durable key storage.',
 'Only actual Windows enumeration and null-device tests; no physical capture/playback, Wi-Fi or two-host run.',
 'iOS object compilation is not SDK linking, execution, signing or installation. Full iOS link failed for unavailable libSystem.',
 'Native iPhone receiver and sender/receiver commands/workers remain unimplemented; macOS native deployment remains unqualified.',
 'Repeated authorization/revocation is implemented, but native effect deduplication/joins and global policy publication remain host obligations.',
 'The copied catalog is bounded, but native enumeration may allocate independently; copied names are not stable endpoint IDs.',
 'Inherited Perl locale diagnostics remain preserved in successful native build logs.',
 'Stable core, native dependency sources and reviewed pins are unchanged; sibling changes are observed without adoption.'])
with (out/'receipt.json').open('x',encoding='utf-8') as f:json.dump(receipt,f,indent=2,ensure_ascii=False);f.write('\n')
assert all(sha(out/r['path'])==r['sha256'] for r in receipt['evidence_files'])
print(json.dumps(dict(receipt=str(out/'receipt.json'),sha256=sha(out/'receipt.json'),changed_paths=len(changes),application_files=sum(r['adoption']=='application' for r in observations),evidence_files_verified=len(receipt['evidence_files']),transport_mismatches=len(mismatches))))
