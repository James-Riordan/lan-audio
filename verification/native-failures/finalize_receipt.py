"""Finalize only a seal whose redirected stdout changed after its own hash scan.

Run with stdout returned to the terminal, never redirected inside this directory.
Preserve the first receipt; do not change source, qualification results or pins.
"""
from pathlib import Path
import datetime
import hashlib
import json

out=Path(__file__).resolve().parent
root=out.parents[1]
def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()

receipt=out/'receipt.json'
data=json.loads(receipt.read_text(encoding='utf-8'))
for path,expected in data['current_qualified_source_hashes'].items():
    assert sha(root/path)==expected,path
for row in data['sources_and_installed_assets']:
    if row['adoption']=='application': assert sha(Path(row['path']))==row['sha256'],row['path']
mismatches=[row['path'] for row in data['evidence_files'] if sha(out/row['path'])!=row['sha256']]
assert mismatches==['seal-run.log'],mismatches
original_sha=sha(receipt)
archive=out/'receipt-attempt-1.json'
assert receipt.resolve().is_relative_to(out) and archive.resolve().is_relative_to(out)
assert not archive.exists()
receipt.rename(archive)
data['seal_correction']=dict(
    at_utc=datetime.datetime.now(datetime.timezone.utc).isoformat(),
    original_receipt='receipt-attempt-1.json',original_sha256=original_sha,
    cause='The initial seal included redirected stdout while still running; its final status line changed seal-run.log after hashing. Qualification and source files are unchanged.',
    reviewed_changed_evidence=mismatches,
)
data['evidence_files']=[dict(path=str(p.relative_to(out)),sha256=sha(p),bytes=p.stat().st_size)
                       for p in sorted(out.rglob('*')) if p.is_file() and p!=receipt]
with receipt.open('x',encoding='utf-8') as f:
    json.dump(data,f,indent=2,ensure_ascii=False);f.write('\n')
assert all(sha(out/row['path'])==row['sha256'] for row in data['evidence_files'])
print(json.dumps(dict(receipt=str(receipt),sha256=sha(receipt),evidence_files_verified=len(data['evidence_files']),source_files_verified=sum(row['adoption']=='application' for row in data['sources_and_installed_assets']))))
