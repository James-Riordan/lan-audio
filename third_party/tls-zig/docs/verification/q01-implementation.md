# Current implementation — protected real TLS packet journeys

Q01 is complete within scope: actual certificate TLS runs through protected Initial and Handshake packets with loss, reordering, exact packet replay, repeated CRYPTO and accepted Retry. **9 of 37 packages are complete; 28 remain unfinished; all 89 obligations are retained.** This is not a production-ready endpoint or universal OS release.

The separate QUIC tests/integration package starts ClientHello before learning the server SCID, binds admitted packet observations once, derives server parameters from actual Retry/CID state, and authenticates both native roles under explicit trust/SAN/ALPN with optional mutual TLS. Accepted Retry validates an address-bound token while preserving the original ClientHello bytes and packet numbers. Initial protection and Retry integrity alone do not authenticate peer identity.

## Executed qualification

- Three integration tests pass in Debug and ReleaseSafe. Per-space sent/received and arrival-order ledgers prove the deliberate packet drop, Handshake ordering 1,0,2, exact packet replay, fresh-PN repeated CRYPTO and Retry PN continuity. Protected ACKs retire all copied bytes; final native input equals outgoing CRYPTO once, byte-for-byte.
- Actual-wire malformed server and role-invalid client parameters map to 0x08; wrong SAN/ALPN reject authentication, with ALPN mapped to 0x178. Neither peer becomes ready in the negative journeys. Every processed native-event prefix cancels in both roles, with stable terminal rejection, cleared keys and leak-checked repeated teardown.
- All sixteen Q00 adapter tests and its separate production consumer pass in both modes, along with all 122 earlier QUIC tests and four examples. Models pass normally and under Python -O. Both exact 166-file SDK checks pass. The earlier eight completion receipts and all existing production sources remain unchanged.
- The first qualification attempt retained passing integration/adapter checks but rejected a cached regression result without an executed test count. Its logs remain in q01-protected-tls-runs. Final source-bound qualification uses fresh per-command local caches in q01-fresh-protected-tls-runs and records ten passing runs.

## Execution and remaining limits

Run the pinned compiler's `zig build test -Doptimize=Debug -j1 --summary all` and ReleaseSafe equivalent from the QUIC tests/integration directory in a full source checkout. This test package depends on sibling tls-zig and its locked Windows SDK. It is intentionally outside the root production archive's tests-excluding allowlist. Root package fingerprints and dependencies were not changed.

This is a bounded offline host with one non-padding frame per packet, explicit simulated loss decisions and lifetime CRYPTO histories. It does not implement full connection transactions, timer-based recovery, congestion, streams, sockets, history reclamation or independent QUIC endpoint interoperability. Q02 adds application packet protection next. The earlier seven-target pure compile evidence remains valid but does not qualify native TLS on other OSs. MacBook testing remains at the final GitHub clone/test stage, and CI/CD follows later, as requested. No publication, pin update or TLS verification bypass occurred.

The canonical Q01 receipt and execution logs live in the QUIC peer. [Final maintenance gates](q01-final-gates.json) and [change audit](q01-change-audit.json) record consistency checks. [Q00 adapter checkpoint](q00-implementation.md) and [records identity checkpoint](peer-identity-implementation.md) remain sealed.
