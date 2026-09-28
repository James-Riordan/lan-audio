//! Public fixture clocks/keys belong only here. Real Socket/Driver/host integration
//! on loopback with independent Python TLS/v2 peer. No audio devices or callbacks.
const std = @import("std");
const host = @import("verified_channel");
const net = @import("network_host");
const policy = @import("peer_policy");
const core = @import("lan_audio");
const wire = core.wire_v2;
const stream: wire.StreamId = .{ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16 };
const sizes = [_]u32{ 1, 17, 240, 1024, 3 };
const words = [_]u32{ 0, 0x80000000, 1, 0x80000001, 0x007fffff, 0x807fffff, 0x00800000, 0x80800000, 0x3f800000, 0xbf800000, 0x7f7fffff, 0xff7fffff };
fn is(a: []const u8, b: []const u8) bool {
    return std.mem.eql(u8, a, b);
}

fn exercise(connection: *host.Connection, rules: *const policy.Policy, flag: *std.atomic.Value(bool), mode: []const u8, deadline: u64) !void {
    if (is(mode, "before-handshake")) {
        _ = try connection.refresh(7, rules);
        return error.AcceptedTooEarly;
    }
    if (try connection.handshake(7, rules, deadline) != .established) return error.FirstAuthorization;
    if (is(mode, "cancel")) {
        flag.store(true, .release);
        _ = try connection.refresh(7, rules);
        return error.AcceptedCancellation;
    }
    if (is(mode, "revoke")) {
        for (0..32) |_| try connection.revoke(7);
        _ = try connection.refresh(7, rules);
        return error.AcceptedRevocation;
    }
    if (is(mode, "revision")) {
        var revised = rules.*;
        revised.revision += 1;
        _ = try connection.refresh(7, &revised);
        return error.AcceptedRevision;
    }
    var out: [wire.max_record]u8 = undefined;
    var pcm: [wire.max_samples]f32 = undefined;
    const sender = connection.channel.gate.role == .sender;
    if (sender) {
        try connection.send(7, 1, try wire.encodeProfile(&out, .offer, stream, .{ .max_frames = 1024 }), deadline);
        _ = try connection.receive(7, 1, deadline);
    } else {
        _ = try connection.receive(7, 1, deadline);
        try connection.send(7, 1, try wire.encodeProfile(&out, .accept, connection.channel.gate.stream, connection.channel.gate.format), deadline);
    }
    const snapshot = connection.channel.snapshot();
    for (0..32) |_| {
        if (try connection.handshake(7, rules, deadline) != .unchanged) return error.RepeatAuthorization;
        if (!std.meta.eql(snapshot, connection.channel.snapshot())) return error.ResetStream;
    }
    // Stale work never mutates TLS or current authorization, including cleanup.
    try std.testing.expectError(error.StaleGeneration, connection.refresh(6, rules));
    try std.testing.expectError(error.StaleGeneration, connection.handshake(6, rules, deadline));
    try std.testing.expectError(error.StaleGeneration, connection.send(6, 1, "bad", deadline));
    try std.testing.expectError(error.StaleGeneration, connection.receive(6, 1, deadline));
    try std.testing.expectError(error.StaleGeneration, connection.confirmDrained(6, 1));
    try std.testing.expectError(error.StaleGeneration, connection.finish(6, 1, deadline));
    try std.testing.expectError(error.StaleGeneration, connection.revoke(6));
    if (!std.meta.eql(snapshot, connection.channel.snapshot())) return error.StaleMutation;
    if (is(mode, "current-revision")) {
        try connection.send(7, 2, "bad", deadline);
        return error.AcceptedRevision;
    }
    if (sender) {
        for (sizes) |frames| {
            const position = connection.channel.gate.next_frame;
            for (pcm[0 .. frames * 2], 0..) |*sample, i| sample.* = @bitCast(words[(position * 2 + i) % words.len]);
            try connection.send(7, 1, try wire.encodeAudio(&out, stream, position, pcm[0 .. frames * 2], connection.channel.gate.format), deadline);
        }
        try connection.send(7, 1, try wire.encodeControl(&out, .end, stream, 1285), deadline);
        _ = try connection.receive(7, 1, deadline);
    } else {
        var consumed: u64 = 0;
        while (connection.channel.gate.phase != .draining) {
            const message = try connection.receive(7, 1, deadline);
            if (message.kind == .audio) {
                if (consumed + message.frames > 1285) return error.Extent;
                for (0..message.body.len / 4) |i| {
                    const word = std.mem.readInt(u32, message.body[i * 4 ..][0..4], .little);
                    if (word != words[(consumed * 2 + i) % words.len]) return error.SampleMismatch;
                }
                consumed += message.frames;
            }
        }
        if (consumed != 1285) return error.IncompleteDrain;
        // Synchronous in-memory verifier only; all received words consumed above.
        for (0..32) |_| try connection.confirmDrained(7, 1);
        try connection.send(7, 1, try wire.encodeControl(&out, .ack, stream, consumed), deadline);
    }
    if (connection.channel.gate.phase != .complete) return error.Incomplete;
    try connection.finish(7, 1, deadline);
    try std.testing.expectError(error.Revoked, connection.refresh(7, rules));
}

pub fn main(init: std.process.Init) !void {
    const args = try init.minimal.args.toSlice(init.arena.allocator());
    if (args.len != 7) return error.Arguments;
    const server = is(args[1], "server");
    const sender = is(args[2], "sender");
    const mode = args[3];
    const port = try std.fmt.parseInt(u16, args[4], 10);
    const expected = try policy.parseFingerprint(args[5]);
    const ipv6 = is(args[6], "ipv6");
    var socket: net.Socket = .{};
    defer socket.close() catch @panic("fixture socket close failed");
    var flag: std.atomic.Value(bool) = .init(false);
    const deadline = try net.nowMilliseconds() + (if (is(mode, "deadline")) @as(u64, 800) else @as(u64, 8000));
    const endpoint: net.Endpoint = .{ .address = if (ipv6) "::1" else "127.0.0.1", .port = port };
    if (server) {
        var listener: net.Socket = .{};
        defer listener.close() catch @panic("fixture listener close failed");
        try listener.init(if (ipv6) .ipv6 else .ipv4);
        try listener.listen(endpoint, 1);
        var line: [64]u8 = undefined;
        try std.Io.File.stdout().writeStreamingAll(init.io, try std.fmt.bufPrint(&line, "READY {d}\n", .{try listener.localPort()}));
        while (!try listener.accept(&socket)) try listener.wait(.input, deadline, &flag);
    } else {
        try socket.init(if (ipv6) .ipv6 else .ipv4);
        if (!try socket.connect(endpoint)) {
            while (true) {
                try socket.wait(.output, deadline, &flag);
                if (try socket.finishConnect()) break;
            }
        }
    }
    var selected = expected;
    if (is(mode, "wrong-peer")) selected[0] ^= 1;
    const allowed_sender = if (is(mode, "wrong-role")) sender else !sender;
    const rule: policy.Rule = .{ .peer = expected, .roles = .{ .sender = allowed_sender, .receiver = !allowed_sender } };
    const rules = try policy.Policy.init(1, if (is(mode, "unapproved")) &.{} else &.{rule});
    var connection = try host.Connection.init(&socket, .{
        .transport_role = if (server) .server else .client,
        .local_role = if (sender) .sender else .receiver,
        .generation = 7,
        .expected_peer = selected,
        .ca_file = "tests/fixtures/ca.pem",
        .certificate_file = if (server) "tests/fixtures/server.pem" else "tests/fixtures/client.pem",
        .private_key_file = if (server) "tests/fixtures/server.key" else "tests/fixtures/client.key",
        .reference_identity = if (server) null else .{ .dns = if (is(mode, "wrong-name")) "wrong.example" else "localhost" },
        .wall_time_seconds = if (is(mode, "expired")) 2_200_000_000 else 1_789_300_000,
        .now_ms = try net.nowMilliseconds(),
    }, &flag);
    defer connection.deinit();
    exercise(&connection, &rules, &flag, mode, deadline) catch |err| {
        // Host errors must revoke TLS and permission before this explicit cleanup.
        std.debug.print("REJECT {s} revoked={any} tls_released={any}\n", .{ @errorName(err), connection.channel.revoked, connection.driver.engine.handle == null });
        std.process.exit(if (connection.channel.revoked and connection.driver.engine.handle == null) 1 else 3);
    };
    for (0..32) |_| connection.deinit();
    std.debug.print("PASS verified frames=1285 exact_words=true clean_close=true repeat=32 stale=7\n", .{});
}
