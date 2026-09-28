# Callback and Windows audio qualification — 2026-09-25

Version 0.3 adds bounded SPSC frame transfer, callback copy/silence/drop policies,
explicit native host profiles and real TLS-to-null-callback integration. It does
not complete the Windows-to-Mac product. No dependency source or SDK changed in
this phase; the earlier TLS and miniaudio custody remains intact.

## Executed checks

| Check | Observed result |
| --- | --- |
| Core Debug / ReleaseSafe | 18/18 tests in each; includes 250,000 ordered stereo frames across two threads |
| Native null-device Debug / ReleaseSafe | Eight callback teardown/recreation cycles in each test run |
| Authenticated TLS to null playback, Debug / ReleaseSafe | All 16 scenarios in each mode; 20 blocks, 9,600 samples, 4,800 frames copied by callbacks |
| Windows WASAPI loopback plus silent playback | 370 encoded blocks, 88,800 frames, 372 callbacks, zero capture drops; samples discarded |
| SPSC publication model | 29 distinct states, 41 generated; safety and fair finite completion pass |
| Two publication model mutations | Early publish and early release each violate `NoCorruption` as expected |
| Mac arm64 pure core | Compile succeeds; no Mac execution or audio/TLS backend qualification |
| Linux x86_64 audio adapter/null test | Compile/link succeeds; no Linux execution |

The successful physical check exercised the default Windows output route with a
silent playback stream holding the engine active. This establishes native callback
capture and finite PCM encoding, not audible quality, latency, clock drift or a
second-computer path. No microphone was opened and no captured samples were saved
or sent over the network. Network integration used synthetic test PCM separately.

The network test's checksum remains an independent check before queue submission;
callback counters establish that all queued frames were copied out. Separate queue
ordering tests check payload preservation. No acoustic waveform comparison is claimed.
ReleaseSafe's positive run also counted 1,200 silent frames; start/gap silence is
explicit, and no low-latency or prefill qualification is inferred.

## Failures retained and corrected

The first concurrent test exposed an inferred narrow integer in the test generator:
`min(17, remaining) * 2` overflowed its inferred width. Giving the frame count an
explicit `usize` fixed the harness; the actual queue was unchanged by that repair.
Initial terminal output also reported a Windows Perl locale warning. Recorded runs
use process-local `LC_ALL=C` and `LANG=C`; no global configuration was changed.

`interop-first-run.json` retains the first callback integration run: 15 cases passed,
but the untrusted-client case produced `TransportFailure` rather than `TlsFailure`.
The independent server recorded certificate rejection. The gate now accepts either
client transport outcome only with that server certificate-verification failure,
no authenticated peer, no ACK and no success marker. Debug and ReleaseSafe reruns
pass all 16 cases; arbitrary process failures still do not count as correct rejection.

`device-2.log` retains the first hardware check's `NoCaptureFrames` failure: the
device initialized but idle system output delivered no complete block. The revised
fixture opens an explicit silent playback stream and drains bounded batches without
assuming millisecond sleeps have exact timing. `capture-retry.log` records the
successful physical run. The earlier failure is not relabeled as a success or skip.

## Mathematical and lifetime limits

The queue's manual acquire/release argument, modular-counter conditions and ownership
preconditions are in `docs/MATHEMATICS.md`; device teardown and overrun policy are in
`docs/CALLBACKS.md`. The TLA+ model uses sequential consistency, two slots and four
frames. It does not verify weak-memory compilation, unbounded executions or OS
callbacks. Tests are not a race-detector certificate or a hard-real-time guarantee.

Native control is serialized. Initialized devices and queues stay at fixed addresses.
Workers must join before reuse, and device uninitialization must complete before
reclaiming callback userdata. The null lifecycle test checks repeated reconstruction;
hotplug, permission changes and production worker cancellation remain unqualified.

## Custody and next gates

`receipt.json` records source observations, commands, evidence hashes, tools and
before-images verified against the prior transport receipt. Original preparation
and transport evidence remain historical. The TLS lock still covers 188 files;
normal verification cannot refresh it. The file map covers all current authored/
vendor files, but navigation completeness does not prove semantic correctness.

Next: production capture-to-network composition and loss handling, endpoint/pairing
UX, Mac TLS/SDK/device execution, clock-domain measurement and drift control, then
sustained end-to-end latency, hotplug and deployment checks. These results do not
establish A1/A5/A6 in the product acceptance contract.
