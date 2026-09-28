# Planned `bench/engine.zig`

Status: **not implemented**. Milestone T4. Exact completion prerequisites are below. This is a design card, not a source stub or an exported capability.

## Responsibility and boundary

Measure handshake/read/write scheduling cost and resource use.

## Invariants, data ownership and errors

Separate provider CPU from host transport time; record distributions and environment; never suppress authentication for speed.

Define input/output ownership, capacity units and failure atomicity in the first implementation. Refuse unsupported capability before accepting application work. Make terminal cleanup idempotent without treating protocol sends or application requests as generally retryable.

## Construction sequence

1. Read the existing relevant file contracts and [integration contract](../../../contracts/quic-tls.md). Resolve public types and caller/provider responsibilities.
2. Author independent positive and negative oracles for the acceptance cases below. Add a minimal compiling implementation behind explicit capability selection.
3. Connect the owning build and external consumer. Keep this design card, update its lifecycle status, and add a separate source-bound contract when the file exists.
4. Run both supported native build modes and the relevant model/interop/fuzz profile; record actual outcome and remaining limits.

## Acceptance cases

Cold/warm starts, fragmented records, many connections, certificate sizes and cancellation latency.

Completion requires all cases to have observable assertions, a bounded failure path and source-bound evidence. A successful happy-path demo alone does not close this card.

## Exact work package T14

Authority: [implementation plan](../../implementation-plan.json). Milestone labels group work; the following edges govern completion order. Tests can be authored earlier.

- `T12` — `tls-zig/tests/resource_limits.zig` must satisfy its acceptance evidence.

### Observable acceptance obligations

**T14-01**

- Stimulus: Measure cold/warm handshakes, fragmented records and many concurrent owners.
- Expected: Report distributions, allocations and environment with identical authentication settings.
- Independent check: Independent plaintext checks outside timed region; timer resolution recorded.

**T14-02**

- Stimulus: Cancel at worst observed queue depth and certificate size.
- Expected: Cancellation latency/work stays within declared measured envelope or fails the stated target.
- Independent check: Injected scheduling trace and independent elapsed/work counters; no unmeasured universal bound.

These obligations refine the earlier acceptance list; they do not replace it. Capture command, exit status, source/backend identity, actual observed assertions and unresolved cases. No test above is represented as already implemented.

## Lifecycle and evidence

Follow the [completion protocol](../../completion-protocol.md). Preserve this design card and its acceptance obligations. Add current source documentation separately; completion requires matching source/log/obligation hashes and completed prerequisite evidence.
