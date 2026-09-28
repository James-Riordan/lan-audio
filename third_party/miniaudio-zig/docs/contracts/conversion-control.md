# Rate control: representation, phase and adopted-source limitations

Status: source review plus silent C-only characterization of the adopted
miniaudio 0.11.25. This is a blocker analysis for Q04, not approval of a production
controller or a vendor patch. [Source custody](../reference/upstream.md) identifies
the exact adoption; [verification](../verification/conversion.md) explains the
reproducer and its limits. Product ownership stays with application WP05.

## Three quantities must remain visible

Let `rho_req` be the controller's requested source frames per output frame,
`rho_repr` the rate pair/parameter actually supplied to the backend, and
`rho_eff` the qualified behavior inferred from native state and sustained counts.
They are not interchangeable. With source rate f_s and physical output rate f_r,
the ideal balance ratio is `rho_0=f_s/f_r`. Increasing rho consumes source faster
per output duration. For a real converter, finite-block output/input counts include
history/latency and do not equal an exact per-call ratio.

Use finite positive validated values throughout. A request is rejected before any
native call if outside the qualified ratio, integer-rate or work-budget envelope.
Do not rely on a native `ratio <= 0` test to reject NaN/infinity or make an
out-of-range float-to-integer cast safe. Validate conversion products and rounding
before casting, and preserve the native error when a validated call still fails.

## R01a: the generic helper is too coarse for a presumed fine actuator

In the adopted [header implementation](../../vendor/miniaudio/miniaudio.h),
`ma_resampler_set_rate_ratio` forms an integer numerator with denominator 1000
and calls the integer-rate setter (local source near 54175). The conversion to
integer truncates a positive product. Actual arithmetic first uses the supplied
binary32 value, so boundary behavior requires measured cases rather than decimal
intuition. `ma_data_converter_set_rate_ratio` delegates to that generic helper.

Observed in both `zig cc -O0` and `-O2`, with the adopted profile and no device:

| Requested binary32 literal / operation | Native represented pair | Consequence near unity |
| --- | --- | --- |
| Generic ratio `1.0001f` | 1000 / 1000 | Intended approximately +100 ppm becomes 0 ppm |
| Generic ratio `0.9999f` | 999 / 1000 | Intended approximately -100 ppm becomes -1000 ppm |
| Explicit integer pair 480048 / 480000 | Generic fields retain pair; stock linear backend reduces to 10001 / 10000 | Exactly +100 ppm as a rational ratio at this state; dynamic transition safety is a separate issue |
| Equal-rate data converter, dynamic disabled | `MA_INVALID_OPERATION` | Equal-rate optimization has omitted the resampler |
| Equal-rate data converter, dynamic enabled, ratio `1.0001f` | Success, underlying 1000 / 1000 | Enabling dynamic operation does not fix the generic quantizer |

The API's available ratio grid is approximately 0.001, or 1000 ppm near unity.
Do not confuse successful setter return with fine clock correction. The separate
`ma_linear_resampler_set_rate_ratio` implementation uses denominator 1,000,000
(near 53701), but selecting it changes the adopted API path and encounters the
phase-scaling concern below. Its precision/behavior is not qualified by the
generic-helper tests. Do not mutate `resampler.state.linear` directly to bypass
the generic owner and leave outer metadata inconsistent.

For a requested constant ratio rho and applied ratio rho+delta, the ideal source
occupancy bias over t seconds is `-f_r*delta*t` frames, before delay/noise/filter
effects. At 48 kHz, an uncorrected +100 ppm source drift adds 4.8 frames/s, or
8,640 frames in 30 minutes. This is a dimensional stress example, not a measurement
of James's devices or a chosen latency tolerance. A controller must include its
actual actuator quantizer; pretending requests are applied can hide accumulation
and make integral windup look like network jitter.

## R01b: large integer rates are not an automatic precision fix

The stock linear backend reduces integer rates by their greatest common divisor.
On a rate update, `ma_linear_resampler_adjust_timer_for_new_rate` rescales its
fractional source phase using a product of two `ma_uint32` quantities (near 53056).
For old fractional numerator p, old reduced denominator d_old and new reduced
denominator d_new, with `0 <= p < d_old`, the mathematical mapping is:

```text
p_new = floor(p * d_new / d_old)
0 <= p_new < d_new
0 <= p/d_old - p_new/d_new < 1/d_new
```

That mapping requires the product to be represented without overflow. In the
observed Windows target, the unsigned 32-bit product wraps before division.
The probes initialize a stereo f32 stock linear resampler with filter order zero,
process zero-valued frames to create a nonzero phase, then call the public generic
integer-rate setter. They inspect native fields without modifying those fields.

| Initial rates; output processed | Next rates | Old p / d_old | New reduced denominator | Mathematical p_new | Observed p_new |
| --- | --- | --- | ---: | ---: | ---: |
| 480001 / 480000; 200000 frames | 480002 / 480000 | 200000 / 480000 | 240000 | 100000 | 1573 |
| 480001 / 480000; 200000 frames | Same 480001 / 480000 | 200000 / 480000 | 480000 | 200000 | 3147 |
| 48001 / 48000; 20000 frames | 48002 / 48000 | 20000 / 48000 | 24000 | 10000 | 10000 |

The first two intermediate products are 48,000,000,000 and 96,000,000,000,
both beyond unsigned 32-bit range. Reapplying identical rates is therefore not
observed to be a phase-preserving no-op for this large-denominator state. These
facts reproduced in both optimization builds. This establishes a phase-arithmetic
problem; zero-valued test samples do not measure an audible artifact.

A conservative sufficient bound for this *one product*, assuming p<d_old, is
`d_old <= 65535` and `d_new <= 65535`. Then `p*d_new <= 65534*65535`, which fits
unsigned 32-bit. It is not a complete proof of all converter arithmetic, quality,
time complexity or all intermediate native states. Preserve a separately checked
processing-span bound for count-query products and advances. Review the GCD-reduced
denominators, not just the unreduced rate pair. Repeated updates also introduce
ordinary phase quantization even when overflow is absent.

## Choosing a future actuator

Do not select one of these alternatives solely because it compiles:

| Candidate | Required qualification before adoption |
| --- | --- |
| Bounded explicit integer-rate pairs | Derive maximum ratio error over the required interval and GCD-reduced phase-product bounds over every allowed transition. Measure equal-rate crossings/filter changes and verify numerical/latency quality. May have insufficient precision; that outcome is acceptable evidence. |
| Reviewed change to adopted implementation | Isolated candidate with original and proposed source hashes, focused arithmetic/rate regressions, full relevant ABI/consumer/native checks and Q02 review. Do not edit the vendor file or adoption manifest merely to make this handoff pass. |
| Another resampling backend | Explicit dependency/API/lifetime/license/performance decision, independent numerical oracle, rate/phase failure semantics and target matrix. A new name does not confer fidelity or real-time guarantees. |

For rounded explicit rates `n = round(rho_req*d)`, ideal arithmetic gives
`abs(n/d-rho_req) <= 1/(2*d)` when the numerator is valid and d fixed. That is
only a representation bound; phase remapping, native filtering, request floating
precision and delay still need tests. If the application uses truncation, record
its asymmetric bound instead. Use wide or checked host arithmetic when calculating
candidate pairs and products; fail outside the validated range.

The adapter can avoid redundant native setter calls for an unchanged accepted
pair, but that alone does not repair differing-rate transitions or qualify native
state. Record requested and accepted pairs before/after each control event. A
failed rate setter may have modified native backend configuration; end the
generation unless failure atomicity is specifically proven for that path.

## Controller contract before gain selection

The application's quantitative-design chapter already derives an ideal discrete
PI region. Do not copy its gains into a delayed/quantized implementation without
preserving its assumptions and update order. A minimal experiment must state:

1. Occupancy measurement location, domain, target and observation uncertainty.
   Queued output converted to source-equivalent units requires a stated mapping;
   two raw queue counts cannot be added across a varying ratio.
2. Controller interval T, actual elapsed-time policy and maximum observation age.
   Timestamp jumps or old generations reset/reject observations explicitly.
3. Filter, estimator and application delays; requested-rate clamps and slew limits;
   represented-rate quantizer and measured application cadence.
4. Integrator rule and anti-windup using the supported/applied actuator. Source
   starvation or output saturation is not necessarily evidence of clock mismatch.
5. Freeze/restart behavior during prefill, source outage, END, rate-set failure and
   generation replacement. Do not tune from invented samples during these states.

The sign follows conservation. In the ideal plant, excess source occupancy e>0
should increase rho. With proportional correction `rho=rho_0+k*e`, k>0, one ideal
step is `e_next=(1-T*f_r*k)*e`; local stability requires the magnitude of that
factor below one. Reversing the sign yields `1+T*f_r*k>1`, hence growth for nonzero
error. This is an analytic mutation oracle for the simulation, not a proof for
the actual PI/filter/saturation system.

Publish maximum/steady occupancy error, represented ratio error, settling time,
clamp activity, drop/silence counts and spectral residuals for the tested envelope.
Keep native/system conversion outside the adapter visible: application resampling
does not prove that the OS/device path adds no further conversion.
