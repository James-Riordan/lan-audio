// Engineering contract (2026-09-26)
// Executable regression suite for transport.
// File contract: docs/reference/files/tests/transport.zig.md
// Ownership and invariant: Tests use explicit expected values and failure-path state comparisons.
// Test discovery depends on the owning build/root imports; names alone are not evidence that a
// test ran. Imports: std, tls.
// Next implementation obligation: Retain every named regression below. Add a minimized
// counterexample for changed behavior, including state before/after failure and externally visible
// output. Avoid generating expected wire bytes with the implementation being tested.
// Verification: tests/transport.zig

const std = @import("std");
const tls = @import("tls");
const expect = std.testing.expect;
const equal = std.testing.expectEqual;
const expectError = std.testing.expectError;
const now = 1_789_300_000; // Fixed 2026 verification time, independent of host clock.

// Independent oracle: Python ssl.PEM_cert_to_DER_cert + hashlib.sha256 on
// the first certificate in each fixture, not this backend's X509_digest.
fn fixtureDigest(comptime hex: []const u8) [32]u8 {
    var bytes: [32]u8 = undefined;
    _ = std.fmt.hexToBytes(&bytes, hex) catch unreachable;
    return bytes;
}
const server_digest = fixtureDigest("67495f2574f958a9106517e3e93532030ed3569fced3f46a63183dfea13ecacd");
const client_digest = fixtureDigest("26d690e9a54cdd8d90e428fe02651762248a5f3728534a8c680f87152775e5cf");
extern fn tz_verified_peer_leaf_sha256(e: ?*anyopaque, out: ?[*]u8, capacity: usize) c_int;

test "verified peer leaf digest is copied only from completed peer-verified TLS" {
    var cc = clientConfig();
    cc.certificate_file = "tests/fixtures/client.pem";
    cc.private_key_file = "tests/fixtures/client.key";
    var sc = serverConfig();
    sc.ca_file = "tests/fixtures/ca.pem";
    sc.require_client_certificate = true;
    var client = try tls.Engine.init(cc);
    defer client.deinit();
    var server = try tls.Engine.init(sc);
    defer server.deinit();
    try expectError(error.InvalidState, client.verifiedPeerLeafSha256());
    try expectError(error.InvalidState, server.verifiedPeerLeafSha256());
    try handshake(&client, &server, 1);
    var copied = try client.verifiedPeerLeafSha256();
    try equal(server_digest, copied);
    try equal(client_digest, try server.verifiedPeerLeafSha256());
    @memset(&copied, 0xa5);
    try equal(server_digest, try client.verifiedPeerLeafSha256());
    const snapshot = try server.verifiedPeerLeafSha256();
    server.cancel();
    try equal(client_digest, snapshot);
    try expectError(error.Canceled, server.verifiedPeerLeafSha256());
    client.deinit();
    try expectError(error.Canceled, client.verifiedPeerLeafSha256());
}

test "digest query rejects unverified clients and closing or ended connections" {
    for (0..3) |ending| {
        var pair = try connected();
        defer pair.client.deinit();
        defer pair.server.deinit();
        try expect(pair.server.authenticated);
        try expectError(error.PeerIdentityUnavailable, pair.server.verifiedPeerLeafSha256());
        try equal(server_digest, try pair.client.verifiedPeerLeafSha256());
        if (ending == 0) {
            _ = try pair.client.shutdown();
        } else if (ending == 1) {
            try pair.client.transportEof();
        } else {
            _ = try pair.server.shutdown();
            while (try transfer(&pair.server, &pair.client, 7) != 0) {}
            var plain: [8]u8 = undefined;
            try equal(.closed, (try pair.client.readPlaintext(&plain)).progress);
        }
        try expectError(error.PeerIdentityUnavailable, pair.client.verifiedPeerLeafSha256());
    }
}

test "digest C boundary leaves failed outputs and success suffix unchanged" {
    var pair = try connected();
    defer pair.client.deinit();
    defer pair.server.deinit();
    const sentinel: [40]u8 = @splat(0xa5);
    var output = sentinel;
    try equal(@as(c_int, -4), tz_verified_peer_leaf_sha256(null, &output, output.len));
    try equal(sentinel, output);
    try equal(@as(c_int, -4), tz_verified_peer_leaf_sha256(pair.client.handle, null, 32));
    try equal(@as(c_int, -4), tz_verified_peer_leaf_sha256(pair.client.handle, &output, 31));
    try equal(sentinel, output);
    try equal(@as(c_int, -4), tz_verified_peer_leaf_sha256(pair.server.handle, &output, output.len));
    try equal(sentinel, output);
    try equal(@as(c_int, 0), tz_verified_peer_leaf_sha256(pair.client.handle, &output, output.len));
    try std.testing.expectEqualSlices(u8, &server_digest, output[0..32]);
    try std.testing.expectEqualSlices(u8, sentinel[32..], output[32..]);
    // Querying neither consumes records nor prevents application traffic.
    try pair.client.queuePlaintext("still live");
    _ = try pair.client.flushPlaintext();
    while (try transfer(&pair.client, &pair.server, 7) != 0) {}
    const read = try pair.server.readPlaintext(&output);
    try std.testing.expectEqualStrings("still live", output[0..read.count]);
}

test "record authentication failure revokes a previously exportable identity" {
    var pair = try connected();
    defer pair.client.deinit();
    defer pair.server.deinit();
    const snapshot = try pair.client.verifiedPeerLeafSha256();
    try pair.server.queuePlaintext("authenticated or rejected");
    _ = try pair.server.flushPlaintext();
    var wire: [256]u8 = undefined;
    const n = (try pair.server.drainRecords(&wire)).count;
    try expect(n > 16);
    wire[n - 1] ^= 1;
    _ = try pair.client.feedRecords(wire[0..n]);
    var plain: [64]u8 = @splat(0xa5);
    try expectError(error.TlsFailure, pair.client.readPlaintext(&plain));
    try expectError(error.TlsFailure, pair.client.verifiedPeerLeafSha256());
    try equal(server_digest, snapshot);
    var output: [32]u8 = @splat(0xa5);
    const before = output;
    try equal(@as(c_int, -4), tz_verified_peer_leaf_sha256(pair.client.handle, &output, output.len));
    try equal(before, output);
}

test "custom ALPN is owned by each connection and bounds are checked" {
    var protocol = [_]u8{ 'j', 'c', 'r', '-', 'a', 'u', 'd', 'i', 'o', '/', '1' };
    var cc = clientConfig();
    var sc = serverConfig();
    cc.alpn = &protocol;
    sc.alpn = &protocol;
    var client = try tls.Engine.init(cc);
    defer client.deinit();
    var server = try tls.Engine.init(sc);
    defer server.deinit();
    @memset(&protocol, 'X'); // Init must not retain this caller-owned storage.
    try handshake(&client, &server, 7);
    try expect(client.authenticated and server.authenticated);
    cc.alpn = "";
    try expectError(error.InvalidConfig, tls.Engine.init(cc));
    const oversized: [256]u8 = @splat('a');
    cc.alpn = &oversized;
    try expectError(error.InvalidConfig, tls.Engine.init(cc));
}

test "ALPN mismatch rejects handshake before application data" {
    var cc = clientConfig();
    cc.alpn = "jcr-audio/1";
    var client = try tls.Engine.init(cc);
    defer client.deinit();
    var server = try tls.Engine.init(serverConfig());
    defer server.deinit();
    try expectError(error.TlsFailure, handshake(&client, &server, 4096));
    try expect(!server.authenticated);
    try expectError(error.TlsFailure, server.queuePlaintext("wrong protocol"));
    try expectError(error.TlsFailure, server.verifiedPeerLeafSha256());
}

test "opaque ALPN accepts the maximum legal identifier" {
    const protocol: [255]u8 = @splat(0);
    var cc = clientConfig();
    var sc = serverConfig();
    cc.alpn = &protocol;
    sc.alpn = &protocol;
    var client = try tls.Engine.init(cc);
    defer client.deinit();
    var server = try tls.Engine.init(sc);
    defer server.deinit();
    try handshake(&client, &server, 4096);
}

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
    try expectError(error.PeerAuthentication, client.verifiedPeerLeafSha256());
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
    try expectError(error.PeerAuthentication, client.verifiedPeerLeafSha256());
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
            try expectError(error.PeerAuthentication, server.verifiedPeerLeafSha256());
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
    try expectError(error.TlsFailure, pair.server.verifiedPeerLeafSha256());
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
    try expectError(error.DeadlineExceeded, e.verifiedPeerLeafSha256());
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
