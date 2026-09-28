# Quantitative design: derive the limits before tuning

These are design derivations, not measured product guarantees. Units and assumptions
are part of every result. [System mathematics](../design/system-mathematics.md)
contains the broader fidelity, clock and measurement definitions.

## Q1. Rate, burst and service are different quantities

For f frames/s, c channels/frame and s bytes/sample, media production is
`r = f*c*s` bytes/s. At 48,000 stereo f32 this is 384,000 bytes/s. For n frames per
record and h header bytes, application framing adds `h*f/n` bytes/s. With n=240
and the implemented v2 h=48, this adds 9,600 bytes/s before TLS/TCP/IP/link overhead.
These numbers describe an application stream; they are not NIC capacity claims.

Suppose cumulative admitted arrival A(t) obeys a burst envelope
`A(t)-A(u) <= sigma + r*(t-u)` for all t>=u, and a backlogged service stage offers
the lower service curve `beta(t)=c*max(0,t-J)`, with c>=r. Here sigma is bytes,
J is seconds, c is *usable* bytes/s after competing work and overhead. The service
curve must apply over every relevant backlogged interval; average throughput or
one measured outage does not establish it.

The deterministic backlog bound is the largest vertical gap:

`sup(t>=0) [sigma+r*t-c*max(0,t-J)] = sigma+r*J`.

For t<=J the gap increases to sigma+rJ. For t>J its slope is r-c<=0. This gives
a candidate queue requirement when the envelope and service assumption hold.
For c<r the gap is unbounded over an unlimited session; no finite queue suffices.

The corresponding fluid FIFO horizontal-delay bound is `J+sigma/c`: after that
shift the service curve dominates the arrival envelope because c>=r. Packetization,
nonpreemptive processing and fixed decoder/device delays must be included in J or
separate bounds; otherwise the fluid expression understates delay. A network card
with unbounded stalls has no finite J and therefore no bound of this form.

## Q2. Playback reserves and source retention are separate

At the start of a no-arrival interval of length J, the sink needs at least
`f_s*(J+S)` contiguous source-equivalent frames for an additional scheduling
reserve S, rounded upward with checked arithmetic. This assumes unchanged
consumption rate and that the samples are already valid and decodable. Out-of-order
occupancy does not all count toward this contiguous reserve.

Separately, the sender or reliable transport must retain the newly captured rJ
bytes while service is unavailable. A playback queue cannot protect media that
the capture queue has already dropped. For post-outage service c>r, ideal backlog
recovery requires at least `r*J/(c-r)` seconds. During this interval the sink's
schedule and any changed latency must remain coherent. Repeated stalls before
recovery must be analyzed as one service process, not independent success cases.

The present bridge capacity 4096 at 48 kHz represents about 85.33 ms of frames
per queue when full. It does not promise that much stall coverage: occupancy can
be smaller, reserve is needed, other stages have independent capacities, and
current production scheduling is unfinished. Fixed small queues are a local
callback mechanism, not a derived maximum-robustness buffer policy.

## Q3. Derive an ideal clock-controller stability region

Let q_k be queued source frames sampled every T seconds, e_k=q_k-q_target,
f_r actual output frames/s, and rho source frames consumed per output frame.
Assume constant source/output rates, exact occupancy measurements, no saturation,
no transport disturbance and no estimator/actuator delay. These assumptions define
the local linear model; real jitter and bounds will require separate analysis.

Choose `rho_k = rho_0 + k_p*e_k + k_i*I_k`,
`I_(k+1) = I_k + T*e_k`, and `rho_0=f_s/f_r`.
Then conservation gives

```text
e_(k+1) = (1 - T*f_r*k_p)*e_k - T*f_r*k_i*I_k
I_(k+1) = T*e_k + I_k
```

Set a=T*f_r*k_p and b=T^2*f_r*k_i. The state matrix has trace 2-a,
determinant 1-a+b, and characteristic polynomial
`lambda^2 - (2-a)*lambda + (1-a+b)`.
For a real second-order monic polynomial, the strict unit-disk conditions reduce
to `b>0`, `a>b`, and `4-2a+b>0`. Thus this discretization's local asymptotic
stability region is:

`k_i>0`, `k_p>T*k_i`, `2*T*f_r*k_p-T^2*f_r*k_i<4`.

One can check the reduction directly by the three inequalities
`1-trace+det>0`, `1+trace+det>0`, `1-det>0`; strict inequalities exclude unit-circle
roots. They imply det lies between -1 and 1. This analysis depends on updating the
integrator from the old error; using a different update order changes the matrix.

Units: k_p has units ratio/frame and k_i ratio/(frame*second). A persistently full
buffer has positive e, hence increases rho and drains faster. Reversing this sign
makes positive feedback. The integral state balances a constant rate-estimation
error in the ideal model, but that statement alone does not prove a bounded
implementation stable under clamps, jitter or adaptive prefill.

Before selecting gains, specify ratio/slew bounds, integrator limits/anti-windup,
sample period, filter delay and device-rate range. Analyze the delayed/saturated
system and replay measured disturbances. Check queue bounds, settling time,
steady error and spectral artifacts. No numeric gains are approved by this chapter;
WP05 must supply simulation and device evidence, not merely a plausible equation.

## Q4. Fidelity and resilience have observable frontiers

For finite f32 transport, compare source and received IEEE-754 bit patterns before
resampling. Preserve signed zero deliberately. Reject NaN/infinity consistently.
For resampling, compare passband gain/error, alias suppression, numerical headroom
and continuity against an independent oracle; raw bit equality is not the correct
property of a changed sample grid. For acoustic output, include OS format/mixing,
device conversion and a calibrated measurement path.

Report how much media was received intact, recovered before deadline, discarded,
rendered as concealment/silence and interrupted by rebuffering. An efficient binary
layout does not establish those properties. Bound allocations, copies, wakeups,
CPU time and transmitted bytes separately, using named measurement boundaries.

A candidate operating envelope is a tuple of burst bound, sustained service,
outage bound, clock mismatch, CPU pressure, device format and latency budget.
Each coordinate needs a measurement or explicit assumption. Publish qualification
against that tuple; a universal claim about all partially failing hardware cannot
follow from a finite experiment or a finite buffer.
