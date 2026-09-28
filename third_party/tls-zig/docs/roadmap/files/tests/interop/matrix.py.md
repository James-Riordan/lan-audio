# Planned `tests/interop/matrix.py`

Status: **not implemented**. Milestone T4. Exact completion prerequisites are below. This is a design card, not a source stub or an exported capability.

## Responsibility and boundary

Run a recorded multi-provider/platform TLS qualification matrix.

## Invariants, data ownership and errors

Pin peer/build versions and test settings; local loopback isolation; no verification bypass; explicit skip reasons.

Define input/output ownership, capacity units and failure atomicity in the first implementation. Refuse unsupported capability before accepting application work. Make terminal cleanup idempotent without treating protocol sends or application requests as generally retryable.

## Construction sequence

1. Read the existing relevant file contracts and [integration contract](../../../../contracts/quic-tls.md). Resolve public types and caller/provider responsibilities.
2. Author independent positive and negative oracles for the acceptance cases below. Add a minimal compiling implementation behind explicit capability selection.
3. Connect the owning build and external consumer. Keep this design card, update its lifecycle status, and add a separate source-bound contract when the file exists.
4. Run both supported native build modes and the relevant model/interop/fuzz profile; record actual outcome and remaining limits.

## Acceptance cases

Both roles; identity/ALPN negatives; shutdown; backpressure; provider upgrade regression.

Completion requires all cases to have observable assertions, a bounded failure path and source-bound evidence. A successful happy-path demo alone does not close this card.

## Exact work package T13

Authority: [implementation plan](../../../implementation-plan.json). Milestone labels group work; the following edges govern completion order. Tests can be authored earlier.

- `T06` — `tls-zig/tests/quic_contract.zig` must satisfy its acceptance evidence.
- `T08` — `tls-zig/examples/consumer/socket_posix.c` must satisfy its acceptance evidence.
- `T09` — `tls-zig/tests/abi.zig` must satisfy its acceptance evidence.
- `T12` — `tls-zig/tests/resource_limits.zig` must satisfy its acceptance evidence.

### Observable acceptance obligations

**T13-01**

- Stimulus: Run both roles across recorded provider/platform combinations with custom ALPN and identity failures.
- Expected: All required cells pass; missing tools/platforms are explicit unqualified cells.
- Independent check: Pinned independent peer commands and full exit/output receipts.

**T13-02**

- Stimulus: Exercise shutdown, partial records, backpressure and provider upgrade regression.
- Expected: Authenticated closure distinguished from truncation; pending bytes preserved; prior compatibility profile retained or versioned.
- Independent check: Wire/application hashes, EOF classification and before/after source/backend identities.

These obligations refine the earlier acceptance list; they do not replace it. Capture command, exit status, source/backend identity, actual observed assertions and unresolved cases. No test above is represented as already implemented.

## Lifecycle and evidence

Follow the [completion protocol](../../../completion-protocol.md). Preserve this design card and its acceptance obligations. Add current source documentation separately; completion requires matching source/log/obligation hashes and completed prerequisite evidence.

## Ecosystem boundary acceptance

**T13-03**

- Stimulus: Compare baseline/candidate shared TLS artifact across all declared consumers, including one missing or failed cell.
- Expected: Coverage gaps block promotion; pre-existing/new/unattributed diagnostics remain visible; no implicit consumer repin.
- Independent check: Exact consumer list, retained dual-stream outputs and independent baseline/candidate identities.

This is an additional proposed obligation, not executed integration evidence. See [ecosystem boundary](../../../../ecosystem/overview.md).
