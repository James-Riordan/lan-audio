//! C02a/b: single-control-owner resource ledger and graceful receiver completion.
//! Host handles live in stable executor slots, never in this value. This module
//! grants permission to dispatch; it cannot itself prove an executor joined.
//! Read docs/runtime/lifecycle-core.md for the refinement and adapter premises.
const std = @import("std");

pub const Resource = enum { storage, device, worker };
pub const Executor = enum { allocator, native, joiner, transport };
pub const Kind = enum { acquire, join_worker, fence_device, release, send_ack, close_transport };
pub const Phase = enum { idle, acquiring, ready, draining, reclaiming, aborting, unresponsive, stopped };
pub const Cause = enum { requested, acquisition_failed, partial_acquisition, deadline, cleanup_failed, transport_failed };

/// Receiver-only protocol facts. ACK copied custody is NOT remote observation.
/// The worker aggregate owns transport through ACK/close, then joins normally.
pub const ReceiveOutcome = struct {
    frontier: u64,
    publication_closed: bool = false,
    local: enum { pending, drained, interrupted } = .pending,
    ack: enum { not_attempted, copied, unknown } = .not_attempted,
    remote: enum { unobserved } = .unobserved,
    secure_close: enum { not_attempted, clean, failed } = .not_attempted,
};

/// All fields participate in identity. Executors echo the descriptor unchanged.
/// The joiner is an owner-management executor, NEVER the worker being joined.
pub const Token = struct {
    generation: u64,
    serial: u64,
    executor: Executor,
    kind: Kind,
    resource: Resource,
};

/// Acquisition failure is admissible only after complete internal rollback.
/// partial_owned means one cleanup-capable resource exists, using this same
/// resource's normal fence/release protocol. Other partial native states require
/// adapter-local recovery; they must not be reported as failed_rolled_back.
pub const Result = enum {
    acquired,
    failed_rolled_back,
    partial_owned,
    joined,
    fenced,
    released,
    failure_no_change,
    ack_copied,
    transport_closed,
    transport_failed,
};

pub const Snapshot = struct {
    phase: Phase,
    generation: u64,
    serial: u64,
    held: [3]bool,
    pending: ?Token,
    worker_joined: bool,
    device_fenced: bool,
    first_cause: ?Cause,
    cleanup_blocked: bool,
    deadline_expired: bool,
    receive: ?ReceiveOutcome,
};

/// Fixed O(1) state/work per call; no allocation, locks, clocks or native calls.
/// Serialize every method externally. Do not copy/reset a controller with debt,
/// mutate its representation, or invoke it from a device callback. One global
/// pending slot deliberately serializes all executors in this initial profile.
pub const Controller = struct {
    phase: Phase = .idle,
    generation: u64 = 0,
    serial: u64 = 0,
    held: [3]bool = .{ false, false, false },
    pending: ?Token = null,
    worker_joined: bool = false,
    device_fenced: bool = false,
    first_cause: ?Cause = null,
    cleanup_blocked: bool = false,
    deadline_expired: bool = false,
    receive: ?ReceiveOutcome = null,

    /// Authenticated receiver END, validated by the media owner. Repetition is
    /// harmless only for the same frontier. Abort cannot return to graceful.
    pub fn requestDrain(self: *Controller, generation: u64, frontier: u64) error{ StaleGeneration, InvalidState, InvalidFrontier }!void {
        if (generation != self.generation) return error.StaleGeneration;
        if (self.first_cause != null) return error.InvalidState;
        if (self.receive) |r| {
            if (r.frontier != frontier) return error.InvalidFrontier;
            return;
        }
        if (self.phase != .ready) return error.InvalidState;
        self.receive = .{ .frontier = frontier };
        self.normalize();
    }

    /// Sole producer attests END, no pending frames, queue empty and permanent
    /// publication closure. Queue-empty alone does not attest callback return.
    /// Worker remains alive but must perform no further device/media operations.
    pub fn observeQueueDrained(self: *Controller, generation: u64, frontier: u64) error{ StaleGeneration, InvalidState, InvalidFrontier }!void {
        if (generation != self.generation) return error.StaleGeneration;
        if (self.phase != .draining) return error.InvalidState;
        const r = self.receive orelse return error.InvalidState;
        if (r.frontier != frontier) return error.InvalidFrontier;
        self.receive.?.publication_closed = true;
    }

    /// Fresh namespace per successful start; exhaustion and Busy are atomic.
    /// This does not validate media/credentials or start a native device.
    pub fn begin(self: *Controller) error{ Busy, GenerationExhausted }!u64 {
        if (self.phase != .idle and self.phase != .stopped) return error.Busy;
        if (self.generation == std.math.maxInt(u64)) return error.GenerationExhausted;
        self.* = .{ .phase = .acquiring, .generation = self.generation + 1 };
        return self.generation;
    }

    /// Monotonic abort intent. Repetition cannot clear debt, cause or timeout.
    pub fn requestStop(self: *Controller, generation: u64) error{StaleGeneration}!void {
        if (generation != self.generation) return error.StaleGeneration;
        if (self.phase == .idle or self.phase == .stopped) return;
        self.stopBecause(.requested);
        self.normalize();
    }

    /// Caller owns the single generation-scoped absolute cleanup deadline.
    /// Notification only marks uncertainty; an issued operation remains owed.
    /// A stale or already terminal notification cannot stop a new generation.
    pub fn deadline(self: *Controller, generation: u64) void {
        if (generation != self.generation or self.phase == .idle or self.phase == .stopped) return;
        self.deadline_expired = true;
        self.stopBecause(.deadline);
        self.normalize();
    }

    /// Explicit retry is legal only after a definitive failure_no_change result.
    /// It cannot retry an uncertain/still-running operation or clear a timeout.
    pub fn retryCleanup(self: *Controller, generation: u64) error{ StaleGeneration, NotBlocked }!void {
        if (generation != self.generation) return error.StaleGeneration;
        if (!self.cleanup_blocked or self.pending != null) return error.NotBlocked;
        self.cleanup_blocked = false;
        self.normalize();
    }

    /// Transfer dispatch authority once, reserving the completion slot before
    /// returning. Wrong executor/no work gives null; serial exhaustion is atomic.
    /// Dispatch rejection before execution must still complete this exact token.
    pub fn takeEffect(self: *Controller, executor: Executor) error{SerialExhausted}!?Token {
        if (self.pending != null or self.cleanup_blocked) return null;
        const next = self.nextOperation() orelse return null;
        if (next.executor != executor) return null;
        if (self.serial == std.math.maxInt(u64)) return error.SerialExhausted;
        const token: Token = .{
            .generation = self.generation,
            .serial = self.serial + 1,
            .executor = executor,
            .kind = next.kind,
            .resource = next.resource,
        };
        self.serial = token.serial;
        self.pending = token;
        return token;
    }

    /// Validate identity AND result shape before changing any field. A rejected
    /// event conveys no permission to destroy a handle; the executor retains it.
    /// Unknown external handles require adapter quarantine, not a forged token.
    pub fn complete(self: *Controller, token: Token, result: Result) error{ InvalidToken, InvalidResult }!void {
        const pending = self.pending orelse return error.InvalidToken;
        if (!std.meta.eql(pending, token)) return error.InvalidToken;
        const legal = switch (token.kind) {
            .acquire => result == .acquired or result == .failed_rolled_back or result == .partial_owned,
            .join_worker => result == .joined or result == .failure_no_change,
            .fence_device => result == .fenced or result == .failure_no_change,
            .release => result == .released or result == .failure_no_change,
            .send_ack => result == .ack_copied or result == .transport_failed,
            .close_transport => result == .transport_closed or result == .transport_failed,
        };
        if (!legal) return error.InvalidResult;

        self.pending = null;
        switch (result) {
            .acquired, .partial_owned => {
                self.held[@backingInt(token.resource)] = true;
                if (result == .partial_owned) self.stopBecause(.partial_acquisition);
            },
            .failed_rolled_back => self.stopBecause(.acquisition_failed),
            .joined => self.worker_joined = true,
            .fenced => {
                self.device_fenced = true;
                if (self.receive) |*r| {
                    if (r.publication_closed and self.first_cause == null) r.local = .drained;
                }
            },
            .released => self.held[@backingInt(token.resource)] = false,
            .failure_no_change => {
                self.cleanup_blocked = true;
                self.stopBecause(.cleanup_failed);
            },
            .ack_copied => self.receive.?.ack = .copied,
            .transport_closed => self.receive.?.secure_close = .clean,
            .transport_failed => {
                if (token.kind == .send_ack) self.receive.?.ack = .unknown else self.receive.?.secure_close = .failed;
                self.stopBecause(.transport_failed);
            },
        }
        self.normalize();
    }

    pub fn snapshot(self: *const Controller) Snapshot {
        return .{
            .phase = self.phase,
            .generation = self.generation,
            .serial = self.serial,
            .held = self.held,
            .pending = self.pending,
            .worker_joined = self.worker_joined,
            .device_fenced = self.device_fenced,
            .first_cause = self.first_cause,
            .cleanup_blocked = self.cleanup_blocked,
            .deadline_expired = self.deadline_expired,
            .receive = self.receive,
        };
    }

    fn stopBecause(self: *Controller, cause: Cause) void {
        if (self.first_cause == null) self.first_cause = cause;
        if (self.receive) |*r| {
            if (r.local == .pending) r.local = .interrupted;
        }
        self.phase = .aborting;
    }

    fn normalize(self: *Controller) void {
        if (self.first_cause != null) {
            const empty = !self.held[0] and !self.held[1] and !self.held[2];
            self.phase = if (empty and self.pending == null) .stopped else if (self.cleanup_blocked or self.deadline_expired) .unresponsive else .aborting;
        } else if (self.receive) |r| {
            if (r.secure_close == .clean) {
                self.phase = if (!self.held[0] and !self.held[1] and !self.held[2] and self.pending == null) .stopped else .reclaiming;
            } else self.phase = .draining;
        } else if (self.held[0] and self.held[1] and self.held[2]) {
            self.phase = .ready;
        }
    }

    const Operation = struct { executor: Executor, kind: Kind, resource: Resource };
    fn nextOperation(self: *const Controller) ?Operation {
        if (self.phase == .acquiring) {
            if (!self.held[0]) return .{ .executor = .allocator, .kind = .acquire, .resource = .storage };
            if (!self.held[1]) return .{ .executor = .native, .kind = .acquire, .resource = .device };
            if (!self.held[2]) return .{ .executor = .joiner, .kind = .acquire, .resource = .worker };
        } else if (self.phase == .draining) {
            const r = self.receive.?;
            if (!r.publication_closed) return null;
            // Deliberately omit native fence.
            if (r.ack == .not_attempted) return .{ .executor = .transport, .kind = .send_ack, .resource = .worker };
            return .{ .executor = .transport, .kind = .close_transport, .resource = .worker };
        } else if (self.phase == .aborting or self.phase == .unresponsive or self.phase == .reclaiming) {
            // takeEffect's global pending guard retains every parent during an
            // outstanding child acquisition, including cancellation/late success.
            if (self.held[2]) return .{ .executor = .joiner, .kind = if (self.worker_joined) .release else .join_worker, .resource = .worker };
            if (self.held[1]) return .{ .executor = .native, .kind = if (self.device_fenced) .release else .fence_device, .resource = .device };
            if (self.held[0]) return .{ .executor = .allocator, .kind = .release, .resource = .storage };
        }
        return null;
    }
};
