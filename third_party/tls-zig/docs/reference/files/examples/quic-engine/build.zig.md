# `examples/quic-engine/build.zig`

Source: [examples/quic-engine/build.zig](../../../../../examples/quic-engine/build.zig)  
Source SHA-256: `43a299083c92998b7f842930fae27bd09b739546fade46d0b99efd010e77df1f`  
Snapshot bytes: 1338. Review date: 2026-09-26.

## Responsibility

Separate production native Engine import and runtime staging.

## Ownership, invariants and failure behavior

Imports dep.module("tls_quic_engine") through its package dependency. Builds a production executable, installs/stages exported locked DLLs beside it and runs against tracked package fixtures. It does not use private symbols or test hooks. Both native optimization modes exercise the actual public module. Only current Windows x86_64 runtime packaging is supported.

## Verification

Native results are scoped to Windows x86_64; see current status, canonical completion receipts and retained qualification runs. This file alone does not establish a completed platform or production QUIC stack.

### `build` — line 2

[Source declaration](../../../../../examples/quic-engine/build.zig#L2)

```zig
pub fn build(b: *std.Build) void {
```

Preserves the explicit input validation, serialization, custody and cleanup rules above. Native tests observe its results and failure effects.
