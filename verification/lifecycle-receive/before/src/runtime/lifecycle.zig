//! C02a: allocation-free, single-control-owner acquisition/abort/reclaim ledger.
//! Host handles live in stable executor slots, never in this value. This module
//! grants permission to dispatch; it cannot itself prove an executor joined.
//! Read docs/runtime/lifecycle-core.md for the refinement and adapter premises.
const std = @import("std");

pub const Resource = enum { storage, device, worker };
pub const Executor = enum { allocator, native, joiner };
pub const Kind = enum { acquire, join_worker, fence_device, release };
pub const Phase = enum { idle, acquiring, ready, aborting, unresponsive, stopped };
pub const Cause = enum { requested, acquisition_failed, partial_acquisition, deadline, cleanup_failed };

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
            .fenced => self.device_fenced = true,
            .released => self.held[@backingInt(token.resource)] = false,
            .failure_no_change => {
                self.cleanup_blocked = true;
                self.stopBecause(.cleanup_failed);
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
        };
    }

    fn stopBecause(self: *Controller, cause: Cause) void {
        if (self.first_cause == null) self.first_cause = cause;
        self.phase = .aborting;
    }

    fn normalize(self: *Controller) void {
        if (self.first_cause != null) {
            const empty = !self.held[0] and !self.held[1] and !self.held[2];
            self.phase = if (empty and self.pending == null) .stopped else if (self.cleanup_blocked or self.deadline_expired) .unresponsive else .aborting;
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
        } else if (self.phase == .aborting or self.phase == .unresponsive) {
            // takeEffect's global pending guard retains every parent during an
            // outstanding child acquisition, including cancellation/late success.
            if (self.held[2]) return .{ .executor = .joiner, .kind = if (self.worker_joined) .release else .join_worker, .resource = .worker };
            if (self.held[1]) return .{ .executor = .native, .kind = if (self.device_fenced) .release else .fence_device, .resource = .device };
            if (self.held[0]) return .{ .executor = .allocator, .kind = .release, .resource = .storage };
        }
        return null;
    }
};
