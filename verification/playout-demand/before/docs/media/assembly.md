# Capture block assembly: preserve the source timeline

Status: implemented pure [`BlockAssembler`](../../src/media/block_assembler.zig),
tested independently of devices and composed with the v2 codec/gate. Native
capture queue integration and its worker lifecycle remain unfinished.

## Problem, owner and representation

The audio backend may supply arbitrary callback frame counts. A 240-frame period
hint is not a promise of 240-frame callbacks. The network protocol accepts records
of at most M negotiated frames, including a shorter final record. One worker must
copy successive complete-frame prefixes into ordered blocks without borrowing
native callback memory or inventing positions for discarded samples.

The assembler owns 2048 f32 slots (8192 payload bytes), a validated Format,
pending count P, committed source frontier W, and sealed/failed flags. M is
1..1024; `0<=P<=M` and `W+P<=max_u64`. Occupied storage is exactly the first 2P
sample slots. Unoccupied undefined slots are never read. Format stays fixed for
the stream, and a single owner serializes every operation.

## Operations and their boundaries

| Operation | Meaning | Failure / lifetime |
| --- | --- | --- |
| `init(format)` | Validate format; return empty owner at frame zero. | InvalidProfile; device support is a separate host decision. |
| `push(input)` | Copy a fitting prefix of complete stereo frames; return accepted frames. | Odd sample count, nonfinite accepted prefix or overflowing frontier reject before writes. Input must not overlap storage. |
| `peek()` | Borrow full block, or sealed nonempty final partial block; otherwise null. | Discontinuity if poisoned; repeated peek does not advance. Mutating calls invalidate borrows. |
| `commit()` | Release one available block and advance W by its frame count. | NotReady without a block; do not call until downstream copied/retained custody succeeds. Repeated commit is not idempotent. |
| `finish()` | Seal source input; expose any last partial block. | Idempotent for a healthy sealed stream; does not copy, send or commit pending samples. |
| `endPosition()` | Return exclusive END frontier once sealed and empty. | NotDrained until all accepted samples committed; never fabricates an empty AUDIO record. |
| `discontinue()` | Poison stream, discard pending data and prohibit future publication. | Idempotent terminal action; previous borrows may no longer be used. |

When full, push returns zero and leaves the caller's suffix owned by the caller.
It validates only the accepted prefix; a NaN in an unaccepted suffix is not silently
accepted and must be reconsidered when that suffix is submitted later. A worker
must neither discard an unaccepted suffix nor repeatedly busy-spin against a full
block. Obtain/copy/send the block, commit it, and continue the retained suffix.

## Conservation and ordering argument

For a healthy stream, W is the count of committed source frames and P the count
of accepted but uncommitted frames. Init has W=P=0. Push chooses
`n=min(offered_frames,M-P)`, checks `W<=max_u64-(P+n)`, validates all 2n words, copies
them after the existing 2P prefix, and sets P'=P+n. Thus W+P rises by exactly the
accepted count, P stays bounded and sample order is preserved.

Peek returns the range `[W,W+P)` only when full or sealed. Commit then changes
`(W,P)` to `(W+P,0)`, preserving the accepted-frame total and making emitted ranges
contiguous/nonoverlapping. Failure cannot partially publish a block: every fallible
push check precedes its first copy. Finish changes no counts. When sealed and empty,
the only truthful exclusive END position is W. Discontinuity deliberately discards
P and terminates the healthy-stream argument; a host loss ledger must count that
discard separately instead of extending this conservation identity past failure.

Push is O(accepted samples), using one bounded copy and a finite-word validation
scan. Peek/commit/finish/endPosition/discontinue are O(1). The assembler has no
heap allocation, clock read, wait or system call. This is an operation-count bound,
not a numeric execution-time claim. No method is safe for concurrent callers.

## Commit with the protocol and transport

The sender obtains a borrowed block, encodes it into worker-owned byte storage,
validates the outgoing event on a candidate Negotiation value, and transfers those
bytes into TLS copied pending-write custody. Only then commit the candidate gate
and assembler. A partial transport send resumes that already accepted write; it
does not reapply the protocol event or commit the assembler again. Any subsequent
transport failure terminates the connection rather than rolling back into an
uncertain byte stream. See [the negotiation commit contract](../protocol/negotiation.md).

Sealing is allowed only after source admission has closed, outstanding capture
callbacks have quiesced, the capture queue is drained and every caller-held suffix
has been consumed. A full block at EOF still needs one commit. A partial final block
also needs a commit. An empty stream produces END at zero and no AUDIO record.

## Source overflow is not EOF

The existing bridge records a sticky capture-overrun flag. The worker checks it
before reading and again before publishing read samples. A later callback that
publishes samples after an overrun is ordered after the sticky flag write; the
queue's release/acquire publication and the worker's subsequent flag observation
must preserve that happens-before chain. This argument requires the existing sole
callback producer and proper worker observations; it is not a license to sample
ordinary non-atomic bridge totals concurrently.

On observed loss, call discontinue and abort this stream. Do not clear the flag
or reset the assembler while owners are live. Invalid native samples likewise
require an explicit abort/error policy; skipping them would change source time.
A new stream begins only with new identity/generation binding after quiescence.
The assembler cannot discover overflow by itself and has no hidden access to a
device, queue or peer. Those remaining WP04 obligations are explicit.

## Evidence

[Tests](../../tests/unit/media/assembler.zig) compare emitted sample words and
absolute positions against a separate 1031-frame sequence under multiple callback
chunk patterns and four block capacities. They also exercise backpressure and
unvalidated suffixes, invalid accepted input, repeated EOF, empty streams, final
partials, repeated commit rejection, terminal loss, u64 exhaustion and codec/gate
composition. The initial test's inferred narrow slice-bound overflow was repaired
with an explicit usize index; the failed test and command output are preserved.
See [current verification](../../verification/v2-independent/RESULTS.md).
