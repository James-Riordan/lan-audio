//! Real loopback sockets only. Production endpoints remain caller-selected.
const std = @import("std");
const net = @import("network_host");
const expect = std.testing.expect;
const eq = std.testing.expectEqual;

const Pair = struct {
    client: net.Socket = .{},
    server: net.Socket = .{},
    fn close(self: *@This()) void {
        self.client.close() catch @panic("client close failed");
        self.server.close() catch @panic("server close failed");
    }
};

fn openPair(family: net.Family) !Pair {
    var listener: net.Socket = .{};
    defer listener.close() catch @panic("listener close failed");
    try listener.init(family);
    const address: [:0]const u8 = if (family == .ipv4) "127.0.0.1" else "::1";
    try listener.listen(.{ .address = address, .port = 0 }, 4);
    var pair: Pair = .{};
    errdefer pair.close();
    const deadline = try net.nowMilliseconds() + 3000;
    try pair.client.init(family);
    if (!try pair.client.connect(.{ .address = address, .port = try listener.localPort() })) {
        while (true) {
            try pair.client.wait(.output, deadline, null);
            if (try pair.client.finishConnect()) break;
        }
    }
    while (!try listener.accept(&pair.server)) try listener.wait(.input, deadline, null);
    try expect(try pair.server.localPort() == try listener.localPort());
    // Returning moves handles before any callback borrows the pair's address.
    // Listener destruction must not terminate either independent socket owner.
    return pair;
}

fn sendAll(socket: *net.Socket, bytes: []const u8, deadline: u64) !void {
    var offset: usize = 0;
    while (offset < bytes.len) {
        if (try socket.send(bytes[offset..])) |n| offset += n else try socket.wait(.output, deadline, null);
    }
}

test "IPv4 and IPv6 preserve byte prefixes and independent half close after listener release" {
    for ([_]net.Family{ .ipv4, .ipv6 }) |family| {
        var pair = try openPair(family);
        defer pair.close();
        const deadline = try net.nowMilliseconds() + 3000;
        var payload: [1021]u8 = undefined;
        for (&payload, 0..) |*byte, i| byte.* = @truncate(i * 37 + 11);
        var out: [19]u8 = undefined;
        try eq(@as(?usize, null), try pair.server.receive(&out));
        try std.testing.expectError(error.EmptyBuffer, pair.client.send(&.{}));
        try std.testing.expectError(error.EmptyBuffer, pair.server.receive(out[0..0]));
        var sent: usize = 0;
        while (sent < payload.len) {
            const n = @min(37, payload.len - sent);
            try sendAll(&pair.client, payload[sent..][0..n], deadline);
            sent += n;
        }
        try pair.client.shutdownWrite();
        try pair.client.shutdownWrite();
        try std.testing.expectError(error.InvalidState, pair.client.send("extra"));
        var received: usize = 0;
        while (true) {
            if (try pair.server.receive(&out)) |n| {
                if (n == 0) break;
                try expect(n <= payload.len - received);
                try std.testing.expectEqualSlices(u8, payload[received..][0..n], out[0..n]);
                received += n;
            } else try pair.server.wait(.input, deadline, null);
        }
        try eq(payload.len, received);
        try eq(@as(?usize, 0), try pair.server.receive(&out));
        try sendAll(&pair.server, "reply", deadline); // Read EOF still permits sending.
        try pair.server.shutdownWrite();
        var reply: [5]u8 = undefined;
        var got: usize = 0;
        while (got < reply.len) {
            if (try pair.client.receive(reply[got..])) |n| {
                try expect(n > 0);
                got += n;
            } else try pair.client.wait(.input, deadline, null);
        }
        try std.testing.expectEqualStrings("reply", &reply);
    }
}

test "cancellation and absolute deadline leave the descriptor with its original owner" {
    const Cancel = struct {
        fn run(flag: *std.atomic.Value(bool)) void {
            std.Io.sleep(std.testing.io, .fromMilliseconds(30), .awake) catch @panic("sleep failed");
            flag.store(true, .release);
        }
    };
    var pair = try openPair(.ipv4);
    defer pair.close();
    var canceled = std.atomic.Value(bool).init(false);
    const thread = try std.Thread.spawn(.{}, Cancel.run, .{&canceled});
    defer thread.join();
    const start = try net.nowMilliseconds();
    try std.testing.expectError(error.Canceled, pair.server.wait(.input, start + 3000, &canceled));
    try expect(try net.nowMilliseconds() - start < 2000); // Coarse stall guard, no 10ms scheduling claim.
    try std.testing.expectError(error.Canceled, pair.client.wait(.output, start + 3000, &canceled));
    const deadline = try net.nowMilliseconds() + 20;
    try std.testing.expectError(error.Deadline, pair.server.wait(.input, deadline, null));
    try std.testing.expectError(error.Deadline, pair.server.wait(.input, deadline, null));
    try eq(.connected, pair.server.state);
    try sendAll(&pair.client, "still-owned", try net.nowMilliseconds() + 1000);
    var bytes: [11]u8 = undefined;
    try pair.server.wait(.input, try net.nowMilliseconds() + 1000, null);
    try expect((try pair.server.receive(&bytes)).? > 0);
}

test "refused connect never becomes connected merely because the socket is writable" {
    var listener: net.Socket = .{};
    defer listener.close() catch @panic("listener close failed");
    try listener.init(.ipv4);
    try listener.listen(.{ .address = "127.0.0.1", .port = 0 }, 1);
    const port = try listener.localPort();
    try listener.close();
    var client: net.Socket = .{};
    defer client.close() catch @panic("client close failed");
    try client.init(.ipv4);
    const immediate = client.connect(.{ .address = "127.0.0.1", .port = port }) catch |err| {
        try eq(error.SystemFailure, err);
        try eq(.failed, client.state);
        return;
    };
    try expect(!immediate);
    try client.wait(.output, try net.nowMilliseconds() + 3000, null);
    try std.testing.expectError(error.SystemFailure, client.finishConnect());
    try eq(.failed, client.state);
    try expect(client.lastNativeError() != 0);
}

test "invalid endpoints and destination owners reject before replacing native ownership" {
    var listener: net.Socket = .{};
    defer listener.close() catch @panic("listener close failed");
    try listener.init(.ipv4);
    try std.testing.expectError(error.InvalidEndpoint, listener.listen(.{ .address = "localhost", .port = 0 }, 2));
    try eq(.open, listener.state);
    try std.testing.expectError(error.InvalidEndpoint, listener.connect(.{ .address = "127.0.0.1", .port = 0 }));
    try std.testing.expectError(error.InvalidEndpoint, listener.listen(.{ .address = "127.0.0.1", .port = 0, .scope_id = 1 }, 2));
    try listener.listen(.{ .address = "127.0.0.1", .port = 0 }, 2);
    var destination: net.Socket = .{};
    defer destination.close() catch @panic("destination close failed");
    try expect(!try listener.accept(&destination));
    try eq(.empty, destination.state);
    try destination.init(.ipv4);
    try std.testing.expectError(error.InvalidState, listener.accept(&destination));
    try eq(.open, destination.state);
    try std.testing.expectError(error.InvalidState, listener.accept(&listener));
    try destination.close();
    try destination.close();
    try std.testing.expectError(error.InvalidState, destination.send("closed"));
}

test "repeated connection teardown releases independent runtime ownership" {
    for (0..32) |_| {
        var pair = try openPair(.ipv4);
        try sendAll(&pair.client, "x", try net.nowMilliseconds() + 1000);
        pair.close();
        try eq(.empty, pair.client.state);
        try eq(.empty, pair.server.state);
    }
}

test "a stalled peer applies backpressure without losing accepted byte prefixes" {
    var pair = try openPair(.ipv4);
    defer pair.close();
    var chunk: [16384]u8 = undefined;
    for (&chunk, 0..) |*byte, i| byte.* = @truncate(i * 13 + 7);
    var accepted: usize = 0;
    const deadline = try net.nowMilliseconds() + 10000;
    while (accepted < 64 * 1024 * 1024) {
        try expect(try net.nowMilliseconds() < deadline);
        const offset = accepted % chunk.len;
        if (try net.Socket.transportSend(&pair.client, chunk[offset..])) |n| {
            try expect(n > 0 and n <= chunk.len - offset);
            accepted += n;
        } else break;
    }
    // This fixture requires a bounded local send window; reaching the cap is a
    // qualification failure, not evidence that backpressure was exercised.
    try expect(accepted > 0 and accepted < 64 * 1024 * 1024);
    var received: usize = 0;
    var output: [4093]u8 = undefined;
    while (received < accepted) {
        try expect(try net.nowMilliseconds() < deadline);
        if (try net.Socket.transportReceive(&pair.server, &output)) |n| {
            try expect(n > 0 and n <= accepted - received);
            for (output[0..n], 0..) |byte, i| try eq(chunk[(received + i) % chunk.len], byte);
            received += n;
        } else try pair.server.wait(.input, deadline, null);
    }
    try pair.client.wait(.output, deadline, null);
    try sendAll(&pair.client, "resumed", deadline);
    var resumed: [7]u8 = undefined;
    var count: usize = 0;
    while (count < resumed.len) {
        if (try pair.server.receive(resumed[count..])) |n| {
            try expect(n > 0);
            count += n;
        } else try pair.server.wait(.input, deadline, null);
    }
    try std.testing.expectEqualStrings("resumed", &resumed);
}
