# Audio callbacks, frame queues and reclamation

This contract owns the boundary between a serialized media worker and miniaudio's
audio callback. The worker performs networking, validation and codec work. The
callback copies interleaved frames and fills missing playback with zero. Neither
`Session` nor `Window` becomes thread-safe by importing this module.

## Representation and ownership

`FrameQueue(K,C)` stores exactly K interleaved f32 frames of C channels. K is a
power of two in `1..2^30`; C is in `1..32`. The qualified atomic profiles are
x86_64 and aarch64. Each cursor is an aligned native u32; cursors and data start
on separate 128-byte boundaries. This avoids sharing on the intended cache-line
profiles, without claiming a universal cache-line size or measured speedup.

One producer calls `write` and `producerPending`. One consumer calls `read`.
An operation transfers a prefix of **whole frames**, returns a frame count and
never waits for the other owner. `read` leaves the unused output suffix untouched.
Arrays must have lengths divisible by C, valid memory, and no overlap with queue
storage; these are caller preconditions, not hostile-input validation. Samples
are copied exactly, including nonfinite values; the wire encoder validates finite
PCM before publication to a peer. A playback producer must provide validated PCM.

Keep a live queue at one address. Never copy, reset or destroy it while either
owner can access it. The queue exposes no concurrent reset. Its atomic fields are
implementation state, not permission for a third owner to synthesize a snapshot.
All stress-test counter initialization happens before owners start.

`CallbackBridge(4096,2)` has independent capture and playback queues: 32 KiB each,
plus counters and alignment. Its nominal queue capacity is `4096/48000 = 85.33 ms`
per direction, not an end-to-end latency result. Occupancy can be much smaller.

| Boundary | Producer | Consumer | Insufficient capacity/data |
| --- | --- | --- | --- |
| Capture | Callback | Worker | Retain the fitting prefix; drop newest remaining whole frames |
| Playback | Worker | Callback | Worker retries a short write outside the callback; callback fills missing frames with silence |

Capture overflow sets a sticky atomic `capture_overrun`. A worker must check it
after reading and before publishing further stream data, and end/reinitialize the
stream on detection. Surviving frames must not be concatenated across a dropped
interval and presented as uninterrupted audio. Reset requires both owners to join.
This phase supplies the signal, not a production capture/network recovery policy.

The callback alone updates saturating diagnostic frame totals. Read those totals
only after `AudioDevice.deinit()` has completed. The separate atomic callback count
can be polled while running but wraps modulo 2^32 and is **not** a join, completion
fence or sample clock. Diagnostics do not promise exact totals after saturation.

## Native device lifetime

The optional `audio_host` build module exports `AudioDevice` and explicit profiles:
silent null playback/duplex, Windows WASAPI system-output loopback/playback, and
Mac CoreAudio playback. No profile selects a microphone. Platform mismatches fail
before native initialization. There is no implicit fallback to another backend.
Physical profiles use the default device; endpoint selection/hotplug remain work.

The application-facing format is 48 kHz, stereo f32. A 240-frame period is a hint;
the callback accepts arbitrary frame counts, independent of wire-block boundaries.
miniaudio owns backend negotiation and any conversion to the hardware format.

Initialize an `AudioDevice` in its final storage. Its userdata points back to that
storage, so returning an initialized value by copy is invalid. Control operations
are serialized, outside all callbacks. `init` creates context/device; `start` and
`stop` check state; `deinit` uninitializes the device, then context, even following a
start/stop error. The last native result remains available for diagnosis.

Before reconstruction, stop worker admission, cancel/join workers, then uninitialize
the device before resetting any reachable queue/userdata. Stopping and starting the
same device is a pause with retained queues, not a new stream generation. Device
uninitialization is the callback reclamation boundary. The existing session model's
callback token is not a replacement for this native join obligation.

The callback makes no allocation, network call, log call, device-control call,
mutex acquisition or retry loop. Copies are at most two spans per queue operation;
playback additionally zeros its missing suffix. Cost is O(requested frames × C).
Neither this bound nor the absence of locks proves an OS callback deadline.

## Checks and scope

`zig build test` covers frame/channel ordering, full/empty/partial operations,
physical ring wrap, u32 rollover, initialized silence, overrun policy and 250,000
stereo frames transferred between two real threads. `zig build audio-test` runs
actual asynchronous miniaudio null callbacks through eight teardown/recreation
cycles. It accesses no physical device.

The TLS probe now feeds decoded PCM into the playback queue and waits, within its
existing absolute deadline, for all 4,800 frames to be copied by null callbacks.
It then tears down the device, checks counters, acknowledges END and closes TLS.
Queue drain proves copying into the callback buffer, not audible completion.
The probe deliberately uses worker yielding under pressure; it is not a production
event-driven scheduler or latency benchmark. Silence before/between packets is
counted. Production prefill, clock control and underrun recovery remain required.

`zig build capture-test` is an explicit Windows-only hardware check. It keeps a
silent playback stream open, captures system output briefly, validates PCM through
the wire encoder, and discards all samples. It generates no audible tone and never
saves/transmits a recording. Missing frames,
device errors and overflow fail the check; an unavailable source is not a pass.

The [mathematical argument](MATHEMATICS.md#9-spsc-publication-and-slot-reuse)
explains the acquire/release obligations. `SpscPublication.tla` checks a bounded
sequentially consistent abstraction and detects both publication-order faults.
It does not model the Zig compiler, ARM weak memory, OS scheduling or physical
device clocks. ARM compilation is not ARM execution or memory-model verification.

Latest execution evidence belongs in [callback results](../verification/callback/RESULTS.md).
