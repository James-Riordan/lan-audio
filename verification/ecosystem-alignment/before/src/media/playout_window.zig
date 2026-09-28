//! Fixed-capacity, single-owner PCM reorder/playout window. No allocation or I/O.
//! Sequence n denotes a whole fixed-size interleaved block in one session epoch.
//! Accepted positions are [next, next+capacity), expressed by subtraction to avoid
//! overflow. Slot n mod capacity is injective on that interval (docs/MATHEMATICS.md).
//! A tick commits exactly one media position, returning PCM or fully written silence.
//! Caller supplies serialization and nonaliasing output; this is not a lock-free queue.
const std = @import("std");

pub fn Window(comptime capacity: usize, comptime samples_per_block: usize) type {
    if (capacity == 0 or samples_per_block == 0) @compileError("window dimensions must be positive");
    return struct {
        const Self = @This();
        pub const Error = error{ StaleEpoch, Late, TooFar, Duplicate, InvalidBlock, SequenceExhausted };
        pub const Result = enum { media, silence };
        epoch: u64,
        next: u64 = 0,
        present: [capacity]bool = @splat(false),
        blocks: [capacity][samples_per_block]f32 = undefined,

        /// Reinitialization discards the prior generation only after host quiescence.
        pub fn init(epoch: u64) Self {
            return .{ .epoch = epoch };
        }
        /// Copies a complete block. Invalid input never publishes or changes a slot.
        /// PCM samples must be finite and within the host's negotiated amplitude policy.
        pub fn insert(self: *Self, epoch: u64, sequence: u64, samples: []const f32) Error!void {
            if (epoch != self.epoch) return error.StaleEpoch;
            if (samples.len != samples_per_block) return error.InvalidBlock;
            for (samples) |sample| if (!std.math.isFinite(sample)) return error.InvalidBlock;
            if (sequence == std.math.maxInt(u64)) return error.SequenceExhausted;
            if (sequence < self.next) return error.Late;
            if (sequence - self.next >= capacity) return error.TooFar;
            const slot: usize = @intCast(sequence % capacity);
            if (self.present[slot]) return error.Duplicate;
            // A temporary permits an input slice overlapping this window's storage.
            var copy: [samples_per_block]f32 = undefined;
            @memcpy(&copy, samples);
            self.blocks[slot] = copy;
            self.present[slot] = true;
        }
        /// Valid output must not alias this object's storage. Work is O(block samples).
        /// Sequence exhaustion changes neither state nor output; negotiate a new epoch.
        pub fn tick(self: *Self, output: []f32) Error!Result {
            if (output.len != samples_per_block) return error.InvalidBlock;
            if (self.next == std.math.maxInt(u64)) return error.SequenceExhausted;
            const slot: usize = @intCast(self.next % capacity);
            const result: Result = if (self.present[slot]) .media else .silence;
            if (self.present[slot]) @memcpy(output, &self.blocks[slot]) else @memset(output, 0);
            self.present[slot] = false;
            self.next += 1;
            return result;
        }
    };
}
