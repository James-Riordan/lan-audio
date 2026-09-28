# WP05 — Pacing, buffering and independent audio clocks

Status: planned. Depends on WP02 and WP04. Acceptance: A3/A4/A5/A8.

The dependency owner's [conversion handoff](../../../third_party/miniaudio-zig/docs/implementation/conversion-handoff.md)
and [measured rate-control constraints](../../../third_party/miniaudio-zig/docs/contracts/conversion-control.md)
are required adoption inputs. Its silent probes found coarse generic ratio control
and overflow in some stock linear phase updates, including repeated same-rate
updates. Do not tune a controller against an assumed exact actuator or use large
integer rates as an unqualified workaround. Qualify a bounded supported path,
reviewed fix or alternative backend first; vendor bytes/pins stay unchanged here.

| Planned file | Contract / verification |
| --- | --- |
| `src/media/playout_clock.zig` | Frame-position ↔ local render-deadline mapping; checked arithmetic and epoch resets; no unsynchronized cross-host subtraction. |
| `src/media/prefill.zig` | Contiguous ready-frame threshold and bounded priming/rebuffer states; holes do not count as playable coverage. |
| `src/media/clock_estimator.zig` | Filter cumulative frame/time observations into rate ratio, confidence and discontinuity; test known synthetic ratios and timestamp resets. |
| `src/media/drift_controller.zig` | Bounded ratio/slew and anti-windup using one documented sign convention; reset only under owner control. |
| `src/host/resampler.zig` | Own qualified miniaudio resampling state; bounded input/output progress, finite samples, no hidden callback allocation; expose actual quality parameters. |
| `tests/simulation/clock_drift.zig` | Deterministic independent-clock plant with rate offset, jitter, source stalls and device restarts; compare against analytic invariants. |
| `tests/integration/resampler.zig` | Impulse/tone/sweep, amplitude headroom, phase/rate transitions, finite-output and tail-drain checks. |

Read M04/M05 in system mathematics. Define consumed source frames per output frame
once, prove controller sign, and separate slow rate mismatch from short network
jitter. Derive gains and stability in discrete time for the actual update cadence;
choose numeric clamps from simulation and hardware observations. No arbitrary ppm
clamp is approved by this work package.

Start output only after the selected contiguous prefill; account for callback
queue and native buffer delay in the latency budget. On underrun, mark the physical
clock advance and either rebuffer into a new mapping or drop specifically late
source ranges according to the chosen policy. Never accumulate unbounded delay by
playing all late data. On END, drain resampler tail under its explicit contract;
distinguish algorithmic tail frames from original media frames in counters/ACK.

Simulate rate errors of both signs, changing ratios, jitter-only cases, sudden
timestamp jumps, long pauses and pathological missing observations. Verify finite
bounded occupancy/ratio, no controller windup and deterministic recovery. Record
which error ranges pass; the scenario numbers are stress inputs, not guaranteed
hardware specifications. Require real Windows/Mac 30-minute drift/occupancy traces.

Exit: continuous playback does not inexorably fill/empty queues in the qualified
clock envelope; latency and correction error are measured; transport sample equality
remains true before resampling. Bit-perfect output mode, if offered, explicitly
states its clock/precondition limitations and failure policy.
