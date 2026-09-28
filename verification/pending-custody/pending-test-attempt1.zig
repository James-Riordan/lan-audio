//! Independent frame/sample identity oracle across short/zero queue writes.
//! Explicit parser reuse and candidate-gate tests complement ReceiveDrain's model.
const std = @import("std");
const core = @import("lan_audio");
const wire = core.wire_v2;
const Pending = @import("pending_audio").PendingBlock;
const expect = std.testing.expect;
const id: wire.StreamId = @splat(1);
const edges = [_]u32{ 0, 0x80000000, 1, 0x80000001, 0x007fffff, 0x807fffff, 0x00800000, 0x80800000, 0x7f7fffff, 0xff7fffff };

fn word(sample: usize) u32 {
    return if (sample % 3 == 0) edges[(sample / 3) % edges.len] else @intCast(sample + 1);
}

/// Build payload independently using integer words, without the production encoder.
fn audio(body: []u8, first: usize, frames: u32) wire.Message {
    const count: usize = @as(usize, frames) * 2;
    for (0..count) |i| std.mem.writeInt(u32, body[4 * i ..][0..4], word(first * 2 + i), .little);
    return .{ .kind = .audio, .stream = id, .position = first, .frames = frames, .body = body[0 .. count * 4] };
}

fn checkSamples(samples: []const f32, first: usize) !void {
    for (samples, 0..) |value, i| try expect(@as(u32, @bitCast(value)) == word(first * 2 + i));
}

test "pending prefixes preserve independent source words through varied queue capacities" {
    inline for ([_]u32{ 1, 8, 32, 4096 }) |capacity| {
        var pending = try Pending.init(.{ .max_frames = 1024 });
        var queue: core.FrameQueue(capacity, 2) = .{};
        var body: [8192]u8 = undefined;
        var output: [14]f32 = undefined;
        var admitted: usize = 0;
        var consumed: usize = 0;
        var turns: usize = 0;
        var short_writes: usize = 0;
        var zero_writes: usize = 0;
        for ([_]u32{ 1, 17, 240, 1024, 3 }) |frames| {
            try pending.admit(audio(&body, admitted, frames));
            admitted += frames;
            while (try pending.peek()) |block| {
                try expect(turns < 20000); // Fail a stalled implementation, never hang.
                turns += 1;
                const accepted = queue.write(block.samples);
                if (accepted < block.frames) short_writes += 1;
                if (accepted == 0) zero_writes += 1;
                try pending.advance(@intCast(accepted));
                // Deterministic pauses force a full queue and zero acceptance.
                if (turns % 4 == 0) {
                    const requested = [_]usize{ 1, 7, 3 }[(turns / 4) % 3];
                    const got = queue.read(output[0 .. requested * 2]);
                    try checkSamples(output[0 .. got * 2], consumed);
                    consumed += got;
                }
            }
        }
        while (queue.producerPending() > 0) {
            const got = queue.read(&output);
            try expect(got > 0);
            try checkSamples(output[0 .. got * 2], consumed);
            consumed += got;
        }
        try expect(consumed == 1285 and admitted == consumed);
        if (capacity < 1024) try expect(short_writes > 0 and zero_writes > 0);
    }
}

test "pending admission failures preserve all initialized storage and metadata" {
    var pending = try Pending.init(.{ .max_frames = 2 });
    @memset(&pending.storage, 0.25);
    const before = pending;
    var body: [24]u8 = undefined;
    var message = audio(&body, 0, 2);
    std.mem.writeInt(u32, body[12..16], 0x7fc00001, .little);
    try std.testing.expectError(error.InvalidSamples, pending.admit(message));
    try std.testing.expectEqualDeep(before, pending);
    message = audio(&body, 0, 2);
    message.body = body[0..15];
    try std.testing.expectError(error.InvalidLength, pending.admit(message));
    try std.testing.expectEqualDeep(before, pending);
    message = audio(&body, 0, 3);
    try std.testing.expectError(error.InvalidFrames, pending.admit(message));
    try std.testing.expectEqualDeep(before, pending);
    message = audio(&body, 0, 1);
    message.position = std.math.maxInt(u64);
    try std.testing.expectError(error.InvalidSequence, pending.admit(message));
    try std.testing.expectEqualDeep(before, pending);
    message.position = 0;
    message.stream = @splat(0);
    try std.testing.expectError(error.InvalidStream, pending.admit(message));
    try std.testing.expectEqualDeep(before, pending);
    message.kind = .end;
    try std.testing.expectError(error.InvalidSamples, pending.admit(message));
    try std.testing.expectEqualDeep(before, pending);
}

test "pending busy rejection and cursor boundaries do not consume the suffix" {
    var pending = try Pending.init(.{ .max_frames = 2 });
    var body: [16]u8 = undefined;
    try pending.advance(0);
    try expect(try pending.peek() == null);
    try std.testing.expectError(error.InvalidAdvance, pending.advance(1));
    try pending.admit(audio(&body, 19, 2));
    const stable = (try pending.peek()).?;
    try std.testing.expectError(error.InvalidAdvance, pending.advance(std.math.maxInt(u32)));
    try pending.advance(0);
    try pending.advance(0);
    try expect((try pending.peek()).?.first_frame == stable.first_frame);
    try pending.advance(1);
    const suffix = (try pending.peek()).?;
    try expect(suffix.first_frame == 20 and suffix.frames == 1);
    try checkSamples(suffix.samples, 20);
    try std.testing.expectError(error.Busy, pending.admit(audio(&body, 90, 2)));
    try checkSamples((try pending.peek()).?.samples, 20);
    try pending.advance(1);
    try expect(try pending.peek() == null);
    try std.testing.expectError(error.InvalidAdvance, pending.advance(1));
    try pending.admit(audio(&body, 21, 1));
    try checkSamples((try pending.peek()).?.samples, 21);
}

test "pending terminal abort reports only local outstanding custody once" {
    var pending = try Pending.init(.{ .max_frames = 2 });
    var body: [16]u8 = undefined;
    try pending.admit(audio(&body, 0, 2));
    try pending.advance(1);
    try expect(pending.abort() == 1);
    try expect(pending.abort() == 0);
    try std.testing.expectError(error.Aborted, pending.peek());
    try std.testing.expectError(error.Aborted, pending.advance(0));
    try std.testing.expectError(error.Aborted, pending.admit(audio(&body, 0, 1)));
}

test "pending permits a nonwrapping exclusive u64 end but no wrapped range" {
    var pending = try Pending.init(.{ .max_frames = 2 });
    var body: [16]u8 = undefined;
    var message = audio(&body, 0, 2);
    message.position = std.math.maxInt(u64) - 2;
    try pending.admit(message);
    try pending.advance(1);
    try expect((try pending.peek()).?.first_frame == std.math.maxInt(u64) - 1);
    try pending.advance(1);
    try expect(try pending.peek() == null);
    message.position += 1;
    try std.testing.expectError(error.InvalidSequence, pending.admit(message));
}

test "pending rejects invalid initialization profiles and zero AUDIO" {
    try std.testing.expectError(error.InvalidProfile, Pending.init(.{ .sample_rate = 0 }));
    try std.testing.expectError(error.InvalidProfile, Pending.init(.{ .channel_count = 1 }));
    try std.testing.expectError(error.InvalidProfile, Pending.init(.{ .max_frames = 1025 }));
    var pending = try Pending.init(.{});
    try std.testing.expectError(error.InvalidFrames, pending.admit(.{ .kind = .audio, .stream = id, .position = 0, .frames = 0, .body = &.{} }));
}

test "pending copied ownership survives parser reuse and blocked gate admission" {
    var pending = try Pending.init(.{ .max_frames = 2 });
    var gate = core.Negotiation.init(.receiver);
    try gate.authorizeChannel();
    var control: [64]u8 = undefined;
    try gate.apply(.incoming, try wire.parse(try wire.encodeProfile(&control, .offer, id, pending.format)));
    try gate.apply(.outgoing, try wire.parse(try wire.encodeProfile(&control, .accept, id, pending.format)));
    var packets: [128]u8 = undefined;
    var source: [4]f32 = undefined;
    for (&source, 0..) |*sample, i| sample.* = @bitCast(word(i));
    const a = try wire.encodeAudio(packets[0..64], id, 0, &source, pending.format);
    for (&source, 0..) |*sample, i| sample.* = @bitCast(word(4 + i));
    const b = try wire.encodeAudio(packets[64..], id, 2, &source, pending.format);
    var parser: wire.Parser = .{};
    const first = try parser.feed(packets[0 .. a.len + b.len]);
    try expect(first.consumed == 64);
    var candidate = gate;
    try candidate.apply(.incoming, first.message.?);
    try pending.admit(first.message.?);
    gate = candidate;
    const second = try parser.feed(packets[first.consumed .. a.len + b.len]);
    candidate = gate;
    try candidate.apply(.incoming, second.message.?);
    try std.testing.expectError(error.Busy, pending.admit(second.message.?));
    try expect(gate.next_frame == 2); // Candidate was not committed on Busy.
    try checkSamples((try pending.peek()).?.samples, 0); // Parser reused its storage.
    try pending.advance(2);
    try pending.admit(second.message.?); // Retained borrow still valid; no next feed.
    gate = candidate;
    try checkSamples((try pending.peek()).?.samples, 2);
    try expect(gate.next_frame == 4);
    try parser.finish();
}
