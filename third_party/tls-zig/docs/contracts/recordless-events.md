# Recordless TLS event custody: implementation design

Status: proposed T1/Q1 design, not an exported API. The existing records Engine and Driver retain their present contracts. Work packages T01–T06 and Q00–Q01 own implementation and integration. This document selects bounded acknowledged events so those files can be implemented against one ownership model.

## Owners and units

One connection owner serializes provider entry, event inspection, acknowledgement, cancel and destruction. Callbacks cannot reenter it. QUIC owns ordered per-level CRYPTO input and outbound retransmission custody; TLS owns provider state, pending event storage, authentication policy and all temporary secret copies. TLS never owns UDP, packet numbers, loss timers or stream data.

Use explicit `EncryptionLevel`, `Direction`, `CipherSuite`, `ByteCount`, `EventId` and monotonic-time types. Initial secrets come from QUIC's version-specific derivation. The first integrated profile allows Initial, Handshake and Application handshake bytes, AES-128-GCM/SHA-256, TLS 1.3, explicit trust/identity, one selected opaque ALPN and no early data/resumption. Unsupported configuration fails before input is accepted. Do not infer a total provider-memory bound from event storage.

`EventId = (owner_generation, sequence)`. Allocate a fresh owner generation at construction; never reuse one while stale handles may exist. Increment sequence without wrap. Exhaustion becomes terminal before emitting an ambiguous ID. The owner-generation allocator and finite-width overflow rule must be designed and tested; the finite model checks two distinguishable issuers, not allocator correctness or arbitrary wraparound.

## Proposed operations

| Operation | Caller provides | Result / retained ownership | Failure rule |
| --- | --- | --- | --- |
| construct | immutable policy, capacities, local parameter copy, injected clocks | exclusive live owner | validate capability and capacity before allocation; unwind partial construction |
| offerCrypto | level and borrowed contiguous byte slice | exact accepted prefix; TLS copies accepted bytes into bounded input custody | zero means no progress; suffix remains QUIC-owned; no cross-level substitution |
| advance | bounded operation budget | progress, pending event, needs input, or terminal reason | never spin on unchanged provider state; preserve provider retry semantics |
| nextEvent | live owner | same immutable head and ID until acknowledged | no head yields explicit empty result; borrow ends at ack/cancel/deinit |
| acknowledge | exact head ID and completed consumer action | head retired once; next event becomes visible | stale, foreign, tail or unconsumed head rejected with no mutation |
| decideParameters | pending peer-parameter decision and validated result | accept recorded or terminal transport-parameter error | no application-ready event while decision pending |
| cancel | live or already canceled owner | terminal; all borrows invalid and provider detached before freeing input custody | idempotent cleanup, no resumed provider calls |
| deinit | exclusively owned handle | destroys owner and clears owned secret storage | no callbacks can refer to released context afterward; reuse of raw freed handle is invalid |

Acknowledgement means the QUIC side has copied bytes into retransmission custody, derived/installed a secret, or copied and accepted a control result as appropriate. It does not mean a UDP datagram was sent or acknowledged by the peer. Do not connect TLS event lifetime directly to network ACK lifetime. Use bounded consumer receipts or internal sequencing to enforce this rule; a caller-supplied boolean is only a trusted contract assertion.

## Callback adapter and backpressure

OpenSSL's external interface supports partial outbound acceptance and retains an offered inbound buffer until its release callback. Secret callbacks identify encryption level and direction. These provider rules require a separate input lease and copied outbound/control events. [OpenSSL 3.5 callback interface](https://docs.openssl.org/3.5/man3/SSL_set_quic_tls_cbs/)

| Provider interaction | Proposed adapter action | Capacity/failure behavior |
| --- | --- | --- |
| send handshake prefix | copy accepted prefix into owned outbound event; associate current write level | success with zero consumed for byte-output backpressure; never report bytes accepted before copy |
| request inbound bytes | expose one stable input lease from accepted custody | no data returns empty; no second nonempty lease while one is retained |
| release inbound lease | require matching outstanding lease/length; retire once only when release succeeds | reject inconsistent release terminally; do not free before provider releases or is destroyed |
| yield traffic secret | validate suite/length/direction; copy to reserved control storage and update level at defined ordering point | callback failure is terminal; do not treat a failed secret callback as a retryable queue-full response |
| peer parameters | copy bounded bytes and enqueue decision obligation | reject excess size; peer-parameter parsing and policy still belong to QUIC |
| alert | retain bounded terminal alert code and schedule transport close mapping | no records-layer alert packet; best-effort close must obey current transport limits |

Reserve non-byte control capacity before entering the provider. A single provider call may produce multiple callbacks; establish and test a bound or use a checked emergency terminal path. Never advertise infallible backpressure merely because the send callback can pause. Interleave secrets and byte events in actual callback order, preserving write-level changes before dependent output; do not assume one secret pair or one event per advance call.

Input lease storage must survive cancellation until the provider can no longer access it. Teardown order: prohibit new entry, destroy/detach provider, invalidate public borrows, clear owned secret bytes, release input/event allocations. If implementation requires a different order, demonstrate callback/reference safety with fault injection before changing the contract.

## Readiness and completion

QUIC handshake completion and confirmation are distinct. Key availability alone does not establish application readiness; peer authentication, ALPN and transport-parameter policy remain gates. Preserve role-specific confirmation/key-discard rules rather than collapsing them into a single TLS-ready flag. [RFC 9001 sections 4.1 and 4.9](https://www.rfc-editor.org/rfc/rfc9001.html#section-4.1)

Proposed project readiness predicate:

`ready = live AND tls_finished AND required_peer_policy_passed AND alpn_accepted AND peer_parameters_accepted AND required_keys_installed`.

For a server configured without client certificates, policy acceptance must not report a certified client identity. Parameter acceptance and secret installation acknowledgements may arrive after provider Finished; a completion event cannot overtake those obligations. Post-handshake CRYPTO still needs a bounded processing path even when resumption issuance is disabled; define handling of forbidden/unrequested messages in tests.

## Failures and diagnostics

Distinguish unsupported configuration, capacity/no-progress, malformed peer input, peer-policy rejection, stale caller token, provider fatal error, cancellation and exhausted counters. Specify which leave state unchanged and which revoke all further progress. Logs contain stable reason codes, levels, byte counts and event identifiers; no secret, key, private certificate material or plaintext dump. Peer-facing close mapping is owned once by the QUIC adapter.

## Required evidence before T1 completion

The initial callback probe is recorded in [capability evidence](../verification/quic-provider-probe.md). It exercises only ClientHello output, send backpressure and send failure. It provides no evidence for receive-release, secret, peer-parameter or authenticated-completion behavior.

Implement the 12 T01–T06 acceptance obligations in the shared plan, including both-role real handshakes, wrong identity/ALPN, partial input, blocked output, each callback failure, stale/foreign tokens and cancellation at every retained object. Connect model actions to concrete operations and record the refinement mapping; model success cannot substitute for those tests.

## Revision 5 implementation refinement

The [authenticated provider experiment](../verification/quic-provider-pair.md) exercises both roles, inbound release, directional secrets, parameters, callback failure and a post-handshake ticket. It does not complete the public wrapper. Follow the [lease transaction and scheduling contract](provider-leases.md): failure preserves held custody, teardown callbacks remain valid, and byte budgets are distinct from provider-call counts. Exactly-once retirement does not imply exactly one callback invocation after a failed attempt.

## Implemented pure core — T01/T03

The `tls_quic` module now supplies `contract` and `events`. `normalize` and `Plan.verify` implement explicit, allocation-free admission. `Queue.next`, `consume` and `acknowledge` implement stable borrow, successful consumer action and retirement as distinct operations. A callback success is a trusted assertion that copying/derivation/policy acceptance completed; arbitrary consumer code cannot be proved honest by the library. Payload memory is cleared before allocator handoff. No provider input lease or TLS Engine is implemented by these modules.

The queue rejects callback reentry. The future Engine must destroy its provider while callback context and input remain valid before canceling the queue. Sequence and owner allocation fail before wrapping. Owner domain/generation tokens are process-memory identities; keep the defining module loaded while tokens exist. Read [current evidence](../verification/t01-implementation.md) for finite trace and native memory checks.
