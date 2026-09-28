# Receiver completion composed with resource ownership

C02b implements a bounded receiver completion path in
[`ReceiveDrain`](../../src/runtime/receive_drain.zig), using the actual
[`Controller`](../../src/runtime/lifecycle.zig), `PendingBlock`, `Negotiation`
and `FrameQueue`. Its caller is the independent fake-owner lifecycle suite.
It is private to this application. There is no new public core export, socket,
native executor, physical output test or production credential default.

This closes a useful receiver subset of C02, not the complete work package.
Sender graceful stop, native start/fault/snapshot adapters and real concurrent
workers remain separate obligations. The exact source-scoped observations are in
[the new results](../../verification/lifecycle-receive/RESULTS.md).

## Ownership profile and why the fence order changes

The three resources remain storage, device and worker. Stable storage contains
the queue, pending block and media owner. The worker aggregate now explicitly
includes the serialized transport owner; its release must include socket/TLS
cleanup in a future adapter. This is an adapter contract, not implemented native
aggregation. There is still one global issued effect/result reservation.

On abort, the original order remains worker join/release, device fence/release,
storage release. An outstanding operation, including ACK/close, must settle first.
The generation-scoped stop/deadline intent is available independently of that
reservation: a real blocked executor must observe cancellation and wake without
requiring a second operation slot. The pure controller cannot interrupt an OS call.

Graceful receive needs a different partial order:

`END -> pending empty + queue empty + publication closed -> native fence ->
ACK copied custody -> secure close -> worker join/release -> device/storage release`.

The worker remains owned while the non-destructive native fence runs. The media
owner has permanently closed publication and must cease device access, but the
transport role remains available for ACK. No device destruction occurs with the
worker alive. C03 must provide the real non-destructive fence; today's combined
`AudioDevice.deinit` is not evidence that this operation exists. A native fence
seals callback admission and waits for every callback return, including callbacks
containing only silence. Queue slot release alone provides neither guarantee.

## Actual calls and failure atomicity

`ReceiveDrain(capacity).init` borrows stable controller/queue addresses after the
three resources are ready. It accepts only a receiver gate already in streaming
phase at source frame zero, an empty queue, and `1 <= prefill <= capacity`.
Authentication and accepted format have already been established by its caller.
Initialization neither authorizes a peer nor opens/starts anything.

`admit(generation, message)` validates a candidate gate before committing it.
AUDIO is copied into PendingBlock before the gate frontier advances. A live
pending suffix returns Busy without consuming another AUDIO record. END may be
admitted with pending frames; it freezes the exact terminal frontier and invokes
`Controller.requestDrain`. Other protocol rejection requests abort but retains
earlier media custody. The rejected candidate is not committed. A later poll or
publish from an old generation cannot act on a reused queue.

`publish` executes one bounded queue write and advances only its returned prefix.
Zero acceptance is a stutter. `takeStart` returns start authority at most once,
when prefill is reached or END has arrived with any nonempty queued tail. A zero
END returns no start authority. This is an authorization, not evidence of a native
start; failure must escalate to abort. The real adapter must separate acquisition
from start, unlike the deliberately permissive callback-admission fake.

`pollDrain` inspects the actual PendingBlock and producer-side queue occupancy.
Only END plus both empty allows `observeQueueDrained` to close publication. The
controller then issues a native fence, never an ACK based on emptiness alone.
This sole-producer closure forbids subsequent publications while the fence runs.

`ackMessage(token)` requires the exact currently issued send_ack token. It returns
a fixed, payload-free descriptor; the executor must encode it and submit it once.
`completeAck` computes a candidate `confirmDrained`/ACK gate transition and commits
it only for `ack_copied`, after controller token/result validation. A failed write
settles as transport_failed and aborts; an uncertain outstanding write retains its
reservation. No retry of a possibly accepted ACK is implied. A late valid result
after cancellation records its actual custody but cannot restore graceful intent.

The transport executor has two operations: send_ack and close_transport. Results
are respectively ack_copied/transport_failed and transport_closed/transport_failed.
`transport_closed` must attest the defined secure shutdown, not merely socket EOF
or a local close request. The future adapter owns this qualification. Wrong token,
result kind, generation or terminal frontier changes no controller fact.

`accountAbort(generation, copied)` is permitted only after worker join and device
fence while storage is still held. The supplied final copied frontier must come
from a qualified final snapshot. It checks exact conservation before discarding
the pending suffix and returns separate pending/queued discards. Repeated calls
return the original report; a changed copied count is rejected. The allocator
executor must preserve this report before destroying the aggregate storage.
It must not inspect this helper or queue after release. Real fault/snapshot
qualification remains C03; this method cannot manufacture a trustworthy counter.

## Mathematics, bounds and progress premises

Fix one healthy, negotiated receiver generation with no DSP. Let S be the finite
sequence of admitted source frame identities. At reconciled boundaries,

`S = C ++ H ++ Q ++ P`,

where C has returned from callbacks, H is held by entered callbacks, Q is queued,
and P is the copied pending suffix. Admission extends S and P together; publication
and callback reads move prefixes without changing order. A queue read can empty Q
while H remains nonempty. The native fence establishes H empty and seals further
entry. With END, publication closure and P=Q=H=empty, C=S. This is a manual
representation argument conditioned on truthful native results, not a formal
implementation refinement theorem or an acoustic-delivery claim.

On abort, after joins/fence, copied C, queued Q and pending P partition admitted
frames by count. `accountAbort` checks `copied <= admitted`,
`queued <= admitted-copied`, then `pending == admitted-copied-queued`. Ordered
subtraction prevents overflow; no saturated counters are silently accepted. It
does not classify unadmitted network bytes, post-device acoustic output or source
loss before receiver admission. Those require different observations.

After END the healthy rank `3*|P| + 2*|Q| + |H|` decreases on positive prefix
transfers/return. Tail priming removes the sub-prefill deadlock. Eventual completion
requires fair publication/callback return, truthful native fence, and eventual
transport results. No wall-clock bound follows. Abort bypasses consumer drain;
the old cleanup rank and pending-acquisition parent-lifetime argument still apply.

Each control call uses fixed state and constant work, except AUDIO validation/copy
and publication bounded by the negotiated maximum (at most 1024 stereo frames).
Storage is one maximum-sized PendingBlock plus the fixed queue and scalar facts.
No callback runs these methods. No method allocates, blocks, logs, controls a
device or calls a network API. The helper and controller must not be copied or
relocated while their associated owners or borrowed addresses are live.

## Truthful outcomes and evidence limits

The receive snapshot distinguishes local pending/drained/interrupted, ACK
not_attempted/copied/unknown, remote unobserved, and secure close
not_attempted/clean/failed. A receiver sending ACK has no further application
confirmation that the sender observed it, so remote remains unobserved even after
clean close. Resource cleanup is separately represented by held/pending debt and
phase stopped. An ACK failure can leave local drained with successful cleanup;
these facts never turn into remote or acoustic success. Timeout before the native
fence conservatively retains interrupted status after a late return.

R03/R04 now execute zero, one-frame, partial and maximum block receive schedules.
R05 pauses the last callback after queue-empty and separately uses a silence-only
callback. R06 exercises full-queue abort with a fake owner and exact residual
counts, plus an unresolved ACK across deadline. R07/R08 retain the original
acquisition/cleanup/token tests and add graceful fence failure, repeat drain,
deadline escalation and old-generation media rejection. These are deterministic
fake-owner subsets, not real blocked-socket wake or native start-failure evidence.
The oracle builds integer sample words independently and checks each copied
prefix against source indices. Its resource/borrow facts are separate from the
controller ledger. Deliberate production-source mutations test its sensitivity.

Next: complete sender-side graceful custody/END/remote-ACK outcomes and refine
fault/start/final-snapshot observations before declaring full C02. Then C03/C04
must make the native and network adapter promises true. The unavailable Intel
Mac, exact macOS/SDK/device and two-host acoustic acceptance remain unexecuted.
