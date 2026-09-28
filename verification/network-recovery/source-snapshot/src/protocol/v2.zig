//! JCR audio/2: bounded, fidelity-preserving records inside an authenticated stream.
//! Header integers are BE; finite binary32 payload words are LE without arithmetic.
//! This module validates syntax/value bounds, not peer trust, phase or continuity.
//! Messages borrow their input; Parser messages expire at the next feed call.
//! All owners are serialized, all storage fixed, all encode errors precede writes.
//! Caller buffers must not alias encoder input, decoder input or Parser storage.
//! Full layout, contracts and proof obligations: docs/protocol/v2.md.
const std = @import("std");
pub const Format = @import("../media/format.zig").Format;
pub const alpn = "jcr-audio/2";
pub const StreamId = [16]u8;
pub const header_size = 48;
pub const profile_size = 16;
pub const max_samples = Format.frame_limit * 2;
pub const max_record = header_size + max_samples * 4;
pub const Kind = enum(u8) { offer = 1, accept = 2, audio = 3, end = 4, ack = 5 };
pub const Error = Format.Error || error{ InvalidHeader, InvalidLength, InvalidSequence, InvalidStream, InvalidSamples, ShortOutput, Poisoned, Truncated };
pub const Message = struct { kind: Kind, stream: StreamId, position: u64, frames: u32, body: []const u8 };

fn validId(id: StreamId) bool {
    for (id) |byte| if (byte != 0) return true;
    return false;
}
fn kindOf(byte: u8) Error!Kind {
    return switch (byte) {
        1 => .offer,
        2 => .accept,
        3 => .audio,
        4 => .end,
        5 => .ack,
        else => error.InvalidHeader,
    };
}
fn finiteWord(word: u32) bool {
    return word & 0x7f800000 != 0x7f800000;
}

/// Bound arithmetic before multiplication/slicing. AUDIO cannot wrap its frontier.
fn bodySize(kind: Kind, position: u64, frames: u32) Error!usize {
    switch (kind) {
        .offer, .accept => {
            if (position != 0 or frames != 0) return error.InvalidSequence;
            return profile_size;
        },
        .audio => {
            if (frames == 0 or frames > Format.frame_limit) return error.InvalidFrames;
            if (position > std.math.maxInt(u64) - @as(u64, frames)) return error.InvalidSequence;
            return @as(usize, frames) * 8;
        },
        .end, .ack => {
            if (frames != 0) return error.InvalidFrames;
            return 0;
        },
    }
}

fn header(bytes: []const u8) Error!struct { message: Message, total: usize } {
    if (bytes.len < header_size) return error.InvalidLength;
    if (!std.mem.eql(u8, bytes[0..4], "JCR2") or bytes[4] != 2 or
        std.mem.readInt(u16, bytes[6..8], .big) != header_size or
        std.mem.readInt(u32, bytes[12..16], .big) != 0 or
        std.mem.readInt(u32, bytes[44..48], .big) != 0) return error.InvalidHeader;
    const kind = try kindOf(bytes[5]);
    const position = std.mem.readInt(u64, bytes[32..40], .big);
    const frames = std.mem.readInt(u32, bytes[40..44], .big);
    const size = try bodySize(kind, position, frames);
    if (std.mem.readInt(u32, bytes[8..12], .big) != size) return error.InvalidLength;
    const stream: StreamId = bytes[16..32].*;
    if (!validId(stream)) return error.InvalidStream;
    return .{ .message = .{ .kind = kind, .stream = stream, .position = position, .frames = frames, .body = &.{} }, .total = header_size + size };
}

fn readProfile(body: []const u8) Error!Format {
    if (body.len != profile_size) return error.InvalidLength;
    if (std.mem.readInt(u32, body[12..16], .big) != 0) return error.InvalidProfile;
    const format: Format = .{ .sample_rate = std.mem.readInt(u32, body[0..4], .big), .channel_count = std.mem.readInt(u16, body[4..6], .big), .representation = std.mem.readInt(u16, body[6..8], .big), .max_frames = std.mem.readInt(u32, body[8..12], .big) };
    try format.validate();
    return format;
}

/// Revalidate even a caller-constructed Message; a Zig struct is not trusted input.
pub fn validate(message: Message) Error!void {
    if (!validId(message.stream)) return error.InvalidStream;
    if (message.body.len != try bodySize(message.kind, message.position, message.frames)) return error.InvalidLength;
    switch (message.kind) {
        .offer, .accept => _ = try readProfile(message.body),
        .audio => {
            for (0..message.body.len / 4) |i|
                if (!finiteWord(std.mem.readInt(u32, message.body[4 * i ..][0..4], .little))) return error.InvalidSamples;
        },
        .end, .ack => {},
    }
}

pub fn profile(message: Message) Error!Format {
    try validate(message);
    if (message.kind != .offer and message.kind != .accept) return error.InvalidProfile;
    return readProfile(message.body);
}

/// Exactly one record, borrowed from bytes; trailing bytes are a caller error.
pub fn parse(bytes: []const u8) Error!Message {
    const h = try header(bytes);
    if (bytes.len != h.total) return error.InvalidLength;
    var message = h.message;
    message.body = bytes[header_size..];
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

    /// Consume through at most one record; process its borrow before the next feed.
    /// Empty input cannot spin. Malformed framing/value input permanently poisons.
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
            const count = @min(self.wanted - self.used, input.len - consumed);
            @memcpy(self.storage[self.used..][0..count], input[consumed..][0..count]);
            self.used += count;
            consumed += count;
            if (self.used < self.wanted) return .{ .consumed = consumed, .message = null };
            if (self.wanted == header_size) self.wanted = (try header(self.storage[0..header_size])).total;
            if (self.used == self.wanted) {
                const message = try parse(self.storage[0..self.used]);
                self.ready = true;
                return .{ .consumed = consumed, .message = message };
            }
        }
    }

    /// Application framing completion only; END/ACK and clean TLS close are separate.
    pub fn finish(self: *const Parser) Error!void {
        if (self.failed) return error.Poisoned;
        if (self.used != 0 and !self.ready) return error.Truncated;
    }
};

fn writeHeader(out: []u8, kind: Kind, id: StreamId, position: u64, frames: u32) Error![]u8 {
    if (!validId(id)) return error.InvalidStream;
    const body = try bodySize(kind, position, frames);
    const size = header_size + body;
    if (out.len < size) return error.ShortOutput;
    @memset(out[0..header_size], 0);
    @memcpy(out[0..4], "JCR2");
    out[4] = 2;
    out[5] = @backingInt(kind);
    std.mem.writeInt(u16, out[6..8], header_size, .big);
    std.mem.writeInt(u32, out[8..12], @intCast(body), .big);
    @memcpy(out[16..32], &id);
    std.mem.writeInt(u64, out[32..40], position, .big);
    std.mem.writeInt(u32, out[40..44], frames, .big);
    return out[0..size];
}

/// OFFER/ACCEPT only. Failure leaves the entire output unchanged.
pub fn encodeProfile(out: []u8, kind: Kind, id: StreamId, format: Format) Error![]const u8 {
    if (kind != .offer and kind != .accept) return error.InvalidHeader;
    try format.validate();
    const record = try writeHeader(out, kind, id, 0, 0);
    const b = record[header_size..];
    std.mem.writeInt(u32, b[0..4], format.sample_rate, .big);
    std.mem.writeInt(u16, b[4..6], format.channel_count, .big);
    std.mem.writeInt(u16, b[6..8], format.representation, .big);
    std.mem.writeInt(u32, b[8..12], format.max_frames, .big);
    std.mem.writeInt(u32, b[12..16], 0, .big);
    return record;
}

/// END/ACK only. A codec cannot attest receiver drain; Negotiation gates ACK.
pub fn encodeControl(out: []u8, kind: Kind, id: StreamId, position: u64) Error![]const u8 {
    if (kind != .end and kind != .ack) return error.InvalidHeader;
    return writeHeader(out, kind, id, position, 0);
}

/// Preserve finite IEEE-754 bits, including signed zero/subnormals. No rounding,
/// clipping, resampling or numeric arithmetic is performed on sample values.
pub fn encodeAudio(out: []u8, id: StreamId, position: u64, input: []const f32, format: Format) Error![]const u8 {
    try format.validate();
    if (input.len == 0 or input.len % 2 != 0 or input.len / 2 > format.max_frames) return error.InvalidSamples;
    for (input) |value| if (!finiteWord(@bitCast(value))) return error.InvalidSamples;
    const record = try writeHeader(out, .audio, id, position, @intCast(input.len / 2));
    for (input, 0..) |value, i| std.mem.writeInt(u32, record[header_size + 4 * i ..][0..4], @bitCast(value), .little);
    return record;
}

/// Prevalidate every word before publishing output. Input/output must not overlap.
pub fn decodeAudio(message: Message, output: []f32) Error!void {
    try validate(message);
    if (message.kind != .audio or output.len != @as(usize, message.frames) * 2) return error.InvalidSamples;
    for (output, 0..) |*value, i| value.* = @bitCast(std.mem.readInt(u32, message.body[4 * i ..][0..4], .little));
}
