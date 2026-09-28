# `tests/quic/events.zig`

Source: [tests/quic/events.zig](../../../../../tests/quic/events.zig)  
Source SHA-256: `150c5935bbcc29c660d11520bf8b4bdb77b6ef074ea6b493b48b917ccf3424bd`  
Snapshot bytes: 12763. Review date: 2026-09-26.

## Responsibility

Adversarial queue traces, allocator cleanup and model refinement tests.

## Ownership, invariants and failure behavior

Exercises stable copies, full queue/control reservation, stale/foreign/tail/early acknowledgement, consumer backpressure/reentry, cancellation, secret clearing, all allocation failures and idempotent deinit. AuditAllocator inspects payload before rawFree and checks exactly two frees. Enumerates 32768 five-action words against an independent pending/copied/retired ledger; terminal suffixes query canceled state and repeated cancel. The finite scope does not prove unbounded behavior.

## Verification

[T01/T03 implementation evidence](../../../../verification/t01-implementation.md) records scope, commands and remaining gates. Update this source contract only after reviewing changed behavior.

### `limits` — line 6

[Source declaration](../../../../../tests/quic/events.zig#L6)

```zig
fn limits() c.Limits {
```

Independent test fixture operation; preserve explicit expected outcomes and owned resource cleanup.

### `accept` — line 13

[Source declaration](../../../../../tests/quic/events.zig#L13)

```zig
    fn accept(raw: *anyopaque, event: c.Event) c.ConsumeError!void {
```

Independent test fixture operation; preserve explicit expected outcomes and owned resource cleanup.

### `consumer` — line 24

[Source declaration](../../../../../tests/quic/events.zig#L24)

```zig
    fn consumer(self: *Sink) c.Consumer {
```

Independent test fixture operation; preserve explicit expected outcomes and owned resource cleanup.

### `accept` — line 116

[Source declaration](../../../../../tests/quic/events.zig#L116)

```zig
        fn accept(raw: *anyopaque, event: c.Event) c.ConsumeError!void {
```

Independent test fixture operation; preserve explicit expected outcomes and owned resource cleanup.

### `allocateAndFree` — line 135

[Source declaration](../../../../../tests/quic/events.zig#L135)

```zig
fn allocateAndFree(allocator: std.mem.Allocator) !void {
```

Independent test fixture operation; preserve explicit expected outcomes and owned resource cleanup.

### `allocator` — line 164

[Source declaration](../../../../../tests/quic/events.zig#L164)

```zig
    fn allocator(self: *@This()) std.mem.Allocator {
```

Independent test fixture operation; preserve explicit expected outcomes and owned resource cleanup.

### `alloc` — line 167

[Source declaration](../../../../../tests/quic/events.zig#L167)

```zig
    fn alloc(raw: *anyopaque, len: usize, alignment: std.mem.Alignment, ret: usize) ?[*]u8 {
```

Independent test fixture operation; preserve explicit expected outcomes and owned resource cleanup.

### `free` — line 174

[Source declaration](../../../../../tests/quic/events.zig#L174)

```zig
    fn free(raw: *anyopaque, memory: []u8, alignment: std.mem.Alignment, ret: usize) void {
```

Independent test fixture operation; preserve explicit expected outcomes and owned resource cleanup.
