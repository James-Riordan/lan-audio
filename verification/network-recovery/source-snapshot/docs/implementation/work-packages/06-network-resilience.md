# WP06 — Measured resilience to the actual network adapter

Status: planned. Depends on WP04–05 and WP07 baseline counters. Acceptance: A5/A9/A10.

| Planned file | Responsibility / independent check |
| --- | --- |
| `tests/simulation/network_path.zig` | Seeded packet/byte arrival events, loss bursts, rate limits and outages; separate transport semantics from media clocks. |
| `tests/simulation/resilience.zig` | Replay recovery deadlines against an independent original-sample ledger; report missing/late/concealed ranges. |
| `src/runtime/recovery_policy.zig` | Bounded rebuffer/reconnect/abort decisions, resource and traffic budgets; no implicit sample-quality downgrade. |
| `src/media/buffer_policy.zig` | Select target prefill within user latency/memory budget using measured conditions; bounded slew and hysteresis. |
| `tools/replay_impairment.py` | Read documented traces, run deterministic scenarios and emit metrics plus seed/source identities; no network adapter reconfiguration as a hidden side effect. |

First characterize the actual Windows adapter: driver, link type/rate, loss bursts,
stall durations, effective throughput, host scheduling and concurrent load. Distinguish
capture gaps caused by host stalls from network delivery failures. Preserve raw
measurement provenance without storing user audio. Do not disable security, firewall
or power settings as an undocumented test workaround.

Measure the TLS/TCP baseline across loss/jitter/stalls. Test selectable buffering
budgets and evaluate source fidelity, missed deadlines, recovery bandwidth and
tail latency. Use M03's service-rate/catch-up conditions to explain failures. Prefer
retaining sample information within the permitted latency budget; beyond the
envelope, report degraded/rebuffering state honestly.

Only if evidence justifies it, introduce a separately reviewed datagram transport
under `src/host/net/` and its own protocol version. Use an established authenticated
transport implementation; the local QUIC candidate is not a complete engine.
Specify packet MTU, congestion control, replay window, loss detection, deadline-aware
repair, bounded retained data and parity budget before implementation. FEC cannot
be bolted onto encrypted TCP records or used to amplify already congested traffic.
Compare approaches on identical replay traces and real hardware. A datagram choice
creates a new dependency/attack-surface qualification package, not a one-line switch.

Exit: publish a measured operating envelope and results outside it; recovered sample
values match originals, no concealed block is counted as successful recovery, and
reconnect does not replay an old generation. Universal immunity to faulty hardware
is explicitly not an acceptance claim.
