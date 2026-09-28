# Recovery and pacing arithmetic: current implementation model

This page describes the current source, not a complete RFC conformance result. Source owners: recovery.zig, congestion.zig and pacing.zig; independent tests are required when changing rounding, units or skipped-number policy.

Let x=max(1, elapsed_us), S=smoothed RTT, V=RTT variance and L=latest RTT. Before any sample, S=L=333000 and V=166500 microseconds. First sample sets S=L=x, V=floor(x/2), minimum=x. Later samples first compute delta=abs(S_old-x), then V_new=floor((3*V_old+delta)/4), S_new=floor((7*S_old+x)/8), L_new=x. Minimum is the smallest sample. Widened intermediate arithmetic avoids multiplication overflow.

The current time-loss delay is max(1000, ceil(9*max(L,S)/8)). A packet is eligible only when it is recorded in flight, classified as in flight and at/below largest_acked. The current packet-threshold branch counts three actual later recorded sends at/below largest_acked; it does not use a raw numeric gap. This deliberate local behavior is covered by recovery_tests and is a Q2 conformance-review item.

Ignoring saturation for notation, Initial PTO duration is (S+max(1000,4V))*2^pto_count. Initial ACK delay is ignored. Loss-time deadlines take priority. When a PTO fires, one probe obligation becomes pending and repeated deadline production is suppressed until a successful eliciting send clears it. Saturating arithmetic avoids wrap but does not prove useful progress near u64 exhaustion; the host must choose an explicit time-exhaustion policy.

For maximum datagram size M, minimum congestion window is 2M; initial window is min(10M,max(14720,2M)). Newly counted losses debit flight before ACK growth. A new recovery period halves the window with the minimum floor. Eligible slow-start ACK bytes increase the window; congestion avoidance accumulates acknowledged byte credit and grants M bytes per acknowledged window. Late ACKs never debit a packet whose counted bit already cleared. Persistent congestion uses post-first-sample lost eliciting intervals and includes the configured peer maximum ACK delay in its duration threshold even though Initial RTT/PTO ignore it.

Pacing stores fixed-point byte credit with scale F=65536 and capacity 2MF. At window W and RTT S, refill rate is 5WF/(4S) credit units per microsecond. Refill is floored and capped; wait duration is ceiling(deficit*4S/(5WF)). Configure first accrues time using the old rate, then installs W/S. A PTO bypass may spend available credit without creating a fresh burst. readyAt checks representability before returning a future timestamp.

## Independent oracle cases

Use rational arithmetic in a test oracle, not copies of the same integer expressions. Test just before/at/after each deadline, half-window and varint boundary, multiple events with equal timestamps, maximum clocks, app-limited ACKs, late original ACK after retransmission loss, discarded Retry flight and persistent intervals broken by acknowledged packets. Add one test explaining every intentional rounding direction.
