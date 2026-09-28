"""Seal restored application evidence without adopting independently changed TLS."""
from pathlib import Path
import datetime
import hashlib
import json
import platform
import subprocess
import sys
import time

root = Path(__file__).resolve().parents[2]
out = Path(__file__).parent
sys.path.insert(0, str(root/'tools'))
from build_reference import inventory

def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()

def read(path):
    return json.loads(path.read_text(encoding='utf-8'))

before = read(out/'before.json')
prior = root/'verification/native-events/receipt.json'
assert sha(prior) == before['prior_receipt_sha256']
baseline = read(prior)
old = {str(Path(row['path'])): row for row in baseline['sources_and_installed_assets']}
qualified = read(out/'qualified/sources.json')
runs = read(out/'qualified/runs.json')
assert len(runs) == 5 and all(r['exit_code']==0 for r in runs)
for name in ['windows-debug','windows-safe']:
    log=(out/'qualified'/(name+'.log')).read_text(encoding='utf-8')
    assert '17/17 tests passed' in log, name
    assert 'run test 5 pass (5 total)' in log, name
    assert log.count('run test 6 pass (6 total)')==2, name
for path, expected in qualified.items():
    assert sha(root/path)==expected, path
mutations = read(out/'mutations/reviewed-results.json')
assert len(mutations)==4 and all(r['detected'] for r in mutations)
for row in mutations:
    assert row['exit_code'] != 0
    assert sha(out/'mutations'/(row['name']+'.log'))==row['log_sha256']
    assert sha(root/row['source_path'])==row['original_sha256']
for row in baseline['sources_and_installed_assets']:
    path=Path(row['path'])
    if 'miniaudio-zig' in path.parts and path.suffix in {'.zig','.c','.h','.zon'}:
        assert sha(path)==row['sha256'], str(path)
for name in ['src/root.zig','build.zig.zon','transport-lock.json','src/runtime/lifecycle.zig',
             'src/runtime/send_drain.zig','src/runtime/receive_drain.zig',
             'docs/reference/miniaudio-zig.md','docs/reference/tls-zig.md',
             'docs/reference/upstream-assets.md','docs/reference/evidence.md']:
    assert sha(root/name)==old[str(root/name)]['sha256'], name
checks=[]
for name,command in [
    ('reference',['python','tools/build_reference.py','--application-only']),
    ('docs',['python','tools/check_docs.py','--application-only']),
    ('handoff',['python','tools/check_handoff.py','--application-only']),
    ('transport-custody',['python','tools/check_transport.py']),
]:
    start=time.monotonic()
    with (out/(name+'.log')).open('w',encoding='utf-8') as log:
        run=subprocess.run(command,cwd=root,stdout=log,stderr=subprocess.STDOUT)
    checks.append(dict(name=name,command=command,exit_code=run.returncode,seconds=time.monotonic()-start))
    (out/'checks.json').write_text(json.dumps(checks,indent=2)+'\n',encoding='utf-8')
    print(name,run.returncode,flush=True)
    if name!='transport-custody': assert run.returncode==0,name
lock=read(root/'transport-lock.json')
dependency=(root/lock['root']).resolve()
mismatches=[]
for entry in lock['files']:
    path=(dependency/entry['path']).resolve()
    assert path.is_relative_to(dependency)
    observed=sha(path) if path.is_file() else None
    if observed!=entry['sha256']:
        mismatches.append(dict(path=str(path),reviewed_sha256=entry['sha256'],observed_sha256=observed))
assert (checks[-1]['exit_code']==0)==(len(mismatches)==0)
observations,changes,unadopted=[],[],[]
for project,relative,path in inventory():
    digest=sha(path); previous=old.get(str(path))
    reviewed=previous and previous.get('adoption')!='unadopted_observation' and previous['sha256']==digest
    adoption='application' if project=='lan-audio' else 'reviewed_unchanged' if reviewed else 'unadopted_observation'
    row=dict(path=str(path),sha256=digest,bytes=path.stat().st_size,adoption=adoption)
    observations.append(row)
    if project=='lan-audio' and (previous is None or previous['sha256']!=digest): changes.append(relative)
    if adoption=='unadopted_observation': unadopted.append(row)
receipt=dict(
    phase='native-failures',observed_at_utc=datetime.datetime.now(datetime.timezone.utc).isoformat(),
    host=platform.platform(),zig=subprocess.check_output(['zig','version'],text=True).strip(),
    prior_receipt=dict(path=str(prior),sha256=sha(prior)),initial_application_files_verified=len(before['application']),
    scope='Controlled native audio API failure ownership; application-owned TCP; no production-ready claim.',
    current_qualified_source_hashes=qualified,runs=runs,mutations=mutations,checks=checks,
    transport_custody_status='FAILED: unadopted dependency revision' if mismatches else 'passed',
    transport_custody_mismatches=mismatches,sources_and_installed_assets=observations,
    changed_or_added_application_paths=changes,unadopted_dependency_observations=unadopted,
    evidence_files=[dict(path=str(p.relative_to(out)),sha256=sha(p),bytes=p.stat().st_size)
                    for p in sorted(out.rglob('*')) if p.is_file() and p.name!='receipt.json'],
    limits=[
        'Windows null devices and loopback sockets only; no physical audio or two-host run.',
        'Linux and Intel macOS 12/26 network compilation, not execution or native audio SDK closure.',
        'Controlled API/metadata failures are not exhaustive internal allocator/driver failures.',
        'Independent peer, socket fault injection, OS resource-leak measurement and atomic process inheritance remain open.',
        'No real credential policy/store, composed network/audio workers, sustained clock/recovery qualification or packaging.',
        'Initial mutation classifier required a nonexistent log phrase; raw runtime witnesses were independently reviewed and preserved.',
        'Inherited Perl locale diagnostics remain in otherwise successful compiler runs; final exit and summary identify outcomes.',
        'Pinned dependency records and stable public core unchanged; concurrent sibling additions are observations, not adoption.',
    ])
with (out/'receipt.json').open('x',encoding='utf-8') as f:
    json.dump(receipt,f,indent=2,ensure_ascii=False);f.write('\n')
print(json.dumps(dict(receipt=str(out/'receipt.json'),sha256=sha(out/'receipt.json'),changes=len(changes),transport_mismatches=len(mismatches))))
