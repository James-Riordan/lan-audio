# Provider input lease transaction and work scheduling

Status: selected implementation refinement from the revision-5 experiment. This is a contract for T02/T04/T06/Q00, not an implemented wrapper. See the [native experiment](../verification/quic-provider-pair.md) for exact observed scope.

## Lease state

Let L be Empty or Held(id, level, offset, length, storage), and R the number of logically retired bytes. A lease ID belongs to one owner generation. The provider callback does not carry that ID; the adapter retains the single outstanding lease internally. Buffers remain allocated and stable through provider destruction.

| Operation | Precondition | Commit | Failure |
| --- | --- | --- | --- |
| offer | L = Empty, contiguous admissible bytes available at current read level | L := Held; return exact pointer/length | return empty for temporary unavailability; never synthesize EOF |
| accept release(n) | L = Held and n = L.length | R := R + n; L := Empty | no partial retirement |
| reject release(n) | mismatched state/length, or injected internal failure | mark terminal; keep existing held custody | do not report success or free memory |
| provider teardown callback | public owner closed to entry, callback context still live | apply the same validated release transaction | retain memory until provider destruction completes |
| finalize owner | provider destroyed and cannot call back | dispose any remaining owned custody once; clear secrets | no callback may access freed context |

At every boundary, retired ranges are disjoint, R never decreases, and successful retirement never exceeds previously leased bytes. A failed attempt does not count as retirement. A retry of a failed attempt can therefore be valid; a duplicate after success is invalid. Length equality alone is insufficient if the adapter has already lost its outstanding lease record.

This refinement distinguishes exactly-once ownership effects from callback invocation counts. Do not weaken public event acknowledgement rules or accept a foreign/stale event ID because native cleanup repeated a failed release. They are separate state machines.

## Scheduling and budgets

Track at least inbound bytes offered, outbound bytes copied, emitted events, reserved control slots and provider-call count separately. A call that consumes all allowed inbound bytes may return WANT_READ while the adapter still owns queued data. Represent this as local work deferred, schedule another permitted turn and preserve input; do not wait indefinitely for a network read that is unnecessary. Do not spin immediately without replenishing a scheduler budget.

A host drive result should distinguish network input needed, outbound/event capacity needed, local budget exhausted, progress and terminal failure, with a documented priority when several facts hold. These are wrapper scheduling facts; do not reinterpret the provider error queue or retry a fatal callback result.

Bounding offered bytes and call count is not a wall-clock deadline guarantee. Certificate processing, provider allocation and control callbacks can occur within a synchronous call. Cancellation takes effect between serialized calls; callback-safe checks may narrow latency only after their semantics are proved. Never destroy the SSL object reentrantly to interrupt it.

## Readiness and post-handshake data

After local TLS completion, classify arriving per-level CRYPTO under QUIC state and route permitted Application-level handshake data to a bounded provider read path. Do not route it into application plaintext delivery. Maintain lease, event and terminal rules during this path. Ticket handling in the diagnostic does not enable resumption in the initial public profile. Independent malformed/forbidden post-handshake tests and adapter close mapping remain required.

## Required implementation tests

Inject release failure before retirement, destroy the provider, and verify no use-after-free, double retirement or stale callback context. Exercise same-length duplicate release after success and wrong length while held. Repeat cancellation and failure at each actual input/control/event retention point. Use allocator instrumentation for the real wrapper; the diagnostic's static arrays cannot prove allocation cleanup.

Prequeue enough fragmented input to exhaust the per-drive byte budget. Assert that deferred local work wakes without a new datagram and does not produce duplicate readiness, premature EOF or unbounded immediate scheduling. Deliver post-handshake bytes under the same budget and teardown rules. Compare native traces to the public operations and finite custody model explicitly.
