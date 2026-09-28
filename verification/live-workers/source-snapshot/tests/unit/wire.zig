//! Golden wire bytes, adversarial parser boundaries and composed receiver behavior.
const std = @import("std");
const core = @import("lan_audio");
const wire = core.wire;
const expect = std.testing.expect;
const id: wire.StreamId = @splat(1);

test "wire has independent golden header and quantization vectors" {
    var out: [wire.max_record]u8 = undefined;
    var pcm: [wire.samples]f32 = @splat(0);
    @memcpy(pcm[0..7], &[_]f32{ -2, -1, -0.5, 0, 0.5, 1, 2 });
    const bytes = try wire.encodeAudio(&out, id, 7, &pcm);
    const golden = [_]u8{ 'J', 'C', 'R', 'A', 1, 2, 0, 36, 0, 0, 3, 192, 0, 0, 0, 0, 0, 0, 0, 7 };
    try std.testing.expectEqualSlices(u8, &golden, bytes[0..20]);
    const encoded = [_]u8{ 0, 128, 0, 128, 0, 192, 0, 0, 0, 64, 255, 127, 255, 127 };
    try std.testing.expectEqualSlices(u8, &encoded, bytes[36..50]);
    var decoded: [wire.samples]f32 = undefined;
    try wire.decodeAudio(try wire.parse(bytes), &decoded);
    try std.testing.expectEqualSlices(f32, &.{ -1, -1, -0.5, 0, 0.5, 32767.0 / 32768.0, 32767.0 / 32768.0 }, decoded[0..7]);
    pcm[0] = std.math.nan(f32);
    const before = out;
    try std.testing.expectError(error.InvalidSamples, wire.encodeAudio(&out, id, 8, &pcm));
    try std.testing.expectEqualSlices(u8, &before, &out);
}

test "every possible single split preserves a complete PCM record" {
    var out: [wire.max_record]u8 = undefined;
    const pcm: [wire.samples]f32 = @splat(0.25);
    const bytes = try wire.encodeAudio(&out, id, 42, &pcm);
    for (0..bytes.len) |split| {
        var parser: wire.Parser = .{};
        const a = try parser.feed(bytes[0..split]);
        try expect(a.consumed == split and a.message == null);
        const b = try parser.feed(bytes[split..]);
        try expect(b.consumed == bytes.len - split and b.message.?.sequence == 42);
        var decoded: [wire.samples]f32 = undefined;
        try wire.decodeAudio(b.message.?, &decoded);
        try std.testing.expectEqualSlices(f32, &pcm, &decoded);
        try parser.finish();
    }
}

test "coalesced records preserve unconsumed suffix and partial close fails" {
    var bytes: [96]u8 = undefined;
    const a = try wire.encodeStart(bytes[0..48], id);
    const b = try wire.encodeEnd(bytes[48..], id, 0);
    var parser: wire.Parser = .{};
    const first = try parser.feed(bytes[0 .. a.len + b.len]);
    try expect(first.consumed == 48 and first.message.?.kind == .start);
    const second = try parser.feed(bytes[first.consumed .. a.len + b.len]);
    try expect(second.consumed == 36 and second.message.?.kind == .end);
    _ = try parser.feed(bytes[0..7]);
    try std.testing.expectError(error.Truncated, parser.finish());
}

test "hostile lengths versions profiles and ids fail without resynchronization" {
    var bytes: [wire.max_record]u8 = undefined;
    _ = try wire.encodeStart(&bytes, id);
    bytes[8] = 255;
    var parser: wire.Parser = .{};
    try std.testing.expectError(error.InvalidLength, parser.feed(bytes[0..36]));
    try std.testing.expectError(error.Poisoned, parser.feed("JCRA"));
    _ = try wire.encodeStart(&bytes, id);
    bytes[4] = 2;
    try std.testing.expectError(error.InvalidHeader, wire.parse(bytes[0..48]));
    _ = try wire.encodeStart(&bytes, id);
    bytes[47] = 1;
    try std.testing.expectError(error.InvalidProfile, wire.parse(bytes[0..48]));
    _ = try wire.encodeStart(&bytes, id);
    @memset(bytes[20..36], 0);
    try std.testing.expectError(error.InvalidStream, wire.parse(bytes[0..48]));
}

test "receiver requires channel authorization and binds exactly one stream" {
    var receiver: core.Receiver(3) = .{};
    var bytes: [wire.max_record]u8 = undefined;
    const start = try wire.parse(try wire.encodeStart(&bytes, id));
    try std.testing.expectError(error.Unauthenticated, receiver.accept(start));
    try receiver.authorizeChannel();
    try receiver.accept(start);
    try std.testing.expectError(error.UnexpectedMessage, receiver.accept(start));
    const pcm: [wire.samples]f32 = @splat(0.25);
    const wrong: wire.StreamId = @splat(2);
    try std.testing.expectError(error.WrongStream, receiver.accept(try wire.parse(try wire.encodeAudio(&bytes, wrong, 0, &pcm))));
    try expect(receiver.window.next == 0);
    try receiver.accept(try wire.parse(try wire.encodeAudio(&bytes, id, 0, &pcm)));
    try std.testing.expectError(error.Duplicate, receiver.accept(try wire.parse(bytes[0..wire.max_record])));
}

test "end drains buffered positions and fills missing positions once" {
    var receiver: core.Receiver(3) = .{};
    var bytes: [wire.max_record]u8 = undefined;
    var output: [wire.samples]f32 = undefined;
    const pcm: [wire.samples]f32 = @splat(-0.5);
    try receiver.authorizeChannel();
    try receiver.accept(try wire.parse(try wire.encodeStart(&bytes, id)));
    try receiver.accept(try wire.parse(try wire.encodeAudio(&bytes, id, 2, &pcm)));
    try std.testing.expectError(error.InvalidEnd, receiver.accept(try wire.parse(try wire.encodeEnd(&bytes, id, 2))));
    try receiver.accept(try wire.parse(try wire.encodeEnd(&bytes, id, 3)));
    try expect(!receiver.ended);
    try expect(try receiver.tick(&output) == .silence);
    try expect(try receiver.tick(&output) == .silence);
    try expect(try receiver.tick(&output) == .media);
    try std.testing.expectEqualSlices(f32, &pcm, &output);
    try expect(receiver.ended and receiver.session.phase == .idle);
    try std.testing.expectError(error.Ended, receiver.tick(&output));
    try std.testing.expectError(error.Ended, receiver.accept(try wire.parse(try wire.encodeEnd(&bytes, id, 3))));
}

test "all s16 values survive decode and re-encode exactly" {
    var bytes: [wire.max_record]u8 = undefined;
    var encoded: [wire.max_record]u8 = undefined;
    var pcm: [wire.samples]f32 = @splat(0);
    _ = try wire.encodeAudio(&bytes, id, 0, &pcm);
    for (0..65536) |bits| {
        std.mem.writeInt(u16, bytes[36..38], @intCast(bits), .little);
        try wire.decodeAudio(try wire.parse(&bytes), &pcm);
        _ = try wire.encodeAudio(&encoded, id, 0, &pcm);
        try std.testing.expectEqualSlices(u8, bytes[36..38], encoded[36..38]);
    }
}
