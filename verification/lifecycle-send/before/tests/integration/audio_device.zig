//! Actual asynchronous miniaudio callback lifecycle on explicit silent/null backend.
const std = @import("std");
const audio = @import("audio_host");

test "null duplex callbacks transfer frames and permit quiescent reconstruction" {
    var host: audio.AudioDevice = .{};
    defer host.deinit();
    for (0..8) |_| {
        try host.init(.null_duplex);
        try std.testing.expectError(error.InvalidState, host.init(.null_duplex));
        try std.testing.expectEqual(@as(u64, 0), host.bridge.rendered_frames);
        var silence: [480]f32 = @splat(0);
        try std.testing.expectEqual(240, host.bridge.playback.write(&silence));
        try host.start();
        try std.testing.expectError(error.InvalidState, host.start());
        var polls: usize = 0;
        while (host.callback_count.load(.monotonic) < 4 and polls < 500) : (polls += 1)
            try std.Io.sleep(std.testing.io, .fromMilliseconds(2), .awake);
        try std.testing.expect(host.callback_count.load(.monotonic) >= 4);
        try std.testing.expect(host.bridge.capture.read(&silence) > 0);
        try std.testing.expectEqualSlices(f32, &@as([480]f32, @splat(0)), &silence);
        try host.stop();
        host.deinit(); // authoritative callback reclamation boundary
        const callbacks = host.callback_count.load(.monotonic);
        try std.Io.sleep(std.testing.io, .fromMilliseconds(10), .awake);
        try std.testing.expectEqual(callbacks, host.callback_count.load(.monotonic));
        try std.testing.expectEqual(@as(u64, 0), host.invalid_buffers);
        try std.testing.expectEqual(@as(u64, 240), host.bridge.rendered_frames);
        try std.testing.expect(host.bridge.silent_frames > 0);
        try std.testing.expect(host.bridge.captured_frames > 0);
    }
    try std.testing.expectError(error.InvalidState, host.start());
    try std.testing.expectError(error.InvalidState, host.stop());
}
