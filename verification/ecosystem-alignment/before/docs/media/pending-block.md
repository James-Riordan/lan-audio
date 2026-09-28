# Pending receive block: retain every unqueued frame

Status: implemented pure [PendingBlock](../../src/runtime/pending_block.zig),
seven unit tests, and a caller in the authenticated v2 test receiver. Native
production receiver/lifecycle work remains open. This is the bounded C01 helper,
not a qualification of speaker playback or native callback drain.

## Problem and placement

One valid v2 AUDIO can contain more frames than the playback queue has room for.
FrameQueue.write copies a prefix and returns its frame count. Treating that as
acceptance of the whole record loses media. A pointer into Parser storage is not
owned custody either: the next feed can overwrite it.

PendingBlock copies/decodes one complete AUDIO into fixed owned storage, then
offers its unqueued suffix until the destination copies every frame. The build
creates a private `pending_audio` module importing the existing `lan_audio` core.
It adds no public core export, package, schema, second decoder, allocation, thread,
clock or OS dependency. The production receiver can import this same private module.

The original design took an already decoded block. Implemented admit instead takes
a borrowed v2 Message and invokes the existing decoder into owned storage. This
removes an intermediate decoded copy and makes parser lifetime explicit. Peer
authorization and continuity remain Negotiation/host responsibilities.

## Representation and lifetime

State is immutable validated format F, 2048 f32 slots, original position a, total
frame count n, consumed-prefix offset o, and a terminal aborted flag. Healthy state
obeys `0<=o<=n<=F.max_frames<=1024` and `a+n<=max_u64`. Occupied samples are exactly
storage[0..2n]; uninitialized slots are never read. The owned suffix storage[2o..2n]
represents [a+o,a+n). When o=n, peek is null and another admission may replace it.

One owner serializes calls. Input bytes must not overlap storage. Input borrow
ends when admit returns; Parser/packet storage may then be reused. A peeked slice
borrows this object only until its next mutating call. No live move/reset is allowed.
Public Zig fields describe representation, not a supported way to bypass methods.

## Call-by-call contract

| Operation | Success and state effect | Errors / obligations |
| --- | --- | --- |
| init(format) | Validated empty healthy owner | InvalidProfile; does not establish native capability. |
| admit(message) | Decode complete AUDIO into owned storage; set a/n/o afterward | Aborted first; Busy while a suffix exists; InvalidSamples for non-AUDIO; otherwise format/wire errors. Every failure preserves metadata and storage. |
| peek() | Borrow first_frame=a+o, frames=n-o and samples=storage[2o..2n]; null when empty | Aborted on terminal owner; never consumes or publishes. |
| advance(k) | Relinquish exactly k frames already copied downstream | Aborted, or InvalidAdvance if k>n-o. Zero is harmless even empty. Positive calls are not idempotent receipts. |
| abort() | Mark terminal, discard n-o, return that count once; repeated call returns zero | Invalidates borrows; does not erase storage, discard queued frames, stop transport or join owners. |

Busy precedes validation of another message. A blocked caller retains that
message's bytes and leaves its real protocol gate unchanged. It may retry only
while that borrow remains valid. Other invalid input terminates the connection
under runtime policy; this helper does not decide generation/retry/teardown policy.

## Preservation and failure atomicity

Init establishes n=o=0 and validated F. Admit requires no remaining suffix.
sampleCount bounds dimensions before slicing. Existing decodeAudio validates the
entire Message (stream, size/count, nonwrapping range, finite words) before its
first output write. No fallible operation follows that write before metadata
commit. Thus rejected admission cannot partially replace a block under the stated
disjointness assumption.

For 0<=k<=n-o, advance replaces o by o+k. The new owned range is [a+o+k,a+n);
exactly [a+o,a+o+k) transferred. Concatenating all copied prefixes yields the
original frame/sample order. Integer decoding and bitcasts introduce no sample
arithmetic, preserving signed zero, subnormals and finite extrema.

While healthy, `n = transferred_from_this_block + remaining`. Abort classifies
remaining as locally discarded exactly once. Already-queued frames belong to the
queue's separate consumption/discard ledger; counting them here would double-count
loss. Neither ledger proves remote or acoustic output. The fuller sequence law is
in [ReceiveDrain](../design/receive-drain.md).

Admit is O(n) bounded validation/decode work. Other methods are O(1). Payload storage
is 8192 bytes plus metadata/alignment. These bounds do not establish a real-time
deadline. Finite words beyond nominal output amplitude remain valid transport;
hardware gain/clipping policy is separate and extrema fixtures stay synthetic.

## Composition with gate, parser and queue

Validate incoming AUDIO on a candidate Negotiation, admit/copy into PendingBlock,
then commit the candidate. Busy or error must not advance the real gate. Its
accepted frontier may lead queue publication by at most one maximum block.

Obtain peek, call queue.write, then advance by exactly the returned frames before
reusing the borrow. Zero progress retains custody and requires appropriate waiting;
it is not EOF. Do not replay a successful positive advance: the count has no token
to detect a duplicate that still fits within the remaining suffix.

After admission, Parser storage is free for reuse. If the owner parses a following
record while a suffix remains, that new record's borrow must survive until it is
accepted/rejected; no later feed may invalidate it. The initial production design
avoids that complication by draining pending custody before the next AUDIO parse.
END, queue emptiness and callback/native quiescence are distinct obligations.

## Independent evidence

[Unit tests](../../tests/unit/runtime/pending_block.zig) construct integer payload
words independently of the encoder and compare source-indexed outputs through
queue capacities 1,8,32,4096 and record sizes 1,17,240,1024,3. They force short/zero
writes and cap iterations. Further tests cover complete failure atomicity, Busy,
cursor bounds, abort, u64 exhaustion, invalid profiles/zero AUDIO, and parser reuse
with a candidate gate left uncommitted on Busy. No physical devices are involved.

The [TLS fixture](../../tests/integration/tls_v2.zig) now decodes into PendingBlock,
copies through an eight-frame queue and checks words through a synchronous
three-frame reader. Its independent Python peer requires exact totals and positive
short/zero-write observations on successful nonempty receive. This is a composed
fixture path, not native callback lifetime or wall-clock playback qualification.
See [execution results](../../verification/pending-custody/RESULTS.md).
