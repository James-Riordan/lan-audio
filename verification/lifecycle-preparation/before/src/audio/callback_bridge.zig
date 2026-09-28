//! Fixed-address device/worker boundary. The callback owns statistics; inspect them
//! only after device teardown. Each queue has exactly one writer and one reader.
//! Counts are frames, not samples/bytes. Totals saturate; capture_overrun is sticky
//! until quiescent reconstruction. Full rationale: docs/CALLBACKS.md.
const FrameQueue = @import("frame_queue.zig").FrameQueue;
const std = @import("std");

pub fn CallbackBridge(comptime capacity: u32, comptime channels: usize) type {
    return struct {
        const Self = @This();
        pub const Queue = FrameQueue(capacity, channels);
        capture: Queue = .{}, // callback writes, worker reads
        playback: Queue = .{}, // worker writes, callback reads
        capture_overrun: std.atomic.Value(bool) = .init(false),
        captured_frames: u64 = 0,
        dropped_frames: u64 = 0,
        rendered_frames: u64 = 0,
        silent_frames: u64 = 0,

        /// Borrow complete interleaved frames for this call only. captured_frames
        /// counts accepted frames; dropped_frames counts the remaining prefix tail.
        /// Their sum counts offered frames only until either counter saturates.
        pub fn captureInput(self: *Self, input: []const f32) void {
            const accepted = self.capture.write(input);
            self.captured_frames +|= accepted;
            self.dropped_frames +|= input.len / channels - accepted;
            // Sticky until quiescent reconstruction. The worker must treat this as
            // stream discontinuity, not concatenate surviving PCM into a false clock.
            if (accepted < input.len / channels) self.capture_overrun.store(true, .release);
        }

        /// Fill every requested sample, taking available media then zeroing the
        /// remainder. Queue/callback consumption does not prove acoustic rendering.
        pub fn renderOutput(self: *Self, output: []f32) void {
            const available = self.playback.read(output);
            @memset(output[available * channels ..], 0);
            self.rendered_frames +|= available;
            self.silent_frames +|= output.len / channels - available;
        }
    };
}
