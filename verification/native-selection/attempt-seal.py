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

checks = []
for name, command in [
    ('reference', ['python', 'tools/build_reference.py', '--application-only']),
    ('docs', ['python', 'tools/check_docs.py', '--application-only']),
    ('handoff', ['python', 'tools/check_handoff.py', '--application-only']),
    ('transport-custody', ['python', 'tools/check_transport.py']),
]:
    start = time.monotonic()
    with (out / (name + '.log')).open('w', encoding='utf-8') as log:
        run = subprocess.run(command, cwd=root, stdout=log, stderr=subprocess.STDOUT)
    checks.append(dict(name=name, command=command, exit_code=run.returncode, seconds=time.monotonic()-start))
    (out / 'checks.json').write_text(json.dumps(checks, indent=2)+'\n', encoding='utf-8')
    print(name, run.returncode, flush=True)
    assert run.returncode == 0, name

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
    tests=tests, checks=checks, sources_and_installed_assets=observations,
    changed_or_added_application_paths=changes, unadopted_dependency_observations=unadopted,
    preserved_prior_core_controller_hashes={name: expected for name, expected in baseline['qualified_current_source_hashes'].items() if name not in tests['source_sha256']},
    evidence_files=[dict(path=str(p.relative_to(out)), sha256=sha(p), bytes=p.stat().st_size) for p in sorted(out.rglob('*')) if p.is_file() and p.name != 'receipt.json'],
    limits=['No production-ready platform.', 'No physical audio, foreign OS/mobile execution or packaging.', 'No native start/stop or format-rejection driver failure injection; endpoint identity/discovery, hotplug and async fences remain open.', 'Names are exact session selectors, not persistent identities.', 'Native dimension matching is not acoustic or OS-mixer bit identity.', 'Dependency source/pins and stable core export unchanged; sibling unadopted observations remain unadopted.'])
with (out / 'receipt.json').open('x', encoding='utf-8') as f:
    json.dump(receipt, f, indent=2, ensure_ascii=False)
    f.write('\n')
print(json.dumps(dict(receipt=str(out / 'receipt.json'), sha256=sha(out / 'receipt.json'), changes=len(changes))))
