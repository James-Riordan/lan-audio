# Connection operations, failure boundaries and deterministic scheduling

Status: selected orchestration design for Q06–Q08/Q12–Q14. These are not existing connection APIs. Existing primitive contracts remain authoritative for their current behavior. Implement each proposed operation with an independently authored state snapshot oracle.

## One owner, one operation boundary

The connection owner serializes input, send completion, timeout, cancellation and TLS events. Callbacks may not synchronously reenter that owner. External threads enqueue immutable events through a separately specified host mechanism; they never mutate protocol state directly. Each turn samples one monotonic processing time and accepts a bounded number of work units. A timeout budget is absolute, not reset by would-block or zero progress.

Selected same-time policy: observe explicit cancellation first; reject clock rollback before state mutation; expire an already-due terminal/handshake/idle deadline before starting new input or application work; otherwise consume queued events in stable host sequence order. Existing current APIs retain their documented ordering. Future host timestamps cannot retroactively revive an expired owner; adopting kernel-arrival timestamps requires a separate clock-domain and admission decision. Record timer precedence in the simulator rather than relying on thread timing.

Completion, closing and draining are distinct. Peer close, idle expiration and local failures do not share an unconditional reply path. Implement protocol closure against [RFC 9000 section 10](https://www.rfc-editor.org/rfc/rfc9000.html#section-10); this document selects local scheduling and ownership policy, not an alternative wire standard.

## Receive transaction

1. The endpoint attributes a datagram to a connection/path under explicit bounded admission. It owns one outer receive/diagnostic ledger entry. Unknown CIDs cannot allocate arbitrary TLS owners.
2. Iterate framed packet boundaries without scanning ciphertext for resynchronization. Authenticate into separate scratch and identify packet-number space; failure cannot grant authenticated packet history or TLS input.
3. Build a bounded candidate effect list: replay/history, CID observations, all frame syntax, all sent-history ACK claims, all CRYPTO overlaps and stream/flow-control final-size effects. Preflight every capacity/counter used by commit. No provider/application callback is allowed yet.
4. If any participant rejects, discard candidate effects. Error classification may produce a separate terminal transition according to protocol rules. Do not accidentally roll back diagnostic counting while retaining an earlier ACK or CRYPTO mutation.
5. Commit accepted packet effects under the single owner using only operations proven nonfailing after preflight. Then perform bounded TLS/application event delivery. A callback failure after commit is terminal follow-up, not grounds for pretending the authenticated packet was never received.

Transaction invariant: for participant state vector `S`, a preflight rejection leaves `S_after = S_before`. On success, every effect is applied exactly once. The outer attributed-datagram counter, discard counters and terminal-error reporting are separate explicitly documented ledgers; an invalid later packet does not undo a previously accepted coalesced packet. Amplification attribution is decided once per datagram/path, never once per coalesced packet. Define which attributed failed packets earn credit in the endpoint's admission policy and test spoofed/unknown routing; do not bury that decision in a parser.

A CONNECTION_CLOSE observation does not authorize delivering earlier CRYPTO before full admission. Test valid-first/malformed-last frames, unsent ACK after a valid ACK, conflicting CRYPTO after a valid prefix, final-size mismatch after valid STREAM data, allocation failure at every preflight step and generation/counter exhaustion.

## Send plan lifecycle

Use one immutable prepared datagram per serialized submission. The plan owns bytes and records connection/path generation, selected frame receipts, packet-number reservations, protected byte counts and budget debits. Packet numbers are reserved before encryption; reusing a plan reuses identical ciphertext, not a newly encrypted variant. A changed frame/key/header requires new reservations after exposure.

| Host result | Custody/accounting | Next permitted action |
| --- | --- | --- |
| known atomic success | commit sent history, ACK receipt, congestion, pacing, path bytes and activity exactly once | retire plan and schedule next work |
| would-block; zero bytes accepted | retain immutable plan; do not debit successful-send participants | await writable/capacity or cancel; revalidate generation before submission |
| known unsent failure | no successful-send commit; burn reserved numbers conservatively | explicit retry with retained exact plan if contract permits, or terminal host error |
| partial or outcome unknown | atomic host contract violated; conservatively regard exposure as possible | stop further sends on that path, revoke application progress and terminate under host-error cleanup; never retry changed bytes under those numbers |
| duplicate/stale completion | no participant changes | reject stale receipt; never double-debit or revive retired custody |

All known-success commit steps must be infallible under the reservations. If an implementation discovers a post-send capacity failure, treat it as an invariant violation with conservative exposure accounting and terminal cleanup; do not report the packet as unsent. Deferred/asynchronous sends need an explicit retained plan and exactly-one completion contract before being supported; the initial host seam is synchronous/nonblocking.

## Local error taxonomy

| Class | Local state rule | Peer-visible policy |
| --- | --- | --- |
| invalid local configuration | construction fails before input | no packet |
| capacity/no progress | preserve pending custody; expose precise wait reason | no automatic close unless declared exhaustion policy says terminal |
| untrusted framing/authentication failure | no authenticated-state commit | apply version/context-specific discard/error rules; avoid diagnostic oracle |
| authenticated semantic violation | reject candidate effects, then one terminal owner handles it | map to defined transport error at permitted protection level |
| TLS authentication/ALPN/parameter rejection | deny readiness, clear pending delivery on terminal path | one adapter owns alert/transport error mapping |
| local stale token/reentry/impossible host count | stable local misuse/invariant error; preserve unrelated owners | never echo internal addresses or exception strings |
| deadline/cancel/host failure | no new application delivery; release each owned object once | timeout/cancel policy determines silent teardown or permitted close |

Numeric transport errors and TLS alert mapping must be specified alongside the dispatch code and standards tests; local reason names alone are not wire values. Secret material, private keys, plaintext and raw provider error queues are not routine logs. Retain bounded escaped diagnostics and exact local failure categories.

## Refinement tests

Q07 owns before/after snapshots for every participant; Q08 owns nonce/reservation and byte-flight ledgers; Q14 supplies deterministic equal-time order and replayable seeds. Check failure before commit separately from failure during delivery after commit. Existing Python safety models cover narrower abstract rules; add a mapping from each concrete transaction to its model action before treating a model as supporting evidence.
