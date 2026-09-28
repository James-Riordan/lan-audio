// Engineering contract (2026-09-26)
// External package consumer exercising client/server TLS and early-response upload probing.
// File contract: docs/reference/files/examples/consumer/main.zig.md
// Ownership and invariant: Uses public fixtures, frozen certificate time and small bounded HTTP
// messages. Cancellation thread signals a flag; engine remains serialized. Upload gates after 17
// ciphertext bytes and finishes the accepted block before response commit.
// Next implementation obligation: Do not copy this fixed-response parser into a general HTTP
// client. Preserve exact request/response and authenticated close oracles. Add consumer-specific
// framing and total upload deadlines in the actual application.

const std = @import("std");
const tls = @import("tls");
extern fn demo_open() isize;
extern fn demo_accept() isize;
extern fn demo_close(socket: isize) void;
extern fn demo_send(socket: isize, bytes: [*]const u8, len: c_int) c_int;
extern fn demo_recv(socket: isize, bytes: [*]u8, len: c_int) c_int;
extern fn demo_poll(socket: isize, writing: c_int, timeout_ms: u32) c_int;
extern fn demo_now() u64;
extern fn demo_name() [*:0]const u8;
extern fn demo_client_ca() [*:0]const u8;
extern fn demo_sleep(ms: u32) void;
extern fn demo_setting(name: [*:0]const u8, fallback: u32) u32;

const Network = struct {
    socket: isize,
    gate_output: bool = false,
    gate_budget: usize = 0,
    fn send(context: *anyopaque, bytes: []const u8) error{TransportFailure}!?usize {
        const self: *Network = @ptrCast(@alignCast(context));
        if (self.gate_output and self.gate_budget == 0) return null;
        const len = if (self.gate_output) @min(bytes.len, self.gate_budget) else bytes.len;
        const n = demo_send(self.socket, bytes.ptr, @intCast(len));
        if (n == -2) return null;
        if (n < 0) return error.TransportFailure;
        if (self.gate_output) self.gate_budget -= @intCast(n);
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
                .again => {}, // A multi-connection host yields fairly here.
                .wait_input, .wait_output => {
                    const now = demo_now();
                    if (now >= driver.deadline_ms) continue;
                    const timeout: u32 = @intCast(@min(25, driver.deadline_ms - now));
                    if (demo_poll(self.socket, @intFromBool(result == .wait_output), timeout) < 0)
                        return error.SocketPoll;
                },
                else => return result,
            }
        }
    }
};
fn cancelLater(flag: *std.atomic.Value(bool), ms: u32) void {
    demo_sleep(ms);
    flag.store(true, .release);
}

pub fn main() !void {
    if (!std.mem.eql(u8, tls.backendVersion(), "OpenSSL 3.5.8 25 Aug 2026")) return error.WrongBackend;
    if (demo_setting("TLS_DEMO_SERVER", 0) != 0) return serve();
    var network: Network = .{ .socket = demo_open() };
    if (network.socket == -1) return error.SocketConnect;
    defer demo_close(network.socket);
    var canceled: std.atomic.Value(bool) = .init(false);
    const started = demo_now();
    var driver = try tls.Driver.init(.{ .role = .client, .ca_file = "tests/fixtures/ca.pem", .peer = .{ .dns = std.mem.span(demo_name()) }, .wall_time_seconds = 1_789_300_000, .now_ms = started }, .{ .context = &network, .send = Network.send, .recv = Network.recv }, &canceled);
    defer driver.deinit();
    try driver.beginHandshake(started, started + 3000);
    if (try network.run(&driver) != .complete) return error.HandshakeFailed;
    try verifyFixturePeer(&driver.engine, "67495f2574f958a9106517e3e93532030ed3569fced3f46a63183dfea13ecacd");
    if (demo_setting("TLS_DEMO_UPLOAD_PROBE", 0) != 0) return upload(&network, &driver, &canceled);
    const now = demo_now();
    try driver.beginWrite("GET / HTTP/1.1\r\nHost: localhost\r\n\r\n", now, now + 3000);
    if (try network.run(&driver) != .complete) return error.WriteFailed;

    // Cancellation is signaled by a different thread; Engine stays on this thread.
    const cancel_ms = demo_setting("TLS_DEMO_CANCEL_MS", 0);
    const canceler: ?std.Thread = if (cancel_ms == 0) null else try std.Thread.spawn(.{}, cancelLater, .{ &canceled, cancel_ms });
    defer if (canceler) |thread| thread.join();
    const close_deadline = demo_now() + demo_setting("TLS_DEMO_TIMEOUT_MS", 3000);
    var response: [512]u8 = undefined;
    var used: usize = 0;
    while (true) {
        try driver.beginShutdown(demo_now(), close_deadline);
        switch (try network.run(&driver)) {
            .closed => break,
            .plaintext_available => {
                if (used == response.len) return error.ResponseTooLarge;
                try driver.beginRead(response[used..], demo_now(), close_deadline);
                const result = try network.run(&driver);
                if (result != .complete or result.complete == 0) return error.ReadFailed;
                used += result.complete;
            },
            else => return error.UnexpectedProgress,
        }
    }
    if (!std.mem.eql(u8, response[0..used], "HTTP/1.1 200 OK\r\nContent-Length: 5\r\n\r\nhello")) return error.WrongResponse;
    std.debug.print("PASS external Zig consumer: TCP response and authenticated close_notify\n", .{});
}

// Deterministic would-block injection over a real TCP connection. The accepted
// TLS record is deliberately only partly sent when the peer response arrives.
fn upload(network: *Network, driver: *tls.Driver, canceled: *std.atomic.Value(bool)) !void {
    const deadline = demo_now() + demo_setting("TLS_DEMO_UPLOAD_MS", 3000);
    try driver.beginWrite("POST / HTTP/1.1\r\nHost: localhost\r\nContent-Length: 32768\r\n\r\n", demo_now(), deadline);
    if (try network.run(driver) != .complete) return error.WriteFailed;
    network.gate_output = true;
    network.gate_budget = 17;
    const body: [16384]u8 = @splat(0x6b);
    try driver.beginWrite(&body, demo_now(), deadline);
    const cancel_ms = demo_setting("TLS_DEMO_CANCEL_MS", 0);
    const canceler: ?std.Thread = if (cancel_ms == 0) null else try std.Thread.spawn(.{}, cancelLater, .{ canceled, cancel_ms });
    defer if (canceler) |thread| thread.join();
    var response: [512]u8 = undefined;
    var used: usize = 0;
    var saw_early = false;
    while (true) {
        // Complete SSL_write retries first. Only the encrypted send is blocked.
        const progress = try driver.step(demo_now());
        if (progress == .complete) break;
        if (progress != .wait_output) continue;
        if (!saw_early) {
            while (true) {
                if (used == response.len) return error.ResponseTooLarge;
                switch (try driver.probePeer(response[used..], demo_now(), deadline + 9000)) {
                    .again => continue,
                    .data => |n| {
                        used += n;
                        if (std.mem.indexOf(u8, response[0..used], "\r\n\r\n") != null) {
                            saw_early = true;
                            if (network.gate_budget != 0) return error.ProbeNotBackpressured;
                            std.debug.print("OBSERVED early final headers with accepted block pending\n", .{});
                            break;
                        }
                    },
                    .no_data, .write_pending, .output_pending => break,
                    .closed => return error.PrematureClose,
                }
            }
        }
        if (saw_early and demo_setting("TLS_DEMO_HOLD_OUTPUT", 0) == 0) network.gate_output = false;
        if (network.gate_output) demo_sleep(1);
    }
    if (!saw_early) return error.MissedEarlyResponse;
    // No second block is queued. Finish the response and authenticate closure.
    const close_deadline = demo_now() + demo_setting("TLS_DEMO_TIMEOUT_MS", 3000);
    while (true) {
        try driver.beginShutdown(demo_now(), close_deadline);
        switch (try network.run(driver)) {
            .closed => break,
            .plaintext_available => {
                if (used == response.len) return error.ResponseTooLarge;
                try driver.beginRead(response[used..], demo_now(), close_deadline);
                const result = try network.run(driver);
                if (result != .complete or result.complete == 0) return error.ReadFailed;
                used += result.complete;
            },
            else => return error.UnexpectedProgress,
        }
    }
    if (!std.mem.eql(u8, response[0..used], "HTTP/1.1 413 Content Too Large\r\nContent-Length: 5\r\n\r\nhello")) return error.WrongResponse;
    std.debug.print("PASS early response: one accepted block, no second block, authenticated close_notify\n", .{});
}

fn serve() !void {
    var network: Network = .{ .socket = demo_accept() };
    if (network.socket == -1) return error.SocketAccept;
    defer demo_close(network.socket);
    const started = demo_now();
    var driver = try tls.Driver.init(.{
        .role = .server,
        .certificate_file = "tests/fixtures/server.pem",
        .private_key_file = "tests/fixtures/server.key",
        .ca_file = std.mem.span(demo_client_ca()),
        .require_client_certificate = true,
        .wall_time_seconds = 1_789_300_000,
        .now_ms = started,
    }, .{ .context = &network, .send = Network.send, .recv = Network.recv }, null);
    defer driver.deinit();
    try driver.beginHandshake(started, started + 3000);
    if (try network.run(&driver) != .complete) return error.HandshakeFailed;
    try verifyFixturePeer(&driver.engine, "26d690e9a54cdd8d90e428fe02651762248a5f3728534a8c680f87152775e5cf");
    var request: [256]u8 = undefined;
    var used: usize = 0;
    const request_deadline = demo_now() + 3000;
    while (std.mem.indexOf(u8, request[0..used], "\r\n\r\n") == null) {
        if (used == request.len) return error.RequestTooLarge;
        try driver.beginRead(request[used..], demo_now(), request_deadline);
        const result = try network.run(&driver);
        if (result != .complete or result.complete == 0) return error.ReadFailed;
        used += result.complete;
    }
    if (!std.mem.eql(u8, request[0..used], "GET / HTTP/1.1\r\nHost: localhost\r\n\r\n")) return error.WrongRequest;
    const reply = "HTTP/1.1 200 OK\r\nContent-Length: 5\r\n\r\nhello";
    const response_deadline = demo_now() + 3000;
    var sent: usize = 0;
    while (sent < reply.len) {
        const end = @min(sent + 3, reply.len);
        try driver.beginWrite(reply[sent..end], demo_now(), response_deadline);
        const result = try network.run(&driver);
        if (result != .complete or result.complete != end - sent) return error.WriteFailed;
        sent = end;
    }
    try driver.beginShutdown(demo_now(), demo_now() + 3000);
    if (try network.run(&driver) != .closed) return error.UnexpectedProgress;
    std.debug.print("PASS external Zig server: mTLS HTTP response and authenticated close_notify\n", .{});
}

// Fixture-only policy demonstrates the public copy API. Real applications own
// enrollment, roles, allowlists, renewal and connection generation lifetimes.
fn verifyFixturePeer(engine: *const tls.Engine, comptime hex: []const u8) !void {
    var expected: [32]u8 = undefined;
    _ = try std.fmt.hexToBytes(&expected, hex);
    const actual = try engine.verifiedPeerLeafSha256();
    if (!std.mem.eql(u8, &expected, &actual)) return error.WrongPeerFingerprint;
}
