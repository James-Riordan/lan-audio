# Cross-module implementation contracts

This document specifies system seams, most still planned. Format and the pure v2
codec/negotiation now exist; their canonical implemented contracts are in
[v2](../protocol/v2.md) and [negotiation](../protocol/negotiation.md). Other existing APIs are documented in the
[file reference](../reference/README.md). New signatures below are semantic
contracts; adapt syntax to the pinned Zig compiler while preserving ownership.

## I01 — Format, identity and time

`Format` contains sample rate in frames/s, channel count/order, scalar representation
and maximum frames per media block. Keep `FrameIndex(u64)`, `FrameCount(u32)`,
`MonotonicNanoseconds(u64)`, peer identity, stream ID and local generation distinct.
Never pass a byte count where a frame count is expected. Use checked products before
slicing/allocating. Source media frame zero defines one stream's timeline; every
reconnect creates a new unpredictable nonzero stream ID and local generation.

Source/sink sample clocks and host monotonic clocks are separate domains. One-way
latency cannot be measured by subtracting timestamps from unsynchronized hosts.
Record local events and uncertainty; use a calibrated common-clock/loopback method
for acoustic measurements. Certificate wall time is a fourth domain.

## I02 — Source and sink capabilities

`enumerate(allocator)` runs on the control owner, returns owned descriptors and
an explicit free obligation. A descriptor distinguishes capture, loopback and
playback; its opaque native device ID is never a permanent peer identity.
`open(selected_id, format, stable_storage)` returns a created device or a typed
failure with retained native diagnostic. Snapshot validity is bounded: revalidate
on open and report vanished/default-changed endpoints. Do not silently switch a
selected endpoint during a stream. `stop/deinit` run outside callbacks.

## I03 — Capture assembly and discontinuity

One worker drains the callback-owned capture queue into its owned block assembler.
`poll(destination)` yields `block{first_frame,count,format}`, `not_ready`, or a
terminal capture/discontinuity error. Partial frames are impossible; partial blocks
remain owned by the assembler. Check the sticky overrun flag after reading and
before publishing. Discard the partial assembly and restart the stream on overflow
in the initial policy; do not relabel discontinuous samples as contiguous frames.
No pointer into a native callback is retained. A downstream short send retains
exactly the unconsumed encoded prefix under one worker owner.

## I04 — Versioned byte boundary

Bounded parser feed returns consumed prefix plus a borrowed message. The caller
finishes processing/copying that message before the next feed. Invalid lengths,
versions, flags, finite-sample rules or truncated end poison the connection parser;
there is no magic-scanning recovery inside authenticated bytes. A changed format
starts a new negotiated stream, never mutates an active decoder in place.
Wire integers have explicit byte order; alignment-dependent pointer casts into
received bytes are forbidden. The v2 packet specification is in WP02.

## I05 — Authenticated transport owner

`SocketTransport` owns its native handle and process/network startup reference;
send/receive callbacks implement `tls.host.Transport` exactly. Would-block is null;
receive zero is raw EOF; send zero is failure. Counts never exceed supplied buffers.
One worker serializes Driver operations and passes a fresh monotonic timestamp per
step. Cancellation from another thread is only an atomic flag plus wake mechanism.
Do not close the socket or Engine from that other thread. Preserve unsent ciphertext,
retained input suffixes and absolute deadlines through every scheduling round.

Channel policy additionally binds peer certificate identity, authorized role,
expected ALPN and negotiated format to the stream. TLS validation is necessary but
does not by itself authorize every certificate signed by a configured CA to play
audio. Host-supplied `authorizeChannel()` is called only after that policy succeeds.

## I06 — Rendering and scheduling

The network worker owns Receiver/Window; the callback never calls their methods.
A playout worker schedules media positions from a monotonic media timeline and
submits validated PCM into the playback queue. Retain a partial queue write and
resume it before advancing to the next block. Prime contiguous data before opening
audible admission. An underrun advances the physical device clock, so subsequent
data must follow an explicit recovery/rebuffer policy; simply replaying all late
data would grow latency without bound. END first drains media, then queue ownership,
then joins the device, then acknowledges the negotiated completion meaning.

## I07 — Clock correction

The estimator consumes timestamped cumulative capture/render frame counts and
queue occupancy from bounded snapshots. It outputs rate ratio estimate, confidence
and discontinuity status, not a guessed globally synchronized time. The controller
uses a filtered estimate and occupancy error with bounded ratio/slew and anti-windup.
Device loss, reconnect or a timestamp discontinuity resets estimation after owners
join. Resampler state belongs to one worker; no retuning/reset races the callback.
Log applied ratio and any sample-quality processing so bit-exact transport claims
remain distinct from corrected output samples.

## I08 — Control, persistence and telemetry

One application owner transitions `configured → connecting → priming → running →
stopping → stopped/failed`. Exact product states are separate from the existing
session kernel. Every stage has a rollback obligation and one cleanup owner.
Status snapshots contain counters/reasons and selected device/format/peer names,
not private keys or raw audio. Routine telemetry is opt-in/minimal and bounded.
Persist identities through an atomic replace and restrictive permissions or the
platform credential facility; corrupted stores fail closed with a recoverable UI.

## I09 — Errors and operations

Public categories: configuration, unsupported target/format, endpoint missing,
permission denied, peer unauthorized, protocol violation, source discontinuity,
network timeout/disconnect, playout underrun and internal contract violation.
Preserve native cause for local diagnostics. Retry only transient categories under
a bounded policy; malformed or unauthorized peers never trigger silent downgrade.
Each work package specifies validation-before-mutation and cleanup on each exit.
