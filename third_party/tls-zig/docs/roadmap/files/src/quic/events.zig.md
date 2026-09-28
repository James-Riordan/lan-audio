# Planned `src/quic/events.zig`

Status: **complete**. Milestone T1. Exact completion prerequisites are below. This is a design card, not a source stub or an exported capability.

## Responsibility and boundary

Bounded acknowledged event queue for bytes, secrets, peer parameters and completion.

## Invariants, data ownership and errors

Stable event identity; no overwrite while borrowed; copy/derive before acknowledgement; stale acknowledgments fail.

Define input/output ownership, capacity units and failure atomicity in the first implementation. Refuse unsupported capability before accepting application work. Make terminal cleanup idempotent without treating protocol sends or application requests as generally retryable.

## Construction sequence

1. Read the existing relevant file contracts and [integration contract](../../../../contracts/quic-tls.md). Resolve public types and caller/provider responsibilities.
2. Author independent positive and negative oracles for the acceptance cases below. Add a minimal compiling implementation behind explicit capability selection.
3. Connect the owning build and external consumer. Keep this design card, update its lifecycle status, and add a separate source-bound contract when the file exists.
4. Run both supported native build modes and the relevant model/interop/fuzz profile; record actual outcome and remaining limits.

## Acceptance cases

Queue full, repeated next-event, out-of-order/stale ack, epoch rollover and cancel with borrowed secret.

Completion requires all cases to have observable assertions, a bounded failure path and source-bound evidence. A successful happy-path demo alone does not close this card.

## Exact work package T03

Authority: [implementation plan](../../../implementation-plan.json). Milestone labels group work; the following edges govern completion order. Tests can be authored earlier.

- `T01` — `tls-zig/src/quic/contract.zig` must satisfy its acceptance evidence.

### Observable acceptance obligations

**T03-01**

- Stimulus: Fill two event slots, borrow the head twice, then acknowledge tail or old-generation token.
- Expected: Same head bytes/token remain stable; invalid acknowledgement changes neither queue nor custody.
- Independent check: Finite custody model plus independently authored queue trace.

**T03-02**

- Stimulus: Acknowledge a secret before copying/deriving it; then cancel with a borrowed event and attempt reuse.
- Expected: Early acknowledgement rejected; cancel invalidates borrow, clears owned secret, and forbids reuse of old owner identity.
- Independent check: Fault-injected model and memory lifecycle instrumentation; abstract erasure alone is insufficient.

These obligations refine the earlier acceptance list; they do not replace it. Capture command, exit status, source/backend identity, actual observed assertions and unresolved cases. No test above is represented as already implemented.

## Lifecycle and evidence

Follow the [completion protocol](../../../completion-protocol.md). Preserve this design card and its acceptance obligations. Add current source documentation separately; completion requires matching source/log/obligation hashes and completed prerequisite evidence.

## Recordless core implementation increment

Source and independent acceptance fixtures now exist. Current acceptance evidence is source-bound in the canonical completion receipt; prior receipts remain preserved. See [current status](../../../../verification/t01-implementation.md).

Reopened during Q00 standards integration: the actual Engine accepted surplus Initial bytes beyond an encryption-level transition. Prior native evidence is retained; source-bound receipts will be refreshed after the new regression and fix.

Reopened for additive records verified-peer leaf digest export: broad source-bound receipts reference the records root/backend closure. Prior level-integrity qualification is preserved; native QUIC implementation is unchanged.
