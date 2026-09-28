const std = @import("std");
const c = @import("tls_quic").contract;
const t = std.testing;
const caps: c.Capabilities = .{ .recordless = true, .tls13 = true, .quic_v1 = true, .aes128gcm_sha256 = true, .runtime = .available };

fn config() c.Config {
    return .{
        .policy = .{ .client = .{ .trust_file = "trust.pem", .peer = .{ .dns = "example.test" } } },
        .alpn = "test-quic",
        .local_parameters = &.{ 1, 2, 3 },
        .wall_time = .{ .value = 1_800_000_000 },
        .now = .{ .value = 100 },
    };
}

test "T01 unavailable or unknown provider rejects before construction" {
    try t.expectError(error.UnavailableCapability, c.normalize(config(), &.{}, .{}, .{}));
    var unknown = caps;
    unknown.runtime = .unknown;
    try t.expectError(error.UnknownCapability, c.normalize(config(), &.{}, .{}, unknown));
    var no_suite = caps;
    no_suite.aes128gcm_sha256 = false;
    try t.expectError(error.UnavailableCapability, c.normalize(config(), &.{}, .{}, no_suite));
}

test "T01 explicit normalization and authority precede immutable plan" {
    const plan = try c.normalize(config(), &.{}, .{}, caps);
    try plan.verify(caps);
    try t.expectEqual(@as(u64, 10_000_000_100), plan.deadline.value);
    try t.expectEqual(c.schema_version, plan.schema);
    try t.expectError(error.UnauthorizedOverride, c.normalize(config(), &.{.{ .policy = .{ .server = .{ .credentials = .{ .certificate_file = "c", .private_key_file = "k" } } } }}, .{}, caps));
    try t.expectError(error.UnauthorizedOverride, c.normalize(config(), &.{.{ .profile = .{} }}, .{}, caps));
    try t.expectError(error.UnknownOption, c.normalize(config(), &.{.unknown}, .{}, caps));
    try t.expectError(error.DuplicateOverride, c.normalize(config(), &.{ .{ .alpn = "a" }, .{ .alpn = "b" } }, .{ .alpn = true }, caps));
    const changed = try c.normalize(config(), &.{.{ .alpn = "h3" }}, .{ .alpn = true }, caps);
    try t.expectEqualStrings("h3", changed.config.alpn);
    try t.expect(!std.mem.eql(u8, &plan.fingerprint, &changed.fingerprint));
    var explicit_zero = config().limits;
    explicit_zero.input_bytes.value = 0;
    try t.expectError(error.InvalidCapacity, c.normalize(config(), &.{.{ .limits = explicit_zero }}, .{ .limits = true }, caps));
    var mutated = plan;
    mutated.config.alpn = "changed-after-hash";
    try t.expectError(error.StalePlan, mutated.verify(caps));
    mutated = plan;
    mutated.schema += 1;
    try t.expectError(error.StalePlan, mutated.verify(caps));
}

test "T01 policy ALPN time limits and unsupported protocol reject explicitly" {
    var cfg = config();
    cfg.alpn = "";
    try t.expectError(error.InvalidAlpn, c.normalize(cfg, &.{}, .{}, caps));
    cfg = config();
    cfg.alpn = &@as([256]u8, @splat('a'));
    try t.expectError(error.InvalidAlpn, c.normalize(cfg, &.{}, .{}, caps));
    cfg = config();
    cfg.alpn = &.{ 0, 255 };
    _ = try c.normalize(cfg, &.{}, .{}, caps);
    cfg = config();
    cfg.policy.client.trust_file = "";
    try t.expectError(error.InvalidPolicy, c.normalize(cfg, &.{}, .{}, caps));
    cfg = config();
    cfg.policy.client.peer = .{ .dns = "*.example.test" };
    try t.expectError(error.InvalidIdentity, c.normalize(cfg, &.{}, .{}, caps));
    cfg = config();
    cfg.policy.client.peer = .{ .ip = "999.1.1.1" };
    try t.expectError(error.InvalidIdentity, c.normalize(cfg, &.{}, .{}, caps));
    cfg = config();
    cfg.policy.client.peer = .{ .ip = "::1" };
    _ = try c.normalize(cfg, &.{}, .{}, caps);
    cfg = config();
    cfg.now.value = std.math.maxInt(u64);
    try t.expectError(error.InvalidTime, c.normalize(cfg, &.{}, .{}, caps));
    cfg = config();
    cfg.wall_time.value = 0;
    try t.expectError(error.InvalidTime, c.normalize(cfg, &.{}, .{}, caps));
    cfg = config();
    cfg.timeout.value = 0;
    try t.expectError(error.InvalidTime, c.normalize(cfg, &.{}, .{}, caps));
    cfg = config();
    cfg.profile.version = @fromBackingInt(@intCast(2));
    try t.expectError(error.UnavailableCapability, c.normalize(cfg, &.{}, .{}, caps));
    cfg = config();
    cfg.requirements.early_data = true;
    try t.expectError(error.UnavailableCapability, c.normalize(cfg, &.{}, .{}, caps));
    cfg = config();
    cfg.requirements.provider_memory_limit = .{ .value = 1 };
    try t.expectError(error.UnavailableCapability, c.normalize(cfg, &.{}, .{}, caps));
    cfg = config();
    cfg.limits.event_slots = std.math.maxInt(usize);
    try t.expectError(error.InvalidCapacity, c.normalize(cfg, &.{}, .{}, caps));
}

test "T01 accepted prefixes clocks and owner identity are checked" {
    const transfer = c.Transfer{ .accepted = .{ .value = 3 }, .wait = .local_work };
    try t.expectEqualSlices(u8, "abc", try transfer.acceptedPrefix("abcdef"));
    try t.expectError(error.ProviderOverconsumption, transfer.acceptedPrefix("a"));
    const a = try c.freshOwner();
    const b = try c.freshOwner();
    try t.expect(!c.OwnerId.eql(a, b));
    try t.expectEqual(@as(u64, 0), (c.MonotonicNs{ .value = 999 }).toMicrosEarly());
    try t.expectEqual(@as(u64, 1), (c.MonotonicNs{ .value = 1000 }).toMicrosEarly());
}

test "T01 plan hash matches independent little-endian length-prefixed oracle" {
    const plan = try c.normalize(config(), &.{}, .{}, caps);
    // Python hashlib + struct.pack('<Q') over the documented field order.
    const expected = [_]u8{ 0x85, 0x63, 0xda, 0xb1, 0x91, 0x45, 0x34, 0x5e, 0x04, 0x82, 0xe2, 0xfe, 0x92, 0xde, 0x29, 0x86, 0x59, 0x04, 0x62, 0x94, 0xa0, 0x1d, 0x7e, 0x25, 0x0c, 0x13, 0x04, 0x22, 0xcd, 0x2b, 0x27, 0x3b };
    try t.expectEqualSlices(u8, &expected, &plan.fingerprint);
    var borrowed = [_]u8{ 1, 2, 3 };
    var cfg = config();
    cfg.local_parameters = &borrowed;
    const bound = try c.normalize(cfg, &.{}, .{}, caps);
    borrowed[1] = 9;
    try t.expectError(error.StalePlan, bound.verify(caps));
    cfg = config();
    cfg.policy = .{ .server = .{ .credentials = .{ .certificate_file = "cert", .private_key_file = "key" } } };
    _ = try c.normalize(cfg, &.{}, .{}, caps);
    cfg.policy.server.client_authentication = .{ .required = "" };
    try t.expectError(error.InvalidPolicy, c.normalize(cfg, &.{}, .{}, caps));
    cfg.policy.server.client_authentication = .{ .required = "client-trust" };
    _ = try c.normalize(cfg, &.{}, .{}, caps);
}
