//! Foreground signal flags and worker-only pacing. No process-wide timer tweak.
const std = @import("std");
const c = @import("platform_c");
pub var abort: std.atomic.Value(bool) = .init(false);
pub var stop: std.atomic.Value(bool) = .init(false);
pub var graceful_sender: std.atomic.Value(bool) = .init(false);
var installed = false; // Serialized foreground owner; handler never reads this.
fn requested(urgent: c_int) callconv(.c) void {
    if (urgent != 0 or stop.load(.monotonic) or !graceful_sender.load(.acquire)) abort.store(true, .release);
    stop.store(true, .release);
}
pub fn install() !void {
    if (installed) return error.SignalInstall;
    abort.store(false, .release);
    stop.store(false, .release);
    graceful_sender.store(false, .release);
    if (c.la_control_install(requested) != 0) return error.SignalInstall;
    installed = true;
}
pub fn restore() void {
    c.la_control_restore();
    installed = false;
}
pub fn wallSeconds() !i64 {
    const now = c.la_wall_seconds();
    if (now <= 0) return error.ClockFailure;
    return now;
}
pub const Pacer = struct {
    native: c.la_pacer = .{ .timer = 0 },
    pub fn init() !Pacer {
        var self: Pacer = .{};
        if (c.la_pacer_init(&self.native) != 0) return error.TimerInit;
        return self;
    }
    pub fn wait(self: *Pacer, ms: u32) !void {
        if (c.la_pacer_wait(&self.native, ms) != 0) return error.TimerWait;
    }
    pub fn deinit(self: *Pacer) void {
        c.la_pacer_close(&self.native);
    }
};

test "foreground handlers and timer can be released and reacquired" {
    for (0..3) |_| {
        try install();
        stop.store(true, .release);
        try std.testing.expectError(error.SignalInstall, install());
        try std.testing.expect(stop.load(.acquire));
        restore();
        restore();
        var pacer = try Pacer.init();
        try pacer.wait(1);
        try std.testing.expectError(error.TimerWait, pacer.wait(0));
        pacer.deinit();
        pacer.deinit();
        try std.testing.expectError(error.TimerWait, pacer.wait(1));
    }
    try std.testing.expect(try wallSeconds() > 0);
}
