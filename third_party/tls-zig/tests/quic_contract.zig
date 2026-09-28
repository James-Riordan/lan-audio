const std = @import("std");
const t = std.testing;
const tls = @import("tls_quic_engine");
const c = tls.contract;
const Engine = tls.Engine;
const Host = struct {
    engine: *Engine,
    peer: ?*Engine = null,
    reference: ?*Reference = null,
    surplus_initial: bool = false,
    surplus_sent: bool = false,
    expected_parameters: []const u8,
    fragment: usize = 65536,
    offset: usize = 0,
    active: ?c.EventId = null,
    secrets: [3][2][32]u8 = @splat(@splat(@splat(0))),
    seen: [3][2]bool = @splat(@splat(false)),
    parameters: bool = false,
    completions: usize = 0,
    events: usize = 0,
    last_sequence: u64 = 0,
    expected_auth: ?c.PeerAuthentication = null,
    ledger: [3][2]std.crypto.hash.sha2.Sha256 = @splat(@splat(std.crypto.hash.sha2.Sha256.init(.{}))),
    bytes: [3][2]usize = @splat(@splat(0)),
    reject_parameters: bool = false,
    reentry: bool = false,

    fn accept(arg: *anyopaque, event: c.Event) c.ConsumeError!void {
        const self: *Host = @ptrCast(@alignCast(arg));
        if (self.reentry) {
            self.engine.cancel() catch |err| {
                if (err != error.ReentrantCall) return error.Rejected;
            };
            if (self.engine.isReady()) |_| return error.Rejected else |err| {
                if (err != error.ReentrantCall) return error.Rejected;
            }
        }
        switch (event.payload) {
            .crypto => |value| {
                if (self.active) |active| {
                    if (!c.EventId.eql(active, event.id)) return error.Rejected;
                } else self.active = event.id;
                const offered = value.bytes[self.offset..][0..@min(value.bytes.len - self.offset, self.fragment)];
                if (self.reference) |reference| {
                    var accepted: usize = 0;
                    if (reference_offer(reference, @backingInt(value.level), offered.ptr, offered.len, &accepted) != 1 or accepted > offered.len) return error.Rejected;
                    self.ledger[@backingInt(value.level)][1].update(offered[0..accepted]);
                    self.bytes[@backingInt(value.level)][1] += accepted;
                    self.offset += accepted;
                } else {
                    const result = self.peer.?.offerCrypto(value.level, offered) catch return error.Rejected;
                    const accepted = result.acceptedPrefix(offered) catch return error.Rejected;
                    self.offset += accepted.len;
                }
                if (self.offset != value.bytes.len) return error.WouldBlock;
                if (self.surplus_initial and !self.surplus_sent and value.level == .initial) {
                    const surplus: [8]u8 = @splat(0xaa);
                    const result = self.peer.?.offerCrypto(.initial, &surplus) catch return error.Rejected;
                    if (result.accepted.value != surplus.len) return error.Rejected;
                    self.surplus_sent = true;
                }
                self.offset = 0;
                self.active = null;
            },
            .secret => |value| {
                const level = @backingInt(value.level);
                const direction = @backingInt(value.direction);
                if (self.seen[level][direction] or value.suite != .aes128gcm_sha256) return error.Rejected;
                self.secrets[level][direction] = value.bytes.*;
                self.seen[level][direction] = true;
            },
            .peer_parameters => |bytes| {
                if (self.reject_parameters or !std.mem.eql(u8, bytes, self.expected_parameters)) return error.Rejected;
                self.parameters = true;
            },
            .handshake_complete => |authentication| {
                if (self.expected_auth) |expected| if (expected != authentication) return error.Rejected;
                if (!self.parameters or self.completions != 0 or !self.seen[1][0] or !self.seen[1][1] or !self.seen[2][0] or !self.seen[2][1]) return error.Rejected;
                self.completions += 1;
            },
            .alert => {},
        }
    }
    fn pump(self: *Host) !void {
        while (try self.engine.nextEvent()) |event| {
            const repeated = (try self.engine.nextEvent()).?;
            try t.expect(c.EventId.eql(event.id, repeated.id));
            try t.expectError(error.NotConsumed, self.engine.acknowledge(event.id));
            self.engine.consume(event.id, .{ .context = self, .accept = accept }) catch |err| {
                if (err == error.WouldBlock) return;
                return err;
            };
            try t.expect(event.id.sequence.value > self.last_sequence);
            self.last_sequence = event.id.sequence.value;
            try self.engine.acknowledge(event.id);
            const stale = self.engine.acknowledge(event.id);
            if (stale) |_| return error.TestUnexpectedResult else |err| {
                try t.expect(err == error.NotBorrowed or err == error.InvalidToken);
            }
            self.events += 1;
        }
    }
};
fn config(server: bool, small: bool) c.Config {
    return .{
        .policy = if (server) .{ .server = .{ .credentials = .{ .certificate_file = "tests/fixtures/server.pem", .private_key_file = "tests/fixtures/server.key" } } } else .{ .client = .{ .trust_file = "tests/fixtures/ca.pem", .peer = .{ .dns = "localhost" } } },
        .alpn = "engine-test",
        .local_parameters = if (server) &.{ 15, 1, 2 } else &.{ 15, 1, 1 },
        .wall_time = .{ .value = 1790424000 },
        .now = .{ .value = 0 },
        .limits = if (small) .{ .input_bytes = .{ .value = 17 }, .event_payload_bytes = .{ .value = 32 }, .peer_parameter_bytes = .{ .value = 32 } } else .{},
    };
}
fn create(cfg: c.Config) !Engine {
    return Engine.init(t.allocator, try c.normalize(cfg, &.{}, .{}, tls.capabilities()));
}
fn pair(small: bool, reentry: bool) !void {
    const cc = config(false, small);
    const sc = config(true, small);
    var client = try create(cc);
    defer client.deinit() catch unreachable;
    var server = try create(sc);
    defer server.deinit() catch unreachable;
    var ch: Host = .{ .engine = &client, .peer = &server, .expected_parameters = sc.local_parameters, .fragment = if (small) 1 else 65536, .reentry = reentry };
    defer std.crypto.secureZero(u8, std.mem.asBytes(&ch.secrets));
    var sh: Host = .{ .engine = &server, .peer = &client, .expected_parameters = cc.local_parameters, .fragment = if (small) 1 else 65536, .reentry = reentry };
    defer std.crypto.secureZero(u8, std.mem.asBytes(&sh.secrets));
    var tick: u64 = 1;
    while (tick < 20000) : (tick += 1) {
        try ch.pump();
        try sh.pump();
        _ = try client.advance(.{ .value = tick }, .{ .input = .{ .value = if (small) 1 else 16384 } });
        _ = try server.advance(.{ .value = tick }, .{ .input = .{ .value = if (small) 1 else 16384 } });
        if (try client.isReady() and try server.isReady()) break;
    }
    try t.expect(tick < 20000);
    try t.expectEqual(@as(usize, 1), ch.completions);
    try t.expectEqual(@as(usize, 1), sh.completions);
    for ([_]usize{ 1, 2 }) |level| {
        for (0..2) |direction| try t.expectEqualSlices(u8, &ch.secrets[level][direction], &sh.secrets[level][1 - direction]);
    }
    try t.expect((try client.nextEvent()) == null);
    try t.expect((try server.nextEvent()) == null);
    try client.cancel();
    try client.cancel();
    try t.expectError(error.Canceled, client.nextEvent());
    try client.deinit();
    try client.deinit();
    try t.expectError(error.Closed, client.nextEvent());
}
test "real Engine pair gates completion on acknowledged policy and keys" {
    try pair(false, true);
}
test "one-byte fragments exercise ring wrap partial acceptance and bounded scheduling" {
    try pair(true, false);
}

const LifetimeAllocator = struct {
    underlying: std.mem.Allocator,
    hooks: *tls.TestHooks,
    allocations: usize = 0,
    frees: usize = 0,
    freed_before_provider: bool = false,
    payload: ?[*]u8 = null,
    input: ?[*]u8 = null,
    payload_cleared: bool = false,
    input_cleared: bool = false,
    fn allocator(self: *@This()) std.mem.Allocator {
        return .{ .ptr = self, .vtable = &.{ .alloc = alloc, .resize = std.mem.Allocator.noResize, .remap = std.mem.Allocator.noRemap, .free = free } };
    }
    fn alloc(arg: *anyopaque, length: usize, alignment: std.mem.Alignment, ret: usize) ?[*]u8 {
        const self: *@This() = @ptrCast(@alignCast(arg));
        const memory = self.underlying.rawAlloc(length, alignment, ret) orelse return null;
        self.allocations += 1;
        if (self.allocations == 2) self.payload = memory;
        if (self.allocations == 3) self.input = memory;
        return memory;
    }
    fn free(arg: *anyopaque, memory: []u8, alignment: std.mem.Alignment, ret: usize) void {
        const self: *@This() = @ptrCast(@alignCast(arg));
        if (self.hooks.leases > 0 and !self.hooks.provider_destroyed) self.freed_before_provider = true;
        if (self.payload == memory.ptr) self.payload_cleared = std.mem.allEqual(u8, memory, 0);
        if (self.input == memory.ptr) self.input_cleared = std.mem.allEqual(u8, memory, 0);
        self.frees += 1;
        self.underlying.rawFree(memory, alignment, ret);
    }
};
const Failure = enum { identity, trust, alpn, parameters, release, alert };
fn negative(kind: Failure) !void {
    var cc = config(false, false);
    var sc = config(true, false);
    if (kind == .identity or kind == .alert) cc.policy.client.peer = .{ .dns = "mismatch.invalid" };
    if (kind == .trust) cc.policy.client.trust_file = "tests/fixtures/other-ca.pem";
    if (kind == .alpn) sc.alpn = "not-engine-test";
    var client = try create(cc);
    defer client.deinit() catch unreachable;
    var hooks: tls.TestHooks = .{ .fail_release_once = kind == .release };
    var audit: LifetimeAllocator = .{ .underlying = t.allocator, .hooks = &hooks };
    var server = try Engine.init(audit.allocator(), try c.normalize(sc, &.{}, .{}, tls.capabilities()));
    defer server.deinit() catch unreachable;
    try server.testingSetHooks(&hooks);
    var client_hooks: tls.TestHooks = .{ .fail_alert = kind == .alert };
    try client.testingSetHooks(&client_hooks);
    var ch: Host = .{ .engine = &client, .peer = &server, .expected_parameters = sc.local_parameters };
    defer std.crypto.secureZero(u8, std.mem.asBytes(&ch.secrets));
    var sh: Host = .{ .engine = &server, .peer = &client, .expected_parameters = cc.local_parameters, .reject_parameters = kind == .parameters };
    defer std.crypto.secureZero(u8, std.mem.asBytes(&sh.secrets));
    var observed: ?anyerror = null;
    var failed: ?*Engine = null;
    var tick: u64 = 1;
    while (tick < 1000 and observed == null) : (tick += 1) {
        ch.pump() catch |err| {
            observed = err;
            failed = &client;
            break;
        };
        sh.pump() catch |err| {
            observed = err;
            failed = &server;
            break;
        };
        _ = client.advance(.{ .value = tick }, .{}) catch |err| {
            observed = err;
            failed = &client;
            break;
        };
        _ = server.advance(.{ .value = tick }, .{}) catch |err| {
            observed = err;
            failed = &server;
            break;
        };
    }
    const expected = if (kind == .parameters) error.PeerPolicyRejected else error.NativeFailure;
    try t.expectEqual(@as(?anyerror, expected), observed);
    try t.expectEqual(@as(usize, 0), ch.completions);
    try t.expectEqual(@as(usize, 0), sh.completions);
    try t.expectError(expected, failed.?.nextEvent());
    try t.expectError(expected, failed.?.offerCrypto(.application, &.{1}));
    try failed.?.cancel();
    try t.expectError(expected, failed.?.advance(.{ .value = tick + 1 }, .{}));
    if (kind == .release) {
        try t.expectEqual(@as(usize, 1), hooks.release_failures);
        try t.expectEqual(@as(usize, 1), hooks.teardown_releases);
        try t.expectEqual(hooks.leases, hooks.releases);
        try t.expect(hooks.provider_destroyed and hooks.input_cleared_after_provider);
    }
    try server.deinit();
    try server.deinit();
    try t.expectEqual(@as(usize, 4), audit.allocations);
    try t.expectEqual(audit.allocations, audit.frees);
    try t.expect(!audit.freed_before_provider and audit.payload_cleared and audit.input_cleared);
}
test "wrong identity trust ALPN and rejected parameters deny readiness with stable terminal errors" {
    for ([_]Failure{ .identity, .trust, .alpn, .parameters }) |failure| try negative(failure);
}
test "failed release and failed alert retain native callback state through provider destruction" {
    try negative(.release);
    try negative(.alert);
}
fn allocateEngine(allocator: std.mem.Allocator) !void {
    var engine = try Engine.init(allocator, try c.normalize(config(false, false), &.{}, .{}, tls.capabilities()));
    defer engine.deinit() catch unreachable;
    try engine.cancel();
}
test "construction unwinds every wrapper allocation failure and rejects drift before allocation" {
    try t.checkAllAllocationFailures(t.allocator, allocateEngine, .{});
    var hooks: tls.TestHooks = .{};
    var audit: LifetimeAllocator = .{ .underlying = t.allocator, .hooks = &hooks };
    var plan = try c.normalize(config(false, false), &.{}, .{}, tls.capabilities());
    plan.config.alpn = "changed-after-plan";
    try t.expectError(error.StalePlan, Engine.init(audit.allocator(), plan));
    try t.expectEqual(@as(usize, 0), audit.allocations);
}
test "input capacity zero offers deadlines and excess provider counts have distinct outcomes" {
    var cfg = config(false, false);
    cfg.limits.input_bytes.value = 4;
    cfg.timeout.value = 10;
    var engine = try create(cfg);
    defer engine.deinit() catch unreachable;
    const offered = try engine.offerCrypto(.handshake, &.{ 1, 2, 3, 4, 5 });
    try t.expectEqual(@as(usize, 4), offered.accepted.value);
    try t.expectEqual(c.Wait.input_capacity, offered.wait);
    const zero = try engine.offerCrypto(.handshake, &.{});
    try t.expectEqual(@as(usize, 0), zero.accepted.value);
    try t.expectEqual(c.Wait.progress, zero.wait);
    _ = try engine.advance(.{ .value = 9 }, .{});
    try t.expectError(error.InvalidTime, engine.advance(.{ .value = 8 }, .{}));
    try t.expectError(error.TimedOut, engine.advance(.{ .value = 10 }, .{}));
    try t.expectError(error.TimedOut, engine.nextEvent());
    var corrupt = try create(config(false, false));
    defer corrupt.deinit() catch unreachable;
    var hooks: tls.TestHooks = .{ .overreport_input = true };
    try corrupt.testingSetHooks(&hooks);
    try t.expectError(error.ProviderOverconsumption, corrupt.advance(.{ .value = 1 }, .{ .input = .{ .value = 1 } }));
    try t.expectError(error.ProviderOverconsumption, corrupt.nextEvent());
    try t.expect(hooks.provider_destroyed);
}

const Reference = opaque {};
extern fn reference_create(role: u32, fixtures: [*:0]const u8, tickets: i32, out: *?*Reference) i32;
extern fn reference_destroy(owner: *?*Reference) void;
extern fn reference_advance(peer: *Reference) i32;
extern fn reference_offer(peer: *Reference, level: u32, bytes: [*]const u8, length: usize, accepted: *usize) i32;
extern fn reference_peek(peer: *Reference, level: u32, bytes: *[*]const u8, length: *usize) i32;
extern fn reference_retire(peer: *Reference, level: u32, length: usize) i32;
extern fn reference_ready(peer: *Reference) i32;
extern fn reference_secret(peer: *Reference, level: u32, direction: u32, out: *[32]u8) i32;
extern fn reference_packet(peer: *Reference, out: [*]u8, capacity: usize, written: *usize) i32;
extern fn reference_ledger(peer: *Reference, level: u32, direction: u32, out: *[32]u8, bytes: *usize) i32;

fn transferReference(peer: *Reference, host: *Host, application: bool) !usize {
    var total: usize = 0;
    for ([_]c.EncryptionLevel{ .initial, .handshake, .application }) |level| {
        if (level == .application and !application) continue;
        var data: [*]const u8 = undefined;
        var length: usize = 0;
        try t.expectEqual(@as(i32, 1), reference_peek(peer, @backingInt(level), &data, &length));
        if (length == 0) continue;
        const offered = data[0..@min(length, 13)];
        const accepted = try (try host.engine.offerCrypto(level, offered)).acceptedPrefix(offered);
        host.ledger[@backingInt(level)][0].update(accepted);
        host.bytes[@backingInt(level)][0] += accepted.len;
        try t.expectEqual(@as(i32, 1), reference_retire(peer, @backingInt(level), accepted.len));
        total += accepted.len;
    }
    return total;
}
fn checkLedgers(peer: *Reference, host: *const Host) !void {
    for (0..3) |level| for (0..2) |direction| {
        var digest: [32]u8 = undefined;
        var bytes: usize = 0;
        try t.expectEqual(@as(i32, 1), reference_ledger(peer, @intCast(level), @intCast(1 - direction), &digest, &bytes));
        var local = host.ledger[level][direction];
        var expected: [32]u8 = undefined;
        local.final(&expected);
        try t.expectEqualSlices(u8, &expected, &digest);
        try t.expectEqual(host.bytes[level][direction], bytes);
    };
}
fn expandPacketKey(comptime length: usize, secret: [32]u8, comptime label: []const u8) [length]u8 {
    const full = "tls13 " ++ label;
    const info = [_]u8{ 0, length, full.len } ++ full.* ++ [_]u8{0};
    var key: [length]u8 = undefined;
    std.crypto.kdf.hkdf.HkdfSha256.expand(&key, &info, secret);
    return key;
}
fn decryptPacket(packet: [61]u8, secret: [32]u8) ![32]u8 {
    var key = expandPacketKey(16, secret, "quic key");
    defer std.crypto.secureZero(u8, &key);
    var iv = expandPacketKey(12, secret, "quic iv");
    defer std.crypto.secureZero(u8, &iv);
    var hp = expandPacketKey(16, secret, "quic hp");
    defer std.crypto.secureZero(u8, &hp);
    var mask: [16]u8 = undefined;
    defer std.crypto.secureZero(u8, &mask);
    std.crypto.core.aes.Aes128.initEnc(hp).encrypt(&mask, packet[13..29]);
    var header: [13]u8 = packet[0..13].*;
    header[0] ^= mask[0] & 0x1f;
    for (0..4) |i| header[9 + i] ^= mask[1 + i];
    if (header[0] != 0x43 or !std.mem.eql(u8, header[9..13], &.{ 0, 0, 0, 1 })) return error.AuthenticationFailed;
    iv[11] ^= 1;
    var plain: [32]u8 = undefined;
    errdefer std.crypto.secureZero(u8, &plain);
    try std.crypto.aead.aes_gcm.Aes128Gcm.decrypt(&plain, packet[13..45], packet[45..61].*, &header, iv, key);
    return plain;
}
fn independentPeer(server: bool, tickets: bool) !void {
    var cfg = config(server, true);
    cfg.alpn = "quic-probe";
    cfg.local_parameters = if (server) &.{ 15, 1, 0x22 } else &.{ 15, 1, 0x11 };
    var engine = try create(cfg);
    defer engine.deinit() catch unreachable;
    var reference: ?*Reference = null;
    try t.expectEqual(@as(i32, 1), reference_create(if (server) 0 else 1, "tests/fixtures", @intFromBool(tickets), &reference));
    defer reference_destroy(&reference);
    var host: Host = .{ .engine = &engine, .reference = reference, .expected_parameters = if (server) &.{ 15, 1, 0x11 } else &.{ 15, 1, 0x22 }, .fragment = 5 };
    host.expected_auth = if (server) .configured_server_policy else .verified_server_identity;
    defer std.crypto.secureZero(u8, std.mem.asBytes(&host.secrets));
    var tick: u64 = 1;
    while (tick < 20000) : (tick += 1) {
        try host.pump();
        try t.expectEqual(@as(i32, 1), reference_advance(reference.?));
        _ = try transferReference(reference.?, &host, false);
        _ = try engine.advance(.{ .value = tick }, .{ .input = .{ .value = 1 }, .output = .{ .value = 7 } });
        if (try engine.isReady() and reference_ready(reference.?) == 1) break;
    }
    try t.expect(tick < 20000);
    try t.expectEqual(@as(usize, 1), host.completions);
    try checkLedgers(reference.?, &host);
    for ([_]u32{ 1, 2 }) |level| for (0..2) |direction| {
        var peer_secret: [32]u8 = undefined;
        defer std.crypto.secureZero(u8, &peer_secret);
        try t.expectEqual(@as(i32, 1), reference_secret(reference.?, level, @intCast(1 - direction), &peer_secret));
        try t.expectEqualSlices(u8, &host.secrets[level][direction], &peer_secret);
    };
    var packet: [61]u8 = undefined;
    var written: usize = 0;
    try t.expectEqual(@as(i32, 1), reference_packet(reference.?, &packet, packet.len, &written));
    try t.expectEqual(packet.len, written);
    var plain = try decryptPacket(packet, host.secrets[2][0]);
    defer std.crypto.secureZero(u8, &plain);
    try t.expectEqual(@as(u8, 1), plain[0]);
    try t.expect(std.mem.allEqual(u8, plain[1..], 0));
    try t.expectError(error.AuthenticationFailed, decryptPacket(packet, host.secrets[2][1]));
    packet[44] ^= 1;
    try t.expectError(error.AuthenticationFailed, decryptPacket(packet, host.secrets[2][0]));

    // Delay the reference server's application-level CRYPTO until after the
    // Engine's one completion event has been consumed and acknowledged.
    var post_bytes: usize = 0;
    var local_work: usize = 0;
    for (0..2048) |_| {
        tick += 1;
        try t.expectEqual(@as(i32, 1), reference_advance(reference.?));
        post_bytes += try transferReference(reference.?, &host, true);
        const wait = try engine.advance(.{ .value = tick }, .{ .input = .{ .value = 1 } });
        if (wait == .local_work) local_work += 1;
        try host.pump();
    }
    if (tickets) {
        try t.expect(post_bytes > 0);
        try t.expect(local_work > 0);
    } else try t.expectEqual(@as(usize, 0), post_bytes);
    try t.expectEqual(@as(usize, 1), host.completions);
    try t.expect(try engine.isReady());
    try checkLedgers(reference.?, &host);
    // TLS KeyUpdate is forbidden in QUIC. It must poison the provider owner,
    // even after readiness; no duplicate completion or plaintext is delivered.
    const key_update = [_]u8{ 24, 0, 0, 1, 0 };
    try t.expectEqual(key_update.len, (try engine.offerCrypto(.application, &key_update)).accepted.value);
    var terminal = false;
    for (0..16) |_| {
        tick += 1;
        _ = engine.advance(.{ .value = tick }, .{ .input = .{ .value = 1 } }) catch |err| {
            try t.expectEqual(error.NativeFailure, err);
            terminal = true;
            break;
        };
        try host.pump();
    }
    try t.expect(terminal);
    try t.expectError(error.NativeFailure, engine.isReady());
    try t.expectEqual(@as(usize, 1), host.completions);
}
test "both Engine roles interoperate with a direct OpenSSL peer and decrypt its protected QUIC packet" {
    try independentPeer(false, false);
    try independentPeer(true, false);
}
test "post-handshake tickets are driven locally without a second completion and KeyUpdate is rejected" {
    try independentPeer(false, true);
}

fn cancelAtEvent(server_side: bool, ordinal: usize) !bool {
    var hooks: tls.TestHooks = .{};
    var audit: LifetimeAllocator = .{ .underlying = t.allocator, .hooks = &hooks };
    var client = try Engine.init(if (server_side) t.allocator else audit.allocator(), try c.normalize(config(false, false), &.{}, .{}, tls.capabilities()));
    defer client.deinit() catch unreachable;
    var server = try Engine.init(if (server_side) audit.allocator() else t.allocator, try c.normalize(config(true, false), &.{}, .{}, tls.capabilities()));
    defer server.deinit() catch unreachable;
    const chosen = if (server_side) &server else &client;
    try chosen.testingSetHooks(&hooks);
    var ch: Host = .{ .engine = &client, .peer = &server, .expected_parameters = config(true, false).local_parameters };
    defer std.crypto.secureZero(u8, std.mem.asBytes(&ch.secrets));
    var sh: Host = .{ .engine = &server, .peer = &client, .expected_parameters = config(false, false).local_parameters };
    defer std.crypto.secureZero(u8, std.mem.asBytes(&sh.secrets));
    var events: usize = 0;
    var tick: u64 = 1;
    while (tick < 2000) : (tick += 1) {
        for ([_]*Host{ &ch, &sh }) |host| {
            while (try host.engine.nextEvent()) |event| {
                if (host.engine == chosen) {
                    events += 1;
                    if (events == ordinal) {
                        try t.expect(!try chosen.isReady());
                        try chosen.cancel();
                        try chosen.cancel();
                        try t.expectError(error.Canceled, chosen.isReady());
                        try t.expectError(error.Canceled, chosen.acknowledge(event.id));
                        try t.expectError(error.Canceled, chosen.offerCrypto(.application, &.{1}));
                        try t.expectError(error.Canceled, chosen.advance(.{ .value = tick }, .{}));
                        try t.expectEqual(@as(usize, 0), host.completions);
                        try chosen.deinit();
                        try chosen.deinit();
                        try t.expectEqual(@as(usize, 4), audit.allocations);
                        try t.expectEqual(audit.allocations, audit.frees);
                        try t.expect(hooks.provider_destroyed and hooks.input_cleared_after_provider);
                        try t.expect(!audit.freed_before_provider and audit.payload_cleared and audit.input_cleared);
                        return true;
                    }
                }
                try host.engine.consume(event.id, .{ .context = host, .accept = Host.accept });
                try host.engine.acknowledge(event.id);
            }
        }
        _ = try client.advance(.{ .value = tick }, .{});
        _ = try server.advance(.{ .value = tick }, .{});
        if (try client.isReady() and try server.isReady()) return false;
    }
    return error.IncompleteHandshake;
}
test "cancel at every borrowed handshake event in both roles denies readiness and disposes custody once" {
    for ([_]bool{ false, true }) |server_side| {
        var ordinal: usize = 1;
        while (ordinal < 64 and try cancelAtEvent(server_side, ordinal)) : (ordinal += 1) {}
        // Each role must expose CRYPTO, parameters, four secrets and completion.
        try t.expect(ordinal >= 8 and ordinal < 64);
    }
}
test "surplus Initial bytes cannot hide in a lease or remain queued across level advancement" {
    for ([_]bool{ false, true }) |server_side| for ([_]usize{ 1, 16384 }) |budget| {
        var client = try create(config(false, false));
        defer client.deinit() catch unreachable;
        var server = try create(config(true, false));
        defer server.deinit() catch unreachable;
        var ch: Host = .{ .engine = &client, .peer = &server, .expected_parameters = config(true, false).local_parameters, .surplus_initial = server_side };
        defer std.crypto.secureZero(u8, std.mem.asBytes(&ch.secrets));
        var sh: Host = .{ .engine = &server, .peer = &client, .expected_parameters = config(false, false).local_parameters, .surplus_initial = !server_side };
        defer std.crypto.secureZero(u8, std.mem.asBytes(&sh.secrets));
        const chosen = if (server_side) &server else &client;
        var rejected = false;
        var tick: u64 = 1;
        outer: while (tick < 20000) : (tick += 1) {
            try ch.pump();
            try sh.pump();
            for ([_]*Engine{ &client, &server }) |engine| {
                _ = engine.advance(.{ .value = tick }, .{ .input = .{ .value = budget } }) catch |err| {
                    try t.expect(engine == chosen);
                    try t.expectEqual(error.UnexpectedLevel, err);
                    rejected = true;
                    break :outer;
                };
            }
        }
        try t.expect(rejected);
        try t.expectError(error.UnexpectedLevel, chosen.isReady());
        try t.expectError(error.UnexpectedLevel, chosen.offerCrypto(.application, &.{1}));
        try t.expectEqual(@as(usize, 0), ch.completions);
        try t.expectEqual(@as(usize, 0), sh.completions);
    };
}
