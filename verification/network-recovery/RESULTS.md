# Network recovery qualification

This phase adds bounded retry/reserve policy, playback starvation/backlog detection,
fresh authenticated streams, a persistent listener, per-attempt cancellation and
diagnostics. The CLI starts with 40 ms reserve and caps adaptation at 120 ms by
default. It also initializes native devices before OFFER/ACCEPT to avoid accepting
media while a slow receiver is still opening its device.

## Final-source results — release gates still failing

`final-source/` records one unchanged source campaign with code hashes captured
before execution and checked afterward. Earlier directories are development runs,
including campaigns interrupted by source changes; none substitutes for this one.

| Build | Component tests | Live workers | Verified channel | Recovery peer | Two-ended proxy |
| --- | --- | --- | --- | --- | --- |
| Debug | 114/114 | 12/12 | 43/43 | 8/10 | Pass |
| ReleaseSafe | 114/114 | 12/12 | 43/43 | 7/10 | Pass |

The failed receiver scenarios are listener starvation/reconnection and the jitter
case in both modes. They report PlaybackStarved with joined/fenced/released owners.
The ReleaseSafe backoff-cancellation case also fails its expected single-attempt
assertion: it observes a second attempt canceled before completion. Cancellation
does finish; this run does not establish the requested backoff timing bound.
These are unresolved failures, not passing recovery qualification. No unchanged
retry was used to replace them with a more favorable result.

The actual sender and receiver recover through the ciphertext-only 150 ms proxy
stall in both modes, and all legacy worker/verified-channel scenarios pass.
Pair provisioning and malformed CLI/buffer options pass. The native registration
unit test exercises real Windows MMCSS entry/revert. All 188 dependency pins and
staged DLLs match. Application docs and per-file contracts are checked separately
by the seal script. Pure Intel Mac core/lifecycle/policy compilation passes; missing
Mac SDK and running the Mac recipe on Windows correctly reject. This is not a
native Mac application build or speaker run.

The final explicit physical Windows CLI run delivers 480,000 frames,
with zero capture drops, exact independent receiver conservation, authenticated
ACK/closure and both native devices fenced/released. The requested capture is ten
seconds; full measured harness time is 12.035 seconds. Captured
samples in this run are silent. The scoped media-priority registration is reported
as True. Process CPU is 0.140625 seconds,
about 1.17% of one CPU core across that interval.
This excludes audio-engine/system CPU and measures no Mac or acoustic path.

An earlier development run (`complete/physical-windows.log`) observed 480,000
frames with 2,525,278 nonzero payload bytes and zero drops. It has separate binary
hashes in that directory and is not the final binary's non-silent qualification.
No PCM or private pairing keys are stored in evidence.

## Failures exposed during development

The Python peer initially omitted TCP_NODELAY. After correcting that, nominal
5 ms jitter still sometimes became a 31 ms or larger send gap under Windows
scheduling. The jitter case now explicitly uses 60 ms reserve and records actual
send gaps. Separate 20 ms tests deliberately exhaust that smaller reserve.
The product CLI default changed to 40 ms after a two-ended 20 ms run starved even
before its requested stall. This is a provisional default, not measured gaming
latency or a guarantee under arbitrary scheduling.

The receiver previously sent ACCEPT before initializing its device. Independent
peers could accumulate an entire latency budget during slow device startup,
causing immediate backlog or starvation. Native initialization now precedes
OFFER/ACCEPT after authentication. Receiver native start also completes before
ACCEPT, with a callback gate that emits silence without draining prefill. The
worker releases that gate only after prefill or short END. This removes backend
start latency from the active media receive loop. OFFER/ACCEPT now runs on the
actual media worker after ownership handoff, so thread creation also precedes
acceptance. The timed backoff-cancellation fixture now starts its timer after the
first failed attempt; a timer from process launch could instead cancel setup. The two-ended proxy previously timed its stall
from TCP connection creation; slow setup could consume that interval before media
started. It now triggers after 64,000 forwarded media-direction ciphertext bytes.

The wrong-peer harness initially misclassified a reset during Python TLS setup.
It now accepts that transport observation only with the application's exact
WrongPeer diagnostic. An empty-report indexing bug is also repaired; failed
children must remain recorded failures. No failed result is overwritten.

A ten-second development physical run returned zero frames and the old harness
reported success. That was protocol closure, not capture delivery. The sender now
owns a silent playback keepalive for the same requested Windows endpoint. The
physical harness requires a substantive frame count and its clean native fence.
Earlier empty physical results remain in evidence and are not delivery proof.

The media worker now registers a scoped Windows MMCSS Audio task. It reports
whether registration succeeded and restores on the entering thread. Default
priority remains the explicit fallback. No global scheduling/registry policy is
changed; registration is not proof of deadline guarantees.

## Remaining acceptance gates

These checks use Windows loopback and null playback unless explicitly identified
as physical capture. There is no native Mac binary/device execution, real Wi-Fi
impairment qualification, acoustic latency/fidelity measurement, clock-drift DSP
or long-session soak. TCP head-of-line stalls remain; fresh-stream recovery can
cause audible gaps. Application queue bounds do not bound OS/TCP/TLS buffering.
Bit preservation covers captured finite f32 words in the current 48 kHz stereo
path, not the game's original format or unmeasured OS/device conversion.
CoreAudio destructive-fence behavior on Monterey/current macOS, native packaging,
signing, credential storage/renewal UX and iPhone support remain open.
