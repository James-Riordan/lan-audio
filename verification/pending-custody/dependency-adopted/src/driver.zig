//! Engineering contract (2026-09-26)
//! Serialized nonblocking transport driver with bounded ciphertext queues and early-response probe.
//! File contract: docs/reference/files/src/driver.zig.md
//! Ownership and invariant: Owns Engine, borrows transport context and optional atomic cancellation
//! flag. Read buffer remains exclusively borrowed until the operation completes or fails. Preserve
//! input suffixes and output prefixes. step has at most one transport callback or TLS/BIO
//! operation. Probe cannot bypass unfinished SSL_write, discard ciphertext, complete the write or
//! extend its deadline. Shutdown reads inherit the original close deadline.
//! Next implementation obligation: Keep serialized semantics explicit. Add a separate duplex design
//! only when a consumer needs it. Build deterministic scheduler traces for cancellation, half-close
//! and peer data during blocked output; verify readiness and deadline transitions rather than
//! counting loops as fairness.
//! Verification: tests/driver.zig
//! Nonblocking host loop. Only the cancellation flag may be accessed concurrently.
//! The host owns the socket and polling; callbacks must never block or reenter us.
const std = @import("std");
const tls = @import("root.zig");

pub const Transport = struct {
    context: *anyopaque,
    /// null = would block, 1..bytes.len = sent prefix. Zero is a transport error.
    send: *const fn (*anyopaque, []const u8) error{TransportFailure}!?usize,
    /// null = would block, zero = raw EOF, otherwise initialized buffer prefix.
    recv: *const fn (*anyopaque, []u8) error{TransportFailure}!?usize,
};
pub const Error = tls.Error || error{ OperationInProgress, OperationDeadline, TransportFailure, TransportContract };
pub const Result = union(enum) {
    /// More work can run immediately. Yield to other connections for fairness.
    again,
    wait_input,
    wait_output,
    /// Operation finished: read/write byte count, or zero for handshake.
    complete: usize,
    closed,
    /// Shutdown paused without consuming final peer data. Begin a read, then
    /// resume shutdown. The original shutdown deadline remains in force.
    plaintext_available,
};
pub const ProbeResult = union(enum) {
    again,
    no_data,
    data: usize,
    closed,
    /// SSL_write has not finished. Resume step before trying to read.
    write_pending,
    /// Resume the active write, or beginFlush when idle, before retrying.
    output_pending,
};

pub const Driver = struct {
    engine: tls.Engine,
    transport: Transport,
    canceled: ?*const std.atomic.Value(bool),
    input: [32768]u8 = undefined,
    input_start: usize = 0,
    input_end: usize = 0,
    output: [16384]u8 = undefined,
    output_start: usize = 0,
    output_end: usize = 0,
    eof: bool = false,
    active: ?Operation = null,
    phase: enum { drive, drain, send, feed, receive } = .drive,
    wanted: tls.Progress = .need_input,
    result: ?Result = null,
    failure: ?tls.Error = null,
    terminal: ?Error = null,
    last_ms: u64,
    deadline_ms: u64 = 0,
    shutdown_deadline_ms: ?u64 = null,
    probe_phase: enum { read, drain, receive, feed } = .read,

    const Operation = union(enum) { handshake, write: usize, read: []u8, shutdown, flush };

    /// Move-only owner of Engine. The transport and flag must outlive this value.
    pub fn init(config: tls.Config, transport: Transport, canceled: ?*const std.atomic.Value(bool)) Error!Driver {
        return .{ .engine = try tls.Engine.init(config), .transport = transport, .canceled = canceled, .last_ms = config.now_ms };
    }
    pub fn deinit(self: *Driver) void {
        self.cancel();
    }
    /// Call only on the serialized driver thread. Other threads store true into
    /// the cancellation flag; they must not close or mutate this Engine.
    pub fn cancel(self: *Driver) void {
        self.engine.cancel();
        self.active = null;
        if (self.terminal == null) self.terminal = error.Canceled;
    }
    fn abort(self: *Driver, err: Error) Error {
        self.terminal = err;
        self.engine.cancel();
        self.active = null;
        return err;
    }
    fn check(self: *Driver, now_ms: u64) Error!void {
        if (self.terminal) |err| return err;
        if (self.canceled) |flag| if (flag.load(.acquire)) return self.abort(error.Canceled);
        if (now_ms < self.last_ms) return error.InvalidState;
        self.last_ms = now_ms;
        if (now_ms >= self.deadline_ms) return self.abort(error.OperationDeadline);
        // A failed Engine may still have an alert to drain. Preserve its original
        // error while applying the driver's operation deadline/cancel above.
        if (self.failure == null) self.engine.tick(now_ms) catch |err| return self.abort(err);
    }
    fn idle(self: *Driver) Error!void {
        if (self.terminal) |err| return err;
        if (self.active != null) return error.OperationInProgress;
    }
    fn begin(self: *Driver, op: Operation, now_ms: u64, deadline_ms: u64) Error!void {
        try self.idle();
        if (now_ms < self.last_ms) return error.InvalidState;
        self.deadline_ms = if (self.shutdown_deadline_ms) |closing| @min(closing, deadline_ms) else deadline_ms;
        try self.check(now_ms);
        self.active = op;
        self.phase = if (self.input_start < self.input_end) .feed else .drive;
        self.result = null;
        self.probe_phase = .read;
    }
    pub fn beginHandshake(self: *Driver, now_ms: u64, deadline_ms: u64) Error!void {
        try self.idle();
        if (self.shutdown_deadline_ms != null) return error.InvalidState;
        try self.begin(.handshake, now_ms, deadline_ms);
    }
    /// Copies bytes into the Engine before returning. One block, 1..16384 bytes.
    pub fn beginWrite(self: *Driver, bytes: []const u8, now_ms: u64, deadline_ms: u64) Error!void {
        try self.idle();
        if (self.shutdown_deadline_ms != null) return error.InvalidState;
        if (!self.engine.authenticated) return error.InvalidState;
        try self.begin(.{ .write = bytes.len }, now_ms, deadline_ms);
        self.engine.queuePlaintext(bytes) catch |err| {
            self.active = null;
            return err;
        };
    }
    /// buffer is borrowed exclusively until this operation returns a final result
    /// or error. Use its bytes only after complete; failed operations discard them.
    pub fn beginRead(self: *Driver, buffer: []u8, now_ms: u64, deadline_ms: u64) Error!void {
        try self.idle();
        if (buffer.len == 0 or !self.engine.authenticated) return error.InvalidState;
        try self.begin(.{ .read = buffer }, now_ms, deadline_ms);
    }
    pub fn beginShutdown(self: *Driver, now_ms: u64, deadline_ms: u64) Error!void {
        try self.idle();
        if (!self.engine.authenticated) return error.InvalidState;
        try self.begin(.shutdown, now_ms, deadline_ms);
        self.shutdown_deadline_ms = self.deadline_ms;
    }
    /// Send pending TLS protocol output without queueing application data.
    pub fn beginFlush(self: *Driver, now_ms: u64, deadline_ms: u64) Error!void {
        try self.idle();
        if (!self.engine.authenticated or self.shutdown_deadline_ms != null) return error.InvalidState;
        try self.begin(.flush, now_ms, deadline_ms);
    }
    /// Nonblocking early-response probe, idle or during an active write whose
    /// SSL_write has completed. Does not send/discard ciphertext or finish/pause
    /// that write. Keep driving step to finish the accepted block in wire order.
    /// buffer is borrowed only for this call; data(count) is authenticated TLS
    /// plaintext, not a complete/committable HTTP response. Idle probes use the
    /// supplied deadline; active writes retain their original deadline unchanged.
    pub fn probePeer(self: *Driver, buffer: []u8, now_ms: u64, idle_deadline_ms: u64) Error!ProbeResult {
        if (self.terminal) |err| return err;
        if (buffer.len == 0 or !self.engine.authenticated or self.shutdown_deadline_ms != null) return error.InvalidState;
        if (self.active) |op| {
            if (op != .write) return error.OperationInProgress;
        } else {
            if (now_ms < self.last_ms) return error.InvalidState;
            self.deadline_ms = idle_deadline_ms;
        }
        try self.check(now_ms);
        if (self.active != null and (self.result == null or self.result.? != .complete)) return .write_pending;
        switch (self.probe_phase) {
            .read => {
                const r = self.engine.readPlaintext(buffer) catch |err| {
                    // Do not resume an upload after a fatal peer record. Ciphertext
                    // already in custody cannot be bypassed to send a fatal alert.
                    self.terminal = err;
                    self.active = null;
                    return err;
                };
                switch (r.progress) {
                    .complete => return .{ .data = r.count },
                    .closed => return .closed,
                    .need_output => return .output_pending,
                    .need_input => self.probe_phase = if (self.active == null) .drain else if (self.input_start < self.input_end) .feed else .receive,
                    else => return self.abort(error.InvalidState),
                }
            },
            .drain => {
                // Only idle probes drain BIO output. Preserve any earlier prefix
                // until beginFlush/another normal operation sends it in order.
                if (self.active != null) {
                    self.probe_phase = .read;
                    return .again;
                }
                if (self.output_start < self.output_end) return .output_pending;
                const r = self.engine.drainRecords(&self.output) catch |err| return self.abort(err);
                self.output_start = 0;
                self.output_end = r.count;
                if (r.count != 0) return .output_pending;
                self.probe_phase = if (self.input_start < self.input_end) .feed else .receive;
            },
            .feed => {
                const r = self.engine.feedRecords(self.input[self.input_start..self.input_end]) catch |err| return self.abort(err);
                self.input_start += r.count;
                self.probe_phase = .read;
            },
            .receive => {
                if (self.eof) {
                    self.probe_phase = .read;
                    return .again;
                }
                const n = (self.transport.recv(self.transport.context, &self.input) catch return self.abort(error.TransportFailure)) orelse {
                    self.probe_phase = .read;
                    return .no_data;
                };
                if (n > self.input.len) return self.abort(error.TransportContract);
                if (n == 0) {
                    self.eof = true;
                    self.engine.transportEof() catch |err| return self.abort(err);
                    self.probe_phase = .read;
                } else {
                    self.input_start = 0;
                    self.input_end = n;
                    self.probe_phase = .feed;
                }
            },
        }
        return .again;
    }
    /// Performs at most one transport callback or one TLS/BIO operation. Pass a
    /// fresh monotonic time every call. Poll only for wait_input/wait_output, with
    /// a timeout bounded by deadline_ms and the host's cancellation wake cadence.
    pub fn step(self: *Driver, now_ms: u64) Error!Result {
        if (self.terminal) |err| return err;
        if (self.active == null) return error.InvalidState;
        try self.check(now_ms);
        switch (self.phase) {
            .drive => {
                const op = self.active.?;
                var count: usize = 0;
                const progress = blk: {
                    break :blk switch (op) {
                        .handshake => self.engine.handshake(),
                        .write => |n| write: {
                            count = n;
                            break :write self.engine.flushPlaintext();
                        },
                        .read => |buffer| read: {
                            const r = self.engine.readPlaintext(buffer) catch |err| break :read err;
                            count = r.count;
                            break :read r.progress;
                        },
                        .shutdown => self.engine.shutdown(),
                        .flush => self.engine.flushPlaintext(),
                    };
                } catch |err| {
                    if (err == error.InvalidState) {
                        self.active = null;
                        return err;
                    }
                    self.failure = err;
                    self.phase = .drain;
                    return .again;
                };
                self.wanted = progress;
                self.result = switch (progress) {
                    .complete => .{ .complete = count },
                    .closed => .closed,
                    .plaintext_available => .plaintext_available,
                    .need_input, .need_output => null,
                    .input_full => return self.abort(error.InvalidState),
                };
                self.phase = .drain;
            },
            .drain => {
                if (self.output_start < self.output_end) {
                    self.phase = .send;
                    return .again;
                }
                const r = self.engine.drainRecords(&self.output) catch |err| return self.abort(err);
                if (r.count > 0) {
                    self.output_start = 0;
                    self.output_end = r.count;
                    self.phase = .send;
                } else if (self.failure) |err| {
                    // Keep the Engine alive for diagnostics until deinit/cancel.
                    self.terminal = err;
                    self.active = null;
                    return err;
                } else if (self.result) |result| {
                    self.active = null;
                    return result;
                } else if (self.wanted == .need_output or self.eof) {
                    self.phase = .drive;
                } else {
                    self.phase = if (self.input_start < self.input_end) .feed else .receive;
                }
            },
            .send => {
                const bytes = self.output[self.output_start..self.output_end];
                const n = (self.transport.send(self.transport.context, bytes) catch return self.abort(error.TransportFailure)) orelse return .wait_output;
                if (n == 0 or n > bytes.len) return self.abort(error.TransportContract);
                self.output_start += n;
                if (self.output_start == self.output_end) self.phase = .drain;
            },
            .feed => {
                const bytes = self.input[self.input_start..self.input_end];
                const r = self.engine.feedRecords(bytes) catch |err| return self.abort(err);
                self.input_start += r.count;
                // Never overwrite a suffix: drive TLS to consume its BIO before
                // retrying any remaining bytes, including zero-consumption input_full.
                self.phase = .drive;
            },
            .receive => {
                const n = (self.transport.recv(self.transport.context, &self.input) catch return self.abort(error.TransportFailure)) orelse return .wait_input;
                if (n > self.input.len) return self.abort(error.TransportContract);
                if (n == 0) {
                    self.eof = true;
                    self.engine.transportEof() catch |err| return self.abort(err);
                    self.phase = .drive;
                } else {
                    self.input_start = 0;
                    self.input_end = n;
                    self.phase = .feed;
                }
            },
        }
        return .again;
    }
};
