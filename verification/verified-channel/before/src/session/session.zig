//! Serialized session-admission state machine. Epochs distinguish local runs;
//! they are not credentials and must be bound to an authenticated peer by the host.
//! Every rejected transition preserves state. Stop closes callback admission before
//! draining the one modeled callback. Actual device-stop/join is a host obligation.
//! No method is atomic or thread-safe: one owner must serialize every operation.
const std = @import("std");

pub const Session = struct {
    pub const Phase = enum { idle, negotiating, streaming, stopping };
    pub const Error = error{ InvalidState, StaleEpoch, Unauthenticated, CallbackActive, NoCallback, EpochExhausted };
    phase: Phase = .idle,
    epoch: u64 = 0,
    authenticated: bool = false,
    callback_active: bool = false,

    /// Starts a new local generation. No counter wrap or implicit recovery.
    pub fn begin(self: *Session) Error!u64 {
        if (self.phase != .idle) return error.InvalidState;
        if (self.epoch == std.math.maxInt(u64)) return error.EpochExhausted;
        self.epoch += 1;
        self.phase = .negotiating;
        return self.epoch;
    }
    /// Host attestation only: this function performs no cryptographic verification.
    pub fn authenticate(self: *Session, epoch: u64) Error!void {
        if (epoch != self.epoch) return error.StaleEpoch;
        if (self.phase != .negotiating) return error.InvalidState;
        self.authenticated = true;
    }
    pub fn start(self: *Session) Error!void {
        if (self.phase != .negotiating) return error.InvalidState;
        if (!self.authenticated) return error.Unauthenticated;
        self.phase = .streaming;
    }
    /// Pure authorization check before copying media into the active window.
    pub fn admit(self: *const Session, epoch: u64) Error!void {
        if (epoch != self.epoch) return error.StaleEpoch;
        if (self.phase != .streaming) return error.InvalidState;
        if (!self.authenticated) return error.Unauthenticated;
    }
    pub fn enterCallback(self: *Session, epoch: u64) Error!void {
        try self.admit(epoch);
        if (self.callback_active) return error.CallbackActive;
        self.callback_active = true;
    }
    pub fn leaveCallback(self: *Session, epoch: u64) Error!void {
        if (epoch != self.epoch) return error.StaleEpoch;
        if (!self.callback_active) return error.NoCallback;
        self.callback_active = false;
    }
    pub fn requestStop(self: *Session) Error!void {
        if (self.phase != .negotiating and self.phase != .streaming) return error.InvalidState;
        self.phase = .stopping;
    }
    /// Call only after the actual device has stopped; the model checks its token.
    pub fn finishStop(self: *Session) Error!void {
        if (self.phase != .stopping) return error.InvalidState;
        if (self.callback_active) return error.CallbackActive;
        self.authenticated = false;
        self.phase = .idle;
    }
};
