//! Pure retry/buffer policy. Never weakens identity, changes samples or owns I/O.
const std = @import("std");
pub const Decision = union(enum) { stop, retry: u32 };
pub const Observation = struct { delivery_gap_ms: u64 = 0, callback_frames: usize = 0 };
pub const maximum_reserve_frames: u32 = 11520;
pub const queue_headroom_frames: u32 = 480; // Two normal 5 ms records at 48 kHz.
pub const maximum_queue_frames = maximum_reserve_frames + queue_headroom_frames;
pub fn queueLimit(reserve_ceiling: u32) !u32 {
    if (reserve_ceiling < 240 or reserve_ceiling > maximum_reserve_frames) return error.InvalidRecoveryBudget;
    return reserve_ceiling + queue_headroom_frames;
}

test "reserve ceiling leaves bounded room for publication bursts" {
    for ([_]u32{ 240, 960, 1920, 5760, 11520 }) |ceiling| {
        const limit = try queueLimit(ceiling);
        try std.testing.expect(ceiling + 240 <= limit);
        try std.testing.expectEqual(@as(u32, 480), limit - ceiling);
        try std.testing.expect(limit <= maximum_queue_frames);
    }
    try std.testing.expectError(error.InvalidRecoveryBudget, queueLimit(0));
    try std.testing.expectError(error.InvalidRecoveryBudget, queueLimit(std.math.maxInt(u32)));
}
/// Serialized local deadline. Cancellation wins even on the expiry boundary.
/// The owner waits only the returned slice, then samples clock and flags again.
pub const Backoff = struct {
    deadline: u64,
    previous: u64,
    pub const Step = union(enum) { ready, canceled, wait_ms: u32 };
    pub fn init(now: u64, delay_ms: u32) !Backoff {
        return .{ .deadline = try std.math.add(u64, now, delay_ms), .previous = now };
    }
    pub fn poll(self: *Backoff, now: u64, canceled: bool) !Step {
        if (now < self.previous) return error.ClockRegressed;
        self.previous = now;
        if (canceled) return .canceled;
        if (now >= self.deadline) return .ready;
        return .{ .wait_ms = @intCast(@min(self.deadline - now, 10)) };
    }
};

test "retry waiting uses one deadline and cancellation wins at expiry" {
    var wait = try Backoff.init(1000, 250);
    try std.testing.expectEqual(@as(u32, 10), (try wait.poll(1000, false)).wait_ms);
    try std.testing.expectEqual(@as(u32, 3), (try wait.poll(1247, false)).wait_ms);
    const before = wait;
    try std.testing.expectError(error.ClockRegressed, wait.poll(1246, false));
    try std.testing.expectEqualDeep(before, wait);
    try std.testing.expect(try wait.poll(1250, true) == .canceled);
    var expired = try Backoff.init(1000, 250);
    try std.testing.expect(try expired.poll(1251, false) == .ready);
    try std.testing.expectError(error.Overflow, Backoff.init(std.math.maxInt(u64), 1));
}
pub const Policy = struct {
    prefill_frames: u32,
    max_prefill_frames: u32,
    failures: u32 = 0,
    pub fn init(initial: u32, maximum: u32) !Policy {
        if (initial < 240 or initial > maximum or maximum > 11520) return error.InvalidRecoveryBudget;
        return .{ .prefill_frames = initial, .max_prefill_frames = maximum };
    }
    pub fn failed(self: *Policy, err: anyerror, listener: bool, active_ms: u64) Decision {
        return self.failedObserved(err, listener, active_ms, .{});
    }
    pub fn failedObserved(self: *Policy, err: anyerror, listener: bool, active_ms: u64, observed: Observation) Decision {
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
            // Retain 20 ms minimum growth; a measured larger worker-delivery gap
            // can skip inadequate intermediate retries. One millisecond covers
            // timestamp flooring, two callback requests cover phase/burst margin.
            // This is a censored observation, not a bound on a network outage.
            const bounded_gap: u32 = @intCast(@min(observed.delivery_gap_ms, 240));
            const gap_frames = bounded_gap * 48;
            const callback: u32 = @intCast(@min(observed.callback_frames, 11520));
            const measured = ((gap_frames + 48 + 2 * callback + 239) / 240) * 240;
            self.prefill_frames = @min(self.max_prefill_frames, @max(self.prefill_frames + 960, measured));
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

test "measured reserve skips inadequate retries, rounds up and respects every budget" {
    var p = try Policy.init(1920, 5760);
    _ = p.failedObserved(error.PlaybackStarved, false, 100, .{ .delivery_gap_ms = 80, .callback_frames = 240 });
    try std.testing.expectEqual(@as(u32, 4560), p.prefill_frames); // 95 ms.
    _ = p.failedObserved(error.PlaybackStarved, false, 100, .{ .delivery_gap_ms = std.math.maxInt(u64), .callback_frames = std.math.maxInt(usize) });
    try std.testing.expectEqual(@as(u32, 5760), p.prefill_frames);
    var large_callback = try Policy.init(960, 11520);
    _ = large_callback.failedObserved(error.PlaybackStarved, false, 0, .{ .callback_frames = 4096 });
    try std.testing.expectEqual(@as(u32, 8400), large_callback.prefill_frames);
    var no_change = try Policy.init(1920, 5760);
    _ = no_change.failedObserved(error.TransportFailure, false, 0, .{ .delivery_gap_ms = 200, .callback_frames = 240 });
    try std.testing.expectEqual(@as(u32, 1920), no_change.prefill_frames);
    for ([_]u32{ 240, 960, 1920, 5760, 11520 }) |maximum| {
        var bounded = try Policy.init(240, maximum);
        for (0..500) |gap| {
            _ = bounded.failedObserved(error.PlaybackStarved, false, 0, .{ .delivery_gap_ms = gap, .callback_frames = gap * 10 });
            try std.testing.expect(bounded.prefill_frames <= maximum and bounded.prefill_frames >= 240);
        }
    }
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
