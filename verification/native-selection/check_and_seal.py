"""Record a bounded host change without adopting sibling library work."""
import datetime
import hashlib
import json
import pathlib
import platform
import subprocess
import sys
import time

root = pathlib.Path(__file__).resolve().parents[2]
out = pathlib.Path(__file__).parent
sys.path.insert(0, str(root / 'tools'))
from build_reference import inventory


def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


prior = root / 'verification/lifecycle-send/receipt.json'
assert sha(prior) == '27e5f6749be3540bf7746a39f727ea393e38ce2bdc5f35b67ac394d9b0e8a33d'
baseline = json.loads(prior.read_text(encoding='utf-8'))
old = {str(pathlib.Path(row['path'])): row for row in baseline['sources_and_installed_assets']}
tests = json.loads((out / 'tests.json').read_text(encoding='utf-8'))
assert len(tests['runs']) == 2 and all(row['exit_code'] == 0 for row in tests['runs'])
for name in ['final-debug', 'final-safe']:
    assert '7/7 tests passed' in (out / (name + '.log')).read_text(encoding='utf-8')
for name, expected in tests['source_sha256'].items():
    assert sha(root / name) == expected, name
for name, expected in baseline['qualified_current_source_hashes'].items():
    if name not in tests['source_sha256']:
        assert sha(root / name) == expected, name
for row in baseline['sources_and_installed_assets']:
    path = pathlib.Path(row['path'])
    if 'miniaudio-zig' in path.parts and path.suffix in {'.zig', '.c', '.h', '.zon'}:
        assert sha(path) == row['sha256'], str(path)
for name in ['src/root.zig', 'build.zig.zon', 'docs/reference/miniaudio-zig.md', 'docs/reference/tls-zig.md', 'docs/reference/upstream-assets.md', 'docs/reference/evidence.md']:
    assert sha(root / name) == old[str(root / name)]['sha256'], name

# Preserve the executed checks, including the failed custody result. Do not
# overwrite it with a passing scoped status or refresh reviewed dependency pins.
checks = json.loads((out / 'checks.json').read_text(encoding='utf-8'))
assert [r['name'] for r in checks] == ['reference', 'docs', 'handoff', 'transport-custody']
assert all(r['exit_code'] == 0 for r in checks[:3])
assert checks[3]['exit_code'] != 0
lock = json.loads((root / 'transport-lock.json').read_text(encoding='utf-8'))
dependency = (root / lock['root']).resolve()
mismatches = []
for entry in lock['files']:
    path = (dependency / entry['path']).resolve()
    assert path.is_relative_to(dependency)
    observed = sha(path) if path.is_file() else None
    if observed != entry['sha256']:
        mismatches.append(dict(path=str(path), reviewed_sha256=entry['sha256'], observed_sha256=observed))
assert mismatches, 'Do not reinterpret the earlier failed check; review any new revision separately.'

observations, changes, unadopted = [], [], []
for project, relative, path in inventory():
    digest = sha(path)
    previous = old.get(str(path))
    reviewed = previous and previous.get('adoption') != 'unadopted_observation' and previous['sha256'] == digest
    adoption = 'application' if project == 'lan-audio' else 'reviewed_unchanged' if reviewed else 'unadopted_observation'
    row = dict(path=str(path), sha256=digest, bytes=path.stat().st_size, adoption=adoption)
    observations.append(row)
    if project == 'lan-audio' and (previous is None or previous['sha256'] != digest):
        changes.append(relative)
    if adoption == 'unadopted_observation':
        unadopted.append(row)

receipt = dict(
    phase='native-selection', observed_at_utc=datetime.datetime.now(datetime.timezone.utc).isoformat(),
    host=platform.platform(), zig=subprocess.check_output(['zig', 'version'], text=True).strip(),
    prior_receipt=dict(path=str(prior), sha256=sha(prior)),
    scope='C03 exact-name endpoint selection and actual callback/native format validation, silent backend only.',
    tests=tests, checks=checks, transport_custody_status='FAILED: separately owned revision not adopted',
    transport_custody_mismatches=mismatches, sources_and_installed_assets=observations,
    changed_or_added_application_paths=changes, unadopted_dependency_observations=unadopted,
    preserved_prior_core_controller_hashes={name: expected for name, expected in baseline['qualified_current_source_hashes'].items() if name not in tests['source_sha256']},
    evidence_files=[dict(path=str(p.relative_to(out)), sha256=sha(p), bytes=p.stat().st_size) for p in sorted(out.rglob('*')) if p.is_file() and p.name != 'receipt.json'],
    limits=['No production-ready platform.', 'No physical audio, foreign OS/mobile execution or packaging.', 'No native start/stop or format-rejection driver failure injection; endpoint identity/discovery, hotplug and async fences remain open.', 'Names are exact session selectors, not persistent identities.', 'Native dimension matching is not acoustic or OS-mixer bit identity.', 'Native miniaudio source, dependency pins and stable core export unchanged. TLS build source changed independently; transport custody is FAILED and TLS/QUIC work remains unadopted.'])
with (out / 'receipt.json').open('x', encoding='utf-8') as f:
    json.dump(receipt, f, indent=2, ensure_ascii=False)
    f.write('\n')
print(json.dumps(dict(receipt=str(out / 'receipt.json'), sha256=sha(out / 'receipt.json'), changes=len(changes))))
