# Planned `tools/verify-backend.py`

Status: **complete**. Milestone T0. Exact completion prerequisites are below. This is a design card, not a source stub or an exported capability.

## Responsibility and boundary

Read-only exact SDK/lock verifier independent of lock generation.

## Invariants, data ownership and errors

Reject missing, extra or changed files, invalid relative paths and disabled checks under Python -O.

Define input/output ownership, capacity units and failure atomicity in the first implementation. Refuse unsupported capability before accepting application work. Make terminal cleanup idempotent without treating protocol sends or application requests as generally retryable.

## Construction sequence

1. Read the existing relevant file contracts and [integration contract](../../../contracts/quic-tls.md). Resolve public types and caller/provider responsibilities.
2. Author independent positive and negative oracles for the acceptance cases below. Add a minimal compiling implementation behind explicit capability selection.
3. Connect the owning build and external consumer. Keep this design card, update its lifecycle status, and add a separate source-bound contract when the file exists.
4. Run both supported native build modes and the relevant model/interop/fuzz profile; record actual outcome and remaining limits.

## Acceptance cases

Corrupt one hash; remove/add file; path traversal in lock; unchanged SDK passes.

Completion requires all cases to have observable assertions, a bounded failure path and source-bound evidence. A successful happy-path demo alone does not close this card.

## Exact work package T00

Authority: [implementation plan](../../implementation-plan.json). Milestone labels group work; the following edges govern completion order. Tests can be authored earlier.

No new-file prerequisite; review existing source contracts before starting.

### Observable acceptance obligations

**T00-01**

- Stimulus: Run verifier normally and with Python -O against changed, missing and extra SDK files; include ../ and drive-qualified lock paths.
- Expected: Each invalid fixture exits nonzero without modifying the SDK or lock; unchanged exact set passes.
- Independent check: Compare hashes and file set before/after; verifier test computes expected digests independently.

**T00-02**

- Stimulus: Simulate wrong archive digest, ignored Range, short body and interrupted extraction in existing acquisition scripts.
- Expected: No incomplete tree is promoted; next run verifies a complete staged extraction instead of trusting Configure presence.
- Independent check: Fixture HTTP responses and independently enumerated final files; do not depend on assert statements.

These obligations refine the earlier acceptance list; they do not replace it. Capture command, exit status, source/backend identity, actual observed assertions and unresolved cases. The source-bound completion receipt records the implemented acceptance cases.

## Lifecycle and evidence

Follow the [completion protocol](../../completion-protocol.md). Preserve this design card and its acceptance obligations. Add current source documentation separately; completion requires matching source/log/obligation hashes and completed prerequisite evidence.

## Implementation milestone

The verifier and acquisition hardening now exist. See [current implementation evidence](../../../verification/t00-implementation.md). Original acceptance obligations above are retained; lifecycle completion follows the recorded gates.

## Recordless core implementation increment

Source and independent acceptance fixtures now exist. Current acceptance evidence is source-bound in the canonical completion receipt; prior receipts remain preserved. See [current status](../../../verification/t01-implementation.md).

Reopened during Q00 standards integration: the actual Engine accepted surplus Initial bytes beyond an encryption-level transition. Prior native evidence is retained; source-bound receipts will be refreshed after the new regression and fix.

Reopened for additive records verified-peer leaf digest export: broad source-bound receipts reference the records root/backend closure. Prior level-integrity qualification is preserved; native QUIC implementation is unchanged.
