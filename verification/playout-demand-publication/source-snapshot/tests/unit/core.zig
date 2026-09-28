//! Adversarial examples and independent payload expectations for the pure kernel.
//! Formal transition exploration lives separately in spec/; neither proves host I/O.
const std = @import("std");
const core = @import("lan_audio");
const expect = std.testing.expect;
test {
    _ = @import("wire.zig");
    _ = @import("callback.zig");
    _ = @import("protocol/v2.zig");
    _ = @import("protocol/negotiation.zig");
    _ = @import("media/assembler.zig");
    _ = @import("runtime/pending_block.zig");
}

test "authentication and callback drain gate restart" {
    var session: core.Session = .{};
    const first = try session.begin();
    try std.testing.expectError(error.Unauthenticated, session.start());
    try session.authenticate(first);
    try session.start();
    try session.enterCallback(first);
    try session.requestStop();
    try std.testing.expectError(error.InvalidState, session.enterCallback(first));
    try std.testing.expectError(error.CallbackActive, session.finishStop());
    try session.leaveCallback(first);
    try session.finishStop();
    const second = try session.begin();
    try expect(second > first);
    try std.testing.expectError(error.StaleEpoch, session.authenticate(first));
    try expect(!session.authenticated);
    try session.authenticate(second);
    try session.start();
    try session.enterCallback(second);
    try std.testing.expectError(error.StaleEpoch, session.leaveCallback(first));
    try expect(session.callback_active);
    try session.leaveCallback(second);
}

test "reorder duplicate loss and late arrival preserve media positions" {
    var window = core.Window(3, 2).init(7);
    try window.insert(7, 2, &.{ 0.2, -0.2 });
    try window.insert(7, 0, &.{ 0.1, -0.1 });
    try std.testing.expectError(error.Duplicate, window.insert(7, 0, &.{ 0.9, 0.9 }));
    try std.testing.expectError(error.TooFar, window.insert(7, 3, &.{ 0.9, 0.9 }));
    var output: [2]f32 = undefined;
    try expect(try window.tick(&output) == .media);
    try std.testing.expectEqualSlices(f32, &.{ 0.1, -0.1 }, &output);
    try expect(try window.tick(&output) == .silence);
    try std.testing.expectEqualSlices(f32, &.{ 0, 0 }, &output);
    try std.testing.expectError(error.Late, window.insert(7, 1, &.{ 1, 1 }));
    try expect(try window.tick(&output) == .media);
    try std.testing.expectEqualSlices(f32, &.{ 0.2, -0.2 }, &output);
}

test "malformed and stale input cannot publish a block" {
    var window = core.Window(2, 2).init(9);
    try std.testing.expectError(error.StaleEpoch, window.insert(8, 0, &.{ 1, 1 }));
    try std.testing.expectError(error.InvalidBlock, window.insert(9, 0, &.{1}));
    try std.testing.expectError(error.InvalidBlock, window.insert(9, 0, &.{ std.math.nan(f32), 0 }));
    try std.testing.expectError(error.InvalidBlock, window.insert(9, 0, &.{ std.math.inf(f32), 0 }));
    var output: [2]f32 = .{ 1, 1 };
    try std.testing.expectError(error.InvalidBlock, window.tick(output[0..1]));
    try expect(window.next == 0);
    try expect(try window.tick(&output) == .silence);
}

test "ring reuse matches expected ordered blocks across many revolutions" {
    var window = core.Window(5, 2).init(1);
    var output: [2]f32 = undefined;
    for (0..100) |cycle| {
        const base: u64 = @intCast(cycle * 5);
        for ([_]u64{ 4, 2, 0 }) |offset| {
            const value: f32 = @floatFromInt(base + offset);
            try window.insert(1, base + offset, &.{ value, -value });
        }
        for (0..5) |offset| {
            const result = try window.tick(&output);
            const value: f32 = if (offset % 2 == 0) @floatFromInt(base + offset) else 0;
            const expected: @TypeOf(result) = if (offset % 2 == 0) .media else .silence;
            try expect(result == expected);
            try std.testing.expectEqualSlices(f32, &.{ value, -value }, &output);
        }
    }
}

test "finite counters fail before wrap and leave output untouched" {
    var session: core.Session = .{ .epoch = std.math.maxInt(u64) };
    try std.testing.expectError(error.EpochExhausted, session.begin());
    try expect(session.phase == .idle);
    var window = core.Window(2, 2).init(1);
    window.next = std.math.maxInt(u64) - 1;
    try window.insert(1, window.next, &.{ 0.5, -0.5 });
    try std.testing.expectError(error.SequenceExhausted, window.insert(1, std.math.maxInt(u64), &.{ 0, 0 }));
    var output: [2]f32 = undefined;
    _ = try window.tick(&output);
    try std.testing.expectError(error.SequenceExhausted, window.tick(&output));
    try std.testing.expectEqualSlices(f32, &.{ 0.5, -0.5 }, &output);
}

test "all 32768 five-action traces agree with an independent non-ring oracle" {
    // Alphabet: insert positions 0..4, tick, stale insert, malformed insert.
    // The oracle stores by absolute position, avoiding the implementation's modulo
    // representation. All action orders include duplicate, late and capacity cases.
    for (0..32768) |trace| {
        var window = core.Window(3, 1).init(1);
        var oracle: [5]bool = @splat(false);
        var next: usize = 0;
        var encoded = trace;
        for (0..5) |_| {
            const action = encoded % 8;
            encoded /= 8;
            if (action < 5) {
                const sample: f32 = @floatFromInt(action + 1);
                const wanted: ?anyerror = if (action < next) error.Late else if (action - next >= 3) error.TooFar else if (oracle[action]) error.Duplicate else null;
                const result = window.insert(1, @intCast(action), &.{sample});
                if (wanted) |err| {
                    try std.testing.expectError(err, result);
                } else {
                    try result;
                    oracle[action] = true;
                }
            } else if (action == 5) {
                var output: [1]f32 = .{-999};
                const result = try window.tick(&output);
                const available = oracle[next];
                const expected: @TypeOf(result) = if (available) .media else .silence;
                try expect(result == expected);
                const sample: f32 = if (available) @floatFromInt(next + 1) else 0;
                try std.testing.expectEqual(sample, output[0]);
                oracle[next] = false;
                next += 1;
            } else if (action == 6) {
                try std.testing.expectError(error.StaleEpoch, window.insert(0, @intCast(next), &.{1}));
            } else {
                try std.testing.expectError(error.InvalidBlock, window.insert(1, @intCast(next), &.{}));
            }
            try std.testing.expectEqual(@as(u64, @intCast(next)), window.next);
        }
    }
}
