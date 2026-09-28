# Planned `src/backend/quic.h`

Status: **complete**. Milestone T1. Exact completion prerequisites are below. This is a design card, not a source stub or an exported capability.

## Responsibility and boundary

Minimal internal ABI for the recordless backend.

## Invariants, data ownership and errors

Typed directions/levels and length units; no C enum layout assumptions across ABI; live-handle ownership documented.

Define input/output ownership, capacity units and failure atomicity in the first implementation. Refuse unsupported capability before accepting application work. Make terminal cleanup idempotent without treating protocol sends or application requests as generally retryable.

## Construction sequence

1. Read the existing relevant file contracts and [integration contract](../../../../contracts/quic-tls.md). Resolve public types and caller/provider responsibilities.
2. Author independent positive and negative oracles for the acceptance cases below. Add a minimal compiling implementation behind explicit capability selection.
3. Connect the owning build and external consumer. Keep this design card, update its lifecycle status, and add a separate source-bound contract when the file exists.
4. Run both supported native build modes and the relevant model/interop/fuzz profile; record actual outcome and remaining limits.

## Acceptance cases

Cross-language sizeof/alignment/signature smoke test and rejected null/length combinations.

Completion requires all cases to have observable assertions, a bounded failure path and source-bound evidence. A successful happy-path demo alone does not close this card.

## Exact work package T05

Authority: [implementation plan](../../../implementation-plan.json). Milestone labels group work; the following edges govern completion order. Tests can be authored earlier.

- `T01` — `tls-zig/src/quic/contract.zig` must satisfy its acceptance evidence.

### Observable acceptance obligations

**T05-01**

- Stimulus: Compile C and Zig ABI consumers with size, alignment and function-signature checks on native LLP64 and LP64.
- Expected: Widths and nullable pointer/length rules agree or target is explicitly unsupported.
- Independent check: C sizeof/alignof and Zig @sizeOf/@alignOf; link and invoke actual symbols.

**T05-02**

- Stimulus: Pass null with nonzero length, unknown level/direction, closed handle via safe test hooks, and output capacity zero.
- Expected: Declared validation error without output mutation; freed raw pointers are never deliberately dereferenced.
- Independent check: C ABI harness snapshots output and allocation ownership around each safe invalid call.

These obligations refine the earlier acceptance list; they do not replace it. Capture command, exit status, source/backend identity, actual observed assertions and unresolved cases. No test above is represented as already implemented.

## Lifecycle and evidence

Follow the [completion protocol](../../../completion-protocol.md). Preserve this design card and its acceptance obligations. Add current source documentation separately; completion requires matching source/log/obligation hashes and completed prerequisite evidence.

Reopened during Q00 standards integration: the actual Engine accepted surplus Initial bytes beyond an encryption-level transition. Prior native evidence is retained; source-bound receipts will be refreshed after the new regression and fix.

Reopened for additive records verified-peer leaf digest export: broad source-bound receipts reference the records root/backend closure. Prior level-integrity qualification is preserved; native QUIC implementation is unchanged.
