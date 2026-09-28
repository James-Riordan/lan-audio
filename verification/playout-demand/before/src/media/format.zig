//! Application v2 format, not an assertion of native device capability.
//! Units are frames/s, channels/frame and frames/record. The initial profile is
//! stereo IEEE binary32 LE; validation rejects unsupported values explicitly.
//! Bounded products below cannot overflow usize on supported 32/64-bit targets.
//! See docs/protocol/v2.md for wire meaning and the preservation argument.
pub const Format = struct {
    sample_rate: u32 = 48000,
    channel_count: u16 = 2,
    representation: u16 = 1,
    max_frames: u32 = 240,

    pub const Error = error{ InvalidProfile, InvalidFrames };
    pub const frame_limit: u32 = 1024;
    pub const bytes_per_sample = 4;

    /// Validate the application domain. The host separately validates endpoints.
    pub fn validate(self: Format) Error!void {
        if (self.sample_rate != 44100 and self.sample_rate != 48000 and self.sample_rate != 96000)
            return error.InvalidProfile;
        if (self.channel_count != 2 or self.representation != 1 or self.max_frames == 0 or self.max_frames > frame_limit)
            return error.InvalidProfile;
    }

    /// Zero frames is a control record, never an AUDIO payload.
    pub fn sampleCount(self: Format, frames: u32) Error!usize {
        try self.validate();
        if (frames == 0 or frames > self.max_frames) return error.InvalidFrames;
        return @as(usize, frames) * self.channel_count;
    }

    pub fn byteCount(self: Format, frames: u32) Error!usize {
        return (try self.sampleCount(frames)) * bytes_per_sample;
    }

    /// Exact echo; negotiation must not silently change any format dimension.
    pub fn eql(self: Format, other: Format) bool {
        return self.sample_rate == other.sample_rate and self.channel_count == other.channel_count and
            self.representation == other.representation and self.max_frames == other.max_frames;
    }
};
