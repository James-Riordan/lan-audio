# Decision register before implementation

Statuses: **selected** means an implementer may code the stated contract; **experiment** requires recorded technical evidence before closing the named packages; **owner decision** requires a deployment/repository owner before the stated release action. None of these statuses claims implementation or external approval.

| ID | Status | Decision / resolving work | Package / closure condition |
| --- | --- | --- | --- |
| D01 | selected | QUIC v1/TLS 1.3, first integrated suite AES-128-GCM/SHA-256; reject unsupported required capabilities | T01/Q00: compiling consumer, explicit negative configuration cases |
| D02 | selected | records and recordless owners stay separate; no TLS record tunneling through CRYPTO | T01/T02/Q00: real provider trace and public API separation |
| D03 | selected | one serialized owner; bounded acknowledged events and explicit inbound provider lease | T03/T04: custody model refinement plus actual callback lifetime/failure tests |
| D04 | selected | Fixed copied event storage with reserved control slots; partial/zero CRYPTO acceptance is retryable, failed control/custody callbacks are terminal. Observed callback counts are not a universal provider bound. | T04/T06: actual native faults, bounded queues and both-role Engine conformance; see native Engine evidence below |
| D05 | selected | One exact input lease survives until successful release or provider destruction; failed release permits matching teardown retry. Post-handshake CRYPTO uses normal bounded driving and custody. | T04/T06: actual retained-release cleanup, allowed ticket and forbidden KeyUpdate tests; see native Engine evidence below |
| D06 | selected | processing-time scheduling with explicit cancellation/deadline precedence; no implicit deadline reset | Q06/Q14: exact-time permutation traces in simulator |
| D07 | selected | bounded terminal-prefix reclamation; retained ACK validation with explicit floor; evicted originals have no custody effect | Q04: design retained authenticated metadata, slot reuse, late-original ACK and unsent-ACK tests |
| D08 | selected | actual-send ordinals preserve the deliberate gap-aware packet threshold; pinned independent component traces agree | Q04: dense/sparse traces respecting the RFC pseudocode no-gap assumption; document gap-aware adaptation and history needs |
| D09 | selected | immutable synchronous datagram send plan; ambiguous/partial host result terminates sending on that path | Q08/Q12: would-block/success/failure/duplicate completion and nonce/accounting ledger |
| D10 | experiment | endpoint attribution and amplification credit for failed packets, unknown CIDs and coalesced input | Q13: standards-backed admission decision and spoofed-address/flood traces |
| D11 | experiment | total provider/resource enforcement, native peak allocations and cancellation cleanup | T12/Q13: explicit unknown terms, measured/enforced envelope and admission policy |
| D12 | experiment | loaded runtime identity, ABI/time_t/usize boundaries and native platform support | T07/T09/T13: exact loaded artifact and native LP64/LLP64/consumer evidence |
| D13 | selected | no 0-RTT/resumption/extra versions/HTTP3/DATAGRAM promise in initial target | T01/Q18: unavailable capability and scope documented; extension requires new decision |
| D14 | selected | keep existing APIs/paths/fixture pins; migrate consumers through explicit reviewed deltas | every affected package: package consumer and source/pin audit |
| D15 | owner decision | repository licensing/distribution authorization; third-party notices retained | distribution gate: owner chooses and records authorization; do not invent a license |
| D16 | owner decision | deployment identity, trust rotation, required client authentication and revocation profile | T10/T11/T13 deployment gate: explicit accepted policy and required negative cases |
| D17 | experiment | retry-token rotation/canonical address policy and wall-clock rollback behavior | Q13/Q15: host policy, overlap/restart/spoofing tests; current Retry-only format remains distinct from NEW_TOKEN |
| D18 | selected | completion is evidence-bound lifecycle, not deletion of roadmap prerequisites | every package: schema-2 plan and completion receipt gates; release still has wider gates |

## D08 independent sparse-number oracle

The current helper counts actual subsequently sent packets. RFC 9002 Appendix A.10 uses a packet-number comparison but explicitly assumes there are no sender-induced gaps. Therefore a sparse-number trace is a diagnostic comparison, not proof that the current helper violates the RFC. [RFC 9002 Appendix A.10](https://www.rfc-editor.org/rfc/rfc9002.html#appendix-A.10)

With sent numbers 10 and 20 only, acknowledge 20 while time-based loss is not due. Mechanical packet-number subtraction with threshold 3 would mark 10 eligible; actual-send rank sees only one later packet. The pseudocode assumption is false for this trace. Preserve the current deliberate gap-aware behavior while Q04 documents the chosen adaptation, peer comparisons and retained-history requirements. Also test the dense sequence 10, 11, 12, 13, where both rules reach threshold 3 when 13 is acknowledged. Reclamation must preserve enough sent-rank information to retain whichever policy is selected. This is an independently reasoned test specification, not a newly executed native regression.

## How to resolve an experiment

Record the question, alternatives, precise stimulus, independent expected result, actual source/backend identity, observations and chosen consequence. Link the result from the relevant file card and completion receipt. If results contradict a selected design, update the decision and all affected acceptance cases; do not silently change expected values to match the implementation. Keep failures and narrower capability findings attributed to their actual scope.

## Revision 5: narrower D04/D05 uncertainty

[Seventeen native pair scenarios](../verification/quic-provider-pair.md) passed at O0 and O2 against the locked Windows provider. D04 now has observed both-role/control-callback and input-budget traces; D05 has matching nonempty releases, failure cleanup, directional secret equality and one post-handshake ticket. Both remain experiments: the real event queues, cancellation matrix, adversarial/post-handshake rejection and native wrapper are still absent. Observed callback maxima must not become production capacity constants. D12 loaded-module/platform identity is not closed by copied-DLL hashes.

## Native Engine resolution of D04/D05

The [native Engine evidence](../verification/t02-implementation.md) resolves D04/D05 for the exact Windows x86_64/OpenSSL profile. The real fixed queue accepts only copied CRYPTO prefixes and reserves control custody; callback failure is terminal, while successful zero/partial output is backpressure. Tests inject each callback failure, reject excess input counts, retain failed releases through SSL_free, compare four directional secrets and cancel at every borrowed event in both roles. Delayed permitted tickets make bounded local progress after readiness; forbidden KeyUpdate terminates without a second completion or plaintext delivery.

This selects observable failure/custody behavior, not a universal maximum callbacks-per-call, provider heap bound or call-duration bound. D11 resource measurements/enforcement and D12 other-platform/loaded-module qualification remain open. The revision-5 observations above remain historical evidence of the earlier uncertainty.

## Q04 resolution of D07/D08

[Coordinated recovery](../verification/q04-implementation.md) records the selected bounded horizon and actual-send-ordinal policy. Fifteen dense/sparse traces execute unmodified pinned quic-go history; local tests additionally cover large gaps, late original ACKs, retained holes and thousand-cycle reclamation. This comparison is component-level evidence, not independent endpoint interoperability. [Decision 0005](../architecture/decisions/0005-recovery-spaces.md) defines the tradeoffs and host obligations.
