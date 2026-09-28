# Mathematical specification and implementation argument

This document separates (1) laws implemented by the pure kernels, (2) their finite
model-checking evidence and (3) system-level mathematics still requiring adapters
and measurements. Equations do not stand in for an implemented or verified system.

Read the [connected program explanation](literate/stream-argument.md) alongside
these local arguments. [Runtime composition](literate/runtime-argument.md) and
[quantitative derivations](literate/quantitative-design.md) develop the wider design;
the [proof ledger](literate/proof-ledger.md) records exact evidence and open claims.

## 1. Typed objects and dimensions

A device descriptor contains a host-scoped identifier, role capabilities and a
negotiated format. A persistent peer identity, OS device ID, network endpoint,
transport connection and local session epoch are different types. Discovery maps
names to candidate endpoints; it does not establish peer identity.

A stream format is `F = (f, c, n, representation, channel_order)`, where `f > 0`
has units frames/second, `c > 0` channels/frame and `n > 0` frames/block. A sample
is a scalar amplitude; a frame is one sample per channel. Block duration is
`tau = n/f` seconds and interleaved element count is `m = n*c`.

For scalar width `s` bytes/sample, block payload is `n*c*s` bytes and raw bitrate
is `8*f*c*s` bits/second. At 48 kHz, stereo PCM16: 1,536,000 bit/s; a 240-frame
block is 960 bytes. A fixed envelope `h` bytes/block adds `8*h/tau` bit/s. Loss
repair, transport ACKs and link/IP overhead require separate terms with explicit
accounting boundaries. These are derived rates, not measured network throughput.

The kernel stores finite `f32` samples. It does not impose `[-1,1]` because mixing
headroom may be intentional; clipping/saturation and integer quantization belong
to the negotiated adapter. Nonfinite samples are rejected before publication.
Checked integer products are required before allocating `n*c*s` bytes.

## 2. State machine and ownership

`S = (phase, epoch, authenticated, callback_active)`.

`phase ∈ {idle, negotiating, streaming, stopping}`;
`epoch ∈ [0, 2^64-1]`; the booleans describe host-attested authentication and one
abstract active callback. Epoch zero is the initial unused generation. Epochs
increase on begin and never wrap. Exhaustion requires a new containing identity
and lifecycle; reusing a number in a surviving connection is forbidden.

| Action | Preconditions | Postcondition |
|---|---|---|
| begin | idle; epoch below maximum | epoch increases; negotiating |
| authenticate(e) | negotiating; e = epoch; host has validated identity | authenticated true |
| start | negotiating; authenticated | streaming |
| admit(e) | streaming; authenticated; e = epoch | state unchanged, permission returned |
| enterCallback(e) | admit(e); no active callback | callback token active |
| leaveCallback(e) | token active; e = epoch | token inactive |
| requestStop | negotiating or streaming | stopping, no further admission |
| finishStop | stopping; token inactive; host device actually quiescent | idle; authentication cleared |

All errors preserve kernel state. The host must keep its attestation meaningful;
calling `authenticate` is not cryptographic verification. The kernel's epoch must
be mapped from an authenticated remote stream identity, not copied from untrusted
packet bytes. Private keys, replay-resistant session identifiers and role/format
binding belong to the selected transport and product handshake.

Safety invariants: streaming implies authenticated; idle implies no active callback
and no authentication; generation changes only at a quiescent begin; rejected/stale
work cannot authorize a new generation. In serialized execution, inspect each action:
begin starts from idle; start has the authentication guard; stop only closes admission;
finish requires no callback. Each therefore preserves these invariants from Init.
This is a manual inductive argument, not a TLAPS proof or a machine-memory proof.

The host destruction order is a happens-before obligation:
`close admission ≺ stop/join callbacks and workers ≺ reclaim buffers/keys ≺ reuse`.
An atomic stop flag alone cannot establish all those edges. Real SPSC queues and
device threads require an acquire/release and reclamation argument before integration.

## 3. Bounded playout window

Let `K > 0` be block capacity, `M > 0` samples/block and `r` the next playout
position. An accepted block `(e,q,x)` must satisfy:

* `e = current_epoch`;
* `x` has exactly `M` finite samples;
* `q < 2^64-1` (terminal value reserved to prevent wrap);
* `q >= r` and `q-r < K`;
* no block already occupies position q.

The implementation uses subtraction after checking `q >= r`. It never computes an
overflow-prone `r+K` as the admission condition. Slot index is `q mod K`.

**Injective-slot lemma.** For `q1,q2` in an interval of K consecutive integers,
`q1 mod K = q2 mod K` implies K divides `q1-q2`. Since `|q1-q2| < K`, the difference
is zero. Therefore every admitted position has a unique slot in the live window.
Capacity need not be a power of two; using a bit mask without that extra assumption
would be wrong. Physical ring-slot reuse is distinct from sequence-number wrap.

**Inductive representation invariant.** A present slot corresponds to exactly one
admitted, unconsumed position in `[r,r+K)`. Init has no present slots. Insert checks
the interval and vacancy, copies the complete block, then publishes its presence.
Tick consumes slot `r mod K` if present, clears it, and increments r. Every remaining
position lies in the next interval. The newly entering position is congruent to
the just-cleared slot, so reuse cannot overwrite another live position.

**At-most-once law.** Each successful tick advances r by exactly one; there is no
decrement or wrap. Thus a pair `(epoch, position)` is submitted at most once by
this window. On absence, it emits M zeros and still advances. Later arrival at that
position is rejected as late. This does not claim acoustic exactly-once playback,
exactly-once network delivery or survival across process crashes.

**Bound and cost.** At most K blocks are present. Payload storage is `4*K*M` bytes
plus K presence flags and metadata; insert uses one `4*M`-byte stack temporary to
permit overlapping input storage. Insert validates/copies O(M) samples; tick
copies/fills O(M). No allocation, I/O, clock read or wait occurs. Bounds are selected
at compile time, so the host must budget stack/object placement. O(M) is not a
measured worst-case execution-time guarantee.

The caller owns exclusive mutation and supplies output that does not alias the
window object. Direct field mutation violates the abstraction except in deliberate
boundary tests. Invalid tick length or exhausted position preserves both state and
output. Failed insert never publishes partial data. Context/window reinitialization
is allowed only after quiescence, with a new epoch for a restarted stream.

## 4. Composition and refinement map

The TLC state combines lifecycle and buffering. In the implementation, `Session`
and `Window` are separate kernels: a future host must compose them lawfully.

| Model item | Concrete correspondence / extra obligation |
|---|---|
| phase, epoch, authenticated, active | `Session` fields; serialized operations; actual join supplies physical quiescence |
| next | `Window.next`; finite bound in TLC replaces large concrete range |
| buffer set of `(generation,position)` | Present ring slots under the injective-slot lemma; samples abstracted away |
| history | Ghost sequence of emitted media positions; no unbounded production history is allocated |
| Receive | Host authenticates and `Session.admit`, then `Window.insert`, serialized against stop/reset |
| Tick | Host-authorized media-clock step and `Window.tick`; silence omits a media record |
| Begin | `Session.begin` plus fresh `Window.init(epoch)` after old ownership is drained |
| FinishStop | `Session.finishStop` plus release/discard of old window after actual device/worker stop |

TLC is not a Zig interpreter. The model/source map is reviewed manually; a test
and an invariant sharing a name do not establish refinement. A stale untrusted
packet must not be retagged with the current epoch by an adapter. A callback may
finish already admitted work while stopping, but no new callback is admitted.

The finite model explores two epochs, three positions per epoch and capacity two,
including arbitrary input order, repetition, omission and stop/restart interleavings.
It checks type safety, authenticated streaming, quiescent idle, bounded current-epoch
buffering and unique media positions. Four mutations must yield counterexamples.
The mathematical induction above generalizes the window argument under its stated
assumptions; the finite state count alone does not prove all K, sequence widths or
possible thread executions.

Stop liveness is `[](stopping => <> idle)` under weak fairness of callback return
and stop completion. It cannot be promised when a driver or callback hangs forever.
Unconditional eventual delivery is impossible under unbounded loss or a peer that
never sends. Playout-position progress instead depends on host ticks continuing;
it may produce silence. Fairness assumptions must remain visible in product claims.

## 5. Time, drift and latency — system design obligations

Host monotonic time, source media-frame count and sink media-frame count are distinct
coordinates. Wall-clock time is not a scheduling clock. For a finite observation
interval, model host-clock correspondence as `t_r = a*t_s + b + epsilon`, where a
is relative rate, b offset and epsilon noise/model error. Offset and one-way network
delay are not separately identifiable from one-way arrival timestamps alone.
Round-trip probes need explicit path-asymmetry bounds; arrival jitter is not clock drift.

Receiver deadline for source position q can be expressed as
`d(q) = b_hat + a_hat*(q*n/f_s) + D`, with a calibrated epoch origin and buffering
delay D. Late means arriving after that deadline, not merely receiving a lower
packet number. The reference window advances only when the host calls tick; it
does not estimate a, b or D and contains no clock controller.

Occupancy conservation is `Q_next = Q + accepted - rendered - discarded` over one
measurement interval, all quantities in the same units (blocks or frames). Missing
positions rendered as silence consume timeline positions but do not subtract a
stored block. Total occupancy, contiguous playable prefix and playout lead are
different measurements under reordering.

For a resampling controller, define u as source frames consumed per output frame.
Ignoring loss and quantization, `dQ/dt = f_source - u*f_sink`. A fuller-than-target
buffer therefore calls for increasing u. A candidate feedback rule is
`u = clamp(u0 + k_p*(Q-Q_target) + k_i*integral_error, u_min, u_max)`.
This is a design equation only: controller gains, anti-windup, estimator filtering,
audible correction bounds, stability and settling time require analysis/simulation.
Do not claim sample-clock synchronization from matching nominal sample rates.

Total source-to-acoustic latency is the sum of nonoverlapping capture, block
formation, conversion/encoding, sender wait, network, receiver wait, decode/conversion
and playback/device terms. Each term needs a measurement boundary; stage percentiles
cannot simply be added and reported as the end-to-end p95. Report latency using
physical loopback or calibrated timestamps, with measurement uncertainty.

## 6. Dependency and documentation mathematics

Represent dependencies as typed edges, not one overloaded graph:
`build-import`, `native-link`, `runtime-load`, `test-tool`, and `optional-integration`.
For admitted root set R and relation E, the source dependency closure is the least
fixed point `D = R ∪ successors_E(D)`. A complete manifest of Zig imports alone
does not include dynamically loaded OS backends, SDKs or verification tools.

Each precisely scoped concern has one semantic owner. A product policy can depend
on a lower-level mechanism without transferring ownership. Every authored file has
a mapped responsibility and every asserted verification result refers to source,
tool, target and scope. Hashes establish an observed byte identity; they do not
prove semantics, provenance trust, atomic snapshots or absence of concurrent edits.

Primary formal-method reference:
[Lamport, Specifying Systems](https://lamport.azurewebsites.net/tla/book.html).
Upstream audio contracts are adopted from the pinned miniaudio source, with the
wrapper's lifetime boundary documented separately.

## 7. Bounded framing and PCM round trips

For parser state `(used,wanted,ready,failed)`, the invariant is
`0 <= used <= wanted <= 996`. A new record initially wants 36 bytes. The header
permits only body lengths 12, 960 or 0 according to the kind; no arbitrary received
length becomes an allocation or copy count. Each copy uses
`min(wanted-used, available_input)`. At most two copy phases occur in one feed:
complete the header, then complete the body or return for more input. Empty input
returns without spinning. A malformed header sets a terminal failure state.

Messages borrow parser storage until the next feed. This lifetime is part of the
refinement boundary: retaining a message body across another feed would invalidate
the model even if all length arithmetic were correct. The receiver validates the
profile/identity and copies decoded samples before any reuse.

For signed integer `z ∈ [-32768,32767]`, decode is `D(z)=z/32768`, exactly
representable in binary32. Encode is
`E(x)=saturate_s16(round_away(32768*clamp(x,-1,1)))` for finite x. Therefore
`E(D(z))=z` for every s16 value. The implementation exhaustively checks all 65,536
values against their original bytes, not merely selected examples.

Away from saturation, quantization error is at most `1/65536` in normalized
amplitude. At positive full scale, saturation to `32767/32768` has error `1/32768`.
Inputs outside the normalized range are intentionally clipped; no universal small
error bound applies to arbitrary finite headroom. Nonfinite input is rejected
before output mutation. Header byte order and PCM byte order are explicitly distinct.

## 8. Terminal frontier and stream completion

Let r be next playout position, B the buffered position set, K capacity and e the
optional exclusive terminal frontier. END admission requires
`r <= e <= r+K` (implemented as safe subtraction) and `∀q∈B: q<e`.
After END, incoming admission is closed. Each tick emits media or silence at r and
increments r exactly once. The nonnegative ranking function `V=e-r` decreases by
one per tick. Under weak fairness of tick, V reaches zero; then B is empty and the
serialized receiver completes. This proves neither device-thread fairness nor
audible completion. Before END arrives there is no finite completion promise.

`EndDrain.tla` checks this abstraction with capacity two and three positions. Its
mutations admit post-END data, accept an END before buffered data, and announce
completion too early. Each must produce a counterexample. The ghost boolean
`postEndAdmission` exists only to observe a forbidden event; it is not a new runtime
field. `Receiver.finish_sequence`, `Window.next`, present slots and `Receiver.ended`
supply the manual refinement map. This is a second bounded model, not a proof that
the two models' liveness assumptions automatically hold when physical threads exist.

## 9. SPSC publication and slot reuse

Let W and R be unbounded logical counts of published and released frames. Initially
both are zero. The invariant is `0 <= W-R <= K`. The producer copies n frames with
`0 <= n <= K-(W-R)` into slots `(W+i) mod K`, then publishes W+n. The consumer
copies m frames with `0 <= m <= W-R`, then releases R+m. Thus induction preserves
the bound, FIFO order and exclusive ownership of every occupied/free slot.

Production stores the low 32 bits of W and R. Because K is a power of two below
2^32, slot indexing by `cursor & (K-1)` agrees with the logical index even across
u32 wrap. Because outstanding distance never exceeds K <= 2^30, wrapping unsigned
subtraction recovers the bounded distance. The explicit rollover test starts two
frames before the u32 boundary; routine stress alone would not reach that boundary.

The memory-order refinement adds two happens-before edges for each reused slot:

1. Producer sample writes precede release publication of W. A consumer acquire
   observing that publication (or a later one by the same sole producer) precedes
   its sample reads. Therefore it cannot consume a not-yet-initialized frame.
2. Consumer sample reads precede release publication of R. A producer acquire
   observing that release (or a later one by the same sole consumer) precedes
   overwriting those slots. Therefore it cannot race an unfinished sample read.

Each owner reads its own cursor monotonically; only its remote cursor needs an
acquire load. Atomic coherence and sole-writer program order prevent an owner's
successive remote observations from moving backward in modification order. A stale
remote observation can only reduce the permitted transfer. Neither owner can lap
a stalled peer: it exhausts the K-frame allowance and must observe progress before
advancing. This is the condition that excludes an ambiguous full 2^32 logical lap
behind the modular values. Third-party cursor snapshots have no such guarantee.

Operations perform a fixed number of atomic loads/stores and at most two copies,
with no compare-and-swap retry. Their work is bounded by the caller's frame count
and K. This algorithmic nonblocking property assumes aligned native atomic loads/
stores on the declared targets; it does not establish scheduler fairness, deadlines
or bounded wall-clock delay. Occupancy observations are producer-only and may
conservatively overestimate remaining frames until later releases become visible.

`SpscPublication.tla` splits copy/publication and copy/release into separate actions
with K=2 and four frames, including slot reuse. Its `NoCorruption` ghost invariant
checks payload identity at every read. Early publication allows an uninitialized
read; early release allows overwrite before read. Both mutations must falsify the
invariant. Under weak fairness of producer and consumer, the finite transfer ends.
The model is sequentially consistent and does not itself prove acquire/release
compilation. The above argument, implementation inspection and concurrent tests are
separate evidence, not a machine-checked refinement proof or race-detector result.
