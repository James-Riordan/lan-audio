# `tests/quic/backend_abi.zig`

Source: [tests/quic/backend_abi.zig](../../../../../tests/quic/backend_abi.zig)  
Source SHA-256: `992c0e282f11b051a58c3acc2ecbd5a0e72eef039f24247b5820de090923185a`  
Snapshot bytes: 3191. Review date: 2026-09-26.

## Responsibility

Production Zig extern ABI layout and native symbol tests.

## Ownership, invariants and failure behavior

Imports the actual independently authored production quic_native_abi declarations. Compares C-reported sizes, alignments and every field offset, calls real tlsq_query and verifies invalid-version output atomicity. A C function invokes all Zig callbacks to check calling conventions and by-value byte pairs. Current native evidence is Windows x86_64 LLP64; LP64 remains unavailable pending native qualification.

## Verification

Native results are scoped to Windows x86_64; see current status, canonical completion receipts and retained qualification runs. This file alone does not establish a completed platform or production QUIC stack.

### `tlsq_abi_value` — line 9

[Source declaration](../../../../../tests/quic/backend_abi.zig#L9)

```zig
extern fn tlsq_abi_value(u32, u32) callconv(.c) u64;
```

Preserves the explicit input validation, serialization, custody and cleanup rules above. Native tests observe its results and failure effects.

### `tlsq_abi_invoke` — line 10

[Source declaration](../../../../../tests/quic/backend_abi.zig#L10)

```zig
extern fn tlsq_abi_invoke(*const Callbacks) callconv(.c) i32;
```

Preserves the explicit input validation, serialization, custody and cleanup rules above. Native tests observe its results and failure effects.

### `tlsq_query` — line 11

[Source declaration](../../../../../tests/quic/backend_abi.zig#L11)

```zig
extern fn tlsq_query(u32, *Capabilities) callconv(.c) u32;
```

Preserves the explicit input validation, serialization, custody and cleanup rules above. Native tests observe its results and failure effects.

### `context` — line 32

[Source declaration](../../../../../tests/quic/backend_abi.zig#L32)

```zig
fn context(arg: ?*anyopaque) *Context {
```

Preserves the explicit input validation, serialization, custody and cleanup rules above. Native tests observe its results and failure effects.

### `send` — line 35

[Source declaration](../../../../../tests/quic/backend_abi.zig#L35)

```zig
fn send(arg: ?*anyopaque, level: u32, bytes: Bytes, accepted: *usize) callconv(.c) i32 {
```

Preserves the explicit input validation, serialization, custody and cleanup rules above. Native tests observe its results and failure effects.

### `receive` — line 41

[Source declaration](../../../../../tests/quic/backend_abi.zig#L41)

```zig
fn receive(arg: ?*anyopaque, level: u32, maximum: usize, out: *Bytes) callconv(.c) i32 {
```

Preserves the explicit input validation, serialization, custody and cleanup rules above. Native tests observe its results and failure effects.

### `release` — line 48

[Source declaration](../../../../../tests/quic/backend_abi.zig#L48)

```zig
fn release(arg: ?*anyopaque, level: u32, bytes: Bytes) callconv(.c) i32 {
```

Preserves the explicit input validation, serialization, custody and cleanup rules above. Native tests observe its results and failure effects.

### `secret` — line 53

[Source declaration](../../../../../tests/quic/backend_abi.zig#L53)

```zig
fn secret(arg: ?*anyopaque, level: u32, direction: u32, suite: u32, bytes: Bytes) callconv(.c) i32 {
```

Preserves the explicit input validation, serialization, custody and cleanup rules above. Native tests observe its results and failure effects.

### `parameters` — line 58

[Source declaration](../../../../../tests/quic/backend_abi.zig#L58)

```zig
fn parameters(arg: ?*anyopaque, bytes: Bytes) callconv(.c) i32 {
```

Preserves the explicit input validation, serialization, custody and cleanup rules above. Native tests observe its results and failure effects.

### `alert` — line 63

[Source declaration](../../../../../tests/quic/backend_abi.zig#L63)

```zig
fn alert(arg: ?*anyopaque, code: u32) callconv(.c) i32 {
```

Preserves the explicit input validation, serialization, custody and cleanup rules above. Native tests observe its results and failure effects.
