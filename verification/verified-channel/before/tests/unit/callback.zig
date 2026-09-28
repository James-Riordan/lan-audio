//! Independent frame-order expectations, wrap boundaries and two-thread transfer.
const std = @import("std");

test "missing output and sticky playback failure preserve media custody" {
    const Bridge = core.CallbackBridge(4, 2);
    var bridge: Bridge = .{};
    try std.testing.expectEqual(1, bridge.playback.write(&.{ 0.25, -0.25 }));
    bridge.missingOutput(0);
    try std.testing.expect(!bridge.playback_failed.load(.acquire));
    bridge.missingOutput(3);
    var output: [4]f32 = @splat(1);
    bridge.renderOutput(&output);
    try std.testing.expect(bridge.playback_failed.load(.acquire));
    try std.testing.expectEqualSlices(f32, &@as([4]f32, @splat(0)), &output);
    try std.testing.expectEqual(@as(u32, 1), bridge.playback.consumerAvailable());
    try std.testing.expectEqual(@as(u64, 0), bridge.rendered_frames);
    try std.testing.expectEqual(@as(u64, 2), bridge.silent_frames);
    try std.testing.expectEqual(@as(u64, 3), bridge.missing_output_frames);
    try std.testing.expect(bridge.counters_exact.load(.acquire));
    bridge.missing_output_frames = std.math.maxInt(u64);
    bridge.missingOutput(1);
    try std.testing.expect(!bridge.counters_exact.load(.acquire));
    try std.testing.expectEqual(std.math.maxInt(u64), bridge.missing_output_frames);
}
const core = @import("lan_audio");

test "SPSC partial operations preserve stereo and output suffix" {
    var queue: core.FrameQueue(4, 2) = .{};
    try std.testing.expectEqual(4, queue.write(&.{ 1, -1, 2, -2, 3, -3, 4, -4, 5, -5 }));
    try std.testing.expectEqual(0, queue.write(&.{ 9, -9 }));
    var first: [6]f32 = undefined;
    try std.testing.expectEqual(3, queue.read(&first));
    try std.testing.expectEqualSlices(f32, &.{ 1, -1, 2, -2, 3, -3 }, &first);
    try std.testing.expectEqual(3, queue.write(&.{ 5, -5, 6, -6, 7, -7 }));
    var rest: [12]f32 = @splat(99);
    try std.testing.expectEqual(4, queue.read(&rest));
    try std.testing.expectEqualSlices(f32, &.{ 4, -4, 5, -5, 6, -6, 7, -7, 99, 99, 99, 99 }, &rest);
    try std.testing.expectEqual(0, queue.read(&rest));
}

test "SPSC u32 rollover preserves distance and slots" {
    var queue: core.FrameQueue(4, 1) = .{};
    // White-box setup occurs before either owner exists, never during concurrency.
    queue.published.store(std.math.maxInt(u32) - 1, .monotonic);
    queue.released.store(std.math.maxInt(u32) - 1, .monotonic);
    try std.testing.expectEqual(4, queue.write(&.{ 10, 20, 30, 40 }));
    try std.testing.expectEqual(@as(u32, 4), queue.consumerAvailable());
    var out: [4]f32 = undefined;
    try std.testing.expectEqual(4, queue.read(&out));
    try std.testing.expectEqualSlices(f32, &.{ 10, 20, 30, 40 }, &out);
    try std.testing.expectEqual(@as(u32, 2), queue.released.load(.monotonic));
    try std.testing.expectEqual(@as(u32, 0), queue.consumerAvailable());
    try std.testing.expectEqual(1, queue.write(&.{50}));
    try std.testing.expectEqual(@as(u32, 1), queue.consumerAvailable());
    try std.testing.expectEqual(1, queue.read(&out));
    try std.testing.expectEqual(@as(f32, 50), out[0]);
}

test "callback gaps silence full tail and capture drops newest complete frames" {
    var bridge: core.CallbackBridge(4, 2) = .{};
    try std.testing.expectEqual(2, bridge.playback.write(&.{ 1, -1, 2, -2 }));
    var out: [10]f32 = @splat(99);
    bridge.renderOutput(&out);
    try std.testing.expectEqualSlices(f32, &.{ 1, -1, 2, -2, 0, 0, 0, 0, 0, 0 }, &out);
    bridge.captureInput(&.{ 1, -1, 2, -2, 3, -3, 4, -4, 5, -5 });
    bridge.captureInput(&.{ 6, -6 });
    try std.testing.expectEqual(4, bridge.capture.read(&out));
    try std.testing.expectEqualSlices(f32, &.{ 1, -1, 2, -2, 3, -3, 4, -4 }, out[0..8]);
    try std.testing.expectEqual(@as(u64, 2), bridge.dropped_frames);
    try std.testing.expect(bridge.capture_overrun.load(.acquire));
    try std.testing.expect(bridge.capture_failed.load(.acquire));
    try std.testing.expectEqual(@as(u64, 3), bridge.silent_frames);
}

const Stress = struct {
    const total = 250_000;
    queue: core.FrameQueue(64, 2) = .{},
    cancel: std.atomic.Value(bool) = .init(false),
    failed: bool = false, // consumer owns; main reads after join

    fn produce(self: *@This()) void {
        var next: usize = 0;
        var block: [34]f32 = undefined;
        while (next < total and !self.cancel.load(.monotonic)) {
            const n: usize = @min(17, total - next);
            for (0..n) |i| {
                block[2 * i] = @floatFromInt(next + i);
                block[2 * i + 1] = -block[2 * i];
            }
            const wrote = self.queue.write(block[0 .. n * 2]);
            next += wrote;
            if (wrote == 0) std.Thread.yield() catch {};
        }
    }
    fn consume(self: *@This()) void {
        var next: usize = 0;
        var block: [46]f32 = undefined;
        while (next < total and !self.cancel.load(.monotonic)) {
            const n = self.queue.read(&block);
            for (0..n) |i| {
                const expected: f32 = @floatFromInt(next + i);
                if (block[2 * i] != expected or block[2 * i + 1] != -expected) {
                    self.failed = true;
                    self.cancel.store(true, .monotonic);
                    return;
                }
            }
            next += n;
            if (n == 0) std.Thread.yield() catch {};
        }
    }
};

test "SPSC simultaneous owners transfer 250000 exact ordered stereo frames" {
    var stress: Stress = .{};
    const producer = try std.Thread.spawn(.{}, Stress.produce, .{&stress});
    const consumer = std.Thread.spawn(.{}, Stress.consume, .{&stress}) catch |err| {
        stress.cancel.store(true, .monotonic);
        producer.join();
        return err;
    };
    producer.join();
    consumer.join();
    try std.testing.expect(!stress.failed);
}

test "callback publishes missing input and nonfinite faults without false contiguous capture" {
    const Bridge = core.CallbackBridge(4, 2);
    var missing: Bridge = .{};
    missing.missingInput(0);
    try std.testing.expect(!missing.capture_failed.load(.acquire));
    missing.captureInput(&.{ 1, -1 });
    missing.missingInput(3);
    missing.captureInput(&.{ 2, -2 });
    try std.testing.expectEqual(@as(u32, 1), missing.capture.consumerAvailable());
    try std.testing.expectEqual(@as(u64, 4), missing.dropped_frames);
    try std.testing.expectEqual(@as(u32, 2), missing.capture_faults.load(.acquire));
    try std.testing.expect(missing.capture_failed.load(.acquire));
    for ([_]u32{ 0x7f800000, 0xff800000, 0x7fc12345 }) |word| {
        var invalid: Bridge = .{};
        invalid.captureInput(&.{ 1, @bitCast(word), 2, -2 });
        try std.testing.expectEqual(@as(u32, 0), invalid.capture.consumerAvailable());
        try std.testing.expectEqual(@as(u64, 2), invalid.dropped_frames);
        try std.testing.expectEqual(@as(u32, 4), invalid.capture_faults.load(.acquire));
    }
}

test "callback counter overflow is visibly inexact and finite words are unmodified" {
    const Bridge = core.CallbackBridge(4, 2);
    var finite: Bridge = .{};
    const words = [_]u32{ 0, 0x80000000, 1, 0x807fffff, 0x7f7fffff, 0xff7fffff };
    var samples: [6]f32 = undefined;
    for (words, &samples) |word, *value| value.* = @bitCast(word);
    finite.captureInput(&samples);
    var copied: [6]f32 = undefined;
    try std.testing.expectEqual(@as(usize, 3), finite.capture.read(&copied));
    for (words, copied) |word, value| try std.testing.expectEqual(word, @as(u32, @bitCast(value)));
    try std.testing.expect(!finite.capture_failed.load(.acquire));
    var exhausted: Bridge = .{};
    exhausted.captured_frames = std.math.maxInt(u64);
    exhausted.captureInput(&.{ 1, 2 });
    try std.testing.expect(!exhausted.counters_exact.load(.acquire));
    try std.testing.expect(exhausted.capture_failed.load(.acquire));
    try std.testing.expectEqual(@as(u32, 8), exhausted.capture_faults.load(.acquire));
    var output: Bridge = .{};
    output.silent_frames = std.math.maxInt(u64);
    var silence: [2]f32 = undefined;
    output.renderOutput(&silence);
    try std.testing.expect(!output.counters_exact.load(.acquire));
    try std.testing.expectEqualSlices(f32, &.{ 0, 0 }, &silence);
}
