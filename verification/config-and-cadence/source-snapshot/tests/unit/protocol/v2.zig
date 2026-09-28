//! Byte-level expectations independent of production serialization, including
//! maximal fragmentation, finite-word preservation and rejection atomicity.
const std = @import("std");
const core = @import("lan_audio");
const v2 = core.wire_v2;
const expect = std.testing.expect;
const id: v2.StreamId = .{ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16 };

test "v2 independent literal offer and AUDIO bytes" {
    const offer = [_]u8{
        74, 67, 82,  50,  2, 1, 0, 48, 0, 0,  0,  16,  0,  0,  0,  0,
        1,  2,  3,   4,   5, 6, 7, 8,  9, 10, 11, 12,  13, 14, 15, 16,
        0,  0,  0,   0,   0, 0, 0, 0,  0, 0,  0,  0,   0,  0,  0,  0,
        0,  0,  187, 128, 0, 2, 0, 1,  0, 0,  0,  240, 0,  0,  0,  0,
    };
    const audio = [_]u8{
        74, 67, 82, 50, 2, 3, 0, 48,  0, 0,  0,  8,  0,  0,  0,  0,
        1,  2,  3,  4,  5, 6, 7, 8,   9, 10, 11, 12, 13, 14, 15, 16,
        0,  0,  0,  0,  0, 0, 0, 7,   0, 0,  0,  1,  0,  0,  0,  0,
        0,  0,  0,  0,  0, 0, 0, 128,
    };
    var out: [v2.max_record]u8 = undefined;
    try std.testing.expectEqualSlices(u8, &offer, try v2.encodeProfile(&out, .offer, id, .{}));
    try expect((try v2.profile(try v2.parse(&offer))).eql(.{}));
    try std.testing.expectEqualSlices(u8, &audio, try v2.encodeAudio(&out, id, 7, &.{ 0, @bitCast(@as(u32, 0x80000000)) }, .{}));
    var decoded: [2]f32 = undefined;
    try v2.decodeAudio(try v2.parse(&audio), &decoded);
    try expect(@as(u32, @bitCast(decoded[0])) == 0 and @as(u32, @bitCast(decoded[1])) == 0x80000000);
}

test "v2 finite boundaries and seeded words preserve exact little endian bits" {
    const boundary = [_]u32{ 0, 0x80000000, 1, 0x80000001, 0x007fffff, 0x807fffff, 0x00800000, 0x80800000, 0x3f800000, 0xbf800000, 0x7f7fffff, 0xff7fffff };
    var input: [v2.max_samples]f32 = undefined;
    var output: [v2.max_samples]f32 = undefined;
    var bytes: [v2.max_record]u8 = undefined;
    var seed: u32 = 0x913cab47;
    for (0..64) |batch| {
        for (&input, 0..) |*value, i| {
            seed ^= seed << 13;
            seed ^= seed >> 17;
            seed ^= seed << 5;
            var bits = if (batch == 0 and i < boundary.len) boundary[i] else seed;
            if (bits & 0x7f800000 == 0x7f800000) bits ^= 0x00800000;
            value.* = @bitCast(bits);
        }
        const record = try v2.encodeAudio(&bytes, id, batch * 1024, &input, .{ .max_frames = 1024 });
        try v2.decodeAudio(try v2.parse(record), &output);
        for (input, output, 0..) |a, b, i| {
            const bits: u32 = @bitCast(a);
            try expect(bits == @as(u32, @bitCast(b)));
            // Independent byte shifts, not the production read/writeInt helpers.
            for (0..4) |j| try expect(record[48 + i * 4 + j] == @as(u8, @truncate(bits >> @as(u5, @intCast(j * 8)))));
        }
    }
}

test "v2 every maximum record split and coalescing respect borrowed boundaries" {
    var bytes: [v2.max_record + 48]u8 = undefined;
    const input: [v2.max_samples]f32 = @splat(0.5);
    const record = try v2.encodeAudio(&bytes, id, 0, &input, .{ .max_frames = 1024 });
    for (0..record.len) |split| {
        var parser: v2.Parser = .{};
        const first = try parser.feed(record[0..split]);
        try expect(first.consumed == split and first.message == null);
        const second = try parser.feed(record[split..]);
        try expect(second.consumed == record.len - split and second.message.?.frames == 1024);
        try std.testing.expectEqualSlices(u8, record[48..], second.message.?.body);
        try parser.finish();
    }
    _ = try v2.encodeControl(bytes[record.len..], .end, id, 1024);
    var parser: v2.Parser = .{};
    const a = try parser.feed(&bytes);
    try expect(a.consumed == record.len and a.message.?.kind == .audio);
    const b = try parser.feed(bytes[a.consumed..]);
    try expect(b.consumed == 48 and b.message.?.kind == .end);
    for (0..64) |length| {
        var partial: v2.Parser = .{};
        _ = try partial.feed(bytes[0..length]);
        if (length == 0) try partial.finish() else try std.testing.expectError(error.Truncated, partial.finish());
    }
}

test "v2 malformed fields poison parsers without resynchronization" {
    var good: [64]u8 = undefined;
    _ = try v2.encodeProfile(&good, .offer, id, .{});
    const offsets = [_]usize{ 0, 4, 5, 6, 8, 12, 32, 40, 44, 48, 52, 54, 56, 60 };
    for (offsets) |offset| {
        var bad = good;
        bad[offset] = 255;
        var parser: v2.Parser = .{};
        if (parser.feed(&bad)) |_| return error.AcceptedMalformed else |_| {}
        try std.testing.expectError(error.Poisoned, parser.feed(&good));
        try std.testing.expectError(error.Poisoned, parser.finish());
    }
    var zero_id = good;
    @memset(zero_id[16..32], 0);
    try std.testing.expectError(error.InvalidStream, v2.parse(&zero_id));
    for (0..good.len) |length| {
        if (v2.parse(good[0..length])) |_| return error.AcceptedTruncated else |_| {}
    }
    var extra: [65]u8 = @splat(0);
    @memcpy(extra[0..64], &good);
    try std.testing.expectError(error.InvalidLength, v2.parse(&extra));
}

test "v2 all rejected encodes and nonfinite decodes preserve caller output" {
    var out: [64]u8 = @splat(0xa5);
    const before = out;
    try std.testing.expectError(error.ShortOutput, v2.encodeProfile(out[0..63], .offer, id, .{}));
    try std.testing.expectError(error.InvalidProfile, v2.encodeProfile(&out, .offer, id, .{ .sample_rate = 123 }));
    try std.testing.expectError(error.InvalidStream, v2.encodeControl(&out, .end, @splat(0), 0));
    try std.testing.expectError(error.InvalidSequence, v2.encodeAudio(&out, id, std.math.maxInt(u64), &.{ 0, 0 }, .{}));
    try std.testing.expectError(error.InvalidSamples, v2.encodeAudio(&out, id, 0, &.{0}, .{}));
    try std.testing.expectError(error.InvalidSamples, v2.encodeAudio(&out, id, 0, &.{}, .{}));
    try std.testing.expectError(error.ShortOutput, v2.encodeAudio(out[0..55], id, 0, &.{ 0, 0 }, .{}));
    for ([_]u32{ 0x7f800000, 0xff800000, 0x7fc00000, 0x7f800001, 0xff800001 }) |word| {
        try std.testing.expectError(error.InvalidSamples, v2.encodeAudio(&out, id, 0, &.{ 0, @bitCast(word) }, .{}));
        var body: [8]u8 = @splat(0);
        for (0..4) |j| body[4 + j] = @truncate(word >> @as(u5, @intCast(j * 8)));
        var decoded: [2]f32 = .{ 3, 4 };
        try std.testing.expectError(error.InvalidSamples, v2.decodeAudio(.{ .kind = .audio, .stream = id, .position = 0, .frames = 1, .body = &body }, &decoded));
        try std.testing.expectEqualSlices(f32, &.{ 3, 4 }, &decoded);
    }
    try std.testing.expectEqualSlices(u8, &before, &out);
    // A representable final frontier is legal; only addition past it is rejected.
    _ = try v2.encodeAudio(&out, id, std.math.maxInt(u64) - 1, &.{ 0, 0 }, .{});
    _ = try v2.encodeControl(&out, .end, id, std.math.maxInt(u64));
}

test "v2 checked formats bound dimensions before products" {
    for ([_]u32{ 44100, 48000, 96000 }) |rate| {
        const format: core.Format = .{ .sample_rate = rate, .max_frames = 1024 };
        try expect(try format.byteCount(1024) == 8192);
        try std.testing.expectError(error.InvalidFrames, format.sampleCount(0));
        try std.testing.expectError(error.InvalidFrames, format.sampleCount(1025));
    }
    for ([_]core.Format{ .{ .max_frames = 0 }, .{ .max_frames = 1025 }, .{ .channel_count = 32 }, .{ .representation = 2 } }) |format|
        try std.testing.expectError(error.InvalidProfile, format.validate());
}
