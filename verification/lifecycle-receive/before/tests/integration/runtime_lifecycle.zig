//! Real controller, independent fake host ownership. No sockets/native devices.
//! The fake's acquired/released arrays and callback/worker borrows are independent
//! of Controller.held: each issued effect must be safe BEFORE it is completed.
const std = @import("std");
const lc = @import("lifecycle");
const expect = std.testing.expect;
const eq = std.testing.expectEqual;

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

    fn begin(self: *Host) !u64 {
        const generation = try self.controller.begin();
        self.worker_joined = false;
        self.device_fenced = false;
        return generation;
    }

    fn dispatch(self: *Host) !lc.Token {
        try expect(self.dispatched == null);
        for ([_]lc.Executor{ .allocator, .native, .joiner }) |executor| {
            if (try self.controller.takeEffect(executor)) |token| {
                const r = @backingInt(token.resource);
                switch (token.kind) {
                    .acquire => {
                        try expect(!self.owned[r]);
                        for (self.owned[0..r]) |parent| try expect(parent);
                    },
                    .join_worker => try expect(self.owned[2]),
                    .fence_device => try expect(self.owned[1] and !self.owned[2] and !self.worker_alive),
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
        for ([_]lc.Executor{ .allocator, .native, .joiner }) |executor|
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
            .failed_rolled_back, .failure_no_change => {},
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
