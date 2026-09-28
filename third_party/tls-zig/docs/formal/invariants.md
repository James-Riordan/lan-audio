# State models and proof obligations

These are engineering models, not completed proofs of the Zig/C implementation or cryptography. Run `python tools/check-models.py` for bounded exploration of three small state machines with deliberately broken variants. The implementation-to-model mapping must be reviewed when the corresponding source changes. No TLA+/TLC run is claimed.

## CRYPTO custody and admission

For a level, let B be byte capacity, d delivered offset, r contiguous ready offset and h highest observed end. Require 0 <= d <= r <= h <= B. Every i < r is present; delivering n requires 0 <= n <= r-d and changes d to d+n. Insertion first checks all overlapping present bytes for equality; a mismatch leaves the entire assembler unchanged. A successful duplicate insert changes neither logical contents nor d. Delivery history is retained in the current implementation, so memory is O(B), not an unbounded stream.

For outbound spans, let A be acknowledged byte offsets and P pending offsets. Require A intersect P = empty. A late ACK of an original transmission unions its span into A and removes the same bytes from P even if another transmission was declared lost. ACK claims must be a subset of recorded sent packet numbers before any state effect. The custody model explores two bytes and two transmissions; it checks a late ACK followed by retransmission loss cannot resurrect acknowledged work.

## Packet numbers and secrets

Within a connection and packet-number space, sending numbers strictly increase, including across Retry. For a direction and key generation, no newly protected plaintext may reuse a packet number. Packet authentication cannot advance another level's replay window. Received Initial authentication does not imply a peer identity because its keys derive from public inputs. The model checker does not implement AEAD or verify these cryptographic claims; packet tests and key-lifecycle review own them.

## ACK scheduling

Let g be the latest admitted ack-eliciting generation and s the latest successfully sent ticket generation. Require 0 <= s <= g. An obligation exists exactly when s < g. Preparing ticket t=g leaves s unchanged. Committing an immutable valid ticket requires s < t <= g and sets s'=t, not s'=g. Therefore a packet arriving after preparation remains owed an ACK. The bounded model exhaustively explores g <= 3 and injects a faulty commit-to-current rule to require a counterexample.

## Amplification and flight accounting

Before path validation, cumulative successful datagram bytes sent S must satisfy S <= 3R for attributed received datagram bytes R. A coalesced datagram increments R once; distinct repeated arrivals are still separate received bytes. Saturating credit may restrict extra sends but must never create extra credit. Flight bytes equal the sum of sizes of packets still counted in flight. An ACK/loss/discard can clear a counted bit once; a late event cannot debit twice.

## Time and shutdown

Clock observations never regress. An operation deadline is fixed when accepted; progress does not extend it. Starting shutdown sets D_close once. Interleaved final-data reads use min(D_close, D_requested). Peer close notification and raw transport EOF are different events. Clean completion requires consuming permitted final data and authenticating close_notify; raw EOF cannot satisfy that condition. The shutdown model explores partial final-data consumption and EOF/notify order, and requires a counterexample for an intentionally faulty EOF-as-close rule.

## Liveness assumptions and refinement

Eventual completion requires a peer that follows the protocol, eventual network delivery, progressing monotonic time, a fair host scheduler, available bounded resources and a provider that eventually consumes or returns a terminal error. Permanent packet loss, zero-progress callbacks or stopped clocks do not satisfy those assumptions. Deadlines provide bounded abandonment only when time progresses and the host schedules checks.

Map model variables to source fields in the per-file contracts. Convert each minimized counterexample into a Zig test using the real implementation. Finite exploration neither proves liveness under arbitrary schedules nor proves memory safety, constant time, network interoperability or unbounded inductive invariants. A future TLA+ model should add explicit fairness, key epochs and queue bounds after the integration contract stabilizes.

## Q04 finite-history refinement boundary

For the coordinated recovery owner, a packet can clear its counted-flight bit once. Retained late-original ACKs still emit the host token with zero flight debit; an evicted original has no effect. The floor bounds which unsent claims can be detected. Thus the earlier late-ACK custody invariant applies to retained transmission metadata, not an unbounded lifetime archive. The host continues reliable byte custody through remaining transmission tokens. Actual-send ordinals, rather than raw skipped packet-number gaps, drive the packet threshold. Sixteen native recovery tests and fifteen reproduced pinned quic-go component traces exercise this mapping; the existing three finite abstract models do not prove the new reclamation policy or complete endpoint liveness.
