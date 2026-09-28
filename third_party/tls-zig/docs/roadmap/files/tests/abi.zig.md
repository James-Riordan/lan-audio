# Planned `tests/abi.zig`

Status: **not implemented**. Milestone T2. Exact completion prerequisites are below. This is a design card, not a source stub or an exported capability.

## Responsibility and boundary

Compile/link ABI contract tests across supported targets.

## Invariants, data ownership and errors

Check C scalar widths and pointer nullability; instantiate public constructors through real linkage.

Define input/output ownership, capacity units and failure atomicity in the first implementation. Refuse unsupported capability before accepting application work. Make terminal cleanup idempotent without treating protocol sends or application requests as generally retryable.

## Construction sequence

1. Read the existing relevant file contracts and [integration contract](../../../contracts/quic-tls.md). Resolve public types and caller/provider responsibilities.
2. Author independent positive and negative oracles for the acceptance cases below. Add a minimal compiling implementation behind explicit capability selection.
3. Connect the owning build and external consumer. Keep this design card, update its lifecycle status, and add a separate source-bound contract when the file exists.
4. Run both supported native build modes and the relevant model/interop/fuzz profile; record actual outcome and remaining limits.

## Acceptance cases

Native LP64/LLP64 coverage; mismatched header/library must fail clearly.

Completion requires all cases to have observable assertions, a bounded failure path and source-bound evidence. A successful happy-path demo alone does not close this card.

## Exact work package T09

Authority: [implementation plan](../../implementation-plan.json). Milestone labels group work; the following edges govern completion order. Tests can be authored earlier.

- `T07` — `tls-zig/build/backend.zig` must satisfy its acceptance evidence.

### Observable acceptance obligations

**T09-01**

- Stimulus: Compare C header and Zig extern scalar widths, pointer shapes and constructor argument order.
- Expected: Compile/link/invocation agree on every supported native target.
- Independent check: C-produced ABI constants and separate Zig consumer.

**T09-02**

- Stimulus: Link a fixture library with deliberately incompatible ABI version or signature guard.
- Expected: Compatibility check rejects mismatch before normal operations.
- Independent check: Known wrong-library fixture; do not use an unsafe call to discover stack corruption.

These obligations refine the earlier acceptance list; they do not replace it. Capture command, exit status, source/backend identity, actual observed assertions and unresolved cases. No test above is represented as already implemented.

## Lifecycle and evidence

Follow the [completion protocol](../../completion-protocol.md). Preserve this design card and its acceptance obligations. Add current source documentation separately; completion requires matching source/log/obligation hashes and completed prerequisite evidence.

## Ecosystem boundary acceptance

**T09-03**

- Stimulus: Supply declared target capability, unknown runtime observation, and runtime request for an omitted compiled branch.
- Expected: A declaration is never treated as observed usability; unknown/absent required capability fails with a specific reason.
- Independent check: Separately authored target/observation/compiled-capability fixtures; native ABI/runtime tests remain independent.

This is an additional proposed obligation, not executed integration evidence. See [ecosystem boundary](../../../ecosystem/overview.md).
