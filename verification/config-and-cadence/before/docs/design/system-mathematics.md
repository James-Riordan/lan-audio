# System mathematics and measurable limits

These obligations extend the implemented proofs in [MATHEMATICS](../MATHEMATICS.md).
They define what future code and experiments must establish; they are not results.

## M01 — Fidelity and representations

Let X be captured finite binary32 sample bit patterns and D(E(X)) the decoded
network samples before clock correction. The fidelity transport law is bitwise
equality `D(E(X)) = X`, preserving signed zero and subnormals. Use integer byte
serialization of bit patterns with explicit endianness, with no floating arithmetic
on that path. Validate NaN/infinity before exposing a block to playback. Test edge
patterns and independent randomized oracles. The existing s16 profile cannot
satisfy this law for arbitrary f32 input and remains versioned separately.

Let Y be samples after an asynchronous resampler. Generally Y differs from X, so
the output guarantee must instead state its rate mapping, passband/stopband error,
added noise, headroom, finite outputs and transient behavior under ratio changes.
Do not conflate exact delivery, high-quality rate correction and analog quality.

## M02 — Payload, copies and resource bounds

For rate f, c channels and s bytes/scalar, payload bitrate is `R = 8 f c s` bit/s.
At 48 kHz stereo f32, R is 3.072 Mbit/s before framing, TLS, IP/link and repair.
At 96 kHz it is 6.144 Mbit/s. With block n frames and header h bytes, framing adds
`8 h f/n` bit/s. Count cryptographic record boundaries and retransmissions from
measurement; a TCP write is not a network packet. A future datagram must satisfy
`IP + UDP + security + media_header + media_payload <= measured_path_MTU`.

If a stage makes k full payload copies, its copy traffic is at least kR/8 bytes/s,
excluding read/write amplification, cache effects and conversion. Count copies at
named boundaries; removing a copy is valid only if exclusive custody, borrow
lifetime, cancellation and alignment remain sound. Total fixed media memory is
the sum of queue capacities, window slots, parser storage, in-flight codec buffers
and worker scratch. OpenSSL/native backend allocations require separate measurement.

## M03 — Outage coverage and catch-up

Let B seconds of contiguous decoded audio already be available at the sink, J the
interval with no usable arrivals, and S a scheduling/processing reserve. A necessary
condition for uninterrupted playback during that outage is `B >= J + S`. It is not
sufficient if the device stops, samples were never captured, data is unauthenticated
or the reserve was estimated incorrectly. Buffered out-of-order positions are not
all contiguous audio coverage.

Let r be source payload bytes/s and c the *usable media service rate* after transport,
repair and framing overhead. An outage J leaves rJ bytes of backlog. For constant
post-outage c > r, the ideal catch-up lower bound is `T = rJ/(c-r)`. If c <= r,
backlog cannot shrink while live source generation continues. Increasing retries
cannot violate this conservation law; it may reduce c through congestion.

For each block i, accept recovery as useful only if its authenticated arrival plus
decode/scheduling reserve precedes its render deadline d_i. Recovery requests,
parity and retransmissions consume bounded traffic budgets. When the deadline
cannot be met, increment a degradation counter and follow explicit rebuffer/stop
policy. No finite buffer guarantees uninterrupted live audio through an unbounded
network or host outage.

## M04 — Two clocks and occupancy

Let f_s and f_r be actual capture and render rates and q(t) queued source-equivalent
frames. Without correction, `dq/dt ≈ f_s - f_r`, plus arrival jitter/discontinuities.
For a relative error ε ppm at nominal f, accumulated difference after t seconds is
`Δq ≈ f ε t / 10^6`. Even small sustained error can eventually exhaust a finite
queue. Network jitter is fast queue variation; clock mismatch is persistent trend.
Do not fit both using an unfiltered instantaneous occupancy sample.

If ρ is source frames consumed per rendered frame, equilibrium requires
`ρ = f_s/f_r`. Choose this sign convention once: when the queue is persistently
too full, increase ρ modestly to consume faster. A provisional controller is a
filtered feed-forward rate estimate plus bounded proportional/integral occupancy
correction. Select gains from a discrete-time model, clamp ratio/slew, apply
anti-windup, and simulate step/jitter/loss disturbances. No numerical controller
constants are approved by this document; acceptance needs measured error bounds.

## M05 — Time and identifiability

Host timestamps satisfy independent affine clock relations with unknown offset
and drift. Packet arrival timestamps mix capture/queue delay, network delay and
clock mapping. Estimating one-way delay from them requires extra synchronization
assumptions or calibrated measurement. RTT does not identify asymmetric one-way
delay. Report uncertainty and measurement method; never subtract unsynchronized
wall-clock timestamps and label the result acoustic latency.

## M06 — Lifecycle and progress

The safety partial order is close admission, signal stop, stop/join producers and
consumers, uninitialize device callbacks, release reachable storage. The exact join
order follows the wait graph: no worker may wait on a callback that control has
stopped while the worker still owns an unbounded drain obligation. Choose bounded
graceful drain followed by explicit abort, with each resource owned and freed once.

The [RuntimeOwnership model and argument](../literate/runtime-argument.md) now
cover count-level custody, cancellation in connect/prime/run/drain, full/empty
queues, timeout escape and new generations, with early-free and cancellation-wait
mutations. Partial acquisition, detailed source drops, multiple in-flight records,
device failure states and stale external generation injection remain extensions.
Separate Session, EndDrain and SPSC liveness does not automatically compose.
Implementation refinement and weak-memory arguments remain separate from bounded
model exploration. See the [proof ledger](../literate/proof-ledger.md).

## M07 — Evidence quality

Percentiles need a named population, duration, load, sample count and measurement
uncertainty. A 30-minute run with zero glitches does not prove universal zero-glitch
behavior. Publish tested ranges for loss bursts, stalls, RTT, throughput, clock
offset, CPU pressure and device/driver versions. Use deterministic replay traces
to reproduce defects and independent expectations to avoid testing an algorithm
against itself. Unknown or unmeasured bounds remain explicitly unknown.
