//! Real controller, independent fake host ownership. No sockets/native devices.
//! The fake's acquired/released arrays and callback/worker borrows are independent
//! of Controller.held: each issued effect must be safe BEFORE it is completed.
const std = @import("std");
const lc = @import("lifecycle");
const expect = std.testing.expect;
const eq = std.testing.expectEqual;
const core = @import("lan_audio");
const wire = core.wire_v2;
const Drain = @import("receive_drain").ReceiveDrain(2);
const stream: wire.StreamId = @splat(9);

fn readyGate() !core.Negotiation {
    var gate = core.Negotiation.init(.receiver);
    try gate.authorizeChannel(); // Explicit fixture attestation, not production policy.
    var bytes: [64]u8 = undefined;
    const format: core.Format = .{ .max_frames = 1024 };
    try gate.apply(.incoming, try wire.parse(try wire.encodeProfile(&bytes, .offer, stream, format)));
    try gate.apply(.outgoing, try wire.parse(try wire.encodeProfile(&bytes, .accept, stream, format)));
    return gate;
}

// Independent finite binary32 identities; never derive expectation from gate or
// queue indices, and never send these synthetic words to a physical device.
fn sourceWord(sample: usize) u32 {
    return @as(u32, @intCast(sample + 1)) | (if (sample % 2 == 0) @as(u32, 0x80000000) else 0);
}

fn media(body: []u8, first: u64, frames: u32) wire.Message {
    for (0..@as(usize, frames) * 2) |i| std.mem.writeInt(u32, body[i * 4 ..][0..4], sourceWord(@as(usize, @intCast(first)) * 2 + i), .little);
    return .{ .kind = .audio, .stream = stream, .position = first, .frames = frames, .body = body[0 .. @as(usize, frames) * 8] };
}

fn end(frontier: u64) wire.Message {
    return .{ .kind = .end, .stream = stream, .position = frontier, .frames = 0, .body = &.{} };
}

fn readMedia(queue: *Drain.Queue, first: usize, requested: usize) !usize {
    var output: [4]f32 = undefined;
    const got = queue.read(output[0 .. requested * 2]);
    for (output[0 .. got * 2], 0..) |sample, i| try eq(sourceWord(first * 2 + i), @as(u32, @bitCast(sample)));
    return got;
}

fn finishAck(host: *Host, drain: *Drain, result: lc.Result) !void {
    const token = try host.dispatch();
    try eq(lc.Kind.send_ack, token.kind);
    const message = try drain.ackMessage(token);
    try eq(wire.Kind.ack, message.kind);
    try eq(drain.gate.next_frame, message.position);
    try drain.completeAck(token, result);
    host.dispatched = null;
}

const Host = struct {
    controller: lc.Controller = .{},
    owned: [3]bool = .{ false, false, false },
    acquired: [3]u32 = .{ 0, 0, 0 },
    released: [3]u32 = .{ 0, 0, 0 },
    dispatched: ?lc.Token = null,
    callback_active: bool = false,
    callback_admission: bool = false,
    worker_alive: bool = false,
    worker_joined: bool = false,
    device_fenced: bool = false,
    publication_closed: bool = false,

    fn begin(self: *Host) !u64 {
        const generation = try self.controller.begin();
        self.worker_joined = false;
        self.device_fenced = false;
        return generation;
    }

    fn dispatch(self: *Host) !lc.Token {
        try expect(self.dispatched == null);
        for ([_]lc.Executor{ .allocator, .native, .joiner, .transport }) |executor| {
            if (try self.controller.takeEffect(executor)) |token| {
                const r = @backingInt(token.resource);
                switch (token.kind) {
                    .acquire => {
                        try expect(!self.owned[r]);
                        for (self.owned[0..r]) |parent| try expect(parent);
                    },
                    .join_worker => try expect(self.owned[2]),
                    .fence_device => {
                        try expect(self.owned[1]);
                        if (self.worker_alive) try expect(self.publication_closed);
                    },
                    .send_ack, .close_transport => try expect(self.owned[2] and self.worker_alive and self.device_fenced and !self.callback_active and self.publication_closed),
                    .release => {
                        try expect(self.owned[r]);
                        for (self.owned[r + 1 ..]) |child| try expect(!child);
                        if (r == 2) try expect(!self.worker_alive and self.worker_joined);
                        if (r == 1) try expect(!self.callback_active and !self.callback_admission and self.device_fenced);
                    },
                }
                self.dispatched = token;
                try self.noSecondDispatch();
                return token;
            }
        }
        return error.ExpectedEffect;
    }

    fn noSecondDispatch(self: *Host) !void {
        for ([_]lc.Executor{ .allocator, .native, .joiner, .transport }) |executor|
            try eq(@as(?lc.Token, null), try self.controller.takeEffect(executor));
    }

    fn finish(self: *Host, result: lc.Result) !void {
        const token = self.dispatched orelse return error.NoFakeOperation;
        const r = @backingInt(token.resource);
        // Environment facts are established independently before attestation.
        switch (result) {
            .acquired, .partial_owned => {
                try expect(!self.owned[r]);
                self.owned[r] = true;
                self.acquired[r] += 1;
                if (r == 1) self.callback_admission = true;
                if (r == 2) self.worker_alive = true;
            },
            .joined => {
                self.worker_alive = false;
                self.worker_joined = true;
            },
            .fenced => {
                try expect(!self.callback_active);
                self.callback_admission = false;
                self.device_fenced = true;
            },
            .released => {
                try expect(self.owned[r]);
                self.owned[r] = false;
                self.released[r] += 1;
            },
            .failed_rolled_back, .failure_no_change, .ack_copied, .transport_closed, .transport_failed => {},
        }
        try self.controller.complete(token, result);
        self.dispatched = null;
        try eq(self.owned, self.controller.snapshot().held);
    }

    fn acquire(self: *Host, count: usize) !void {
        for (0..count) |_| {
            const token = try self.dispatch();
            try eq(lc.Kind.acquire, token.kind);
            try self.finish(.acquired);
        }
    }

    fn clean(self: *Host) !void {
        // At most join + worker free + fence + device free + storage free.
        for (0..6) |_| {
            if (self.controller.snapshot().phase == .stopped) {
                try expect(self.dispatched == null and !self.callback_active and !self.worker_alive);
                try eq(self.acquired, self.released);
                try eq([3]bool{ false, false, false }, self.owned);
                return;
            }
            const token = try self.dispatch();
            try self.finish(success(token.kind));
        }
        return error.CleanupDidNotConverge;
    }
};

fn success(kind: lc.Kind) lc.Result {
    return switch (kind) {
        .acquire => .acquired,
        .join_worker => .joined,
        .fence_device => .fenced,
        .release => .released,
        .send_ack => .ack_copied,
        .close_transport => .transport_closed,
    };
}

test "cancel before each dispatch reclaims exactly the acquired prefix" {
    for (0..4) |prefix| {
        var host: Host = .{};
        const generation = try host.begin();
        try host.acquire(prefix);
        try host.controller.requestStop(generation);
        const stopped_intent = host.controller.snapshot();
        try host.controller.requestStop(generation);
        try eq(stopped_intent, host.controller.snapshot());
        try host.clean();
    }
}

test "cancel during every acquisition retains parents for late success failure and partial debt" {
    for (0..3) |prefix| {
        for ([_]lc.Result{ .acquired, .failed_rolled_back, .partial_owned }) |result| {
            var host: Host = .{};
            const generation = try host.begin();
            try host.acquire(prefix);
            _ = try host.dispatch();
            try host.controller.requestStop(generation);
            try host.noSecondDispatch();
            try std.testing.expectError(error.Busy, host.controller.begin());
            try host.finish(result);
            try host.clean();
        }
    }
}

test "each rolled back failure and partial acquisition independently initiates cleanup" {
    for (0..3) |prefix| {
        for ([_]lc.Result{ .failed_rolled_back, .partial_owned }) |result| {
            var host: Host = .{};
            _ = try host.begin();
            try host.acquire(prefix);
            _ = try host.dispatch();
            try host.finish(result);
            try eq(if (result == .partial_owned) lc.Cause.partial_acquisition else lc.Cause.acquisition_failed, host.controller.snapshot().first_cause.?);
            try host.clean();
        }
    }
}

test "pending worker acquisition reserves device and storage across cancel and deadline" {
    var host: Host = .{};
    const generation = try host.begin();
    try host.acquire(2);
    const worker = try host.dispatch();
    try eq(lc.Resource.worker, worker.resource);
    try host.controller.requestStop(generation);
    host.controller.deadline(generation);
    for (0..100) |_| try host.noSecondDispatch();
    try eq([3]bool{ true, true, false }, host.owned);
    try eq(lc.Phase.unresponsive, host.controller.snapshot().phase);
    try std.testing.expectError(error.NotBlocked, host.controller.retryCleanup(generation));
    try host.finish(.acquired);
    try host.clean();
    try expect(host.controller.snapshot().deadline_expired);
}

test "callback may enter after stop and fence cannot return while callback is paused" {
    var host: Host = .{};
    const generation = try host.begin();
    try host.acquire(2);
    try host.controller.requestStop(generation);
    try expect(host.callback_admission);
    host.callback_active = true; // Independent fake callback borrow, even after stop.
    const fence = try host.dispatch();
    try eq(lc.Kind.fence_device, fence.kind);
    // Native operation now seals admission, but still owes the paused return.
    host.callback_admission = false;
    host.controller.deadline(generation);
    try host.noSecondDispatch();
    try eq([3]bool{ true, true, false }, host.owned);
    try std.testing.expectError(error.Busy, host.controller.begin());
    host.callback_active = false;
    try host.finish(.fenced);
    try host.clean();
}

test "every token field and contradictory result is rejected atomically" {
    var host: Host = .{};
    _ = try host.begin();
    const token = try host.dispatch();
    const before = host.controller.snapshot();
    var foreign = [_]lc.Token{ token, token, token, token, token };
    foreign[0].generation += 1;
    foreign[1].serial += 1;
    foreign[2].executor = .native;
    foreign[3].kind = .release;
    foreign[4].resource = .device;
    for (foreign) |bad| {
        try std.testing.expectError(error.InvalidToken, host.controller.complete(bad, .acquired));
        try eq(before, host.controller.snapshot());
    }
    try std.testing.expectError(error.InvalidResult, host.controller.complete(token, .released));
    try eq(before, host.controller.snapshot());
    try host.finish(.acquired);
    const settled = host.controller.snapshot();
    try std.testing.expectError(error.InvalidToken, host.controller.complete(token, .acquired));
    try eq(settled, host.controller.snapshot());
    try host.controller.requestStop(token.generation);
    try host.clean();
}

test "each cleanup failure preserves ownership and requires explicit retry with new identity" {
    for (0..5) |failed_step| {
        var host: Host = .{};
        const generation = try host.begin();
        try host.acquire(3);
        try host.controller.requestStop(generation);
        for (0..failed_step) |_| {
            const token = try host.dispatch();
            try host.finish(success(token.kind));
        }
        const failed = try host.dispatch();
        const owners = host.owned;
        try host.finish(.failure_no_change);
        try eq(owners, host.owned);
        try eq(lc.Phase.unresponsive, host.controller.snapshot().phase);
        try host.noSecondDispatch();
        try host.controller.requestStop(generation);
        try host.noSecondDispatch();
        try host.controller.retryCleanup(generation);
        const retry = try host.dispatch();
        try eq(failed.kind, retry.kind);
        try eq(failed.resource, retry.resource);
        try expect(retry.serial > failed.serial);
        const before = host.controller.snapshot();
        try std.testing.expectError(error.InvalidToken, host.controller.complete(failed, success(failed.kind)));
        try eq(before, host.controller.snapshot());
        try host.finish(success(retry.kind));
        try host.clean();
    }
}

test "old generation stop deadline and completion cannot affect restarted owner" {
    var host: Host = .{};
    const old = try host.begin();
    const old_token = try host.dispatch();
    try host.finish(.acquired);
    try host.controller.requestStop(old);
    try host.clean();
    const fresh = try host.begin();
    try expect(fresh > old);
    _ = try host.dispatch();
    const before = host.controller.snapshot();
    try std.testing.expectError(error.StaleGeneration, host.controller.requestStop(old));
    try std.testing.expectError(error.StaleGeneration, host.controller.retryCleanup(old));
    try std.testing.expectError(error.InvalidToken, host.controller.complete(old_token, .acquired));
    host.controller.deadline(old);
    try eq(before, host.controller.snapshot());
    try host.finish(.acquired);
    try host.controller.requestStop(fresh);
    try host.clean();
}

test "namespace exhaustion never wraps and does not forget an acquired owner" {
    var controller: lc.Controller = .{ .generation = std.math.maxInt(u64) };
    const empty = controller.snapshot();
    try std.testing.expectError(error.GenerationExhausted, controller.begin());
    try eq(empty, controller.snapshot());
    var host: Host = .{};
    const generation = try host.begin();
    try host.acquire(1);
    // Test-only boundary injection; production callers may not mutate fields.
    host.controller.serial = std.math.maxInt(u64);
    try host.controller.requestStop(generation);
    const debt = host.controller.snapshot();
    try std.testing.expectError(error.SerialExhausted, host.controller.takeEffect(.allocator));
    try eq(debt, host.controller.snapshot());
    try expect(host.owned[0]);
    try std.testing.expectError(error.Busy, host.controller.begin());
}

test "wrong executor observes no dispatch and deadline cannot change terminal outcome" {
    var host: Host = .{};
    const generation = try host.begin();
    const before = host.controller.snapshot();
    try eq(@as(?lc.Token, null), try host.controller.takeEffect(.native));
    try eq(before, host.controller.snapshot());
    try host.controller.requestStop(generation);
    const after = host.controller.snapshot();
    host.controller.deadline(generation);
    try host.controller.requestStop(generation);
    try eq(after, host.controller.snapshot());
    try host.clean();
}

test "result matrix rejects every inappropriate tag without settling an issued effect" {
    var host: Host = .{};
    const generation = try host.begin();
    for (0..8) |step| {
        if (step == 3) try host.controller.requestStop(generation);
        const token = try host.dispatch();
        const before = host.controller.snapshot();
        for (std.enums.values(lc.Result)) |result| {
            const legal = if (token.kind == .acquire)
                result == .acquired or result == .failed_rolled_back or result == .partial_owned
            else
                result == success(token.kind) or result == .failure_no_change;
            if (!legal) {
                try std.testing.expectError(error.InvalidResult, host.controller.complete(token, result));
                try eq(before, host.controller.snapshot());
            }
        }
        try host.finish(success(token.kind));
    }
    try host.clean();
}

test "receiver zero END fences without starting and separates ACK close and cleanup" {
    var host: Host = .{};
    const g = try host.begin();
    try host.acquire(3);
    var queue: Drain.Queue = .{};
    var drain = try Drain.init(&host.controller, &queue, try readyGate(), 2);
    try drain.admit(g, end(0));
    try expect(!try drain.takeStart(g));
    try drain.pollDrain(g);
    host.publication_closed = true; // Oracle knows no source frames were admitted.
    const fence = try host.dispatch();
    try eq(lc.Kind.fence_device, fence.kind);
    try std.testing.expectError(error.InvalidToken, drain.ackMessage(fence));
    try host.finish(.fenced);
    try expect(host.worker_alive);
    try finishAck(&host, &drain, .ack_copied);
    try eq(core.Negotiation.Phase.complete, drain.gate.phase);
    try eq(.unobserved, host.controller.snapshot().receive.?.remote);
    try eq(.not_attempted, host.controller.snapshot().receive.?.secure_close);
    try eq(lc.Kind.close_transport, (try host.dispatch()).kind);
    try host.finish(.transport_closed);
    try eq(lc.Phase.reclaiming, host.controller.snapshot().phase);
    try host.clean();
    try eq(.drained, host.controller.snapshot().receive.?.local);
    try eq(.clean, host.controller.snapshot().receive.?.secure_close);
}

test "receiver short tail and maximum block preserve identities with zero writes and paused return" {
    for ([_]u32{ 1, 3, 1024 }) |count| {
        var host: Host = .{};
        const g = try host.begin();
        try host.acquire(3);
        var queue: Drain.Queue = .{};
        var drain = try Drain.init(&host.controller, &queue, try readyGate(), 2);
        var body: [8192]u8 = undefined;
        try drain.admit(g, media(&body, 0, count));
        _ = try drain.publish(g);
        if (count == 1) try expect(!try drain.takeStart(g));
        try drain.admit(g, end(count)); // END overtakes only local pending custody.
        const intent = host.controller.snapshot();
        try host.controller.requestDrain(g, count);
        try eq(intent, host.controller.snapshot());
        try expect(try drain.takeStart(g));
        try expect(!try drain.takeStart(g));
        if (count > 2) try eq(@as(u32, 0), try drain.publish(g));
        try drain.pollDrain(g);
        try host.noSecondDispatch();
        var copied: usize = 0;
        while (copied < count) {
            host.callback_active = true;
            copied += try readMedia(&queue, copied, 1);
            if (copied < count) host.callback_active = false;
            _ = try drain.publish(g);
        }
        try eq(@as(usize, count), copied);
        try eq(@as(u32, 0), queue.producerPending());
        // The last callback has released slots but still owns its output buffer.
        try drain.pollDrain(g);
        host.publication_closed = true;
        const fence = try host.dispatch();
        try eq(lc.Kind.fence_device, fence.kind);
        host.callback_admission = false;
        try host.noSecondDispatch();
        try eq(.pending, host.controller.snapshot().receive.?.local);
        try std.testing.expectError(error.InvalidToken, drain.ackMessage(fence));
        try std.testing.expectError(error.Busy, host.controller.begin());
        host.callback_active = false;
        try host.finish(.fenced);
        try finishAck(&host, &drain, .ack_copied);
        try eq(lc.Kind.close_transport, (try host.dispatch()).kind);
        try host.finish(.transport_closed);
        try host.clean();
    }
}

test "receiver ACK failure preserves local drain without claiming remote or secure completion" {
    for ([_]bool{ false, true }) |ack_copied| {
        var host: Host = .{};
        const g = try host.begin();
        try host.acquire(3);
        var queue: Drain.Queue = .{};
        var drain = try Drain.init(&host.controller, &queue, try readyGate(), 2);
        try drain.admit(g, end(0));
        try drain.pollDrain(g);
        host.publication_closed = true;
        _ = try host.dispatch();
        try host.finish(.fenced);
        try finishAck(&host, &drain, if (ack_copied) .ack_copied else .transport_failed);
        if (ack_copied) {
            try eq(lc.Kind.close_transport, (try host.dispatch()).kind);
            try host.finish(.transport_failed);
        }
        try host.clean();
        const outcome = host.controller.snapshot().receive.?;
        try eq(.drained, outcome.local);
        try eq(.unobserved, outcome.remote);
        try eq(if (ack_copied) .copied else .unknown, outcome.ack);
        try eq(if (ack_copied) .failed else .not_attempted, outcome.secure_close);
    }
}

test "receiver abort full queue counts retained frames only after quiescence and before free" {
    for ([_]bool{ false, true }) |timeout| {
        var host: Host = .{};
        const g = try host.begin();
        try host.acquire(3);
        var queue: Drain.Queue = .{};
        var drain = try Drain.init(&host.controller, &queue, try readyGate(), 2);
        var body: [40]u8 = undefined;
        try drain.admit(g, media(&body, 0, 5));
        try eq(@as(u32, 2), try drain.publish(g));
        try drain.admit(g, end(5));
        if (timeout) host.controller.deadline(g) else try host.controller.requestStop(g);
        try std.testing.expectError(error.InvalidState, host.controller.requestDrain(g, 5));
        try std.testing.expectError(error.NotQuiescent, drain.accountAbort(g, 0));
        try eq(lc.Kind.join_worker, (try host.dispatch()).kind);
        // Joiner cancels/wakes the fake blocked transport owner. No consumer drain.
        try host.finish(.joined);
        try eq(lc.Kind.release, (try host.dispatch()).kind);
        try host.finish(.released);
        try eq(lc.Kind.fence_device, (try host.dispatch()).kind);
        try host.finish(.fenced);
        try std.testing.expectError(error.AccountingMismatch, drain.accountAbort(g, 1));
        const accounting = try drain.accountAbort(g, 0);
        try eq(@as(u64, 3), accounting.pending_discarded);
        try eq(@as(u64, 2), accounting.queued_discarded);
        try eq(accounting, try drain.accountAbort(g, 0));
        try host.clean();
        try eq(.interrupted, host.controller.snapshot().receive.?.local);
        try eq(.not_attempted, host.controller.snapshot().receive.?.ack);
    }
}

test "receiver deadline during issued ACK retains worker and reconciles late copied custody" {
    var host: Host = .{};
    const g = try host.begin();
    try host.acquire(3);
    var queue: Drain.Queue = .{};
    var drain = try Drain.init(&host.controller, &queue, try readyGate(), 2);
    try drain.admit(g, end(0));
    try drain.pollDrain(g);
    host.publication_closed = true;
    _ = try host.dispatch();
    try host.finish(.fenced);
    const ack = try host.dispatch();
    try eq(lc.Kind.send_ack, ack.kind);
    host.controller.deadline(g);
    try host.noSecondDispatch();
    try expect(host.worker_alive and host.owned[2]);
    try std.testing.expectError(error.Busy, host.controller.begin());
    try drain.completeAck(ack, .ack_copied);
    host.dispatched = null;
    try host.clean();
    try expect(host.controller.snapshot().deadline_expired);
    try eq(.copied, host.controller.snapshot().receive.?.ack);
    try eq(.not_attempted, host.controller.snapshot().receive.?.secure_close);
    const fresh = try host.begin();
    const before = host.controller.snapshot();
    try std.testing.expectError(error.StaleGeneration, drain.pollDrain(g));
    try std.testing.expectError(error.InvalidToken, drain.completeAck(ack, .ack_copied));
    try eq(before, host.controller.snapshot());
    try host.controller.requestStop(fresh);
    try host.clean();
}

test "receiver wire rejection preserves prior custody and never authorizes ACK" {
    var host: Host = .{};
    const g = try host.begin();
    try host.acquire(3);
    var queue: Drain.Queue = .{};
    var drain = try Drain.init(&host.controller, &queue, try readyGate(), 2);
    var body: [24]u8 = undefined;
    try drain.admit(g, media(&body, 0, 3));
    try std.testing.expectError(error.Busy, drain.admit(g, media(&body, 3, 1)));
    try eq(@as(u64, 3), drain.gate.next_frame);
    try std.testing.expectError(error.Discontinuous, drain.admit(g, end(4)));
    try eq(lc.Phase.aborting, host.controller.snapshot().phase);
    try eq(@as(u32, 3), (try drain.pending.peek()).?.frames);
    try host.clean();
}
