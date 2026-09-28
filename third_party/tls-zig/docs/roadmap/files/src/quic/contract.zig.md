# Planned `src/quic/contract.zig`

Status: **complete**. Milestone T1. Exact completion prerequisites are below. This is a design card, not a source stub or an exported capability.

## Responsibility and boundary

TLS-owned recordless boundary with precise provider capabilities.

## Invariants, data ownership and errors

Separate records and handshake modes; declare borrowed event lifetimes, consumption, backpressure, epoch, secret lifetime and cancellation.

Define input/output ownership, capacity units and failure atomicity in the first implementation. Refuse unsupported capability before accepting application work. Make terminal cleanup idempotent without treating protocol sends or application requests as generally retryable.

## Construction sequence

1. Read the existing relevant file contracts and [integration contract](../../../../contracts/quic-tls.md). Resolve public types and caller/provider responsibilities.
2. Author independent positive and negative oracles for the acceptance cases below. Add a minimal compiling implementation behind explicit capability selection.
3. Connect the owning build and external consumer. Keep this design card, update its lifecycle status, and add a separate source-bound contract when the file exists.
4. Run both supported native build modes and the relevant model/interop/fuzz profile; record actual outcome and remaining limits.

## Acceptance cases

Compile consumer fixture and provider against one contract; unsupported capability returns explicit error.

Completion requires all cases to have observable assertions, a bounded failure path and source-bound evidence. A successful happy-path demo alone does not close this card.

## Exact work package T01

Authority: [implementation plan](../../../implementation-plan.json). Milestone labels group work; the following edges govern completion order. Tests can be authored earlier.

- `T00` — `tls-zig/tools/verify-backend.py` must satisfy its acceptance evidence.

### Observable acceptance obligations

**T01-01**

- Stimulus: Compile one host fixture and one provider against the same contract; request records-only provider in recordless mode.
- Expected: Compatible fixtures link; unavailable recordless capability fails construction before input is accepted.
- Independent check: Separate consumer build and explicit error observation.

**T01-02**

- Stimulus: Specify input bytes, secret event, peer parameters, cancellation and stale event token in a contract-only fixture.
- Expected: Every borrow has one ending action; units, direction and generation have explicit types; no accepted prefix exceeds input.
- Independent check: Review ownership table and compile negative type examples; these are design checks until executable types exist.

These obligations refine the earlier acceptance list; they do not replace it. Capture command, exit status, source/backend identity, actual observed assertions and unresolved cases. No test above is represented as already implemented.

## Lifecycle and evidence

Follow the [completion protocol](../../../completion-protocol.md). Preserve this design card and its acceptance obligations. Add current source documentation separately; completion requires matching source/log/obligation hashes and completed prerequisite evidence.

## Ecosystem boundary acceptance

**T01-03**

- Stimulus: Normalize environment defaults and attempt an unauthorized trust/capability override before construction.
- Expected: Typed effective options match the recorded normalized plan; unauthorized or unclassified changes fail before input/allocation.
- Independent check: Independent selected-option/schema identity and caller allowlist; verify no post-hash native default was introduced.

This is an additional proposed obligation, not executed integration evidence. See [ecosystem boundary](../../../../ecosystem/overview.md).

## Recordless core implementation increment

Source and independent acceptance fixtures now exist. Current acceptance evidence is source-bound in the canonical completion receipt; prior receipts remain preserved. See [current status](../../../../verification/t01-implementation.md).

Reopened during Q00 standards integration: the actual Engine accepted surplus Initial bytes beyond an encryption-level transition. Prior native evidence is retained; source-bound receipts will be refreshed after the new regression and fix.

Reopened for additive records verified-peer leaf digest export: broad source-bound receipts reference the records root/backend closure. Prior level-integrity qualification is preserved; native QUIC implementation is unchanged.
