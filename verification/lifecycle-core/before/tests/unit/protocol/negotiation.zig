//! Exercise both roles against explicit record-order and terminal-error contracts.
//! Host authentication/drain calls are attestations; no physical devices run here.
const std = @import("std");
const core = @import("lan_audio");
const v2 = core.wire_v2;
const Gate = core.Negotiation;
const id: v2.StreamId = @splat(7);
const expect = std.testing.expect;

fn streaming(role: Gate.Role, format: core.Format) !Gate {
    var gate = Gate.init(role);
    try gate.authorizeChannel();
    var bytes: [64]u8 = undefined;
    const data: Gate.Direction = if (role == .sender) .outgoing else .incoming;
    const reverse: Gate.Direction = if (role == .sender) .incoming else .outgoing;
    try gate.apply(data, try v2.parse(try v2.encodeProfile(&bytes, .offer, id, format)));
    try gate.apply(reverse, try v2.parse(try v2.encodeProfile(&bytes, .accept, id, format)));
    return gate;
}

test "v2 both roles preserve partial-block frontier and require receiver drain" {
    var sender = try streaming(.sender, .{});
    var receiver = try streaming(.receiver, .{});
    var bytes: [64]u8 = undefined;
    const audio = try v2.parse(try v2.encodeAudio(&bytes, id, 0, &.{ 0.25, -0.25 }, .{}));
    try sender.apply(.outgoing, audio);
    try receiver.apply(.incoming, audio);
    const end = try v2.parse(try v2.encodeControl(&bytes, .end, id, 1));
    try sender.apply(.outgoing, end);
    try receiver.apply(.incoming, end);
    try receiver.confirmDrained();
    try receiver.confirmDrained(); // Idempotent attestation while draining.
    const ack = try v2.parse(try v2.encodeControl(&bytes, .ack, id, 1));
    try receiver.apply(.outgoing, ack);
    try sender.apply(.incoming, ack);
    try expect(sender.phase == .complete and receiver.phase == .complete);
    try expect(sender.next_frame == 1 and receiver.next_frame == 1);
    try std.testing.expectError(error.InvalidState, receiver.apply(.outgoing, ack));
    try expect(receiver.phase == .failed);
}

test "v2 unauthorized, wrong-role and altered-accept records fail closed" {
    var bytes: [64]u8 = undefined;
    const offer = try v2.parse(try v2.encodeProfile(&bytes, .offer, id, .{}));
    var untrusted = Gate.init(.receiver);
    try std.testing.expectError(error.Unauthenticated, untrusted.apply(.incoming, offer));
    try expect(untrusted.phase == .failed);
    try std.testing.expectError(error.InvalidState, untrusted.authorizeChannel());
    var wrong = Gate.init(.sender);
    try wrong.authorizeChannel();
    try std.testing.expectError(error.WrongDirection, wrong.apply(.incoming, offer));
    var sender = Gate.init(.sender);
    try sender.authorizeChannel();
    try sender.apply(.outgoing, offer);
    const altered = try v2.parse(try v2.encodeProfile(&bytes, .accept, id, .{ .sample_rate = 96000 }));
    try std.testing.expectError(error.FormatMismatch, sender.apply(.incoming, altered));
    try expect(sender.format.sample_rate == 48000 and sender.phase == .failed);
}

test "v2 discontinuities wrong-stream oversized blocks and early ACK are terminal" {
    var bytes: [80]u8 = undefined;
    var receiver = try streaming(.receiver, .{});
    const gap = try v2.parse(try v2.encodeAudio(&bytes, id, 1, &.{ 0, 0 }, .{}));
    try std.testing.expectError(error.Discontinuous, receiver.apply(.incoming, gap));
    try expect(receiver.next_frame == 0);
    receiver = try streaming(.receiver, .{});
    const wrong = try v2.parse(try v2.encodeAudio(&bytes, @splat(9), 0, &.{ 0, 0 }, .{}));
    try std.testing.expectError(error.WrongStream, receiver.apply(.incoming, wrong));
    receiver = try streaming(.receiver, .{ .max_frames = 1 });
    const oversized = try v2.parse(try v2.encodeAudio(&bytes, id, 0, &.{ 0, 0, 0, 0 }, .{}));
    try std.testing.expectError(error.InvalidFrames, receiver.apply(.incoming, oversized));
    try expect(receiver.next_frame == 0);
    receiver = try streaming(.receiver, .{});
    const end = try v2.parse(try v2.encodeControl(&bytes, .end, id, 0));
    try receiver.apply(.incoming, end);
    const ack = try v2.parse(try v2.encodeControl(&bytes, .ack, id, 0));
    try std.testing.expectError(error.NotDrained, receiver.apply(.outgoing, ack));
    try expect(receiver.phase == .failed);
}

test "v2 empty streams complete but replay and audio-before-accept cannot" {
    var bytes: [64]u8 = undefined;
    var gate = try streaming(.receiver, .{});
    const audio = try v2.parse(try v2.encodeAudio(&bytes, id, 0, &.{ 0, 0 }, .{}));
    try gate.apply(.incoming, audio);
    try std.testing.expectError(error.Discontinuous, gate.apply(.incoming, audio));
    gate = Gate.init(.receiver);
    try gate.authorizeChannel();
    try std.testing.expectError(error.InvalidState, gate.apply(.incoming, audio));
    gate = try streaming(.receiver, .{});
    try gate.apply(.incoming, try v2.parse(try v2.encodeControl(&bytes, .end, id, 0)));
    try gate.confirmDrained();
    try gate.apply(.outgoing, try v2.parse(try v2.encodeControl(&bytes, .ack, id, 0)));
    try expect(gate.phase == .complete and gate.next_frame == 0);
}

test "v2 explicit role phase kind direction table covers 140 combinations" {
    // Sender allowed-kind bitmasks [outgoing,incoming], in Phase declaration order.
    // This is the published transition table, independent of apply's control flow.
    const allowed = [_][2]u8{ .{ 0, 0 }, .{ 1, 0 }, .{ 0, 2 }, .{ 12, 0 }, .{ 0, 16 }, .{ 0, 0 }, .{ 0, 0 } };
    const phases = [_]Gate.Phase{ .unauthorized, .ready, .offered, .streaming, .draining, .complete, .failed };
    const kinds = [_]v2.Kind{ .offer, .accept, .audio, .end, .ack };
    const directions = [_]Gate.Direction{ .outgoing, .incoming };
    for ([_]Gate.Role{ .sender, .receiver }) |role| {
        for (phases, 0..) |phase, p| {
            for (kinds, 0..) |kind, k| {
                for (directions, 0..) |direction, d| {
                    var bytes: [64]u8 = undefined;
                    const record = switch (kind) {
                        .offer, .accept => try v2.encodeProfile(&bytes, kind, id, .{}),
                        .audio => try v2.encodeAudio(&bytes, id, 0, &.{ 0, 0 }, .{}),
                        .end, .ack => try v2.encodeControl(&bytes, kind, id, 0),
                    };
                    // Deliberate state injection checks each abstract table row;
                    // separate tests establish that real workflows reach them.
                    var gate: Gate = .{ .role = role, .phase = phase, .stream = id, .drained = phase == .draining };
                    const direction_index = if (role == .sender) d else 1 - d;
                    const permitted = allowed[p][direction_index] & (@as(u8, 1) << @as(u3, @intCast(k))) != 0;
                    if (gate.apply(direction, try v2.parse(record))) |_| {
                        try expect(permitted);
                    } else |_| {
                        try expect(!permitted and gate.phase == .failed);
                        try expect(gate.next_frame == 0);
                    }
                }
            }
        }
    }
}
