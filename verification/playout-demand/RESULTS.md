# Native callback demand and signal qualification

The native adapter now accepts backend-sized callbacks and avoids a redundant
output clear. Its bridge already fills every requested sample and accepts arbitrary
frame counts. This removes miniaudio fixed-size staging that consumed ahead of the
backend and retained a tail outside the application's queue accounting.

A new test calls the public native backend entry on an initialized, quiescent null
device. Before the change, a 17-frame request dequeued 240 frames: expected queue
occupancy 755, observed 532. The preserved negative test fails at that assertion.
The corrected path checks exact consumption and sample ordering for 17, 241, 511
and 3 frames, then verifies all silence after a genuine short read. No vendor bytes
or dependency pins changed. This does not remove native conversion or OS buffers,
or establish acoustic tail drain.

Worker timing now records cumulative published/consumed queue frontiers, maximum
nominal playback lead and consumption between observations without reading live
callback counters. There are no new callback clocks, allocations or logs. Recovery
uses the larger of observed lead and two maximum callback requests as its bounded
margin. Pure checks cover numeric extremes, monotonicity and rejection atomicity.

| Build | Components | Config CLI | Live workers | Recovery peer | Two-ended proxy |
| --- | --- | --- | --- | --- | --- |
| Debug | 123/123 | 24/24 | 12/12 | 10/10 | Pass |
| ReleaseSafe | 123/123 | 24/24 | 12/12 | 10/10 | Pass |

Five additional ReleaseSafe jitter trials: 5/5 passed.
Failed final checks: none.
Initial campaign failed checks (preserved): recovery-Debug, recovery-ReleaseSafe, jitter-repeat-0, jitter-repeat-1, jitter-repeat-2, jitter-repeat-3, jitter-repeat-4.

All named final worker/recovery cases passed.

The initial campaign used the earlier peer pacing and its five repeat jitter trials
all failed. Inspection found that it called sleep(0) for each overdue record. On
Windows this relinquishes the CPU time slice and can compound source-frame lateness.
Both paced peers now sleep only for positive remaining time; recovery diagnostics
also include maximum lateness against the source-frame schedule. The revised
tests ran against byte-identical Debug/ReleaseSafe product binaries. Only the two
Python peer harnesses and their reference contracts changed between campaigns;
their earlier sources are preserved under cadence/before. Product checks whose
inputs were unchanged are retained from the full campaign. No reserve, completion,
attempt count, authentication or cleanup assertion was weakened.

These are finite, short loopback/null-backend checks. The unchanged jitter criterion
requires one clean session using 60 ms reserve. A diagnostic fixed-staging run
passed under quieter scheduling, while a later direct-callback preflight failed
with a 27.063 ms maximum peer send gap and 5 ms observed playback lead. This rules
out claiming that the staging change alone solves every timing failure. Maximum
single gaps do not bound cumulative delivery lag or all callback/worker scheduling.
The final trials above are recorded without replacing any failed earlier report.

Explicit Windows capture tests used generated configuration-relative identities:

| Physical observation | Passed | Received frames | Capture drops | Non-silent bytes |
| --- | --- | --- | --- | --- |
| Idle capture | True | 480832 | 0 | 0 |
| Generated 1 kHz tone | True | 481536 | 0 | 2287296 |

Tone signal metrics: {"detected": true, "finite": true, "frames": 481536, "rms": 0.022094454333347713, "tone_amplitudes": [0.031246275847269106, 0.031246275847269106], "tone_energy_fraction": 0.999999928043638}.
Tone-run application CPU: 0.140625 seconds over
14.203 seconds of harness time. Idle application CPU:
0.109375 seconds over 11.118 seconds.
No captured PCM is persisted. A quiet generated WAV is temporary and stopped on
exit; system volume and selected devices are not changed. The independent meter
passes analytic 1 kHz amplitude/phase and irregular-chunk checks and rejects
silence, other test frequencies and nonfinite input. Detection is a narrow signal
test, not a full-band fidelity, acoustic latency, Mac receiver or Wi-Fi measurement.

Pure Intel macOS 12 compilation, pairing and 188 TLS custody entries pass. The final
campaign binds unchanged product code and miniaudio source/build/vendor inputs to
installed binary hashes; the later harness-only change and fresh peer checks have
separate source/binary records. Prior receipt and all 367 evidence
files remain intact. Documentation/reference/handoff checks are recorded separately.

This is not production-ready. Required work still includes sustained independent
clock correction, native Intel Mac build and real speaker execution, Monterey and
current compatible macOS checks, real Wi-Fi/latency/soak qualification, and any
failed checks above. Stable endpoint identities, credential lifecycle, app/tab
selection, phone receivers and the SvelteKit interface remain open. Finite reserve
cannot hide arbitrary network or scheduling outages while preserving low latency.
