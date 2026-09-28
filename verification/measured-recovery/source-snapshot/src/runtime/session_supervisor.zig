//! Reconstruct fully quiescent sessions after recoverable faults. No native owner
//! survives into the next attempt; random stream IDs prevent stale media replay.
const std = @import("std");
const stream = @import("stream_runtime");
const platform = @import("platform_host");
const net = @import("network_host");
const Policy = stream.recovery_policy.Policy;
const Backoff = stream.recovery_policy.Backoff;
pub const Config = struct { enabled: bool = true, max_prefill_frames: u32 = 5760, max_attempts: ?u32 = null };
pub const Event = struct { attempt: u64, prefill_frames: u32, report: stream.Report };
pub const Observer = struct { context: *anyopaque, completed: *const fn (*anyopaque, Event) anyerror!void };
pub const Summary = struct { attempts: u64, intentional_stop: bool, last_failure: ?anyerror };

pub fn run(allocator: std.mem.Allocator, io: std.Io, original: stream.Options, controls: stream.Controls, config: Config, observer: Observer) !Summary {
    var policy = try Policy.init(original.prefill_frames, config.max_prefill_frames);
    if (config.max_attempts == 0) return error.InvalidOptions;
    var pacer = try platform.Pacer.init();
    defer pacer.deinit();
    var listener: net.Socket = .{};
    defer listener.close() catch @panic("supervisor listener close failed");
    if (original.listen) {
        try listener.init(original.family);
        try listener.listen(original.endpoint, 8);
    }
    var summary: Summary = .{ .attempts = 0, .intentional_stop = false, .last_failure = null };
    while (true) {
        if (controls.abort.load(.acquire) or controls.stop.load(.acquire)) {
            summary.intentional_stop = true;
            return summary;
        }
        var options = original;
        if (original.listen) options.listener = &listener;
        options.prefill_frames = policy.prefill_frames;
        options.max_queue_frames = try stream.recovery_policy.queueLimit(config.max_prefill_frames);
        options.recover_playback = config.enabled;
        try std.Io.randomSecure(io, &options.stream_id);
        if (summary.attempts == std.math.maxInt(u64)) return error.AttemptExhausted;
        summary.attempts += 1;
        // Throws (rather than Report.failure) denote unresolved cleanup or setup
        // resources. They must escape; never construct a replacement over debt.
        const report = try stream.run(allocator, options, controls);
        summary.last_failure = report.failure;
        try observer.completed(observer.context, .{ .attempt = summary.attempts, .prefill_frames = options.prefill_frames, .report = report });
        if (controls.abort.load(.acquire) or controls.stop.load(.acquire)) {
            summary.intentional_stop = true;
            return summary;
        }
        const failure = report.failure orelse return summary;
        if (!config.enabled or (config.max_attempts != null and summary.attempts >= config.max_attempts.?)) return summary;
        const decision = policy.failedObserved(failure, options.listen, report.active_ms, .{
            .delivery_gap_ms = report.delivery_timing.observedGap(),
            .callback_frames = if (report.audio) |audio| audio.max_output_request_frames else 0,
        });
        if (decision == .stop) return summary;
        std.debug.print("Connection interrupted ({s}); retrying in {d} ms with {d} ms playback reserve.\n", .{ @errorName(failure), decision.retry, policy.prefill_frames / 48 });
        var backoff = try Backoff.init(try net.nowMilliseconds(), decision.retry);
        while (true) {
            switch (try backoff.poll(try net.nowMilliseconds(), controls.abort.load(.acquire) or controls.stop.load(.acquire))) {
                .ready => break,
                .canceled => {
                    summary.intentional_stop = true;
                    return summary;
                },
                .wait_ms => |ms| try pacer.wait(ms),
            }
        }
    }
}
