"""Seal observations; never modify dependency pins or historical receipts."""
import datetime, hashlib, json, pathlib, platform, subprocess, sys

root = pathlib.Path(__file__).resolve().parents[2]
phase = pathlib.Path(__file__).parent
sys.path.insert(0, str(root / 'tools'))
from build_reference import inventory

def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()

prior = root / 'verification/lifecycle-core/receipt.json'
baseline = json.loads(prior.read_text(encoding='utf-8'))
before = json.loads((phase / 'before.json').read_text(encoding='utf-8'))
assert digest(prior) == before['prior_receipt_sha256']
tests = json.loads((phase / 'final-tests.json').read_text())
mutations = json.loads((phase / 'mutations-2/results.json').read_text())
checks = json.loads((phase / 'sealed-checks.json').read_text())
assert all(r['exit_code'] == 0 for r in tests['runs'] + checks)
assert mutations['passed'] and len(mutations['results']) == 10
for path, expected in tests['source_sha256'].items():
    assert digest(root / path) == expected, path
assert digest(root / 'tests/integration/runtime_lifecycle.zig') == mutations['tests_sha256']
for module, expected in mutations['sources'].items():
    assert digest(root / ('src/runtime/' + module + '.zig')) == expected
old = {str(pathlib.Path(x['path'])): x for x in baseline['sources_and_installed_assets']}
observed, drift, changed_application = [], [], []
for project, relative, path in inventory():
    actual = digest(path)
    previous = old.get(str(path))
    status = 'application' if project == 'lan-audio' else 'reviewed_unchanged' if previous and previous['sha256'] == actual else 'unadopted_observation'
    row = dict(path=str(path), sha256=actual, bytes=path.stat().st_size, adoption=status)
    observed.append(row)
    if status == 'unadopted_observation':
        drift.append(dict(path=str(path), prior_sha256=previous['sha256'] if previous else None, observed_sha256=actual))
    if project == 'lan-audio' and (previous is None or actual != previous['sha256']):
        changed_application.append(relative)
for file in ['docs/reference/tls-zig.md', 'docs/reference/miniaudio-zig.md', 'docs/reference/upstream-assets.md', 'docs/reference/evidence.md', 'build.zig.zon', 'src/root.zig']:
    assert digest(root / file) == old[str(root / file)]['sha256'], file
evidence = [dict(path=str(p.relative_to(phase)), bytes=p.stat().st_size, sha256=digest(p)) for p in sorted(phase.rglob('*')) if p.is_file() and p.name != 'receipt.json']
receipt = dict(
    phase='lifecycle-receive', observed_at_utc=datetime.datetime.now(datetime.timezone.utc).isoformat(),
    host=platform.platform(), zig=subprocess.check_output(['zig','version'], text=True).strip(),
    scope='C02b pure receiver custody/fence/ACK/close with actual controller and fake owners; full C02/native product incomplete.',
    prior_receipt=dict(path=str(prior), sha256=digest(prior)),
    initial_verified_file_count=len(before['checked']),
    sources_and_installed_assets=observed,
    changed_or_added_application_paths=changed_application,
    tests=tests, mutations=mutations, scoped_checks=checks,
    full_inventory_checks=json.loads((phase/'final-checks.json').read_text()),
    unadopted_dependency_drift=drift,
    dependency_owner=dict(title='QUIC and TLS — Codex implementation', thread_id='01a0de3c-68e5-7fd3-baa0-5a3a7748cf76', work='T00 in progress; preparation owner reported no completed reviewed receipt'),
    evidence_files=evidence,
    limits=['No native executor, real socket/identity, physical capture/output or foreign execution.', 'Sender graceful outcomes and native start/fault/final snapshots remain open C02/C03 work.', 'One pending reservation retains unresolved work after timeout; no OS termination bound.', 'Receiver ACK copy is not remote attestation or acoustic completion.', 'Initial compile failure, mutation-harness timeout and full inventory failures remain recorded; only second mutation campaign is successful.', 'Unadopted sibling observations are not reviewed pins; full inventory coverage remains incomplete pending owner receipt.'])
target = phase / 'receipt.json'
with target.open('x', encoding='utf-8') as f:
    json.dump(receipt, f, indent=2, ensure_ascii=False); f.write('\n')
print(json.dumps(dict(receipt=str(target), application_changes=len(changed_application), observed_files=len(observed), unadopted_files=len(drift), receipt_sha256=digest(target))))
