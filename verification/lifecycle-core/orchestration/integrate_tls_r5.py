import hashlib,json
from pathlib import Path
r=Path('C:/Projects/lan-audio');tls=r.parent/'tls-zig';phase=r/'verification/lifecycle-core'
def read(p):return json.loads(p.read_text(encoding='utf-8'))
def obs(p):return {'path':str(p),'sha256':hashlib.sha256(p.read_bytes()).hexdigest()}
audit=read(tls/'docs/verification/r5-change-audit.json');prior=read(r/'verification/lifecycle-preparation/receipt.json')
assert audit['status']=='applied-and-verified' and not audit['deleted_paths'] and not audit['application_pins_modified'] and not audit['preexisting_source_modified']
old={Path(x['path']).relative_to(tls).as_posix():x['sha256'] for x in prior['sources_and_installed_assets'] if Path(x['path']).is_relative_to(tls)}
changes={row['path']:row for row in audit['changes']}
for rel,sha in old.items():
    if rel in changes:assert changes[rel]['before_sha256']==sha,rel
    else:assert obs(tls/rel)['sha256']==sha,rel
for rel,row in changes.items():assert obs(tls/rel)['sha256']==row['after_sha256'],rel
c=read(r/'tools/reference_contracts.json'); fields=('purpose','contract','failure','verify','next')
def add(rel,purpose,contract,failure,verify,next):c['tls-zig/'+rel]=dict(zip(fields,(purpose,contract,failure,verify,next)))
special={
 'docs/contracts/provider-leases.md':('Provider input lease transaction and work-budget contract.','Held input survives rejected release through provider destruction; logical retirement differs from callback invocation. Byte/call/event budgets do not establish wall-clock bounds.'),
 'tools/probe-quic-pair.c':('Offline two-object authenticated recordless provider diagnostic, isolated from the production library.','Seventeen bounded cases with independent expected role/identity/ALPN/secret-direction/lease outcomes; fixed stable arrays, fixture credentials/time and teardown-retained callback context; no sockets or QUIC packets.'),
 'tools/probe-quic-pair.py':('Exact-SDK compiler and seventeen-case execution runner for the C provider diagnostic.','Windows only, pinned compiler and exact 166-file SDK; fresh scratch, copied/hashed DLLs, O0/O2 modes, bounded subprocesses, raw case logs and source-bound results; no automatic lock refresh.'),
 'docs/verification/quic-provider-pair.md':('Scope and findings of owner revision-5 authenticated provider experiments.','Records release-after-failure cleanup, callback fanout, input-budget pauses and post-handshake processing; 17 cases at O0/O2 remain diagnostic evidence, not production T01-T06 completion.'),
 'docs/verification/baseline-r4.md':('Preserved revision-4 verification narrative.','Historical observations retain original scope; later source/pin/evidence status belongs to the later revision.'),
 'docs/verification/r5-check-results.json':('Owner revision-5 documentation/model/SDK/delivery check observations.','Binds recorded commands/results and source scope; review raw failures and audit before treating an earlier check as current evidence.'),
 'docs/verification/r5-change-audit.json':('Owner revision-4-to-5 before/after custody audit.','Lists additions and modifications with hashes and its explicit self exclusion; existing runtime sources and application pins preserved.'),
}
for suffix in ['c','py']:
    special[f'docs/reference/files/tools/probe-quic-pair.{suffix}.md']=(f'Declaration-by-declaration contract for the provider diagnostic {suffix} source.','Names the exact source hash, inputs, mutation/failure boundaries, fixed storage/fixtures, native teardown and bounded execution limits; source declarations remain canonical.')
new=[rel for rel,row in changes.items() if row['before_sha256'] is None]+['docs/verification/r5-change-audit.json']
for rel in new:
    if rel in special: purpose,contract=special[rel]
    elif rel.startswith('docs/verification/provider-pair/'):
        name=Path(rel).name;mode=Path(rel).parent.name
        purpose=f'Preserved provider-pair {mode}/{name} observation.'
        contract=('Exploratory failing attempt; never counted as successful qualification. '+name if 'exploratory' in name else f'Exact {mode}/{name} diagnostic output or aggregate receipt; interpret with quic-provider-pair.md and its recorded source/compiler/SDK/case oracle.')
    else:raise RuntimeError('Unreviewed added role: '+rel)
    add(rel,purpose,contract,'Do not promote fixture/static-array behavior to production API, cryptographic policy, heap bound or two-host acceptance. Keep existing failed attempts and historical bytes.',
        'Verify revision-5 audit and owner source/artifact inventory; inspect source-specific provider-pair receipt/logs. Application integration checks custody/navigation and does not rerun the native diagnostic.',
        'Use this evidence for T02/T04/T06 and native lease/work-budget refinement; implement real callers and their missing acceptance before any application transport adoption.')
for rel in changes:
    key='tls-zig/'+rel
    if rel not in new and ('recordless' in rel or rel.startswith('docs/roadmap/')):
        c[key]['contract']+=' Revision 5 additionally requires failed-release lease retention, deferred local-input wakeup, post-handshake custody and measured provider callback/work limits.'
(r/'tools/reference_contracts.json').write_text(json.dumps(c,indent=2,ensure_ascii=False)+'\n',encoding='utf-8')
report={'scope':'Reviewed TLS r5 documentation and isolated provider diagnostics; all pre-existing non-documentation source/SDK/locks preserved; no LAN Audio transport replacement.',
 'added_contracts':new,'changed_paths':list(changes),'evidence_files':[obs(tls/rel) for rel in changes]+[obs(tls/'docs/verification/r5-change-audit.json')],
 'previous_sources_checked':len(old),'application_pins_modified':False}
with (phase/'tls-r5-integration.json').open('x',encoding='utf-8') as f:json.dump(report,f,indent=2);f.write('\n')
print(f'Reconciled TLS r5: {len(new)} added file contracts; existing runtime/SDK/pins unchanged.')
