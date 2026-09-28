//! Windows loopback-only integration probe. Uses public tls-zig test credentials,
//! an explicit private CA, mTLS, project ALPN and a single absolute transfer deadline.
//! Not a product CLI. Peer PCM crosses the queue into an explicit silent callback.
const std = @import("std");
const tls = @import("tls");
const core = @import("lan_audio");
const audio = @import("audio_host");
const wire = core.wire;
extern fn demo_open() isize;
extern fn demo_close(socket: isize) void;
extern fn demo_send(socket: isize, bytes: [*]const u8, len: c_int) c_int;
extern fn demo_recv(socket: isize, bytes: [*]u8, len: c_int) c_int;
extern fn demo_poll(socket: isize, writing: c_int, timeout_ms: u32) c_int;
extern fn demo_now() u64;
extern fn demo_name() [*:0]const u8;

const Network = struct {
    socket: isize,
    fn send(context: *anyopaque, bytes: []const u8) error{TransportFailure}!?usize {
        const self: *Network = @ptrCast(@alignCast(context));
        const n = demo_send(self.socket, bytes.ptr, @intCast(bytes.len));
        if (n == -2) return null;
        if (n < 0) return error.TransportFailure;
        return @intCast(n);
    }
    fn recv(context: *anyopaque, bytes: []u8) error{TransportFailure}!?usize {
        const self: *Network = @ptrCast(@alignCast(context));
        const n = demo_recv(self.socket, bytes.ptr, @intCast(bytes.len));
        if (n == -2) return null;
        if (n < 0) return error.TransportFailure;
        return @intCast(n);
    }
    fn run(self: *Network, driver: *tls.Driver) !tls.host.Result {
        while (true) {
            const result = try driver.step(demo_now());
            switch (result) {
                .again => {},
                .wait_input, .wait_output => {
                    const now = demo_now();
                    if (now >= driver.deadline_ms) continue;
                    const timeout: u32 = @intCast(@min(25, driver.deadline_ms - now));
                    if (demo_poll(self.socket, @intFromBool(result == .wait_output), timeout) < 0) return error.SocketPoll;
                },
                else => return result,
            }
        }
    }
};

pub fn main() !void {
    if (!std.mem.eql(u8, tls.backendVersion(), "OpenSSL 3.5.8 25 Aug 2026")) return error.WrongBackend;
    var network: Network = .{ .socket = demo_open() };
    if (network.socket == -1) return error.SocketConnect;
    defer demo_close(network.socket);
    var canceled: std.atomic.Value(bool) = .init(false);
    const started = demo_now();
    var driver = try tls.Driver.init(.{
        .role = .client,
        .alpn = wire.alpn,
        .ca_file = "tests/fixtures/ca.pem",
        .peer = .{ .dns = std.mem.span(demo_name()) },
        .certificate_file = "tests/fixtures/client.pem",
        .private_key_file = "tests/fixtures/client.key",
        .wall_time_seconds = 1_789_300_000,
        .now_ms = started,
    }, .{ .context = &network, .send = Network.send, .recv = Network.recv }, &canceled);
    defer driver.deinit();
    try driver.beginHandshake(started, started + 3000);
    if (try network.run(&driver) != .complete) return error.HandshakeFailed;

    var device: audio.AudioDevice = .{};
    try device.init(.null_playback);
    defer device.deinit();
    try device.start();

    var receiver: core.Receiver(12) = .{};
    try receiver.authorizeChannel();
    var parser: wire.Parser = .{};
    var incoming: [2048]u8 = undefined;
    var pcm: [wire.samples]f32 = undefined;
    var blocks: u64 = 0;
    var checksum: i64 = 0;
    const transfer_deadline = demo_now() + 4000;
    while (!receiver.ended) {
        try driver.beginRead(&incoming, demo_now(), transfer_deadline);
        const result = try network.run(&driver);
        if (result == .closed) {
            try parser.finish();
            return error.MissingEnd;
        }
        if (result != .complete or result.complete == 0) return error.ReadFailed;
        var offset: usize = 0;
        while (offset < result.complete) {
            if (receiver.ended) return error.DataAfterEnd;
            const fed = try parser.feed(incoming[offset..result.complete]);
            if (fed.consumed == 0) return error.ParserStalled;
            offset += fed.consumed;
            if (fed.message) |message| {
                try receiver.accept(message);
                if (message.kind == .audio) {
                    if (try receiver.tick(&pcm) != .media) return error.UnexpectedGap;
                    for (pcm) |value| checksum += @as(i64, @intFromFloat(value * 32768));
                    var submitted: usize = 0;
                    while (submitted < wire.samples / 2) {
                        if (demo_now() >= transfer_deadline) return error.OperationDeadline;
                        const count = device.bridge.playback.write(pcm[submitted * 2 ..]);
                        submitted += count;
                        if (count == 0) std.Thread.yield() catch {};
                    }
                    blocks += 1;
                }
            }
        }
    }
    try parser.finish();
    // Queue release follows the callback's last copy; device teardown below is the
    // join boundary for counters. Neither fact asserts acoustic delivery.
    while (device.bridge.playback.producerPending() != 0) {
        if (demo_now() >= transfer_deadline) return error.OperationDeadline;
        std.Thread.yield() catch {};
    }
    try device.stop();
    device.deinit();
    if (device.bridge.rendered_frames != blocks * wire.samples / 2) return error.CallbackFrameMismatch;
    var acknowledgement: [wire.header_size]u8 = undefined;
    const ack = try wire.encodeAck(&acknowledgement, receiver.stream.?, receiver.window.next);
    try driver.beginWrite(ack, demo_now(), transfer_deadline);
    if (try network.run(&driver) != .complete) return error.WriteFailed;
    try driver.beginShutdown(demo_now(), transfer_deadline);
    const ending = try network.run(&driver);
    if (ending == .plaintext_available) return error.DataAfterEnd;
    if (ending != .closed) return error.UncleanClose;
    std.debug.print("PASS audio TLS probe: blocks={d} samples={d} checksum={d} clean_close=true\n", .{ blocks, blocks * wire.samples, checksum });
    std.debug.print("callback_frames={d} silent_frames={d} backend=null\n", .{ device.bridge.rendered_frames, device.bridge.silent_frames });
}
