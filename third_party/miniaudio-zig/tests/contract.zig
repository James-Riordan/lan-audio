//! Deterministic adoption tests: pinned ABI, frame units and a silent, explicitly
//! selected null backend. No microphone, physical playback, default device or socket.
const std = @import("std");
const c = @import("miniaudio").c;

test "pinned upstream version and interleaved PCM units" {
    try std.testing.expectEqual(@as(c_uint, 0), c.MA_VERSION_MAJOR);
    try std.testing.expectEqual(@as(c_uint, 11), c.MA_VERSION_MINOR);
    try std.testing.expectEqual(@as(c_uint, 25), c.MA_VERSION_REVISION);
    try std.testing.expectEqual(@as(c_uint, 4), c.ma_get_bytes_per_sample(c.ma_format_f32));
    try std.testing.expectEqual(@as(c_uint, 8), c.ma_get_bytes_per_frame(c.ma_format_f32, 2));
}

test "configuration defaults are obtained from upstream" {
    const config = c.ma_device_config_init(c.ma_device_type_playback);
    try std.testing.expectEqual(@as(c.ma_device_type, c.ma_device_type_playback), config.deviceType);
    try std.testing.expectEqual(@as(c_uint, 0), config.sampleRate);
}

test "explicit null context and device retain stable storage until teardown" {
    var context: c.ma_context = undefined;
    const backends = [_]c.ma_backend{c.ma_backend_null};
    try std.testing.expectEqual(c.MA_SUCCESS, c.ma_context_init(&backends, 1, null, &context));
    defer _ = c.ma_context_uninit(&context);
    var config = c.ma_device_config_init(c.ma_device_type_playback);
    config.playback.format = c.ma_format_f32;
    config.playback.channels = 2;
    config.sampleRate = 48000;
    var device: c.ma_device = undefined;
    try std.testing.expectEqual(c.MA_SUCCESS, c.ma_device_init(&context, &config, &device));
    defer c.ma_device_uninit(&device);
    try std.testing.expectEqual(@as(c_uint, 48000), device.sampleRate);
    try std.testing.expectEqual(@as(c_uint, 2), device.playback.channels);
}
