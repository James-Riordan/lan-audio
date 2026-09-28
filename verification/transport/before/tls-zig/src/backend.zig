// Deliberately small C ABI mirror of backend.h. Zig 0.17 has no @cImport.
pub const tz_engine = opaque {};
pub extern fn tz_new(server: c_int, ca: ?[*:0]const u8, cert: ?[*:0]const u8, key: ?[*:0]const u8, peer: ?[*:0]const u8, ip: c_int, require_client: c_int, wall_time: i64) ?*tz_engine;
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
