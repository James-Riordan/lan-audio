# Proof ledger: claims, premises and outstanding obligations

This ledger owns the epistemic status of the engineering claims. "Manual argument"
means reviewable reasoning in prose. "Bounded checked" means TLC or an explicitly
named finite explorer checked a stated configuration. "Tested" means an actual
executable ran in its recorded environment.
None of these labels silently implies the others. There is no TLAPS proof of the
whole application and no established implementation refinement theorem.

| ID / claim | Premises and argument | Current evidence | Missing obligation / next action |
| --- | --- | --- | --- |
| P01 Authenticated generation admission | Serialized Session; host attestation truthful; no epoch wrap. State-action induction in MATHEMATICS section 2. | Existing kernel tests and SessionWindow bounded model/mutations. | Runtime must bind remote identity/format to local epoch and serialize stop/admission. |
| P02 Window slot uniqueness and at-most-once submission | q lies in K-wide live interval; r monotone; exclusive owner. Injective modulo lemma and insert/tick induction. | Independent window oracle/boundary tests; SessionWindow model. | Host ticks and concealment deadlines; no claim of acoustic exactly-once. |
| P03 Bounded framing and rejection | Validated v1 sizes and bounded v2 kind/count products; nonaliasing input; borrowed Message consumed before reuse. | V1 independent peer; v2 maximum-split/unit checks, independent bounded oracle campaign and fixture-mTLS peer. | Extend beyond finite corpus and integrate actual host owners; runtime must preserve parser borrow/commit boundaries. |
| P04 Sample representation identity | V1 s16 decode is exactly representable; v2 preserves admissible finite binary32 words by integer byte serialization/bitcast. | Exhaustive s16 round trip; v2 representation argument, 131,072 finite patterns and independent byte/peer checks. | Real device integration and broader qualification; resampler/acoustic output have different fidelity properties. |
| P05 Exclusive END drain | Frontier covers all admitted positions; ticks fairly continue; rank e-r decreases. | EndDrain model with three falsifying mutations; receiver cases. | Define downstream ACK frontier and connect it to actual queues/device ownership. |
| P06 SPSC visibility and reuse | One producer/consumer, aligned atomic profile, bounded distance, no reset/move before join, nonoverlapping buffers. | Manual release/acquire argument, SpscPublication abstraction/mutations, threaded FIFO/rollover tests. | No formal Zig weak-memory refinement or numeric worst-case callback timing proof. Review target code generation/ABI when porting. |
| P07 Native storage lifetime | Stable userdata; correct init cleanup; authoritative native callback join; worker joins separately. | Null-device lifecycle cycles; historical Windows capture fixture. | Native Mac SDK/device execution, partial-failure injection and two-host lifecycle. |
| P08 Composed custody/reclamation | RuntimeOwnership count abstraction; every real reference registered in an owner/token; Free after quiescence. | New bounded RuntimeOwnership model and early_free counterexample; manual R1/R2. | C02a/b now implement acquisition/abort and receiver drain with fake-owner evidence; real native/transport composition and refinement remain open. |
| P09 Abort/drain progress | Weak fairness of return, stop, owner exit, Free, timer/deadline; no network fairness. | New bounded temporal check and stop_wait counterexample; manual R3/R4. | Interruptible real waits, cancellation wakeups and native termination assumptions; eventuality is not a timed bound. |
| P10 Finite outage coverage | Finite arrival burst and service/outage bounds; adequate contiguous playback and source retention. | Algebraic derivation only in quantitative-design Q1/Q2. | Capture actual NIC traces; estimate/test envelope and memory/latency policy. |
| P11 Clock correction stability | Specific ideal discrete PI equations, fixed sample period, no delay/saturation/noise. | Algebraic local Schur-region derivation only in Q3. | Choose/filter controller; analyze delays/clamps; independently simulate then measure devices. |
| P12 Dependency and build identity | Observed files match reviewed hashes; tool/target/runtime loader explicit. | Custody checks and recorded native/cross builds. | Hashes do not establish vendor correctness; Mac private SDK, release provenance and license/distribution gates remain. |
| P13 Source prefix assembly | Single owner; validated immutable format; complete frames; disjoint input; downstream custody before commit; no live reset. | Manual W/P conservation/order argument; independent chunk/EOF/loss/boundary tests and codec/gate composition. | Actual capture-queue overrun observations, worker cancellation and transport commit/join integration remain WP04 work. |
| P14 Ordered receive custody and truthful ACK | One authenticated healthy stream; fixed source frame identities; pending/queue/callback prefixes; real host fence; fair positive transfers/return/fences after END. | ReceiveDrain bounded model/four mutations; manual concatenation/rank argument; PendingBlock independent prefix/borrow tests, synchronous fixture-TLS queue composition and [C02b real-controller receiver completion](../runtime/receive-drain.md) with independent frame/owner oracles. | Qualify native worker/refinement and callback fence; complete sender composition and fault snapshots. Does not establish acoustic completion or real-time bounds. |
| P15 Partial-acquisition debt and operation isolation | Serialized controller; issued acquisitions retain parents; every real success creates debt; native join and worker exit precede destruction; no token wrap. | [C02a implementation and argument](../runtime/lifecycle-core.md), real-controller independent fake owners, plus earlier Python finite safety/existential reachability and six model counterexamples; original draft defect preserved. | C02b receiver graceful composition now executes with the same controller; complete sender outcomes and C03 truthful native mappings. No machine-checked refinement, all-schedule liveness, process-crash, weak-memory or whole-protocol composition proof. |

Canonical arguments: [kernel mathematics](../MATHEMATICS.md),
[stream explanation](stream-argument.md), [runtime model argument](runtime-argument.md),
[quantitative derivations](quantitative-design.md). Exact prior runs are in
[structure verification](../../verification/handoff/RESULTS.md) and
[this model/document revision](../../verification/literate-specification/RESULTS.md).
The subsequent [fidelity-core revision](../../verification/fidelity-core/RESULTS.md)
provides current pure v2 test evidence; it adds no new device or TLS-peer result.
The later [independent v2/assembly revision](../../verification/v2-independent/RESULTS.md)
adds fixture TLS application peers, bounded differential evidence and assembly tests,
but no real device or native Mac execution.
The former remains historical when current documentation or runner hashes change.

The [runtime design revision](../../verification/runtime-blueprint/RESULTS.md)
adds P14 and concrete implementation/test contracts. It does not add product
commands, native Mac execution or a whole-system refinement proof.

## Proof work cannot be replaced by repeated assertions

To close a missing obligation, identify a specific claim and its quantifiers;
state the representation/refinement relation and environmental premises; establish
initialization and preservation or a decreasing rank/fairness argument; execute
independent checks where appropriate; record counterexamples and scope. For a
computer-checked theorem, commit the actual proof and reproducible checker result.
Writing "must be correct", increasing prose volume, or deriving checks from the
same incorrect implementation does not satisfy the obligation.
