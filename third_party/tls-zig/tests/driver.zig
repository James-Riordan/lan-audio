// Engineering contract (2026-09-26)
// Executable regression suite for driver.
// File contract: docs/reference/files/tests/driver.zig.md
// Ownership and invariant: Tests use explicit expected values and failure-path state comparisons.
// Test discovery depends on the owning build/root imports; names alone are not evidence that a
// test ran. Imports: std, tls.
// Next implementation obligation: Retain every named regression below. Add a minimized
// counterexample for changed behavior, including state before/after failure and externally visible
// output. Avoid generating expected wire bytes with the implementation being tested.
// Verification: tests/driver.zig

const std = @import("std");
const tls = @import("tls");
const expect = std.testing.expect;
const equal = std.testing.expectEqual;
const expectError = std.testing.expectError;
const Result = tls.host.Result;
const Pipe = struct {
    bytes: [131072]u8 = undefined,
    start: usize = 0,
    end: usize = 0,
    eof: bool = false,
};
const Socket = struct {
    incoming: *Pipe,
    outgoing: *Pipe,
    send_limit: usize = 7,
    recv_limit: usize = 113,
    sends: usize = 0,
    recvs: usize = 0,
    block_send: bool = false,
    block_recv: bool = false,
    invalid_send: bool = false,
    invalid_recv: bool = false,
    fn transport(self: *Socket) tls.host.Transport {
        return .{ .context = self, .send = send, .recv = recv };
    }
    fn send(context: *anyopaque, bytes: []const u8) error{TransportFailure}!?usize {
        const self: *Socket = @ptrCast(@alignCast(context));
        self.sends += 1;
        if (self.invalid_send) return bytes.len + 1;
        if (self.block_send or self.sends % 2 == 0) return null;
        const pipe = self.outgoing;
        if (pipe.start == pipe.end) {
            pipe.start = 0;
            pipe.end = 0;
        }
        const n = @min(bytes.len, self.send_limit, pipe.bytes.len - pipe.end);
        if (n == 0) return null;
        @memcpy(pipe.bytes[pipe.end..][0..n], bytes[0..n]);
        pipe.end += n;
        return n;
    }
    fn recv(context: *anyopaque, buffer: []u8) error{TransportFailure}!?usize {
        const self: *Socket = @ptrCast(@alignCast(context));
        self.recvs += 1;
        if (self.invalid_recv) return buffer.len + 1;
        if (self.block_recv or self.recvs % 2 == 0) return null;
        const pipe = self.incoming;
        const n = @min(buffer.len, self.recv_limit, pipe.end - pipe.start);
        if (n == 0) return if (pipe.eof) 0 else null;
        @memcpy(buffer[0..n], pipe.bytes[pipe.start..][0..n]);
        pipe.start += n;
        return n;
    }
};
const Pair = struct {
    to_client: Pipe = .{},
    to_server: Pipe = .{},
    client_socket: Socket = undefined,
    server_socket: Socket = undefined,
    client: tls.Driver = undefined,
    server: tls.Driver = undefined,
    canceled: std.atomic.Value(bool) = .init(false),
    fn init(self: *Pair) !void {
        self.client_socket = .{ .incoming = &self.to_client, .outgoing = &self.to_server };
        self.server_socket = .{ .incoming = &self.to_server, .outgoing = &self.to_client };
        self.client = try tls.Driver.init(.{ .role = .client, .ca_file = "tests/fixtures/ca.pem", .peer = .{ .dns = "localhost" }, .wall_time_seconds = 1_789_300_000, .now_ms = 100 }, self.client_socket.transport(), &self.canceled);
        errdefer self.client.deinit();
        self.server = try tls.Driver.init(.{ .role = .server, .certificate_file = "tests/fixtures/server.pem", .private_key_file = "tests/fixtures/server.key", .wall_time_seconds = 1_789_300_000, .now_ms = 100 }, self.server_socket.transport(), null);
    }
    fn deinit(self: *Pair) void {
        self.client.deinit();
        self.server.deinit();
    }
    fn handshake(self: *Pair) !void {
        try self.client.beginHandshake(100, 10000);
        try self.server.beginHandshake(100, 10000);
        var client_done = false;
        var server_done = false;
        for (0..50000) |_| {
            if (!client_done) client_done = (try self.client.step(101)) == .complete;
            if (!server_done) server_done = (try self.server.step(101)) == .complete;
            if (client_done and server_done) return;
        }
        return error.HandshakeStalled;
    }
};
fn finish(driver: *tls.Driver) !Result {
    for (0..100000) |_| {
        const result = try driver.step(102);
        switch (result) {
            .again, .wait_input, .wait_output => {},
            else => return result,
        }
    }
    return error.OperationStalled;
}

fn probe(driver: *tls.Driver, buffer: []u8) !tls.host.ProbeResult {
    for (0..10000) |_| {
        const result = try driver.probePeer(buffer, 102, 9000);
        if (result != .again) return result;
    }
    return error.ProbeStalled;
}

test "peer probe observes early response without changing blocked ciphertext or deadline" {
    var pair: Pair = .{};
    try pair.init();
    defer pair.deinit();
    try pair.handshake();
    var response: [128]u8 = undefined;
    try equal(.no_data, try probe(&pair.client, &response));
    try expect(pair.client.active == null);
    var body: [16384]u8 = @splat(0x6b);
    try pair.client.beginWrite(&body, 102, 500);
    try equal(.write_pending, try probe(&pair.client, &response));
    for (0..20) |_| {
        _ = try pair.client.step(102);
        if (pair.client.output_start > 0) break;
    }
    try expect(pair.client.output_start > 0 and pair.client.output_start < pair.client.output_end);
    pair.client_socket.block_send = true;
    const start = pair.client.output_start;
    const end = pair.client.output_end;
    const ciphertext = pair.client.output;
    @memset(&body, 0); // Driver/Engine owns the accepted write, including retries.
    const early = "HTTP/1.1 413 Content Too Large\r\nContent-Length: 0\r\n\r\n";
    try pair.server.beginWrite(early, 102, 1000);
    _ = try finish(&pair.server);
    var received: usize = 0;
    for (0..10000) |_| {
        const r = try probe(&pair.client, response[received..]);
        if (r == .data) received += r.data;
        if (received == early.len) break;
    }
    try std.testing.expectEqualStrings(early, response[0..received]);
    try equal(@as(u64, 500), pair.client.deadline_ms);
    try equal(start, pair.client.output_start);
    try equal(end, pair.client.output_end);
    try std.testing.expectEqualSlices(u8, ciphertext[start..end], pair.client.output[start..end]);
    try expect(pair.client.active.? == .write);
    try equal(.wait_output, try pair.client.step(102));
    pair.client_socket.block_send = false;
    try equal(@as(usize, body.len), (try finish(&pair.client)).complete);
    try pair.server.beginRead(&body, 102, 1000);
    try equal(@as(usize, body.len), (try finish(&pair.server)).complete);
    for (body) |byte| try equal(@as(u8, 0x6b), byte);
}

test "peer probe during blocked write honors cancel deadline and raw EOF" {
    for (0..3) |mode| {
        var pair: Pair = .{};
        try pair.init();
        defer pair.deinit();
        try pair.handshake();
        pair.client_socket.block_send = true;
        try pair.client.beginWrite("accepted upload", 102, 200);
        for (0..20) |_| if (try pair.client.step(102) == .wait_output) break;
        var bytes: [32]u8 = undefined;
        if (mode == 0) {
            pair.canceled.store(true, .release);
            try expectError(error.Canceled, pair.client.probePeer(&bytes, 102, 9000));
        } else if (mode == 1) {
            try expectError(error.OperationDeadline, pair.client.probePeer(&bytes, 200, 9000));
        } else {
            pair.to_client.eof = true;
            var failed = false;
            for (0..100) |_| {
                _ = probe(&pair.client, &bytes) catch |err| {
                    try equal(error.TlsFailure, err);
                    failed = true;
                    break;
                };
            }
            try expect(failed);
        }
    }
}

test "idle probe output flush preserves order before next application write" {
    var pair: Pair = .{};
    try pair.init();
    defer pair.deinit();
    try pair.handshake();
    // Arrange pending encrypted output before an idle probe, as can happen with
    // TLS protocol output. The public fixture Engine produces real valid records.
    try pair.client.engine.queuePlaintext("first");
    _ = try pair.client.engine.flushPlaintext();
    var bytes: [32]u8 = undefined;
    try equal(.output_pending, try probe(&pair.client, &bytes));
    try expect(pair.client.output_end > pair.client.output_start);
    try pair.client.beginFlush(102, 1000);
    try equal(@as(usize, 0), (try finish(&pair.client)).complete);
    try pair.client.beginWrite("second", 102, 1000);
    _ = try finish(&pair.client);
    try pair.server.beginRead(&bytes, 102, 1000);
    const first = (try finish(&pair.server)).complete;
    try std.testing.expectEqualStrings("first", bytes[0..first]);
    try pair.server.beginRead(&bytes, 102, 1000);
    const second = (try finish(&pair.server)).complete;
    try std.testing.expectEqualStrings("second", bytes[0..second]);
}

test "host driver preserves partial writes and received suffixes across reads" {
    var pair: Pair = .{};
    try pair.init();
    defer pair.deinit();
    try pair.handshake();
    // Queue enough encrypted records for one socket recv to exceed feed's 16KiB.
    pair.server_socket.recv_limit = 32768;
    var block: [16384]u8 = @splat(0x5a);
    for (0..3) |_| {
        try pair.client.beginWrite(&block, 102, 20000);
        @memset(&block, 0); // Retry data belongs to Engine, not this caller buffer.
        try equal(@as(usize, 16384), (try finish(&pair.client)).complete);
        @memset(&block, 0x5a);
    }
    var total: usize = 0;
    var saw_suffix = false;
    var plain: [1009]u8 = undefined;
    while (total < 3 * 16384) {
        try pair.server.beginRead(&plain, 102, 20000);
        try expectError(error.OperationInProgress, pair.server.beginRead(&plain, 102, 20000));
        const n = (try finish(&pair.server)).complete;
        try expect(n > 0);
        for (plain[0..n]) |byte| try equal(@as(u8, 0x5a), byte);
        total += n;
        saw_suffix = saw_suffix or pair.server.input_start < pair.server.input_end;
    }
    try equal(@as(usize, 49152), total);
    try expect(saw_suffix);
    try expect(pair.client_socket.sends > 100);
}

test "host shutdown preserves deadline across final plaintext reads and rejects raw EOF" {
    for ([_]bool{ false, true }) |clean| {
        var pair: Pair = .{};
        try pair.init();
        defer pair.deinit();
        try pair.handshake();
        try pair.server.beginWrite("final response", 102, 1000);
        _ = try finish(&pair.server);
        if (clean) {
            try pair.server.beginShutdown(102, 1000);
            // Deliver the server's close_notify, stopping when it needs peer input.
            for (0..10000) |_| if (try pair.server.step(102) == .wait_input) break;
        } else pair.to_client.eof = true;
        try pair.client.beginShutdown(102, 500);
        try equal(.plaintext_available, try finish(&pair.client));
        var response: [64]u8 = undefined;
        try pair.client.beginRead(&response, 102, 9000);
        try equal(@as(u64, 500), pair.client.deadline_ms);
        const n = (try finish(&pair.client)).complete;
        try std.testing.expectEqualStrings("final response", response[0..n]);
        try pair.client.beginShutdown(102, 9000);
        try equal(@as(u64, 500), pair.client.deadline_ms);
        if (clean) {
            try equal(.closed, try finish(&pair.client));
            try equal(.closed, try finish(&pair.server));
        } else try expectError(error.TlsFailure, finish(&pair.client));
    }
}

test "host operation deadline expires despite slow transport progress" {
    var pair: Pair = .{};
    try pair.init();
    defer pair.deinit();
    try pair.handshake();
    try pair.client.beginWrite("write must not extend its deadline", 102, 110);
    for (102..110) |tick| _ = try pair.client.step(tick);
    try expect(pair.client_socket.sends > 0);
    const calls = pair.client_socket.sends;
    try expectError(error.OperationDeadline, pair.client.step(110));
    try equal(calls, pair.client_socket.sends);
    try expect(pair.client.engine.handle == null);
    try expectError(error.OperationDeadline, pair.client.step(111));
}

test "atomic cancellation stops blocked reads and writes without touching transport" {
    for ([_]bool{ false, true }) |write| {
        var pair: Pair = .{};
        try pair.init();
        defer pair.deinit();
        try pair.handshake();
        var plain: [8]u8 = undefined;
        if (write) {
            pair.client_socket.block_send = true;
            try pair.client.beginWrite("blocked", 102, 1000);
        } else {
            pair.client_socket.block_recv = true;
            try pair.client.beginRead(&plain, 102, 1000);
        }
        for (0..20) |_| {
            const result = try pair.client.step(102);
            if (result == .wait_input or result == .wait_output) break;
        }
        const sends = pair.client_socket.sends;
        const recvs = pair.client_socket.recvs;
        pair.canceled.store(true, .release);
        try expectError(error.Canceled, pair.client.step(103));
        try expectError(error.Canceled, pair.client.beginRead(&plain, 103, 1000));
        try expectError(error.Canceled, pair.client.beginWrite("again", 103, 1000));
        try equal(sends, pair.client_socket.sends);
        try equal(recvs, pair.client_socket.recvs);
        try expect(pair.client.engine.handle == null);
    }
}

test "host cannot extend a shutdown deadline by switching to read" {
    var pair: Pair = .{};
    try pair.init();
    defer pair.deinit();
    try pair.handshake();
    try pair.server.beginWrite("final data, no close", 102, 1000);
    _ = try finish(&pair.server);
    try pair.client.beginShutdown(102, 150);
    try equal(.plaintext_available, try finish(&pair.client));
    var plain: [64]u8 = undefined;
    try pair.client.beginRead(&plain, 102, 9000);
    _ = try finish(&pair.client);
    try expectError(error.OperationDeadline, pair.client.beginShutdown(150, 9000));
    try expect(pair.client.engine.handle == null);
}

test "host rejects invalid transport counts and backward clocks" {
    for ([_]bool{ false, true }) |write| {
        var pair: Pair = .{};
        try pair.init();
        defer pair.deinit();
        try pair.handshake();
        var plain: [8]u8 = undefined;
        if (write) {
            pair.client_socket.invalid_send = true;
            try pair.client.beginWrite("bad transport", 102, 1000);
        } else {
            pair.client_socket.invalid_recv = true;
            try pair.client.beginRead(&plain, 102, 1000);
        }
        try expectError(error.InvalidState, pair.client.step(101));
        try expectError(error.TransportContract, finish(&pair.client));
        try expect(pair.client.engine.handle == null);
    }
}

test "host authentication failure flushes fragmented alert and retains diagnostics" {
    var pair: Pair = .{};
    try pair.init();
    defer pair.deinit();
    pair.client.deinit();
    pair.client = try tls.Driver.init(.{ .role = .client, .ca_file = "tests/fixtures/ca.pem", .peer = .{ .dns = "wrong.example" }, .wall_time_seconds = 1_789_300_000, .now_ms = 100 }, pair.client_socket.transport(), &pair.canceled);
    try pair.client.beginHandshake(100, 10000);
    try pair.server.beginHandshake(100, 10000);
    var client_error: ?tls.host.Error = null;
    var server_error: ?tls.host.Error = null;
    for (0..50000) |_| {
        if (client_error == null) _ = pair.client.step(101) catch |err| blk: {
            client_error = err;
            break :blk Result.again;
        };
        if (server_error == null) _ = pair.server.step(101) catch |err| blk: {
            server_error = err;
            break :blk Result.again;
        };
        if (client_error != null and server_error != null) break;
    }
    try equal(error.PeerAuthentication, client_error.?);
    try equal(error.TlsFailure, server_error.?);
    try equal(@as(c_long, 62), pair.client.engine.diagnostics().?.verification_code);
    try expect(pair.server.engine.diagnostics().?.received_alert != null);
    try expect(pair.client.engine.handle != null);
    try expectError(error.PeerAuthentication, pair.client.beginHandshake(102, 10000));
}

test "host raw EOF during handshake is terminal even when alert delivery blocks" {
    var pair: Pair = .{};
    try pair.init();
    defer pair.deinit();
    pair.to_client.eof = true;
    try pair.client.beginHandshake(100, 200);
    var saw_failure = false;
    for (0..10000) |_| {
        _ = try pair.client.step(101);
        if (pair.client.failure != null) {
            saw_failure = true;
            break;
        }
    }
    try expect(saw_failure);
    pair.client_socket.block_send = true;
    var blocked = false;
    for (0..10) |_| {
        if (try pair.client.step(101) == .wait_output) {
            blocked = true;
            break;
        }
    }
    try expect(blocked);
    try expectError(error.OperationDeadline, pair.client.step(200));
    try expect(pair.client.engine.handle == null);
}
