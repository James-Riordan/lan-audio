# Native recordless Engine implementation and qualification

T00/T01/T03/T05/T04/T02/T06 are complete within their acceptance scope: 7 of 37 packages, with all 89 obligations preserved. Thirty packages remain unfinished. This is a qualified Windows x86_64 recordless TLS boundary, not a production QUIC connection or universal OS release.

## Encryption-level regression closed

The external Q00 probe exposed surplus Initial bytes surviving a level transition. Input leases are now bounded to individual TLS Handshake headers/message bodies, and queued old-level surplus is rejected before output/readiness is exposed. All ten Engine tests and the production consumer pass in Debug/ReleaseSafe; the same external probe now exits zero with UnexpectedLevel. Both roles and one-byte/whole-buffer budgets are tested. The prior nine-test checkpoint, failed probe and pre-fix receipts remain historical. See the TLS peer's `t02-level-integrity.md` and `t02-level-gap-probe` evidence.

The native Engine execution was repeated for this behavior change. Core, C ABI, backend integrity and records evidence is reused only where the actual source/build/runtime execution closure is unchanged. Final source hashes and dependency receipts are refreshed. The separate external Windows build-run path issue remains a consumer/platform follow-up; absolute installed executable invocation succeeds.

## Implemented boundary

The existing `tls` and `runtime` exports and records APIs are preserved. `tls_quic` remains an SDK-free configuration/event module. The new `tls_quic_engine` export owns a real native OpenSSL recordless handshake, three bounded copied input rings, stable provider leases and copied output/control events. No TLS record feed is used for CRYPTO.

Client trust, reference DNS/IP identity, credentials, ALPN, wall time and monotonic deadline are explicit. Readiness follows configured authentication, consumer-validated QUIC parameters, four acknowledged directional secret events, retired prior output and one acknowledged completion event. A no-mTLS server reports configured server policy, not verified client identity. A production QUIC owner must derive/install packet keys and apply role/CID parameter policy before acknowledging those events.

The input limit is per encryption level. One native drive obeys byte budgets and reports local work separately from network input and event/input capacity. Provider byte-count violations, callback failures and rejected policy become stable terminal errors. Cancellation closes entry, destroys SSL while callback state/leases are live, then clears custody. `deinit` releases wrapper storage once.

## Executed evidence

| Evidence | Result and limit |
| --- | --- |
| Native C adapter | 25 scenarios pass in Debug and ReleaseSafe: fragmentation/backpressure, authentication/mTLS/DNS/IP/ALPN negatives, each callback fault, lease violations, budgets, copying and reentry. OpenSSL allocation ledger returns to zero after cleanup. |
| Production C/Zig ABI | Two native tests compare every size/alignment/field offset in five types and invoke each actual Zig callback from C, in both modes. LLP64 Windows x86_64 only; other targets explicitly unavailable. |
| Native Engine | Ten named tests pass in both modes: exact byte/hash ledgers, keys/readiness, one-byte ring wrap, failure/allocator/deadline checks, retained-release teardown and cancellation at every borrowed handshake event in both roles. |
| Direct reference peer | Both Engine roles talk to a separately driven direct OpenSSL adapter. All four directional secrets and per-level byte counts/SHA-256 digests agree. This uses the same provider, not an independent QUIC endpoint. |
| Protected packet check | Zig independently derives keys, removes header protection and authenticates a reference C/OpenSSL QUIC short-header packet containing PING/padding. Wrong direction and tampering fail. |
| Post-handshake CRYPTO | Delayed tickets are processed after acknowledged readiness under one-byte work budgets; completion remains singular. Forbidden TLS KeyUpdate is terminal with no application plaintext delivery. |
| Native external consumer | Standalone `dep.module("tls_quic_engine")` consumer runs in Debug/ReleaseSafe, with test hooks absent. It demonstrates custody; it does not retain production packet keys. |
| Pure core | Contract/custody suites and separate consumer pass in both native modes. Seven additional targets compile only: x86/aarch64 Windows, x86_64/aarch64 Linux musl, x86_64/aarch64 macOS and x86_64 FreeBSD. |
| Preserved records | 11 records plus 19 driver tests pass in both modes; public example and separate records consumer pass; 17 independent peer and 14 TCP cases pass. |
| Tools and integrity | 16 backend groups, type misuse controls, safety/custody/lifecycle models pass normally and under Python -O. Exact 166-file SDK validation passes before/after qualification. |

Source-bound canonical receipts are in the TLS peer's `docs/verification/completions/`. `t04-abi-production-runs` binds the actual production ABI; `t02-level-integrity-runs` binds the final ten-test Engine suite; `t02-core-runs`, `t02-extra-runs` and `t02-regression-runs` bind the supporting checks. Earlier checkpoints and failed attempts remain historical, never overwritten to appear passing. Final document/plan checks are recorded separately.

## Build adoption and remaining work

The TLS build file changed to expose the core/Engine modules and test steps. Its previous checkpoint SHA-256 was `b61f99699d71fbc481c52fa81fd2a39a8e59520f8cb330717807713b5c4ee638`; the current value is `7c0523998971a6f23f8db89a6597141433ad0a6778b398b934e99c7874558134`. Records implementation, original package fingerprints, SDK lock and QUIC's pinned `vendor/transport.zig` fixture remain unchanged. Downstream exact-source pins should continue to flag the build change until their owners review this receipt. No downstream pins were changed and no GitHub publication was performed.

Q00 is next in the real QUIC integration chain, followed by the authenticated packet journey and the remaining connection/recovery/stream/endpoint work. T07 and subsequent provider packaging/native-platform gates remain open. Total provider heap/work limits and production resource measurements are not established by byte budgets or leak checks.

Per the user's plan, this Windows 10 machine remains the execution host; macOS native testing is deferred to the final GitHub clone-and-test stage on the 2019 MacBook Pro. CI/CD follows later. These constraints do not turn cross-compilation into native runtime evidence. Universal production readiness remains unclaimed.
