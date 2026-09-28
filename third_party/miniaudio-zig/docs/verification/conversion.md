# Conversion qualification: independent evidence before activation

Status: Q04 remains open. Source review and a silent C-only experiment reproduce
the [control limitations](../contracts/conversion-control.md). This chapter
specifies the missing Zig adapter, numerical, controller and target evidence.
The [file plan](../implementation/conversion-handoff.md) owns future application
paths; the [custody model](../contracts/conversion-custody.md) owns units and END.

## What the present characterization establishes

The preparation bundle records the exact probe/runner, source hashes, compiler
identity, commands, build/run logs and executable hashes. It uses the adopted
`src/native.c` as the only implementation translation unit, the same `src/profile.h`,
explicit null-only backend macros, C99, and Windows system linkage. Both `-O0` and
`-O2` builds execute the probe. No context/device is initialized and no audio is
played. The filter order is zero to isolate control state, not to endorse quality.

Cases reproduce generic ratio quantization in both directions, demonstrate the
explicit integer pair, verify equal-rate data-converter dynamic enable/disable,
and compare three phase transitions against independently calculated integer
products. Two transitions intentionally assert the adopted overflow behavior;
one small-denominator control asserts agreement with the mathematical mapping.
Passing these cases means the expected limitations were reproduced. A future fix
must replace the appropriate defect expectation with a correct-phase regression
on a deliberately reviewed source candidate, retaining the original evidence.

The delivered `verification/conversion-readiness/probes/` directory contains
`probe.c`, `run_probe.py` and `check_examples.py`. It is evidence material, excluded
from authored source inventory just like other top-level verification directories.
From a delivered snapshot or a copy with that evidence directory, reproduce with:

```powershell
python verification/conversion-readiness/probes/run_probe.py --root . --output verification/new-control-characterization
python verification/conversion-readiness/probes/check_examples.py
```

The output directory must not exist. The runner is a Windows-specific exploratory
C build script, not a general qualification runner. It requires the exact adopted
compiler version, records command logs progressively and seals completion only
after both fresh runs and unchanged inputs. Direct-process timeout is not a
guarantee that every compiler descendant has terminated. These results do not
exercise Zig calls, the production build graph, a worker, filters with nonzero
order, another OS, a native device, acoustic output or a 30-minute run.

`check_examples.py` uses exact rational/integer arithmetic for the hand-worked
custody, drift, sign, phase and rounding examples. Its negative examples reject
mixed-domain accounting and premature completion. This is finite specification
evidence, not a runtime implementation, numerical audio oracle or formal refinement
proof. Existing 23 Python tooling tests and Q01 remain independent checks.

## Candidate record: fill facts, never copy assumed defaults

Before a numerical or hardware run, save these inputs with source hashes. Missing
required values mark the run exploratory/incomplete rather than quietly passing.

| Field group | Required facts |
| --- | --- |
| Identity | Application/binding/vendor hashes; compiler; target triple; SDK/OS; optimization; feature macros; chosen public API and algorithm. |
| Signal | Source/output nominal rates and their domains; channels/map; sample type; input amplitude/headroom; finite-sample policy; seed/vector hash. |
| Native setup | Filter order and all non-default quality parameters; dynamic enable flag if converter used; allocation policy/heap; latency queries with units. |
| Control | Requested/represented/effective rate convention; quantizer; allowed pairs/denominators; ratio/slew bounds; cadence/filter/delay; failure policy. |
| Buffers | Offered spans in frames and bytes; source/output staging and queue bounds; maximum process calls/work per turn; scheduling deadline. |
| Terminal | Empty-stream behavior; padding cap; output cap; residual criterion; deadline; truncation/drop disclosure; completion/fence meaning. |
| Numerical acceptance | Named passband and stopband, maximum gain/error/alias/transient bounds, valid comparison region, oracle uncertainty and rationale. |
| Physical envelope | Endpoint/driver/native format, OS conversion, actual callback range, CPU/load, drift range, latency and outage envelope; unavailable facts stay unknown. |

Quality thresholds, controller gains, acceptable ppm envelope and product latency
are open decisions R03/R04/R07/R08. Fixture values below are stress cases, not
approved product defaults. An unavailable native target cannot complete its gate.

## Functional and failure matrix

| Case / independent setup | Required observation / failure witness |
| --- | --- |
| Fake native counts: partial input, partial output, input-only, output-only, zero/zero | Exactly advance each independent cursor; retain held suffix; bound every count; zero progress cannot become EOF or a hot loop. |
| Queue capacity 1/2, zero/short write, tiny caller spans | At-most-once FIFO output with guards intact; no overwritten held output; apply the hand-worked custody trace independently of converter internals. |
| Native returns error after writing count parameters/buffer | Preserve fault/native result; publish none of that uncommitted output; abandon generation and clean acquired resources safely. |
| Invalid ratio/sample/span/config | Reject finite/range/checked-product violations before native casts/access; test NaN/infinity/zero/negative/huge values in silent memory tests. |
| Rate 1.0001 and 0.9999 through generic API | Record current coarse represented ratios; fail a candidate that claims fine adjustment while exhibiting those results. |
| Nonzero-phase integer-rate changes and repeated same request | Compare widened mathematical mapping with actual state/output continuity; include the overflow witness and both transition directions. |
| Equal-rate init then rate changes | Dynamic-disabled data-converter failure remains explicit; dynamic-enabled mode still needs effective precision and transitions across unity. |
| Empty, one-frame and short source END | Finite declared behavior, no invented media from null input, bounded synthetic padding, correct final frontiers and fences. |
| Cancellation in every custody/terminal state | No new publication after cancellation boundary; safe joins; idempotent cleanup; no success acknowledgement. |
| Generation replacement and stale observations | Old control events, source tails and statistics cannot affect the new owner; no live reset/reuse. |
| Count/memory bounds | Guarded input/output, maximum spans, checked query products, no unlimited allocation or calls caused by a rate request. |

Scripted counts test the adapter contract but cannot qualify native numerical
behavior. Native numerical tests cannot establish concurrent worker/device lifetime.
Keep those evidence boundaries explicit when combining results.

## Numerical oracle and comparison method

Use at least two independent views: analytic low-frequency signals/rational time
coordinates and a documented high-accuracy offline reference for broadband/filter
quality. Do not use a second miniaudio instance as the expected-output generator.
The reference's interpolation/filter choice, coefficient precision, boundary
extension, delay convention and error budget must be explicit. A reference
algorithm different from the candidate may have different phase/delay; compare
appropriate metrics instead of demanding sample equality without alignment.

For a constant rational source/output ratio rho and independently justified
phase p0, output coordinate is `p(m)=p0+m*rho` in source frames. An analytic
sinusoid of input amplitude A and frequency f has expected ideal samples
`A*sin(2*pi*f*p(m)/f_in + phi)`. This is an ideal bandlimited signal oracle in its
valid frequency range, not the transient response of a particular finite filter.
For changing rates, state exactly which output index applies each new ratio and
accumulate a piecewise coordinate. Never use the candidate's cursor to generate
its own expected phase.

| Signal/campaign | Comparison and required independent facts |
| --- | --- |
| Zero and DC | Finite outputs, steady gain after declared settling, separately reported startup/tail. Zero alone cannot reveal phase errors. |
| Impulse per channel | Impulse position, response extent/residual, channel identity/crosstalk and declared delay; preserve leading/trailing samples for tail analysis. |
| Low-frequency sine/cosine | Gain and phase residual against analytic samples in a stated interior region. Validate phase origin independently; do not optimize an arbitrary shift that hides discontinuities. |
| Passband sweep or tones | Frequency grid, amplitude, window, FFT/fit method and reference error; report worst gain/error rather than one favorable tone. |
| Downsample stopband tones | For input tones above output Nyquist but below input Nyquist, measure unwanted folded energy in output; account for leakage/window/scaling. Tiny DC error does not establish alias suppression. |
| Different per-channel tones/impulses | No unintended mixing, channel swap or correlation. Use asymmetric signals so identical channels cannot hide errors. |
| Ratio staircase/ramp and unity crossings | Continuity/residual, effective phase/rate, filter-state behavior and CPU cost; include nonzero state and both signs. |
| Chunk partition campaign | Same source and same rate-event positions under contiguous, one-frame and seeded fragmentation with output capacities 1, 2, 17 and larger blocks. Compare full concatenated output under the same terminal policy with justified tolerances. |

Choose finite analysis windows before seeing results. Record startup, interior and
tail separately; excluding transients from a passband metric must not delete them
from the reported transient metric. A deterministic stress list can include nominal
44.1->48 kHz, 48->44.1 kHz and equal rates, plus clock offsets of both signs; none
is a support claim until measured. Compare all required regions and fail explicitly
on nonfinite output rather than silently removing those samples from statistics.

A finite f32 input can exceed practical output headroom or overflow intermediate
arithmetic. Wire bit-pattern tests belong upstream of the DSP boundary. Choose an
explicit adapter amplitude/limiting/rejection policy and distinguish that transform
from transport preservation. Never feed full-range protocol extremes to speakers.

## Controller and target completion

The independent plant must include the measured control quantizer, delay, source
and output clocks, input arrival bursts/stalls and bounded storage. Test positive/
negative mismatch, jitter-only arrivals, slowly varying mismatch, timestamp reset,
missing observations, ratio clamps, windup/recovery, prefill, END and device restart.
Report seeds, all bounds and observed occupancy/ratio/error extrema. A reversed-sign
mutation and a pretend-perfect-actuator mutation must violate an independent
expectation; if they do not, the scenario is too weak to qualify that property.

Only after arithmetic, custody and numerical gates pass should the application
run its real Windows/Intel Mac campaign. Include 30-minute drift traces as required
by WP05, observed callback/service ranges, CPU/memory/allocation counts, actual
output format, end-to-end latency method and terminal behavior. Quiet successful
playback is useful observation, not a quantitative alias/latency/fence proof.

Close Q04 only with source-bound native adapter tests, independent numerical and
controller evidence, defined completion semantics and the advertised target's
results. Readiness documents and successful defect reproducers leave Q04 open.
