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
const Send = @import("send_drain").SendDrain(8);
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
    sender_role: bool = false,
    source_empty: bool = false,
    end_sent: bool = false,
    ack_seen: bool = false,

    fn begin(self: *Host) !u64 {
        const generation = try self.controller.begin();
        self.worker_joined = false;
        self.device_fenced = false;
        self.publication_closed = false;
        self.sender_role = false;
        self.source_empty = false;
        self.end_sent = false;
        self.ack_seen = false;
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
                        if (self.worker_alive) try expect(self.publication_closed or self.sender_role);
                    },
                    .send_ack => try expect(self.owned[2] and self.worker_alive and self.device_fenced and !self.callback_active and self.publication_closed),
                    .send_audio => try expect(self.sender_role and self.owned[2] and self.worker_alive and !self.end_sent),
                    .send_end => try expect(self.sender_role and self.owned[2] and self.worker_alive and self.device_fenced and !self.callback_active and self.source_empty),
                    .await_ack => try expect(self.sender_role and self.end_sent and self.worker_alive),
                    .close_transport => try expect(self.owned[2] and self.worker_alive and self.device_fenced and !self.callback_active and (if (self.sender_role) self.ack_seen else self.publication_closed)),
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
            .failed_rolled_back, .failure_no_change, .ack_copied, .transport_closed, .transport_failed, .write_copied, .write_rejected, .end_copied, .ack_received => {},
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
        .send_audio => .write_copied,
        .send_end => .end_copied,
        .await_ack => .ack_received,
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
            const got = try readMedia(&queue, copied, 1);
            // This deterministic scheduler publishes before the next read. Any
            // missing frame is a defect, not permission for an unbounded wait.
            try eq(@as(usize, 1), got);
            copied += got;
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
        try eq(@as(@TypeOf(outcome.ack), if (ack_copied) .copied else .unknown), outcome.ack);
        try eq(@as(@TypeOf(outcome.secure_close), if (ack_copied) .failed else .not_attempted), outcome.secure_close);
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

test "receiver late fence after deadline never enables ACK and keeps return debt" {
    var host: Host = .{};
    const g = try host.begin();
    try host.acquire(3);
    var queue: Drain.Queue = .{};
    var drain = try Drain.init(&host.controller, &queue, try readyGate(), 2);
    try drain.admit(g, end(0));
    // Silence-only callback still borrows native storage on an empty stream.
    host.callback_active = true;
    try drain.pollDrain(g);
    host.publication_closed = true;
    try eq(lc.Kind.fence_device, (try host.dispatch()).kind);
    host.controller.deadline(g);
    try host.noSecondDispatch();
    try expect(host.worker_alive and host.callback_active);
    host.callback_active = false;
    try host.finish(.fenced);
    try eq(lc.Kind.join_worker, (try host.dispatch()).kind);
    try host.finish(.joined);
    try host.clean();
    try eq(.interrupted, host.controller.snapshot().receive.?.local);
    try eq(.not_attempted, host.controller.snapshot().receive.?.ack);
}

test "receiver ACK and close reject foreign tokens and every illegal result atomically" {
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
    for ([_]lc.Kind{ .send_ack, .close_transport }) |kind| {
        const token = try host.dispatch();
        try eq(kind, token.kind);
        const before = host.controller.snapshot();
        var bad = token;
        bad.serial += 1;
        try std.testing.expectError(error.InvalidToken, host.controller.complete(bad, success(kind)));
        for (std.enums.values(lc.Result)) |result| {
            if (result != success(kind) and result != .transport_failed) {
                try std.testing.expectError(error.InvalidResult, host.controller.complete(token, result));
                try eq(before, host.controller.snapshot());
            }
        }
        if (kind == .send_ack) {
            try drain.completeAck(token, .ack_copied);
            host.dispatched = null;
        } else try host.finish(.transport_closed);
        const after = host.controller.snapshot();
        try std.testing.expectError(error.InvalidToken, host.controller.complete(token, success(kind)));
        try eq(after, host.controller.snapshot());
    }
    try host.clean();
}

test "receiver definitive fence failure escalates to abort and retry cannot restore graceful" {
    var host: Host = .{};
    const g = try host.begin();
    try host.acquire(3);
    var queue: Drain.Queue = .{};
    var drain = try Drain.init(&host.controller, &queue, try readyGate(), 2);
    try drain.admit(g, end(0));
    try drain.pollDrain(g);
    host.publication_closed = true;
    _ = try host.dispatch();
    try host.finish(.failure_no_change);
    try host.noSecondDispatch();
    try host.controller.retryCleanup(g);
    try host.clean();
    try eq(.interrupted, host.controller.snapshot().receive.?.local);
    try eq(.not_attempted, host.controller.snapshot().receive.?.ack);
}

fn senderGate(max_frames: u32) !core.Negotiation {
    var gate = core.Negotiation.init(.sender);
    try gate.authorizeChannel();
    var bytes: [64]u8 = undefined;
    const format: core.Format = .{ .max_frames = max_frames };
    try gate.apply(.outgoing, try wire.parse(try wire.encodeProfile(&bytes, .offer, stream, format)));
    try gate.apply(.incoming, try wire.parse(try wire.encodeProfile(&bytes, .accept, stream, format)));
    return gate;
}

fn capture(queue: *Send.Queue, first: usize, frames: usize) !void {
    var samples: [16]f32 = undefined;
    for (samples[0 .. frames * 2], 0..) |*value, i| value.* = @bitCast(sourceWord(first * 2 + i));
    try eq(frames, queue.write(samples[0 .. frames * 2]));
}

// Parse framing through the real codec, but expected sample words and position
// come from the independent source list, never from assembler/gate state.
fn checkRecord(bytes: []const u8, first: u64, frames: u32) !void {
    const message = try wire.parse(bytes);
    try eq(wire.Kind.audio, message.kind);
    try eq(first, message.position);
    try eq(frames, message.frames);
    for (0..@as(usize, frames) * 2) |i|
        try eq(sourceWord(@as(usize, @intCast(first)) * 2 + i), std.mem.readInt(u32, message.body[i * 4 ..][0..4], .little));
}

fn recordResult(host: *Host, sender: *Send, token: lc.Token, result: lc.Result) !void {
    try sender.completeRecord(token, result);
    host.dispatched = null;
    if (result == .end_copied) host.end_sent = true;
}

fn sourceFence(host: *Host) !void {
    try eq(lc.Kind.fence_device, (try host.dispatch()).kind);
    try host.finish(.fenced);
}

fn finishSender(host: *Host, sender: *Send, frontier: u64) !void {
    host.source_empty = true; // Caller has independently checked every source word.
    _ = try sender.pump(sender.generation);
    const token = try host.dispatch();
    try eq(lc.Kind.send_end, token.kind);
    const message = try wire.parse(try sender.prepareRecord(token));
    try eq(wire.Kind.end, message.kind);
    try eq(frontier, message.position);
    try recordResult(host, sender, token, .end_copied);
    const ack = try host.dispatch();
    try eq(lc.Kind.await_ack, ack.kind);
    try sender.completeAck(ack, .{ .kind = .ack, .stream = stream, .position = frontier, .frames = 0, .body = &.{} });
    host.dispatched = null;
    host.ack_seen = true;
    try eq(lc.Kind.close_transport, (try host.dispatch()).kind);
    try host.finish(.transport_closed);
    try host.clean();
    try eq(.transferred, host.controller.snapshot().send.?.local);
    try eq(.confirmed, host.controller.snapshot().send.?.remote);
    try eq(.clean, host.controller.snapshot().send.?.secure_close);
}

test "sender zero and partial EOF require actual source fence before END" {
    for ([_]u32{ 0, 1, 3, 7 }) |count| {
        var host: Host = .{};
        const g = try host.begin();
        try host.acquire(3);
        host.sender_role = true;
        var queue: Send.Queue = .{};
        var fault: std.atomic.Value(bool) = .init(false);
        var sender = try Send.init(&host.controller, &queue, &fault, try senderGate(4));
        try capture(&queue, 0, count);
        try sender.requestStop(g);
        const before = host.controller.snapshot();
        try sender.requestStop(g);
        try eq(before, host.controller.snapshot());
        host.callback_active = true;
        try eq(lc.Kind.fence_device, (try host.dispatch()).kind);
        try eq(@as(u32, 0), try sender.pump(g));
        try host.noSecondDispatch();
        host.callback_active = false;
        try host.finish(.fenced);
        var copied: u64 = 0;
        for (0..4) |_| {
            _ = try sender.pump(g);
            if (copied == count) break;
            const n: u32 = @intCast(@min(4, count - copied));
            const token = try host.dispatch();
            try eq(lc.Kind.send_audio, token.kind);
            try checkRecord(try sender.prepareRecord(token), copied, n);
            try recordResult(&host, &sender, token, .write_copied);
            copied += n;
        }
        try eq(@as(u64, count), copied);
        try finishSender(&host, &sender, count);
    }
}

test "sender rejection preserves bytes and commits once despite short transport progress" {
    var host: Host = .{};
    const g = try host.begin();
    try host.acquire(3);
    host.sender_role = true;
    var queue: Send.Queue = .{};
    var fault: std.atomic.Value(bool) = .init(false);
    var sender = try Send.init(&host.controller, &queue, &fault, try senderGate(3));
    try capture(&queue, 0, 7);
    try eq(@as(u32, 3), try sender.pump(g));
    const rejected = try host.dispatch();
    try checkRecord(try sender.prepareRecord(rejected), 0, 3);
    try recordResult(&host, &sender, rejected, .write_rejected);
    try eq(@as(u64, 0), sender.gate.next_frame);
    try eq(@as(u64, 0), sender.assembler.next_frame);
    const retry = try host.dispatch();
    try expect(retry.serial > rejected.serial);
    const bytes = try sender.prepareRecord(retry);
    var transport_copy: [wire.max_record]u8 = undefined;
    @memcpy(transport_copy[0..bytes.len], bytes);
    const length = bytes.len;
    try recordResult(&host, &sender, retry, .write_copied);
    try std.testing.expectError(error.InvalidToken, sender.completeRecord(retry, .write_copied));
    // The fake transport emits its own copy in small chunks. No new assembler
    // commit is tied to these byte-level sends; caller input may now be reused.
    var reconstructed: [wire.max_record]u8 = undefined;
    var offset: usize = 0;
    while (offset < length) {
        const n = @min(@as(usize, 7), length - offset);
        @memcpy(reconstructed[offset..][0..n], transport_copy[offset..][0..n]);
        offset += n;
    }
    try checkRecord(reconstructed[0..length], 0, 3);
    try sender.requestStop(g);
    try sourceFence(&host);
    _ = try sender.pump(g);
    var token = try host.dispatch();
    try checkRecord(try sender.prepareRecord(token), 3, 3);
    try recordResult(&host, &sender, token, .write_copied);
    _ = try sender.pump(g);
    token = try host.dispatch();
    try checkRecord(try sender.prepareRecord(token), 6, 1);
    try recordResult(&host, &sender, token, .write_copied);
    try finishSender(&host, &sender, 7);
}

test "sender stop during write retains result debt and late copied custody" {
    var host: Host = .{};
    const g = try host.begin();
    try host.acquire(3);
    host.sender_role = true;
    var queue: Send.Queue = .{};
    var fault: std.atomic.Value(bool) = .init(false);
    var sender = try Send.init(&host.controller, &queue, &fault, try senderGate(2));
    try capture(&queue, 0, 2);
    _ = try sender.pump(g);
    const token = try host.dispatch();
    try checkRecord(try sender.prepareRecord(token), 0, 2);
    try sender.requestStop(g);
    host.controller.deadline(g);
    try host.noSecondDispatch();
    try expect(host.worker_alive and host.owned[1]);
    try recordResult(&host, &sender, token, .write_copied);
    try eq(@as(u64, 2), sender.gate.next_frame);
    try host.clean();
    try eq(.interrupted, host.controller.snapshot().send.?.local);
    try eq(.not_attempted, host.controller.snapshot().send.?.end);
    try eq(.unknown, host.controller.snapshot().send.?.remote);
    const fresh = try host.begin();
    const before = host.controller.snapshot();
    try std.testing.expectError(error.StaleGeneration, sender.pump(g));
    try std.testing.expectError(error.InvalidToken, sender.completeRecord(token, .write_copied));
    try eq(before, host.controller.snapshot());
    try host.controller.requestStop(fresh);
    try host.clean();
}

test "sender uncertain write preserves exact local and uncertain frame partition" {
    var host: Host = .{};
    const g = try host.begin();
    try host.acquire(3);
    host.sender_role = true;
    var queue: Send.Queue = .{};
    var fault: std.atomic.Value(bool) = .init(false);
    var sender = try Send.init(&host.controller, &queue, &fault, try senderGate(3));
    try capture(&queue, 0, 5);
    _ = try sender.pump(g);
    const token = try host.dispatch();
    _ = try sender.prepareRecord(token);
    try recordResult(&host, &sender, token, .transport_failed);
    try std.testing.expectError(error.NotQuiescent, sender.accountAbort(g, 5));
    try eq(lc.Kind.join_worker, (try host.dispatch()).kind);
    try host.finish(.joined);
    try eq(lc.Kind.release, (try host.dispatch()).kind);
    try host.finish(.released);
    try sourceFence(&host);
    try std.testing.expectError(error.AccountingMismatch, sender.accountAbort(g, 4));
    const a = try sender.accountAbort(g, 5);
    try eq(@as(u64, 0), a.copied_to_transport);
    try eq(@as(u64, 3), a.uncertain_transfer);
    try eq(@as(u64, 2), a.discarded_local);
    try eq(a, try sender.accountAbort(g, 5));
    try host.clean();
}

test "sender sticky source fault prevents END before read after read or after copied write" {
    for (0..3) |stage| {
        var host: Host = .{};
        const g = try host.begin();
        try host.acquire(3);
        host.sender_role = true;
        var queue: Send.Queue = .{};
        var fault: std.atomic.Value(bool) = .init(false);
        var sender = try Send.init(&host.controller, &queue, &fault, try senderGate(2));
        try capture(&queue, 0, 2);
        if (stage == 0) {
            fault.store(true, .release);
            try std.testing.expectError(error.Discontinuity, sender.pump(g));
        } else {
            _ = try sender.pump(g);
            const token = try host.dispatch();
            if (stage == 1) {
                fault.store(true, .release);
                try std.testing.expectError(error.Discontinuity, sender.prepareRecord(token));
                try recordResult(&host, &sender, token, .write_rejected);
            } else {
                _ = try sender.prepareRecord(token);
                fault.store(true, .release);
                try recordResult(&host, &sender, token, .write_copied);
            }
        }
        try eq(lc.Cause.media_fault, host.controller.snapshot().first_cause.?);
        try eq(.not_attempted, host.controller.snapshot().send.?.end);
        try host.clean();
    }
}

test "sender nonfinite capture retains scratch and aborts without a record" {
    var host: Host = .{};
    const g = try host.begin();
    try host.acquire(3);
    host.sender_role = true;
    var queue: Send.Queue = .{};
    var fault: std.atomic.Value(bool) = .init(false);
    var sender = try Send.init(&host.controller, &queue, &fault, try senderGate(2));
    const words = [_]f32{ 0, @bitCast(@as(u32, 0x7fc00001)) };
    try eq(@as(usize, 1), queue.write(&words));
    try std.testing.expectError(error.InvalidSamples, sender.pump(g));
    try eq(@as(u32, 1), sender.scratch_frames);
    try eq(@as(u64, 0), sender.gate.next_frame);
    try eq(lc.Kind.join_worker, (try host.dispatch()).kind);
    try host.finish(.joined);
    _ = try host.dispatch();
    try host.finish(.released);
    try sourceFence(&host);
    const a = try sender.accountAbort(g, 1);
    try eq(@as(u64, 1), a.discarded_local);
    try host.clean();
}

test "sender wrong ACK fails without claiming remote confirmation" {
    for (0..3) |wrong| {
        var host: Host = .{};
        const g = try host.begin();
        try host.acquire(3);
        host.sender_role = true;
        var queue: Send.Queue = .{};
        var fault: std.atomic.Value(bool) = .init(false);
        var sender = try Send.init(&host.controller, &queue, &fault, try senderGate(2));
        try sender.requestStop(g);
        try sourceFence(&host);
        _ = try sender.pump(g);
        host.source_empty = true;
        const token = try host.dispatch();
        _ = try sender.prepareRecord(token);
        try recordResult(&host, &sender, token, .end_copied);
        const ack = try host.dispatch();
        var message: wire.Message = .{ .kind = .ack, .stream = stream, .position = 0, .frames = 0, .body = &.{} };
        switch (wrong) {
            0 => message.position = 1,
            1 => message.stream = @splat(8),
            else => message.kind = .end,
        }
        const expected = switch (wrong) {
            0 => error.Discontinuous,
            1 => error.WrongStream,
            else => error.InvalidState,
        };
        try std.testing.expectError(expected, sender.completeAck(ack, message));
        host.dispatched = null;
        try eq(.transferred, host.controller.snapshot().send.?.local);
        try eq(.unknown, host.controller.snapshot().send.?.remote);
        try host.clean();
    }
}
