# Version 2: one connection, one ordered stream

Status: implemented serialized gate in
[`Negotiation`](../../src/protocol/negotiation.zig). It composes v2 record validation
with role, stream identity, exact format echo, source-frame continuity and a
receiver drain attestation. It does not implement transport, authentication,
capability discovery, device joining or concurrent state synchronization.

## State and transition table

State is `(role,phase,stream,format,next_frame,drained)`. The initial phase is
unauthorized. Data direction is outgoing for sender and incoming for receiver;
reverse direction is the opposite. Each successful logical record is applied once.

| Phase | Event / guard | Result |
| --- | --- | --- |
| unauthorized | Host `authorizeChannel`, after mTLS/peer/role/v2 ALPN checks | ready |
| ready | OFFER in data direction | Bind copied format and stream; offered |
| offered | ACCEPT in reverse direction; identical stream and all format fields | streaming |
| streaming | AUDIO in data direction; same stream, position=next, count<=negotiated max | Advance next by count; remain streaming |
| streaming | END in data direction; same stream, position=next | draining |
| draining | Receiver host `confirmDrained` after downstream quiescence | Set drained; repeated attestation is harmless |
| draining | ACK in reverse direction; same stream, position=next; receiver requires drained | complete |
| any record phase | Malformed/unexpected/wrong-direction/wrong-stream/noncontiguous record | failed |
| failed | Any apply | Reject; no recovery or mutation |

Control-attestation misuse returns InvalidState without changing an established
state. Record rejection changes only phase to failed; prior stream, format and
frontier remain available for diagnostics. Restart requires a fresh connection
and fresh host generation. Repeating an AUDIO record is replay, not idempotence.
Only the explicitly documented drain attestation is idempotent in its valid phase.

The sender cannot publish audio before ACCEPT. The receiver may observe OFFER
before it has opened its device, but may not commit outgoing ACCEPT until actual
capability validation and stable owner initialization succeed. Syntactic acceptance
of a Format never supplies that host attestation automatically.

## The commit point across transport calls

`apply` is a protocol-state operation, not a send call. Incoming application must
validate the record/gate before publishing media to downstream ownership. Preserve
or abort on downstream backpressure; never reapply the same record on each retry.
For outgoing work, validate on a local copy of the gate, encode the record, transfer
it successfully into the transport owner's copied pending-write storage, then
commit that gate copy. If any later transport operation fails, terminate the
connection. Do not roll back and resend into an uncertain existing byte stream.

This local-copy pattern avoids advancing next before transport custody is acquired.
Transport partial send/retry steps belong to the TLS Driver and do not trigger new
protocol events. All these operations share one serialized owner; another thread
signals cancellation and wakes that owner rather than changing the gate itself.

For a receiver ACK, `confirmDrained` means the chosen application boundary has
actually been reached: queued media consumed and relevant callback/worker owners
quiescent. The gate trusts the host assertion. A counter reaching zero is not a
join; a joined device is not calibrated proof of the last acoustic sample time.
The sender trusts authenticated peer acknowledgement of this contract.

## Inductive argument and its limits

In ready, no stream has been admitted. The only record transition binds OFFER and
moves to offered. The only offered transition checks the complete echo and moves
to streaming; hence audio cannot precede an accepted format. While streaming,
successful AUDIO requires exact next and a nonwrapping end proven by codec validation.
Induction makes accepted source ranges contiguous and nonoverlapping from zero.
END freezes that frontier; only matching ACK can then complete. No record transition
leaves failed or starts a second stream from complete.

These facts assume only methods change fields and `apply` is serialized. Public
fields exist for ordinary Zig value ownership/diagnostics and deliberate tests;
arbitrary external mutation invalidates the representation. Cryptographic trust,
native lifecycle and fairness are additional assumptions, not conclusions here.

The [tests](../../tests/unit/protocol/negotiation.zig) execute both roles, empty and
partial streams, mismatch/replay/early-ACK failures, and all 140 role/phase/kind/
direction combinations against a literal permission table. This enumeration checks
the finite control surface for valid representative payloads; it is not a formal
proof over all wire inputs, queue states or real concurrent executions. Existing
v1 TLA+ models do not automatically prove this gate. A future composed production
model must include its commit boundary and actual abort/drain owners.
