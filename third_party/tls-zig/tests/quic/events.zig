const std = @import("std");
const quic = @import("tls_quic");
const c = quic.contract;
const Queue = quic.events.Queue;
const t = std.testing;
fn limits() c.Limits {
    return .{ .event_slots = 2, .control_slots = 1, .event_payload_bytes = .{ .value = 32 }, .peer_parameter_bytes = .{ .value = 32 } };
}
const Sink = struct {
    calls: usize = 0,
    copied: [32]u8 = @splat(0),
    block: bool = false,
    fn accept(raw: *anyopaque, event: c.Event) c.ConsumeError!void {
        const self: *Sink = @ptrCast(@alignCast(raw));
        if (self.block) return error.WouldBlock;
        self.calls += 1;
        switch (event.payload) {
            .crypto => |data| @memcpy(self.copied[0..data.bytes.len], data.bytes),
            .secret => |data| @memcpy(&self.copied, data.bytes),
            .peer_parameters => |data| @memcpy(self.copied[0..data.len], data),
            else => {},
        }
    }
    fn consumer(self: *Sink) c.Consumer {
        return .{ .context = self, .accept = accept };
    }
};

test "T03 stable head tail foreign stale and premature acknowledgement" {
    var q = try Queue.init(t.allocator, limits());
    defer q.deinit() catch unreachable;
    var source = [_]u8{ 1, 2, 3 };
    try t.expectEqual(@as(usize, 3), (try q.pushCrypto(.initial, &source)).accepted.value);
    const head = (try q.next()).?;
    source[0] = 99;
    const secret: [32]u8 = @splat(0x5a);
    try q.pushSecret(.handshake, .write, .aes128gcm_sha256, &secret);
    try t.expectEqualSlices(u8, &.{ 1, 2, 3 }, (try q.next()).?.payload.crypto.bytes);
    try t.expect(c.EventId.eql(head.id, (try q.next()).?.id));
    try t.expectError(error.NotConsumed, q.acknowledge(head.id));
    var wrong = head.id;
    wrong.sequence.value += 1;
    try t.expectError(error.InvalidToken, q.acknowledge(wrong));
    wrong = head.id;
    wrong.owner = try c.freshOwner();
    try t.expectError(error.InvalidToken, q.acknowledge(wrong));
    var sink: Sink = .{};
    try q.consume(head.id, sink.consumer());
    try t.expectError(error.AlreadyConsumed, q.consume(head.id, sink.consumer()));
    try q.acknowledge(head.id);
    try t.expectError(error.InvalidToken, q.acknowledge(head.id));
    const next = (try q.next()).?;
    try t.expectEqual(c.Direction.write, next.payload.secret.direction);
    try t.expectEqual(c.EncryptionLevel.handshake, next.payload.secret.level);
    try t.expectError(error.NotConsumed, q.acknowledge(next.id));
    try q.consume(next.id, sink.consumer());
    try q.acknowledge(next.id);
    try t.expectEqualSlices(u8, &secret, &sink.copied);
    try t.expectEqual(@as(usize, 2), sink.calls);
    try t.expectEqual(@as(?c.Event, null), try q.next());
}

test "T03 output prefixes reserve control capacity and never overwrite" {
    var q = try Queue.init(t.allocator, limits());
    defer q.deinit() catch unreachable;
    const bytes: [40]u8 = @splat(7);
    const sent = try q.pushCrypto(.handshake, &bytes);
    try t.expectEqual(@as(usize, 32), sent.accepted.value);
    try t.expectEqual(c.Wait.event_capacity, sent.wait);
    try t.expectEqual(@as(usize, 0), (try q.pushCrypto(.application, bytes[32..])).accepted.value);
    try q.pushParameters(&.{ 9, 8 });
    try t.expectError(error.Capacity, q.pushAlert(42));
    const first = (try q.next()).?;
    var sink: Sink = .{ .block = true };
    try t.expectError(error.WouldBlock, q.consume(first.id, sink.consumer()));
    try t.expectEqual(@as(usize, 0), sink.calls);
    try t.expectError(error.NotConsumed, q.acknowledge(first.id));
    sink.block = false;
    try q.consume(first.id, sink.consumer());
    try q.acknowledge(first.id);
    try t.expectEqual(@as(usize, 8), (try q.pushCrypto(.application, bytes[32..])).accepted.value);
    const parameters = (try q.next()).?;
    try t.expectEqualSlices(u8, &.{ 9, 8 }, parameters.payload.peer_parameters);
    try q.consume(parameters.id, sink.consumer());
    try q.acknowledge(parameters.id);
    try t.expectEqual(c.EncryptionLevel.application, (try q.next()).?.payload.crypto.level);
}

test "T03 cancellation erases pending secret storage and prevents identity reuse" {
    var q = try Queue.init(t.allocator, limits());
    defer q.deinit() catch unreachable;
    const secret: [32]u8 = @splat(0xab);
    try q.pushSecret(.application, .read, .aes128gcm_sha256, &secret);
    const borrowed = (try q.next()).?;
    // Allocation remains live after cancel; inspect clearing without dereferencing freed memory.
    const owned = borrowed.payload.secret.bytes;
    try q.cancel();
    try q.cancel();
    try t.expectEqualSlices(u8, &@as([32]u8, @splat(0)), owned);
    try t.expectError(error.Canceled, q.acknowledge(borrowed.id));
    try t.expectError(error.Canceled, q.pushSecret(.application, .read, .aes128gcm_sha256, &secret));
    var other = try Queue.init(t.allocator, limits());
    defer other.deinit() catch unreachable;
    try other.pushSecret(.application, .read, .aes128gcm_sha256, &secret);
    try t.expect(!c.OwnerId.eql(borrowed.id.owner, (try other.next()).?.id.owner));
    try t.expectError(error.InvalidToken, other.acknowledge(borrowed.id));
}

test "T03 callback reentry is rejected without destroying borrowed bytes" {
    var q = try Queue.init(t.allocator, limits());
    defer q.deinit() catch unreachable;
    try q.pushParameters(&.{ 4, 5, 6 });
    const Reenter = struct {
        queue: *Queue,
        checked: bool = false,
        fn accept(raw: *anyopaque, event: c.Event) c.ConsumeError!void {
            const self: *@This() = @ptrCast(@alignCast(raw));
            self.queue.cancel() catch |err| {
                if (err == error.ReentrantCall and std.mem.eql(u8, event.payload.peer_parameters, &.{ 4, 5, 6 })) {
                    self.checked = true;
                    return;
                }
                return error.Rejected;
            };
            return error.Rejected;
        }
    };
    var callback: Reenter = .{ .queue = &q };
    const event = (try q.next()).?;
    try q.consume(event.id, .{ .context = &callback, .accept = Reenter.accept });
    try t.expect(callback.checked);
    try q.acknowledge(event.id);
}

fn allocateAndFree(allocator: std.mem.Allocator) !void {
    var q = try Queue.init(allocator, limits());
    defer q.deinit() catch unreachable;
    try q.pushParameters(&.{1});
}
test "T03 construction unwinds each allocation failure" {
    try t.checkAllAllocationFailures(t.allocator, allocateAndFree, .{});
}

test "T03 invalid controls preserve queue and empty crypto is not EOF" {
    var q = try Queue.init(t.allocator, limits());
    defer q.deinit() catch unreachable;
    const secret: [32]u8 = @splat(1);
    try t.expectError(error.InvalidSecret, q.pushSecret(.initial, .read, .aes128gcm_sha256, &secret));
    try t.expectError(error.InvalidSecret, q.pushSecret(.handshake, .read, .aes128gcm_sha256, secret[0..31]));
    try t.expectError(error.InvalidSecret, q.pushSecret(.handshake, .read, @fromBackingInt(@intCast(0x1302)), &secret));
    try t.expectError(error.PayloadTooLarge, q.pushParameters(&@as([33]u8, @splat(1))));
    try t.expectEqual(@as(usize, 0), (try q.pushCrypto(.initial, &.{})).accepted.value);
    try t.expectEqual(@as(?c.Event, null), try q.next());
    try q.pushComplete(.verified_server_identity);
    try t.expectEqual(c.PeerAuthentication.verified_server_identity, (try q.next()).?.payload.handshake_complete);
}

const AuditAllocator = struct {
    underlying: std.mem.Allocator,
    allocations: usize = 0,
    frees: usize = 0,
    payload: ?[*]u8 = null,
    payload_cleared: bool = false,
    fn allocator(self: *@This()) std.mem.Allocator {
        return .{ .ptr = self, .vtable = &.{ .alloc = alloc, .resize = std.mem.Allocator.noResize, .remap = std.mem.Allocator.noRemap, .free = free } };
    }
    fn alloc(raw: *anyopaque, len: usize, alignment: std.mem.Alignment, ret: usize) ?[*]u8 {
        const self: *@This() = @ptrCast(@alignCast(raw));
        const memory = self.underlying.rawAlloc(len, alignment, ret) orelse return null;
        self.allocations += 1;
        if (self.allocations == 2) self.payload = memory;
        return memory;
    }
    fn free(raw: *anyopaque, memory: []u8, alignment: std.mem.Alignment, ret: usize) void {
        const self: *@This() = @ptrCast(@alignCast(raw));
        if (self.payload == memory.ptr) self.payload_cleared = std.mem.allEqual(u8, memory, 0);
        self.frees += 1;
        self.underlying.rawFree(memory, alignment, ret);
    }
};
test "T03 deinit clears payload before allocator free and retires allocations once" {
    var audit: AuditAllocator = .{ .underlying = t.allocator };
    var q = try Queue.init(audit.allocator(), limits());
    const secret: [32]u8 = @splat(0xdb);
    try q.pushSecret(.handshake, .read, .aes128gcm_sha256, &secret);
    _ = try q.next();
    try q.deinit();
    try q.deinit();
    try t.expect(audit.payload_cleared);
    try t.expectEqual(@as(usize, 2), audit.allocations);
    try t.expectEqual(@as(usize, 2), audit.frees);
}

test "T03 exhaustive five-action traces refine independent custody ledger" {
    // Eight actions, every length-five permutation: 32768 traces / 163840 steps.
    // The ledger owns expected sequence/order/copy state independently of Queue.
    var word: usize = 0;
    while (word < 32768) : (word += 1) {
        var q = try Queue.init(t.allocator, limits());
        defer q.deinit() catch unreachable;
        var pending: [2]u64 = undefined;
        var count: usize = 0;
        var emitted: u64 = 0;
        var retired: u64 = 0;
        var borrowed = false;
        var copied = false;
        var canceled = false;
        var sink: Sink = .{};
        var code = word;
        for (0..5) |_| {
            const action = code % 8;
            code /= 8;
            const id = c.EventId{ .owner = q.owner, .sequence = .{ .value = if (count > 0) pending[0] else 0 } };
            if (canceled) {
                if (action == 6) try q.cancel() else try t.expectError(error.Canceled, q.next());
                continue;
            }
            switch (action) {
                0 => {
                    if (count == 2) try t.expectError(error.Capacity, q.pushParameters(&.{7})) else {
                        try q.pushParameters(&.{7});
                        emitted += 1;
                        pending[count] = emitted;
                        count += 1;
                    }
                },
                1 => {
                    const got = try q.next();
                    if (count == 0) try t.expect(got == null) else {
                        try t.expect(c.EventId.eql(id, got.?.id));
                        borrowed = true;
                        try t.expectEqualSlices(u8, &.{7}, got.?.payload.peer_parameters);
                    }
                },
                2, 7 => {
                    sink.block = action == 7;
                    if (count == 0) try t.expectError(error.InvalidToken, q.consume(id, sink.consumer())) else if (!borrowed) try t.expectError(error.NotBorrowed, q.consume(id, sink.consumer())) else if (copied) try t.expectError(error.AlreadyConsumed, q.consume(id, sink.consumer())) else if (action == 7) try t.expectError(error.WouldBlock, q.consume(id, sink.consumer())) else {
                        try q.consume(id, sink.consumer());
                        copied = true;
                    }
                },
                3 => {
                    if (count == 0) try t.expectError(error.InvalidToken, q.acknowledge(id)) else if (!borrowed) try t.expectError(error.NotBorrowed, q.acknowledge(id)) else if (!copied) try t.expectError(error.NotConsumed, q.acknowledge(id)) else {
                        try q.acknowledge(id);
                        retired += 1;
                        count -= 1;
                        if (count > 0) pending[0] = pending[1];
                        borrowed = false;
                        copied = false;
                    }
                },
                4, 5 => {
                    var invalid = id;
                    if (action == 4) invalid.owner.generation.value = 0 else invalid.sequence.value += 1;
                    try t.expectError(error.InvalidToken, q.acknowledge(invalid));
                },
                6 => {
                    try q.cancel();
                    count = 0;
                    borrowed = false;
                    copied = false;
                    canceled = true;
                },
                else => unreachable,
            }
            try t.expectEqual(count, q.length);
            try t.expectEqual(borrowed, q.borrowed);
            try t.expectEqual(copied, q.consumed);
            if (!canceled) try t.expectEqual(emitted, retired + count);
        }
    }
}
