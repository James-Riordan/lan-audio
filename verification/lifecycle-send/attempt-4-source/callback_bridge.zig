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
        // Callback is the sole writer. Workers observe only these atomics, never
        // the plain diagnostic counters while callbacks can run.
        capture_failed: std.atomic.Value(bool) = .init(false),
        capture_faults: std.atomic.Value(u32) = .init(0),
        counters_exact: std.atomic.Value(bool) = .init(true),
        pub const CaptureFault = enum(u32) { overrun = 1, missing_input = 2, invalid_samples = 4, counter_exhausted = 8 };
        captured_frames: u64 = 0,
        dropped_frames: u64 = 0,
        rendered_frames: u64 = 0,
        silent_frames: u64 = 0,

        fn failCapture(self: *Self, fault: CaptureFault) void {
            const previous = self.capture_faults.load(.monotonic);
            self.capture_faults.store(previous | @backingInt(fault), .release);
            self.capture_failed.store(true, .release);
        }

        fn addCaptureCount(self: *Self, counter: *u64, frames: usize) void {
            if (frames > std.math.maxInt(u64) - counter.*) {
                self.counters_exact.store(false, .release);
                self.failCapture(.counter_exhausted);
            }
            counter.* +|= frames;
        }

        /// Callback-only null-input path. Missing frames are source loss, not a
        /// valid all-zero signal, and cannot silently disappear from the clock.
        pub fn missingInput(self: *Self, frames: usize) void {
            self.failCapture(.missing_input);
            self.addCaptureCount(&self.dropped_frames, frames);
        }

        /// Borrow complete interleaved frames for this call only. captured_frames
        /// counts accepted frames; dropped_frames counts the remaining prefix tail.
        /// Their sum counts offered frames only until either counter saturates.
        pub fn captureInput(self: *Self, input: []const f32) void {
            std.debug.assert(input.len % channels == 0);
            const frames = input.len / channels;
            if (self.capture_failed.load(.monotonic)) {
                self.addCaptureCount(&self.dropped_frames, frames);
                return;
            }
            // Validate before publishing any part of this callback's input.
            // Integer inspection preserves finite signed zeros and subnormals.
            for (input) |value| {
                const word: u32 = @bitCast(value);
                if (word & 0x7f800000 == 0x7f800000) {
                    self.failCapture(.invalid_samples);
                    self.addCaptureCount(&self.dropped_frames, frames);
                    return;
                }
            }
            const accepted = self.capture.write(input);
            self.addCaptureCount(&self.captured_frames, accepted);
            self.addCaptureCount(&self.dropped_frames, frames - accepted);
            // Sticky until quiescent reconstruction. The worker must treat this as
            // stream discontinuity, not concatenate surviving PCM into a false clock.
            if (accepted < frames) {
                self.capture_overrun.store(true, .release);
                self.failCapture(.overrun);
            }
        }

        /// Fill every requested sample, taking available media then zeroing the
        /// remainder. Queue/callback consumption does not prove acoustic rendering.
        pub fn renderOutput(self: *Self, output: []f32) void {
            const available = self.playback.read(output);
            @memset(output[available * channels ..], 0);
            if (available > std.math.maxInt(u64) - self.rendered_frames or output.len / channels - available > std.math.maxInt(u64) - self.silent_frames)
                self.counters_exact.store(false, .release);
            self.rendered_frames +|= available;
            self.silent_frames +|= output.len / channels - available;
        }
    };
}
