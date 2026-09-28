//! Private, serialized receiver media owner. No native calls or callback work.
//! Adopts an already authorized/negotiated v2 receiver; keeps one copied block.
//! Controller and queue addresses stay fixed until resource cleanup completes.
const std = @import("std");
const core = @import("lan_audio");
const lc = @import("lifecycle");
const Pending = @import("pending_audio").PendingBlock;
const wire = core.wire_v2;

pub fn ReceiveDrain(comptime capacity: u32) type {
    return struct {
        const Self = @This();
        pub const Queue = core.FrameQueue(capacity, 2);
        pub const Error = Pending.Error || core.Negotiation.Error || error{ StaleGeneration, InvalidFrontier, InvalidToken, InvalidResult, InvalidPrefill, NotQuiescent, AccountingMismatch };
        controller: *lc.Controller,
        queue: *Queue,
        generation: u64,
        gate: core.Negotiation,
        pending: Pending,
        prefill: u32,
        start_taken: bool = false,
        abort_accounting: ?AbortAccounting = null,

        pub const AbortAccounting = struct { copied: u64, pending_discarded: u64, queued_discarded: u64 };

        /// Authentication/ACCEPT precede construction; this creates no identity
        /// defaults and acquires nothing. The producer begins at source frame 0.
        pub fn init(controller: *lc.Controller, queue: *Queue, gate: core.Negotiation, prefill: u32) Error!Self {
            if (prefill == 0 or prefill > capacity) return error.InvalidPrefill;
            if (controller.snapshot().phase != .ready or gate.role != .receiver or gate.phase != .streaming or gate.next_frame != 0 or queue.producerPending() != 0) return error.InvalidState;
            return .{ .controller = controller, .queue = queue, .generation = controller.snapshot().generation, .gate = gate, .pending = try Pending.init(gate.format), .prefill = prefill };
        }

        fn live(self: *const Self, generation: u64) Error!void {
            if (generation != self.generation or generation != self.controller.snapshot().generation) return error.StaleGeneration;
            const phase = self.controller.snapshot().phase;
            if (phase != .ready and phase != .draining) return error.InvalidState;
        }

        /// Busy is backpressure, without consuming a record. Every other wire
        /// rejection aborts the generation while preserving earlier custody.
        /// END may arrive while the last copied block still has a pending suffix.
        pub fn admit(self: *Self, generation: u64, message: wire.Message) Error!void {
            try self.live(generation);
            if (message.kind == .audio and self.gate.phase == .streaming and try self.pending.peek() != null) return error.Busy;
            errdefer self.controller.requestStop(generation) catch {};
            var candidate = self.gate;
            try candidate.apply(.incoming, message);
            switch (message.kind) {
                .audio => try self.pending.admit(message),
                .end => try self.controller.requestDrain(generation, candidate.next_frame),
                else => return error.InvalidState,
            }
            self.gate = candidate;
        }

        /// One bounded queue write; only the copied prefix advances PendingBlock.
        pub fn publish(self: *Self, generation: u64) Error!u32 {
            try self.live(generation);
            const block = (try self.pending.peek()) orelse return 0;
            const accepted: u32 = @intCast(self.queue.write(block.samples));
            try self.pending.advance(accepted);
            return accepted;
        }

        /// One start authorization. Adapter start failure must request abort.
        /// END permits a nonempty short tail below prefill; zero END never starts.
        pub fn takeStart(self: *Self, generation: u64) Error!bool {
            try self.live(generation);
            if (self.start_taken) return false;
            const queued = self.queue.producerPending();
            if (queued == 0 or (queued < self.prefill and self.gate.phase != .draining)) return false;
            self.start_taken = true;
            return true;
        }

        /// Close publication only after real pending/queue emptiness. Native
        /// fencing is a subsequent controller effect; this never authorizes ACK.
        pub fn pollDrain(self: *Self, generation: u64) Error!void {
            try self.live(generation);
            if (self.gate.phase != .draining or try self.pending.peek() != null or self.queue.producerPending() != 0) return;
            try self.controller.observeQueueDrained(generation, self.gate.next_frame);
        }

        /// Borrow-free fixed ACK descriptor only for the exact issued authority.
        pub fn ackMessage(self: *const Self, token: lc.Token) Error!wire.Message {
            const issued = self.controller.snapshot().pending orelse return error.InvalidToken;
            if (!std.meta.eql(token, issued) or token.generation != self.generation or token.kind != .send_ack) return error.InvalidToken;
            return .{ .kind = .ack, .stream = self.gate.stream, .position = self.gate.next_frame, .frames = 0, .body = &.{} };
        }

        /// Gate commits only after transport reports accepted copied write custody.
        /// A subsequent network failure still leaves remote observation unknown.
        pub fn completeAck(self: *Self, token: lc.Token, result: lc.Result) Error!void {
            const message = try self.ackMessage(token);
            if (result != .ack_copied and result != .transport_failed) return error.InvalidResult;
            var candidate = self.gate;
            if (result == .ack_copied) {
                try candidate.confirmDrained();
                try candidate.apply(.outgoing, message);
            }
            try self.controller.complete(token, result);
            if (result == .ack_copied) self.gate = candidate;
        }

        /// Only after joins/fences, BEFORE storage release, using a truthful final
        /// copied frontier. The allocator executor must retain this report before
        /// destroying the aggregate; this method never touches freed queue memory.
        /// Repeated calls preserve the original report. Queue bytes are retained;
        /// their classified custody is discarded, not consumed by a fake callback.
        pub fn accountAbort(self: *Self, generation: u64, copied: u64) Error!AbortAccounting {
            if (generation != self.generation or generation != self.controller.snapshot().generation) return error.StaleGeneration;
            const state = self.controller.snapshot();
            if (!state.held[0] or !state.worker_joined or !state.device_fenced or state.first_cause == null) return error.NotQuiescent;
            if (self.abort_accounting) |a| {
                if (a.copied != copied) return error.AccountingMismatch;
                return a;
            }
            const pending = if (try self.pending.peek()) |p| p.frames else 0;
            const queued = self.queue.producerPending();
            // Subtraction after ordered bounds avoids saturation and overflow.
            if (copied > self.gate.next_frame or queued > self.gate.next_frame - copied or pending != self.gate.next_frame - copied - queued) return error.AccountingMismatch;
            const a: AbortAccounting = .{ .copied = copied, .pending_discarded = pending, .queued_discarded = queued };
            _ = self.pending.abort();
            self.abort_accounting = a;
            return a;
        }
    };
}
