# `examples/quic-contract/build.zig`

Source: [examples/quic-contract/build.zig](../../../../../examples/quic-contract/build.zig)  
Source SHA-256: `6748052bac1238badda3164f7cedf4c00d873b30c6ea717c7f24b5bac538eb0f`  
Snapshot bytes: 685. Review date: 2026-09-26.

## Responsibility

Separate package consumer of the pure recordless contract and event queue.

## Ownership, invariants and failure behavior

Builds against dep.module("tls_quic") without SDK artifacts. provider.zig is explicitly a synthetic contract fixture, not TLS. Construction verifies the plan before incrementing observable counters; the host checks unavailable capability rejection, exact input prefix, real secret-event copy/ack and terminal cancellation. Uses a fixed local allocator, no sockets, filesystem credentials or native provider. Package fingerprint is newly generated for this example; existing package pins remain unchanged.

## Verification

[T01/T03 implementation evidence](../../../../verification/t01-implementation.md) records scope, commands and remaining gates. Update this source contract only after reviewing changed behavior.

### `build` — line 2

[Source declaration](../../../../../examples/quic-contract/build.zig#L2)

```zig
pub fn build(b: *std.Build) void {
```

Independent test fixture operation; preserve explicit expected outcomes and owned resource cleanup.
