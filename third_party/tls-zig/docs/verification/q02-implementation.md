# Current implementation — application packet protection

Q02 is complete within scope: the public QUIC module exports AES-128-GCM short-header protection/opening with explicit usage and packet-number custody. **10 of 37 packages are complete; 27 remain unfinished; all 89 obligations are retained.** The codebases are not yet production-ready across all OSs.

SendBudget refuses repeated/decreasing packet numbers and excessive per-key encryption, consuming a number when encryption completes even if a later socket send blocks/fails. ReceiveBudget tracks failed authentication across connection keys and stops at its integrity limit. Parsing/sample/buffer failures preserve scratch; every post-copy error clears the copied packet extent. Reserved bits, phase mismatch and empty payload are rejected only after authentication. The codec returns authenticated borrowed data without committing replay, largest PN or key generations. Q03 owns update/retirement policy; application release still requires configured TLS authentication.

## Executed qualification

- All 129 QUIC tests pass in Debug and ReleaseSafe, including seven new application tests. Nineteen valid complete .NET packet vectors match exactly at every PN width, truncation wraps, high nonce bytes and final sendable PN; three independently authenticated malformed vectors cover reserved bits and empty payload. All 22 fixtures independently regenerate without source writes.
- Every bit corruption/truncation rejects without replay commit. Tests cover exact production usage bounds and smaller limits, counts across keys, blocked-send PN reuse, alias/size/phase failures, sample padding, maximum packets and scratch/output suffix preservation.
- Separate public and actual-TLS application consumers pass in both modes. The real consumer waits for both configured-authentication readiness gates and then protects/opens 1-RTT packets using actual application keys in both directions. All sixteen prior adapter tests/consumer and protected loss/reordering/Retry journeys, including 21 cancellation prefixes, remain passing.
- Seven additional pure targets compile both the original four examples and the new application consumer: x86/aarch64 Windows, x86_64/aarch64 Linux musl, x86_64/aarch64 macOS and x86_64 FreeBSD. These are compile-only, not native TLS/runtime evidence.
- Twenty-seven final qualification runs pass, including models normally/under Python -O and exact 166-file SDK checks before/after. All seven TLS completion receipts and all TLS source remain unchanged. Only existing QUIC src/root.zig changes, adding the application export/test import. Q00/Q01 were explicitly reopened for that closure and are resealed; their earlier receipts remain in history.

## Execution and remaining work

Run the pinned compiler from examples/application: `zig build run -Doptimize=ReleaseSafe` exercises the pure consumer; `zig build native -Dnative-tls=true -Doptimize=ReleaseSafe` adds the exact sibling Windows TLS SDK/fixtures. Default cross builds use only the pure consumer. No root package fingerprint/dependency or frozen fixture changes occurred.

Key updates, long-lived packet-space reclamation, full connection/recovery/stream/endpoint behavior, provider resource bounds, packaging and other-native-OS qualification remain open. Native execution evidence is Windows x86_64. The MacBook remains at the final GitHub clone/test stage; CI/CD follows later. No GitHub publication or TLS verification bypass occurred.

Source-bound Q00/Q01/Q02 receipts and q02-application-runs live in the QUIC peer. [Final consistency gates](q02-final-gates.json) and [change audit](q02-change-audit.json) verify the retained scope. [Protected TLS checkpoint](q01-implementation.md) and [records identity checkpoint](peer-identity-implementation.md) preserve earlier progress.
