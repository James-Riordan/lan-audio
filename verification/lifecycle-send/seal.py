"""Record current source scope without adopting unrelated dependency work."""
import datetime, hashlib, json, pathlib, platform, subprocess, sys

root = pathlib.Path(__file__).resolve().parents[2]
out = pathlib.Path(__file__).parent
sys.path.insert(0, str(root / 'tools'))
from build_reference import inventory

def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()

def read(name):
    return json.loads((out / name).read_text(encoding='utf-8'))

prior = root / 'verification/lifecycle-receive/receipt.json'
before = read('before.json')
assert sha(prior) == before['prior_receipt_sha256']
baseline = json.loads(prior.read_text(encoding='utf-8'))
old = {str(pathlib.Path(x['path'])): x for x in baseline['sources_and_installed_assets']}
tests, native, mutants, checks = read('final-tests.json'), read('native-final.json'), read('mutations/results.json'), read('checks.json')
assert all(r['exit_code'] == 0 for r in tests['runs'] + native['runs'])
assert all(r['exit_code'] == 0 for r in checks if not r['name'].startswith('full-'))
assert mutants['passed'] and len(mutants['results']) == 14
qualified = dict(tests['source_sha256'])
qualified.update(native['source_sha256']) # Explicit newer host/native-test revision.
for file, expected in qualified.items():
    assert sha(root / file) == expected, file
assert sha(root / 'tests/integration/runtime_lifecycle.zig') == mutants['tests_sha256']
for module, expected in mutants['sources'].items():
    assert sha(root / ('src/runtime/' + module + '.zig')) == expected, module
for x in baseline['sources_and_installed_assets']:
    path = pathlib.Path(x['path'])
    if 'miniaudio-zig' in path.parts and (path.suffix in {'.zig', '.c', '.h', '.zon'}):
        assert sha(path) == x['sha256'], str(path)
for file in ['build.zig.zon', 'src/root.zig', 'docs/reference/miniaudio-zig.md', 'docs/reference/tls-zig.md', 'docs/reference/upstream-assets.md', 'docs/reference/evidence.md']:
    assert sha(root/file) == old[str(root/file)]['sha256'], file

observations, changes, unadopted = [], [], []
for project, relative, path in inventory():
    digest = sha(path)
    previous = old.get(str(path))
    reviewed = previous and previous.get('adoption') != 'unadopted_observation' and previous['sha256'] == digest
    adoption = 'application' if project == 'lan-audio' else 'reviewed_unchanged' if reviewed else 'unadopted_observation'
    row = dict(path=str(path), sha256=digest, bytes=path.stat().st_size, adoption=adoption)
    observations.append(row)
    if project == 'lan-audio' and (previous is None or previous['sha256'] != digest): changes.append(relative)
    if adoption == 'unadopted_observation': unadopted.append(row)
receipt = dict(
    phase='lifecycle-send', observed_at_utc=datetime.datetime.now(datetime.timezone.utc).isoformat(),
    host=platform.platform(), zig=subprocess.check_output(['zig','version'],text=True).strip(),
    scope='C02c sender/receiver custody plus C03 callback faults and synchronous native fence/snapshot subset. Not production-ready on any OS.',
    prior_receipt=dict(path=str(prior), sha256=sha(prior)), initial_application_files_verified=len(before['application']),
    sources_and_installed_assets=observations, changed_or_added_application_paths=changes,
    qualified_current_source_hashes=qualified, core_controller_tests=tests, superseding_native_tests=native, implementation_mutations=mutants,
    checks=checks, unadopted_dependency_observations=unadopted,
    native_source_mapping=dict(path=str(root.parent/'miniaudio-zig/vendor/miniaudio/miniaudio.h'), sha256=sha(root.parent/'miniaudio-zig/vendor/miniaudio/miniaudio.h'), scope='Synchronous data-loop return/stopped/stopEvent ordering; null execution, no physical WASAPI or async-backend qualification.'),
    evidence_files=[dict(path=str(p.relative_to(out)), bytes=p.stat().st_size, sha256=sha(p)) for p in sorted(out.rglob('*')) if p.is_file() and p.name != 'receipt.json'],
    limits=['All-OS scope includes mobile, but no production platform is qualified.', 'No new physical audio, foreign execution, real socket/identity worker or sustained network/drift qualification.', 'Native fence excludes mac_playback and asynchronous shapes; partial-failure/notification/endpoint adapters remain open.', 'Native-final source supersedes earlier host observation; previous logs and receipts are unchanged.', 'Unadopted TLS work remains separately owned, even when its bytes match an earlier unadopted observation.', 'No dependency pins, vendor source or stable public core import changed.'])
target=out/'receipt.json'
with target.open('x',encoding='utf-8') as f:
    json.dump(receipt,f,indent=2,ensure_ascii=False);f.write('\n')
print(json.dumps(dict(receipt=str(target), application_changes=len(changes), observed_files=len(observations), unadopted_files=len(unadopted), sha256=sha(target))))
