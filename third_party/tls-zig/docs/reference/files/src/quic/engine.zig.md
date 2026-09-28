# `src/quic/engine.zig`

Source: [src/quic/engine.zig](../../../../../src/quic/engine.zig)  
Source SHA-256: `850643b2f3c52022ac164bf9e975c07171458d093047ce31762aa038d2b0bc36`  
Snapshot bytes: 20611. Review date: 2026-09-26.

## Responsibility

Stable native owner, bounded input custody, event acknowledgement and authenticated readiness.

## Ownership, invariants and failure behavior

Engine is a serialized, move-only value owning a stable allocated callback State. Init verifies the normalized plan against actual provider capabilities before allocating. Allocation is a fixed queue/slots pair, three input rings and State. The input byte capacity is per encryption level: total ring allocation is three times that limit, checked for overflow. Future-level input cannot consume another level's capacity. Offers copy exactly the reported prefix; zero input is progress, never EOF. A full ring reports input_capacity. A lower retired encryption level poisons the owner.

Native receive borrows one contiguous bounded ring prefix. Matching release clears and retires it once; failed release retains custody until native destruction. Callback context and input storage remain alive while SSL_free can release the lease. Terminal failure closes public entry before destroying the native owner, then cancels/clears events and input; wrapper allocations are released by deinit. Cancel and deinit are idempotent. Every callback and public entry is serialized; callback reentry is rejected. A moved/copied alias is not a second owner.

Advance performs one native drive with explicit input/output byte budgets, verifies reported counts, respects queued events, and distinguishes network input, local work and event capacity. The configured monotonic deadline gates handshake completion; backward time is rejected. Certificate wall time is independently supplied through the plan. Native TLS completion does not imply application readiness: peer parameters must pass the consumer, four directional secret events must complete their consumer action and acknowledgement, and all preceding output events must retire. One completion event is then queued; isReady becomes true only after its acknowledgement. Its peer-authentication enum distinguishes verified server identity, verified client certificate and configured no-mTLS server policy.

Consumer WouldBlock retains the same event and bytes. Rejected parameters cause PeerPolicyRejected; another rejected action causes ConsumerRejected. Stale or foreign acknowledgements cannot retire a head. Consumer code must retain partial progress, copy/install keys and validate role-aware QUIC parameters before reporting success. The Engine does not interpret QUIC transport parameters, encrypt packets, provide sockets or feed TLS records. Post-handshake CRYPTO uses the same bounded input and event custody; allowed tickets produce no second completion, forbidden KeyUpdate fails terminally.

Diagnostics copy counts and provider error codes, never plaintext or secrets. Test-only hooks exercise retained-release cleanup and overconsumption; the production consumer compiles with those hooks removed. Byte budgets do not impose a total OpenSSL heap or time bound.

Encryption-level integrity: each input lease is bounded to a single TLS Handshake header or message body, tracked independently per level across one-byte fragments and ring wrap. The provider can retain a final message lease while processing it; any queued old-level bytes beyond that exact lease are rejected before new events or readiness escape the drive. Message framing prevents a large lease from hiding surplus bytes belonging to a subsequent old-level message. The four-byte TLS header is used only for bounds; OpenSSL remains responsible for message semantics and authentication. Framing metadata is cleared at teardown. The independently reproduced surplus-Initial failure and fix are retained in the level-integrity evidence.

## Verification

Native results are scoped to Windows x86_64; see current status, canonical completion receipts and retained qualification runs. This file alone does not establish a completed platform or production QUIC stack.

### `capabilities` — line 36

[Source declaration](../../../../../src/quic/engine.zig#L36)

```zig
pub fn capabilities() c.Capabilities {
```

Preserves the explicit input validation, serialization, custody and cleanup rules above. Native tests observe its results and failure effects.

### `prefix` — line 49

[Source declaration](../../../../../src/quic/engine.zig#L49)

```zig
    fn prefix(self: *Framing, bytes: []const u8) usize {
```

Preserves the explicit input validation, serialization, custody and cleanup rules above. Native tests observe its results and failure effects.

### `live` — line 99

[Source declaration](../../../../../src/quic/engine.zig#L99)

```zig
    fn live(self: *State) Error!void {
```

Preserves the explicit input validation, serialization, custody and cleanup rules above. Native tests observe its results and failure effects.

### `block` — line 103

[Source declaration](../../../../../src/quic/engine.zig#L103)

```zig
    fn block(self: *State, level: c.EncryptionLevel) []u8 {
```

Preserves the explicit input validation, serialization, custody and cleanup rules above. Native tests observe its results and failure effects.

### `terminate` — line 108

[Source declaration](../../../../../src/quic/engine.zig#L108)

```zig
    fn terminate(self: *State, reason: Error) void {
```

Preserves the explicit input validation, serialization, custody and cleanup rules above. Native tests observe its results and failure effects.

### `ready` — line 127

[Source declaration](../../../../../src/quic/engine.zig#L127)

```zig
    fn ready(self: *State) Error!void {
```

Preserves the explicit input validation, serialization, custody and cleanup rules above. Native tests observe its results and failure effects.

### `reject` — line 139

[Source declaration](../../../../../src/quic/engine.zig#L139)

```zig
    fn reject(self: *State, reason: Error) i32 {
```

Preserves the explicit input validation, serialization, custody and cleanup rules above. Native tests observe its results and failure effects.

### `init` — line 148

[Source declaration](../../../../../src/quic/engine.zig#L148)

```zig
    pub fn init(allocator: std.mem.Allocator, plan: c.Plan) Error!Engine {
```

Preserves the explicit input validation, serialization, custody and cleanup rules above. Native tests observe its results and failure effects.

### `live` — line 175

[Source declaration](../../../../../src/quic/engine.zig#L175)

```zig
    fn live(self: *Engine) Error!*State {
```

Preserves the explicit input validation, serialization, custody and cleanup rules above. Native tests observe its results and failure effects.

### `offerCrypto` — line 180

[Source declaration](../../../../../src/quic/engine.zig#L180)

```zig
    pub fn offerCrypto(self: *Engine, level: c.EncryptionLevel, bytes: []const u8) Error!c.Transfer {
```

Preserves the explicit input validation, serialization, custody and cleanup rules above. Native tests observe its results and failure effects.

### `advance` — line 197

[Source declaration](../../../../../src/quic/engine.zig#L197)

```zig
    pub fn advance(self: *Engine, now: c.MonotonicNs, budget: Budget) Error!c.Wait {
```

Preserves the explicit input validation, serialization, custody and cleanup rules above. Native tests observe its results and failure effects.

### `nextEvent` — line 263

[Source declaration](../../../../../src/quic/engine.zig#L263)

```zig
    pub fn nextEvent(self: *Engine) Error!?c.Event {
```

Preserves the explicit input validation, serialization, custody and cleanup rules above. Native tests observe its results and failure effects.

### `consume` — line 280

[Source declaration](../../../../../src/quic/engine.zig#L280)

```zig
    pub fn consume(self: *Engine, token: c.EventId, consumer: c.Consumer) Error!void {
```

Preserves the explicit input validation, serialization, custody and cleanup rules above. Native tests observe its results and failure effects.

### `acknowledge` — line 293

[Source declaration](../../../../../src/quic/engine.zig#L293)

```zig
    pub fn acknowledge(self: *Engine, token: c.EventId) Error!void {
```

Preserves the explicit input validation, serialization, custody and cleanup rules above. Native tests observe its results and failure effects.

### `isReady` — line 307

[Source declaration](../../../../../src/quic/engine.zig#L307)

```zig
    pub fn isReady(self: *Engine) Error!bool {
```

Preserves the explicit input validation, serialization, custody and cleanup rules above. Native tests observe its results and failure effects.

### `diagnostic` — line 311

[Source declaration](../../../../../src/quic/engine.zig#L311)

```zig
    pub fn diagnostic(self: *const Engine) ?native.Result {
```

Preserves the explicit input validation, serialization, custody and cleanup rules above. Native tests observe its results and failure effects.

### `cancel` — line 315

[Source declaration](../../../../../src/quic/engine.zig#L315)

```zig
    pub fn cancel(self: *Engine) Error!void {
```

Preserves the explicit input validation, serialization, custody and cleanup rules above. Native tests observe its results and failure effects.

### `deinit` — line 320

[Source declaration](../../../../../src/quic/engine.zig#L320)

```zig
    pub fn deinit(self: *Engine) Error!void {
```

Preserves the explicit input validation, serialization, custody and cleanup rules above. Native tests observe its results and failure effects.

### `setHooks` — line 332

[Source declaration](../../../../../src/quic/engine.zig#L332)

```zig
    fn setHooks(self: *Engine, hooks: *TestHooks) Error!void {
```

Preserves the explicit input validation, serialization, custody and cleanup rules above. Native tests observe its results and failure effects.

### `nativeBytes` — line 337

[Source declaration](../../../../../src/quic/engine.zig#L337)

```zig
fn nativeBytes(bytes: []const u8) native.Bytes {
```

Preserves the explicit input validation, serialization, custody and cleanup rules above. Native tests observe its results and failure effects.

### `nativeConfig` — line 340

[Source declaration](../../../../../src/quic/engine.zig#L340)

```zig
fn nativeConfig(cfg: c.Config) native.Config {
```

Preserves the explicit input validation, serialization, custody and cleanup rules above. Native tests observe its results and failure effects.

### `context` — line 373

[Source declaration](../../../../../src/quic/engine.zig#L373)

```zig
fn context(arg: ?*anyopaque) *State {
```

Preserves the explicit input validation, serialization, custody and cleanup rules above. Native tests observe its results and failure effects.

### `levelFromNative` — line 376

[Source declaration](../../../../../src/quic/engine.zig#L376)

```zig
fn levelFromNative(value: u32) ?c.EncryptionLevel {
```

Preserves the explicit input validation, serialization, custody and cleanup rules above. Native tests observe its results and failure effects.

### `view` — line 384

[Source declaration](../../../../../src/quic/engine.zig#L384)

```zig
fn view(bytes: native.Bytes) ?[]const u8 {
```

Preserves the explicit input validation, serialization, custody and cleanup rules above. Native tests observe its results and failure effects.

### `send` — line 388

[Source declaration](../../../../../src/quic/engine.zig#L388)

```zig
fn send(arg: ?*anyopaque, raw_level: u32, bytes: native.Bytes, accepted: *usize) callconv(.c) i32 {
```

Preserves the explicit input validation, serialization, custody and cleanup rules above. Native tests observe its results and failure effects.

### `receive` — line 398

[Source declaration](../../../../../src/quic/engine.zig#L398)

```zig
fn receive(arg: ?*anyopaque, raw_level: u32, maximum: usize, out: *native.Bytes) callconv(.c) i32 {
```

Preserves the explicit input validation, serialization, custody and cleanup rules above. Native tests observe its results and failure effects.

### `release` — line 416

[Source declaration](../../../../../src/quic/engine.zig#L416)

```zig
fn release(arg: ?*anyopaque, raw_level: u32, bytes: native.Bytes) callconv(.c) i32 {
```

Preserves the explicit input validation, serialization, custody and cleanup rules above. Native tests observe its results and failure effects.

### `secret` — line 437

[Source declaration](../../../../../src/quic/engine.zig#L437)

```zig
fn secret(arg: ?*anyopaque, raw_level: u32, raw_direction: u32, suite: u32, bytes: native.Bytes) callconv(.c) i32 {
```

Preserves the explicit input validation, serialization, custody and cleanup rules above. Native tests observe its results and failure effects.

### `parameters` — line 451

[Source declaration](../../../../../src/quic/engine.zig#L451)

```zig
fn parameters(arg: ?*anyopaque, bytes: native.Bytes) callconv(.c) i32 {
```

Preserves the explicit input validation, serialization, custody and cleanup rules above. Native tests observe its results and failure effects.

### `alert` — line 457

[Source declaration](../../../../../src/quic/engine.zig#L457)

```zig
fn alert(arg: ?*anyopaque, code: u32) callconv(.c) i32 {
```

Preserves the explicit input validation, serialization, custody and cleanup rules above. Native tests observe its results and failure effects.
