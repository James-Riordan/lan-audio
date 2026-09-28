# Resource, counter and scheduling budget contract

Status: required design for T03/T04/T12 and Q04/Q06/Q11/Q13. Numbers below describe units and relations, not measured production defaults. Every exposed limit needs validation, an exhaustion outcome and a test at zero/minimum/exact-boundary/one-past-boundary. Do not claim a total connection bound while provider allocation is unbounded.

## Capacity owners

| Symbol | Unit / owner | Validation or coupling | Exhaustion behavior |
| --- | --- | --- | --- |
| B_crypto_in[level] | retained CRYPTO bytes / QUIC reassembly | checked max offset plus length; current lifetime storage does not reclaim after read | explicit buffer-limit outcome; never wrap or silently forget overlap history |
| B_crypto_out[level] | retransmittable CRYPTO bytes / QUIC sender | copy before TLS event acknowledgement | pause outbound-byte consumption; declared terminal path if progress cannot be serviced within deadline |
| P_history[space] | retained packet entries / recovery | packet numbers and byte-range custody remain independently tracked | do not reuse slots until ACK validation/reclamation policy is proved |
| E_bytes | TLS output-event slots / event owner | slot descriptor and payload byte budgets checked independently | nonfatal send-prefix backpressure where provider permits it |
| E_control | secret/parameter/alert slots / callback adapter | reserve before provider entry; account multiple callbacks in one call | explicit terminal capacity error if no safe pause exists; never report callback success after dropping data |
| B_tls_lease | accepted inbound bytes / TLS adapter | at most one provider-held nonempty lease; release only on matching callback or safe provider destruction | zero accepted prefix when full; preserve QUIC-owned suffix |
| B_parameters | transport-parameter bytes / owner | parse count/length and role/CID rules; negotiated peer limits do not expand local memory automatically | reject excess before copy/commit |
| S_active | active stream objects / connection | direction/role and negotiated stream count; closed-stream metadata retention separately bounded | refuse local creation or apply defined peer violation rule |
| B_stream / B_connection | stream and aggregate receive custody | sparse offsets charge flow-control high-water marks, not just stored bytes | no credit increase without application consumption policy; reject over-limit semantics atomically |
| N_active / N_pending | admitted and handshaking owners / endpoint | endpoint memory/work budget and per-peer admission | reject/defer new admission before expensive provider allocation |
| W_turn | work units / scheduler turn | count provider calls, parser candidate work and emitted callbacks separately | yield with exact readiness/deadline; do not busy-loop on zero progress |
| G_owner / G_event | identifier generations / owner registry | checked finite-width increase, no reuse while stale handles can exist | stop before wrap; never alias stale owner/event IDs |

Current records TLS arrays include two 32 KiB BIO buffers, a 16 KiB pending-write block and Driver's additional queues. They do not include all SSL/SSL_CTX/certificate/provider allocation. Existing QUIC helpers have compile-time bounded storage with lifetime limitations. These facts do not select endpoint admission counts or recordless defaults.

## Accounting model

For a declared profile, express application-controlled connection storage as

`M_owned <= M_fixed + sum_level(B_crypto_in + B_crypto_out + B_tls_lease) + sum_space(P_history * packet_metadata_size) + event_descriptors + event_payload_storage + stream_metadata + stream_payload_storage`.

Do not double-count a shared payload allocation referenced by multiple descriptors. Conversely, borrowed pointers do not eliminate the memory owned by the supplying component. Total process peak additionally includes provider memory, allocator overhead, transient copies, thread stacks, endpoint tables and OS socket buffers. Record each measured category or explicitly unknown term.

With known per-owner upper bound M_owner and endpoint reserve M_endpoint, a candidate admission count must satisfy `N * M_owner + M_endpoint <= configured_process_budget`. This is a validation relation, not a usable total-memory guarantee until M_owner includes the provider and transient peaks. If hard provider enforcement is unavailable, say measured/observed envelope and apply conservative admission/rate limits; do not rename it a hard cap.

## Counter and time rules

Represent packet numbers, byte offsets, cumulative flow-control use and event generations with explicitly bounded unsigned domains; validate before addition/subtraction. A packet-number/key pair must never repeat. Reclaimed storage slots are not permission to reset counters. Lifetime metadata and overflow are separate decisions from physical ring-buffer reuse.

The adapter owns unit conversion. Reduce monotonic deadline precision toward earlier wakeup; checked multiplication must reject overflow. Certificate Unix time is not a progress clock. A clock rollback is a host contract failure; no subtraction underflow or timeout extension. Test exactly before/at/after deadline, conversion remainder, maximum representable timestamp and cancellation at each blocked boundary.

## Reclamation decision still required

P_history reclamation must specify what ACKs for discarded metadata mean, how late originals interact with retransmitted byte ranges, and which authenticated number information remains available to reject unsent claims. Reusing lifetime slots without that design invalidates existing sender/recovery contracts. Resolve D07 before closing Q04; retain the current bounded-failure behavior until replacement evidence exists.

## Measurement receipt

Record compiler/backend/OS/CPU/allocator, configured capacities, role, chain size, input fragmentation, packet loss/reorder seed, active connections, warmup and sample count. Report peak/high-percentile latency and memory, rejection-path work, cancellation cleanup and steady-state retention separately. Include resource failure at each allocation ordinal and repeated construct/cancel cycles. Never suppress identity checks to improve benchmark results.

T12 owns provider/resource instrumentation; Q13 owns admission/fairness; benchmarks T14/Q21 report the measured envelope. A test that only reaches the happy path with one connection does not satisfy this contract.

## Q04 coordinated history qualification

The original bounded Initial helper retains its prior behavior. The separate recovery_spaces owner resolves D07 for three fixed packet histories: only terminal/non-flight prefix entries may be reclaimed, advancing an exclusive ACK-validation floor. Claims at or above the floor must name retained successful sends; older portions have no effect. Reclaimed originals cannot retire frame custody, which remains with the host and its retained retransmissions. Capacity exhaustion while the oldest entry is active flight returns ResourceLimit without mutation. Successful-send ordinals and packet-number high-water marks survive reclamation and Retry.

Storage is three capacity-sized packet arrays plus copied outcome batches of at most three times capacity, with bounded scans and no allocation inside the owner. Returned batches and transient stack copies must be included in the host envelope; no provider or whole-connection memory cap is inferred. [Q04 evidence](../verification/q04-implementation.md) records exact boundary, late-ACK, thousand-cycle and cancellation tests.
