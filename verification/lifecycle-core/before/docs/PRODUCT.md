# Product contract

## Ecosystem requirement

This prospective Zigadel ZApp participates in James's wider JCR ecosystem through
explicit, versioned boundaries. The [integration contract](architecture/ecosystem-integration.md)
owns optional MetaOS/context, ZSON, Quartz/Docz, observability and deployment seams.
Simple user actions share one tested lifecycle; typed identities, capability-aware
adaptation, immutable operation configuration and truthful recovery are requirements.
The first local audio path does not require a hosted account or the whole ecosystem.
These requirements extend preparation; they do not mark any A1-A10 gate complete.

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

## Quality and resilience requirements

James's stated objective is maximum practical robustness and fidelity, including
operation with an unreliable Windows network adapter, with Cap'n Proto-style
efficiency. This is a product requirement; the existing test profile and timing
examples are implementation evidence, not a ceiling on product quality.

* Preserve captured sample information through network delivery. Avoid lossy
  compression, silent precision reduction, clipping and unnecessary conversions
  in the fidelity-first profile. Specify the exact capture-to-decoder boundary for
  bit-exact comparisons; Windows mixing and independent device clocks prevent a
  blanket claim of bit-perfect physical end-to-end playback. If clock correction
  requires resampling, qualify its numerical/audio error and expose that fact.
* Tolerate measured packet loss, burst loss, variable delay, reordering, short
  stalls and adapter disconnect/reconnect within a declared operating envelope.
  Evaluate adaptive buffering, deadline-aware retransmission and, where justified,
  forward error correction against measured failures. These are candidate recovery
  mechanisms, not yet implemented guarantees or a predetermined transport choice.
* Prefer retaining source fidelity and increasing recovery time within an agreed
  latency budget before reducing sample quality. The user's acceptable latency
  remains to be established; the illustrative 100 ms p95 target below is provisional.
  Recovery traffic must fit available throughput and avoid aggravating congestion.
* Use preallocated bounded storage, direct binary layouts, minimal justified copies,
  bounded callback work and measured CPU/latency/traffic costs. Cap'n Proto is an
  efficiency reference, not an automatically selected dependency or proof that
  this implementation has equivalent performance. Cryptography and necessary
  sample conversion still have costs; zero-copy claims need a named boundary.
* Diagnose network loss separately from capture gaps, host scheduling stalls and
  output clock mismatch. Software cannot recover samples never captured or sustain
  live playback through an outage longer than its available buffered/recoverable
  media. Concealment and inserted silence must be counted as degraded delivery.

Qualification must combine deterministic impairment tests with traces and sustained
runs on the actual Windows adapter and MacBook. Record burst lengths, outage time,
throughput, RTT/jitter, deadlines missed, exact samples recovered, concealment,
buffer occupancy, clock drift, CPU, allocations, copies and recovery bandwidth.
State the tested envelope instead of promising immunity to every hardware failure.

Reference: [Cap'n Proto encoding](https://capnproto.org/encoding.html) explains its
in-memory/wire representation; audio timing and network recovery are separate
engineering obligations.

## Current experimental profile

The reference kernel accepts fixed-size finite `f32` PCM blocks. The implemented
experimental `jcr-audio/1` wire profile is 48,000 frames/s, two channels,
240 frames/block (5 ms), little-endian signed PCM16 in left/right interleaved order.
Its [transport contract](TRANSPORT.md) defines 36-byte record headers and a fixed
960-byte media payload. The current TLS/TCP stream does not promise one record per
network packet or datagram. Any future datagram profile must prove its actual MTU
and cryptographic overhead budget separately.

The current PCM16 encoder quantizes f32 input. That is sufficient for existing
framing tests but does not meet the fidelity-first requirement for higher-precision
captured samples. A negotiated fidelity-preserving representation needs a separately
versioned wire profile, bandwidth accounting and exact sample-preservation tests;
do not silently change the meaning of `jcr-audio/1`.

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

A full capture queue drops newest whole frames with an explicit counter and sticky
discontinuity flag; it must never block the callback. The fixed playout window rejects stale, late,
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
| A8 | Fidelity-preserving media path | Exact captured-sample versus decoded-sample tests at the declared boundary; negotiated representation; clipping, quantization and resampling evidence |
| A9 | Robustness with the actual Windows adapter | Deterministic impairment/replay tests plus sustained Windows-to-Mac runs; documented loss/jitter/outage envelope, recovery limits and all degraded-output counters |
| A10 | Measured low-overhead implementation | Per-block copies/allocations, CPU and latency distributions, memory bounds and wire/recovery overhead at the selected fidelity and latency budget |

The kernels contribute to A3 and abstract A4. The Windows loopback probe provides
real, bounded evidence toward A2/A3 using public synthetic identities and samples;
it does not establish production pairing or authorization policy. A1, A5 and A6
remain unmet. No physical device integration is implied by successful TLS tests.
The expanded A8-A10 quality requirements remain unqualified. Earlier verification
receipts describe their recorded source revisions; this requirements update does
not retroactively upgrade those results or change the implemented wire protocol.
