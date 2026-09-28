//! Test-only v2 application sender or receiver, both as TLS clients on loopback.
//! Public fixture identities and frozen test time; never use as a product command.
//! Synchronous sample verification owns all media; no callbacks/devices are opened.
//! ACK therefore attests completion of this synchronous test sink only.
const std = @import("std");
const tls = @import("tls");
const core = @import("lan_audio");
const wire = core.wire_v2;
const Gate = core.Negotiation;
const net = @import("loopback_transport.zig");
const sender = @import("probe_options").sender;
const stream: wire.StreamId = .{ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16 };
const sizes = [_]u32{ 1, 17, 240, 1024, 3 };
const words = [_]u32{ 0, 0x80000000, 1, 0x80000001, 0x007fffff, 0x807fffff, 0x00800000, 0x80800000, 0x3f800000, 0xbf800000, 0x7f7fffff, 0xff7fffff };

const Reader = struct {
    parser: wire.Parser = .{},
    buffer: [2048]u8 = undefined,
    offset: usize = 0,
    used: usize = 0,

    /// Borrow lasts until next call; retain coalesced suffix and parser fragments.
    fn next(self: *Reader, network: *net.Network, driver: *tls.Driver, deadline: u64) !wire.Message {
        while (true) {
            if (self.offset < self.used) {
                const fed = try self.parser.feed(self.buffer[self.offset..self.used]);
                if (fed.consumed == 0) return error.ParserStalled;
                self.offset += fed.consumed;
                if (fed.message) |message| return message;
            } else {
                try driver.beginRead(&self.buffer, net.demo_now(), deadline);
                const result = try network.run(driver);
                if (result == .closed) {
                    try self.parser.finish();
                    return error.ChannelClosed;
                }
                if (result != .complete or result.complete == 0) return error.ReadFailed;
                self.offset = 0;
                self.used = result.complete;
            }
        }
    }
};

/// Queue copied plaintext first, then commit the candidate gate exactly once.
fn sendRecord(network: *net.Network, driver: *tls.Driver, gate: *Gate, bytes: []const u8, deadline: u64) !void {
    var candidate = gate.*;
    try candidate.apply(.outgoing, try wire.parse(bytes));
    try driver.beginWrite(bytes, net.demo_now(), deadline);
    gate.* = candidate;
    if (try network.run(driver) != .complete) return error.WriteFailed;
}

pub fn main() !void {
    if (!std.mem.eql(u8, tls.backendVersion(), "OpenSSL 3.5.8 25 Aug 2026")) return error.WrongBackend;
    var network = try net.Network.open();
    defer network.close();
    var canceled: std.atomic.Value(bool) = .init(false);
    const started = net.demo_now();
    var driver = try tls.Driver.init(.{
        .role = .client,
        .alpn = wire.alpn,
        .ca_file = "tests/fixtures/ca.pem",
        .peer = .{ .dns = std.mem.span(net.demo_name()) },
        .certificate_file = "tests/fixtures/client.pem",
        .private_key_file = "tests/fixtures/client.key",
        .wall_time_seconds = 1_789_300_000,
        .now_ms = started,
    }, .{ .context = &network, .send = net.Network.send, .recv = net.Network.recv }, &canceled);
    defer driver.deinit();
    try driver.beginHandshake(started, started + 3000);
    if (try network.run(&driver) != .complete) return error.HandshakeFailed;
    var gate = Gate.init(if (sender) .sender else .receiver);
    try gate.authorizeChannel();
    const deadline = net.demo_now() + 12000;
    var reader: Reader = .{};
    var outgoing: [wire.max_record]u8 = undefined;
    var pcm: [wire.max_samples]f32 = undefined;
    if (sender) {
        try sendRecord(&network, &driver, &gate, try wire.encodeProfile(&outgoing, .offer, stream, .{ .max_frames = 1024 }), deadline);
        try gate.apply(.incoming, try reader.next(&network, &driver, deadline));
        for (sizes) |frames| {
            const sample_count: usize = @as(usize, frames) * 2;
            for (pcm[0..sample_count], 0..) |*value, i| value.* = @bitCast(words[(gate.next_frame * 2 + i) % words.len]);
            try sendRecord(&network, &driver, &gate, try wire.encodeAudio(&outgoing, stream, gate.next_frame, pcm[0..sample_count], gate.format), deadline);
        }
        try sendRecord(&network, &driver, &gate, try wire.encodeControl(&outgoing, .end, stream, gate.next_frame), deadline);
        const ack = reader.next(&network, &driver, deadline) catch |err| return if (err == error.ChannelClosed) error.MissingAck else err;
        try gate.apply(.incoming, ack);
    } else {
        try gate.apply(.incoming, try reader.next(&network, &driver, deadline));
        try sendRecord(&network, &driver, &gate, try wire.encodeProfile(&outgoing, .accept, gate.stream, gate.format), deadline);
        while (gate.phase != .draining) {
            const message = reader.next(&network, &driver, deadline) catch |err| return if (err == error.ChannelClosed) error.MissingEnd else err;
            try gate.apply(.incoming, message);
            if (gate.next_frame > 1285) return error.FixtureExtent;
            if (message.kind == .audio) {
                const sample_count: usize = @as(usize, message.frames) * 2;
                try wire.decodeAudio(message, pcm[0..sample_count]);
                for (pcm[0..sample_count], 0..) |value, i|
                    if (@as(u32, @bitCast(value)) != words[(message.position * 2 + i) % words.len]) return error.SampleMismatch;
            }
        }
        if (reader.offset < reader.used) return error.DataAfterEnd;
        // No asynchronous owner exists in this synchronous verification sink.
        try gate.confirmDrained();
        try sendRecord(&network, &driver, &gate, try wire.encodeControl(&outgoing, .ack, gate.stream, gate.next_frame), deadline);
    }
    if (gate.phase != .complete or reader.offset < reader.used) return error.DataAfterEnd;
    try reader.parser.finish();
    try driver.beginShutdown(net.demo_now(), deadline);
    const ending = try network.run(&driver);
    if (ending == .plaintext_available) return error.DataAfterEnd;
    if (ending != .closed) return error.UncleanClose;
    std.debug.print("PASS v2 role={s} frames={d} exact_words=true clean_close=true\n", .{ if (sender) "sender" else "receiver", gate.next_frame });
}
