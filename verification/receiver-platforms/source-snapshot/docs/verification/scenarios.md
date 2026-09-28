# Qualification scenarios and oracles

Numbers below are experiment inputs, not promised recoverability or user-approved
latency. Use deterministic seeds and virtual time for simulation; physical runs
record measured conditions. Each scenario reports its complete accounting even
when output cannot remain uninterrupted.

| Scenario | Stimulus | Oracle and stop criterion |
| --- | --- | --- |
| F01 representation | ±0, finite extrema, subnormal boundaries, seeded f32 patterns | Decoded pre-resampler u32 bit patterns equal originals; NaN/Inf rejected without partial publication. |
| F02 framing | Every byte split, coalesced maximum records, oversized/truncated/unknown fields | Exact consumed prefix, bounded storage, poisoned state on invalid record; no hangs or out-of-bounds writes. |
| L01 stage failure | Fail each context/socket/TLS/device/thread acquisition in turn | Only acquired resources freed, exactly once; no callbacks touch reclaimed memory. |
| L02 cancellation | Connect, handshake, prime, send/read stall, full queues, drain | Owner wakes, respects deadline, joins, then reclaims; no stale playback on next stream. |
| L03 device change | Selected endpoint vanishes, default changes, permission refusal, sleep/wake | Typed visible error or explicit re-selection; no silent switch and no fabricated successful frames. |
| N01 jitter | Seeded 0–5, 0–20, 0–100 ms variations and correlated bursts | Original timeline plus chosen buffer budget predicts deadlines; measured misses match independent ledger. |
| N02 loss | 0%, 0.1%, 1%, 5% random loss, then bursts of 1/5/20 packets | Recover only original authenticated bytes before deadline; count unrecovered/degraded media exactly. TCP and datagram semantics modeled separately. |
| N03 outage | No useful delivery for 20/100/500/2000 ms | Conservation bound predicts impossible cases; bounded rebuffer/abort outside budget and clean recovery/new generation. |
| N04 service rate | Usable service at 0.5/0.9/1.1/2× media rate, with contention | No unbounded backlog; catch-up only when service exceeds generation; congestion/repair overhead counted. |
| N05 disconnect | Peer exit, half-close, raw EOF, adapter reconnect | Distinguish authenticated END/close from truncation; deadlines persist despite partial progress. |
| C01 clocks | ±10/50/100/500 ppm constant and changing rate errors | Bounded ratio/occupancy for declared supported range; correct control sign; explicit failure outside range. |
| C02 timing faults | Backward/large-jump timestamps, sparse observations, jitter-only variation | Reject/reset invalid time mapping without numeric overflow or estimator windup; do not invent one-way delay. |
| P01 efficiency | Fixed workload/profile, increasing CPU contention and telemetry load | Allocation/copy counts and latency distributions at named boundaries; no callback lock/I/O/allocation introduced. |
| S01 authorization | Wrong name, CA, key, role, identity-store corruption, stale stream | No media admission; stable typed failure; secret-redacted diagnostics and no downgrade. |
| R01 release | Clean hosts, path spaces/non-ASCII, missing/wrong DLL/dylib, update rollback | Exact runtime loading, useful failure, preserved settings, no global dependency side effects. |

## Observed-adapter scenarios

After the Windows adapter is characterized, add its actual traces to the manifest
with time domains, capture method, redactions and loss/event-counter limitations.
Do not call synthetic random loss equivalent to that adapter's failure. Distinguish
OS/DPC scheduling stalls, capture callback gaps and network arrivals; repairing
network packets cannot recreate a sample the source never captured.

## Replay and interpretation

Use an independent source ledger indexed by generation and frame range. Track
in-flight, buffered, delivered, discarded and concealed sets. Duplicates may arrive
but may not render twice. A reconnect clears old ranges. Compare simulated results
with analytic bounds and at least one separately implemented scheduler/oracle for
critical algorithms. When a fault is found, minimize and preserve its trace rather
than only adding its seed to a huge opaque test run.

For listening tests, disclose whether the test signal, OS mixer or resampler alters
the original waveform. For latency, disclose reference clocks and uncertainty.
Human listening, exact digital comparison and formal model checks answer different
questions; report each under its own claim.
