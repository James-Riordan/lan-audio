//! Serialized v2 record-order gate; no I/O, device control or cryptography.
//! One sender/receiver role, one authenticated connection, one stream generation.
//! Apply each logical record once, not again on partial transport retries.
//! A protocol error is terminal; rebuild only for a new authenticated connection.
//! Host attestation supplies both authorization and the real receiver drain fence.
//! See docs/protocol/negotiation.md for the transition table and commit boundary.
const std = @import("std");
const v2 = @import("v2.zig");
pub const Negotiation = struct {
    pub const Role = enum { sender, receiver };
    pub const Direction = enum { incoming, outgoing };
    pub const Phase = enum { unauthorized, ready, offered, streaming, draining, complete, failed };
    pub const Error = v2.Error || error{ InvalidState, Unauthenticated, WrongDirection, WrongStream, FormatMismatch, Discontinuous, NotDrained };
    role: Role,
    phase: Phase = .unauthorized,
    stream: v2.StreamId = @splat(0),
    format: v2.Format = .{},
    next_frame: u64 = 0,
    drained: bool = false,

    pub fn init(role: Role) Negotiation {
        return .{ .role = role };
    }

    /// Call after mutual authentication, role/peer policy and exact v2 ALPN succeed.
    /// Repeated authorization is rejected without changing established state.
    pub fn authorizeChannel(self: *Negotiation) Error!void {
        if (self.phase != .unauthorized) return error.InvalidState;
        self.phase = .ready;
    }

    /// Receiver only, after actual downstream drain and native/worker quiescence.
    /// Repeating this attestation in draining is harmless; it performs no joining.
    pub fn confirmDrained(self: *Negotiation) Error!void {
        if (self.role != .receiver or self.phase != .draining) return error.InvalidState;
        self.drained = true;
    }

    /// Validates before changing stream/format/frontier. Rejection changes only
    /// phase to failed. Caller must close/cancel the connection, never skip bytes.
    pub fn apply(self: *Negotiation, direction: Direction, message: v2.Message) Error!void {
        if (self.phase == .failed) return error.InvalidState;
        errdefer self.phase = .failed;
        if (self.phase == .unauthorized) return error.Unauthenticated;
        try v2.validate(message);
        const data_direction: Direction = if (self.role == .sender) .outgoing else .incoming;
        const reverse: Direction = if (data_direction == .outgoing) .incoming else .outgoing;
        switch (self.phase) {
            .ready => {
                if (message.kind != .offer) return error.InvalidState;
                if (direction != data_direction) return error.WrongDirection;
                const format = try v2.profile(message);
                self.stream = message.stream;
                self.format = format;
                self.phase = .offered;
            },
            .offered => {
                if (message.kind != .accept) return error.InvalidState;
                if (direction != reverse) return error.WrongDirection;
                if (!std.mem.eql(u8, &self.stream, &message.stream)) return error.WrongStream;
                if (!self.format.eql(try v2.profile(message))) return error.FormatMismatch;
                self.phase = .streaming;
            },
            .streaming => {
                if (direction != data_direction) return error.WrongDirection;
                if (!std.mem.eql(u8, &self.stream, &message.stream)) return error.WrongStream;
                if (message.position != self.next_frame) return error.Discontinuous;
                switch (message.kind) {
                    .audio => {
                        _ = try self.format.sampleCount(message.frames);
                        // v2.validate proved this addition cannot wrap.
                        self.next_frame += message.frames;
                    },
                    .end => self.phase = .draining,
                    else => return error.InvalidState,
                }
            },
            .draining => {
                if (message.kind != .ack) return error.InvalidState;
                if (direction != reverse) return error.WrongDirection;
                if (!std.mem.eql(u8, &self.stream, &message.stream)) return error.WrongStream;
                if (message.position != self.next_frame) return error.Discontinuous;
                if (self.role == .receiver and !self.drained) return error.NotDrained;
                self.phase = .complete;
            },
            .complete, .unauthorized, .failed => return error.InvalidState,
        }
    }
};
