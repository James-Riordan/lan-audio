# WP10 — Product acceptance and supported envelope

Status: planned. Depends on WP01–09. Acceptance: all A1–A10 with explicit limits.

Read the acceptance matrix and scenario definitions. Establish the user's approved
latency profile and the actual adapter/Mac test environment. Record exact hardware,
OS/driver/SDK/compiler, link topology, selected endpoint formats, package hashes,
power/CPU conditions, measurement tools and uncertainty. Include normal playback,
background load and the specific semi-faulty adapter behavior.

Run at least the product's 30-minute steady-state obligation at each claimed
profile, plus fault/recovery scenarios. Longer soak and repetitions may be necessary
to justify the published envelope; no duration is a universal proof. Compute p50,
p95, p99 and worst observed latency only from a named valid population. Count source
gaps, unrecovered media, concealment, disconnects and telemetry loss separately.

Inject/replay loss bursts, jitter, reordering, stalled transfer, bounded throughput,
device unplug/default changes, sleep/wake, peer termination and active start-stop-
restart. Validate stale generations never render and each worker/device/socket is
reclaimed. Outside the supported envelope, the product must degrade/rebuffer/stop
truthfully and recover according to policy, not deadlock or grow memory indefinitely.

Perform fidelity comparison at the declared capture/decoder boundary. Qualify
resampling/audio output separately. For acoustic latency, use calibrated shared
measurement or an appropriate loopback method, not unsynchronized timestamp
subtraction. Check packaging and authorization failures on clean targets.

Create a new `verification/release-<id>/` evidence set with machine-readable status,
commands, results, data provenance, source/package hashes and limitations. Add a
human release report that maps each A ID to evidence. Do not copy old PASS labels
onto new versions; do not count expected negative-case failures as product faults
or unexpected crashes as correct rejection. Retain unsuccessful attempts.

Exit: all claimed acceptance rows have fresh evidence, unresolved blockers are
visible, supported profiles and the recoverable fault envelope are stated, and a
new user can reproduce installation and normal operation. Any row intentionally
deferred is an explicit alpha limitation, not a 10/10 release claim.
