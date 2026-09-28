//! Media-worker-owned local timing, read by control only after worker join.
//! No packet timestamps, cross-host subtraction or audio callback clock queries.
const std = @import("std");
pub const Timing = struct {
    last_publication_ms: ?u64 = null,
    max_publication_gap_ms: u64 = 0,
    max_receive_ms: u64 = 0,
    starvation_gap_ms: u64 = 0,

    pub fn published(self: *Timing, now: u64) !void {
        if (self.last_publication_ms) |previous| {
            if (now < previous) return error.ClockRegressed;
            self.max_publication_gap_ms = @max(self.max_publication_gap_ms, now - previous);
        }
        self.last_publication_ms = now;
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
    try timing.published(10_000);
    try timing.published(10_005);
    try timing.received(10_005, 10_013);
    try timing.published(10_080);
    try timing.starved(10_180);
    try std.testing.expectEqual(@as(u64, 75), timing.max_publication_gap_ms);
    try std.testing.expectEqual(@as(u64, 8), timing.max_receive_ms);
    try std.testing.expectEqual(@as(u64, 100), timing.observedGap());
    const before = timing;
    try std.testing.expectError(error.ClockRegressed, timing.published(1));
    try std.testing.expectError(error.ClockRegressed, timing.received(2, 1));
    try std.testing.expectError(error.ClockRegressed, timing.starved(1));
    try std.testing.expectEqualDeep(before, timing);
}
