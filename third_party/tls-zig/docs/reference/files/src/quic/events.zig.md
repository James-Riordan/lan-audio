# `src/quic/events.zig`

Source: [src/quic/events.zig](../../../../../src/quic/events.zig)  
Source SHA-256: `8d1a96ace52219d318b6c85696f769d1533513ba493bf7a6d8b49cc8adfe5d22`  
Snapshot bytes: 9478. Review date: 2026-09-26.

## Responsibility

Bounded queue retaining bytes, secrets, controls and acknowledged consumer custody.

## Ownership, invariants and failure behavior

Queue.init validates payload and descriptor-size multiplication, obtains a fresh owner and allocates descriptor/payload arrays once. OOM unwinds every successful allocation. Queue is logically move-only: do not copy or mutate its implementation fields. No allocation occurs during push, borrow, consume, ack or cancel. Storage is event_slots * event_payload_bytes plus descriptors; it does not bound provider heap. The initial limits are configurable, not a measured universal resource profile.

Data events cannot consume reserved control slots. pushCrypto copies only an exact accepted prefix, with zero/event_capacity on backpressure; empty input emits nothing and is not EOF. Control events copy into stable per-slot payload storage and fail explicitly on overflow. Secret events require Handshake/Application, the selected suite and exactly 32 bytes; Initial secrets belong to QUIC. Native callbacks must map a failed non-pausable control operation to terminal failure in T04.

next returns the same head identity and byte address until ack/cancel/deinit. Appends cannot overwrite a borrowed slot. consume validates exact owner/generation/sequence and head borrow, executes one synchronous consumer callback and marks consumed only on success. A repeated successful consumption is rejected to prevent duplicate consumer effects. WouldBlock/Rejected preserve queue custody; the trusted consumer must make its own failing effects retry-safe and must actually perform the copy/derivation/policy action it reports. This boundary cannot prove honesty of arbitrary caller code. Reentry to every public mutation/query including cancel/deinit is rejected while the callback runs.

acknowledge rejects foreign/tail/stale IDs and early acknowledgements without mutation. Success zeroes the entire payload slot with volatile stores, clears its descriptor, advances the ring and retires custody once. Sequence exhaustion terminates and erases the queue before ID reuse. While live, independently emitted events partition into pending and retired; retirement requires an observed successful consumer action. Cancel invalidates views and zeroes all owned storage; deinit frees each allocation once. Payload uses rawFree after secureZero so Debug poisoning in Allocator.free does not replace observable zeroes before allocator handoff. The test allocator inspects live memory at that handoff, never after free.

This queue owns no provider input leases. The future Engine must close public entry, destroy the provider with callback context/leases still alive, then cancel/deinit this queue. pushComplete is storage only: T02 must check TLS completion, peer/ALPN/parameter policy and installed keys before enqueueing it. Independent five-action traces exercise bounded custody; neither they nor the Python finite model prove all execution lengths or provider correctness.

## Verification

[T01/T03 implementation evidence](../../../../verification/t01-implementation.md) records scope, commands and remaining gates. Update this source contract only after reviewing changed behavior.

### `init` — line 36

[Source declaration](../../../../../src/quic/events.zig#L36)

```zig
    pub fn init(allocator: std.mem.Allocator, limits: c.Limits) Error!Queue {
```

Two allocations, both checked before use. No allocation during push/borrow/ consume/ack/cancel. Payload storage is slots * bytes-per-slot, not provider heap.

### `live` — line 48

[Source declaration](../../../../../src/quic/events.zig#L48)

```zig
    fn live(self: *const Queue) Error!void {
```

Implements the file responsibility and validated ownership/serialization rules above; no hidden network or provider side effects.

### `block` — line 55

[Source declaration](../../../../../src/quic/events.zig#L55)

```zig
    fn block(self: *Queue, index: usize) []u8 {
```

Implements the file responsibility and validated ownership/serialization rules above; no hidden network or provider side effects.

### `requireSequence` — line 59

[Source declaration](../../../../../src/quic/events.zig#L59)

```zig
    fn requireSequence(self: *Queue) Error!void {
```

Implements the file responsibility and validated ownership/serialization rules above; no hidden network or provider side effects.

### `append` — line 67

[Source declaration](../../../../../src/quic/events.zig#L67)

```zig
    fn append(self: *Queue, initial: Slot, bytes: []const u8) void {
```

Commit a preflighted payload copy and descriptor exactly once.

### `pushCrypto` — line 78

[Source declaration](../../../../../src/quic/events.zig#L78)

```zig
    pub fn pushCrypto(self: *Queue, level: c.EncryptionLevel, bytes: []const u8) Error!c.Transfer {
```

Implements the file responsibility and validated ownership/serialization rules above; no hidden network or provider side effects.

### `control` — line 88

[Source declaration](../../../../../src/quic/events.zig#L88)

```zig
    fn control(self: *Queue, slot: Slot, bytes: []const u8) Error!void {
```

Implements the file responsibility and validated ownership/serialization rules above; no hidden network or provider side effects.

### `pushSecret` — line 95

[Source declaration](../../../../../src/quic/events.zig#L95)

```zig
    pub fn pushSecret(self: *Queue, level: c.EncryptionLevel, direction: c.Direction, suite: c.CipherSuite, bytes: []const u8) Error!void {
```

Implements the file responsibility and validated ownership/serialization rules above; no hidden network or provider side effects.

### `pushParameters` — line 100

[Source declaration](../../../../../src/quic/events.zig#L100)

```zig
    pub fn pushParameters(self: *Queue, bytes: []const u8) Error!void {
```

Implements the file responsibility and validated ownership/serialization rules above; no hidden network or provider side effects.

### `pushComplete` — line 106

[Source declaration](../../../../../src/quic/events.zig#L106)

```zig
    pub fn pushComplete(self: *Queue, peer: c.PeerAuthentication) Error!void {
```

The owning Engine, not this storage layer, must check every readiness gate.

### `pushAlert` — line 109

[Source declaration](../../../../../src/quic/events.zig#L109)

```zig
    pub fn pushAlert(self: *Queue, alert: u8) Error!void {
```

Implements the file responsibility and validated ownership/serialization rules above; no hidden network or provider side effects.

### `event` — line 112

[Source declaration](../../../../../src/quic/events.zig#L112)

```zig
    fn event(self: *Queue) c.Event {
```

Implements the file responsibility and validated ownership/serialization rules above; no hidden network or provider side effects.

### `next` — line 123

[Source declaration](../../../../../src/quic/events.zig#L123)

```zig
    pub fn next(self: *Queue) Error!?c.Event {
```

Implements the file responsibility and validated ownership/serialization rules above; no hidden network or provider side effects.

### `validateHead` — line 129

[Source declaration](../../../../../src/quic/events.zig#L129)

```zig
    fn validateHead(self: *Queue, token: c.EventId) Error!void {
```

Implements the file responsibility and validated ownership/serialization rules above; no hidden network or provider side effects.

### `consume` — line 137

[Source declaration](../../../../../src/quic/events.zig#L137)

```zig
    pub fn consume(self: *Queue, token: c.EventId, consumer: c.Consumer) Error!void {
```

Calls the consumer synchronously while custody remains owned. Only success permits acknowledgement; a trusted consumer is responsible for doing the copy/derivation it reports. A failing callback must be retry-safe.

### `acknowledge` — line 145

[Source declaration](../../../../../src/quic/events.zig#L145)

```zig
    pub fn acknowledge(self: *Queue, token: c.EventId) Error!void {
```

Implements the file responsibility and validated ownership/serialization rules above; no hidden network or provider side effects.

### `erase` — line 156

[Source declaration](../../../../../src/quic/events.zig#L156)

```zig
    fn erase(self: *Queue) void {
```

Implements the file responsibility and validated ownership/serialization rules above; no hidden network or provider side effects.

### `cancel` — line 166

[Source declaration](../../../../../src/quic/events.zig#L166)

```zig
    pub fn cancel(self: *Queue) Error!void {
```

Invalidates all views immediately but keeps zeroed allocations until deinit.

### `deinit` — line 171

[Source declaration](../../../../../src/quic/events.zig#L171)

```zig
    pub fn deinit(self: *Queue) Error!void {
```

Implements the file responsibility and validated ownership/serialization rules above; no hidden network or provider side effects.
