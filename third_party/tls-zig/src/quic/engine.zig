//! Owns native TLS, copied input rings and acknowledged output/control events.
//! Engine values are move-only and serialized. State has a stable address for C.
const std = @import("std");
const builtin = @import("builtin");
const core = @import("tls_quic");
const native = @import("quic_native_abi");
pub const contract = core.contract;
const c = contract;
const Queue = core.events.Queue;
pub const Error = c.Error || core.events.Error || error{
    Closed,
    TimedOut,
    NativeConfiguration,
    NativeFailure,
    InvalidProviderResult,
    PeerPolicyRejected,
    ConsumerRejected,
    UnexpectedLevel,
};
pub const Budget = struct {
    input: c.ByteCount = .{ .value = 16 * 1024 },
    output: c.ByteCount = .{ .value = 16 * 1024 },
};
pub const TestHooks = if (builtin.is_test) struct {
    fail_release_once: bool = false,
    fail_alert: bool = false,
    overreport_input: bool = false,
    leases: usize = 0,
    releases: usize = 0,
    release_failures: usize = 0,
    teardown_releases: usize = 0,
    provider_destroyed: bool = false,
    input_cleared_after_provider: bool = false,
} else void;

pub fn capabilities() c.Capabilities {
    var value: native.Capabilities = undefined;
    if (native.tlsq_query(1, &value) != 0) return .{};
    return .{ .recordless = value.compiled_recordless == 1, .tls13 = true, .quic_v1 = true, .aes128gcm_sha256 = true, .runtime = if (value.runtime_available == 1 and value.qualified_target == 1) .available else .unavailable };
}
const Ring = struct { head: usize = 0, length: usize = 0 };
// Lease at most one TLS Handshake message at a time. Otherwise a provider can
// retain a buffer spanning the old message and surplus bytes when keys change,
// making queued old-level data indistinguishable from an already supplied lease.
const Framing = struct {
    header: [4]u8 = @splat(0),
    have: usize = 0,
    remaining: usize = 0,
    fn prefix(self: *Framing, bytes: []const u8) usize {
        if (self.have < 4) {
            const count = @min(bytes.len, 4 - self.have);
            @memcpy(self.header[self.have..][0..count], bytes[0..count]);
            self.have += count;
            if (self.have == 4) {
                self.remaining = (@as(usize, self.header[1]) << 16) | (@as(usize, self.header[2]) << 8) | self.header[3];
                if (self.remaining == 0) self.have = 0;
            }
            return count;
        }
        const count = @min(bytes.len, self.remaining);
        self.remaining -= count;
        if (self.remaining == 0) self.have = 0;
        return count;
    }
};
const Lease = struct { level: c.EncryptionLevel, length: usize, pointer: [*]const u8 };
const Metadata = struct {
    id: c.EventId,
    kind: enum { other, parameters, secret, complete },
    level: c.EncryptionLevel = .initial,
    direction: c.Direction = .read,
};
const State = struct {
    allocator: std.mem.Allocator,
    queue: Queue,
    input: []u8,
    capacity: usize,
    rings: [3]Ring = @splat(.{}),
    framing: [3]Framing = @splat(.{}),
    lease: ?Lease = null,
    provider: ?*native.Provider = null,
    busy: bool = false,
    tearing_down: bool = false,
    failure: ?Error = null,
    callback_error: ?Error = null,
    deadline: c.MonotonicNs,
    last_now: c.MonotonicNs,
    read_level: c.EncryptionLevel = .initial,
    borrowed: ?Metadata = null,
    tls_finished: bool = false,
    peer: c.PeerAuthentication = .configured_server_policy,
    parameters_accepted: bool = false,
    installed: [3][2]bool = @splat(@splat(false)),
    completion_enqueued: bool = false,
    completion_acked: bool = false,
    last_native: ?native.Result = null,
    hooks: if (builtin.is_test) ?*TestHooks else void = if (builtin.is_test) null else {},

    fn live(self: *State) Error!void {
        if (self.busy) return error.ReentrantCall;
        if (self.failure) |reason| return reason;
    }
    fn block(self: *State, level: c.EncryptionLevel) []u8 {
        const offset = @as(usize, @backingInt(level)) * self.capacity;
        return self.input[offset..][0..self.capacity];
    }
    /// Called internally after public entry closes; release callbacks remain live.
    fn terminate(self: *State, reason: Error) void {
        if (self.failure != null) return;
        self.failure = reason;
        self.tearing_down = true;
        if (native.tlsq_destroy(&self.provider) != 0) unreachable;
        if (builtin.is_test) if (self.hooks) |hooks| {
            hooks.provider_destroyed = true;
        };
        self.tearing_down = false;
        self.lease = null;
        self.queue.cancel() catch unreachable;
        std.crypto.secureZero(u8, self.input);
        self.rings = @splat(.{});
        std.crypto.secureZero(u8, std.mem.asBytes(&self.framing));
        self.borrowed = null;
        if (builtin.is_test) if (self.hooks) |hooks| {
            hooks.input_cleared_after_provider = hooks.provider_destroyed;
        };
    }
    fn ready(self: *State) Error!void {
        if (self.failure != null or self.completion_enqueued or !self.tls_finished or
            !self.parameters_accepted or self.queue.length != 0) return;
        for ([_]usize{ 1, 2 }) |level| {
            if (!self.installed[level][0] or !self.installed[level][1]) return;
        }
        self.queue.pushComplete(self.peer) catch |err| {
            self.terminate(err);
            return err;
        };
        self.completion_enqueued = true;
    }
    fn reject(self: *State, reason: Error) i32 {
        if (self.callback_error == null) self.callback_error = reason;
        return 0;
    }
};

pub const Engine = struct {
    state: ?*State,
    /// Gate before wrapper allocation; retained configuration is copied by C.
    pub fn init(allocator: std.mem.Allocator, plan: c.Plan) Error!Engine {
        try plan.verify(capabilities());
        const cfg = plan.config;
        const bytes = std.math.mul(usize, cfg.limits.input_bytes.value, 3) catch return error.InvalidCapacity;
        var queue = try Queue.init(allocator, cfg.limits);
        errdefer queue.deinit() catch unreachable;
        const input = try allocator.alloc(u8, bytes);
        @memset(input, 0);
        errdefer {
            std.crypto.secureZero(u8, input);
            allocator.rawFree(input, .fromByteUnits(@alignOf(u8)), @returnAddress());
        }
        const state = try allocator.create(State);
        errdefer allocator.destroy(state);
        state.* = .{ .allocator = allocator, .queue = queue, .input = input, .capacity = cfg.limits.input_bytes.value, .deadline = plan.deadline, .last_now = cfg.now };
        const options = nativeConfig(cfg);
        const callbacks: native.Callbacks = .{ .abi_version = 1, .context = state, .send = send, .receive = receive, .release = release, .secret = secret, .parameters = parameters, .alert = alert };
        switch (native.tlsq_create(&options, &callbacks, &state.provider)) {
            0 => if (state.provider == null) return error.InvalidProviderResult,
            1 => return error.InvalidPolicy,
            2 => return error.UnavailableCapability,
            3 => return error.OutOfMemory,
            4 => return error.NativeConfiguration,
            else => return error.InvalidProviderResult,
        }
        return .{ .state = state };
    }
    fn live(self: *Engine) Error!*State {
        const state = self.state orelse return error.Closed;
        try state.live();
        return state;
    }
    pub fn offerCrypto(self: *Engine, level: c.EncryptionLevel, bytes: []const u8) Error!c.Transfer {
        const state = try self.live();
        if (bytes.len == 0) return .{ .accepted = .{ .value = 0 }, .wait = .progress };
        if (@backingInt(level) < @backingInt(state.read_level)) {
            state.terminate(error.UnexpectedLevel);
            return error.UnexpectedLevel;
        }
        const ring = &state.rings[@backingInt(level)];
        const count = @min(bytes.len, state.capacity - ring.length);
        const target = state.block(level);
        const tail = (ring.head + ring.length) % state.capacity;
        const first = @min(count, state.capacity - tail);
        @memcpy(target[tail..][0..first], bytes[0..first]);
        @memcpy(target[0 .. count - first], bytes[first..count]);
        ring.length += count;
        return .{ .accepted = .{ .value = count }, .wait = if (count < bytes.len) .input_capacity else .progress };
    }
    pub fn advance(self: *Engine, now: c.MonotonicNs, budget: Budget) Error!c.Wait {
        const state = try self.live();
        if (now.value < state.last_now.value) return error.InvalidTime;
        if (!state.completion_enqueued and now.value >= state.deadline.value) {
            state.terminate(error.TimedOut);
            return error.TimedOut;
        }
        state.last_now = now;
        if (state.queue.length != 0) return .event_capacity;
        state.busy = true;
        defer state.busy = false;
        var result: native.Result = undefined;
        const status = native.tlsq_step(state.provider.?, budget.input.value, budget.output.value, &result);
        if (status != 0 and status != 7) {
            state.terminate(error.InvalidProviderResult);
            return error.InvalidProviderResult;
        }
        if (builtin.is_test) if (state.hooks) |hooks| {
            if (hooks.overreport_input and budget.input.value < std.math.maxInt(usize)) result.input_delivered = budget.input.value + 1;
        };
        state.last_native = result;
        if (result.input_delivered > budget.input.value or result.output_accepted > budget.output.value) {
            state.terminate(error.ProviderOverconsumption);
            return error.ProviderOverconsumption;
        }
        if (status == 7) {
            const reason = state.callback_error orelse error.NativeFailure;
            state.terminate(reason);
            return reason;
        }
        // A final old-level lease may still be held by SSL until cleanup. The
        // framing boundary guarantees it cannot hide bytes of another message.
        // Anything queued beyond that lease is undelivered surplus (RFC 9001
        // 4.1.3), and must not survive into a higher encryption level/readiness.
        for (0..@backingInt(state.read_level)) |index| {
            const held = if (state.lease) |lease| if (@backingInt(lease.level) == index) lease.length else 0 else 0;
            if (state.rings[index].length > held) {
                state.terminate(error.UnexpectedLevel);
                return error.UnexpectedLevel;
            }
        }
        if (result.tls_complete == 1) {
            state.tls_finished = true;
            state.peer = switch (result.peer_authentication) {
                1 => .configured_server_policy,
                2 => .verified_server_identity,
                3 => .verified_client_certificate,
                else => {
                    state.terminate(error.InvalidProviderResult);
                    return error.InvalidProviderResult;
                },
            };
        }
        try state.ready();
        if (state.queue.length != 0) return .event_capacity;
        return switch (result.wait) {
            0 => .progress,
            1 => .network_input,
            2 => .event_capacity,
            3 => .local_work,
            else => {
                state.terminate(error.InvalidProviderResult);
                return error.InvalidProviderResult;
            },
        };
    }
    pub fn nextEvent(self: *Engine) Error!?c.Event {
        const state = try self.live();
        const event = (try state.queue.next()) orelse return null;
        var meta: Metadata = .{ .id = event.id, .kind = .other };
        switch (event.payload) {
            .peer_parameters => meta.kind = .parameters,
            .secret => |value| {
                meta.kind = .secret;
                meta.level = value.level;
                meta.direction = value.direction;
            },
            .handshake_complete => meta.kind = .complete,
            else => {},
        }
        state.borrowed = meta;
        return event;
    }
    pub fn consume(self: *Engine, token: c.EventId, consumer: c.Consumer) Error!void {
        const state = try self.live();
        state.busy = true;
        defer state.busy = false;
        state.queue.consume(token, consumer) catch |err| {
            if (err == error.Rejected) {
                const reason: Error = if (state.borrowed != null and state.borrowed.?.kind == .parameters) error.PeerPolicyRejected else error.ConsumerRejected;
                state.terminate(reason);
                return reason;
            }
            return err;
        };
    }
    pub fn acknowledge(self: *Engine, token: c.EventId) Error!void {
        const state = try self.live();
        const meta = state.borrowed orelse return error.NotBorrowed;
        if (!c.EventId.eql(meta.id, token)) return error.InvalidToken;
        try state.queue.acknowledge(token);
        state.borrowed = null;
        switch (meta.kind) {
            .parameters => state.parameters_accepted = true,
            .secret => state.installed[@backingInt(meta.level)][@backingInt(meta.direction)] = true,
            .complete => state.completion_acked = true,
            .other => {},
        }
        try state.ready();
    }
    pub fn isReady(self: *Engine) Error!bool {
        return (try self.live()).completion_acked;
    }
    /// Diagnostic snapshot contains counts/reason codes, never keys or input bytes.
    pub fn diagnostic(self: *const Engine) ?native.Result {
        const state = self.state orelse return null;
        return state.last_native;
    }
    pub fn cancel(self: *Engine) Error!void {
        const state = self.state orelse return;
        if (state.busy) return error.ReentrantCall;
        state.terminate(error.Canceled);
    }
    pub fn deinit(self: *Engine) Error!void {
        const state = self.state orelse return;
        if (state.busy) return error.ReentrantCall;
        state.terminate(error.Closed);
        const allocator = state.allocator;
        try state.queue.deinit();
        std.crypto.secureZero(u8, state.input);
        allocator.rawFree(state.input, .fromByteUnits(@alignOf(u8)), @returnAddress());
        allocator.destroy(state);
        self.state = null;
    }
    pub const testingSetHooks = if (builtin.is_test) setHooks else void;
    fn setHooks(self: *Engine, hooks: *TestHooks) Error!void {
        (try self.live()).hooks = hooks;
    }
};

fn nativeBytes(bytes: []const u8) native.Bytes {
    return .{ .data = if (bytes.len == 0) null else bytes.ptr, .length = bytes.len };
}
fn nativeConfig(cfg: c.Config) native.Config {
    const empty = nativeBytes(&.{});
    var value: native.Config = .{ .abi_version = 1, .role = 0, .identity_kind = 0, .require_client_certificate = 0, .wall_time_seconds = cfg.wall_time.value, .trust_file = empty, .certificate_file = empty, .private_key_file = empty, .identity = empty, .alpn = nativeBytes(cfg.alpn), .local_parameters = nativeBytes(cfg.local_parameters), .peer_parameter_limit = cfg.limits.peer_parameter_bytes.value };
    switch (cfg.policy) {
        .client => |policy| {
            value.trust_file = nativeBytes(policy.trust_file);
            switch (policy.peer) {
                .dns => |name| value.identity = nativeBytes(name),
                .ip => |name| {
                    value.identity_kind = 1;
                    value.identity = nativeBytes(name);
                },
            }
            if (policy.credentials) |credentials| {
                value.certificate_file = nativeBytes(credentials.certificate_file);
                value.private_key_file = nativeBytes(credentials.private_key_file);
            }
        },
        .server => |policy| {
            value.role = 1;
            value.certificate_file = nativeBytes(policy.credentials.certificate_file);
            value.private_key_file = nativeBytes(policy.credentials.private_key_file);
            switch (policy.client_authentication) {
                .none => {},
                .required => |trust| {
                    value.require_client_certificate = 1;
                    value.trust_file = nativeBytes(trust);
                },
            }
        },
    }
    return value;
}
fn context(arg: ?*anyopaque) *State {
    return @ptrCast(@alignCast(arg.?));
}
fn levelFromNative(value: u32) ?c.EncryptionLevel {
    return switch (value) {
        0 => .initial,
        1 => .handshake,
        2 => .application,
        else => null,
    };
}
fn view(bytes: native.Bytes) ?[]const u8 {
    if (bytes.length == 0) return &.{};
    return if (bytes.data) |data| data[0..bytes.length] else null;
}
fn send(arg: ?*anyopaque, raw_level: u32, bytes: native.Bytes, accepted: *usize) callconv(.c) i32 {
    const state = context(arg);
    accepted.* = 0;
    const level = levelFromNative(raw_level) orelse return state.reject(error.InvalidProviderResult);
    const data = view(bytes) orelse return state.reject(error.InvalidProviderResult);
    const result = state.queue.pushCrypto(level, data) catch |err| return state.reject(err);
    _ = result.acceptedPrefix(data) catch |err| return state.reject(err);
    accepted.* = result.accepted.value;
    return 1;
}
fn receive(arg: ?*anyopaque, raw_level: u32, maximum: usize, out: *native.Bytes) callconv(.c) i32 {
    const state = context(arg);
    out.* = nativeBytes(&.{});
    const level = levelFromNative(raw_level) orelse return state.reject(error.InvalidProviderResult);
    if (state.lease != null) return state.reject(error.InvalidProviderResult);
    state.read_level = level;
    const ring = &state.rings[@backingInt(level)];
    const available = @min(ring.length, state.capacity - ring.head, maximum);
    if (available == 0) return 1;
    const length = state.framing[@backingInt(level)].prefix(state.block(level)[ring.head..][0..available]);
    const data = state.block(level)[ring.head..][0..length];
    state.lease = .{ .level = level, .length = length, .pointer = data.ptr };
    if (builtin.is_test) if (state.hooks) |hooks| {
        hooks.leases += 1;
    };
    out.* = nativeBytes(data);
    return 1;
}
fn release(arg: ?*anyopaque, raw_level: u32, bytes: native.Bytes) callconv(.c) i32 {
    const state = context(arg);
    const lease = state.lease orelse return state.reject(error.InvalidProviderResult);
    if (raw_level != @backingInt(lease.level) or bytes.length != lease.length or bytes.data != lease.pointer)
        return state.reject(error.InvalidProviderResult);
    if (builtin.is_test) if (state.hooks) |hooks| {
        if (state.tearing_down) hooks.teardown_releases += 1;
        if (hooks.fail_release_once) {
            hooks.fail_release_once = false;
            hooks.release_failures += 1;
            return state.reject(error.NativeFailure);
        }
        hooks.releases += 1;
    };
    const ring = &state.rings[@backingInt(lease.level)];
    std.crypto.secureZero(u8, state.block(lease.level)[ring.head..][0..lease.length]);
    ring.head = (ring.head + lease.length) % state.capacity;
    ring.length -= lease.length;
    state.lease = null;
    return 1;
}
fn secret(arg: ?*anyopaque, raw_level: u32, raw_direction: u32, suite: u32, bytes: native.Bytes) callconv(.c) i32 {
    const state = context(arg);
    const level = levelFromNative(raw_level) orelse return state.reject(error.InvalidProviderResult);
    const direction: c.Direction = switch (raw_direction) {
        0 => .read,
        1 => .write,
        else => return state.reject(error.InvalidProviderResult),
    };
    if (suite != 0x1301) return state.reject(error.UnavailableCapability);
    const data = view(bytes) orelse return state.reject(error.InvalidProviderResult);
    state.queue.pushSecret(level, direction, .aes128gcm_sha256, data) catch |err| return state.reject(err);
    if (direction == .read) state.read_level = level;
    return 1;
}
fn parameters(arg: ?*anyopaque, bytes: native.Bytes) callconv(.c) i32 {
    const state = context(arg);
    const data = view(bytes) orelse return state.reject(error.InvalidProviderResult);
    state.queue.pushParameters(data) catch |err| return state.reject(err);
    return 1;
}
fn alert(arg: ?*anyopaque, code: u32) callconv(.c) i32 {
    const state = context(arg);
    if (builtin.is_test) if (state.hooks) |hooks| {
        if (hooks.fail_alert) return state.reject(error.NativeFailure);
    };
    if (code > 255) return state.reject(error.InvalidProviderResult);
    state.queue.pushAlert(@intCast(code)) catch |err| return state.reject(err);
    return 1;
}
