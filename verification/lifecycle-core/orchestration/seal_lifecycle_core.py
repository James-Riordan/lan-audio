import hashlib,json,platform,shutil,subprocess
from datetime import datetime,timezone
from pathlib import Path
r=Path('C:/Projects/lan-audio');p=r/'verification/lifecycle-core'
def read(path):return json.loads(path.read_text(encoding='utf-8'))
def obs(path):return {'path':str(path),'sha256':hashlib.sha256(path.read_bytes()).hexdigest(),'bytes':path.stat().st_size}
def verify(row):
    assert obs(Path(row['path']))['sha256']==row['sha256'],row['path']
    return row
assert not (p/'receipt.json').exists()
prior_path=r/'verification/lifecycle-preparation/receipt.json';prior=read(prior_path)
for row in prior['evidence_files']:verify(row)
before=read(p/'before.json');assert len(before)==113
stable=[]
for row in before:
    verify({'path':str(p/'before'/row['path']),'sha256':row['sha256']})
    if row['path'].startswith(('src/','tests/','spec/')) or row['path'] in {'build.zig.zon','transport-lock.json'}:
        stable.append(verify({'path':str(r/row['path']),'sha256':row['sha256']}))
integration=read(p/'dependency-integration.json');tls=read(p/'tls-r5-integration.json')
for row in integration['evidence_files']+tls['evidence_files']:verify(row)
mutations=read(p/'mutations-2/reviewed-results.json')
assert mutations['passed'] and len(mutations['results'])==6 and all(x['detected'] for x in mutations['results'])
assert obs(r/'src/runtime/lifecycle.zig')['sha256']==mutations['production_sha256']
assert obs(r/'tests/integration/runtime_lifecycle.zig')['sha256']==mutations['tests_sha256']
for row in mutations['results']:
    assert obs(p/'mutations-2'/(row['mutation']+'.log'))['sha256']==row['log_sha256']
    assert obs(p/'mutations-2'/(row['mutation']+'.zig'))['sha256']==row['source_sha256']
names=['format','debug-1','release-safe','mac-compile','linux-compile','regression','docs','handoff','transport','miniaudio-docs','miniaudio-vendor','tls-docs','tls-plan']
checks=[]
for name in names:
    row=read(p/(name+'.json'));assert row['exit_code']==0,name
    assert obs(p/row['log'])['sha256']==row['log_sha256'];checks.append(row)
assert '11/11 tests passed' in (p/'debug-1.log').read_text(encoding='utf-8')
assert '11/11 tests passed' in (p/'release-safe.log').read_text(encoding='utf-8')
assert '55/55 tests passed' in (p/'regression.log').read_text(encoding='utf-8')
assert 'cached' not in (p/'regression.log').read_text(encoding='utf-8').lower()
version=subprocess.check_output(['zig','version'],text=True).strip()
assert version=='0.17.0-dev.1859+dcceb318e'
# Retain orchestration sources with the phase; they are not product dependencies.
scripts=p/'orchestration';scripts.mkdir(exist_ok=False)
for name in ['run_lifecycle_core.py','integrate_lifecycle_dependency.py','register_lifecycle_core.py','mutate_lifecycle_core.py','classify_lifecycle_mutations.py','integrate_tls_r5.py','seal_lifecycle_core.py']:
    shutil.copy2(Path.cwd()/'work'/name,scripts/name)
# Enumerate evidence only after its last additions; the receipt is explicitly
# excluded by the renderer to avoid source/evidence self-hash recursion.
render=subprocess.run(['python','tools/build_reference.py'],cwd=r,capture_output=True,text=True,encoding='utf-8',timeout=120)
assert render.returncode==0,render.stdout+render.stderr
index=read(r/'docs/reference/file-index.json')['entries']
sources=[obs(r.parent/x['project']/x['path']) for x in index]
assert len(sources)==563
old={row['path']:row for row in prior['sources_and_installed_assets']}
evidence=[obs(path) for path in sorted(p.rglob('*')) if path.is_file()]
receipt={'phase':'lifecycle-core','observed_at_utc':datetime.now(timezone.utc).isoformat(),'host':platform.platform(),'zig':version,
 'scope':'Implementation begins in the existing Codex-backed chat: C02a acquisition/abort/reclaim, independent fake owners, mathematical contracts and reviewed miniaudio packaging/TLS r5 reference integration. Full C02 and native product remain open.',
 'prior_receipt':obs(prior_path),'sources_and_installed_assets':sources,'evidence_files':evidence,
 'before_application_file_count':len(before),'unchanged_preexisting_application_runtime_tests_models_package_pins':stable,
 'changed_paths':[x['path'] for x in sources if x['path'] in old and x['sha256']!=old[x['path']]['sha256']],
 'added_paths':[x['path'] for x in sources if x['path'] not in old],
 'commands':checks,'final_reference_render':{'command':['python','tools/build_reference.py'],'exit_code':render.returncode,'output':render.stdout+render.stderr},
 'controller_tests':{'Debug':11,'ReleaseSafe':11,'concrete_mutations_detected':6,'fresh_cache_regression':55,'regression_breakdown':{'existing_core':42,'lifecycle':11,'dependency_consumer':1,'silent_device':1}},
 'compile_only':['x86_64-macos','aarch64-linux'],'historical_evidence_verified':True,
 'dependency_integration':integration,'tls_r5_integration':tls,
 'reference_counts':{'total':len(index),'authored_support':sum(x['kind']=='authored-or-support' for x in index),'installed_sdk':sum(x['kind']=='upstream-sdk' for x in index)},
 'limits':['C02a has one global outstanding effect and three aggregate resources; graceful media/END/ACK/outcome composition remains open.',
 'Tests assume truthful fake executor results; C03 real native fence/join mapping is unqualified.',
 'Timeout preserves live debt; no all-schedule liveness, real-time bound or formal implementation-refinement theorem.',
 'Provider/packaging owner results and unchanged Python/TLA model evidence are historical, not new application executions.',
 'Initial Zig test syntax error, mutation-classifier defects and missing TLS reference contract were corrected with original evidence retained.',
 'Perl locale warnings persisted during otherwise successful silent native regression.',
 'Mac unavailable, Monterey unconfirmed; no foreign execution, physical output, two-host or production-ready claim.']}
for row in sources+evidence:verify(row)
for row in prior['evidence_files']:verify(row)
with (p/'receipt.json').open('x',encoding='utf-8') as f:json.dump(receipt,f,indent=2);f.write('\n')
print('SEALED: C02a; 11 Debug + 11 ReleaseSafe; six executed mutation witnesses; 55-test fresh regression; two compile-only foreign targets; 563 indexed files.')
