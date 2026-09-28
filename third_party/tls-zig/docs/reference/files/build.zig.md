# `build.zig`

Source: [build.zig](../../../build.zig)  
Source SHA-256: `7c0523998971a6f23f8db89a6597141433ad0a6778b398b934e99c7874558134`  
Snapshot bytes: 10498. Review date: 2026-09-26.

## Responsibility

Build graph for records, portable core and native recordless Engine.

## Ownership, invariants and failure behavior

Preserves tls, runtime and SDK-free tls_quic exports and adds tls_quic_engine with private quic_native_abi and quic.c. quic-engine-test runs the actual owner with a separate direct OpenSSL reference peer. quic-backend-test runs 25 native callback scenarios and independently probes the production Zig ABI. Locked DLLs are staged next to each executable. Native tests use the package fixture working directory; native C scenarios and external consumer track fixture inputs. Existing records tests/examples/consumers remain intact. Standard target selection and pure cross builds do not qualify native provider support on other systems.

## Verification

Native results are scoped to Windows x86_64; see current status, canonical completion receipts and retained qualification runs. This file alone does not establish a completed platform or production QUIC stack.

### `staged` — line 12

[Source declaration](../../../build.zig#L12)

```zig
fn staged(b: *std.Build, artifact: *std.Build.Step.Compile, bin: std.Build.LazyPath, name: []const u8) std.Build.LazyPath {
```

Preserves the explicit input validation, serialization, custody and cleanup rules above. Native tests observe its results and failure effects.

### `build` — line 18

[Source declaration](../../../build.zig#L18)

```zig
pub fn build(b: *std.Build) void {
```

Preserves the explicit input validation, serialization, custody and cleanup rules above. Native tests observe its results and failure effects.
