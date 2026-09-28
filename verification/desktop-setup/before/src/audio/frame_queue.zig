//! Fixed-storage, interleaved f32 SPSC frame queue. One producer calls write;
//! one consumer calls read. No reset/move/destruction until both owners join.
//! Short operations transfer a prefix of whole frames; no wait, allocation or RMW.
//! Caller buffers must not overlap storage; lengths must contain complete frames.
//! Publication/reuse proof: docs/MATHEMATICS.md section 9. Native target atomic
//! support is a separate qualification from this fixed-operation algorithm.
const std = @import("std");
const builtin = @import("builtin");

pub fn FrameQueue(comptime capacity: u32, comptime channels: usize) type {
    if (capacity == 0 or capacity > (1 << 30) or capacity & (capacity - 1) != 0)
        @compileError("capacity must be a power of two in 1..2^30 frames");
    if (channels == 0 or channels > 32) @compileError("channels must be in 1..32");
    // The current qualification depends on native aligned 32-bit atomic loads/stores.
    if (builtin.cpu.arch != .x86_64 and builtin.cpu.arch != .aarch64)
        @compileError("SPSC atomic profile currently covers x86_64 and aarch64");
    return struct {
        const Self = @This();
        pub const frame_capacity = capacity;
        pub const channel_count = channels;
        // 128-byte separation avoids sharing a line on the target profiles. This is
        // a layout choice, not a portable claim about every processor's cache line.
        published: std.atomic.Value(u32) align(128) = .init(0),
        released: std.atomic.Value(u32) align(128) = .init(0),
        storage: [capacity * channels]f32 align(128) = undefined,

        /// Producer-only conservative occupancy observation. No third-party polling.
        pub fn producerPending(self: *const Self) u32 {
            return self.published.load(.monotonic) -% self.released.load(.acquire);
        }

        /// Consumer-only conservative availability. Exact once the producer is
        /// fenced; this observation alone is never a producer-lifetime fence.
        pub fn consumerAvailable(self: *const Self) u32 {
            return self.published.load(.acquire) -% self.released.load(.monotonic);
        }

        /// Producer owns input until return; only the returned whole-frame prefix
        /// transfers. Rejecting/backpressuring the remainder is the host's policy.
        pub fn write(self: *Self, samples: []const f32) usize {
            std.debug.assert(samples.len % channels == 0);
            const w = self.published.load(.monotonic);
            const r = self.released.load(.acquire);
            const occupied = w -% r;
            std.debug.assert(occupied <= capacity);
            const frames: u32 = @intCast(@min(samples.len / channels, capacity - occupied));
            const start: usize = w & (capacity - 1);
            const first: usize = @min(frames, capacity - start);
            @memcpy(self.storage[start * channels ..][0 .. first * channels], samples[0 .. first * channels]);
            @memcpy(self.storage[0 .. (frames - first) * channels], samples[first * channels ..][0 .. (frames - first) * channels]);
            // Publish only after both spans are completely initialized.
            self.published.store(w +% frames, .release);
            return frames;
        }

        /// Consumer owns output; unavailable suffix is unchanged, not zero-filled.
        /// CallbackBridge provides silence where required by the native contract.
        pub fn read(self: *Self, samples: []f32) usize {
            std.debug.assert(samples.len % channels == 0);
            const r = self.released.load(.monotonic);
            const w = self.published.load(.acquire);
            const available = w -% r;
            std.debug.assert(available <= capacity);
            const frames: u32 = @intCast(@min(samples.len / channels, available));
            const start: usize = r & (capacity - 1);
            const first: usize = @min(frames, capacity - start);
            @memcpy(samples[0 .. first * channels], self.storage[start * channels ..][0 .. first * channels]);
            @memcpy(samples[first * channels ..][0 .. (frames - first) * channels], self.storage[0 .. (frames - first) * channels]);
            // Producer cannot reuse these slots before the consumer finishes copying.
            self.released.store(r +% frames, .release);
            return frames;
        }
    };
}
