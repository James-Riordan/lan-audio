//! Independent authorization truth table plus actual v2 record transitions.
//! TLS evidence here is synthetic. No certificate verification or devices run.
const std = @import("std");
const core = @import("lan_audio");
const security = @import("peer_policy");
const admission = @import("channel_admission");
const eq = std.testing.expectEqual;
const expect = std.testing.expect;
const peer_a: security.Fingerprint = @splat(0x11);
const peer_b: security.Fingerprint = @splat(0x22);
const stream: core.wire_v2.StreamId = @splat(7);

fn evidence(generation: u64, peer: security.Fingerprint) security.Evidence {
    return .{ .generation = generation, .mutually_authenticated = true, .verified_leaf = peer, .alpn = core.wire_v2.alpn };
}
fn policy(revision: u64, peer: security.Fingerprint) !security.Policy {
    return security.Policy.init(revision, &.{.{ .peer = peer, .roles = .{ .sender = true, .receiver = true } }});
}

test "fingerprints preserve all byte values and reject ambiguous presentation" {
    for (0..256) |value| {
        const fingerprint: security.Fingerprint = @splat(@intCast(value));
        const lower = security.formatFingerprint(fingerprint);
        try eq(fingerprint, try security.parseFingerprint(&lower));
        var upper = lower;
        for (&upper) |*byte| byte.* = std.ascii.toUpper(byte.*);
        try eq(fingerprint, try security.parseFingerprint(&upper));
        var colon: [95]u8 = undefined;
        for (0..32) |i| {
            @memcpy(colon[i * 3 ..][0..2], upper[i * 2 ..][0..2]);
            if (i < 31) colon[i * 3 + 2] = ':';
        }
        try eq(fingerprint, try security.parseFingerprint(&colon));
        colon[2] = '-';
        try std.testing.expectError(error.InvalidFingerprint, security.parseFingerprint(&colon));
    }
    const valid = security.formatFingerprint(peer_a);
    for ([_]usize{ 0, 1, 31, 32, 63 }) |length| try std.testing.expectError(error.InvalidFingerprint, security.parseFingerprint(valid[0..length]));
    for ([_]u8{ 'g', ' ', 0, 0xff, ':' }) |bad| {
        var text = valid;
        text[31] = bad;
        try std.testing.expectError(error.InvalidFingerprint, security.parseFingerprint(&text));
    }
}

test "bounded policy owns its rules and refuses duplicates and invalid roles" {
    var rules = [_]security.Rule{.{ .peer = peer_a, .roles = .{ .receiver = true } }};
    const copied = try security.Policy.init(3, &rules);
    rules[0] = .{ .peer = peer_b, .roles = .{ .sender = true } };
    const permit = try copied.authorize(5, .sender, peer_a, evidence(5, peer_a));
    try eq(peer_a, permit.peer);
    try eq(@as(u64, 3), permit.policy_revision);
    try eq(.receiver, permit.remote_role);
    try std.testing.expectError(error.WrongRole, copied.authorize(5, .receiver, peer_a, evidence(5, peer_a)));
    const empty = try security.Policy.init(1, &.{});
    try std.testing.expectError(error.UnauthorizedPeer, empty.authorize(5, .sender, peer_a, evidence(5, peer_a)));
    try std.testing.expectError(error.InvalidPolicy, security.Policy.init(0, &.{}));
    try std.testing.expectError(error.InvalidPolicy, security.Policy.init(1, &.{.{ .peer = peer_a, .roles = .{} }}));
    try std.testing.expectError(error.DuplicatePeer, security.Policy.init(1, &.{
        .{ .peer = peer_a, .roles = .{ .receiver = true } },
        .{ .peer = peer_a, .roles = .{ .sender = true } },
    }));
    var full: [security.max_peers + 1]security.Rule = undefined;
    for (&full, 0..) |*rule, i| rule.* = .{ .peer = @splat(@intCast(i)), .roles = .{ .sender = true } };
    _ = try security.Policy.init(1, full[0..security.max_peers]);
    try std.testing.expectError(error.TooManyPeers, security.Policy.init(1, &full));
    try std.testing.expectError(error.InvalidGeneration, admission.Channel.init(0, .receiver, peer_a));
}

test "independent 128-case authorization table requires every binding condition" {
    for ([_]security.Role{ .sender, .receiver }) |local_role| {
        for (0..64) |flags| {
            const same_generation = flags & 4 != 0;
            const wanted_role: security.Role = if (flags & 32 != 0)
                (if (local_role == .sender) .receiver else .sender)
            else
                local_role;
            const allowed = try security.Policy.init(1, &.{.{
                .peer = if (flags & 16 != 0) peer_a else peer_b,
                .roles = .{ .sender = wanted_role == .sender, .receiver = wanted_role == .receiver },
            }});
            var channel = try admission.Channel.init(9, local_role, peer_a);
            const initial = channel.snapshot();
            const proof: security.Evidence = .{
                .generation = if (same_generation) 9 else 8,
                .mutually_authenticated = flags & 1 != 0,
                .alpn = if (flags & 2 != 0) core.wire_v2.alpn else "jcr-audio/1",
                .verified_leaf = if (flags & 8 != 0) peer_a else peer_b,
            };
            if (channel.authorize(&allowed, proof)) |result| {
                try eq(@as(usize, 63), flags); // Independent conjunction oracle.
                try eq(.established, result);
                try eq(.ready, channel.snapshot().phase);
            } else |_| {
                try expect(flags != 63);
                if (!same_generation) try expect(std.meta.eql(initial, channel.snapshot())) else {
                    try expect(channel.snapshot().revoked);
                    try eq(@as(?security.Permit, null), channel.snapshot().permit);
                }
            }
        }
    }
}

test "repeated authorization preserves an actual negotiated frame frontier" {
    const trusted = try policy(4, peer_a);
    for ([_]security.Role{ .sender, .receiver }) |role| {
        var channel = try admission.Channel.init(13, role, peer_a);
        const proof = evidence(13, peer_a);
        try eq(.established, try channel.authorize(&trusted, proof));
        var bytes: [80]u8 = undefined;
        const direction: core.Negotiation.Direction = if (role == .sender) .outgoing else .incoming;
        const reverse: core.Negotiation.Direction = if (role == .sender) .incoming else .outgoing;
        try channel.apply(13, 4, direction, try core.wire_v2.parse(try core.wire_v2.encodeProfile(&bytes, .offer, stream, .{})));
        try channel.apply(13, 4, reverse, try core.wire_v2.parse(try core.wire_v2.encodeProfile(&bytes, .accept, stream, .{})));
        try channel.apply(13, 4, direction, try core.wire_v2.parse(try core.wire_v2.encodeAudio(&bytes, stream, 0, &.{ 0.5, -0.5, 0.25, -0.25 }, .{})));
        const before = channel.snapshot();
        for (0..32) |_| try eq(.unchanged, try channel.authorize(&trusted, proof));
        try expect(std.meta.eql(before, channel.snapshot()));
        try eq(@as(u64, 2), channel.snapshot().next_frame);
        try channel.apply(13, 4, direction, try core.wire_v2.parse(try core.wire_v2.encodeControl(&bytes, .end, stream, 2)));
        if (role == .receiver) {
            try channel.confirmDrained(13, 4);
            try channel.confirmDrained(13, 4);
        }
        try channel.apply(13, 4, reverse, try core.wire_v2.parse(try core.wire_v2.encodeControl(&bytes, .ack, stream, 2)));
        try eq(.complete, channel.snapshot().phase);
        try eq(.unchanged, try channel.authorize(&trusted, proof));
        try eq(.complete, channel.snapshot().phase);
    }
}

test "changed current identity or policy revokes without reauthorizing or resetting" {
    const trusted = try policy(1, peer_a);
    var channel = try admission.Channel.init(3, .receiver, peer_a);
    _ = try channel.authorize(&trusted, evidence(3, peer_a));
    const changed = try policy(2, peer_a);
    try std.testing.expectError(error.AuthorizationChanged, channel.authorize(&changed, evidence(3, peer_a)));
    try std.testing.expectError(error.Revoked, channel.authorize(&trusted, evidence(3, peer_a)));
    var identity = try admission.Channel.init(4, .receiver, peer_a);
    _ = try identity.authorize(&trusted, evidence(4, peer_a));
    try std.testing.expectError(error.WrongPeer, identity.authorize(&trusted, evidence(4, peer_b)));
    try expect(identity.snapshot().revoked);
    var revision = try admission.Channel.init(5, .receiver, peer_a);
    _ = try revision.authorize(&trusted, evidence(5, peer_a));
    var bytes: [64]u8 = undefined;
    const offer = try core.wire_v2.parse(try core.wire_v2.encodeProfile(&bytes, .offer, stream, .{}));
    try std.testing.expectError(error.AuthorizationChanged, revision.apply(5, 2, .incoming, offer));
    try eq(@as(u64, 0), revision.snapshot().next_frame);
    try expect(revision.snapshot().revoked);
}

test "stale platform events cannot change a replacement and repeated revocation converges" {
    const trusted = try policy(1, peer_a);
    var current = try admission.Channel.init(9, .receiver, peer_a);
    _ = try current.authorize(&trusted, evidence(9, peer_a));
    const before = current.snapshot();
    try std.testing.expectError(error.StaleGeneration, current.authorize(&trusted, evidence(8, peer_a)));
    try std.testing.expectError(error.StaleGeneration, current.revoke(8));
    var bytes: [64]u8 = undefined;
    const offer = try core.wire_v2.parse(try core.wire_v2.encodeProfile(&bytes, .offer, stream, .{}));
    try std.testing.expectError(error.StaleGeneration, current.apply(8, 1, .incoming, offer));
    try std.testing.expectError(error.StaleGeneration, current.confirmDrained(8, 1));
    try expect(std.meta.eql(before, current.snapshot()));
    try current.revoke(9);
    const revoked = current.snapshot();
    for (0..32) |_| try current.revoke(9);
    try expect(std.meta.eql(revoked, current.snapshot()));
    try std.testing.expectError(error.Revoked, current.apply(9, 1, .incoming, offer));
    try std.testing.expectError(error.Revoked, current.authorize(&trusted, evidence(9, peer_a)));
}

test "unauthorized records and invalid stream order terminate admission" {
    const trusted = try policy(1, peer_a);
    var unauthenticated = try admission.Channel.init(1, .receiver, peer_a);
    var bytes: [64]u8 = undefined;
    const offer = try core.wire_v2.parse(try core.wire_v2.encodeProfile(&bytes, .offer, stream, .{}));
    try std.testing.expectError(error.Unauthenticated, unauthenticated.apply(1, 1, .incoming, offer));
    try std.testing.expectError(error.Revoked, unauthenticated.authorize(&trusted, evidence(1, peer_a)));
    var wrong_direction = try admission.Channel.init(2, .sender, peer_a);
    _ = try wrong_direction.authorize(&trusted, evidence(2, peer_a));
    try std.testing.expectError(error.WrongDirection, wrong_direction.apply(2, 1, .incoming, offer));
    try expect(wrong_direction.snapshot().revoked);
}
