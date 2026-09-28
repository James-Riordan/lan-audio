# Ordered frame custody and truthful completion

Status: original design argument plus executable bounded model. The
[pending helper](../media/pending-block.md) now implements copied admission and
prefix advance, with independent tests and a synchronous TLS fixture caller. No production
receiver refinement proof is claimed. The canonical model is
[ReceiveDrain.tla](../../spec/runtime/ReceiveDrain.tla), with the reviewed
[configuration](../../spec/runtime/ReceiveDrain.cfg). It complements the broader
[runtime ownership argument](../literate/runtime-argument.md).

## Domain and representation relation

Fix one authenticated healthy v2 generation without resampling. Source frame IDs
are the ordered integers 1..r in this model; production positions are zero-based,
so model ID i corresponds to source frame index i-1. A stereo frame is one ID,
not two scalar samples. Payload values, cryptography and channel authorization
are established by other components and deliberately abstracted here.

State r is the number of admitted/copied source frames. P is the pending decoded
sequence; Q is the copied playback queue; H is a callback-held sequence not yet
returned; C is the callback-consumed sequence after return. E marks authenticated
END, S marks playback started, A marks an active nonempty callback, J marks the
host quiescence fence, and K marks ACK emitted. Model names are received, pending,
queued, held, consumed, ended, started, active, quiesced and acked respectively.

The representation invariant is the sequence identity

`C ⧺ H ⧺ Q ⧺ P = <1,2,...,r>`.

This is stronger than a count sum: no admitted frame can disappear, be duplicated
or change relative order. It implies `r=|C|+|H|+|Q|+|P|`. The abstraction counts
logical downstream custody once. It does not assert that sender bytes or TLS
copies have vanished from memory; simultaneous physical copies are not additional
source frames. Source data not yet admitted is outside this receiver equation.

Define frontiers c=|C|, h=c+|H|, q=h+|Q|. Then
`0 <= c <= h <= q <= r`, with contiguous ranges [0,c), [c,h), [h,q), [q,r).
The pending block's cursor is q, while Negotiation.next_frame is r. Confusing
these two makes partial queue writes lose data even when protocol checks pass.

## Initialization and preservation

Initialization uses empty sequences and r=0; the identity holds. For a legal
admission of n frames, require P empty, no END/quiescence/ACK, and bounds on n and
r+n. Set P to the next n IDs and increase r by n. The old identity extended by
those n IDs is exactly the new identity. Production must copy/validate the whole
record into owned pending storage before advancing the gate frontier.

Publish n moves Prefix(P,n) to Q's tail and leaves Suffix(P,n). Sequence
concatenation associativity and `Prefix(P,n) ⧺ Suffix(P,n)=P` preserve the identity.
The admissible n is positive and no larger than pending length or free queue space;
zero progress is a stuttering step. Overwriting P with another record or clearing
all of P after a short write breaks this proof.

Enter n moves a prefix of Q into previously empty H and sets A. Return appends H
to C, clears H and A. Both preserve order by the same prefix identity. At most
one callback is active in this abstraction. Silence-only native callbacks do not
consume source IDs and are omitted; their timing and admission still matter to
the concrete join. Prime, END, Quiesce and ACK change none of the sequences.

The model checks CallbackCustody (`A iff H nonempty`) and Quiescent as separate
strengthening invariants. Real callbacks may be active with zero media, so the
refinement must map this Boolean to *nonempty modeled custody*, while separately
proving that the native fence joins every callback, including silence-only calls.

## Why queue-empty cannot justify ACK

With two admitted frames, a legal prefix is:

`P=<1,2> → Q=<1,2> → H=<1,2>, Q=<> → C=<1,2>, H=<>`.

The queue is empty at the third state, while a callback still owns the output
copy. An early ACK then overstates completion. A truthful fence requires END,
empty P/Q, no active modeled callback and J. By FrameOrder this entails
`C=<1,...,r>`. Only then may the healthy model set K.

Concrete queue slot release occurs during FrameQueue.read, before native callback
return; it is only permission for the producer to reuse slots. Native callback
quiescence and worker publication closure must be established separately. The
network owner sending ACK can remain alive after its media publication role closes.
The ACK's failure or loss creates an unknown remote completion outcome, not a
license to replay already submitted frames. Exactly-once audible output cannot
be inferred from an acknowledgement exchange across a failed connection.

## Short streams and conditional progress

Normal priming waits for Prefill queued frames, with 1<=Prefill<=Capacity.
Once END is known, start with any nonempty queued tail. If r=0, no callback or
device start is needed. Omitting the tail rule permits a one-frame stream with
Prefill=2 to wait forever despite all frames having arrived.

EndProgress is `ended ~> acked`. Its premises are weak fairness of positive
Publish, Prime, nonempty Enter, Return, Quiesce and ACK. No fairness of network
admission or END is assumed: progress is conditional on END actually being known.
Once END occurs, r is fixed. Finite P either publishes if there is room or waits
for a queued prefix to move through H to C. Normal or tail priming enables that
movement. Positive transfers and fair return eventually increase |C| until r;
the remaining fences then stay enabled and fair execution reaches ACK.

One can make the finite-transfer argument explicit with a nonnegative rank
`3|P|+2|Q|+|H|`: positive Publish, Enter and Return strictly decrease it after END.
Prime/fences do not increase it, and whenever the rank is nonzero the finite
enabling chain above supplies a fair decreasing action. Rank zero still requires
Quiesce then ACK. This is eventuality under fairness, not a real-time bound.

Abort is intentionally absent. A failed transport, invalid record, device fault
or deadline exits this healthy subprotocol into RuntimeOwnership's abort cleanup.
The models have not been mechanically composed. Whole-system completion needs
an explicit simulation relation for this exit and a discard/unknown-outcome ledger.

## Bounds, mutants and refinement duties

The standard configuration uses queue capacity 2, prefill 2, at most 3 frames,
and maximum block size 2. TLC checks all reachable interleavings in that finite
domain, not arbitrary streams or weak memory. Four deliberate mutations test
property sensitivity: overwrite pending, discard an unwritten suffix, acknowledge
before the fence, and require full prefill after END. The first two must violate
FrameOrder, the third AckFence, the fourth temporal EndProgress.

| Model transition | Planned concrete boundary | Obligation not supplied by the model |
| --- | --- | --- |
| Admit | PendingBlock.admit decodes into owned storage; fixture then commits candidate Negotiation | Real host authorization and native worker composition remain; copied finite admission and parser reuse have component tests. |
| Publish | FrameQueue.write then PendingBlock.advance(returned_frames) | Single producer and source order tested in the synchronous fixture; real concurrent worker/callback composition remains. |
| Enter/Return | Callback queue copy and native callback return | Actual ABI, acquire/release visibility, no callback allocation/wait, output buffer lifetime |
| End | Gate admits exact terminal frontier | Strict wire order and no accepted AUDIO afterward |
| Prime | Control starts configured device once | Revalidate selected endpoint, finite start failure path, race-free request/response |
| Quiesce | Publication closed plus media-owner/native joins | Empty-queue observation by authorized owner, all foreign references registered, no self-join |
| Ack | confirmDrained then accepted copied TLS write | Correct generation/frontier, actual send failure handling and remote uncertainty |

Current results and tool hashes belong to the
[runtime design phase](../../verification/runtime-blueprint/RESULTS.md). Extend the
model only when adding a new semantic distinction; do not inflate its state count
as a substitute for implementation evidence.
