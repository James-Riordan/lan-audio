# Planned `examples/consumer/socket_posix.c`

Status: **not implemented**. Milestone T2. Exact completion prerequisites are below. This is a design card, not a source stub or an exported capability.

## Responsibility and boundary

POSIX demonstration transport matching the public Driver contract.

## Invariants, data ownership and errors

Nonblocking descriptors and host-owned close; distinguish EINTR, would-block, EOF and hard errors.

Define input/output ownership, capacity units and failure atomicity in the first implementation. Refuse unsupported capability before accepting application work. Make terminal cleanup idempotent without treating protocol sends or application requests as generally retryable.

## Construction sequence

1. Read the existing relevant file contracts and [integration contract](../../../../contracts/quic-tls.md). Resolve public types and caller/provider responsibilities.
2. Author independent positive and negative oracles for the acceptance cases below. Add a minimal compiling implementation behind explicit capability selection.
3. Connect the owning build and external consumer. Keep this design card, update its lifecycle status, and add a separate source-bound contract when the file exists.
4. Run both supported native build modes and the relevant model/interop/fuzz profile; record actual outcome and remaining limits.

## Acceptance cases

Partial read/write, IPv4/IPv6, connect failure, cancellation and descriptor cleanup.

Completion requires all cases to have observable assertions, a bounded failure path and source-bound evidence. A successful happy-path demo alone does not close this card.

## Exact work package T08

Authority: [implementation plan](../../../implementation-plan.json). Milestone labels group work; the following edges govern completion order. Tests can be authored earlier.

- `T07` — `tls-zig/build/backend.zig` must satisfy its acceptance evidence.

### Observable acceptance obligations

**T08-01**

- Stimulus: Drive nonblocking read/write with EINTR, EAGAIN, short transfer, clean EOF and hard error.
- Expected: Driver receives distinct outcomes and exact transferred prefix; callbacks never block or retry forever.
- Independent check: Injected syscall shim with finite call budget; real loopback test separately.

**T08-02**

- Stimulus: Cancel during connect/read/write and cycle IPv4/IPv6 sockets repeatedly.
- Expected: Host closes each descriptor exactly once; no descriptor growth; caller buffer released on completion.
- Independent check: Descriptor counts and transport ownership trace before/after each case.

These obligations refine the earlier acceptance list; they do not replace it. Capture command, exit status, source/backend identity, actual observed assertions and unresolved cases. No test above is represented as already implemented.

## Lifecycle and evidence

Follow the [completion protocol](../../../completion-protocol.md). Preserve this design card and its acceptance obligations. Add current source documentation separately; completion requires matching source/log/obligation hashes and completed prerequisite evidence.
