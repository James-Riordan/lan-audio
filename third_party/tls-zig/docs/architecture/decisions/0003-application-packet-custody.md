# Application packet custody

Status: selected; reviewed during Q02 qualification on 2026-09-26. This refines the existing AES-128-GCM profile and serialized-owner rules, without expanding protocol/platform support.

## Need and alternatives

The public short-header codec must account for AEAD usage and cannot let a blocked or failed socket operation cause packet-number reuse. A stateless encryption helper with a comment asking callers to count usage leaves an easy omission. A full key-update/connection owner inside the codec would couple this bounded primitive to unfinished Q03/Q06 lifecycle policy.

## Selected boundary

Use an explicit serialized SendBudget for one directional key generation, and a ReceiveBudget shared across all connection keys. Successful encryption consumes the PN and usage allowance before the host submits ciphertext. All preflight failures preserve output and budget. The host either retains exactly that ciphertext or encrypts different content under a fresh PN; no rollback of encryption exposure is offered.

The host carries last-PN continuity across generation changes and resets only per-key encryption count when installing genuinely new keys. Integrity failures never reset on an update. Limits may be reduced, but never exceed the supported suite's conservative confidentiality/integrity bounds. These structs follow the existing move-only ownership convention; Zig does not make their fields private or prevent copying, and such misuse is not supported.

Receive authenticates before checking reserved bits, expected candidate phase or empty payload. It commits no replay, largest-PN or key-generation state. Pre-copy errors preserve scratch, and post-copy errors wipe the complete copied extent. The host owns CID/frame/replay admission, packet-width choice from ACK state, path MTU, final-short-packet coalescing, spin policy and configured authentication before application release. Q03 owns secret generation/retirement; a phase bit alone cannot replace keys.

## Compatibility and evidence

The additive `application` export preserves existing root APIs, root manifests/builds and the frozen fixture. A standalone public consumer exercises the import, and its optional native profile uses actual authenticated TLS application keys in both directions. Seven tests cover 22 independent .NET wire vectors, malformed authentication boundaries, nonce/usage limits, aliases and scratch/state snapshots. The final Q02 receipt binds actual qualification; pure target compilation is separate from native OS support. Earlier Q00/Q01 receipts are retained and requalified because the public-root closure changes.

Source contract in the QUIC peer: `docs/reference/files/src/packet/application.zig.md`. [Current qualification](../../verification/current.md).
