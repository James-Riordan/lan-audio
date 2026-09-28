# `examples/quic-contract/provider.zig`

Source: [examples/quic-contract/provider.zig](../../../../../examples/quic-contract/provider.zig)  
Source SHA-256: `0c81a656f93b1dece96a0480e8e351dcfd543e225e0a7fc9483b8524180cc7b1`  
Snapshot bytes: 663. Review date: 2026-09-26.

## Responsibility

Separate package consumer of the pure recordless contract and event queue.

## Ownership, invariants and failure behavior

Builds against dep.module("tls_quic") without SDK artifacts. provider.zig is explicitly a synthetic contract fixture, not TLS. Construction verifies the plan before incrementing observable counters; the host checks unavailable capability rejection, exact input prefix, real secret-event copy/ack and terminal cancellation. Uses a fixed local allocator, no sockets, filesystem credentials or native provider. Package fingerprint is newly generated for this example; existing package pins remain unchanged.

## Verification

[T01/T03 implementation evidence](../../../../verification/t01-implementation.md) records scope, commands and remaining gates. Update this source contract only after reviewing changed behavior.

### `construct` — line 6

[Source declaration](../../../../../examples/quic-contract/provider.zig#L6)

```zig
    pub fn construct(self: *Provider, plan: c.Plan, caps: c.Capabilities) c.Error!void {
```

Independent test fixture operation; preserve explicit expected outcomes and owned resource cleanup.

### `consume` — line 10

[Source declaration](../../../../../examples/quic-contract/provider.zig#L10)

```zig
    pub fn consume(self: *Provider, input: []const u8) c.Transfer {
```

Independent test fixture operation; preserve explicit expected outcomes and owned resource cleanup.
