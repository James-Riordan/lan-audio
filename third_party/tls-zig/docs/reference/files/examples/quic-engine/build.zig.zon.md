# `examples/quic-engine/build.zig.zon`

Source: [examples/quic-engine/build.zig.zon](../../../../../examples/quic-engine/build.zig.zon)  
Source SHA-256: `dd575a2931f3010dc679d42dff63f1ca013ea8e40ae001121777c3b4e6b81810`  
Snapshot bytes: 276. Review date: 2026-09-26.

## Responsibility

Standalone native recordless consumer manifest.

## Ownership, invariants and failure behavior

A new separately fingerprinted local consumer package using the exact compiler and local TLS dependency. Existing TLS/QUIC package pins and records consumer fingerprint are unchanged. Its manifest closure contains only its build and source.

## Verification

Native results are scoped to Windows x86_64; see current status, canonical completion receipts and retained qualification runs. This file alone does not establish a completed platform or production QUIC stack.
