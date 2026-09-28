# `src/backend.zig`

Source: [src/backend.zig](../../../../src/backend.zig)  
Source SHA-256: `9a7e22086f439b6381c0810f6259cd923c359b7e8c920222a1f974c0e7e91c9c`  
Snapshot bytes: 2072. Review date: 2026-09-26.

## Responsibility

Manual Zig extern mirror of the internal C ABI.

## Contract, ownership and failure behavior

Use c_int/c_long/c_ulong for target C types and usize for size_t. Keep opaque engine ownership in Engine. Nullability differs intentionally for creation/free versus live operations. Do not infer target support from a successful declaration compile.

## Next implementation work

Generate or verify the mirror against backend.h using a compile/link smoke consumer; keep no independent protocol logic here. Expand symbols only alongside the C implementation and wrapper tests.

## Verification obligations

- [tests/transport.zig](../../../../tests/transport.zig): preserve existing regression assertions and add any changed-boundary cases.

## Declaration-by-declaration work map

Each entry points to the exact current source. Adjacent source documentation is retained below. Direct error names and assigned self fields are mechanically extracted navigation cues; they exclude transitive errors, pointer writes and full branch reasoning. Use the module contract above for obligations.

### `tz_new` — line 14

[Source declaration](../../../../src/backend.zig#L14)

```zig
pub extern fn tz_new(server: c_int, ca: ?[*:0]const u8, cert: ?[*:0]const u8, key: ?[*:0]const u8, peer: ?[*:0]const u8, ip: c_int, require_client: c_int, wall_time: i64) ?*tz_engine;
```

Review `tz_new` as part of this file’s responsibility: Manual Zig extern mirror of the internal C ABI. Preserve the stated ownership/failure contract when extending this entry point.

### `tz_new_with_alpn` — line 15

[Source declaration](../../../../src/backend.zig#L15)

```zig
pub extern fn tz_new_with_alpn(server: c_int, ca: ?[*:0]const u8, cert: ?[*:0]const u8, key: ?[*:0]const u8, peer: ?[*:0]const u8, ip: c_int, require_client: c_int, wall_time: i64, protocol: [*]const u8, protocol_length: usize) ?*tz_engine;
```

Review `tz_new_with_alpn` as part of this file’s responsibility: Manual Zig extern mirror of the internal C ABI. Preserve the stated ownership/failure contract when extending this entry point.

### `tz_free` — line 16

[Source declaration](../../../../src/backend.zig#L16)

```zig
pub extern fn tz_free(e: ?*tz_engine) void;
```

Review `tz_free` as part of this file’s responsibility: Manual Zig extern mirror of the internal C ABI. Preserve the stated ownership/failure contract when extending this entry point.

### `tz_handshake` — line 17

[Source declaration](../../../../src/backend.zig#L17)

```zig
pub extern fn tz_handshake(e: *tz_engine) c_int;
```

Review `tz_handshake` as part of this file’s responsibility: Manual Zig extern mirror of the internal C ABI. Preserve the stated ownership/failure contract when extending this entry point.

### `tz_feed` — line 18

[Source declaration](../../../../src/backend.zig#L18)

```zig
pub extern fn tz_feed(e: *tz_engine, p: [*]const u8, n: usize, used: *usize) c_int;
```

Review `tz_feed` as part of this file’s responsibility: Manual Zig extern mirror of the internal C ABI. Preserve the stated ownership/failure contract when extending this entry point.

### `tz_drain` — line 19

[Source declaration](../../../../src/backend.zig#L19)

```zig
pub extern fn tz_drain(e: *tz_engine, p: [*]u8, n: usize, used: *usize) c_int;
```

Review `tz_drain` as part of this file’s responsibility: Manual Zig extern mirror of the internal C ABI. Preserve the stated ownership/failure contract when extending this entry point.

### `tz_read` — line 20

[Source declaration](../../../../src/backend.zig#L20)

```zig
pub extern fn tz_read(e: *tz_engine, p: [*]u8, n: usize, used: *usize) c_int;
```

Review `tz_read` as part of this file’s responsibility: Manual Zig extern mirror of the internal C ABI. Preserve the stated ownership/failure contract when extending this entry point.

### `tz_write` — line 21

[Source declaration](../../../../src/backend.zig#L21)

```zig
pub extern fn tz_write(e: *tz_engine, p: [*]const u8, n: usize) c_int;
```

Review `tz_write` as part of this file’s responsibility: Manual Zig extern mirror of the internal C ABI. Preserve the stated ownership/failure contract when extending this entry point.

### `tz_flush` — line 22

[Source declaration](../../../../src/backend.zig#L22)

```zig
pub extern fn tz_flush(e: *tz_engine) c_int;
```

Review `tz_flush` as part of this file’s responsibility: Manual Zig extern mirror of the internal C ABI. Preserve the stated ownership/failure contract when extending this entry point.

### `tz_shutdown` — line 23

[Source declaration](../../../../src/backend.zig#L23)

```zig
pub extern fn tz_shutdown(e: *tz_engine) c_int;
```

Review `tz_shutdown` as part of this file’s responsibility: Manual Zig extern mirror of the internal C ABI. Preserve the stated ownership/failure contract when extending this entry point.

### `tz_eof` — line 24

[Source declaration](../../../../src/backend.zig#L24)

```zig
pub extern fn tz_eof(e: *tz_engine) c_int;
```

Review `tz_eof` as part of this file’s responsibility: Manual Zig extern mirror of the internal C ABI. Preserve the stated ownership/failure contract when extending this entry point.

### `tz_verify_error` — line 25

[Source declaration](../../../../src/backend.zig#L25)

```zig
pub extern fn tz_verify_error(e: *tz_engine) c_long;
```

Review `tz_verify_error` as part of this file’s responsibility: Manual Zig extern mirror of the internal C ABI. Preserve the stated ownership/failure contract when extending this entry point.

### `tz_reason` — line 26

[Source declaration](../../../../src/backend.zig#L26)

```zig
pub extern fn tz_reason(e: *tz_engine) c_ulong;
```

Review `tz_reason` as part of this file’s responsibility: Manual Zig extern mirror of the internal C ABI. Preserve the stated ownership/failure contract when extending this entry point.

### `tz_alert` — line 27

[Source declaration](../../../../src/backend.zig#L27)

```zig
pub extern fn tz_alert(e: *tz_engine) c_int;
```

Review `tz_alert` as part of this file’s responsibility: Manual Zig extern mirror of the internal C ABI. Preserve the stated ownership/failure contract when extending this entry point.

### `tz_version` — line 29

[Source declaration](../../../../src/backend.zig#L29)

```zig
pub extern fn tz_version() [*:0]const u8;
```

Review `tz_version` as part of this file’s responsibility: Manual Zig extern mirror of the internal C ABI. Preserve the stated ownership/failure contract when extending this entry point.

## Verified peer leaf export increment

Mirrors the actual new C symbol with nullable opaque handle/output pointers and usize capacity; c_int return. Actual wrapper, independent extern boundary calls and Python ctypes calls exercise linkage and arguments in both native build modes.

See the [identity guide](../../../guides/peer-identity.md) for the application boundary and current evidence.

### `tz_verified_peer_leaf_sha256` — line 28

[Source declaration](../../../../src/backend.zig#L28)

```zig
pub extern fn tz_verified_peer_leaf_sha256(e: ?*tz_engine, out: ?[*]u8, capacity: usize) c_int;
```

Mirrors the actual new C symbol with nullable opaque handle/output pointers and usize capacity; c_int return. Actual wrapper, independent extern boundary calls and Python ctypes calls exercise linkage and arguments in both native build modes.
