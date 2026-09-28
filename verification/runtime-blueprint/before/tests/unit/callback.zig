//! Independent frame-order expectations, wrap boundaries and two-thread transfer.
const std = @import("std");
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
    var out: [4]f32 = undefined;
    try std.testing.expectEqual(4, queue.read(&out));
    try std.testing.expectEqualSlices(f32, &.{ 10, 20, 30, 40 }, &out);
    try std.testing.expectEqual(@as(u32, 2), queue.released.load(.monotonic));
    try std.testing.expectEqual(1, queue.write(&.{50}));
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
