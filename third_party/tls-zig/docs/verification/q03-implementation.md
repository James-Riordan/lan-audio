# Current implementation — directional application keys

Q03 is complete within scope: authenticated application-key handoff and directional key-update ownership are implemented and qualified. **11 of 37 packages are complete; 26 remain unfinished; all 89 obligations are retained.** The codebases are not yet production-ready across all OSs.

The adapter transfers both application directions only once, after configured authentication is ready. It transfers generation-zero packet keys and the next traffic secret, clearing its own custody. A serialized owner derives future keys during local maintenance, preserves original header-protection keys, enforces handshake confirmation and later-update ACK/cooldown rules, and retains old read keys for a bounded three-PTO interval. Host cancellation must explicitly reach independently transferred custody.

Authentication returns a provisional ticket: key generations and received packet-number metadata commit only after host CID/replay/frame admission. Forged packets cannot advance them. Encryption consumes packet numbers across key changes even if a later socket operation fails. Integrity failures count across generations; limit and protocol failures clear all owned keys. Retained packet-number ordering survives old-key erasure. The host still supplies actual sent/received histories, valid ACK facts, QUIC confirmation and PTO timing; full history and connection coordination remain future packages.

## Executed qualification

- All 140 QUIC root tests pass in Debug and ReleaseSafe, including eleven key-owner tests and seven application codec tests. Eight independent .NET vectors cover four generations in both directions and match key/IV/header protection/next secret/full ciphertext exactly. The prior 22 independent application vectors also reproduce.
- Five native handoff tests pass in each mode, including early/repeated handoff denial, cancellation at each native event prefix, actual authenticated TLS handoff, forbidden TLS KeyUpdate cleanup, and explicit cancellation after ownership transfer. Public and real-TLS key-update consumers demonstrate provisional admission and simultaneous directional updates.
- Sixteen adapter tests/consumer, three protected handshake journey tests, public and real-TLS application consumers, all root tests and four original examples remain passing in both modes.
- Seven pure targets compile the original examples, application consumer and key-update consumer: x86/aarch64 Windows, x86_64/aarch64 Linux musl, x86_64/aarch64 macOS and x86_64 FreeBSD. These are compile-only results, not native TLS/runtime evidence.
- Thirty-one pre-crash executions are preserved with their original timestamps and logs; six missing checks were executed after recovery against matching source and SDK hashes. All 37 qualification runs pass, including both independent vector recreations, models normally/under Python -O and 166-file SDK checks before/after. All TLS source and seven TLS receipts remain unchanged. Q00/Q01/Q02 are resealed against the changed adapter/public-root closure; earlier exact receipts remain in history.

## Execution and remaining work

From examples/key-update, use the pinned compiler: `zig build run -Doptimize=ReleaseSafe` for the pure consumer, or `zig build run native test -Dnative-tls=true -Doptimize=ReleaseSafe` for native handoff tests/consumers. Default cross builds require no TLS SDK. Root package fingerprints/dependencies and frozen fixture are unchanged.

Source-level masked key selection is not independent compiled constant-time certification. Long-lived packet-space reclamation, full recovery/connection/stream/endpoint behavior, provider resource bounds, packaging and native other-OS qualification remain open. Native execution evidence is Windows x86_64. MacBook testing stays at the final GitHub clone/test stage; CI/CD follows later. No GitHub publication or TLS verification bypass occurred.

Source-bound Q00/Q01/Q02/Q03 receipts and q03-crash-recovery-runs live in the QUIC peer. [Final consistency gates](q03-final-gates.json) and [change audit](q03-change-audit.json) verify the retained scope. [Application packet checkpoint](q02-implementation.md) preserves earlier progress. [Handoff decision](../architecture/decisions/0004-application-key-handoff.md) explains ownership.
