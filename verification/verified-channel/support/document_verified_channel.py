from pathlib import Path
import json
root=Path('C:/Projects/lan-audio')
for rel in ['docs/implementation/START_HERE.md','docs/implementation/completion-sequence.md']:
    p=root/rel
    text=p.read_text()
    old='Next: verified TLS peer export, stable endpoint IDs, asynchronous fences, native\nApple receivers and real streaming-worker integration.'
    new='The [verified native channel](../runtime/verified-channel.md) now joins the real TCP\nowner, reviewed TLS peer export, authorization and v2 records. Next: live audio\nworkers, credential storage, stable endpoint IDs, asynchronous fences and native\nApple receivers.'
    if old not in text: raise RuntimeError(rel)
    p.write_text(text.replace(old,new))

updates={
 'README.md':'\nThe [verified channel](docs/runtime/verified-channel.md) now composes native TCP,\nreviewed TLS identity export and v2 authorization/records, tested against an\nindependent peer. It is a worker component; the foreground command still supports\ninspection only. Live audio workers and native MacBook/iPhone applications remain open.\n',
 'docs/reference/api-contracts.md':'\n## Verified native connection\n\n[Verified channel contracts](../runtime/verified-channel.md) specify the actual\nSocket/Driver/peer-policy composition. The reviewed records Engine now exports\n`verifiedPeerLeafSha256()` as copied leaf-DER identity with a separate error set.\nThe application binds that identity to a current connection generation and clears\npermission on current errors. It never derives production Evidence from fixture\nfiles. Native audio-worker publication remains outside this component.\n',
 'docs/verification/acceptance-matrix.md':'\nThe [verified-channel increment](../../verification/verified-channel/RESULTS.md)\nadds real native Socket/TLS/authorization/v2 evidence for A2/A4/A7, with independent\npeers in both TLS and media roles. Credential enrollment/storage, live audio workers,\nApple execution and release gates remain open; this does not close A1/A2.\n',
 'docs/implementation/layout.md':'\n`src/host/verified_channel.zig` now owns the serialized TLS/v2 worker connection\non a borrowed native Socket. Its actual callers are the Zig integration probe and\nindependent Python peer under `tests/integration/verified_channel*`. It is private\nto this application and does not change the stable core export.\n',
 'docs/implementation/runtime-blueprint.md':'\nThe [verified native channel](../runtime/verified-channel.md) implements the\nreal Socket/TLS/peer-policy/record boundary. It does not yet drive SendDrain or\nReceiveDrain: the future worker must connect copied custody, current controller\ngeneration/revision, native fault publication and callback fences without applying\nrecords twice. Its synchronous test sink is not a native drain attestation.\n',
 'docs/literate/proof-ledger.md':'\nThe [verified-channel evidence](../../verification/verified-channel/RESULTS.md)\nadds a real native Socket and TLS identity mapping to P03/P09/P12: exact-record\nadmission, current-error permission/TLS cleanup, repeat/stale controls and independent\npeer checks. It does not close P08/P14 native worker/refinement or P10/P11 sustained\ntiming obligations. Both audio directions are synthetic and physical devices are unopened.\n',
 'docs/DEPENDENCIES.md':'\n## Records identity adoption (2026-09-26)\n\nThe application deliberately updates five TLS custody entries for the reviewed\nleaf-DER identity export and build graph; 183 other entries retain their previous\nhashes. Review authority and copied owner receipt are recorded in\n`verification/verified-channel/dependency-adoption.json`. Only the records `tls`\nmodule is imported; no QUIC module becomes an application dependency. The Windows\nSDK/Driver/fixtures are unchanged. Apple TLS build/runtime qualification stays open.\n',
}
for rel,addition in updates.items():
    p=root/rel
    p.write_text(p.read_text()+addition)

contracts_path=root/'tools/reference_contracts.json'
c=json.loads(contracts_path.read_text())
c['lan-audio/src/host/verified_channel.zig']={
 'purpose':'Serialized real Socket/TLS/verified-identity/v2 host connection used by the independent peer probe.',
 'contract':'Own Driver, borrow connected Socket and flag at stable addresses; explicit credentials/time/name/selected fingerprint; exact ALPN; live Engine digest only; copied send custody and bounded borrowed receive records.',
 'failure':'Current policy/protocol/TLS/transport/deadline failure releases TLS and permission; stale generation preserves replacement. Socket/device cleanup belongs to outer owner; no callback I/O or fabricated drain fence.',
 'verify':'Both TLS/audio roles and IPv4/IPv6 independent peer campaign; rejection cleanup, cancellation/deadline, EOF, repeat/stale controls, compiled mutations and legacy media regressions.',
 'next':'Bind the same transport to actual lifecycle, capture/playback workers, durable credentials and reviewed Apple TLS runtime.'}
c['lan-audio/tests/integration/verified_channel.zig']={
 'purpose':'Executable test-only caller of the real verified host connection with finite word verification.',
 'contract':'Public credentials and frozen wall time only here; explicit loopback endpoints, both TLS/audio roles; synchronous verifier only; no physical device or native callback claim.',
 'failure':'Named rejection includes permission/TLS release before explicit cleanup; actual socket cleanup occurs on exit paths. Preserve fixture-only boundaries.',
 'verify':'Independent Python peer plus Debug/ReleaseSafe and compiled mutation qualification.',
 'next':'Keep adversarial probes aligned with implemented host contracts; product command must never inherit fixture defaults.'}
c['lan-audio/tests/integration/verified_channel_peer.py']={
 'purpose':'Independent TLS/certificate-digest/v2 oracle for the native verified channel.',
 'contract':'Loopback only; explicit TLS1.3 client/server certificates; independent exact bytes and DER SHA256; bounded child/socket/thread lifetimes; new evidence reports only under verification.',
 'failure':'Success requires verified peer, full exact frames and clean close; negative requires named error and both released TLS and permission. Preserve crashes/timeouts as failures and never overwrite earlier results.',
 'verify':'42-case fresh campaign, mutation witnesses and custody before/after.',
 'next':'Qualify actual multi-device audio separately; do not turn test identities into application credentials.'}
c['lan-audio/docs/runtime/verified-channel.md']={
 'purpose':'Explain live verified identity mapping, record custody, native ownership and scoped evidence.',
 'contract':'Match actual worker-side Connection methods and explicit independent-peer/fixture limits.',
 'failure':'Do not equate local TLS completion with remote application approval or synchronous verification with native/audio completion.',
 'verify':'Source-bound integration evidence, application documentation/coverage checks.',
 'next':'Update the ownership argument when actual audio workers and Apple runtime are integrated.'}
c['lan-audio/src/security/peer_policy.zig']['next']='Live mapping now in verified_channel; restrictive identity store and real native workers remain open.'
c['lan-audio/tests/integration/peer_policy.zig']['next']='Preserve pure truth-table coverage alongside real verified-channel tests; persisted approvals remain open.'
contracts_path.write_text(json.dumps(c,indent=2)+'\n')
