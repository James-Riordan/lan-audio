# Conversion handoff: files, decisions and order of work

Status: preparation for application WP05/C08, not an implemented resampling path.
The current non-resampled application receive path remains authoritative. The
binding's Q01 ABI work is independent of this DSP qualification. Start with
[control limitations](../contracts/conversion-control.md): the adopted generic
ratio helper loses small corrections, and large reduced denominators can overflow
phase remapping. Neither is fixed by this document.

## Ownership and the canonical future layout

LAN Audio owns all runtime files below. Paths are relative to `lan-audio/` and
match its `docs/implementation/work-packages/05-timing-clocks.md`. In particular,
the native adapter belongs at `src/host/resampler.zig`, not `src/media/resampler.zig`.
The pure media layer must not import native audio. These are planned files: create
each with its first caller and tests, not as empty scaffolding. Inspect the actual
application inventory before creating one; retain an existing compatible owner.

| File | First caller / responsibility | Contract and failure behavior | Independent exit evidence |
| --- | --- | --- | --- |
| `src/media/playout_clock.zig` | Playout worker maps source positions into one local output-time generation. | Explicit frame domains and checked arithmetic; epoch change invalidates old maps. No cross-host timestamp subtraction; output silence advances the physical schedule without pretending source media was copied. | Analytic fixed-rate maps, wrap/overflow rejection, timestamp jumps, underrun/new-map cases. |
| `src/media/prefill.zig` | Receiver worker decides when contiguous playable coverage is sufficient. | Count ready source coverage and queued output separately. States priming/running/rebuffering/terminal; memory and latency bounds apply in every state. A source hole or unavailable converter input is not ready output. | Holes, tiny queue, restart, EOF below threshold, cancellation and independent coverage arithmetic. |
| `src/media/clock_estimator.zig` | Controller receives timestamp/frame observations from a safely published snapshot. | Observations carry generation, monotonic time units, frame domain and uncertainty. Estimate rate and confidence; duplicate/decreasing/old-generation points cannot silently train the filter. No unsynchronized read of callback-owned totals. | Known positive/negative drift, no drift with arrival jitter, quantized times, missing points, discontinuities. |
| `src/media/drift_controller.zig` | Playout worker requests a bounded consumed-source/output ratio. | Specify update order, elapsed-time handling, filter delay, ratio/slew limits and anti-windup. Separate requested from represented/applied ratio. Freeze or back-calculate using the actual actuator rule; never integrate a fictitious correction. | Delayed/quantized plant simulation, both signs, saturation and recovery, reversed-sign mutation, deterministic seed replay. |
| `src/host/resampler.zig` | The single playout worker owns native conversion and its buffers. | Stable native address; checked disjoint spans; actual consumed/produced counts; explicit partial-output custody and tail state; typed fault plus original result. Do not expose upstream mutable internals to controller/UI. | Scripted fake seam plus adopted-native integration; tiny spans, zero progress, invalid samples, faults, finite tail, applied-rate precision and phase continuity. |
| `tests/simulation/clock_drift.zig` | Pure test runner and tuning experiments. | Independently model source clock, render clock and arrival disturbances; record all seeds, units, controller cadence, quantizer, delays and bounds. It must not call the production controller to calculate its expected plant evolution. | Analytic constant-rate conservation and sign checks; reject divergent, nonfinite or out-of-bounds trajectories rather than hiding them by clamping observations. |
| `tests/integration/resampler.zig` | Native test runner, never an audible demo. | Exercise exported miniaudio module and actual chosen adapter. Keep C-profile/compiler/source identity and quality configuration in results. Separate functional tests, deliberate defect reproduction and quality qualification. | Matrix in [conversion verification](../verification/conversion.md), including empty/short streams and transitions across equal rates. |

Supporting files become justified with the corresponding implementation:

| Planned addition | Granular contract |
| --- | --- |
| `tests/unit/media/{playout_clock,prefill,clock_estimator,drift_controller}.zig` | One pure test file per real owner, following the application's existing runner conventions. Hand-worked expected values, range/error cases and seeded traces; no duplicate private controller. |
| `tests/unit/host/resampler_contract.zig` | Proposed fake-native seam test. Inject each init/process/rate/terminal failure and arbitrary legal partial counts. Prove no suffix is lost, output is not republished, and failed native state is never resumed. Reuse an existing host test harness if it can express these operations. |
| `tests/fixtures/resampler/manifest.json` | Proposed manifest for reproducible independent vectors: generator/source identity, rate/phase/channel convention, valid comparison region, expected metrics, tolerances and rationale, hashes. Every stored binary has an explicit frame format/byte order/length; reject missing or stale data. |
| `tools/generate_resampler_fixtures.py` | Proposed offline oracle generator, only if fixtures need generation. Pin its actual dependencies and parameters; never call miniaudio to manufacture the expected numerical output. Normal verification reads the committed manifest; regeneration requires deliberate review. |
| `verification/<new-conversion-phase>/` | New immutable observation directory: commands, source and fixture hashes, target/compiler, logs, metrics, failures, limitations. No overwrite of Q01 or application C01 evidence. |

No converter class, scheduler, UI or product configuration belongs in this thin
binding. It supplies the raw adopted C surface and dependency-specific constraints.
There is no justification yet for a new general-purpose DSP package.

## Decisions that must exist before production activation

An implementer can build isolated tests while these are open. Production adaptive
playback is blocked until the relevant decision has evidence and an application
record. Proposed choices below are experiments, not user-approved quality targets.

| ID | Current status / owner | Concrete record required to close |
| --- | --- | --- |
| R01 Native control path | Blocked / host adapter | Resolve the generic helper quantization and phase-remapping overflow in the adopted source. Compare a demonstrably safe bounded integer-rate profile, a reviewed source fix/adoption, or another backend; measure represented and applied precision. |
| R02 Algorithm and format | Open / host adapter + product fidelity | f32 stereo is the current application path. Evaluate stock linear resampling with explicit filter order first; record why measured alias/passband/transition behavior is sufficient, or reject it. Data conversion must not silently add channel mixing, clipping or a second resampler. |
| R03 Actuator envelope | Open / controller | Actual rate interval, update cadence, ratio quantization/error, slew and phase bounds. Include rate crossings and failures, not merely successful setter return values. |
| R04 Quality envelope | Open / product qualification | Passband, stopband/alias rejection, amplitude/headroom and allowed transition residual, with units and independent oracle. No invented dB threshold in this dependency handbook. |
| R05 END and ACK | Open / protocol + runtime | Finite terminal recipe and deadline, declared residual/truncation, source/output ledger, and compatible acknowledgement meaning. The existing source-frame copy frontier cannot be reused by multiplying an output count by a ratio. |
| R06 Underrun/rebuffer | Open / scheduler | Define mapping invalidation, source ranges discarded and audible silence; choose whether held history survives each recovery. A new generation may be required; never silently reset a live converter. |
| R07 Memory and service | Open / worker + target qualification | Maximum source/output staging, native heap, queue capacity and work per scheduling turn; measured worst observed service plus stated unproven worst-case limits. |
| R08 Native target scope | Open / release qualification | Real Windows and Intel Mac results, output path configuration and at least the application's required 30-minute drift traces. An unavailable Mac remains an explicit target gap. |

## Smallest coherent implementation sequence

1. Preserve C01 and complete application lifecycle/device/network prerequisites.
   This handoff does not move WP05 ahead of safe C02/C03 owners.
2. Characterize R01 in an isolated experiment. Establish domain validation,
   effective-ratio resolution and safe phase updates before tuning a controller.
   Passing the known-defect reproducer means the defect exists, not that R01 passed.
3. Implement one fixed-rate host adapter with fake partial-count/error tests and
   bounded real native input/output. Maintain the [custody ledger](../contracts/conversion-custody.md).
   Keep the old non-resampled path available and distinguish its fidelity claims.
4. Choose/test the terminal recipe and define compatible completion semantics.
   Supply empty, one-frame, short-block, stalled-output and cancellation tests.
5. Qualify numerical behavior against independent vectors. Resolve headroom and
   finite-output policy before any physical playback experiment.
6. Implement the estimator/controller and independent plant simulation with the
   measured actuator quantizer/delay. Include saturation and rate-set failure.
7. Integrate through the single worker; prove wakeup, bounds, generation ownership
   and final fences. Only then collect actual target drift/latency/quality traces.

## Completion record for the next implementer

For each file, retain purpose, public inputs/outputs and units, lifetime/owner,
valid states, failure effects, cancellation, bounded resource use, invariants,
test oracle and exact evidence. Link any open item to R01-R08. Describe assertions
as tested only when a source-bound executable actually ran; preserve a failed
candidate's evidence and do not make an unsupported path the default.

This plan covers the conversion slice. Application identity, networking, lifecycle,
UI, packaging and release gates remain in the application's completion sequence.
