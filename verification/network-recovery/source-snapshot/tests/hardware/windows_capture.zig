//! Explicit physical WASAPI loopback qualification: no microphone or recording file.
//! A silent playback stream keeps the engine active. Captured samples are discarded.
const std = @import("std");
const audio = @import("audio_host");
const wire = @import("lan_audio").wire;

test "Windows system-output capture supplies finite encodable stereo frames" {
    var host: audio.AudioDevice = .{};
    defer host.deinit();
    var silent_source: audio.AudioDevice = .{};
    defer silent_source.deinit();
    try silent_source.init(.windows_playback);
    try silent_source.start(); // an empty playback queue produces only zeros
    host.init(.windows_loopback) catch |err| {
        std.debug.print("WASAPI loopback init failed: {s}, native={d}\n", .{ @errorName(err), host.last_result });
        return err;
    };
    try host.start();
    var samples: [wire.samples]f32 = undefined;
    var encoded: [wire.max_record]u8 = undefined;
    var collected: usize = 0;
    var blocks: u64 = 0;
    for (0..120) |_| {
        // Drain the available prefix rather than assuming 2 ms sleeps are accurate.
        // Bound each turn to 18 blocks even if the callback keeps writing.
        for (0..18) |_| {
            const got = host.bridge.capture.read(samples[collected..]);
            collected += got * 2;
            if (host.bridge.capture_overrun.load(.acquire)) return error.CaptureOverrun;
            if (collected == samples.len) {
                _ = try wire.encodeAudio(&encoded, @splat(1), blocks, &samples);
                blocks += 1;
                collected = 0;
            }
            if (got == 0) break;
        }
        try std.Io.sleep(std.testing.io, .fromMilliseconds(2), .awake);
    }
    try host.stop();
    host.deinit();
    if (host.bridge.capture_overrun.load(.acquire)) return error.CaptureOverrun;
    try std.testing.expectEqual(@as(u64, 0), host.invalid_buffers);
    if (blocks == 0) return error.NoCaptureFrames;
    std.debug.print("WASAPI loopback: blocks={d} frames={d} callbacks={d} drops={d}; samples discarded\n", .{ blocks, blocks * 240, host.callback_count.load(.monotonic), host.bridge.dropped_frames });
}
