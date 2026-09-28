//! C-produced facts versus the public translated module. No devices or callbacks
//! from an OS are involved. The C callback probe invokes a synthetic, synchronous
//! sentinel to exercise call convention and borrowed sample arguments only.
//! Selector order is a tiny test protocol, not a public library API. See
//! docs/verification/abi.md for coverage, fault controls and native target limits.
const std = @import("std");
const c = @import("miniaudio").c;

extern fn mz_abi_size(type_id: c_uint) usize;
extern fn mz_abi_align(type_id: c_uint) usize;
extern fn mz_abi_offset(field_id: c_uint) usize;
extern fn mz_abi_enum(value_id: c_uint) c_int;
extern fn mz_abi_call_callback(callback: c.ma_device_data_proc) c_int;

test "C and Zig object sizes and alignments agree" {
    const objects = .{
        .{ "ma_context", c.ma_context },
        .{ "ma_device", c.ma_device },
        .{ "ma_device_config", c.ma_device_config },
        .{ "ma_device_id", c.ma_device_id },
        .{ "ma_device_info", c.ma_device_info },
    };
    var differences: usize = 0;
    inline for (objects, 0..) |item, id| {
        const native_size = mz_abi_size(@intCast(id));
        const native_align = mz_abi_align(@intCast(id));
        if (native_size != @sizeOf(item[1])) {
            std.debug.print("ABI size {s}: Zig={d} C={d}\n", .{ item[0], @sizeOf(item[1]), native_size });
            differences += 1;
        }
        if (native_align != @alignOf(item[1])) {
            std.debug.print("ABI alignment {s}: Zig={d} C={d}\n", .{ item[0], @alignOf(item[1]), native_align });
            differences += 1;
        }
    }
    try std.testing.expectEqual(@as(usize, 0), differences);
}

test "C and Zig callback userdata and endpoint field offsets agree" {
    const fields = .{
        .{ c.ma_device_config, "dataCallback" },
        .{ c.ma_device_config, "notificationCallback" },
        .{ c.ma_device_config, "pUserData" },
        .{ c.ma_device_config, "playback" },
        .{ c.ma_device_config, "capture" },
        .{ c.ma_device, "onData" },
        .{ c.ma_device, "pUserData" },
        .{ c.ma_device, "playback" },
        .{ c.ma_device, "capture" },
        .{ c.ma_device_info, "name" },
        .{ c.ma_device_info, "isDefault" },
        .{ c.ma_device_info, "nativeDataFormats" },
    };
    var differences: usize = 0;
    inline for (fields, 0..) |item, id| {
        const translated = @offsetOf(item[0], item[1]);
        const native = mz_abi_offset(@intCast(id));
        if (native != translated) {
            std.debug.print("ABI offset #{d} {s}: Zig={d} C={d}\n", .{ id, item[1], translated, native });
            differences += 1;
        }
    }
    try std.testing.expectEqual(@as(usize, 0), differences);
}

test "C and Zig adopted result and enum values agree" {
    const values = [_]c_int{
        c.MA_SUCCESS,              c.MA_INVALID_ARGS,        c.ma_format_f32,
        c.ma_device_type_playback, c.ma_device_type_capture, c.ma_device_type_duplex,
        c.ma_device_type_loopback, c.ma_backend_null,
    };
    for (values, 0..) |value, id| {
        try std.testing.expectEqual(value, mz_abi_enum(@intCast(id)));
    }
}

fn sentinel(device: [*c]c.ma_device, output: ?*anyopaque, input: ?*const anyopaque, frames: c.ma_uint32) callconv(.c) void {
    // This probe intentionally supplies no real device. Do not generalize that
    // synthetic convention to a production callback's device/userdata contract.
    if (device != null or output == null or input == null or frames != 3) return;
    const in: [*]const f32 = @ptrCast(@alignCast(input.?));
    const out: [*]f32 = @ptrCast(@alignCast(output.?));
    for (0..6) |index| out[index] = in[index] + 10;
}

test "C invokes the translated callback type with intact arguments and guards" {
    try std.testing.expectEqual(@as(c_int, 0), mz_abi_call_callback(sentinel));
}

test "probe rejects invalid selectors and null callback" {
    const absent: c_uint = std.math.maxInt(c_uint);
    try std.testing.expectEqual(std.math.maxInt(usize), mz_abi_size(absent));
    try std.testing.expectEqual(std.math.maxInt(usize), mz_abi_align(absent));
    try std.testing.expectEqual(std.math.maxInt(usize), mz_abi_offset(absent));
    try std.testing.expectEqual(@as(c_int, 2147483647), mz_abi_enum(absent));
    try std.testing.expectEqual(@as(c_int, -1), mz_abi_call_callback(null));
}
