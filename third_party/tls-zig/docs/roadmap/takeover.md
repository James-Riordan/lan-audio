# Before implementation takeover

This guide separates a usable implementation specification from a completed protocol. The project has documented primitives, scoped native evidence, exact work packages and acceptance obligations. It still needs implementation, independent interoperability and deployment qualification. No folder layout, model or score substitutes for those results.

## Start without inventing a subsystem

Read current status, the selected implementation profile, the decision register and the exact work graph. Run documentation, plan and lifecycle checks before changing source. Inspect the earliest ready packages: T00 backend verification, Q09 STREAM wire syntax, Q12 datagram host contract and Q14 deterministic network simulation. A developer can author dependent tests earlier, but cannot close a package before its prerequisites.

For each package: read its design card and existing caller/callee contracts; write independent failing acceptance checks; implement one observable increment; run the relevant native modes and consumer; update the source contract/inventory; attach exact evidence; then update lifecycle in both plan snapshots. The [completion protocol](completion-protocol.md) now defines the mechanical part of that process.

## Specification that must exist before each boundary is implemented

| Boundary | Required preparation | Where it now lives | Still requires implementation evidence |
| --- | --- | --- | --- |
| Public capability/configuration | selected version, role/policy and unsupported-feature behavior | [Implementation profile](../architecture/decisions/0002-implementation-profile.md) | independent consumer and negative configuration tests |
| TLS callback boundary | input lease, event receipt, direction, queue overflow and teardown | [Recordless events](../contracts/recordless-events.md) | both-role authenticated handshake; callback failure/lifetime traces |
| Connection orchestration | event precedence, receive commit, immutable send and ambiguous host outcomes | [Transactions](../contracts/connection-transactions.md) | complete state snapshots and deterministic event traces |
| Resources and scheduling | units, coupled capacity constraints, overflow/reclamation and measured envelope | [Budget contract](../contracts/resource-budgets.md) | allocation/work instrumentation and native measurements |
| Work completion | lifecycle, exact source/log scope and prerequisite evidence | [Completion protocol](completion-protocol.md) | actual commands and reviewer assessment; hashes cannot attest truth |
| Unsettled policy | named decision, owner package, resolving experiment and stop condition | [Decision register](decision-register.md) | selected experiments and deployment owner choices |

## What the handoff intentionally does not fabricate

No empty endpoint or fake working provider is added. No production memory number, throughput target, platform support, license authorization or external review is invented. No successful complete-QUIC-handshake result is inferred from the SDK ClientHello probe. There is no promise that all extensions or every RFC requirement have been enumerated: the scoped target is explicit, and its next implementation must maintain a requirement-to-test matrix as behavior expands.

The unresolved decisions are actionable work, not permission requests. Implementers can resolve technical experiments and document their evidence. Repository ownership/license and deployment identity/revocation policy require the appropriate owner before distribution or deployment; they do not prevent coding the selected baseline.

## First takeover increment

T00 is now complete; see [implementation evidence](../verification/t00-implementation.md). The next production dependency is T01. The original T00 work order below is retained as its required scope.

T00 is the smallest security-relevant foundation. Add read-only exact SDK verification; make existing acquisition/pinning integrity checks unconditional; test malformed ranges, short downloads, corrupt digests and interrupted staging normally and under Python -O. Do not rebuild or repin the already-qualified SDK just to make the verifier pass. Keep this separate from the recordless provider implementation and preserve records regressions.

After T00, implement T01/T03/T05 contract, event custody and ABI before T04/T02/T06 provider/owner/conformance. The already-passing callback probe narrows uncertainty; it does not eliminate the need for real peer tests. Q00/Q01 then integrate the real provider without record-layer tunneling or premature application readiness.

## Ecosystem alignment — revision 4

[QUIC/TLS ecosystem boundary](../ecosystem/overview.md) defines configuration, host adaptation, identity, maintenance, observability and future Docz migration. Eleven additional obligations refine existing packages; no new runtime dependency is adopted.

## Revision 5: provider experiment before implementation

Read the [authenticated callback experiment](../verification/quic-provider-pair.md) before T02/T04/T06/Q00. It adds exact failure-cleanup and local-work scheduling obligations while all 37 production packages remain planned. The current shared plan contains 89 acceptance obligations.
