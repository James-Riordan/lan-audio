# Proof ledger: claims, premises and outstanding obligations

This ledger owns the epistemic status of the engineering claims. "Manual argument"
means reviewable reasoning in prose. "Bounded checked" means TLC or an explicitly
named finite explorer checked a stated configuration. "Tested" means an actual
executable ran in its recorded environment.
None of these labels silently implies the others. There is no TLAPS proof of the
whole application and no established implementation refinement theorem.

| ID / claim | Premises and argument | Current evidence | Missing obligation / next action |
| --- | --- | --- | --- |
| P01 Authenticated generation admission | Serialized Session; host attestation truthful; no epoch wrap. State-action induction in MATHEMATICS section 2. | Existing kernel tests and SessionWindow bounded model/mutations; copied peer policy and generation-bound v2 guard now have synthetic evidence. | Runtime must obtain verified TLS leaf identity, bind it to the controller epoch and propagate revocation before media publication. |
| P02 Window slot uniqueness and at-most-once submission | q lies in K-wide live interval; r monotone; exclusive owner. Injective modulo lemma and insert/tick induction. | Independent window oracle/boundary tests; SessionWindow model. | Host ticks and concealment deadlines; no claim of acoustic exactly-once. |
| P03 Bounded framing and rejection | Validated v1 sizes and bounded v2 kind/count products; nonaliasing input; borrowed Message consumed before reuse. | V1 independent peer; v2 maximum-split/unit checks, independent bounded oracle campaign and fixture-mTLS peer. | Extend beyond finite corpus and integrate actual host owners; runtime must preserve parser borrow/commit boundaries. |
| P04 Sample representation identity | V1 s16 decode is exactly representable; v2 preserves admissible finite binary32 words by integer byte serialization/bitcast. | Exhaustive s16 round trip; v2 representation argument, 131,072 finite patterns and independent byte/peer checks. | Real device integration and broader qualification; resampler/acoustic output have different fidelity properties. |
| P05 Exclusive END drain | Frontier covers all admitted positions; ticks fairly continue; rank e-r decreases. | EndDrain model with three falsifying mutations; receiver cases. | Define downstream ACK frontier and connect it to actual queues/device ownership. |
| P06 SPSC visibility and reuse | One producer/consumer, aligned atomic profile, bounded distance, no reset/move before join, nonoverlapping buffers. | Manual release/acquire argument, SpscPublication abstraction/mutations, threaded FIFO/rollover tests. | No formal Zig weak-memory refinement or numeric worst-case callback timing proof. Review target code generation/ABI when porting. |
| P07 Native storage lifetime | Stable userdata; correct init cleanup; authoritative native callback join; worker joins separately. | Null-device lifecycle cycles, current synchronous native fence/snapshot, source-fault, selected silent endpoint, format and native-event ABI/concurrency tests; controlled API failure cleanup/reconstruction with real null owners; historical Windows capture fixture. | Native Mac SDK/device execution, internal driver partial-failure injection and two-host lifecycle. Copied native discovery now has lifetime/failure tests; stable endpoint IDs remain open. |
| P08 Composed custody/reclamation | RuntimeOwnership count abstraction; every real reference registered in an owner/token; Free after quiescence. | New bounded RuntimeOwnership model and early_free counterexample; manual R1/R2. | C02a/b now implement acquisition/abort and receiver drain with fake-owner evidence; real native/transport composition and refinement remain open. |
| P09 Abort/drain progress | Weak fairness of return, stop, owner exit, Free, timer/deadline; no network fairness. | New bounded temporal check and stop_wait counterexample; manual R3/R4. | Native TCP absolute waits and atomic cancellation now have Windows tests. Full worker cancellation/native termination assumptions remain; eventuality is not a timed bound. |
| P10 Finite outage coverage | Finite arrival burst and service/outage bounds; adequate contiguous playback and source retention. | Algebraic derivation only in quantitative-design Q1/Q2. | Capture actual NIC traces; estimate/test envelope and memory/latency policy. |
| P11 Clock correction stability | Specific ideal discrete PI equations, fixed sample period, no delay/saturation/noise. | Algebraic local Schur-region derivation only in Q3. | Choose/filter controller; analyze delays/clamps; independently simulate then measure devices. |
| P12 Dependency and build identity | Observed files match reviewed hashes; tool/target/runtime loader explicit. | Custody checks and recorded native/cross builds. | Hashes do not establish vendor correctness; Mac private SDK, release provenance and license/distribution gates remain. |
| P13 Source prefix assembly | Single owner; validated immutable format; complete frames; disjoint input; downstream custody before commit; no live reset. | Manual W/P conservation/order argument; independent chunk/EOF/loss/boundary tests and codec/gate composition. | C02c now composes real assembler/queue/gate/controller with source-fault and exact write-custody tests. Real socket workers, physical loss observations and native failure integration remain open. |
| P14 Ordered receive custody and truthful ACK | One authenticated healthy stream; fixed source frame identities; pending/queue/callback prefixes; real host fence; fair positive transfers/return/fences after END. | ReceiveDrain bounded model/four mutations; manual concatenation/rank argument; PendingBlock independent prefix/borrow tests, synchronous fixture-TLS queue composition and [C02b real-controller receiver completion](../runtime/receive-drain.md) with independent frame/owner oracles. | Direct receiver output-fault/ACK gating now has actual controller/bridge tests. Qualify native worker/refinement, callback fences and full native fault mappings. Does not establish acoustic completion or real-time bounds. |
| P15 Partial-acquisition debt and operation isolation | Serialized controller; issued acquisitions retain parents; every real success creates debt; native join and worker exit precede destruction; no token wrap. | [C02a implementation and argument](../runtime/lifecycle-core.md), real-controller independent fake owners, plus earlier Python finite safety/existential reachability and six model counterexamples; original draft defect preserved. | C02b/c receiver/sender completion executes with the same controller; C03 now has source-inspected synchronous fencing and silent-native snapshots. Complete endpoint discovery/identity, failure and async-native mappings. No machine-checked refinement, all-schedule liveness, process-crash, weak-memory or whole-protocol composition proof. |

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

The [verified-channel evidence](../../verification/verified-channel/RESULTS.md)
adds a real native Socket and TLS identity mapping to P03/P09/P12: exact-record
admission, current-error permission/TLS cleanup, repeat/stale controls and independent
peer checks. It does not close P08/P14 native worker/refinement or P10/P11 sustained
timing obligations. Both audio directions are synthetic and physical devices are unopened.

## Foreground live-worker refinement

The [live-worker argument](../runtime/live-workers.md) now maps these owners to
actual threads, queues, copied TLS writes, callback fences and final joins.
Independent null-backend peers and a physical Windows capture/discard check
exercise this implementation. The implementation preserves the single ledger
owner through atomic start/finish publication. Intel Mac native execution,
acoustic completion, long-session drift/jitter and iPhone support remain open;
this evidence does not establish a whole-program proof or production readiness.

## Quiescent session recovery

[Network recovery](../runtime/network-recovery.md) adds a concrete cancellation
handoff and reconstructs each attempt only after actual join/fence/release.
Independent peers and a two-ended ciphertext proxy exercise starvation, backlog,
rejection, disconnect and cancellation. This supports P08/P09 failure recovery;
it does not close the P10/P11 clock, latency or sustained smoothness obligations.

## Bounded operation configuration

[Declarative profiles](../runtime/configuration.md) now separate pure decoding and
resolution from foreground resource acquisition. Duplicate/unknown/null fields,
ambiguous profile names, unsupported versions and unavailable capture selections
reject before opening a device or socket. Independent installed-CLI checks cover
multiple profiles, typed values, resource limits and redacted validation with
nonexistent credential references. A physical Windows run exercises config-relative
credentials from an unrelated working directory and authenticates frame delivery.
These are executed cases, not a proof over every parser input. The command retains
parsed ownership for all retries; credentials are reopened per connection and are
not themselves an immutable store snapshot. Persistent revisions, provenance,
ZSON/host adapters, GUI operations and native Mac execution remain open.


Measured recovery now uses worker-owned publication/receive intervals and bounded
callback-demand observations. Pure tests compare native tick conversion with a
128-bit oracle, preserve timing state on clock regression, constrain reserve across
all admitted budgets and prioritize retry cancellation at deadline expiry. This
improves the evidence behind P09/P10 but does not close independent-clock correction,
physical latency or arbitrary-outage claims. The final starvation gap is censored
by failure detection; it cannot predict the entire outage.

The native backend-entry regression now checks that irregular requests consume
exactly their frame counts without a hidden fixed-size staging tail. Its old-path
failure (17 requested, 240 dequeued) and new-path result are separate evidence.
Worker-side publication/queue frontiers observe nominal playback lead without
reading live callback counters. This improves accounting and retry reserve
selection; it does not constitute independent-clock correction or acoustic drain
proof. The explicit Windows fixture can additionally generate a quiet 1 kHz tone
and require a matching component in received PCM; it saves only aggregate signal
metrics, never captured audio. Its detector is checked against analytic signals.
