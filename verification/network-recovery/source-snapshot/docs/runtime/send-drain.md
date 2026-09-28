# Sender custody, capture fencing and remote attestation

C02c implements [`SendDrain`](../../src/runtime/send_drain.zig) with the same
[`Controller`](../../src/runtime/lifecycle.zig) already used by the receiver.
It composes the actual capture queue, BlockAssembler, v2 encoder and Negotiation.
Tests use independent source words and fake resource/transport owners, including
one sender-to-receiver record exchange. This is not yet a native network worker.

## Representation and authority

One serialized worker owns the sender helper, one BlockAssembler, a fixed scratch
array and a fixed encoded-record array. It borrows stable controller, queue and
sticky-fault addresses until cleanup. The source callback owns the queue producer;
the helper owns its consumer. An authorized sender gate must already be streaming
at source frame zero. Initialization does not authenticate or acquire a resource.

The three-resource profile remains storage/device/worker. The worker aggregate
will own the transport and its copied write buffers. There is one global issued
effect/result reservation. Sender configuration and receiver configuration are
mutually exclusive for a generation. No public core export was added.

The controller's sender facts distinguish committed source frames, one offered
block, graceful intent, a final frontier, END copied custody, remote attestation,
local transfer status and secure-close status. Existing held/pending facts and
stopped phase independently represent resource cleanup. A confirmed remote ACK
can coexist with failed secure close, deadline expiry or incomplete cleanup.

## Prefix custody and transactional writes

`pump(generation)` performs at most one queue read, bounded by the free space in
the current assembler block. Thus it never removes a larger prefix than it can
retain. Scratch owns the read prefix until validation and assembler copying
succeed. Invalid samples remain in scratch for final accounting; they cannot
silently disappear after queue slots have been released.

The worker checks the sticky source fault before the read, after the read, before
record preparation and at record completion. Fault observation requests abort
without resetting an outstanding operation or invalidating its retained media.
A simultaneous fault can occur after a transport copy; the copy is recorded,
while successful terminal stream completion is prohibited. Source loss is not
repaired by concatenating the surviving frames.

When a full or sealed partial block is ready, `offerAudio` reserves its frame
count. `takeEffect(transport)` grants one send_audio token. `prepareRecord` validates
that exact token, encodes into fixed owned bytes and prepares a candidate gate.
Its returned borrow remains stable through completion. Repeating preparation
does not grant a second submission. The future Driver executor must make exactly
one logical write attempt for each issued authority.

`completeRecord` distinguishes:

| Result | Media/gate mutation | Subsequent authority |
| --- | --- | --- |
| write_rejected | No copied custody; block, frontier and gate remain unchanged | A new token may retry the same block |
| write_copied | Commit assembler and gate exactly once | The transport owns its copied bytes and all short-send progress |
| transport_failed | Retain the offered range as uncertain; abort | Never replay a possibly accepted range |

The controller validates token identity and legal result before media commits.
Under the representation contract, the subsequent assembler commit cannot fail:
the block remains ready and no mutating helper call can consume it while the
token is issued. Rejected inputs preserve logical custody; encoding scratch may
be changed on preparation failure but is not returned as a valid borrow.
Namespace/frontier arithmetic is checked before issuing new authority.

No queue read or assembler mutation accompanies byte-level short sends. The
independent test transport copies a whole record, emits that copy in seven-byte
pieces and checks reconstruction without additional frame commits.

## EOF and completion order

Temporary queue emptiness is not EOF. Graceful `requestStop` first requests the
non-destructive capture fence. The callback may publish its final frames while
that operation is pending. Existing writes must settle before the one global
slot permits the fence; cancellation/deadline never erase their custody.

After native callback quiescence, the worker drains the queue, seals the assembler,
submits its final partial block, and attests the exact committed frontier. Only
then may the controller issue send_end. A zero stream sends no AUDIO. After
end_copied the controller issues await_ack. `completeAck` validates the incoming
kind, stream and exclusive frontier with the real gate. A malformed ACK settles
the read as transport_failed and aborts without claiming remote confirmation.

The healthy partial order is:

`capture fence -> queue/assembler drain -> END copied -> exact remote ACK ->
secure close -> worker join/release -> device/storage release`.

A late valid ACK after timeout remains truthful remote attestation; it does not
clear the deadline or restore graceful cleanup. Local transferred means all
admitted source frames entered copied transport custody, not that they sounded
at the destination. Receiver ACK attests its declared callback fence, not acoustic
delivery. An unresponsive transport must retain its operation/result slot until
resolved; real interruptible I/O remains a C04/C05 adapter obligation.

## Conservation and bounded work

Let A be source frames accepted by the capture queue, T the sequence committed to
copied transport custody, B the assembler's pending sequence, X retained scratch,
and Q the remaining capture queue. At reconciled healthy boundaries,

`A = T ++ B ++ X ++ Q`.

Normally X is empty: one call moves a fitting Q prefix through X to B. Validation
failure may leave X nonempty while initiating abort. A copied write moves B to T;
a rejection moves nothing. The invariant describes logical custody, not the
number of physical copies in memory. Independent tests compare integer sample
identities, including signed subnormal words, with a separate source list.

After abort and worker/native fences, `accountAbort` checks the qualified final
accepted-capture count against `committed + assembler + scratch + queued`. Ordered
subtraction avoids overflow. The one uncertain write is a subset of retained B;
the report partitions frames into copied_to_transport, uncertain_transfer and
discarded_local. It must be copied out before storage release. Saturated native
counters cannot satisfy an exact accounting claim. Missing/unaccepted source
frames remain separate native loss diagnostics.

Space is fixed: one maximum block, one read scratch block, one maximum wire record,
the queue and scalar state. Work per call is constant except bounded sample
validation/copy/encoding. This deliberately keeps simple copied ownership; no
zero-copy or throughput claim is made. Eventual completion requires cooperative
callback return, native fencing, transport results and fair worker scheduling.
Neither this argument nor tests prove a real-time termination bound.

## Evidence and remaining implementation

[Recorded results](../../verification/lifecycle-send/RESULTS.md) cover both roles,
source faults, zero/partial streams, exact retry/commit behavior, uncertain writes,
old generations, deadline races, ACK validation and source counter limits. The
consumer-only queue availability observation has rollover coverage. Four new
sender mutations complement ten retained resource/receiver mutations.

The same increment adds [live callback fault publication and a qualified subset
of native fencing](native-fence.md). Endpoint selection/validated formats,
device-loss notification, asynchronous backend fencing, full partial-native-failure
adapters, socket/identity policy and actual production worker threads remain open.
No foreign execution, two-host delivery or production readiness follows from the
pure sender/receiver exchange.
