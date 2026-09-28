const std = @import("std");
const t = std.testing;
const native = @import("quic_native_abi");
const Bytes = native.Bytes;
const Capabilities = native.Capabilities;
const Config = native.Config;
const Callbacks = native.Callbacks;
const Result = native.Result;
extern fn tlsq_abi_value(u32, u32) callconv(.c) u64;
extern fn tlsq_abi_invoke(*const Callbacks) callconv(.c) i32;
extern fn tlsq_query(u32, *Capabilities) callconv(.c) u32;

const native_types = .{ Bytes, Capabilities, Config, Callbacks, Result };
test "native C sizes alignments and offsets agree with independent Zig ABI declarations" {
    inline for (native_types, 0..) |Z, kind| {
        try t.expectEqual(@as(u64, @sizeOf(Z)), tlsq_abi_value(kind, 0));
        try t.expectEqual(@as(u64, @alignOf(Z)), tlsq_abi_value(kind, 1));
        inline for (comptime std.meta.fieldNames(Z), 2..) |field, index| {
            try t.expectEqual(@as(u64, @offsetOf(Z, field)), tlsq_abi_value(kind, index));
        }
    }
    var caps: Capabilities = undefined;
    try t.expectEqual(@as(u32, 0), tlsq_query(1, &caps));
    try t.expectEqual(@as(u32, 1), caps.abi_version);
    try t.expectEqual(@as(u32, 1), caps.runtime_available);
    try t.expectEqual(@as(u32, 1), caps.qualified_target);
    const before = caps;
    try t.expectEqual(@as(u32, 1), tlsq_query(999, &caps));
    try t.expectEqualDeep(before, caps);
}
const Context = struct { calls: usize = 0, data: [3]u8 = .{ 1, 2, 3 } };
fn context(arg: ?*anyopaque) *Context {
    return @ptrCast(@alignCast(arg.?));
}
fn send(arg: ?*anyopaque, level: u32, bytes: Bytes, accepted: *usize) callconv(.c) i32 {
    if (level != 0 or bytes.length != 3 or bytes.data.?[1] != 2) return 0;
    context(arg).calls += 1;
    accepted.* = 2;
    return 1;
}
fn receive(arg: ?*anyopaque, level: u32, maximum: usize, out: *Bytes) callconv(.c) i32 {
    if (level != 1 or maximum != 3) return 0;
    const ctx = context(arg);
    ctx.calls += 1;
    out.* = .{ .data = &ctx.data, .length = 3 };
    return 1;
}
fn release(arg: ?*anyopaque, level: u32, bytes: Bytes) callconv(.c) i32 {
    if (level != 1 or bytes.length != 3 or bytes.data.? != &context(arg).data) return 0;
    context(arg).calls += 1;
    return 1;
}
fn secret(arg: ?*anyopaque, level: u32, direction: u32, suite: u32, bytes: Bytes) callconv(.c) i32 {
    if (level != 2 or direction != 1 or suite != 0x1301 or bytes.length != 32 or bytes.data.?[0] != 7) return 0;
    context(arg).calls += 1;
    return 1;
}
fn parameters(arg: ?*anyopaque, bytes: Bytes) callconv(.c) i32 {
    if (bytes.length != 3 or bytes.data.?[2] != 3) return 0;
    context(arg).calls += 1;
    return 1;
}
fn alert(arg: ?*anyopaque, code: u32) callconv(.c) i32 {
    if (code != 42) return 0;
    context(arg).calls += 1;
    return 1;
}
test "native C invokes every Zig callback with the declared widths and calling convention" {
    var ctx: Context = .{};
    const cb: Callbacks = .{ .abi_version = 1, .context = &ctx, .send = send, .receive = receive, .release = release, .secret = secret, .parameters = parameters, .alert = alert };
    try t.expectEqual(@as(i32, 1), tlsq_abi_invoke(&cb));
    try t.expectEqual(@as(usize, 6), ctx.calls);
}
