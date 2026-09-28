from pathlib import Path
import datetime
import hashlib
import importlib.util
import json
import platform
import shutil
import subprocess

ROOT=Path('C:/Projects/lan-audio')
P=ROOT/'verification/verified-channel'
def digest(path): return hashlib.sha256(path.read_bytes()).hexdigest()
def read(path): return json.loads(path.read_text())

prior=ROOT/'verification/receiver-platforms/receipt.json'
if digest(prior)!='18631d3e831db5c87fee13c8f7e0fc76029b58be3780088d330edab2480c229d':
    raise RuntimeError('prior receipt changed')
baseline=read(P/'baseline.json')
for rel,sha in baseline['application_files'].items():
    if digest(P/'before'/rel)!=sha: raise RuntimeError('before snapshot changed: '+rel)
for row in read(prior)['evidence_files']:
    if digest(prior.parent/row['path'])!=row['sha256']: raise RuntimeError('prior evidence changed')
for mode in ('Debug','ReleaseSafe'):
    rows=read(P/'final-host'/f'{mode}.json')['results']
    if len(rows)!=43 or not all(r['matched'] for r in rows): raise RuntimeError('final host not qualified')
for rel,count in [('qualified/legacy-v1.json',16),('qualified/legacy-v2.json',22)]:
    rows=read(P/rel)['results']
    if len(rows)!=count or not all(r['passed'] for r in rows): raise RuntimeError('legacy regression failed')
if not all(r['caught'] for r in read(P/'mutations/results.json')): raise RuntimeError('mutation survived')
for name in ('buffered-deadline','after-end'):
    if all(r['matched'] for r in read(P/'buffered-record-regression'/f'{name}.json')['results']):
        raise RuntimeError('earlier defective source was not caught')
if not read(P/'ios-unsupported.json')['expected_rejection']: raise RuntimeError('unsupported iOS gate')

results='''# Verified native connection — qualification

This increment connects the actual application TCP owner, reviewed TLS Driver and
live verified peer leaf identity to copied policy and v2 records. It adds no device
streaming command, native Apple app, credential store or physical audio run.

## Current source results

- Final host: 43 independent Python-peer scenarios pass in both Debug and ReleaseSafe.
  Eight positive combinations cover both TLS roles, both audio roles and IPv4/IPv6,
  exact words for 1285 frames, mutual certificate identity and clean TLS close.
  Negative cases cover approval/role/identity, protocol, deadline, EOF, cancellation,
  policy revision, truncation, trailing records and buffered expiry.
- Each positive path checks 32 repeated authorizations, seven stale operations and
  repeated cleanup. Receiver completion here is a synchronous verifier, not a device.
- Three compiled authorization/lifetime mutants were caught. Two further regressions
  fail on the preserved earlier implementation: buffered expiry and ACK after known
  trailing data. Final source has both guards; fresh 43-case results supersede the
  prior 42-case host qualification for these changes.
- Existing v1 (16 cases) and v2 (22 cases) media regressions pass with the reviewed
  TLS adoption. Policy/network component tests pass in both modes (13 tests).
  These unchanged execution closures were not rerun after the two isolated host guards.
- All 188 reviewed TLS custody entries and staged DLLs pass. Five entries changed
  by explicit reviewed adoption, with the copied owner receipt and rationale retained;
  183 entries stayed fixed. All 47 previously observed miniaudio files are unchanged.
- iOS native transport probe intentionally rejects as unsupported. Earlier iOS
  shared-policy object compilation remains separate, with no native Apple qualification.

## Historical attempts and limits

The initial build succeeded. The first independent campaign rejected all intended
bad connections but incorrectly classified three error names (server ALPN and two
sequence errors). The raw 38-case result and classifier review remain in attempt-2.
The corrected/expanded 42-case campaign passed, then passed in both modes with the
legacy suites. Subsequent code inspection identified the two buffered-record guards;
before-code tests reproduce them and the final 43-case campaign passes freshly.

The inherited Perl locale warning appears in raw build output even where the final
build summary and process report success. It has not been rewritten or claimed fixed.
The native evidence is Windows 10 x86_64. Public fixture keys and frozen certificate
time remain only in test programs. No Mac/iPhone execution, sustained Wi-Fi audio,
acoustic fidelity/latency, secure pairing/storage, packaging/signing or release claim
follows. Live capture/playback workers and their lifecycle/callback mapping are next.

`receipt.json` binds current application bytes, exact source snapshot, adoption,
commands, raw evidence, and executable hashes. It is a review record, not a proof of
universal correctness. The previous 135-file snapshot and all 206 prior evidence
files were verified and preserved.
'''
(P/'RESULTS.md').write_text(results)

checks=[]
for name,cmd in [
 ('reference',['python','tools/build_reference.py','--application-only']),
 ('docs',['python','tools/check_docs.py','--application-only']),
 ('handoff',['python','tools/check_handoff.py','--application-only']),
 ('custody',['python','tools/check_transport.py','--staged']),
]:
    result=subprocess.run(cmd,cwd=ROOT,capture_output=True,timeout=90)
    (P/(name+'.log')).write_bytes(result.stdout+result.stderr)
    checks.append(dict(name=name,command=cmd,exit_code=result.returncode))
    print((result.stdout+result.stderr).decode(errors='replace'),flush=True)
    if result.returncode: raise RuntimeError(name+' gate failed')

spec=importlib.util.spec_from_file_location('inventory',ROOT/'tools/build_reference.py')
mod=importlib.util.module_from_spec(spec)
spec.loader.exec_module(mod)
application={rel:digest(path) for project,rel,path in mod.inventory() if project=='lan-audio'}
snapshot=P/'source-snapshot'
snapshot.mkdir(exist_ok=False)
for rel,sha in application.items():
    target=snapshot/rel
    target.parent.mkdir(parents=True,exist_ok=True)
    shutil.copy2(ROOT/rel,target)
    if digest(target)!=sha: raise RuntimeError('snapshot mismatch')

stable=['src/root.zig','src/host/audio_device.zig','src/host/net/socket.zig','src/host/net/native.c','src/host/net/native.h','src/runtime/send_drain.zig','src/runtime/receive_drain.zig','src/runtime/lifecycle.zig','src/app/main.zig']
for rel in stable:
    if digest(ROOT/rel)!=baseline['application_files'][rel]: raise RuntimeError('unexpected stable source change: '+rel)
for row in read(prior)['sources_and_installed_assets']:
    if '/miniaudio-zig/' in row['path'].replace('\\','/') and digest(Path(row['path']))!=row['sha256']:
        raise RuntimeError('miniaudio changed')

receipt=dict(phase='verified-channel',observed_at_utc=datetime.datetime.now(datetime.timezone.utc).isoformat(),host=platform.platform(),
    zig=subprocess.check_output(['zig','version'],text=True).strip(),
    prior_receipt={'path':str(prior),'sha256':digest(prior)},
    prior_application_files_verified=135,prior_evidence_files_verified=206,
    scope='Real native Socket/TLS/peer authorization/v2 records. No physical audio or production receiver apps.',
    final_host_runs=read(P/'final-host/runs.json'),
    integration_and_component_runs=read(P/'qualified/runs.json'),
    mutations=read(P/'mutations/results.json'),
    buffered_regressions=read(P/'buffered-record-regression/runs.json'),
    checks=checks,dependency_adoption=read(P/'dependency-adoption.json'),
    application_files=application,
    changed_or_added_paths=[rel for rel,sha in application.items() if baseline['application_files'].get(rel)!=sha],
    stable_source_files=stable,
    source_snapshot='source-snapshot',
    executable={'path':'zig-out/bin/audio-verified-probe.exe','sha256':digest(ROOT/'zig-out/bin/audio-verified-probe.exe'),'configuration':'ReleaseSafe'},
    limits=['Windows native execution only; MacBook/iPhone receivers unimplemented/unqualified.',
            'Public credentials/frozen wall time only in test probe. Real enrollment/storage remains open.',
            'No physical audio, actual worker/controller/callback mapping, sustained timing or release claim.',
            'Legacy/component regressions retain unchanged source closure; final host guards freshly qualify 43 cases in both modes.',
            'TLS owner receipt is reviewed records-only adoption, not adoption of independently evolving QUIC sources.'])
receipt['evidence_files']=[{'path':f.relative_to(P).as_posix(),'sha256':digest(f),'bytes':f.stat().st_size} for f in sorted(P.rglob('*')) if f.is_file() and f.name!='receipt.json']
out=P/'receipt.json'
if out.exists(): raise RuntimeError('already sealed')
out.write_text(json.dumps(receipt,indent=2)+'\n')
for rel,sha in application.items():
    if digest(ROOT/rel)!=sha: raise RuntimeError('source changed during seal')
for entry in receipt['evidence_files']:
    if digest(P/entry['path'])!=entry['sha256']: raise RuntimeError('evidence changed during seal')
print(json.dumps({'receipt_sha256':digest(out),'application_files':len(application),'changed':len(receipt['changed_or_added_paths']),'evidence_files':len(receipt['evidence_files'])}),flush=True)
