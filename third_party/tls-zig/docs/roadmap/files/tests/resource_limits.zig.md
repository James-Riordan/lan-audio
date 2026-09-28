# Planned `tests/resource_limits.zig`

Status: **not implemented**. Milestone T3. Exact completion prerequisites are below. This is a design card, not a source stub or an exported capability.

## Responsibility and boundary

Measure and constrain provider allocation and work under adversarial input.

## Invariants, data ownership and errors

BIO bounds are not a total heap bound; define supported total-resource enforcement before claiming it.

Define input/output ownership, capacity units and failure atomicity in the first implementation. Refuse unsupported capability before accepting application work. Make terminal cleanup idempotent without treating protocol sends or application requests as generally retryable.

## Construction sequence

1. Read the existing relevant file contracts and [integration contract](../../../contracts/quic-tls.md). Resolve public types and caller/provider responsibilities.
2. Author independent positive and negative oracles for the acceptance cases below. Add a minimal compiling implementation behind explicit capability selection.
3. Connect the owning build and external consumer. Keep this design card, update its lifecycle status, and add a separate source-bound contract when the file exists.
4. Run both supported native build modes and the relevant model/interop/fuzz profile; record actual outcome and remaining limits.

## Acceptance cases

Large chain, malformed messages, repeated fragments, concurrent handshakes and cleanup after allocation failure.

Completion requires all cases to have observable assertions, a bounded failure path and source-bound evidence. A successful happy-path demo alone does not close this card.

## Exact work package T12

Authority: [implementation plan](../../implementation-plan.json). Milestone labels group work; the following edges govern completion order. Tests can be authored earlier.

- `T02` — `tls-zig/src/quic/engine.zig` must satisfy its acceptance evidence.
- `T10` — `tls-zig/src/policy/credentials.zig` must satisfy its acceptance evidence.
- `T11` — `tls-zig/src/policy/verification.zig` must satisfy its acceptance evidence.

### Observable acceptance obligations

**T12-01**

- Stimulus: Feed large chains, repeated fragments and many simultaneous handshakes under declared quotas.
- Expected: Peak provider and wrapper allocations/work are measured separately; enforced quotas terminate boundedly.
- Independent check: Allocator/process measurements and callback operation budget; BIO size is not total heap.

**T12-02**

- Stimulus: Fail each allocation ordinal during construction, progress and teardown.
- Expected: No leak, double free or post-terminal delivery; preexisting owners remain valid.
- Independent check: Allocator ledger and sanitizers/available native diagnostics with recorded limitations.

These obligations refine the earlier acceptance list; they do not replace it. Capture command, exit status, source/backend identity, actual observed assertions and unresolved cases. No test above is represented as already implemented.

## Lifecycle and evidence

Follow the [completion protocol](../../completion-protocol.md). Preserve this design card and its acceptance obligations. Add current source documentation separately; completion requires matching source/log/obligation hashes and completed prerequisite evidence.
