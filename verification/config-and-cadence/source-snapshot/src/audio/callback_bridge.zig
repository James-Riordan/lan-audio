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
        pub const CaptureFault = enum(u32) { overrun = 1, missing_input = 2, invalid_samples = 4, counter_exhausted = 8 };
        capture: Queue = .{}, // callback writes, worker reads
        playback: Queue = .{}, // worker writes, callback reads
        capture_overrun: std.atomic.Value(bool) = .init(false),
        // Native notification owners may also store true to the failure flags.
        // Only the data callback updates reason bits and plain frame counters.
        // All failure publications are sticky until quiescent reconstruction.
        capture_failed: std.atomic.Value(bool) = .init(false),
        playback_failed: std.atomic.Value(bool) = .init(false),
        // Warm a native receiver while retaining prefill. Publish true only
        // after the worker has configured the playback guard.
        playback_ready: std.atomic.Value(bool) = .init(true),
        // Optional product recovery guard. Underrun is distinct from a native
        // failure and ordinary callers retain their existing zero-fill behavior.
        playback_guard: std.atomic.Value(bool) = .init(false),
        playback_starved: std.atomic.Value(bool) = .init(false),
        capture_faults: std.atomic.Value(u32) = .init(0),
        counters_exact: std.atomic.Value(bool) = .init(true),
        captured_frames: u64 = 0,
        dropped_frames: u64 = 0,
        rendered_frames: u64 = 0,
        silent_frames: u64 = 0,
        missing_output_frames: u64 = 0,
        // Callback-owned diagnostics, read only after the native fence. No clock
        // queries or logging on the real-time path.
        max_output_request_frames: usize = 0,
        first_starvation_requested: usize = 0,
        first_starvation_available: usize = 0,
        first_starvation_rendered: u64 = 0,

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
            if (frames == 0) return;
            self.failCapture(.missing_input);
            self.addCaptureCount(&self.dropped_frames, frames);
        }

        /// Data-callback only. No destination means no frames can be accounted as
        /// copied output or silence. Leave queued media in its current custody.
        pub fn missingOutput(self: *Self, frames: usize) void {
            if (frames == 0) return;
            self.playback_failed.store(true, .release);
            if (frames > std.math.maxInt(u64) - self.missing_output_frames)
                self.counters_exact.store(false, .release);
            self.missing_output_frames +|= frames;
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
            self.max_output_request_frames = @max(self.max_output_request_frames, output.len / channels);
            const ready = self.playback_ready.load(.acquire);
            const guarded = ready and self.playback_guard.load(.acquire);
            const available = if (!ready or self.playback_failed.load(.acquire)) 0 else self.playback.read(output);
            @memset(output[available * channels ..], 0);
            if (available > std.math.maxInt(u64) - self.rendered_frames or output.len / channels - available > std.math.maxInt(u64) - self.silent_frames)
                self.counters_exact.store(false, .release);
            self.rendered_frames +|= available;
            self.silent_frames +|= output.len / channels - available;
            if (guarded and available < output.len / channels) {
                if (!self.playback_starved.load(.monotonic)) {
                    self.first_starvation_requested = output.len / channels;
                    self.first_starvation_available = available;
                    self.first_starvation_rendered = self.rendered_frames;
                }
                self.playback_starved.store(true, .release);
            }
        }
    };
}
