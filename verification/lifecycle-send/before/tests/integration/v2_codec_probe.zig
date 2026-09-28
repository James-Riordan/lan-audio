//! Test-only C ABI for a separately implemented Python oracle. No product ABI.
//! Borrow bounded input/output for one call; no I/O/heap/retained pointers.
//! Positive return: canonical re-encoded size. Zero: invalid record. Negative:
//! harness misuse or disagreement between production paths, never normal rejection.
const std = @import("std");
const v2 = @import("lan_audio").wire_v2;

export fn jcr_v2_probe(input: ?[*]const u8, size: usize, fragment: usize, output: ?[*]u8, capacity: usize) c_int {
    if (size > v2.max_record + 1 or fragment == 0 or fragment > v2.max_record + 1 or capacity < v2.max_record or input == null or output == null) return -1;
    const bytes = input.?[0..size];
    const direct = v2.parse(bytes) catch null;
    var parser: v2.Parser = .{};
    var streamed: ?v2.Message = null;
    var offset: usize = 0;
    var rejected = false;
    while (offset < size) {
        const fed = parser.feed(bytes[offset..@min(size, offset + fragment)]) catch {
            rejected = true;
            // A parse error must poison both later feed and finish.
            if (parser.feed(&.{})) |_| return -2 else |err| if (err != error.Poisoned) return -2;
            if (parser.finish()) |_| return -2 else |err| if (err != error.Poisoned) return -2;
            break;
        };
        if (fed.consumed == 0) return -3;
        offset += fed.consumed;
        if (fed.message) |message| {
            streamed = message;
            if (offset != size) rejected = true; // Extra bytes violate exactly-one-record.
            break;
        }
    }
    parser.finish() catch {
        rejected = true;
    };
    const accepted = !rejected and streamed != null;
    if ((direct != null) != accepted) return -4;
    if (!accepted) return 0;
    const message = streamed.?;
    const original = direct.?;
    if (original.kind != message.kind or original.position != message.position or original.frames != message.frames or
        !std.mem.eql(u8, &original.stream, &message.stream) or !std.mem.eql(u8, original.body, message.body)) return -5;
    const out = output.?[0..capacity];
    const record = switch (message.kind) {
        .offer, .accept => v2.encodeProfile(out, message.kind, message.stream, v2.profile(message) catch return -6) catch return -6,
        .end, .ack => v2.encodeControl(out, message.kind, message.stream, message.position) catch return -6,
        .audio => blk: {
            var pcm: [v2.max_samples]f32 = undefined;
            const samples = pcm[0 .. @as(usize, message.frames) * 2];
            v2.decodeAudio(message, samples) catch return -6;
            break :blk v2.encodeAudio(out, message.stream, message.position, samples, .{ .max_frames = 1024 }) catch return -6;
        },
    };
    return @intCast(record.len);
}
