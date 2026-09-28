const std = @import("std");
const tls = @import("tls");
const expect = std.testing.expect;
const equal = std.testing.expectEqual;
const expectError = std.testing.expectError;
const now = 1_789_300_000; // Fixed 2026 verification time, independent of host clock.

test "qualified runtime backend is OpenSSL 3.5.8" {
    try std.testing.expectEqualStrings("OpenSSL 3.5.8 25 Aug 2026", tls.backendVersion());
}

fn clientConfig() tls.Config {
    return .{ .role = .client, .ca_file = "tests/fixtures/ca.pem", .peer = .{ .dns = "localhost" }, .wall_time_seconds = now, .now_ms = 100 };
}
fn serverConfig() tls.Config {
    return .{ .role = .server, .certificate_file = "tests/fixtures/server.pem", .private_key_file = "tests/fixtures/server.key", .wall_time_seconds = now, .now_ms = 100 };
}
fn transfer(from: *tls.Engine, to: *tls.Engine, fragment: usize) !usize {
    var buffer: [16384]u8 = undefined;
    const n = (try from.drainRecords(buffer[0..@min(fragment, buffer.len)])).count;
    if (n > 0) try equal(n, (try to.feedRecords(buffer[0..n])).count);
    return n;
}
fn handshake(client: *tls.Engine, server: *tls.Engine, fragment: usize) !void {
    for (0..20000) |_| {
        _ = try client.handshake();
        _ = try transfer(client, server, fragment);
        _ = try server.handshake();
        _ = try transfer(server, client, fragment);
        if (client.authenticated and server.authenticated) return;
    }
    return error.TestHandshakeStalled;
}
fn connected() !struct { client: tls.Engine, server: tls.Engine } {
    var client = try tls.Engine.init(clientConfig());
    errdefer client.deinit();
    var server = try tls.Engine.init(serverConfig());
    errdefer server.deinit();
    try handshake(&client, &server, 4096);
    return .{ .client = client, .server = server };
}

test "TLS13 HTTP1 roundtrip with single-byte handshake fragments" {
    var client = try tls.Engine.init(clientConfig());
    defer client.deinit();
    var server = try tls.Engine.init(serverConfig());
    defer server.deinit();
    var buf: [128]u8 = undefined;
    try expectError(error.InvalidState, client.readPlaintext(&buf));
    try expectError(error.InvalidState, server.queuePlaintext("premature"));
    try handshake(&client, &server, 1);
    const request = "POST /echo HTTP/1.1\r\nHost: localhost\r\nContent-Length: 5\r\n\r\nhello";
    try client.queuePlaintext(request);
    try equal(.complete, try client.flushPlaintext());
    while (try transfer(&client, &server, 7) != 0) {}
    const r = try server.readPlaintext(&buf);
    try std.testing.expectEqualStrings(request, buf[0..r.count]);
    try server.queuePlaintext("HTTP/1.1 200 OK\r\nContent-Length: 5\r\n\r\nhello");
    try equal(.complete, try server.flushPlaintext());
    while (try transfer(&server, &client, 3) != 0) {}
    const response = try client.readPlaintext(&buf);
    try std.testing.expectEqualStrings("HTTP/1.1 200 OK\r\nContent-Length: 5\r\n\r\nhello", buf[0..response.count]);
    try equal(@as(c_long, 0), client.diagnostics().?.verification_code);
}

test "wrong DNS name fails before application access" {
    var cfg = clientConfig();
    cfg.peer = .{ .dns = "wrong.example" };
    var client = try tls.Engine.init(cfg);
    defer client.deinit();
    var server = try tls.Engine.init(serverConfig());
    defer server.deinit();
    try expectError(error.PeerAuthentication, handshake(&client, &server, 1024));
    try equal(@as(c_long, 62), client.diagnostics().?.verification_code);
    try expect(!client.authenticated);
    try expectError(error.PeerAuthentication, client.queuePlaintext("secret"));
}

test "explicit trust excludes an unrelated CA" {
    var cfg = clientConfig();
    cfg.ca_file = "tests/fixtures/other-ca.pem";
    var client = try tls.Engine.init(cfg);
    defer client.deinit();
    var server = try tls.Engine.init(serverConfig());
    defer server.deinit();
    try expectError(error.PeerAuthentication, handshake(&client, &server, 1024));
    try expect(client.diagnostics().?.verification_code != 0);
}

test "expired certificate and future validity use supplied wall time" {
    var cfg = serverConfig();
    cfg.certificate_file = "tests/fixtures/expired.pem";
    cfg.private_key_file = "tests/fixtures/expired.key";
    var client = try tls.Engine.init(clientConfig());
    defer client.deinit();
    var server = try tls.Engine.init(cfg);
    defer server.deinit();
    try expectError(error.PeerAuthentication, handshake(&client, &server, 4096));
    try equal(@as(c_long, 10), client.diagnostics().?.verification_code);
    var early_cfg = clientConfig();
    early_cfg.wall_time_seconds = 1_700_000_000;
    var early = try tls.Engine.init(early_cfg);
    defer early.deinit();
    var normal = try tls.Engine.init(serverConfig());
    defer normal.deinit();
    try expectError(error.PeerAuthentication, handshake(&early, &normal, 4096));
    try equal(@as(c_long, 9), early.diagnostics().?.verification_code);
}

test "client-only EKU cannot authenticate a server" {
    var cfg = serverConfig();
    cfg.certificate_file = "tests/fixtures/wrong-purpose.pem";
    cfg.private_key_file = "tests/fixtures/wrong-purpose.key";
    var client = try tls.Engine.init(clientConfig());
    defer client.deinit();
    var server = try tls.Engine.init(cfg);
    defer server.deinit();
    try expectError(error.PeerAuthentication, handshake(&client, &server, 4096));
    try equal(@as(c_long, 26), client.diagnostics().?.verification_code);
}

test "IP SAN succeeds and wrong IP fails" {
    for ([_][:0]const u8{ "127.0.0.1", "127.0.0.2" }, 0..) |ip, i| {
        var cfg = clientConfig();
        cfg.peer = .{ .ip = ip };
        var client = try tls.Engine.init(cfg);
        defer client.deinit();
        var server = try tls.Engine.init(serverConfig());
        defer server.deinit();
        if (i == 0) try handshake(&client, &server, 4096) else {
            try expectError(error.PeerAuthentication, handshake(&client, &server, 4096));
            try equal(@as(c_long, 64), client.diagnostics().?.verification_code);
        }
    }
}

test "mTLS requires a trusted client certificate" {
    for ([_]bool{ false, true }) |credential| {
        var cc = clientConfig();
        if (credential) {
            cc.certificate_file = "tests/fixtures/client.pem";
            cc.private_key_file = "tests/fixtures/client.key";
        }
        var sc = serverConfig();
        sc.ca_file = "tests/fixtures/ca.pem";
        sc.require_client_certificate = true;
        var client = try tls.Engine.init(cc);
        defer client.deinit();
        var server = try tls.Engine.init(sc);
        defer server.deinit();
        if (credential) try handshake(&client, &server, 4096) else {
            try expectError(error.PeerAuthentication, handshake(&client, &server, 4096));
            try expect(!server.authenticated);
        }
    }
}

test "AEAD record tampering is terminal and releases no plaintext" {
    var pair = try connected();
    defer pair.client.deinit();
    defer pair.server.deinit();
    try pair.client.queuePlaintext("do not release");
    _ = try pair.client.flushPlaintext();
    var wire: [16384]u8 = undefined;
    const n = (try pair.client.drainRecords(&wire)).count;
    try expect(n > 16);
    wire[n - 1] ^= 1;
    _ = try pair.server.feedRecords(wire[0..n]);
    var plain: [32]u8 = @splat(0xa5);
    try expectError(error.TlsFailure, pair.server.readPlaintext(&plain));
    try expectError(error.TlsFailure, pair.server.readPlaintext(&plain));
}

test "clean close_notify differs from raw EOF and truncated record" {
    for (0..3) |kind| {
        var pair = try connected();
        defer pair.client.deinit();
        defer pair.server.deinit();
        if (kind == 0) {
            _ = try pair.client.shutdown();
            while (try transfer(&pair.client, &pair.server, 4096) != 0) {}
        } else if (kind == 2) {
            try pair.client.queuePlaintext("incomplete");
            _ = try pair.client.flushPlaintext();
            var wire: [128]u8 = undefined;
            const n = (try pair.client.drainRecords(&wire)).count;
            _ = try pair.server.feedRecords(wire[0 .. n - 1]);
        }
        try pair.server.transportEof();
        var buf: [64]u8 = undefined;
        if (kind == 0) try equal(.closed, (try pair.server.readPlaintext(&buf)).progress) else try expectError(error.TlsFailure, pair.server.readPlaintext(&buf));
    }
}

test "shutdown preserves final records in both roles and still rejects truncation" {
    for ([_]bool{ false, true }) |close_server| {
        for (0..3) |ending| { // close_notify, missing close_notify, truncated close_notify
            var pair = try connected();
            defer pair.client.deinit();
            defer pair.server.deinit();
            const local = if (close_server) &pair.server else &pair.client;
            const peer = if (close_server) &pair.client else &pair.server;
            _ = try local.shutdown();
            // A valid final response crosses the outgoing close_notify in flight.
            for ([_][]const u8{ "final ", "response" }) |record| {
                try peer.queuePlaintext(record);
                try equal(.complete, try peer.flushPlaintext());
            }
            if (ending != 1) _ = try peer.shutdown();
            var wire: [256]u8 = undefined;
            const n = (try peer.drainRecords(&wire)).count;
            const available = n - @as(usize, if (ending == 2) 1 else 0);
            var offset: usize = 0;
            while (offset < available) {
                const end = @min(offset + 7, available);
                try equal(end - offset, (try local.feedRecords(wire[offset..end])).count);
                offset = end;
            }
            if (ending != 0) try local.transportEof();
            const expected = "final response";
            var consumed: usize = 0;
            var plain: [3]u8 = undefined;
            while (consumed < expected.len) {
                try equal(.plaintext_available, try local.shutdown());
                try equal(.plaintext_available, try local.shutdown()); // Must not consume bytes.
                const read = try local.readPlaintext(&plain);
                try equal(.complete, read.progress);
                try expect(read.count > 0 and consumed + read.count <= expected.len);
                try std.testing.expectEqualStrings(expected[consumed .. consumed + read.count], plain[0..read.count]);
                consumed += read.count;
            }
            if (ending == 0) {
                try equal(.closed, try local.shutdown());
                try equal(.closed, try local.shutdown());
                while (try transfer(local, peer, 7) != 0) {}
                try equal(.closed, try peer.shutdown());
            } else {
                try expectError(error.TlsFailure, local.shutdown());
                try expectError(error.TlsFailure, local.readPlaintext(&plain));
            }
        }
    }
}

test "shutdown retries a blocked close alert before reading final peer data" {
    var pair = try connected();
    defer pair.client.deinit();
    defer pair.server.deinit();
    const block: [16384]u8 = @splat(0x5a);
    try pair.client.queuePlaintext(&block);
    try equal(.complete, try pair.client.flushPlaintext());
    try pair.client.queuePlaintext(block[0..16330]);
    try equal(.complete, try pair.client.flushPlaintext());
    // The two TLS records leave too little space in the BIO for close_notify.
    try equal(.need_output, try pair.client.shutdown());
    try expectError(error.InvalidState, pair.client.queuePlaintext("after close"));
    var received: usize = 0;
    var plain: [16384]u8 = undefined;
    for (0..64) |_| {
        _ = try transfer(&pair.client, &pair.server, 4096);
        const r = try pair.server.readPlaintext(&plain);
        for (plain[0..r.count]) |byte| try equal(@as(u8, 0x5a), byte);
        received += r.count;
        if (received == 16384 + 16330) break;
    }
    try equal(@as(usize, 16384 + 16330), received);
    try pair.server.queuePlaintext("last");
    try equal(.complete, try pair.server.flushPlaintext());
    _ = try pair.server.shutdown();
    while (try transfer(&pair.server, &pair.client, 7) != 0) {}
    try equal(.need_input, try pair.client.shutdown()); // Finish the blocked alert.
    try equal(.plaintext_available, try pair.client.shutdown());
    const r = try pair.client.readPlaintext(&plain);
    try std.testing.expectEqualStrings("last", plain[0..r.count]);
    try equal(.closed, try pair.client.shutdown());
    while (try transfer(&pair.client, &pair.server, 7) != 0) {}
    try equal(.closed, try pair.server.shutdown());
}

test "bounded output retains write data across WANT_WRITE" {
    var pair = try connected();
    defer pair.client.deinit();
    defer pair.server.deinit();
    var block: [16384]u8 = @splat(0x5a);
    try pair.client.queuePlaintext(&block);
    try equal(.complete, try pair.client.flushPlaintext());
    try pair.client.queuePlaintext(&block);
    try equal(.need_output, try pair.client.flushPlaintext());
    try expectError(error.InvalidState, pair.client.queuePlaintext("overwrite"));
    @memset(&block, 0); // Proves queue owns the retry bytes.
    var total: usize = 0;
    var plain: [16384]u8 = undefined;
    for (0..20) |_| {
        while (try transfer(&pair.client, &pair.server, 4096) != 0) {
            const r = try pair.server.readPlaintext(&plain);
            for (plain[0..r.count]) |ch| try equal(@as(u8, 0x5a), ch);
            total += r.count;
        }
        _ = try pair.client.flushPlaintext();
        if (total == 32768) break;
    }
    try equal(@as(usize, 32768), total);
}

test "input bounds, empty input, and explicit EOF" {
    var e = try tls.Engine.init(serverConfig());
    defer e.deinit();
    var bytes: [20000]u8 = @splat(0);
    try equal(@as(usize, 0), (try e.feedRecords("")).count);
    try equal(@as(usize, 16384), (try e.feedRecords(&bytes)).count);
    try equal(@as(usize, 16384), (try e.feedRecords(&bytes)).count);
    try equal(@as(usize, 0), (try e.feedRecords(&bytes)).count);
    try equal(.input_full, (try e.feedRecords(&bytes)).progress);
    try e.transportEof();
    try expectError(error.InvalidState, e.feedRecords("x"));
}

test "absolute deadline, backward clock, and idempotent cancel" {
    var e = try tls.Engine.init(clientConfig());
    defer e.deinit();
    try expectError(error.InvalidState, e.tick(99));
    try e.tick(101);
    _ = try e.handshake();
    try expectError(error.DeadlineExceeded, e.tick(10100));
    try expectError(error.DeadlineExceeded, e.handshake());
    e.cancel();
    e.cancel();
    try expect(e.handle == null);
}

test "invalid configuration and mismatched credentials fail at creation" {
    var cfg = clientConfig();
    cfg.peer = .{ .dns = "" };
    try expectError(error.InvalidConfig, tls.Engine.init(cfg));
    cfg.peer = .{ .dns = "local\x00host" };
    try expectError(error.InvalidConfig, tls.Engine.init(cfg));
    cfg.peer = .{ .dns = "*.example" };
    try expectError(error.InvalidConfig, tls.Engine.init(cfg));
    cfg = clientConfig();
    cfg.ca_file = null;
    try expectError(error.InvalidConfig, tls.Engine.init(cfg));
    cfg = serverConfig();
    cfg.private_key_file = "tests/fixtures/client.key";
    try expectError(error.BackendInitialization, tls.Engine.init(cfg));
}
