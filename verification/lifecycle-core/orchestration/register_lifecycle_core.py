import json
from pathlib import Path
r=Path('C:/Projects/lan-audio');p=r/'tools/reference_contracts.json'
c=json.loads(p.read_text(encoding='utf-8'));fields=('purpose','contract','failure','verify','next')
def add(key,*values):
    assert len(values)==5
    c['lan-audio/'+key]=dict(zip(fields,values))
add('src/runtime/lifecycle.zig',
 'Application-private C02a single-owner acquisition, abort and reclamation controller with no I/O or allocation.',
 'Three ordered executor-owned resources; one issued effect/result reservation; exact generation/serial/executor/kind/resource identity; late success and partial ownership create cleanup debt; worker join and device fence precede release.',
 'Rejected tokens/results and counter exhaustion are atomic. Cancel/deadline never erase pending work. Definitive cleanup failure blocks until explicit retry; uncertain work remains pending. Adapter truthfulness and stable handle slots are required.',
 'Run lifecycle-test in Debug/ReleaseSafe against independent fake acquisition/release/callback/worker ledgers; replay pending-parent trace and six isolated implementation guard mutations. Foreign-target lifecycle-check is compile-only.',
 'Compose graceful PendingBlock/queue/END/ACK outcomes for full C02; qualify C03 native fence/join mappings and explicit socket/TLS owners before deploying this controller.')
add('tests/integration/runtime_lifecycle.zig',
 'Deterministic fake-executor caller of the actual C02a production controller, with independent host ownership and borrow facts.',
 'Validates effect authority before completion; counts real fake acquisitions/releases separately from controller bits; pauses callback return; exercises all acquisition prefixes, late results, partial ownership, five cleanup failures/retries, token fields and counter bounds.',
 'Never complete a native fence while the fake callback is active; test that timeout preserves pending debt. No OS handles, audio output, media success ACK or hardware qualification is implied.',
 'Eleven named tests execute through lifecycle-test and default test. Mutation campaign must fail named executed tests, not merely fail compilation. Record host/compiler/optimization and exact source hashes.',
 'Extend this same harness for graceful media/tail/outcome composition and new concrete resource owners; add independent native adapter tests only when mappings exist.')
add('docs/runtime/lifecycle-core.md',
 'Literate explanation of implemented C02a methods, resource representation, error atomicity, adapter premises, inductive argument and cleanup rank.',
 'Separates actual three-resource/global-slot controller from proposed full lifecycle API; states generation identity, late cleanup debt, qualified partial acquisition, deadline semantics and fake/native evidence limits.',
 'No guarantee of wall-clock completion, truthful foreign adapters, crash exactly-once, acoustic output or complete C02. Keep native unknown-handle/partial-object recovery in explicit adapter custody.',
 'Cross-check actual Zig source and independent test caller; read lifecycle-core phase results and receipt for positive/mutation/compile-only evidence.',
 'Complete graceful media outcome/refinement mappings and native adapter qualification; update mathematical premises when adding resource types or executor concurrency.')
for key in ['docs/design/lifecycle-transactions.md','docs/implementation/takeover-readiness.md']:
    row=c['lan-audio/'+key]
    row['contract']+=' C02a acquisition/abort/reclaim is now implemented; its exact narrower API and evidence are in docs/runtime/lifecycle-core.md.'
    row['verify']='Read actual C02a source and independent fake-owner tests, the unchanged earlier finite model and lifecycle-core source-scoped receipt. Preserve full-C02/native/graceful gaps.'
    row['next']='Extend the existing controller with graceful media custody/outcome composition, then qualify native C03 mappings; do not restart preparation or declare all C02 complete.'
row=c['lan-audio/build.zig']
row['contract']+=' Private lifecycle module and lifecycle-test/lifecycle-check steps compile actual controller/fake owners; default test includes lifecycle execution, and check includes its compile. Requested lifecycle runs always execute.'
row['verify']='Run core/lifecycle/dependency/silent-device tests with recorded cache/execution status and compiler; cross-target lifecycle-check compiles only. Explicit capture-test remains the sole physical capture step.'
row=c['lan-audio/tools/build_reference.py']
row['contract']+=' Lifecycle-core receipt is excluded from its own generated evidence listing to avoid a self-hash cycle; all source contracts remain explicit.'
p.write_text(json.dumps(c,indent=2,ensure_ascii=False)+'\n',encoding='utf-8')
renderer=r/'tools/build_reference.py';s=renderer.read_text(encoding='utf-8')
old="ROOT/'verification/lifecycle-preparation/receipt.json'}"
assert s.count(old)==1
s=s.replace(old,"ROOT/'verification/lifecycle-preparation/receipt.json', ROOT/'verification/lifecycle-core/receipt.json'}")
old='and the takeover-readiness audit. `.zig-cache/`'
assert s.count(old)==1
s=s.replace(old,'and the takeover-readiness audit; `verification/lifecycle-core/receipt.json` seals implemented acquisition/abort/reclaim, real-controller fake owners, deliberate implementation mutations and the reviewed source-package dependency adoption. `.zig-cache/`')
renderer.write_text(s,encoding='utf-8')
print('Registered actual lifecycle controller, independent caller and mathematical explanation; updated adoption/status/build contracts.')
