# Product contract

## Purpose, scope and terminology

The product sends an explicitly selected audio source on one authorized peer to an
explicitly selected playback sink on another peer. The first end-to-end target is
Windows system-loopback capture to Mac speakers on the same LAN. Later microphone,
reverse-direction, Linux, duplex and multiple-sink profiles require their own
capability and timing evidence; cross-platform does not imply every role on every OS.

An **audio frame** contains one sample per channel. A **block** contains `N` frames.
A **packet** is a transport unit and need not equal one block. A **session** is an
authenticated, negotiated source-to-sink relation. An **epoch** separates runs of
a local session; it is not a secret or peer identity. A **playout position** identifies
one block's place in that epoch. Rendered silence occupies a position; it is not a
successfully received media block. Device submission is not proof of audible output.

## Intended first profile

The reference kernel accepts fixed-size finite `f32` PCM blocks. The implemented
experimental `jcr-audio/1` wire profile is 48,000 frames/s, two channels,
240 frames/block (5 ms), little-endian signed PCM16 in left/right interleaved order.
Its [transport contract](TRANSPORT.md) defines 36-byte record headers and a fixed
960-byte media payload. The current TLS/TCP stream does not promise one record per
network packet or datagram. Any future datagram profile must prove its actual MTU
and cryptographic overhead budget separately.

The illustrative receiver uses capacity 12 blocks (60 ms of window span), target
prefill four blocks (20 ms), and a measured total latency target of 100 ms at p95
on a documented LAN/hardware profile. None is a measured result. Capacity and
contiguous prefill are distinct: four out-of-order blocks do not necessarily mean
the next four positions are ready. No arbitrary latency guarantee follows from LAN.

## Complete user journey and failure behavior

1. Inspect local source/sink capabilities and permissions without starting capture.
2. Select a peer explicitly; discovery is an untrusted address hint, never identity.
3. Authenticate/pair using a reviewed transport and bind the peer, protocol version,
   role, media profile and stream identifier to the session transcript.
4. Open source/sink on control owners, reserve bounded storage and establish a new
   local epoch. Start capture only after an explicit user start action.
5. Convert bounded blocks, send under network pacing/congestion rules, authenticate
   incoming media, reorder it within the bounded window and render at clock deadlines.
6. Report underrun, reconnect, permission denial, missing backend, device loss and
   rejected peer distinctly. Do not mislabel concealment as received media.
7. Stop admission, stop/join devices and workers, drain ownership, release keys and
   buffers, then permit reuse. Restart discards stale generation data.

A full capture queue drops a newly completed block with an explicit counter; it
must never block the callback. The fixed playout window rejects stale, late,
duplicate and too-distant positions. Missing positions produce silence once and
advance. A future concealment algorithm changes the audible policy, not sequence
identity. Repeated loss triggers a user-visible degraded state and a bounded
recovery policy, whose thresholds need measured justification.

## Acceptance obligations

| ID | Claim | Required evidence |
|---|---|---|
| A1 | Windows source → Mac sink actually works | Physical-device run with OS/driver/permissions, source selection, negotiated format and reproducible setup recorded |
| A2 | Peer authorization precedes media | Negative wrong-peer/wrong-key/replay tests against the integrated transport; no plaintext fallback |
| A3 | Bounded media admission and at-most-once positions | Pure kernel tests, TLC scope, parser/adapter fuzzing and integrated reordered/duplicate/late-packet traces |
| A4 | Safe stop/restart/device loss | Active-callback stress test, repeated cycles, worker joins and OS hotplug/permission failure cases; no stale playback or use-after-free |
| A5 | Latency and resource budgets | At least a 30-minute documented run; p50/p95/p99/end-to-end latency, underruns, CPU, memory, traffic and device-clock drift; instrumentation and uncertainty described |
| A6 | Portable packaging | Clean Windows and Mac installs, dependency custody, launch/stop/uninstall and rollback; Linux is separately qualified |
| A7 | Reproducible development | Exact source/toolchain/profile, command receipts and meaningful test failures; no source-hash refresh used to hide a change |

The kernels contribute to A3 and abstract A4. The Windows loopback probe provides
real, bounded evidence toward A2/A3 using public synthetic identities and samples;
it does not establish production pairing or authorization policy. A1, A5 and A6
remain unmet. No physical device integration is implied by successful TLS tests.
