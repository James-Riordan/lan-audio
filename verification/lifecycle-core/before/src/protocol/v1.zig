//! JCR audio/1: bounded application records inside an authenticated TLS stream.
//! Framing is independent of TLS record/TCP packet boundaries. Parser storage is
//! fixed; malformed input poisons the parser instead of scanning for a new magic.
//! Returned messages borrow parser storage until the next feed call. No I/O/heap.
const std = @import("std");
pub const alpn = "jcr-audio/1";
pub const StreamId = [16]u8;
pub const sample_rate = 48000;
pub const channels = 2;
pub const frames = 240;
pub const samples = frames * channels;
pub const header_size = 36;
pub const pcm_size = samples * 2;
pub const max_record = header_size + pcm_size;
pub const Kind = enum(u8) { start = 1, audio = 2, end = 3, ack = 4 };
pub const Error = error{ InvalidHeader, InvalidLength, InvalidProfile, InvalidSequence, InvalidStream, InvalidSamples, ShortOutput, Poisoned, Truncated };
pub const Message = struct { kind: Kind, stream: StreamId, sequence: u64, body: []const u8 };

fn bodySize(kind: Kind) usize {
    return switch (kind) {
        .start => 12,
        .audio => pcm_size,
        .end, .ack => 0,
    };
}
fn validId(id: StreamId) bool {
    for (id) |byte| if (byte != 0) return true;
    return false;
}
fn kindOf(byte: u8) Error!Kind {
    return switch (byte) {
        1 => .start,
        2 => .audio,
        3 => .end,
        4 => .ack,
        else => error.InvalidHeader,
    };
}
fn header(bytes: []const u8) Error!struct { kind: Kind, stream: StreamId, sequence: u64, total: usize } {
    if (bytes.len < header_size) return error.InvalidLength;
    if (!std.mem.eql(u8, bytes[0..4], "JCRA") or bytes[4] != 1 or std.mem.readInt(u16, bytes[6..8], .big) != header_size) return error.InvalidHeader;
    const kind = try kindOf(bytes[5]);
    if (std.mem.readInt(u32, bytes[8..12], .big) != bodySize(kind)) return error.InvalidLength;
    const seq = std.mem.readInt(u64, bytes[12..20], .big);
    if ((kind == .start and seq != 0) or (kind == .audio and seq == std.math.maxInt(u64))) return error.InvalidSequence;
    const id: StreamId = bytes[20..36].*;
    if (!validId(id)) return error.InvalidStream;
    return .{ .kind = kind, .stream = id, .sequence = seq, .total = header_size + bodySize(kind) };
}

pub fn validate(message: Message) Error!void {
    if (!validId(message.stream)) return error.InvalidStream;
    if (message.body.len != bodySize(message.kind)) return error.InvalidLength;
    if ((message.kind == .start and message.sequence != 0) or (message.kind == .audio and message.sequence == std.math.maxInt(u64))) return error.InvalidSequence;
    if (message.kind == .start) {
        const b = message.body;
        if (std.mem.readInt(u32, b[0..4], .big) != sample_rate or
            std.mem.readInt(u16, b[4..6], .big) != channels or
            std.mem.readInt(u16, b[6..8], .big) != frames or
            std.mem.readInt(u16, b[8..10], .big) != 1 or
            std.mem.readInt(u16, b[10..12], .big) != 0) return error.InvalidProfile;
    }
}

pub fn parse(bytes: []const u8) Error!Message {
    const h = try header(bytes);
    if (bytes.len != h.total) return error.InvalidLength;
    const message: Message = .{ .kind = h.kind, .stream = h.stream, .sequence = h.sequence, .body = bytes[header_size..] };
    try validate(message);
    return message;
}

pub const Parser = struct {
    storage: [max_record]u8 = undefined,
    used: usize = 0,
    wanted: usize = header_size,
    ready: bool = false,
    failed: bool = false,
    pub const Feed = struct { consumed: usize, message: ?Message };

    /// Consumes only through one record. The caller must process the unconsumed
    /// suffix; input must not overlap this parser's storage. Errors are terminal.
    pub fn feed(self: *Parser, input: []const u8) Error!Feed {
        if (self.failed) return error.Poisoned;
        if (self.ready) {
            self.used = 0;
            self.wanted = header_size;
            self.ready = false;
        }
        errdefer self.failed = true;
        var consumed: usize = 0;
        while (true) {
            const n = @min(self.wanted - self.used, input.len - consumed);
            @memcpy(self.storage[self.used..][0..n], input[consumed..][0..n]);
            self.used += n;
            consumed += n;
            if (self.used < self.wanted) return .{ .consumed = consumed, .message = null };
            if (self.wanted == header_size) self.wanted = (try header(self.storage[0..header_size])).total;
            if (self.used == self.wanted) {
                const message = try parse(self.storage[0..self.used]);
                self.ready = true;
                return .{ .consumed = consumed, .message = message };
            }
        }
    }
    /// Call at authenticated channel close or protocol end to reject a partial record.
    pub fn finish(self: *const Parser) Error!void {
        if (self.failed) return error.Poisoned;
        if (self.used != 0 and !self.ready) return error.Truncated;
    }
};

fn writeHeader(out: []u8, kind: Kind, id: StreamId, sequence: u64) Error![]u8 {
    if (!validId(id)) return error.InvalidStream;
    if ((kind == .start and sequence != 0) or (kind == .audio and sequence == std.math.maxInt(u64))) return error.InvalidSequence;
    const size = header_size + bodySize(kind);
    if (out.len < size) return error.ShortOutput;
    @memcpy(out[0..4], "JCRA");
    out[4] = 1;
    out[5] = @backingInt(kind);
    std.mem.writeInt(u16, out[6..8], header_size, .big);
    std.mem.writeInt(u32, out[8..12], @intCast(bodySize(kind)), .big);
    std.mem.writeInt(u64, out[12..20], sequence, .big);
    @memcpy(out[20..36], &id);
    return out[0..size];
}
pub fn encodeStart(out: []u8, id: StreamId) Error![]const u8 {
    const record = try writeHeader(out, .start, id, 0);
    const b = record[header_size..];
    std.mem.writeInt(u32, b[0..4], sample_rate, .big);
    std.mem.writeInt(u16, b[4..6], channels, .big);
    std.mem.writeInt(u16, b[6..8], frames, .big);
    std.mem.writeInt(u16, b[8..10], 1, .big); // signed PCM16, little endian, L/R interleaved
    std.mem.writeInt(u16, b[10..12], 0, .big); // reserved, must remain zero
    return record;
}
pub fn encodeEnd(out: []u8, id: StreamId, next: u64) Error![]const u8 {
    return writeHeader(out, .end, id, next);
}
pub fn encodeAck(out: []u8, id: StreamId, next: u64) Error![]const u8 {
    return writeHeader(out, .ack, id, next);
}

/// Rounds finite PCM to nearest integer (ties away from zero), saturates, then
/// serializes little-endian s16. Rejects all invalid input before modifying output.
/// Input samples and output bytes must not overlap.
pub fn encodeAudio(out: []u8, id: StreamId, sequence: u64, input: []const f32) Error![]const u8 {
    if (input.len != samples) return error.InvalidSamples;
    for (input) |value| if (!std.math.isFinite(value)) return error.InvalidSamples;
    const record = try writeHeader(out, .audio, id, sequence);
    for (input, 0..) |value, i| {
        const scaled: i32 = @intFromFloat(@round(std.math.clamp(value, -1, 1) * 32768));
        std.mem.writeInt(i16, record[header_size + 2 * i ..][0..2], @intCast(std.math.clamp(scaled, -32768, 32767)), .little);
    }
    return record;
}
pub fn decodeAudio(message: Message, output: []f32) Error!void {
    try validate(message);
    if (message.kind != .audio or output.len != samples) return error.InvalidSamples;
    // Temporary permits decoding into storage overlapping the input record.
    var copy: [samples]f32 = undefined;
    for (&copy, 0..) |*value, i| value.* = @as(f32, @floatFromInt(std.mem.readInt(i16, message.body[2 * i ..][0..2], .little))) / 32768;
    @memcpy(output, &copy);
}
