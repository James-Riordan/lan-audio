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

test "silent native fence preserves device storage and grants a stable final snapshot" {
    var host: audio.AudioDevice = .{};
    defer host.deinit();
    try std.testing.expectError(error.NotFenced, host.finalSnapshot());
    try host.init(.null_playback);
    const silence: [480]f32 = @splat(0);
    try std.testing.expectEqual(@as(usize, 240), host.bridge.playback.write(&silence));
    try host.start();
    try std.testing.expectError(error.NotFenced, host.finalSnapshot());
    var polls: usize = 0;
    while (host.callback_count.load(.monotonic) < 3 and polls < 500) : (polls += 1)
        try std.Io.sleep(std.testing.io, .fromMilliseconds(2), .awake);
    try std.testing.expect(host.callback_count.load(.monotonic) >= 3);
    try host.fence();
    const before = try host.finalSnapshot();
    try std.testing.expectEqual(@as(u64, 240), before.rendered_frames);
    try std.testing.expect(before.counters_exact);
    try std.testing.expectEqual(.ready, host.state);
    try host.fence(); // Repeated control intent preserves the same native object.
    try std.Io.sleep(std.testing.io, .fromMilliseconds(10), .awake);
    try std.testing.expectEqualDeep(before, try host.finalSnapshot());
    try host.start(); // Native pause/resume, not a queue reset or new generation.
    try std.testing.expectError(error.NotFenced, host.finalSnapshot());
    try host.fence();
    host.deinit();
    _ = try host.finalSnapshot();
}

test "native null device callback publishes missing input through the installed callback" {
    var host: audio.AudioDevice = .{};
    defer host.deinit();
    try host.init(.null_duplex);
    // Never started: no native callback can race this controlled ABI invocation.
    // Use the actual installed function pointer, without a production test hook.
    host.device.onData.?(&host.device, null, null, 1);
    try std.testing.expect(host.bridge.capture_failed.load(.acquire));
    try host.fence();
    const observed = try host.finalSnapshot();
    try std.testing.expectEqual(@as(u64, 1), observed.invalid_buffers);
    try std.testing.expectEqual(@as(u64, 1), observed.dropped_frames);
    try std.testing.expectEqual(@as(u32, 2), observed.capture_faults);
}
