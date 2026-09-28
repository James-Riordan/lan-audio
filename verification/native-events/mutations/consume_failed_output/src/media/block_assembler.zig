//! Single-worker bridge from arbitrary complete stereo-frame prefixes to v2 blocks.
//! Owns bounded copied finite f32 storage; no queue/device/network/thread operations.
//! Full blocks become readable; finish exposes one final partial block. commit
//! advances position only after the caller has transferred/copied the block onward.
//! Capture discontinuity is terminal: discard pending data and start a new stream.
//! Mutating calls invalidate borrows. Input must not overlap storage. See
//! docs/media/assembly.md for conservation, commit order and host obligations.
const std = @import("std");
const Format = @import("format.zig").Format;

pub const BlockAssembler = struct {
    pub const Error = Format.Error || error{ InvalidSamples, InvalidSequence, InvalidState, NotReady, NotDrained, Discontinuity };
    pub const Block = struct { first_frame: u64, frames: u32, samples: []const f32 };
    format: Format,
    storage: [Format.frame_limit * 2]f32 = undefined,
    pending_frames: u32 = 0,
    next_frame: u64 = 0,
    sealed: bool = false,
    failed: bool = false,

    pub fn init(format: Format) Error!BlockAssembler {
        try format.validate();
        return .{ .format = format };
    }

    /// Copy the fitting whole-frame prefix and return its frame count. A full
    /// block returns zero; unaccepted input remains caller-owned and unvalidated.
    /// Validate the entire accepted prefix before changing any state/storage.
    pub fn push(self: *BlockAssembler, input: []const f32) Error!usize {
        if (self.failed) return error.Discontinuity;
        if (self.sealed) return error.InvalidState;
        if (input.len % 2 != 0) return error.InvalidSamples;
        const frames: u32 = @intCast(@min(input.len / 2, self.format.max_frames - self.pending_frames));
        const pending = self.pending_frames + frames;
        if (self.next_frame > std.math.maxInt(u64) - @as(u64, pending)) return error.InvalidSequence;
        const count: usize = @as(usize, frames) * 2;
        for (input[0..count]) |value| {
            const word: u32 = @bitCast(value);
            if (word & 0x7f800000 == 0x7f800000) return error.InvalidSamples;
        }
        const start: usize = @as(usize, self.pending_frames) * 2;
        @memcpy(self.storage[start..][0..count], input[0..count]);
        self.pending_frames = pending;
        return frames;
    }

    /// Borrow a complete block, or the sealed final partial block. Repeated peek
    /// returns the same block; no media position advances until commit succeeds.
    pub fn peek(self: *const BlockAssembler) Error!?Block {
        if (self.failed) return error.Discontinuity;
        if (self.pending_frames == 0 or (!self.sealed and self.pending_frames < self.format.max_frames)) return null;
        return .{ .first_frame = self.next_frame, .frames = self.pending_frames, .samples = self.storage[0 .. @as(usize, self.pending_frames) * 2] };
    }

    /// Commit exactly one available block after downstream copied custody. This
    /// is not idempotent: a second commit must fail instead of advancing twice.
    pub fn commit(self: *BlockAssembler) Error!void {
        const block = (try self.peek()) orelse return error.NotReady;
        self.next_frame += block.frames; // push established nonwrapping end.
        self.pending_frames = 0;
    }

    /// Source EOF after capture has quiesced and its queue is drained. Idempotent;
    /// does not commit data or manufacture a zero-length AUDIO block.
    pub fn finish(self: *BlockAssembler) Error!void {
        if (self.failed) return error.Discontinuity;
        self.sealed = true;
    }

    /// Exclusive END frontier exists only after all accepted data was committed.
    pub fn endPosition(self: *const BlockAssembler) Error!u64 {
        if (self.failed) return error.Discontinuity;
        if (!self.sealed or self.pending_frames != 0) return error.NotDrained;
        return self.next_frame;
    }

    /// Sticky terminal source loss; pending media cannot be relabeled contiguous.
    /// No owner may retain a previous borrowed block across this call.
    pub fn discontinue(self: *BlockAssembler) void {
        self.failed = true;
        self.sealed = true;
        self.pending_frames = 0;
    }
};
