"""Seal scoped application evidence while retaining failed dependency gates."""
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


def read(path):
    return json.loads(path.read_text(encoding='utf-8'))


before = read(out / 'before.json')
prior = root / 'verification/native-selection/receipt.json'
assert sha(prior) == before['prior_receipt_sha256']
baseline = read(prior)
old = {str(pathlib.Path(row['path'])): row for row in baseline['sources_and_installed_assets']}
events = read(out / 'attempt-1/tests.json')
receiver = read(out / 'receiver-final/tests.json')
native_mutations = read(out / 'mutations/results.json')
receiver_mutations = read(out / 'receiver-mutations/reviewed-results.json')
assert len(events['runs']) == 3 and len(receiver['runs']) == 4
assert all(row['exit_code'] == 0 for row in events['runs'] + receiver['runs'])
assert native_mutations['passed'] and len(native_mutations['results']) == 4
assert receiver_mutations['passed'] and len(receiver_mutations['results']) == 2
assert '87/87 tests passed' in (out / 'attempt-1/debug.log').read_text(encoding='utf-8')
assert '10/10 tests passed' in (out / 'attempt-1/native-safe.log').read_text(encoding='utf-8')
for name in ['debug', 'safe']:
    assert '36/36 tests passed' in (out / ('receiver-final/' + name + '.log')).read_text(encoding='utf-8')
assert '-target x86_64-macos.12.0' in (out / 'receiver-final/monterey.log').read_text(encoding='utf-8')
assert '-target x86_64-macos.26.0' in (out / 'receiver-final/macos-26.log').read_text(encoding='utf-8')
qualified = dict(events['source_sha256'])
qualified.update(receiver['source_sha256'])
for name, expected in qualified.items():
    assert sha(root / name) == expected, name
for directory, results in [('mutations', native_mutations), ('receiver-mutations', receiver_mutations)]:
    for row in results['results']:
        assert row['detected'] and row['exit_code'] != 0 and row['witness']
        assert sha(out / directory / (row['name'] + '.log')) == row['log_sha256']
for row in baseline['sources_and_installed_assets']:
    path = pathlib.Path(row['path'])
    if 'miniaudio-zig' in path.parts and path.suffix in {'.zig', '.c', '.h', '.zon'}:
        assert sha(path) == row['sha256'], str(path)
for name in ['src/root.zig', 'build.zig.zon', 'transport-lock.json', 'src/runtime/lifecycle.zig', 'src/runtime/send_drain.zig', 'docs/reference/miniaudio-zig.md', 'docs/reference/tls-zig.md', 'docs/reference/upstream-assets.md', 'docs/reference/evidence.md']:
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
    if name != 'transport-custody':
        assert run.returncode == 0, name

lock = read(root / 'transport-lock.json')
dependency = (root / lock['root']).resolve()
mismatches = []
for entry in lock['files']:
    path = (dependency / entry['path']).resolve()
    assert path.is_relative_to(dependency)
    observed = sha(path) if path.is_file() else None
    if observed != entry['sha256']:
        mismatches.append(dict(path=str(path), reviewed_sha256=entry['sha256'], observed_sha256=observed))
assert (checks[-1]['exit_code'] == 0) == (len(mismatches) == 0)

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
    phase='native-events', observed_at_utc=datetime.datetime.now(datetime.timezone.utc).isoformat(),
    host=platform.platform(), zig=subprocess.check_output(['zig', 'version'], text=True).strip(),
    prior_receipt=dict(path=str(prior), sha256=sha(prior)), initial_application_files_verified=len(before['application']),
    scope='Native event and missing-output failure publication, receiver fault/ACK custody, Monterey default target. No production-ready claim.',
    native_event_tests=events, superseding_receiver_tests=receiver,
    native_mutations=native_mutations, receiver_mutations=receiver_mutations,
    current_qualified_source_hashes=qualified,
    checks=checks, transport_custody_status='FAILED: unadopted dependency revision' if mismatches else 'passed',
    transport_custody_mismatches=mismatches, sources_and_installed_assets=observations,
    changed_or_added_application_paths=changes, unadopted_dependency_observations=unadopted,
    evidence_files=[dict(path=str(p.relative_to(out)), sha256=sha(p), bytes=p.stat().st_size) for p in sorted(out.rglob('*')) if p.is_file() and p.name != 'receipt.json'],
    limits=['No physical audio, native Mac/foreign execution, production network workers or packaging.',
            'Monterey floor and explicit macOS 26 compile are core/controller checks, not native SDK/runtime closure or installation.',
            'Native start/stop failure injection, event coverage, endpoint identity/discovery and CoreAudio fences remain open.',
            'Data fences do not join all notification producers; native storage remains owned until uninit.',
            'Fault flags do not atomically prevent a concurrently submitted write or retract an ACK already copied.',
            'Initial receiver mutation parser produced false negatives; original logs/classification preserved and corrected from executed witnesses.',
            'Native source, dependency pins and stable core export unchanged; independently owned TLS changes remain unadopted.'])
with (out / 'receipt.json').open('x', encoding='utf-8') as f:
    json.dump(receipt, f, indent=2, ensure_ascii=False)
    f.write('\n')
print(json.dumps(dict(receipt=str(out / 'receipt.json'), sha256=sha(out / 'receipt.json'), changes=len(changes), transport_mismatches=len(mismatches))))
