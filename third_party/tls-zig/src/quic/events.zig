//! Fixed-allocation acknowledged event custody; no provider or transport calls.
//! Queue is move-only and serialized. Borrowed payloads remain stable through
//! appends, and expire at ack/cancel/deinit. The Engine must destroy any provider
//! before canceling this queue; this module owns no provider input leases.
const std = @import("std");
const c = @import("contract.zig");
pub const Error = error{ OutOfMemory, InvalidCapacity, OutOfGenerations, Canceled, CounterExhausted, Capacity, InvalidSecret, PayloadTooLarge, InvalidToken, NotBorrowed, NotConsumed, AlreadyConsumed, ReentrantCall } || c.ConsumeError;
const Kind = enum { crypto, secret, peer_parameters, handshake_complete, alert };
const Slot = struct {
    kind: Kind = .crypto,
    length: usize = 0,
    sequence: u64 = 0,
    level: c.EncryptionLevel = .initial,
    direction: c.Direction = .read,
    peer: c.PeerAuthentication = .configured_server_policy,
    alert: u8 = 0,
};

pub const Queue = struct {
    allocator: std.mem.Allocator,
    limits: c.Limits,
    owner: c.OwnerId,
    slots: []Slot,
    storage: []u8,
    head: usize = 0,
    length: usize = 0,
    data_count: usize = 0,
    next_sequence: ?u64 = 1,
    borrowed: bool = false,
    consumed: bool = false,
    in_callback: bool = false,
    terminal: ?enum { canceled, counter_exhausted } = null,

    /// Two allocations, both checked before use. No allocation during push/borrow/
    /// consume/ack/cancel. Payload storage is slots * bytes-per-slot, not provider heap.
    pub fn init(allocator: std.mem.Allocator, limits: c.Limits) Error!Queue {
        limits.validate() catch return error.InvalidCapacity;
        const bytes = limits.payloadStorageBytes() catch return error.InvalidCapacity;
        _ = std.math.mul(usize, limits.event_slots, @sizeOf(Slot)) catch return error.InvalidCapacity;
        const owner = c.freshOwner() catch return error.OutOfGenerations;
        const slots = try allocator.alloc(Slot, limits.event_slots);
        errdefer allocator.free(slots);
        const storage = try allocator.alloc(u8, bytes.value);
        @memset(slots, .{});
        @memset(storage, 0);
        return .{ .allocator = allocator, .limits = limits, .owner = owner, .slots = slots, .storage = storage };
    }
    fn live(self: *const Queue) Error!void {
        if (self.in_callback) return error.ReentrantCall;
        if (self.terminal) |reason| return switch (reason) {
            .canceled => error.Canceled,
            .counter_exhausted => error.CounterExhausted,
        };
    }
    fn block(self: *Queue, index: usize) []u8 {
        const start = index * self.limits.event_payload_bytes.value;
        return self.storage[start..][0..self.limits.event_payload_bytes.value];
    }
    fn requireSequence(self: *Queue) Error!void {
        if (self.next_sequence == null) {
            self.terminal = .counter_exhausted;
            self.erase();
            return error.CounterExhausted;
        }
    }
    /// Commit a preflighted payload copy and descriptor exactly once.
    fn append(self: *Queue, initial: Slot, bytes: []const u8) void {
        const index = (self.head + self.length) % self.slots.len;
        var slot = initial;
        slot.sequence = self.next_sequence.?;
        slot.length = bytes.len;
        @memcpy(self.block(index)[0..bytes.len], bytes);
        self.slots[index] = slot;
        self.next_sequence = if (slot.sequence == std.math.maxInt(u64)) null else slot.sequence + 1;
        self.length += 1;
        if (slot.kind == .crypto) self.data_count += 1;
    }
    pub fn pushCrypto(self: *Queue, level: c.EncryptionLevel, bytes: []const u8) Error!c.Transfer {
        try self.live();
        if (bytes.len == 0) return .{ .accepted = .{ .value = 0 }, .wait = .progress };
        try self.requireSequence();
        if (self.length == self.slots.len or self.data_count == self.slots.len - self.limits.control_slots)
            return .{ .accepted = .{ .value = 0 }, .wait = .event_capacity };
        const count = @min(bytes.len, self.limits.event_payload_bytes.value);
        self.append(.{ .kind = .crypto, .level = level }, bytes[0..count]);
        return .{ .accepted = .{ .value = count }, .wait = if (count < bytes.len) .event_capacity else .progress };
    }
    fn control(self: *Queue, slot: Slot, bytes: []const u8) Error!void {
        try self.live();
        try self.requireSequence();
        if (bytes.len > self.limits.event_payload_bytes.value) return error.PayloadTooLarge;
        if (self.length == self.slots.len) return error.Capacity;
        self.append(slot, bytes);
    }
    pub fn pushSecret(self: *Queue, level: c.EncryptionLevel, direction: c.Direction, suite: c.CipherSuite, bytes: []const u8) Error!void {
        try self.live();
        if (level == .initial or suite != .aes128gcm_sha256 or bytes.len != 32) return error.InvalidSecret;
        try self.control(.{ .kind = .secret, .level = level, .direction = direction }, bytes);
    }
    pub fn pushParameters(self: *Queue, bytes: []const u8) Error!void {
        try self.live();
        if (bytes.len > self.limits.peer_parameter_bytes.value) return error.PayloadTooLarge;
        try self.control(.{ .kind = .peer_parameters }, bytes);
    }
    /// The owning Engine, not this storage layer, must check every readiness gate.
    pub fn pushComplete(self: *Queue, peer: c.PeerAuthentication) Error!void {
        try self.control(.{ .kind = .handshake_complete, .peer = peer }, &.{});
    }
    pub fn pushAlert(self: *Queue, alert: u8) Error!void {
        try self.control(.{ .kind = .alert, .alert = alert }, &.{});
    }
    fn event(self: *Queue) c.Event {
        const slot = self.slots[self.head];
        const bytes = self.block(self.head)[0..slot.length];
        return .{ .id = .{ .owner = self.owner, .sequence = .{ .value = slot.sequence } }, .payload = switch (slot.kind) {
            .crypto => .{ .crypto = .{ .level = slot.level, .bytes = bytes } },
            .secret => .{ .secret = .{ .level = slot.level, .direction = slot.direction, .suite = .aes128gcm_sha256, .bytes = bytes[0..32] } },
            .peer_parameters => .{ .peer_parameters = bytes },
            .handshake_complete => .{ .handshake_complete = slot.peer },
            .alert => .{ .alert = slot.alert },
        } };
    }
    pub fn next(self: *Queue) Error!?c.Event {
        try self.live();
        if (self.length == 0) return null;
        self.borrowed = true;
        return self.event();
    }
    fn validateHead(self: *Queue, token: c.EventId) Error!void {
        try self.live();
        if (self.length == 0 or !c.EventId.eql(self.event().id, token)) return error.InvalidToken;
        if (!self.borrowed) return error.NotBorrowed;
    }
    /// Calls the consumer synchronously while custody remains owned. Only success
    /// permits acknowledgement; a trusted consumer is responsible for doing the
    /// copy/derivation it reports. A failing callback must be retry-safe.
    pub fn consume(self: *Queue, token: c.EventId, consumer: c.Consumer) Error!void {
        try self.validateHead(token);
        if (self.consumed) return error.AlreadyConsumed;
        self.in_callback = true;
        defer self.in_callback = false;
        try consumer.accept(consumer.context, self.event());
        self.consumed = true;
    }
    pub fn acknowledge(self: *Queue, token: c.EventId) Error!void {
        try self.validateHead(token);
        if (!self.consumed) return error.NotConsumed;
        if (self.slots[self.head].kind == .crypto) self.data_count -= 1;
        std.crypto.secureZero(u8, self.block(self.head));
        self.slots[self.head] = .{};
        self.head = (self.head + 1) % self.slots.len;
        self.length -= 1;
        self.borrowed = false;
        self.consumed = false;
    }
    fn erase(self: *Queue) void {
        std.crypto.secureZero(u8, self.storage);
        @memset(self.slots, .{});
        self.length = 0;
        self.data_count = 0;
        self.head = 0;
        self.borrowed = false;
        self.consumed = false;
    }
    /// Invalidates all views immediately but keeps zeroed allocations until deinit.
    pub fn cancel(self: *Queue) Error!void {
        if (self.in_callback) return error.ReentrantCall;
        if (self.terminal == null) self.terminal = .canceled;
        self.erase();
    }
    pub fn deinit(self: *Queue) Error!void {
        try self.cancel();
        // Allocator.free writes undefined before invoking rawFree in Debug.
        // Hand the explicitly zeroed secret allocation directly to the allocator.
        if (self.storage.len != 0)
            self.allocator.rawFree(self.storage, .fromByteUnits(@alignOf(u8)), @returnAddress());
        self.allocator.free(self.slots);
        self.storage = &.{};
        self.slots = &.{};
    }
};

test "event sequence exhaustion is terminal and clears custody" {
    const t = std.testing;
    var queue = try Queue.init(t.allocator, .{});
    defer queue.deinit() catch unreachable;
    queue.next_sequence = std.math.maxInt(u64);
    try queue.pushParameters(&.{ 1, 2 });
    const event = (try queue.next()).?;
    try t.expectEqual(std.math.maxInt(u64), event.id.sequence.value);
    try t.expectError(error.CounterExhausted, queue.pushAlert(1));
    try t.expectEqual(@as(usize, 0), queue.length);
    try t.expectError(error.CounterExhausted, queue.next());
    try t.expectEqualSlices(u8, &.{ 0, 0 }, event.payload.peer_parameters);
}
