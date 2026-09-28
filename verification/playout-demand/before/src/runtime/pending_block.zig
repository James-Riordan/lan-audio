//! Project-private receive custody; one serialized owner and one copied v2 block.
//! Admission decodes before changing metadata. Only the returned queue-write
//! prefix may advance the cursor. This does not authorize peers or check stream
//! continuity: commit a candidate Negotiation only after admit succeeds.
//! No heap, clock, I/O or callback ownership. All input bytes must be disjoint
//! from storage; peek borrows expire on the next mutating call. See
//! docs/media/pending-block.md for the representation and commit argument.
const core = @import("lan_audio");
const wire = core.wire_v2;

pub const PendingBlock = struct {
    pub const Error = wire.Error || error{ Busy, Aborted, InvalidAdvance };
    pub const Block = struct { first_frame: u64, frames: u32, samples: []const f32 };

    format: core.Format,
    storage: [wire.max_samples]f32 = undefined,
    first_frame: u64 = 0,
    frames: u32 = 0,
    offset: u32 = 0,
    aborted: bool = false,

    /// The immutable per-stream format bounds admission; it is not device support.
    pub fn init(format: core.Format) Error!PendingBlock {
        try format.validate();
        return .{ .format = format };
    }

    /// Copy exactly one complete AUDIO record, preserving every finite word.
    /// Failure leaves storage and metadata unchanged; no partial admission.
    /// Input borrow ends at return. Pending frames must first be fully advanced.
    pub fn admit(self: *PendingBlock, message: wire.Message) Error!void {
        if (self.aborted) return error.Aborted;
        if (self.offset != self.frames) return error.Busy;
        if (message.kind != .audio) return error.InvalidSamples;
        const count = try self.format.sampleCount(message.frames);
        // decodeAudio validates the entire record before its first output write.
        try wire.decodeAudio(message, self.storage[0..count]);
        self.first_frame = message.position;
        self.frames = message.frames;
        self.offset = 0;
    }

    /// Borrow the still-owned suffix. Empty is null, not a zero-length block.
    pub fn peek(self: *const PendingBlock) Error!?Block {
        if (self.aborted) return error.Aborted;
        if (self.offset == self.frames) return null;
        const start: usize = @as(usize, self.offset) * 2;
        const end: usize = @as(usize, self.frames) * 2;
        return .{
            .first_frame = self.first_frame + self.offset, // validated nonwrapping range
            .frames = self.frames - self.offset,
            .samples = self.storage[start..end],
        };
    }

    /// After downstream copying, relinquish only its accepted whole-frame prefix.
    /// Zero is harmless, including while empty. Positive advances are not retryable
    /// acknowledgements: applying the same accepted count twice would lose media.
    pub fn advance(self: *PendingBlock, accepted_frames: u32) Error!void {
        if (self.aborted) return error.Aborted;
        if (accepted_frames > self.frames - self.offset) return error.InvalidAdvance;
        self.offset += accepted_frames;
    }

    /// Terminal discard; returns the still-pending frame count exactly once.
    /// Does not discard frames already copied into a queue or join any owner.
    /// Reconstruction requires release of all borrows and a new stream lifecycle.
    pub fn abort(self: *PendingBlock) u32 {
        const discarded = self.frames - self.offset;
        self.aborted = true;
        self.frames = 0;
        self.offset = 0;
        return discarded;
    }
};
