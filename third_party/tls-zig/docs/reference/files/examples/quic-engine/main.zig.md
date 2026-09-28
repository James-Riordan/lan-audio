# `examples/quic-engine/main.zig`

Source: [examples/quic-engine/main.zig](../../../../../examples/quic-engine/main.zig)  
Source SHA-256: `7458353d8a7327d7f99c1ba65add2875e2acb41ec422c713e3ff1d2f0cad2775`  
Snapshot bytes: 4063. Review date: 2026-09-26.

## Responsibility

Production-import recordless handshake and acknowledged custody demonstration.

## Ownership, invariants and failure behavior

Creates explicit fixture client/server policy, pumps each copied CRYPTO prefix to its peer, validates parameter bytes and acknowledges each event only after consumer success. Tracks partial event progress across WouldBlock. Requires one completion per role and calls cancel/deinit through native ownership. The demonstration validates secret receipt but deliberately retains no packet keys: production QUIC consumers must install packet keys before acknowledging. Hard-coded fixture paths and certificate time are for this executable test only; there are no sockets or application data.

## Verification

Native results are scoped to Windows x86_64; see current status, canonical completion receipts and retained qualification runs. This file alone does not establish a completed platform or production QUIC stack.

### `accept` — line 14

[Source declaration](../../../../../examples/quic-engine/main.zig#L14)

```zig
    fn accept(arg: *anyopaque, event: c.Event) c.ConsumeError!void {
```

Preserves the explicit input validation, serialization, custody and cleanup rules above. Native tests observe its results and failure effects.

### `pump` — line 45

[Source declaration](../../../../../examples/quic-engine/main.zig#L45)

```zig
    fn pump(host: *Host) !void {
```

Preserves the explicit input validation, serialization, custody and cleanup rules above. Native tests observe its results and failure effects.

### `config` — line 55

[Source declaration](../../../../../examples/quic-engine/main.zig#L55)

```zig
fn config(server: bool) c.Config {
```

Preserves the explicit input validation, serialization, custody and cleanup rules above. Native tests observe its results and failure effects.

### `main` — line 64

[Source declaration](../../../../../examples/quic-engine/main.zig#L64)

```zig
pub fn main() !void {
```

Preserves the explicit input validation, serialization, custody and cleanup rules above. Native tests observe its results and failure effects.
