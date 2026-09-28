# Acceptance traceability and evidence rules

The [product contract](../PRODUCT.md) owns A1–A10. This table maps them to work,
tests and evidence. “Partial” means an existing component contributes; no row
becomes complete merely because this document exists.

| ID / present status | Responsible work | Required independent check / evidence |
| --- | --- | --- |
| A1 two-host audio — open | WP01,03,04,08 | Actual Windows source and Intel Mac output; selected endpoint IDs, binary hashes, negotiated format and observed sound; stop/restart trace. |
| A2 authorization — partial fixture tests | WP03,04,08 | Wrong name/key/CA/role, trusted-but-unauthorized certificate, changed identity, expired identity, no media before approval, no plaintext fallback. |
| A3 bounded media — partial core/models | WP02,04,05 | V1 regressions; v2 independent codec/fuzz/state tests, buffer limits, exact frame ranges, late/duplicate/overflow/end behavior and composed runtime model. |
| A4 lifecycle — partial null/native and C02a/b fake-owner tests | WP03–05,08 | Acquisition-failure matrix, cancellation at every state, full/empty queues, joins, stale-generation rejection, hotplug/sleep/wake and repeated restart. |
| A5 timing/resources — open | WP05–07,10 | ≥30-minute qualified profile run; valid latency population/uncertainty, drift and occupancy, CPU/memory, device/network errors and no unbounded growth. |
| A6 installation — open | WP01,08–10 | Clean Windows/Intel Mac launch, private runtimes, settings migration, stop/uninstall/rollback and declared OS support. |
| A7 reproducibility — partial local receipts | all | Source/compiler/dependency custody, commands/return codes, seeds, raw failures and target identity; independent clean-tree reproduction. |
| A8 fidelity — partial independent v2 qualification | WP02,05,10 | Codec bit-pattern/differential tests and independent fixture peers now exist; still require bitwise real capture-to-decoder equality, native integration, named conversions, and rate-correction/clipping/headroom evidence. |
| A9 faulty-adapter resilience — open | WP06,07,10 | Measured adapter trace and deterministic replay; declared loss/jitter/outage/rate envelope, useful recovery and honest degraded-output counters. |
| A10 efficiency — open | WP05–07,10 | Named copy/allocation boundaries, CPU/tail latency, memory limits and framing/repair bandwidth; comparisons on identical workloads. |

## Evidence schema for each run

The [independent v2 phase](../../verification/v2-independent/RESULTS.md) contributes
bounded protocol evidence to A2/A3/A7/A8 and pure capture assembly checks to A3.
It does not complete any whole-product row or establish native Mac playback.

The [runtime design phase](../../verification/runtime-blueprint/RESULTS.md) adds a
bounded frame-identity/drain model contributing to A3/A4 and the planned
[runtime test obligations](runtime-obligations.md). These tests are not implemented
merely because their stimuli and independent oracles are specified.

Record `run_id`, UTC/local timestamps, source/package hashes, target/OS/driver,
compiler/SDK/runtime hashes, selected device and negotiated application/native
formats, scenario parameters/seed, command and working directory, environment
overrides, return code, duration, observed metrics, limits and artifact hashes.
Private keys/raw audio are excluded. Expected negative-case errors must have an
explicit oracle and no success marker. A skipped/unavailable host is neither pass
nor fail of a run that never executed; mark it blocked/unexecuted.

Historical evidence is immutable. New relocation evidence establishes build/model
and integration behavior at the new paths; it does not reproduce past hardware
measurements. Documentation-only changes do not require replaying physical capture.
Measure after substantive runtime changes and preserve both failure and repair.

## Release review

Every claim in a release note must identify a supporting artifact or be marked
planned/limited. Verify source versus recorded hashes and all dependency locks.
Accept bounded-model results only for their exact specs/configuration and fairness
assumptions. Review the independent oracle and falsifying mutations, not merely
the count of green tests. A test named “robust” is not a robustness argument.
