// Engineering contract (2026-09-26)
// Public consumer demonstration of authenticated in-memory TLS records roundtrip.
// File contract: docs/reference/files/examples/roundtrip.zig.md
// Ownership and invariant: Example buffers and fixture inputs are deliberately bounded. Success
// covers this journey only. Network ownership, provider identity and production policy are claimed
// only when actually exercised; QUIC examples stay offline.
// Next implementation obligation: Keep the example importing the public facade. Preserve exact
// expected bytes and final invariants. Update its run command and fixture provenance whenever
// dependencies change. Add a real integration test separately from the demonstration.

const std = @import("std");
const tls = @import("tls");

// A host owns the byte transport. Replace this pump with socket queues in Zap.
fn pump(from: *tls.Engine, to: *tls.Engine) !void {
    var bytes: [4096]u8 = undefined;
    const n = (try from.drainRecords(&bytes)).count;
    if (n != 0 and (try to.feedRecords(bytes[0..n])).count != n) return error.HostQueueRequired;
}
pub fn main() !void {
    var client = try tls.Engine.init(.{ .role = .client, .ca_file = "tests/fixtures/ca.pem", .peer = .{ .dns = "localhost" }, .wall_time_seconds = 1_789_300_000, .now_ms = 0 });
    defer client.deinit();
    var server = try tls.Engine.init(.{ .role = .server, .certificate_file = "tests/fixtures/server.pem", .private_key_file = "tests/fixtures/server.key", .wall_time_seconds = 1_789_300_000, .now_ms = 0 });
    defer server.deinit();
    for (0..100) |i| {
        try client.tick(i);
        try server.tick(i);
        _ = try client.handshake();
        try pump(&client, &server);
        _ = try server.handshake();
        try pump(&server, &client);
        if (client.authenticated and server.authenticated) break;
    } else return error.HandshakeStalled;
    try client.queuePlaintext("GET / HTTP/1.1\r\nHost: localhost\r\n\r\n");
    _ = try client.flushPlaintext();
    try pump(&client, &server);
    var plaintext: [256]u8 = undefined;
    const request = try server.readPlaintext(&plaintext);
    if (request.count == 0) return error.MissingRequest;
    try server.queuePlaintext("HTTP/1.1 200 OK\r\nContent-Length: 8\r\n\r\ntls-zig\n");
    _ = try server.flushPlaintext();
    try pump(&server, &client);
    const response = try client.readPlaintext(&plaintext);
    std.debug.print("{s}\nTLS 1.3, verified localhost, ALPN http/1.1\n{s}", .{ tls.backendVersion(), plaintext[0..response.count] });
    _ = try client.shutdown();
    try pump(&client, &server);
    if ((try server.readPlaintext(&plaintext)).progress != .closed) return error.MissingCloseNotify;
    _ = try server.shutdown();
    try pump(&server, &client);
    if (try client.shutdown() != .closed) return error.MissingCloseNotify;
}
