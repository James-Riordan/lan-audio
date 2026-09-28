# Coordinated packet-space recovery

Q04 is complete within its documented component scope. Q00/Q01/Q02/Q03 are requalified against the additive public-root change. **12 of 37 packages are complete; 25 remain; all 89 acceptance obligations are retained.** This is not a production-ready endpoint or an all-OS runtime release.

The new recovery owner keeps separate bounded Initial, Handshake and Application sent histories with shared RTT and bytes-in-flight accounting. It chooses one next recovery timer, isolates ACK effects by space and debits flight once on acknowledgment, loss or key discard. PTO requests one pending probe without declaring loss. Confirmation, amplification gating, Retry and cancellation have explicit lifecycle rules.

History reclamation preserves successful-send ordinals and a documented ACK-validation horizon. Retained late-original ACKs return their frame token without a second flight debit; reclaimed originals have no effect on retransmission custody. All retained ACK ranges are checked before mutation. Opaque tokens refer to host-owned frame data; the host still supplies successful-send facts and idempotent frame/CC handling.

All 156 root tests pass in Debug and ReleaseSafe, including sixteen new recovery tests. A separate public consumer passes in both modes. Fifteen independent component traces reproduce using unmodified pinned quic-go history and its reviewed threshold predicate. Independent integer expectations cover much larger skipped packet-number gaps, time boundaries and byte accounting. This is component comparison, not complete endpoint interoperability.

All 47 qualification steps pass: native recovery and retained real TLS/key/application integration, independent vectors and peer traces, seven pure cross-target profiles, safety models and before/after SDK checks. Both projects' documentation, shared-plan and lifecycle checks pass normally and under Python optimization. All 166 locked SDK files, TLS source/seven receipts, original pins and frozen fixture remain unchanged. The only existing QUIC source edit for this increment is the public root export/test import.

Native runtime evidence remains Windows x86_64. Cross-build targets are x86/ARM64 Windows, x64/ARM64 Linux musl, Intel/ARM64 macOS and x64 FreeBSD, each compiling four pure profiles. Native other-OS ABI/runtime qualification, congestion control integration, full connection/streams/endpoints, resource enforcement and independent network interoperability remain open. MacBook testing stays at the final GitHub-ready clone stage; CI/CD follows later.

Next work is Application ACK integration and the remaining stream/connection prerequisites. No GitHub publication or TLS-verification bypass occurred.
