# Planned `tests/quic_contract.zig`

Status: **complete**. Milestone T1. Exact completion prerequisites are below. This is a design card, not a source stub or an exported capability.

## Responsibility and boundary

Adversarial conformance tests for the chosen QUIC boundary.

## Invariants, data ownership and errors

Test provider and host independently; expected event traces authored separately from implementation.

Define input/output ownership, capacity units and failure atomicity in the first implementation. Refuse unsupported capability before accepting application work. Make terminal cleanup idempotent without treating protocol sends or application requests as generally retryable.

## Construction sequence

1. Read the existing relevant file contracts and [integration contract](../../../contracts/quic-tls.md). Resolve public types and caller/provider responsibilities.
2. Author independent positive and negative oracles for the acceptance cases below. Add a minimal compiling implementation behind explicit capability selection.
3. Connect the owning build and external consumer. Keep this design card, update its lifecycle status, and add a separate source-bound contract when the file exists.
4. Run both supported native build modes and the relevant model/interop/fuzz profile; record actual outcome and remaining limits.

## Acceptance cases

Zero/partial/overconsumption; recordless-only capability; fatal alert; repeated ack; no premature completion.

Completion requires all cases to have observable assertions, a bounded failure path and source-bound evidence. A successful happy-path demo alone does not close this card.

## Exact work package T06

Authority: [implementation plan](../../implementation-plan.json). Milestone labels group work; the following edges govern completion order. Tests can be authored earlier.

- `T02` — `tls-zig/src/quic/engine.zig` must satisfy its acceptance evidence.

### Observable acceptance obligations

**T06-01**

- Stimulus: Exercise zero/partial/excess input consumption and reordered/duplicated acknowledgements against independent host/provider fixtures.
- Expected: Overconsumption poisons owner; valid retry preserves bytes; stale acknowledgement never retires another event.
- Independent check: Expected event traces authored independently; compare with bounded custody model.

**T06-02**

- Stimulus: Run real client/server recordless handshake with bad identity, ALPN, parameters and fatal alert.
- Expected: Negative policy denies readiness; both success roles finish with correct directional traffic keys.
- Independent check: Use independently configured peer identity and packet decrypt check; symbol/ClientHello probes cannot satisfy this case.

These obligations refine the earlier acceptance list; they do not replace it. Capture command, exit status, source/backend identity, actual observed assertions and unresolved cases. No test above is represented as already implemented.

## Lifecycle and evidence

Follow the [completion protocol](../../completion-protocol.md). Preserve this design card and its acceptance obligations. Add current source documentation separately; completion requires matching source/log/obligation hashes and completed prerequisite evidence.

## Revision 5 provider-boundary evidence

**T06-03**

- Stimulus: Queue one-byte fragments beyond a per-drive input budget, then process permitted and forbidden post-handshake CRYPTO after local completion.
- Expected: Budget exhaustion defers local work without EOF or starvation; allowed post-handshake bytes obey normal custody; forbidden input fails without application plaintext delivery.
- Independent check: Compare scheduler wakeups, byte retirement and public events to an independently specified trace; retain malformed-input and cancellation results.

[Native diagnostic and its limits](../../../verification/quic-provider-pair.md). Current source-bound acceptance is recorded in the canonical completion receipt; native platform and full QUIC interoperability gates remain separate.

Reopened during Q00 standards integration: the actual Engine accepted surplus Initial bytes beyond an encryption-level transition. Prior native evidence is retained; source-bound receipts will be refreshed after the new regression and fix.

Reopened for additive records verified-peer leaf digest export: broad source-bound receipts reference the records root/backend closure. Prior level-integrity qualification is preserved; native QUIC implementation is unchanged.
