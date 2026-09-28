const std = @import("std");
const quic = @import("tls_quic");
const c = quic.contract;
const fixture = @import("provider.zig");
const Sink = struct {
    bytes: [32]u8 = @splat(0),
    fn accept(raw: *anyopaque, event: c.Event) c.ConsumeError!void {
        const self: *@This() = @ptrCast(@alignCast(raw));
        switch (event.payload) {
            .secret => |secret| @memcpy(&self.bytes, secret.bytes),
            else => return error.Rejected,
        }
    }
};
pub fn main() !void {
    const plan = try c.normalize(.{
        .policy = .{ .client = .{ .trust_file = "fixture-only-trust.pem", .peer = .{ .dns = "fixture.example" } } },
        .alpn = "fixture",
        .local_parameters = &.{1},
        .wall_time = .{ .value = 1_800_000_000 },
        .now = .{ .value = 0 },
    }, &.{}, .{}, fixture.available);
    var provider: fixture.Provider = .{};
    if (provider.construct(plan, .{})) |_| return error.MissingCapabilityAccepted else |err| {
        if (err != error.UnavailableCapability or provider.calls != 0) return error.PrematureProviderEffect;
    }
    try provider.construct(plan, fixture.available);
    const transfer = provider.consume("abcd");
    if (!std.mem.eql(u8, try transfer.acceptedPrefix("abcd"), "ab")) return error.WrongPrefix;
    var memory: [16384]u8 = undefined;
    var allocator = std.heap.FixedBufferAllocator.init(&memory);
    var queue = try quic.events.Queue.init(allocator.allocator(), .{ .event_slots = 2, .control_slots = 1, .event_payload_bytes = .{ .value = 32 }, .peer_parameter_bytes = .{ .value = 32 } });
    defer queue.deinit() catch unreachable;
    const secret: [32]u8 = @splat(0x83);
    try queue.pushSecret(.handshake, .write, .aes128gcm_sha256, &secret);
    const head = (try queue.next()).?;
    if (queue.acknowledge(head.id)) |_| return error.EarlyAcknowledgementAccepted else |err| {
        if (err != error.NotConsumed) return err;
    }
    var sink: Sink = .{};
    try queue.consume(head.id, .{ .context = &sink, .accept = Sink.accept });
    try queue.acknowledge(head.id);
    if (!std.mem.eql(u8, &sink.bytes, &secret)) return error.CustodyLost;
    try queue.cancel();
    if (queue.next()) |_| return error.CanceledOwnerRevived else |err| {
        if (err != error.Canceled) return err;
    }
}
