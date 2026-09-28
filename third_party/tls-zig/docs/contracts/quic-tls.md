# QUIC–TLS implementation contract

Status: proposed integration contract; existing record-based Engine and frozen fixture remain unchanged. First delivery is authenticated client/server QUIC handshake without 0-RTT, resumption or streams. The records API remains supported independently.

## Required decisions before T1/Q1

The exact locked SDK passed the initial external callback probe on 2026-09-26 despite its no-quic recipe. This establishes registration, linkage, ClientHello output, partial-send backpressure and fatal-send behavior only. A rebuild is not a prerequisite for those exercised capabilities. See [native probe evidence](../verification/quic-provider-probe.md) and the [selected event/lease design](recordless-events.md). Complete a real authenticated handshake and callback failure/lifetime tests before claiming a production provider. Keep quic-zig as the transport owner.

| Interaction | Producer | Consumer obligation | Failure rule |
| --- | --- | --- | --- |
| Ordered handshake bytes | QUIC reassembler | TLS returns accepted prefix <= offered length | Zero means no progress; overconsumption poisons the connection. |
| Outbound handshake event | TLS | QUIC copies into bounded retransmission custody before ack | On no capacity, retain event and stop producing; never lose bytes. |
| Directional secret event | TLS | Derive/install matching level and suite before ack | Reject unsupported suite/length; clear all owned copies on terminal failure. |
| Peer parameters | TLS | QUIC validates structure, role and observed CIDs | Negative decision prevents application release and maps to a defined close reason. |
| Peer authentication | TLS policy | Host supplies independent expected identity/trust | Server no-mTLS policy must not report a certified client identity. |
| Completion | TLS plus QUIC policy | Require all mandatory checks; distinguish handshake complete/confirmed | Key availability alone is insufficient. |
| Fatal alert/cancel | Either owner | Revoke delivery, clear secrets, release event custody | No reentry; no callback after deinit. |

## Event and lifetime rules

Select a single outstanding borrowed event or a bounded queue with explicit identifiers. nextEvent must return the same pending event until acknowledgment. Document whether an identifier is connection-local plus generation; reject stale/out-of-order acknowledgment without consuming a different event. Borrowed data remains unchanged until ack/cancel/deinit; applications must not retain it afterward. A callback is synchronous and nonreentrant. A canceled connection never resumes its old generation.

The fixture's entropy, limit and asynchronous peer-policy declarations exceed current records capabilities. Either implement each advertised guarantee or return UnavailableCapability before construction. In particular, never claim a total provider-memory cap by passing a queue-size constant.

## Clocks and units

Existing QUIC recovery/pacing/idle/termination use microseconds; TLS Driver uses milliseconds; the frozen fixture uses nanoseconds; Retry tokens use seconds. The integration adapter is the only conversion owner. Use named unit types, checked multiplication, and round deadlines toward earlier wakeup when reducing precision. Supply certificate wall time separately from monotonic progress time. Record rounding at exactly-before/at/after deadline boundaries.

## Receive transaction

Attribute UDP input once to its path and connection. Iterate packet boundaries independently. Authenticate into separate scratch; preflight packet history, CID policy, complete frame syntax, all ACK claims and all CRYPTO overlaps. Decide close/idle state before delivery. Commit accepted component state under one owner, then pump contiguous CRYPTO to TLS. A later frame failure must not leave an earlier ACK or CRYPTO effect committed. This is a connection-level obligation, not an existing single helper call.

## Send transaction

Capture immutable frame choices and packet numbers; size/pad the complete datagram; preflight custody, ACK ticket, congestion, pacing, path amplification, idle and lifecycle. Submit without intervening state mutation. On known success, commit every participant. Would-block retains the same plan; a changed plan must reserve new packet numbers where encryption was already exposed. Ambiguous transport success consumes the reserved numbers and requires an explicit custody/recovery policy. A cached closing packet may be replayed byte-for-byte under its separate rule.

## First acceptance trace

Use real TLS peers through QUIC packet protection in both directions. Drop one Initial and reorder Handshake packets. Verify ordered once-only CRYPTO delivery, distinct packet spaces, correct directional secrets, peer identity and ALPN, role-checked transport parameters, Retry without resetting packet numbers, bounded resource failure and cancellation at each pending event. Add negative cases before exposing an application API.
