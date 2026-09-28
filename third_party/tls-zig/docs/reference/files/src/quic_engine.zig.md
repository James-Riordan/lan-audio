# `src/quic_engine.zig`

Source: [src/quic_engine.zig](../../../../src/quic_engine.zig)  
Source SHA-256: `0539e2b42f43244a97580be5f03775a676af524e3460176eff6c63600055cebb`  
Snapshot bytes: 403. Review date: 2026-09-26.

## Responsibility

Public native recordless Engine module exports.

## Ownership, invariants and failure behavior

Exports Engine, Budget, Error, capabilities and the shared SDK-free contract. The separate tls_quic module continues to require no SDK. TestHooks is void outside test compilation and is not a production fault-injection facility. The native module requires the locked Windows x86_64 backend. Public production import is exercised by the standalone quic-engine consumer in both native build modes.

## Verification

Native results are scoped to Windows x86_64; see current status, canonical completion receipts and retained qualification runs. This file alone does not establish a completed platform or production QUIC stack.
