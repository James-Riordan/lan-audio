# Engineering principles and scope

This handoff defines a reviewable target for a bounded QUIC v1 transport and a TLS 1.3 provider, dated 2026-09-26. It is not a claim of universal perfection, complete protocol compliance, security certification or implementation completeness. A requirement is finished only when its implementation, tests and evidence agree.

## Ownership boundaries

QUIC owns UDP packet protection, packet-number spaces, frame admission, CRYPTO retransmission, streams, flow control, congestion/loss scheduling, path validation and connection lifecycle. TLS owns handshake transcript processing, certificate checks, ALPN, traffic-secret production and provider lifetime. Applications own request semantics, authorization and whether an authenticated partial response is complete enough to commit. Hosts own sockets, polling, time, entropy and admission budgets.

Current tls-zig implements ordered TLS records/Driver and a separate native recordless QUIC Engine. The explicitly injected QUIC adapter uses that Engine for real authenticated handshake messages and directional secrets, while preserving the old frozen type-only fixture for compatibility. QUIC CRYPTO must not be passed to Engine.feedRecords. Qualification and unfinished capabilities are tracked in [current status](../verification/current.md). [RFC 9001](https://www.rfc-editor.org/info/rfc9001/)

## Design rules

1. Keep existing public imports stable while new capability is implemented. Directory depth must express responsibility, not prestige. Retain the small working core paths and introduce subdirectories for new owners.
2. Every state transition has one owner. Wrappers own the mutation of wrapped custody. Fields documented as read-only are still publicly writable in Zig; misuse resistance is a future API-hardening task, not a language-enforced guarantee.
3. Treat local acceptance, transport transmission, peer acknowledgment, peer authentication and application commit as distinct milestones.
4. Parse and validate before changing state. Cross-component operations need a preflight for every participant and an infallible commit under serialized ownership, or an explicit rollback strategy.
5. Document allocation, limits and CPU work separately. Fixed queue capacity does not imply bounded provider heap or constant operation cost.
6. Explicit capabilities replace universal platform assumptions. Unsupported configurations fail before a connection starts.
7. Deterministic replay is a test property. Network delivery and application requests are not automatically idempotent. Retry only the operation whose contract allows it.
8. Mechanized checks prove their stated model/coverage only. Independent wire vectors, peer interoperability and security review remain separate evidence.

## Versioned decisions

Use a decision record before changing the TLS seam, buffer reclamation, cryptographic suite set, clock units, public ownership, error mapping or support matrix. Record the consumer need, alternatives, selected rule, compatibility effect and acceptance tests. A decision can be superseded; keep the old record readable.
