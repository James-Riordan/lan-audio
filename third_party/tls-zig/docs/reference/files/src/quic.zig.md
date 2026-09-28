# `src/quic.zig`

Source: [src/quic.zig](../../../../src/quic.zig)  
Source SHA-256: `40b6f17b4cae413fc28a6b05f6fff1898b1288af1d36ebbce00379915e9478fd`  
Snapshot bytes: 187. Review date: 2026-09-26.

## Responsibility

Pure recordless configuration and event-custody module exports.

## Ownership, invariants and failure behavior

Exports contract and events through the tls_quic build module. This module has no native backend import and makes no TLS handshake or network capability claim. Existing records Engine/Driver remain separate. Consumers must obtain and verify actual capabilities before construction.

## Verification

[T01/T03 implementation evidence](../../../verification/t01-implementation.md) records scope, commands and remaining gates. Update this source contract only after reviewing changed behavior.
