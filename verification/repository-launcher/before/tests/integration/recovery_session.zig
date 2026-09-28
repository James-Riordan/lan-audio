//! Explicit null callback/fixture caller of the product supervisor, never real audio.
const std = @import("std");
const stream = @import("stream_runtime");
const supervisor = @import("session_supervisor");
const policy = @import("peer_policy");
const platform = @import("platform_host");
const net = @import("network_host");
const Log = struct {
    io: std.Io,
    allocator: std.mem.Allocator,
    abort: *std.atomic.Value(bool),
    cancel_in_backoff: bool,
    canceler: ?std.Thread = null,
    timer_ready: std.atomic.Value(bool) = .init(false),
    fn completed(context: *anyopaque, event: supervisor.Event) !void {
        const self: *Log = @ptrCast(@alignCast(context));
        const r = event.report;
        const text = try std.json.Stringify.valueAlloc(self.allocator, .{
            .attempt = event.attempt,
            .prefill_frames = event.prefill_frames,
            .frames = r.frames,
            .failure = if (r.failure) |err| @errorName(err) else null,
            .lifecycle = r.lifecycle,
            .audio = r.audio,
            .active_ms = r.active_ms,
            .starved = r.starved,
            .unplayed_frames = r.unplayed_frames,
            .delivery_timing = r.delivery_timing,
        }, .{});
        defer self.allocator.free(text);
        try std.Io.File.stdout().writeStreamingAll(self.io, text);
        try std.Io.File.stdout().writeStreamingAll(self.io, "\n");
        if (self.cancel_in_backoff and self.canceler == null) {
            const Later = struct {
                fn run(log: *Log) void {
                    var timer = platform.Pacer.init() catch unreachable;
                    defer timer.deinit();
                    log.timer_ready.store(true, .release);
                    timer.wait(100) catch unreachable;
                    log.abort.store(true, .release);
                }
            };
            self.canceler = try std.Thread.spawn(.{}, Later.run, .{self});
            // Timer construction/thread startup precede the supervisor's backoff;
            // otherwise the fixture can first run after the 250 ms retry expires.
            var wait = try platform.Pacer.init();
            defer wait.deinit();
            const deadline = try net.nowMilliseconds() + 2000;
            while (!self.timer_ready.load(.acquire)) {
                if (try net.nowMilliseconds() >= deadline) return error.FixtureTimerStartup;
                try wait.wait(1);
            }
        }
    }
};
pub fn main(init: std.process.Init) !void {
    const args = try init.minimal.args.toSlice(init.arena.allocator());
    if (args.len != 5) return error.Arguments;
    const sender = std.mem.eql(u8, args[1], "sender");
    const listening = std.mem.endsWith(u8, args[4], "listener");
    var stop: std.atomic.Value(bool) = .init(false);
    var abort: std.atomic.Value(bool) = .init(false);
    const Cancel = struct {
        fn run(io: std.Io, flag: *std.atomic.Value(bool)) void {
            std.Io.sleep(io, .fromMilliseconds(600), .awake) catch unreachable;
            flag.store(true, .release);
        }
    };
    const canceler = if (std.mem.eql(u8, args[4], "cancel-handshake")) try std.Thread.spawn(.{}, Cancel.run, .{ init.io, &abort }) else null;
    defer if (canceler) |thread| thread.join();
    var log: Log = .{ .io = init.io, .allocator = init.gpa, .abort = &abort, .cancel_in_backoff = std.mem.eql(u8, args[4], "cancel-backoff") };
    defer if (log.canceler) |thread| thread.join();
    const options: stream.Options = .{
        .role = if (sender) .sender else .receiver,
        .profile = if (sender) .null_duplex else .null_playback,
        .endpoint = .{ .address = "127.0.0.1", .port = try std.fmt.parseInt(u16, args[2], 10) },
        .family = .ipv4,
        .listen = listening,
        .ca = "tests/fixtures/ca.pem",
        .certificate = if (listening) "tests/fixtures/server.pem" else "tests/fixtures/client.pem",
        .key = if (listening) "tests/fixtures/server.key" else "tests/fixtures/client.key",
        .peer_name = if (listening) null else "localhost",
        .peer_fingerprint = try policy.parseFingerprint(args[3]),
        .wall_seconds = 1_789_300_000,
        .stream_id = @splat(0),
        .seconds = if (sender) 1 else 0,
        // Python/OS scheduling jitter can exceed its requested 5 ms sleeps.
        // This case explicitly qualifies 60 ms reserve; other cases use 20 ms.
        .prefill_frames = if (std.mem.eql(u8, args[4], "jitter")) 2880 else if (std.mem.startsWith(u8, args[4], "proxy")) 1920 else 960,
    };
    const summary = try supervisor.run(init.gpa, init.io, options, .{ .stop = &stop, .abort = &abort }, .{ .max_attempts = 3, .max_prefill_frames = 5760 }, .{ .context = &log, .completed = Log.completed });
    if (!summary.intentional_stop) if (summary.last_failure) |err| return err;
}
