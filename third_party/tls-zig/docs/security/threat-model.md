# Threat model and release blockers

Scope: hostile network bytes, malicious peers, malformed certificates, replay/reordering, packet loss, resource exhaustion, host callback misuse and dependency substitution. Trusted inputs include the selected compiler/backend provenance, configured trust and expected peer identity, serialization of library ownership and the correctness of the cryptographic provider. A compromised host or stolen provider key is outside this library's ability to repair.

| Boundary | Abuse | Required defense/evidence |
| --- | --- | --- |
| Packet parser | Truncation, huge lengths, overflow, aliasing | Checked bounds, immutable failure state, bounded fuzz corpus |
| Authentication gate | Initial or synthetic secret mistaken for identity | Explicit TLS/policy/parameter completion gate and negative peer tests |
| CRYPTO history | Conflicting retransmission, gaps, huge offset | Full preflight, fixed cap, once-only contiguous delivery |
| ACK/recovery | Unsent ACK, wrong space, late duplicate, timer manipulation | Sent history validation, independent spaces, monotonic time |
| Server path | Reflection amplification, forged migration | Per-address budget and independent address validation |
| TLS records | Invalid trust/SAN/ALPN, tampering, truncated close | Fail closed before data release; preserve authenticated shutdown |
| Driver callbacks | Impossible count, would-block spin, reentry | Validate counts, serialized owner, deadline and cancellation policy |
| Dependencies | Wrong DLL, changed archive, stale configuration | Exact file set/hash, loaded-path verification, unconditional validation |
| Diagnostics | Secret leakage and untrusted reason rendering | Redaction, bounded escaped output, no secret logging by default |

## Current limitations requiring design or evidence

QUIC lacks a real TLS provider integration, 1-RTT connection/streams, complete multi-space recovery and path lifecycle, native UDP endpoint and independent peer qualification. TLS's records buffers are bounded, but provider heap and CPU are not globally bounded. Current build and TCP demo are Windows-specific. Revocation policy, credential generations and deployment-specific trust rotation are not implemented. These are explicit roadmap requirements, not capabilities inferred from folder names.

0-RTT and resumption are excluded from the initial target. Enabling them requires a dedicated replay and application-idempotency design, persisted transport-parameter compatibility and ticket-key policy. No automatic plaintext fallback, validation-off client mode, request replay or silent provider substitution is permitted.

## Dependency and license custody

The TLS SDK retains upstream LICENSE.txt and exact hashes. QUIC vector NOTICE is retained unchanged. No new license is invented for either project; a distributable release must establish the repository's own license and verify third-party notices. SDK headers, compiled libraries and helper scripts are documented as upstream material, not rewritten or independently cryptographically audited here. A new provider version requires fresh qualification; no permanent security claim attaches to a version pin.
