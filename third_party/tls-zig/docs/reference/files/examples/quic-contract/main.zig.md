# `examples/quic-contract/main.zig`

Source: [examples/quic-contract/main.zig](../../../../../examples/quic-contract/main.zig)  
Source SHA-256: `7b7982c218c8e83741db7afde71d88579e92f36e7ee8c8b833d7418aa61427ff`  
Snapshot bytes: 2287. Review date: 2026-09-26.

## Responsibility

Separate package consumer of the pure recordless contract and event queue.

## Ownership, invariants and failure behavior

Builds against dep.module("tls_quic") without SDK artifacts. provider.zig is explicitly a synthetic contract fixture, not TLS. Construction verifies the plan before incrementing observable counters; the host checks unavailable capability rejection, exact input prefix, real secret-event copy/ack and terminal cancellation. Uses a fixed local allocator, no sockets, filesystem credentials or native provider. Package fingerprint is newly generated for this example; existing package pins remain unchanged.

## Verification

[T01/T03 implementation evidence](../../../../verification/t01-implementation.md) records scope, commands and remaining gates. Update this source contract only after reviewing changed behavior.

### `accept` — line 7

[Source declaration](../../../../../examples/quic-contract/main.zig#L7)

```zig
    fn accept(raw: *anyopaque, event: c.Event) c.ConsumeError!void {
```

Independent test fixture operation; preserve explicit expected outcomes and owned resource cleanup.

### `main` — line 15

[Source declaration](../../../../../examples/quic-contract/main.zig#L15)

```zig
pub fn main() !void {
```

Independent test fixture operation; preserve explicit expected outcomes and owned resource cleanup.
