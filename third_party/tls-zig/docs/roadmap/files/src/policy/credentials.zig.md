# Planned `src/policy/credentials.zig`

Status: **not implemented**. Milestone T3. Exact completion prerequisites are below. This is a design card, not a source stub or an exported capability.

## Responsibility and boundary

Versioned immutable credential configuration for new connections.

## Invariants, data ownership and errors

Rotation affects new owners; live engines retain their own credentials; cleanup after last reference; encrypted-key policy explicit.

Define input/output ownership, capacity units and failure atomicity in the first implementation. Refuse unsupported capability before accepting application work. Make terminal cleanup idempotent without treating protocol sends or application requests as generally retryable.

## Construction sequence

1. Read the existing relevant file contracts and [integration contract](../../../../contracts/quic-tls.md). Resolve public types and caller/provider responsibilities.
2. Author independent positive and negative oracles for the acceptance cases below. Add a minimal compiling implementation behind explicit capability selection.
3. Connect the owning build and external consumer. Keep this design card, update its lifecycle status, and add a separate source-bound contract when the file exists.
4. Run both supported native build modes and the relevant model/interop/fuzz profile; record actual outcome and remaining limits.

## Acceptance cases

Rotate during handshake, missing pair, invalid chain, handle retirement and config rollback.

Completion requires all cases to have observable assertions, a bounded failure path and source-bound evidence. A successful happy-path demo alone does not close this card.

## Exact work package T10

Authority: [implementation plan](../../../implementation-plan.json). Milestone labels group work; the following edges govern completion order. Tests can be authored earlier.

- `T07` — `tls-zig/build/backend.zig` must satisfy its acceptance evidence.
- `T09` — `tls-zig/tests/abi.zig` must satisfy its acceptance evidence.

### Observable acceptance obligations

**T10-01**

- Stimulus: Rotate credential configuration while old and new handshakes run.
- Expected: Existing owners retain original credential version; new owners receive new version; last release destroys retired version.
- Independent check: Certificate fingerprint per peer and exact reference/free counters.

**T10-02**

- Stimulus: Attempt rotation with missing key, invalid chain or allocation failure.
- Expected: Previously active version remains usable; failed candidate resources are released.
- Independent check: Independent pre/post configuration fingerprint and leak instrumentation.

These obligations refine the earlier acceptance list; they do not replace it. Capture command, exit status, source/backend identity, actual observed assertions and unresolved cases. No test above is represented as already implemented.

## Lifecycle and evidence

Follow the [completion protocol](../../../completion-protocol.md). Preserve this design card and its acceptance obligations. Add current source documentation separately; completion requires matching source/log/obligation hashes and completed prerequisite evidence.

## Ecosystem boundary acceptance

**T10-03**

- Stimulus: Change terminal context and logical credential locator while existing/new TLS owners coexist.
- Expected: Ambient context cannot mutate existing credentials; explicitly accepted rotation uses distinct retained versions.
- Independent check: Old/new credential fingerprints and owner lifetimes; no secret bytes in plan or diagnostic output.

This is an additional proposed obligation, not executed integration evidence. See [ecosystem boundary](../../../../ecosystem/overview.md).
