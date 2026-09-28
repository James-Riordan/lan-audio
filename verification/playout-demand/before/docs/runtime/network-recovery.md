# Recovering an interrupted audio stream

The foreground command now supervises complete sessions. The initial reserve is
40 ms, and a receiver starvation increases the next session's reserve by at least
20 ms, using measured delivery gaps when they call for a larger increase,
up to `--max-buffer-ms` (120 ms by default, at most 240 ms). This is recovery after
a gap, not concealment of a gap. Captured finite f32 sample words are unchanged by
this policy. There is still no asynchronous sample-rate correction.

## Why a fresh stream is necessary

A callback that exhausts its queue must output silence. Resuming the same ordered
TCP stream later would play old game sound, potentially accumulating delay after
each interruption. The callback therefore publishes a sticky `playback_starved`
atomic when its guard is armed and a read supplies fewer frames than requested.
It still only copies and zero-fills: it never reconnects, waits or controls devices.
The worker and control watcher observe the flag and cancel this session.

The native receiver starts before ACCEPT with playback_ready false: callbacks
zero-fill without consuming queued frames. The worker arms the guard and then
release-publishes playback_ready when prefill is complete. A callback acquires
readiness before reading the guard, so warmup cannot drain prefill or trip recovery.
The guard is disarmed after authenticated END so intentional final zero-fill is
not classified as network failure. Short streams first released after END never
arm it. Empty streams keep the warmup gate closed until teardown. A callback
observes the guard at entry; an END concurrent with an already
guarded callback can conservatively classify its shortage as starvation. Resetting
the sticky event requires quiescence and reconstruction, not a live queue reset.

The receiver also rejects a streaming queue above the reserve ceiling plus a
bounded 480-frame (10 ms at 48 kHz) publication-burst allowance.
This detects accumulated delay even when playback has not starved. The check is
before publication; at most one accepted record can overshoot the threshold
(240 frames normally, 1024 at the protocol maximum). This bounds the application
queue, not TCP, TLS, OS device buffers or acoustic delay. The reserve ceiling
remains unchanged; this separate allowance avoids treating two ordinary records
arriving before the next callback as backlog when reserve has reached its ceiling. The native bridge has
32,768 stereo frames in each direction (256 KiB each, about 682.7 ms capacity),
leaving headroom above every permitted 240 ms reserve. Capacity is not occupancy.

## Cancellation, ownership and retry

`session_supervisor.run` owns the listening socket across attempts. Each
`stream.run` owns a fresh fixed audio/network aggregate and one worker. After
authentication, it initializes the audio device before OFFER/ACCEPT. ACCEPT thus
means receiver native initialization and start have finished, avoiding a backlog
while a slow receiver opens/starts its device. Playback remains gated silent until
negotiation and prefill; sender capture starts only after negotiation. The actual
media worker exchanges OFFER/ACCEPT after it has acquired control, so acceptance
cannot race thread creation. Setup borrows the external abort flag; after TLS
setup `Connection.bindCancellation`
switches to the session's private flag while no operation is active. A stale
generation, active operation or already-canceled replacement flag rejects without
rebinding. The replacement flag must outlive the connection. An already-canceled
connection cannot be revived through this method.

An internal starvation/native failure sets the private flag, leaving the user's
stop flag unchanged. This distinction lets the next attempt run, while Ctrl+C
still interrupts connection setup, media I/O and retry waiting. Setup failure or
worker completion is followed by actual join, device fencing/destruction and
connection/socket release. Only a fully cleaned Report may reach the retry policy.
An exception with unresolved cleanup is terminal and retains the endangered
storage; constructing another session over it is forbidden.

The policy retries named transport/native failures at 250, 500, 1000, 2000 and
then 4000 ms, capped without counter wrap. Thirty seconds of active playback or
capture resets the failure count. Only starvation raises the reserve; backlog
does not. A listener survives a rejected identity, but a client stops on a known
peer/approval mismatch. Unknown errors and cleanup errors stop. Every attempt
gets a fresh cryptographically random sender stream ID and repeats mTLS, peer
fingerprint authorization and format negotiation. No credential or trust rule is
weakened. There is no retransmission of samples from a retired session.

A clean END stops both commands; the receiver does not wait forever for another
intentional session. `--reconnect off` selects the previous one-session behavior
and disables starvation/backlog recovery. `--seconds` limits each sender session,
not the whole retry campaign. Cancellation during retry returns promptly through
10 ms control waits; native join/device teardown still depend on the backend.

## Keeping idle Windows capture clocked

WASAPI loopback can produce no callbacks when the shared render endpoint has no
active output. An empty ten-second physical run exposed this; empty EOF is a valid
protocol result but is not evidence of audio delivery. The Windows sender now opens
an additional silent playback device on the same requested output endpoint before
capture starts. Its empty queue supplies zeros and keeps the shared engine active.
Silence therefore travels as real captured frames instead of a network timeout.
It does not select a microphone or change system volume.

The ledger's native resource now owns the primary device and this optional device
as one aggregate. Both have fixed addresses in State (about 1 MiB of total queue
storage); the extra native device is initialized only for Windows loopback.
Failure of secondary initialization rolls back the primary before reporting failed
acquisition. Failure after aggregate acquisition follows normal cleanup. Either
device's health fault cancels the session. Graceful capture fencing stops capture
before fencing the silent output; abort/release uninitializes both before State
can be freed. The per-attempt clock_keepalive diagnostic is true only when the
extra device existed and is fenced; it is null for other profiles.

The explicit physical test now requires at least 80% of the nominal duration's
frames, exact received/captured conservation, zero capture drops and that additional
device's fence. A no-frame run cannot pass it. Native Windows failure-injection
coverage of this two-device aggregate and repeated idle/active hardware soaks are
still limited; generic null tests do not initialize this additional device.

## Scoped media scheduling

On Windows the media worker registers itself with the MMCSS Audio task and
reverts that registration on the same thread when leaving. This is the native
[MMCSS interface](https://learn.microsoft.com/en-us/windows/win32/api/avrt/nf-avrt-avsetmmthreadcharacteristicsw),
not a registry edit, process-wide priority change or guarantee of scheduling
latency. Failed registration falls back to normal scheduling and media_priority
is false in the final report. A failed restoration is terminal; it never silently
retries an unresolved thread registration. The same-thread scoped API has repeated
register/revert and rejected duplicate-entry tests. Non-Windows currently reports
this optional feature unavailable; CoreAudio/backend scheduling is separate.

## Evidence and its limits

The newer [measured-recovery record](../../verification/measured-recovery/RESULTS.md)
reports the clock, adaptive reserve, queue headroom and retry deadline changes,
including failed checks. Its source snapshot and binary hashes are separate from
the earlier records below.

The [qualification record](../../verification/network-recovery/RESULTS.md) binds
pure policy/callback tests, independent TLS peers and a ciphertext-only proxy to
the tested sources. Both actual application supervisors run through the proxy's
150 ms forwarding stall, triggered after 64,000 ciphertext bytes in the media
direction rather than connection age. Each attempt reports its reserve, duration, failure,
starvation and admitted-but-unplayed frames, plus final owner state. The latter
frame subtraction assumes the present direct, non-resampled receive path.

The jitter peer explicitly requests 60 ms reserve and records actual send gaps:
Python's nominal 5 ms perturbation is not a guarantee about Windows scheduling.
The 20 ms exhaustion tests remain separate. These are short Windows loopback/null
callback experiments, not real Wi-Fi, Mac speakers, a latency benchmark or a clock
soak. No finite buffer can hide an outage longer than its playable reserve while
also guaranteeing low latency. Native Mac qualification and a separately tested
clock-correction DSP path are still required for sustained gaming playback.

## Measured reserve selection and clock domain

Windows runtime intervals now use QueryPerformanceCounter, converted to integer
milliseconds with checked quotient/remainder arithmetic. This replaces the coarse
GetTickCount64 clock. Certificate validity still uses wall-clock seconds; no QPC
value crosses the wire or substitutes for UTC. Microsoft describes QPC as the
appropriate same-system interval clock in its
[high-resolution timestamp guidance](https://learn.microsoft.com/en-us/windows/win32/sysinfo/acquiring-high-resolution-time-stamps/).
POSIX retains CLOCK_MONOTONIC. Detected clock failures/regressions are terminal errors.
There is no global timer-resolution, scheduler, power-plan or NIC change.

The receiver media worker owns `delivery_timing`: maximum successful receive-call
duration, maximum gap between nonempty queue publications, and the time since the
last publication when starvation is observed. Startup before the first publication
is excluded. The last gap is captured before transport/native cleanup. Read these
plain fields only after worker join; the audio callback still makes no clock call.
A publication gap includes network waiting, TLS work and scheduling, so it cannot
identify a faulty NIC by itself. A starvation ends the observation early: the full
outage may continue beyond it. Cleanup time and acoustic latency are not measured.

For observed gap G milliseconds and largest native output request C frames, the
candidate reserve is G plus one millisecond of timestamp quantization margin plus
two callback requests, rounded upward to a 240-frame block at 48 kHz. G and C are
bounded before arithmetic. The next reserve is the larger of that candidate and
the current reserve plus 960 frames, then capped by the configured maximum. With
40 ms current reserve, G=80 ms and C=240 frames, it selects 95 ms instead of taking
several 20 ms retries. Other failure classes do not change reserve. No live queue
is resized or retuned; the next authenticated stream gets the new setting.

This is a conservative bounded heuristic, not an outage predictor, independent
clock correction or guarantee of future scheduling. Two callback requests are a
phase/burst allowance; arbitrarily delayed callback bursts have no such bound.
Higher reserve adds delay and never exceeds the user's chosen ceiling. Pure tests
exercise overflow/extreme values and budgets; independent peers check observed
policy decisions as well as complete ownership cleanup.


Retry waiting is now a pure absolute-deadline state machine used by the real
supervisor. It checks monotonic ordering and returns at most 10 ms of waiting;
cancellation wins when sampled at or after deadline expiry. Pure tests cover the
exact boundary, a regressing clock and overflowing deadline construction. Native
wake-up/scheduling delay remains outside that logical guarantee. The cancellation
integration fixture initializes its timer and confirms thread startup before
returning to the supervisor; it still requires the original one-attempt result.
This removes fixture startup from the backoff interval, without allowing a late
cancellation to be reported as a timely one.
