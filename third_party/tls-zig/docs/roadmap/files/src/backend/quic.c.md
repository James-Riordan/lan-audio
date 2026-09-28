# Planned `src/backend/quic.c`

Status: **complete**. Milestone T1. Exact completion prerequisites are below. This is a design card, not a source stub or an exported capability.

## Responsibility and boundary

OpenSSL external QUIC TLS callback adapter, isolated from records BIO backend.

## Invariants, data ownership and errors

Probe symbols in the exact SDK first. Establish callback-owned copies before reporting success and cleanup every failure path.

Define input/output ownership, capacity units and failure atomicity in the first implementation. Refuse unsupported capability before accepting application work. Make terminal cleanup idempotent without treating protocol sends or application requests as generally retryable.

## Construction sequence

1. Read the existing relevant file contracts and [integration contract](../../../../contracts/quic-tls.md). Resolve public types and caller/provider responsibilities.
2. Author independent positive and negative oracles for the acceptance cases below. Add a minimal compiling implementation behind explicit capability selection.
3. Connect the owning build and external consumer. Keep this design card, update its lifecycle status, and add a separate source-bound contract when the file exists.
4. Run both supported native build modes and the relevant model/interop/fuzz profile; record actual outcome and remaining limits.

## Acceptance cases

Independent handshake, callback ordering and failure injection; no production claim from a symbol probe alone.

Completion requires all cases to have observable assertions, a bounded failure path and source-bound evidence. A successful happy-path demo alone does not close this card.

## Exact work package T04

Authority: [implementation plan](../../../implementation-plan.json). Milestone labels group work; the following edges govern completion order. Tests can be authored earlier.

- `T05` — `tls-zig/src/backend/quic.h` must satisfy its acceptance evidence.
- `T03` — `tls-zig/src/quic/events.zig` must satisfy its acceptance evidence.

### Observable acceptance obligations

**T04-01**

- Stimulus: Run send callback with zero, partial and full capacity, then inject failure into each callback during an actual handshake.
- Expected: Only accepted prefix is committed; callback failure becomes terminal; no deferred reference points at temporary callback memory.
- Independent check: Current capability probe is preliminary evidence; use real handshake fault injection for completion.

**T04-02**

- Stimulus: Offer one input buffer, drive provider, and request another before release; deliver both directional secrets.
- Expected: Borrow retained until matching release; at most one provider-held input; exact level/direction preserved for copied secrets.
- Independent check: Poison released memory under instrumentation; compare callback trace to public wrapper events.

These obligations refine the earlier acceptance list; they do not replace it. Capture command, exit status, source/backend identity, actual observed assertions and unresolved cases. No test above is represented as already implemented.

## Lifecycle and evidence

Follow the [completion protocol](../../../completion-protocol.md). Preserve this design card and its acceptance obligations. Add current source documentation separately; completion requires matching source/log/obligation hashes and completed prerequisite evidence.

## Revision 5 provider-boundary evidence

**T04-03**

- Stimulus: Reject a matching input release before retirement, then destroy the provider; separately inject wrong length and a duplicate after successful release.
- Expected: Failed release retains stable custody; matching teardown retry can retire once; invalid or already-retired release cannot double-free or advance input.
- Independent check: Instrument actual wrapper lease/allocation effects and callback order through provider destruction; standalone static probe is supporting evidence only.

[Native diagnostic and its limits](../../../../verification/quic-provider-pair.md). Current source-bound acceptance is recorded in the canonical completion receipt; native platform and full QUIC interoperability gates remain separate.

Reopened during Q00 standards integration: the actual Engine accepted surplus Initial bytes beyond an encryption-level transition. Prior native evidence is retained; source-bound receipts will be refreshed after the new regression and fix.

Reopened for additive records verified-peer leaf digest export: broad source-bound receipts reference the records root/backend closure. Prior level-integrity qualification is preserved; native QUIC implementation is unchanged.
