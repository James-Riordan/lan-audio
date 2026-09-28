//! Serialized composition of authenticated-channel admission and bounded playout.
//! One stream per TLS connection. Trust is supplied by the host after peer policy
//! and ALPN succeed; record headers cannot assert it. Physical callbacks are external.
const std = @import("std");
const wire = @import("../protocol/v1.zig");
const Session = @import("session.zig").Session;
const Window = @import("../media/playout_window.zig").Window;

pub fn Receiver(comptime capacity: usize) type {
    return struct {
        const Self = @This();
        const Buffer = Window(capacity, wire.samples);
        pub const Error = wire.Error || Session.Error || Buffer.Error || error{ WrongStream, UnexpectedMessage, Ended, InvalidEnd };
        session: Session = .{},
        window: Buffer = Buffer.init(0),
        channel_authorized: bool = false,
        stream: ?wire.StreamId = null,
        finish_sequence: ?u64 = null,
        ended: bool = false,

        /// Attestation boundary, not authentication implementation. One control owner.
        pub fn authorizeChannel(self: *Self) Error!void {
            if (self.channel_authorized or self.stream != null) return error.InvalidState;
            self.channel_authorized = true;
        }
        pub fn accept(self: *Self, message: wire.Message) Error!void {
            try wire.validate(message);
            if (!self.channel_authorized) return error.Unauthenticated;
            if (self.finish_sequence != null or self.ended) return error.Ended;
            if (message.kind == .start) {
                if (self.stream != null) return error.UnexpectedMessage;
                const epoch = try self.session.begin();
                try self.session.authenticate(epoch);
                try self.session.start();
                self.window = Buffer.init(epoch);
                self.stream = message.stream;
                return;
            }
            const id = self.stream orelse return error.UnexpectedMessage;
            if (!std.mem.eql(u8, &id, &message.stream)) return error.WrongStream;
            try self.session.admit(self.window.epoch);
            switch (message.kind) {
                .audio => {
                    var pcm: [wire.samples]f32 = undefined;
                    try wire.decodeAudio(message, &pcm);
                    try self.window.insert(self.window.epoch, message.sequence, &pcm);
                },
                .end => {
                    if (message.sequence < self.window.next or message.sequence - self.window.next > capacity) return error.InvalidEnd;
                    const distance = message.sequence - self.window.next;
                    for (0..capacity) |offset| {
                        const slot: usize = @intCast((self.window.next % capacity + offset) % capacity);
                        if (self.window.present[slot] and offset >= distance) return error.InvalidEnd;
                    }
                    self.finish_sequence = message.sequence;
                    try self.completeIfDrained();
                },
                else => return error.UnexpectedMessage,
            }
        }
        pub fn tick(self: *Self, output: []f32) Error!Buffer.Result {
            if (self.ended) return error.Ended;
            try self.session.admit(self.window.epoch);
            const result = try self.window.tick(output);
            try self.completeIfDrained();
            return result;
        }
        fn completeIfDrained(self: *Self) Error!void {
            if (self.finish_sequence) |end| if (self.window.next == end) {
                try self.session.requestStop();
                try self.session.finishStop();
                self.ended = true;
            };
        }
    };
}
