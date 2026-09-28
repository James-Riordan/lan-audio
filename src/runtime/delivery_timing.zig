//! Media-worker-owned local timing, read by control only after worker join.
//! No packet timestamps, cross-host subtraction or audio callback clock queries.
const std = @import("std");
pub const Timing = struct {
    last_publication_ms: ?u64 = null,
    max_publication_gap_ms: u64 = 0,
    max_receive_ms: u64 = 0,
    starvation_gap_ms: u64 = 0,
    published_frames: u64 = 0,
    playback_started_ms: ?u64 = null,
    playback_observed_ms: ?u64 = null,
    observed_playback_frames: u64 = 0,
    max_playback_lead_frames: u64 = 0,
    max_frames_between_observations: u64 = 0,

    pub fn published(self: *Timing, now: u64, frames: u32) !void {
        const total = try std.math.add(u64, self.published_frames, frames);
        if (self.last_publication_ms) |previous| {
            if (now < previous) return error.ClockRegressed;
            self.max_publication_gap_ms = @max(self.max_publication_gap_ms, now - previous);
        }
        self.last_publication_ms = now;
        self.published_frames = total;
    }
    /// Sample the origin BEFORE opening playback_ready. This makes elapsed time
    /// conservative if the worker is descheduled before it opens the gate.
    pub fn beginPlayback(self: *Timing, now: u64) !void {
        if (self.playback_started_ms != null) return error.PlaybackAlreadyStarted;
        if (self.last_publication_ms) |previous| if (now < previous) return error.ClockRegressed;
        self.playback_started_ms = now;
    }
    /// Producer owner only: sample queue occupancy BEFORE sampling now. The
    /// released queue frontier is safe to observe while callbacks run; callback
    /// plain counters are not. Lead is relative to nominal 48 kHz consumption,
    /// not an acoustic timestamp or a calibrated independent-clock estimate.
    pub fn observePlayback(self: *Timing, queued: u32, now: u64) !void {
        const start = self.playback_started_ms orelse return;
        if (now < (self.playback_observed_ms orelse start)) return error.ClockRegressed;
        if (queued > self.published_frames) return error.InvalidPlaybackAccounting;
        const consumed = self.published_frames - queued;
        if (consumed < self.observed_playback_frames) return error.InvalidPlaybackAccounting;
        const nominal: u128 = @as(u128, now - start) * 48;
        const lead: u64 = if (consumed > nominal) @intCast(consumed - nominal) else 0;
        self.max_playback_lead_frames = @max(self.max_playback_lead_frames, lead);
        self.max_frames_between_observations = @max(self.max_frames_between_observations, consumed - self.observed_playback_frames);
        self.observed_playback_frames = consumed;
        self.playback_observed_ms = now;
    }
    pub fn received(self: *Timing, started: u64, ended: u64) !void {
        if (ended < started) return error.ClockRegressed;
        self.max_receive_ms = @max(self.max_receive_ms, ended - started);
    }
    pub fn starved(self: *Timing, now: u64) !void {
        if (self.last_publication_ms) |previous| {
            if (now < previous) return error.ClockRegressed;
            self.starvation_gap_ms = now - previous;
        }
    }
    pub fn observedGap(self: Timing) u64 {
        return @max(self.max_publication_gap_ms, self.starvation_gap_ms);
    }
};

test "publication gaps exclude startup and preserve state on clock regression" {
    var timing: Timing = .{};
    try timing.starved(200);
    try std.testing.expectEqual(@as(u64, 0), timing.observedGap());
    try timing.published(10_000, 240);
    try timing.published(10_005, 240);
    try timing.received(10_005, 10_013);
    try timing.published(10_080, 240);
    try timing.starved(10_180);
    try std.testing.expectEqual(@as(u64, 75), timing.max_publication_gap_ms);
    try std.testing.expectEqual(@as(u64, 8), timing.max_receive_ms);
    try std.testing.expectEqual(@as(u64, 100), timing.observedGap());
    const before = timing;
    try std.testing.expectError(error.ClockRegressed, timing.published(1, 240));
    try std.testing.expectError(error.ClockRegressed, timing.received(2, 1));
    try std.testing.expectError(error.ClockRegressed, timing.starved(1));
    try std.testing.expectEqualDeep(before, timing);
}

test "worker queue frontiers expose demand lead without callback counter races" {
    var timing: Timing = .{};
    try timing.published(1000, 2880);
    try timing.beginPlayback(1000);
    // The backend requests its entire 60 ms reserve in the next millisecond.
    try timing.observePlayback(0, 1001);
    try std.testing.expectEqual(@as(u64, 2832), timing.max_playback_lead_frames);
    try std.testing.expectEqual(@as(u64, 2880), timing.max_frames_between_observations);
    try timing.published(1005, 240);
    try timing.observePlayback(240, 1005);
    try timing.observePlayback(0, 1020);
    try std.testing.expectEqual(@as(u64, 3120), timing.observed_playback_frames);
    try std.testing.expectEqual(@as(u64, 2832), timing.max_playback_lead_frames);
    const before = timing;
    try std.testing.expectError(error.ClockRegressed, timing.observePlayback(0, 1019));
    try std.testing.expectError(error.InvalidPlaybackAccounting, timing.observePlayback(1, 1021));
    try std.testing.expectError(error.PlaybackAlreadyStarted, timing.beginPlayback(1021));
    try std.testing.expectEqualDeep(before, timing);
    // Extreme elapsed time has no multiplication overflow or fabricated lead.
    try timing.observePlayback(0, std.math.maxInt(u64));
    timing.published_frames = std.math.maxInt(u64);
    const exhausted = timing;
    try std.testing.expectError(error.Overflow, timing.published(std.math.maxInt(u64), 1));
    try std.testing.expectEqualDeep(exhausted, timing);
}
