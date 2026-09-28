//! Pure retry/buffer policy. Never weakens identity, changes samples or owns I/O.
const std = @import("std");
pub const Decision = union(enum) { stop, retry: u32 };
pub const Policy = struct {
    prefill_frames: u32,
    max_prefill_frames: u32,
    failures: u32 = 0,
    pub fn init(initial: u32, maximum: u32) !Policy {
        if (initial < 240 or initial > maximum or maximum > 11520) return error.InvalidRecoveryBudget;
        return .{ .prefill_frames = initial, .max_prefill_frames = maximum };
    }
    pub fn failed(self: *Policy, err: anyerror, listener: bool, active_ms: u64) Decision {
        const retry = switch (err) {
            error.PlaybackStarved, error.PlaybackBacklog, error.NativeAudioFault, error.ChannelClosed, error.TransportFailure, error.SystemFailure, error.Deadline, error.OperationDeadline, error.DeadlineExceeded, error.TlsFailure, error.PlaybackStalled, error.DeviceInit, error.DeviceStart => true,
            // A listener survives rejected peers. A client never retries a known
            // approval/identity failure as though it were a transient network loss.
            error.PeerAuthentication, error.AlpnMismatch, error.WrongPeer, error.UnauthorizedPeer, error.WrongRole => listener,
            else => false,
        };
        if (!retry) return .stop;
        if (active_ms >= 30_000) self.failures = 0;
        if (err == error.PlaybackStarved) {
            // Increase reserve in whole 20 ms steps, only between closed streams.
            // Never alter an active queue or exceed the caller's latency budget.
            self.prefill_frames = @min(self.max_prefill_frames, self.prefill_frames + 960);
        }
        const delay: u32 = @as(u32, 250) << @as(u5, @intCast(@min(self.failures, 4)));
        self.failures +|= 1;
        return .{ .retry = delay };
    }
};

test "retry schedule is bounded and identity/cleanup faults cannot enable retry" {
    var p = try Policy.init(960, 5760);
    for ([_]u32{ 250, 500, 1000, 2000, 4000, 4000 }) |expected|
        try std.testing.expectEqual(expected, p.failed(error.TransportFailure, false, 0).retry);
    for ([_]anyerror{ error.WrongPeer, error.PeerAuthentication, error.InvalidConfig, error.CleanupBlocked, error.CloseFailure, error.Canceled }) |err|
        try std.testing.expect(p.failed(err, false, 0) == .stop);
    try std.testing.expectEqual(@as(u32, 250), p.failed(error.TransportFailure, false, 30_000).retry);
    try std.testing.expect(p.failed(error.WrongPeer, true, 0) == .retry);
}
test "starvation adds bounded reserve without changing the requested budget" {
    var p = try Policy.init(960, 2400);
    _ = p.failed(error.PlaybackStarved, false, 0);
    try std.testing.expectEqual(@as(u32, 1920), p.prefill_frames);
    for (0..100) |_| _ = p.failed(error.PlaybackStarved, false, 0);
    try std.testing.expectEqual(@as(u32, 2400), p.prefill_frames);
    try std.testing.expectEqual(@as(u32, 2400), p.max_prefill_frames);
    try std.testing.expectError(error.InvalidRecoveryBudget, Policy.init(960, 480));
    try std.testing.expectError(error.InvalidRecoveryBudget, Policy.init(1, 11521));
}
