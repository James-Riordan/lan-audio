# `tests/quic_contract.zig`

Source: [tests/quic_contract.zig](../../../../tests/quic_contract.zig)  
Source SHA-256: `d70ca89559bd6928ab6255a251b30b2e51eba7913d3cc29a8ed40c82aa82e4c9`  
Snapshot bytes: 27975. Review date: 2026-09-26.

## Responsibility

Actual Engine conformance with separate host ledgers and direct OpenSSL reference peer.

## Ownership, invariants and failure behavior

Ten named tests cover both Engine roles, one-byte fragments, ring wrap, output backpressure, acknowledged policy/key readiness, stale/early/duplicate events, callback reentry, wrong identity/trust/ALPN/parameters, failed release and alert, all four wrapper allocation failure positions, stale plan, input limits, deadline and excess provider counts. The allocator observer checks that provider destruction precedes wrapper frees and that live input/event payload allocations are zeroed at allocator handoff.

The direct C reference peer bypasses both the Engine and its C adapter. Both roles compare four directional secrets in memory, require exact peer authentication and parameters, and compare per-level byte counts and SHA-256 ledgers across independently implemented host/provider boundaries. Packet decryption derives QUIC keys with Zig HKDF/AES, reverses independently generated header protection, authenticates PING plus padding and rejects tampering/wrong-direction keys. This is a genuine protected QUIC packet check, not independent QUIC endpoint interoperability: both TLS peers use the same locked OpenSSL.

Post-handshake tickets are withheld until acknowledged readiness, then driven with one-byte budgets and checked for local work and a single completion. A forbidden TLS KeyUpdate must become a stable terminal failure. Secret arrays are cleared and never logged; finite test cases do not imply exhaustive protocol or race coverage.

The tenth test injects eight surplus Initial bytes after a legitimate hello in each role, with both one-byte and whole-buffer native input budgets. The owner must fail UnexpectedLevel before readiness, including when a large provider lease would previously have hidden the boundary. All earlier positive, negative, fragmentation and cancellation tests remain active.

An additional exhaustive finite-prefix cancellation test restarts both roles at every borrowed handshake event through completion. Cancellation must deny readiness and stale operations, preserve callback state through native teardown, and clear/free all four wrapper allocations once.

## Verification

Native results are scoped to Windows x86_64; see current status, canonical completion receipts and retained qualification runs. This file alone does not establish a completed platform or production QUIC stack.

### `accept` — line 28

[Source declaration](../../../../tests/quic_contract.zig#L28)

```zig
    fn accept(arg: *anyopaque, event: c.Event) c.ConsumeError!void {
```

Preserves the explicit input validation, serialization, custody and cleanup rules above. Native tests observe its results and failure effects.

### `pump` — line 84

[Source declaration](../../../../tests/quic_contract.zig#L84)

```zig
    fn pump(self: *Host) !void {
```

Preserves the explicit input validation, serialization, custody and cleanup rules above. Native tests observe its results and failure effects.

### `config` — line 104

[Source declaration](../../../../tests/quic_contract.zig#L104)

```zig
fn config(server: bool, small: bool) c.Config {
```

Preserves the explicit input validation, serialization, custody and cleanup rules above. Native tests observe its results and failure effects.

### `create` — line 114

[Source declaration](../../../../tests/quic_contract.zig#L114)

```zig
fn create(cfg: c.Config) !Engine {
```

Preserves the explicit input validation, serialization, custody and cleanup rules above. Native tests observe its results and failure effects.

### `pair` — line 117

[Source declaration](../../../../tests/quic_contract.zig#L117)

```zig
fn pair(small: bool, reentry: bool) !void {
```

Preserves the explicit input validation, serialization, custody and cleanup rules above. Native tests observe its results and failure effects.

### `allocator` — line 168

[Source declaration](../../../../tests/quic_contract.zig#L168)

```zig
    fn allocator(self: *@This()) std.mem.Allocator {
```

Preserves the explicit input validation, serialization, custody and cleanup rules above. Native tests observe its results and failure effects.

### `alloc` — line 171

[Source declaration](../../../../tests/quic_contract.zig#L171)

```zig
    fn alloc(arg: *anyopaque, length: usize, alignment: std.mem.Alignment, ret: usize) ?[*]u8 {
```

Preserves the explicit input validation, serialization, custody and cleanup rules above. Native tests observe its results and failure effects.

### `free` — line 179

[Source declaration](../../../../tests/quic_contract.zig#L179)

```zig
    fn free(arg: *anyopaque, memory: []u8, alignment: std.mem.Alignment, ret: usize) void {
```

Preserves the explicit input validation, serialization, custody and cleanup rules above. Native tests observe its results and failure effects.

### `negative` — line 189

[Source declaration](../../../../tests/quic_contract.zig#L189)

```zig
fn negative(kind: Failure) !void {
```

Preserves the explicit input validation, serialization, custody and cleanup rules above. Native tests observe its results and failure effects.

### `allocateEngine` — line 260

[Source declaration](../../../../tests/quic_contract.zig#L260)

```zig
fn allocateEngine(allocator: std.mem.Allocator) !void {
```

Preserves the explicit input validation, serialization, custody and cleanup rules above. Native tests observe its results and failure effects.

### `reference_create` — line 300

[Source declaration](../../../../tests/quic_contract.zig#L300)

```zig
extern fn reference_create(role: u32, fixtures: [*:0]const u8, tickets: i32, out: *?*Reference) i32;
```

Preserves the explicit input validation, serialization, custody and cleanup rules above. Native tests observe its results and failure effects.

### `reference_destroy` — line 301

[Source declaration](../../../../tests/quic_contract.zig#L301)

```zig
extern fn reference_destroy(owner: *?*Reference) void;
```

Preserves the explicit input validation, serialization, custody and cleanup rules above. Native tests observe its results and failure effects.

### `reference_advance` — line 302

[Source declaration](../../../../tests/quic_contract.zig#L302)

```zig
extern fn reference_advance(peer: *Reference) i32;
```

Preserves the explicit input validation, serialization, custody and cleanup rules above. Native tests observe its results and failure effects.

### `reference_offer` — line 303

[Source declaration](../../../../tests/quic_contract.zig#L303)

```zig
extern fn reference_offer(peer: *Reference, level: u32, bytes: [*]const u8, length: usize, accepted: *usize) i32;
```

Preserves the explicit input validation, serialization, custody and cleanup rules above. Native tests observe its results and failure effects.

### `reference_peek` — line 304

[Source declaration](../../../../tests/quic_contract.zig#L304)

```zig
extern fn reference_peek(peer: *Reference, level: u32, bytes: *[*]const u8, length: *usize) i32;
```

Preserves the explicit input validation, serialization, custody and cleanup rules above. Native tests observe its results and failure effects.

### `reference_retire` — line 305

[Source declaration](../../../../tests/quic_contract.zig#L305)

```zig
extern fn reference_retire(peer: *Reference, level: u32, length: usize) i32;
```

Preserves the explicit input validation, serialization, custody and cleanup rules above. Native tests observe its results and failure effects.

### `reference_ready` — line 306

[Source declaration](../../../../tests/quic_contract.zig#L306)

```zig
extern fn reference_ready(peer: *Reference) i32;
```

Preserves the explicit input validation, serialization, custody and cleanup rules above. Native tests observe its results and failure effects.

### `reference_secret` — line 307

[Source declaration](../../../../tests/quic_contract.zig#L307)

```zig
extern fn reference_secret(peer: *Reference, level: u32, direction: u32, out: *[32]u8) i32;
```

Preserves the explicit input validation, serialization, custody and cleanup rules above. Native tests observe its results and failure effects.

### `reference_packet` — line 308

[Source declaration](../../../../tests/quic_contract.zig#L308)

```zig
extern fn reference_packet(peer: *Reference, out: [*]u8, capacity: usize, written: *usize) i32;
```

Preserves the explicit input validation, serialization, custody and cleanup rules above. Native tests observe its results and failure effects.

### `reference_ledger` — line 309

[Source declaration](../../../../tests/quic_contract.zig#L309)

```zig
extern fn reference_ledger(peer: *Reference, level: u32, direction: u32, out: *[32]u8, bytes: *usize) i32;
```

Preserves the explicit input validation, serialization, custody and cleanup rules above. Native tests observe its results and failure effects.

### `transferReference` — line 311

[Source declaration](../../../../tests/quic_contract.zig#L311)

```zig
fn transferReference(peer: *Reference, host: *Host, application: bool) !usize {
```

Preserves the explicit input validation, serialization, custody and cleanup rules above. Native tests observe its results and failure effects.

### `checkLedgers` — line 328

[Source declaration](../../../../tests/quic_contract.zig#L328)

```zig
fn checkLedgers(peer: *Reference, host: *const Host) !void {
```

Preserves the explicit input validation, serialization, custody and cleanup rules above. Native tests observe its results and failure effects.

### `expandPacketKey` — line 340

[Source declaration](../../../../tests/quic_contract.zig#L340)

```zig
fn expandPacketKey(comptime length: usize, secret: [32]u8, comptime label: []const u8) [length]u8 {
```

Preserves the explicit input validation, serialization, custody and cleanup rules above. Native tests observe its results and failure effects.

### `decryptPacket` — line 347

[Source declaration](../../../../tests/quic_contract.zig#L347)

```zig
fn decryptPacket(packet: [61]u8, secret: [32]u8) ![32]u8 {
```

Preserves the explicit input validation, serialization, custody and cleanup rules above. Native tests observe its results and failure effects.

### `independentPeer` — line 367

[Source declaration](../../../../tests/quic_contract.zig#L367)

```zig
fn independentPeer(server: bool, tickets: bool) !void {
```

Preserves the explicit input validation, serialization, custody and cleanup rules above. Native tests observe its results and failure effects.

### `cancelAtEvent` — line 453

[Source declaration](../../../../tests/quic_contract.zig#L453)

```zig
fn cancelAtEvent(server_side: bool, ordinal: usize) !bool {
```

Preserves the explicit input validation, serialization, custody and cleanup rules above. Native tests observe its results and failure effects.
