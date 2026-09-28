//! A real package import plus native calls, independent of the library test root.
//! Checks PCM units and C-returned configuration through the exported module.
//! No context/device initialization, physical audio, network or fixture keys.
const std = @import("std");
const c = @import("miniaudio").c;

test "external package receives the linked native PCM and configuration API" {
    try std.testing.expectEqual(@as(c_uint, 8), c.ma_get_bytes_per_frame(c.ma_format_f32, 2));
    const config = c.ma_device_config_init(c.ma_device_type_playback);
    try std.testing.expectEqual(@as(c.ma_device_type, c.ma_device_type_playback), config.deviceType);
    try std.testing.expectEqual(@as(c_uint, 0), config.sampleRate);
    try std.testing.expect(config.dataCallback == null);
}
