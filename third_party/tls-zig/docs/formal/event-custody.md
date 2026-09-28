# Finite model: acknowledged event custody

Status: executable design model of the proposed TLS boundary. Run `python tools/check-event-model.py` or `python -O tools/check-event-model.py`. This supplements the three existing safety models; it does not execute C/Zig or prove the implementation correct.

## State and transitions

State is `(n, Q, b, C, R, terminal)`: emitted event count, ordered pending event IDs, optional borrowed head, ghost set of independently copied/derived IDs, ghost set of retired IDs, and terminal flag. Ghost ledgers exist only to state/check history properties; production queues need not retain those unbounded histories.

Explore three emitted events, capacities one and two, issuers 7 and 8, and acknowledgement sequence values 0 through 3. Issuer 7 is the live owner; issuer 8 is foreign. BFS visits each reachable state once, including rejection stutters and repeated terminal operations. A trace attached to a detected failure is shortest by transition count under these finite choices.

| Action | Guard | Transition |
| --- | --- | --- |
| emit | live, n < 3, length(Q) < capacity | append n; increment n |
| nextEvent | live, Q nonempty | b becomes head(Q); repeated borrow returns same identity |
| copy/derive | live, b exists | add b to C without retiring provider event |
| acknowledge(i,s) | live, i = 7, s = b = head(Q), s in C | remove head, add s to R, clear b |
| invalid acknowledgement | guard above false | no state change |
| cancel | live | clear Q/b, terminal becomes true |
| later operation | terminal | no state change |

While live, `set(Q) union R = {0,...,n-1}` and `set(Q) intersection R = empty`. Always `R subset C`, queue IDs are unique, and a borrowed ID equals the current head. Terminal state has no pending queue or borrow. A separate transition check requires a mutating acknowledgement to identify exactly the live issuer and borrowed ID; it does not trust the transition's own acceptance predicate.

## Fault sensitivity

The runner must both pass the normal model and find each injected defect. Full-queue overwrite loses custody; stale/foreign acknowledgement consumes another event; premature acknowledgement retires an event before independent custody exists. The JSON receipt retains the counterexample action sequence and state/edge counts. Removing the normal invariants or weakening the negative cases would invalidate this evidence.

## Limits and implementation obligations

No liveness/fairness, TLS cryptographic property, real buffer erasure, thread safety, memory allocation, generation allocator, sequence wraparound, input-lease release or network retransmission is modeled. Cancellation discards abstract payload custody; C/R remain history-only ghost sets, not retained secret bytes. Prove physical clearing and provider input lifetime with native instrumentation. Event payload is abstract: byte integrity needs independent hashes/poisoned-buffer tests.

The finite model does not prove the safety statement for arbitrary capacities or unbounded execution. A paper induction can use the partition invariant and each guarded transition, but that reasoning still depends on fresh IDs and the implementation-to-model mapping. Model cancellation never constructs a second owner; separately test owner generation uniqueness and overflow.

Implementation mapping: T03 event queue supplies emit/borrow/ack/cancel; T04 callback adapter supplies copied payload custody; Q00 supplies independent QUIC copy/derive receipts. T06 conformance tests must demonstrate this mapping, not merely call this Python model from a test runner.

## Concrete queue refinement evidence

`tests/quic/events.zig` enumerates 32768 five-action words and compares the actual Queue against a separate emitted/pending/retired ledger. Parameter events allow both physical slots to participate without the data-control reservation changing model capacity. Borrow and successful consumer action are tracked independently; invalid head/foreign/tail operations stutter. Cancellation suffixes test closed queries and idempotent cancellation, with additional explicit tests for post-cancel acknowledgement and emission rejection. This is bounded refinement evidence, not an unbounded proof or a TLS provider model.

Other tests copy exact bytes through an independent sink, poison caller input after enqueue, inject each construction allocation failure, check pre-free secret clearing through an allocator hook, and exercise owner/sequence exhaustion. The Python model remains a separate design oracle and is not relabeled as production execution.
