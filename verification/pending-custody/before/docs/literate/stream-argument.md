# Following one stream: the program and its reasons

## 1. Decide what must survive the journey

The useful object is an ordered sequence of source frames, each containing one
sample per channel. Source frame identity, its numeric value, its playback time
and the lifetime of the memory carrying it are different obligations. Preserving
three of these while losing the fourth can still produce a click, stale audio or
a use-after-free. This separation determines the module boundaries.

The current path is a qualified foundation rather than the complete product.
The native capture fixture and the synthetic TLS receiver exercise different
segments; they do not constitute an end-to-end Windows-to-Mac run. The implemented
[v2 pure codec and gate](../protocol/v2.md) are separate from the existing PCM16
receiver and have not yet been integrated into production transport/device owners.

## 2. Borrow native memory; publish owned memory

Read [`AudioDevice`](../../src/host/audio_device.zig), particularly `init`,
`callback` and `deinit`, then [`CallbackBridge`](../../src/audio/callback_bridge.zig).
The backend owns the callback buffers. Their address is valid for that invocation,
not for the later network send. Copying into a fixed queue converts a temporary
borrow into application ownership. A pointer-only optimization would need a
different lifetime contract that the native callback does not currently supply.

Initialization passes `self` as native userdata. Therefore the entire owner must
remain at a fixed address from successful initialization through uninitialization.
`start` may trigger callbacks before it returns. A stack temporary moved into its
final owner after starting is already too late. Ordinary bridge totals are owned
by the callback and read after quiescence; adding live UI reads without a publication
mechanism introduces a data race even if those reads are called diagnostics.

Capture overflow is a discontinuity. The bridge copies only the fitting prefix
and records the dropped remainder. The [assembler](../media/assembly.md) and its
future native worker must not concatenate the
next callback as if no source time elapsed. The initial production policy is to
abort/report that stream; a future continuity policy needs explicit missing-frame
positions. Playback underflow has a different rule: fill every unprovided output
sample with zero, so no native buffer contains uninitialized output.

## 3. Prove when a slot can change owners

Read [`FrameQueue.write` and `read`](../../src/audio/frame_queue.zig). Let logical
producer/consumer frontiers be W and R. Occupied frames form `[R,W)` and satisfy
`0 <= W-R <= K`. Neither cursor is an index alone: the outstanding distance carries
the distinction between an empty and a full ring.

A write first observes the consumer release frontier, chooses a fitting whole-frame
prefix, copies at most two physical spans, and only then release-publishes W.
A read acquire-observes W, copies the available prefix and release-publishes R.
The second publication is as important as the first: it stops a producer from
overwriting storage while the consumer is still reading it. Each side has exactly
one owner. Adding a second producer invalidates the argument even if the cursor
loads remain atomic.

The modular proof and its no-lapping assumption are in
[the SPSC argument](../MATHEMATICS.md#9-spsc-publication-and-slot-reuse).
The public operations require nonoverlapping caller buffers and queue storage;
`@memcpy` is not an overlapping move. Whole-frame length and sole ownership are
caller preconditions, not an untrusted-input validation layer. Short transfer is
normal flow control: its untouched suffix remains caller-owned.

The important cost bound is two bounded span copies plus a fixed set of atomic
operations. This explains callback suitability under the supported profile; it
does not establish a numeric worst-case execution time or all-platform lock freedom.
The independent FIFO stress and rollover tests exercise different obligations:
ordinary stress is exceedingly unlikely to reach u32 wrap by itself.

## 4. Serialize values without inventing trust

Read [`v1.Parser`, `encodeAudio` and `decodeAudio`](../../src/protocol/v1.zig).
TCP/TLS supplies a byte stream, so one read can contain part of a header, multiple
records, or a header plus part of its body. The parser consumes a prefix and returns
at most one borrowed record. The owner must process that record before feeding
again, then continue with the unconsumed input suffix. Neither socket reads nor
TLS record boundaries are application message boundaries.

Header validation selects a bounded legal body size before copying that body.
Malformed framing poisons the parser; searching ahead for a magic sequence could
reinterpret attacker-controlled payload as a new header. The bounded parser avoids
allocation proportional to an untrusted length. `finish` distinguishes clean
application framing from a truncated record, independently of TLS close handling.

PCM16 is deliberately lossy for general finite f32 input. The proven local identity
is encode(decode(z)) = z for every s16 code z, not decode(encode(x)) = x for every
f32 x. Signed zero and values outside the PCM16 range illustrate the distinction.
The [v2 codec](../protocol/v2.md) preserves
finite f32 bit patterns during transport; clock correction and OS mixing remain
separate transformations with separate evidence.

## 5. Authenticate the channel before authorizing a generation

Read [`Receiver.authorizeChannel` and `accept`](../../src/session/receiver.zig)
alongside [`Session`](../../src/session/session.zig). The authorization method is
an attestation from the host after certificate, peer policy and protocol checks.
It cannot verify those checks by itself. An input field claiming authentication
must never trigger it. A START record binds one stream identity to one connection
and initializes the local generation. A remote ID and a local generation counter
are not interchangeable values.

The current TLS [Engine and Driver contracts](../reference/api-contracts.md)
separate TLS state from transport ownership. A successful `queuePlaintext` means
local custody, not delivery. `beginRead` borrows its output until the operation
finishes. Partial sends retain the unsent suffix; WANT_READ/WANT_WRITE preserve
the same pending write buffer and deadline. Cancellation is a signal to the owning
worker, not permission for another thread to destroy its Engine concurrently.

Certificate checks, implementation correctness and deployment identity are distinct
trust assumptions. The public test credentials prove none of the production
pairing policy. The adopted OpenSSL binaries and miniaudio header are dependency
boundaries, not source code proved correct by our models.

## 6. Decide which position can play next

Read [`Window.insert` and `tick`](../../src/media/playout_window.zig).
The logical live interval is `[r,r+K)`. Admission implements it by first checking
`q >= r`, then `q-r < K`; evaluating `r+K` directly would require another overflow
argument. Within this interval modulo K is injective. Therefore a presence bit can
represent a unique logical position even though the slot stores no separate tag.
This representation depends on never admitting an out-of-window position.

`insert` validates every sample before publication, uses a temporary to tolerate
overlap with its own payload storage, then marks the slot present. `tick` either
copies the expected block or fills silence, clears presence and advances the
timeline once. A late retransmission cannot undo an already committed deadline.
The output must not alias the window; the input overlap allowance is deliberately
not a universal allowance for every argument of every API.

In the existing Receiver, tick timing comes from the host. There is no drift
estimator hidden inside the ring and no automatic playout clock. At-most-once
submission by this window is not exactly-once acoustic playback by a speaker.

## 7. End a stream without confusing receipt with reclamation

An END names an exclusive frontier e. The receiver requires `r <= e <= r+K` and
every buffered position below e. The loop over physical slots checks this condition
in logical order relative to r; the physical array index is not a media position.
After admission closes, the ranking function `e-r` falls by one per tick. Reaching
zero finishes the serialized receiver, including silence for missing positions.

That event does not prove downstream queues empty or native callbacks joined.
Calling `Session.finishStop` in this pure kernel cannot establish those external
facts. The [runtime ownership argument](runtime-argument.md) makes the missing
composition explicit. A production completion ACK must name its frontier—received,
queued, callback-consumed or device-observed—rather than borrowing the strongest
meaning of the word "done".

## 8. Reproduce the program being explained

[`build.zig`](../../build.zig) owns the Zig module/test graph;
[`build.zig.zon`](../../build.zig.zon) owns package identity, pinned compiler floor,
sibling dependency paths and package inclusion. `.zon` is Zig Object Notation in
this build; ecosystem discussion of ZSON does not make it a runtime parser or a
replacement package manifest. A future alternate representation needs its own
specified grammar, authority and round-trip behavior.

The pure module, native audio module and opt-in TLS probe have different dependency
closures. `miniaudio-zig` is the upstream wrapper; product session/recovery policy
belongs in `lan-audio`. `tls-zig` owns generic TLS mechanisms. This organization
keeps a change to product buffering from silently changing a reusable TLS API.
Build evidence must name target and execution status: producing a Mac object on
Windows is not observing a Mac audio device.

Use the [proof ledger](proof-ledger.md) to review these explanations after a change.
An omitted assumption must become a contract, a checked guard or a stated gap;
it must not remain knowledge that only the original author possesses.
