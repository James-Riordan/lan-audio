//! Engineering contract (2026-09-26)
//! Manual Zig extern mirror of the internal C ABI.
//! File contract: docs/reference/files/src/backend.zig.md
//! Ownership and invariant: Use c_int/c_long/c_ulong for target C types and usize for size_t. Keep
//! opaque engine ownership in Engine. Nullability differs intentionally for creation/free versus
//! live operations. Do not infer target support from a successful declaration compile.
//! Next implementation obligation: Generate or verify the mirror against backend.h using a
//! compile/link smoke consumer; keep no independent protocol logic here. Expand symbols only
//! alongside the C implementation and wrapper tests.
//! Verification: tests/transport.zig

// Deliberately small C ABI mirror of backend.h. Zig 0.17 has no @cImport.
pub const tz_engine = opaque {};
pub extern fn tz_new(server: c_int, ca: ?[*:0]const u8, cert: ?[*:0]const u8, key: ?[*:0]const u8, peer: ?[*:0]const u8, ip: c_int, require_client: c_int, wall_time: i64) ?*tz_engine;
pub extern fn tz_new_with_alpn(server: c_int, ca: ?[*:0]const u8, cert: ?[*:0]const u8, key: ?[*:0]const u8, peer: ?[*:0]const u8, ip: c_int, require_client: c_int, wall_time: i64, protocol: [*]const u8, protocol_length: usize) ?*tz_engine;
pub extern fn tz_free(e: ?*tz_engine) void;
pub extern fn tz_handshake(e: *tz_engine) c_int;
pub extern fn tz_feed(e: *tz_engine, p: [*]const u8, n: usize, used: *usize) c_int;
pub extern fn tz_drain(e: *tz_engine, p: [*]u8, n: usize, used: *usize) c_int;
pub extern fn tz_read(e: *tz_engine, p: [*]u8, n: usize, used: *usize) c_int;
pub extern fn tz_write(e: *tz_engine, p: [*]const u8, n: usize) c_int;
pub extern fn tz_flush(e: *tz_engine) c_int;
pub extern fn tz_shutdown(e: *tz_engine) c_int;
pub extern fn tz_eof(e: *tz_engine) c_int;
pub extern fn tz_verify_error(e: *tz_engine) c_long;
pub extern fn tz_reason(e: *tz_engine) c_ulong;
pub extern fn tz_alert(e: *tz_engine) c_int;
pub extern fn tz_version() [*:0]const u8;
