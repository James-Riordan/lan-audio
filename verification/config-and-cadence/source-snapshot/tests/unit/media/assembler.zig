//! Independent absolute-frame expectations for variable capture chunking, EOF,
//! backpressure, finite-bit preservation and terminal discontinuity. No devices.
const std = @import("std");
const core = @import("lan_audio");
const Assembler = core.BlockAssembler;
const expect = std.testing.expect;

test "assembly preserves arbitrary callback prefixes and final partial block" {
    const total = 1031;
    var source: [total * 2]f32 = undefined;
    for (&source, 0..) |*value, i| value.* = @bitCast(@as(u32, @intCast(i + 1))); // distinct subnormal words
    const chunks = [_]usize{ 1, 7, 333, 2, 511, 177 };
    for ([_]u32{ 1, 17, 240, 1024 }) |maximum| {
        var assembler = try Assembler.init(.{ .max_frames = maximum });
        var produced: usize = 0;
        var consumed: usize = 0;
        var chunk: usize = 0;
        while (produced < total) {
            const end: usize = @min(total, produced + chunks[chunk % chunks.len]);
            chunk += 1;
            while (produced < end) {
                const copied = try assembler.push(source[produced * 2 .. end * 2]);
                produced += copied;
                if (try assembler.peek()) |block| {
                    try expect(block.first_frame == consumed and block.frames == maximum);
                    for (block.samples, 0..) |value, i| try expect(@as(u32, @bitCast(value)) == (consumed * 2 + i + 1));
                    consumed += block.frames;
                    try assembler.commit();
                } else try expect(copied > 0);
            }
        }
        try assembler.finish();
        try assembler.finish();
        if (try assembler.peek()) |tail| {
            try expect(tail.first_frame == consumed and tail.frames == total - consumed);
            for (tail.samples, 0..) |value, i| try expect(@as(u32, @bitCast(value)) == consumed * 2 + i + 1);
            consumed += tail.frames;
            try assembler.commit();
        }
        try expect(consumed == total and try assembler.endPosition() == total);
    }
}

test "assembly backpressure leaves block and caller suffix intact" {
    var assembler = try Assembler.init(.{ .max_frames = 1 });
    const input = [_]f32{ @bitCast(@as(u32, 0x80000000)), @bitCast(@as(u32, 1)), std.math.nan(f32), 0 };
    try expect(try assembler.push(&input) == 1); // Invalid suffix not consumed.
    try expect(try assembler.push(input[2..]) == 0);
    const block = (try assembler.peek()).?;
    try expect(@as(u32, @bitCast(block.samples[0])) == 0x80000000);
    try expect(@as(u32, @bitCast(block.samples[1])) == 1);
    try expect((try assembler.peek()).?.first_frame == 0);
    try assembler.commit();
    try std.testing.expectError(error.NotReady, assembler.commit());
    try std.testing.expectError(error.InvalidSamples, assembler.push(input[2..]));
    try expect(assembler.next_frame == 1 and assembler.pending_frames == 0);
}

test "assembly rejected accepted prefix leaves previous data unchanged" {
    var assembler = try Assembler.init(.{ .max_frames = 3 });
    try expect(try assembler.push(&.{ 1, 2 }) == 1);
    const before = assembler.storage[0..2].*;
    try std.testing.expectError(error.InvalidSamples, assembler.push(&.{ 3, 4, 5, std.math.inf(f32) }));
    try std.testing.expectError(error.InvalidSamples, assembler.push(&.{3}));
    try expect(assembler.pending_frames == 1 and assembler.next_frame == 0);
    try std.testing.expectEqualSlices(f32, &before, assembler.storage[0..2]);
    try expect(try assembler.push(&.{}) == 0);
    try std.testing.expectError(error.NotDrained, assembler.endPosition());
}

test "assembly EOF and discontinuity have different terminal meanings" {
    var assembler = try Assembler.init(.{});
    try assembler.finish();
    try expect(try assembler.peek() == null and try assembler.endPosition() == 0);
    try std.testing.expectError(error.InvalidState, assembler.push(&.{ 0, 0 }));
    assembler = try Assembler.init(.{});
    _ = try assembler.push(&.{ 1, 2 });
    assembler.discontinue();
    assembler.discontinue();
    try std.testing.expectError(error.Discontinuity, assembler.peek());
    try std.testing.expectError(error.Discontinuity, assembler.push(&.{ 0, 0 }));
    try std.testing.expectError(error.Discontinuity, assembler.commit());
    try std.testing.expectError(error.Discontinuity, assembler.finish());
    try std.testing.expectError(error.Discontinuity, assembler.endPosition());
    try expect(assembler.pending_frames == 0);
}

test "assembly checks terminal u64 frontier before storing samples" {
    var assembler = try Assembler.init(.{ .max_frames = 1 });
    // Deliberate boundary injection; production reaches this only by commits.
    assembler.next_frame = std.math.maxInt(u64) - 1;
    _ = try assembler.push(&.{ 0, 0 });
    try assembler.commit();
    try std.testing.expectError(error.InvalidSequence, assembler.push(&.{ 1, 2 }));
    try expect(assembler.pending_frames == 0 and assembler.next_frame == std.math.maxInt(u64));
    try assembler.finish();
    try expect(try assembler.endPosition() == std.math.maxInt(u64));
}

test "assembly output composes with v2 encoding and exact frame negotiation" {
    var assembler = try Assembler.init(.{ .max_frames = 3 });
    var gate = core.Negotiation.init(.sender);
    try gate.authorizeChannel();
    var bytes: [core.wire_v2.max_record]u8 = undefined;
    const id: core.wire_v2.StreamId = @splat(1);
    try gate.apply(.outgoing, try core.wire_v2.parse(try core.wire_v2.encodeProfile(&bytes, .offer, id, assembler.format)));
    try gate.apply(.incoming, try core.wire_v2.parse(try core.wire_v2.encodeProfile(&bytes, .accept, id, assembler.format)));
    _ = try assembler.push(&.{ 1, 2, 3, 4 });
    try assembler.finish();
    const tail = (try assembler.peek()).?;
    const record = try core.wire_v2.encodeAudio(&bytes, id, tail.first_frame, tail.samples, assembler.format);
    try gate.apply(.outgoing, try core.wire_v2.parse(record)); // Stand-in for copied transport acceptance.
    try assembler.commit();
    const end = try assembler.endPosition();
    try gate.apply(.outgoing, try core.wire_v2.parse(try core.wire_v2.encodeControl(&bytes, .end, id, end)));
    try expect(end == 2 and gate.next_frame == 2 and gate.phase == .draining);
}
