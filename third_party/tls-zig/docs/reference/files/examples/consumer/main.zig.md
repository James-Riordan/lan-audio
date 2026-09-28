# `examples/consumer/main.zig`

Source: [examples/consumer/main.zig](../../../../../examples/consumer/main.zig)  
Source SHA-256: `2248f9026d2312679d110460bd59f824d71bc9bb0f806a0880618a27f1d07087`  
Snapshot bytes: 11880. Review date: 2026-09-26.

## Responsibility

External package consumer exercising client/server TLS and early-response upload probing.

## Contract, ownership and failure behavior

Uses public fixtures, frozen certificate time and small bounded HTTP messages. Cancellation thread signals a flag; engine remains serialized. Upload gates after 17 ciphertext bytes and finishes the accepted block before response commit.

## Next implementation work

Do not copy this fixed-response parser into a general HTTP client. Preserve exact request/response and authenticated close oracles. Add consumer-specific framing and total upload deadlines in the actual application.

## Verification obligations

Run the owning build or maintenance entry point described in the [verification guide](../../../../verification/strategy.md). A passive fixture/record is verified by hash and by its named consumers; it is not an executable test.

## Dependency edges

`std`, `tls`. External module names resolve through the owning build graph; relative paths resolve from this source file.

## Declaration-by-declaration work map

Each entry points to the exact current source. Adjacent source documentation is retained below. Direct error names and assigned self fields are mechanically extracted navigation cues; they exclude transitive errors, pointer writes and full branch reasoning. Use the module contract above for obligations.

### `demo_open` — line 13

[Source declaration](../../../../../examples/consumer/main.zig#L13)

```zig
extern fn demo_open() isize;
```

Review `demo_open` as part of this file’s responsibility: External package consumer exercising client/server TLS and early-response upload probing. Preserve the stated ownership/failure contract when extending this entry point.

### `demo_accept` — line 14

[Source declaration](../../../../../examples/consumer/main.zig#L14)

```zig
extern fn demo_accept() isize;
```

Review `demo_accept` as part of this file’s responsibility: External package consumer exercising client/server TLS and early-response upload probing. Preserve the stated ownership/failure contract when extending this entry point.

### `demo_close` — line 15

[Source declaration](../../../../../examples/consumer/main.zig#L15)

```zig
extern fn demo_close(socket: isize) void;
```

Review `demo_close` as part of this file’s responsibility: External package consumer exercising client/server TLS and early-response upload probing. Preserve the stated ownership/failure contract when extending this entry point.

### `demo_send` — line 16

[Source declaration](../../../../../examples/consumer/main.zig#L16)

```zig
extern fn demo_send(socket: isize, bytes: [*]const u8, len: c_int) c_int;
```

Review `demo_send` as part of this file’s responsibility: External package consumer exercising client/server TLS and early-response upload probing. Preserve the stated ownership/failure contract when extending this entry point.

### `demo_recv` — line 17

[Source declaration](../../../../../examples/consumer/main.zig#L17)

```zig
extern fn demo_recv(socket: isize, bytes: [*]u8, len: c_int) c_int;
```

Review `demo_recv` as part of this file’s responsibility: External package consumer exercising client/server TLS and early-response upload probing. Preserve the stated ownership/failure contract when extending this entry point.

### `demo_poll` — line 18

[Source declaration](../../../../../examples/consumer/main.zig#L18)

```zig
extern fn demo_poll(socket: isize, writing: c_int, timeout_ms: u32) c_int;
```

Review `demo_poll` as part of this file’s responsibility: External package consumer exercising client/server TLS and early-response upload probing. Preserve the stated ownership/failure contract when extending this entry point.

### `demo_now` — line 19

[Source declaration](../../../../../examples/consumer/main.zig#L19)

```zig
extern fn demo_now() u64;
```

Review `demo_now` as part of this file’s responsibility: External package consumer exercising client/server TLS and early-response upload probing. Preserve the stated ownership/failure contract when extending this entry point.

### `demo_name` — line 20

[Source declaration](../../../../../examples/consumer/main.zig#L20)

```zig
extern fn demo_name() [*:0]const u8;
```

Review `demo_name` as part of this file’s responsibility: External package consumer exercising client/server TLS and early-response upload probing. Preserve the stated ownership/failure contract when extending this entry point.

### `demo_client_ca` — line 21

[Source declaration](../../../../../examples/consumer/main.zig#L21)

```zig
extern fn demo_client_ca() [*:0]const u8;
```

Review `demo_client_ca` as part of this file’s responsibility: External package consumer exercising client/server TLS and early-response upload probing. Preserve the stated ownership/failure contract when extending this entry point.

### `demo_sleep` — line 22

[Source declaration](../../../../../examples/consumer/main.zig#L22)

```zig
extern fn demo_sleep(ms: u32) void;
```

Review `demo_sleep` as part of this file’s responsibility: External package consumer exercising client/server TLS and early-response upload probing. Preserve the stated ownership/failure contract when extending this entry point.

### `demo_setting` — line 23

[Source declaration](../../../../../examples/consumer/main.zig#L23)

```zig
extern fn demo_setting(name: [*:0]const u8, fallback: u32) u32;
```

Review `demo_setting` as part of this file’s responsibility: External package consumer exercising client/server TLS and early-response upload probing. Preserve the stated ownership/failure contract when extending this entry point.

Direct error exits in the syntactic region: `SocketPoll`, `TransportFailure`.

Directly assigned owner fields in the syntactic region: `gate_budget`.

### `send` — line 29

[Source declaration](../../../../../examples/consumer/main.zig#L29)

```zig
fn send(context: *anyopaque, bytes: []const u8) error{TransportFailure}!?usize {
```

Review `send` as part of this file’s responsibility: External package consumer exercising client/server TLS and early-response upload probing. Preserve the stated ownership/failure contract when extending this entry point.

Direct error exits in the syntactic region: `TransportFailure`.

Directly assigned owner fields in the syntactic region: `gate_budget`.

### `recv` — line 39

[Source declaration](../../../../../examples/consumer/main.zig#L39)

```zig
fn recv(context: *anyopaque, bytes: []u8) error{TransportFailure}!?usize {
```

Review `recv` as part of this file’s responsibility: External package consumer exercising client/server TLS and early-response upload probing. Preserve the stated ownership/failure contract when extending this entry point.

Direct error exits in the syntactic region: `TransportFailure`.

### `run` — line 46

[Source declaration](../../../../../examples/consumer/main.zig#L46)

```zig
fn run(self: *Network, driver: *tls.Driver) !tls.host.Result {
```

Review `run` as part of this file’s responsibility: External package consumer exercising client/server TLS and early-response upload probing. Preserve the stated ownership/failure contract when extending this entry point.

Direct error exits in the syntactic region: `SocketPoll`.

### `cancelLater` — line 63

[Source declaration](../../../../../examples/consumer/main.zig#L63)

```zig
fn cancelLater(flag: *std.atomic.Value(bool), ms: u32) void {
```

Review `cancelLater` as part of this file’s responsibility: External package consumer exercising client/server TLS and early-response upload probing. Preserve the stated ownership/failure contract when extending this entry point.

### `main` — line 68

[Source declaration](../../../../../examples/consumer/main.zig#L68)

```zig
pub fn main() !void {
```

Review `main` as part of this file’s responsibility: External package consumer exercising client/server TLS and early-response upload probing. Preserve the stated ownership/failure contract when extending this entry point.

Direct error exits in the syntactic region: `HandshakeFailed`, `ReadFailed`, `ResponseTooLarge`, `SocketConnect`, `UnexpectedProgress`, `WriteFailed`, `WrongBackend`, `WrongResponse`.

### `upload` — line 113

[Source declaration](../../../../../examples/consumer/main.zig#L113)

```zig
fn upload(network: *Network, driver: *tls.Driver, canceled: *std.atomic.Value(bool)) !void {
```

Deterministic would-block injection over a real TCP connection. The accepted TLS record is deliberately only partly sent when the peer response arrives.

Direct error exits in the syntactic region: `MissedEarlyResponse`, `PrematureClose`, `ProbeNotBackpressured`, `ReadFailed`, `ResponseTooLarge`, `UnexpectedProgress`, `WriteFailed`, `WrongResponse`.

### `serve` — line 175

[Source declaration](../../../../../examples/consumer/main.zig#L175)

```zig
fn serve() !void {
```

Review `serve` as part of this file’s responsibility: External package consumer exercising client/server TLS and early-response upload probing. Preserve the stated ownership/failure contract when extending this entry point.

Direct error exits in the syntactic region: `HandshakeFailed`, `ReadFailed`, `RequestTooLarge`, `SocketAccept`, `UnexpectedProgress`, `WriteFailed`, `WrongRequest`.

## Verified peer leaf export increment

The independent TCP package calls the new public Engine query through driver.engine after successful Driver handshake in both roles. It compares the copied digest with an independently derived fixture constant before application traffic. Hard-coded certificate fingerprints are test-only policy; production enrollment, role/allowlist/renewal/generation ownership belongs to the application. Existing request/response, early upload, cancellation/deadline and authenticated close journeys remain intact.

See the [identity guide](../../../../guides/peer-identity.md) for the application boundary and current evidence.

### `verifyFixturePeer` — line 221

[Source declaration](../../../../../examples/consumer/main.zig#L221)

```zig
fn verifyFixturePeer(engine: *const tls.Engine, comptime hex: []const u8) !void {
```

The independent TCP package calls the new public Engine query through driver.engine after successful Driver handshake in both roles. It compares the copied digest with an independently derived fixture constant before application traffic. Hard-coded certificate fingerprints are test-only policy; production enrollment, role/allowlist/renewal/generation ownership belongs to the application. Existing request/response, early upload, cancellation/deadline and authenticated close journeys remain intact.
