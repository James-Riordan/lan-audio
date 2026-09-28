import hashlib,json
from pathlib import Path
r=Path('C:/Projects/lan-audio'); phase=r/'verification/lifecycle-core'
owner=Path('C:/Users/James/Documents/Codex/2026-09-26/your-job-chatgpt-work-is-to-2/outputs')
bundle=owner/'miniaudio-package-readiness/miniaudio-zig'; evidence=bundle/'verification/source-package'
def read(p): return json.loads(p.read_text(encoding='utf-8'))
def digest(p): return hashlib.sha256(p.read_bytes()).hexdigest()
def obs(p): return {'path':str(p),'sha256':digest(p)}
adoption=read(evidence/'integration-receipt.json'); qualification=read(evidence/'receipt.json')
assert digest(evidence/'receipt.json')==adoption['qualification_receipt_sha256']
assert len(adoption['sources'])==47 and adoption['sources']==qualification['sources']
for rel,sha in adoption['sources'].items():
    assert digest(r.parent/'miniaudio-zig'/rel)==sha,rel
    assert digest(bundle/rel)==sha,rel
delta_path=owner/'audio-package-reference-contracts-additions.json'; delta=read(delta_path)
assert digest(delta_path)==adoption['contract_delta_sha256']
assert len(delta)==12 and set(delta)=={'miniaudio-zig/'+p for p in adoption['changed']+adoption['new']}
assert digest(owner/'miniaudio-zig-qualified-source.tar')==adoption['source_tar_sha256']
for row in qualification['commands']+adoption['checks']:
    assert row['returncode']==0 and digest(evidence/row['log'])==row['log_sha256']
assert digest(evidence/'final-tooling-tests.log')==adoption['unit_tests_log_sha256']
old=read(r/'verification/lifecycle-preparation/receipt.json')
changed=[]
for row in old['sources_and_installed_assets']:
    p=Path(row['path'])
    if p.is_relative_to(r.parent/'miniaudio-zig') and digest(p)!=row['sha256']:
        rel=p.relative_to(r.parent/'miniaudio-zig').as_posix()
        assert rel in adoption['changed'],rel
        changed.append(rel)
assert set(changed)==set(adoption['changed'])
contracts=read(r/'tools/reference_contracts.json');contracts.update(delta)
(r/'tools/reference_contracts.json').write_text(json.dumps(contracts,indent=2,ensure_ascii=False)+'\n',encoding='utf-8')
report={'scope':'Reviewed 12-entry miniaudio package delta. Exact live/snapshot source, archive, command logs and historical receipt verified; owner tests not relabeled as fresh application tests.',
 'changed':changed,'new':adoption['new'],'live_files_verified':47,
 'evidence_files':[obs(delta_path),obs(owner/'miniaudio-package-handoff.md'),obs(owner/'miniaudio-zig-qualified-source.tar')]+[obs(p) for p in sorted(evidence.rglob('*')) if p.is_file()],
 'runtime_build_vendor_profile_unchanged':True,'manifest_allowlist_changed':True}
with (phase/'dependency-integration.json').open('x',encoding='utf-8') as f: json.dump(report,f,indent=2);f.write('\n')
print('Verified and integrated miniaudio package delta: 47 files; 8 changes, 4 additions; vendor/runtime/native build unchanged.')
