# Planned `src/quic/engine.zig`

Status: **complete**. Milestone T1. Exact completion prerequisites are below. This is a design card, not a source stub or an exported capability.

## Responsibility and boundary

Public owner for recordless TLS handshake operations.

## Invariants, data ownership and errors

Never route QUIC CRYPTO through feedRecords; own peer checks, parameters, post-handshake messages and provider lifetime.

Define input/output ownership, capacity units and failure atomicity in the first implementation. Refuse unsupported capability before accepting application work. Make terminal cleanup idempotent without treating protocol sends or application requests as generally retryable.

## Construction sequence

1. Read the existing relevant file contracts and [integration contract](../../../../contracts/quic-tls.md). Resolve public types and caller/provider responsibilities.
2. Author independent positive and negative oracles for the acceptance cases below. Add a minimal compiling implementation behind explicit capability selection.
3. Connect the owning build and external consumer. Keep this design card, update its lifecycle status, and add a separate source-bound contract when the file exists.
4. Run both supported native build modes and the relevant model/interop/fuzz profile; record actual outcome and remaining limits.

## Acceptance cases

Both roles; partial input; output pending; wrong identity/ALPN; stale events; canceled owner.

Completion requires all cases to have observable assertions, a bounded failure path and source-bound evidence. A successful happy-path demo alone does not close this card.

## Exact work package T02

Authority: [implementation plan](../../../implementation-plan.json). Milestone labels group work; the following edges govern completion order. Tests can be authored earlier.

- `T03` — `tls-zig/src/quic/events.zig` must satisfy its acceptance evidence.
- `T04` — `tls-zig/src/backend/quic.c` must satisfy its acceptance evidence.
- `T05` — `tls-zig/src/backend/quic.h` must satisfy its acceptance evidence.

### Observable acceptance obligations

**T02-01**

- Stimulus: Run a complete real certificate handshake in both roles with fragmented per-level bytes and bounded output.
- Expected: Completion occurs once after configured peer/ALPN policy; no record-layer feed API is called.
- Independent check: Independent expected SAN/ALPN and peer implementation; record event order and per-level byte hashes.

**T02-02**

- Stimulus: Use wrong SAN, untrusted CA, mismatched ALPN, cancellation and repeated calls after terminal failure.
- Expected: No application-ready event; stable terminal error; all owned queues and secrets released once.
- Independent check: Instrument allocation/free and event counters; do not infer authentication from traffic-secret availability.

These obligations refine the earlier acceptance list; they do not replace it. Capture command, exit status, source/backend identity, actual observed assertions and unresolved cases. No test above is represented as already implemented.

## Lifecycle and evidence

Follow the [completion protocol](../../../completion-protocol.md). Preserve this design card and its acceptance obligations. Add current source documentation separately; completion requires matching source/log/obligation hashes and completed prerequisite evidence.

## Revision 5 provider-boundary evidence

**T02-03**

- Stimulus: Cancel or fail while a provider lease remains held, including an alert callback failure and a failed release callback.
- Expected: Public entry closes before destruction; callback state remains live through provider cleanup; owned custody and secrets are disposed once after provider access ends.
- Independent check: Instrument allocation lifetime and poisoning at each retained state in the real Zig/C owner; compare with native cleanup traces.

[Native diagnostic and its limits](../../../../verification/quic-provider-pair.md). Current source-bound acceptance is recorded in the canonical completion receipt; native platform and full QUIC interoperability gates remain separate.

Reopened during Q00 standards integration: the actual Engine accepted surplus Initial bytes beyond an encryption-level transition. Prior native evidence is retained; source-bound receipts will be refreshed after the new regression and fix.

Reopened for additive records verified-peer leaf digest export: broad source-bound receipts reference the records root/backend closure. Prior level-integrity qualification is preserved; native QUIC implementation is unchanged.
