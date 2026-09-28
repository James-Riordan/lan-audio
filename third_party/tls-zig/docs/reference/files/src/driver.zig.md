# `src/driver.zig`

Source: [src/driver.zig](../../../../src/driver.zig)  
Source SHA-256: `f33d5d2a494c6918497af4d0133ae1c2b4e267a5c6a9fd5d24aafd08fed4556f`  
Snapshot bytes: 16070. Review date: 2026-09-26.

## Responsibility

Serialized nonblocking transport driver with bounded ciphertext queues and early-response probe.

## Contract, ownership and failure behavior

Owns Engine, borrows transport context and optional atomic cancellation flag. Read buffer remains exclusively borrowed until the operation completes or fails. Preserve input suffixes and output prefixes. step has at most one transport callback or TLS/BIO operation. Probe cannot bypass unfinished SSL_write, discard ciphertext, complete the write or extend its deadline. Shutdown reads inherit the original close deadline.

## Next implementation work

Keep serialized semantics explicit. Add a separate duplex design only when a consumer needs it. Build deterministic scheduler traces for cancellation, half-close and peer data during blocked output; verify readiness and deadline transitions rather than counting loops as fairness.

## Verification obligations

- [tests/driver.zig](../../../../tests/driver.zig): preserve existing regression assertions and add any changed-boundary cases.

## Dependency edges

`root.zig`, `std`. External module names resolve through the owning build graph; relative paths resolve from this source file.

## Declaration-by-declaration work map

Each entry points to the exact current source. Adjacent source documentation is retained below. Direct error names and assigned self fields are mechanically extracted navigation cues; they exclude transitive errors, pointer writes and full branch reasoning. Use the module contract above for obligations.

### `init` — line 75

[Source declaration](../../../../src/driver.zig#L75)

```zig
pub fn init(config: tls.Config, transport: Transport, canceled: ?*const std.atomic.Value(bool)) Error!Driver {
```

Move-only owner of Engine. The transport and flag must outlive this value.

### `deinit` — line 78

[Source declaration](../../../../src/driver.zig#L78)

```zig
pub fn deinit(self: *Driver) void {
```

Cancel through the serialized owner; borrowed transport context and cancellation flag remain host-owned.

### `cancel` — line 83

[Source declaration](../../../../src/driver.zig#L83)

```zig
pub fn cancel(self: *Driver) void {
```

Call only on the serialized driver thread. Other threads store true into the cancellation flag; they must not close or mutate this Engine.

Directly assigned owner fields in the syntactic region: `active`, `terminal`.

### `abort` — line 88

[Source declaration](../../../../src/driver.zig#L88)

```zig
fn abort(self: *Driver, err: Error) Error {
```

Choose a terminal driver error, cancel/free the engine and remove the active operation. No later callback may continue the abandoned operation.

Directly assigned owner fields in the syntactic region: `active`, `terminal`.

### `check` — line 94

[Source declaration](../../../../src/driver.zig#L94)

```zig
fn check(self: *Driver, now_ms: u64) Error!void {
```

Observe terminal/cancel state before work; reject clock regression, enforce the current absolute operation deadline and tick the engine unless a retained TLS failure is awaiting alert drain.

Direct error exits in the syntactic region: `Canceled`, `InvalidState`, `OperationDeadline`.

Directly assigned owner fields in the syntactic region: `last_ms`.

### `idle` — line 104

[Source declaration](../../../../src/driver.zig#L104)

```zig
fn idle(self: *Driver) Error!void {
```

Require a nonterminal driver with no active operation. Reject overlap with OperationInProgress without starting another operation.

Direct error exits in the syntactic region: `OperationInProgress`.

### `begin` — line 108

[Source declaration](../../../../src/driver.zig#L108)

```zig
fn begin(self: *Driver, op: Operation, now_ms: u64, deadline_ms: u64) Error!void {
```

Preflight idle/time; choose min(requested deadline, retained shutdown deadline); set the operation and reset progress state. Start by feeding any retained input suffix before driving TLS.

Direct error exits in the syntactic region: `InvalidState`.

Directly assigned owner fields in the syntactic region: `active`, `deadline_ms`, `phase`, `probe_phase`, `result`.

### `beginHandshake` — line 118

[Source declaration](../../../../src/driver.zig#L118)

```zig
pub fn beginHandshake(self: *Driver, now_ms: u64, deadline_ms: u64) Error!void {
```

Reject shutdown mode, then begin a handshake under the caller deadline; the engine’s own handshake deadline also applies.

Direct error exits in the syntactic region: `InvalidState`.

### `beginWrite` — line 124

[Source declaration](../../../../src/driver.zig#L124)

```zig
pub fn beginWrite(self: *Driver, bytes: []const u8, now_ms: u64, deadline_ms: u64) Error!void {
```

Copies bytes into the Engine before returning. One block, 1..16384 bytes.

Direct error exits in the syntactic region: `InvalidState`.

Directly assigned owner fields in the syntactic region: `active`.

### `beginRead` — line 136

[Source declaration](../../../../src/driver.zig#L136)

```zig
pub fn beginRead(self: *Driver, buffer: []u8, now_ms: u64, deadline_ms: u64) Error!void {
```

Require nonempty exclusive buffer and an authenticated engine. Borrow the destination until a final result/error, including when shutdown is paused for final data.

Direct error exits in the syntactic region: `InvalidState`.

### `beginShutdown` — line 141

[Source declaration](../../../../src/driver.zig#L141)

```zig
pub fn beginShutdown(self: *Driver, now_ms: u64, deadline_ms: u64) Error!void {
```

Require an authenticated idle owner, begin shutdown and remember the chosen deadline so subsequent reads cannot extend it.

Direct error exits in the syntactic region: `InvalidState`.

Directly assigned owner fields in the syntactic region: `shutdown_deadline_ms`.

### `beginFlush` — line 148

[Source declaration](../../../../src/driver.zig#L148)

```zig
pub fn beginFlush(self: *Driver, now_ms: u64, deadline_ms: u64) Error!void {
```

Send pending TLS protocol output without queueing application data.

Direct error exits in the syntactic region: `InvalidState`.

### `probePeer` — line 159

[Source declaration](../../../../src/driver.zig#L159)

```zig
pub fn probePeer(self: *Driver, buffer: []u8, now_ms: u64, idle_deadline_ms: u64) Error!ProbeResult {
```

Nonblocking early-response probe, idle or during an active write whose SSL_write has completed. Does not send/discard ciphertext or finish/pause that write. Keep driving step to finish the accepted block in wire order. buffer is borrowed only for this call; data(count) is authenticated TLS plaintext, not a complete/committable HTTP response. Idle probes use the supplied deadline; active writes retain their original deadline unchanged.

Direct error exits in the syntactic region: `InvalidState`, `OperationInProgress`, `TransportContract`, `TransportFailure`.

Directly assigned owner fields in the syntactic region: `active`, `deadline_ms`, `eof`, `input_end`, `input_start`, `output_end`, `output_start`, `probe_phase`, `terminal`.

### `step` — line 232

[Source declaration](../../../../src/driver.zig#L232)

```zig
pub fn step(self: *Driver, now_ms: u64) Error!Result {
```

Performs at most one transport callback or one TLS/BIO operation. Pass a fresh monotonic time every call. Poll only for wait_input/wait_output, with a timeout bounded by deadline_ms and the host's cancellation wake cadence.

Direct error exits in the syntactic region: `InvalidState`, `TransportContract`, `TransportFailure`.

Directly assigned owner fields in the syntactic region: `active`, `eof`, `failure`, `input_end`, `input_start`, `output_end`, `output_start`, `phase`, `result`, `terminal`, `wanted`.

## Public type vocabulary

`Transport`, `Result`, `ProbeResult`, `Driver`. Changing fields/tags/errors affects consumers; define migration and negative tests before changing representation.
