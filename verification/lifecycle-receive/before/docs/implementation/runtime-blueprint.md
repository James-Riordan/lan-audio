# Runtime blueprint: from verified components to first sound

Status: proposed integration contract, with the [pending block helper](../media/pending-block.md)
now implemented and exercised by pure tests and the TLS fixture. Lifecycle and
native worker files do not yet exist. This chapter refines
[WP04](work-packages/04-first-sound.md); it does not introduce another protocol.
Use the [execution sequence](completion-sequence.md) to choose the next change.

## Resolve these mismatches before connecting modules

| Existing boundary | Actual behavior | Required integration decision |
| --- | --- | --- |
| `session/receiver.zig`, `media/playout_window.zig` | V1 fixed-block sequence numbers and fixed sample dimensions | Do not feed v2 frame offsets into this window. Initial v2 TCP receiver uses the gate, one decoded pending block and the FIFO playback queue. Preserve v1. |
| `protocol/negotiation.zig` | Validates one contiguous v2 stream; advances on admitted record | Record acceptance, queue publication and callback consumption are three separate frontiers. |
| `host/audio_device.zig` | Default endpoint, 48 kHz stereo f32, period hint 240, bridge capacity 4096 | Initially admit only this actually configured application rate. Other legal wire rates require implemented host configuration/validation, not just Format.validate. Record backend conversion separately. |
| `audio/frame_queue.zig` | Short operations transfer whole-frame prefixes; producerPending is producer-only | Retain every unwritten suffix. Control/UI must not poll queue internals as a third owner. |
| `audio/callback_bridge.zig` | Capture overrun is atomic/sticky; totals and invalid-buffer diagnostics are callback-owned | Add qualified callback-safe status publication for runtime faults and live snapshots. Never concurrently read current plain totals. |
| `tls-zig/src/driver.zig` | One active operation; beginWrite copies plaintext; beginRead borrows output until completion | One transport worker serializes operations and keeps all buffers alive. A concurrent read thread cannot share this Driver. |
| `tls-zig/src/root.zig` | Validates certificates/ALPN; no public verified-peer fingerprint export | WP03 must supply a reviewed generic identity export before product allowlist policy can be enforced. |
| v2 finite-f32 domain | All finite words are valid, including values beyond nominal device amplitude | Network equality does not establish safe output amplitude. Define and report the output gain/clipping/headroom policy; never play extrema-based fixtures on hardware. |

These statements describe the inspected revision, not every possible future API.
Read the actual [source contracts](../reference/api-contracts.md) before coding.

## Owners and storage

One connection generation has a control owner, one serialized transport/media
worker per endpoint, and the native audio callback. The initial worker may both
decode and publish playback frames; a second playout worker is justified only
when timing/resampling needs it. If added, it needs its own bounded queue and join.

| Storage/resource | Sole mutable owner | Borrow/copy boundary | Reclaim only after |
| --- | --- | --- | --- |
| Configuration and generation identity | Control; immutable while running | Worker receives validated values | Worker exits |
| AudioDevice and bridge at stable address | Control for lifecycle; callback/worker own their specified fields | Native userdata borrows stable pointer | Native uninit joins callbacks and worker releases bridge reference |
| Capture queue | Callback producer, sender worker consumer | Copy complete frames to worker scratch | Both queue owners quiesce |
| Assembler, encoder bytes | Sender worker | beginWrite copies encoded bytes before assembler.commit | No pending borrows; worker exits |
| Socket, Engine, Driver | Transport worker | Native transport callbacks borrow Driver buffers for one call | Serialized cancellation/close/deinit completes |
| Parser/read buffer | Receiver worker | Message borrows parser storage; decode/copy before next feed | No outstanding parser/read borrow |
| Pending decoded block | Receiver worker | Queue.write copies only returned prefix | Pending suffix empty or classified discarded on abort |
| Playback queue | Receiver worker producer, callback consumer | Callback copies to native output | Publication closed, callbacks joined, worker exits |
| Status snapshot | Explicit publisher; control reads published snapshot | Atomic fields or race-free bounded message transport | All publishers/subscribers released |

Do not return a movable AudioDevice value after init. Never solve cleanup by
freeing storage while a native join is outstanding. Worker-owned TLS may remain
alive to transmit ACK after all downstream media owners have quiesced: joining
the thread that must send ACK before sending it would deadlock. Closing its media
publication role is distinct from joining its remaining transport role.

## Sender: a bounded iteration

Preparation validates configuration, authorizes a real channel, selects a fresh
nonzero unpredictable stream ID, exchanges OFFER/ACCEPT and opens the chosen
capture device in stable storage. Capture admission begins only after ACCEPT.
The receiver must already be able to receive/prefill at this point.

On each worker iteration, service cancellation/deadline first. Advance an active
TLS operation by bounded steps; preserve its original deadline. If it needs OS
readiness, wait interruptibly. Do not poll in an unbounded busy loop. If no TLS
operation is active:

1. Observe sticky capture loss/invalid-buffer status before reading. Loss aborts
   this generation; it cannot be relabeled as a contiguous source timeline.
2. Retain any scratch suffix from a previous partial assembler.push. Otherwise
   read complete frames from the capture queue into fixed worker-owned scratch.
3. Submit a fitting prefix to BlockAssembler; advance the scratch cursor only by
   the returned count. Recheck loss before publishing a block.
4. For a peeked block, encode into disjoint byte storage and apply the outgoing
   AUDIO to a candidate copy of Negotiation. Call Driver.beginWrite. Only after
   copied custody succeeds commit the candidate gate and assembler. A later short
   socket send resumes this same write; it never repeats either commit.
5. Zero input/zero accepted prefix is backpressure, not EOF. Wait for the relevant
   event or bounded wake cadence. Callback work must remain qualified and bounded.

Graceful stop closes capture admission and obtains native callback quiescence
while keeping the bridge allocated. The worker drains captured frames and all
scratch suffixes, finishes/commits the assembler tail, and sends END at
endPosition. A failed native stop requires the native uninit fence before treating
capture as quiescent. The control/worker coordination must not deallocate the
bridge while the worker drains it. Final native counters are read only after the
authoritative fence. Source loss makes this an abort, never successful EOF.

After END, preserve the TLS connection for the exact matching ACK and clean close
under an absolute completion deadline. No media retransmission on this same
connection follows uncertain write failure. Reconnect creates a fresh generation.

## Receiver: copy once into pending custody, publish prefixes

After host policy approves the peer, authorize Negotiation. Validate OFFER against
real endpoint capability and resource limits before ACCEPT. Opening a device is
not starting it: delay audible admission until prefill or the short-stream rule.

For each complete incoming record, validate it with a candidate gate. For AUDIO,
require no previous pending suffix, decode/copy the entire record into fixed owned
storage, then commit the candidate gate. Decode failure aborts without publishing
that record. Only after this copy may parser storage be reused. Queue.write moves
the returned prefix; advance pending.first_frame and its cursor by exactly that
count. Preserve the remainder before accepting another AUDIO record. The gate's
next_frame can lead queue publication by this pending count; that is intentional.

The initial ordered TCP path needs no reorder window. Gaps, duplicates or stale
stream IDs are protocol errors. Reordering/repair for a future transport needs a
new documented contract and cannot be smuggled into this FIFO design.

Retain coalesced plaintext suffixes in the worker read buffer. Do not beginRead
again while its buffer is borrowed or overwrite retained plaintext. One decoded
block, one parser, a bounded plaintext buffer and the fixed queue suffice for the
initial copy path. TLS may retain additional ciphertext/plaintext internally;
document those allocations separately instead of claiming this sum is total RSS.

## Priming, END and drain

Let K be playback queue capacity and P the chosen prefill in frames. Require
`1 <= P <= K`; do not accept a configuration that can never prime. Only queued
contiguous frames count toward P, not bytes in a socket or a partially parsed
record. Playback begins once at least P frames are queued. At authenticated END,
any nonempty final queued prefix may start below P. An empty stream needs no device
start. These rules prevent a short stream from waiting forever for nonexistent
future samples. If pending data remains, keep publishing it during drain.

For the initial no-resampler profile, the proposed completion attestation is:
all admitted source frames have been copied to callback output, publication is
closed, native callbacks have joined, and the final media count equals END.
Queue-empty alone is insufficient: FrameQueue releases slots before the callback
returns and before all callback-owned diagnostics are finalized. See the
[frame-identity argument](../design/receive-drain.md).

The control owner responds to a drain request by closing native admission and
joining callbacks without destroying still-borrowed storage. The worker receives
the completion fence and final counts, calls confirmDrained, then sends ACK using
candidate-gate/copied-write commit. This does not attest that speakers have
physically finished sounding. Backend buffer truncation/tail policy requires
separate native qualification; ACK naming and user-visible completion must respect
that distinction. Resampler tail accounting belongs to WP05, not this equality.

## Underrun and missing native input

An input callback with a missing buffer currently increments a plain diagnostic;
it does not give the worker a live, safe discontinuity signal. Add a sticky atomic
fault before using the adapter for continuous production capture. Reuse neither
the diagnostic callback_count nor a queue index as a lifetime fence.

Playback currently zero-fills shortages. Before making this a production policy,
publish enough qualified status to distinguish startup, running underrun and the
expected zero suffix after a known final END. A first-sound implementation may
conservatively abort on an unclassified running shortage; it must report it.
It cannot silently call that a flawless run. Rebuffer/remapping is separate WP05
work; the callback must never allocate, wait or call the lifecycle owner itself.

## Scheduling, cancellation and partial failure

The [lifecycle transaction contract](../design/lifecycle-transactions.md) specifies
the C02 ledger, methods, command/result tokens and bounded dispatch. In-flight
acquisitions retain their parent resources; cancellation cannot erase their pending
result or discard a late successful resource. A native fence does not by itself
permit release while a worker acquisition still borrows that parent.

The worker services at most one Driver operation and one bounded media work batch
before revisiting cancellation/deadlines. No newly processed byte extends a total
handshake/drain budget. An active beginRead cannot be abandoned to start a write;
choose operations from the protocol phase and preserve their borrowed buffers.
Unexpected reverse-direction application data while streaming must be rejected
through serialized bounded peer servicing or at the next legal read boundary;
never add another Driver owner. A stalled peer is escaped by cancellation/deadline.

Every acquisition adds one entry to a rollback ledger: stable storage, native
context/device, socket startup reference, socket, Engine, worker. Their dependencies
determine cleanup order; a simple reverse list is insufficient when callbacks and
workers share the bridge. First revoke admission, signal/wake owners, then join;
only afterward destroy resources whose borrowers have gone. A failed acquisition
does not create a resource to free. A duplicate stop request changes no ownership.

Graceful drain has a finite budget. Expiry switches to abort and records remaining
custody as discarded or peer outcome unknown; it must not report ACK success.
Scheduling and native joins are environment assumptions. If a native call hangs,
retain live storage and report failure; do not force-free it to satisfy a timeout.
Process isolation is a future architectural option if a hard external termination
bound becomes necessary, not an undocumented thread-kill mechanism.

Implement the [fault obligations](../verification/runtime-obligations.md) with
fake owners first, then real Windows adapters, then the actual Intel Mac. The
bounded models guide this work; matching action names does not prove refinement.
