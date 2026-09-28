# One-command maintenance and bounded observability

Status: QUIC/TLS integration requirements aligned with inspected Updatez/JCR contracts. Updatez's source documentation describes selected implemented reconciliation/diagnostic paths and explicit remaining gaps. This pass neither invokes uz! nor changes its runtime/configuration or application pins.

## Consumer-safe update journey

| Stage | Required record | Failure behavior |
| --- | --- | --- |
| observe baseline | exact source/build/backend/compiler/configuration and consumer set; both command streams | missing/inaccessible/unknown is distinct from empty or healthy |
| prepare candidate | immutable candidate closure, intended version policy, allowed changed paths | preserve existing source and user edits; no in-place library replacement during qualification |
| run equivalent checks | baseline/candidate commands, target/mode, actual outputs, diagnostics and completeness | failed or skipped cells stay visible; absent consumer coverage blocks shared-runtime promotion |
| compare | pre-existing, persistent, resolved, newly observed and unattributed issues | a candidate issue is not erased because baseline also had unrelated failures |
| qualify consumer | public package build, API/ABI, runtime identity, peer behavior and relevant failure/resource cases | protocol probe or source hash alone does not establish consumer adoption |
| promote | explicit consumer-owned pin/selector change with receipt | do not regenerate a pin merely to conceal a mismatch |
| reconcile rerun | stable operation/input identity and interrupted/completed effect ledger | no duplicate promotion/commit; changed inputs become a new reviewed operation |

The exact Zig and OpenSSL identities remain pinned for these projects until a reviewed upgrade is qualified. The user's general preference for current versions does not justify breaking a compiler ABI dependency. A successful check does not mean latest release, zero warnings or complete fleet coverage.

## Repair packet for future Codex work

A useful failure packet contains project/component identity, baseline and candidate source scopes, environment/target/compiler/backend, exact command arguments, bounded structured diagnostic observations, full retained stdout/stderr references, failure classification, prior issue comparison, reproducer and allowed mutation scope. It states whether observed input coverage was complete. Never include plaintext payloads, private keys, session secrets, access tokens or environment secret values.

Its repair instructions should specify the failing assertion and owning source contract, not merely say make checks green. Preserve the unsuccessful receipt. A repair generates a new candidate and fresh equivalent evidence; it does not rewrite old outputs or lower warning/error policy without an explicit policy decision.

## Operational telemetry contract

| Signal | Suggested content | Limit / authority |
| --- | --- | --- |
| connection progress | phase, role, encryption level, queue occupancy, blocked reason | bounded event vocabulary; no raw handshake/secret/plaintext dump |
| transport health | RTT/loss estimates, bytes in flight, credit, deadline and path state | units explicit; estimate distinct from observation; address/identity disclosure policy belongs to host |
| TLS policy outcome | stable reason, selected ALPN policy outcome, verification stage | no certificate identity or provider error queue exposed automatically across tenants |
| resource pressure | configured limits, high-water marks, rejected admission, operation counts | sampled/aggregated under host budget; logger cannot become unbounded allocation path |
| maintenance diagnosis | exact artifact/version identities and baseline/candidate classification | separate from runtime packet telemetry and application audit records |
| application audit | application-owned operation/authorization/commit identity | not synthesized from TLS completion or QUIC ACK |

Use host callbacks or pull snapshots so libraries remain usable without a specific telemetry server, GUI or managed account. A diagnostic sink must be nonblocking under its contract, nonreentrant and bounded; overload drops/aggregates optional telemetry with explicit counters. Mandatory audit durability, if required by an application, has its own failure policy and cannot be silently downgraded to a best-effort logger.

## Workflow acceptance

T13-03/Q19-03 require baseline/candidate and actual consumer coverage, source-bound diagnostics and no automatic pin change. Q06-03 checks telemetry overload/reentry cannot change protocol outcomes or leak secret buffers. Q13-03 checks context/logical service attribution is metadata, not admission or authentication authority. A simple front door is achieved by clear outcomes and ownership behind it; it does not hide unsupported or failed work.
