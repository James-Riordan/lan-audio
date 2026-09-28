//! Bounded, serialized capture-to-record custody using the real lifecycle owner.
//! No native/network calls. Device, queue, fault flag and controller stay fixed.
const std = @import("std");
const core = @import("lan_audio");
const lc = @import("lifecycle");
const wire = core.wire_v2;

pub fn SendDrain(comptime capacity: u32) type {
    return struct {
        const Self = @This();
        pub const Queue = core.FrameQueue(capacity, 2);
        pub const Accounting = struct { copied_to_transport: u64, uncertain_transfer: u64, discarded_local: u64 };
        controller: *lc.Controller,
        queue: *Queue,
        source_fault: *const std.atomic.Value(bool),
        generation: u64,
        gate: core.Negotiation,
        assembler: core.BlockAssembler,
        scratch: [wire.max_samples]f32 = undefined,
        scratch_frames: u32 = 0,
        record: [wire.max_record]u8 = undefined,
        record_length: usize = 0,
        prepared: ?lc.Token = null,
        candidate: ?core.Negotiation = null,
        uncertain_frames: u32 = 0,
        accounting: ?Accounting = null,

        pub fn init(controller: *lc.Controller, queue: *Queue, fault: *const std.atomic.Value(bool), gate: core.Negotiation) !Self {
            if (gate.role != .sender or gate.phase != .streaming or gate.next_frame != 0) return error.InvalidState;
            const assembler = try core.BlockAssembler.init(gate.format);
            const generation = controller.snapshot().generation;
            try controller.configureSender(generation);
            return .{ .controller = controller, .queue = queue, .source_fault = fault, .generation = generation, .gate = gate, .assembler = assembler };
        }

        fn live(self: *const Self, generation: u64) !void {
            if (generation != self.generation or generation != self.controller.snapshot().generation) return error.StaleGeneration;
            const state = self.controller.snapshot();
            if (state.phase != .ready and state.phase != .draining) return error.InvalidState;
        }

        fn healthy(self: *Self) !void {
            if (self.source_fault.load(.acquire)) {
                try self.controller.mediaFault(self.generation);
                return error.Discontinuity;
            }
        }

        pub fn requestStop(self: *Self, generation: u64) !void {
            try self.live(generation);
            try self.healthy();
            try self.controller.requestSendDrain(generation);
        }

        /// At most one capture read; never read beyond assembler free capacity.
        /// A failed sample validation retains the read scratch for accounting.
        /// No EOF until actual native fence AND consumer-observed empty queue.
        pub fn pump(self: *Self, generation: u64) !u32 {
            try self.live(generation);
            try self.healthy();
            const state = self.controller.snapshot();
            if (state.pending != null or state.send.?.offered_frames != 0) return 0;
            errdefer self.controller.mediaFault(generation) catch {};
            const space = self.assembler.format.max_frames - self.assembler.pending_frames;
            var got: u32 = 0;
            if (!self.assembler.sealed and space > 0) {
                got = @intCast(self.queue.read(self.scratch[0 .. @as(usize, space) * 2]));
                self.scratch_frames = got;
                try self.healthy(); // Catch sticky loss published during the read.
                const accepted = try self.assembler.push(self.scratch[0 .. @as(usize, got) * 2]);
                std.debug.assert(accepted == got);
                self.scratch_frames = 0;
            }
            if (state.device_fenced and self.queue.consumerAvailable() == 0) try self.assembler.finish();
            if (try self.assembler.peek()) |block| {
                try self.controller.offerAudio(generation, block.frames);
            } else if (self.assembler.sealed) {
                try self.controller.observeSourceDrained(generation, try self.assembler.endPosition());
            }
            return got;
        }

        fn issued(self: *const Self, token: lc.Token) !void {
            const pending = self.controller.snapshot().pending orelse return error.InvalidToken;
            if (token.generation != self.generation or !std.meta.eql(pending, token)) return error.InvalidToken;
        }

        /// Bounded immutable record borrow until completeRecord. Caller submits
        /// exactly once; short network sends operate on the transport's own copy.
        /// If this fails after dispatch, settle known-not-submitted AUDIO as
        /// write_rejected; END settles transport_failed. Never erase the token.
        pub fn prepareRecord(self: *Self, token: lc.Token) ![]const u8 {
            try self.issued(token);
            if (token.kind != .send_audio and token.kind != .send_end) return error.InvalidToken;
            try self.live(token.generation);
            try self.healthy();
            if (self.prepared) |previous| {
                if (!std.meta.eql(previous, token)) return error.InvalidToken;
                return self.record[0..self.record_length];
            }
            const encoded = if (token.kind == .send_audio) blk: {
                const block = (try self.assembler.peek()) orelse return error.NotReady;
                break :blk try wire.encodeAudio(&self.record, self.gate.stream, block.first_frame, block.samples, self.gate.format);
            } else try wire.encodeControl(&self.record, .end, self.gate.stream, try self.assembler.endPosition());
            var candidate = self.gate;
            try candidate.apply(.outgoing, try wire.parse(encoded));
            self.record_length = encoded.len;
            self.candidate = candidate;
            self.prepared = token;
            return encoded;
        }

        /// Copied acceptance commits gate/assembler exactly once, even if stop
        /// raced a dispatched operation. Known no-copy rejection preserves both.
        /// Unknown write failure quarantines its frame range without replay.
        pub fn completeRecord(self: *Self, token: lc.Token, result: lc.Result) !void {
            try self.issued(token);
            if (token.kind != .send_audio and token.kind != .send_end) return error.InvalidToken;
            const copied = result == .write_copied or result == .end_copied;
            if (copied and (self.prepared == null or !std.meta.eql(self.prepared.?, token))) return error.InvalidState;
            // Validate result before any media change; controller does not call out.
            try self.controller.complete(token, result);
            if (copied) {
                if (token.kind == .send_audio) try self.assembler.commit();
                self.gate = self.candidate.?;
            } else if (result == .transport_failed and token.kind == .send_audio) {
                self.uncertain_frames = 0;
            }
            self.prepared = null;
            self.candidate = null;
            // Publication after a simultaneous source fault may already have
            // happened; retain that fact but never permit successful END/ACK.
            if (self.source_fault.load(.acquire)) try self.controller.mediaFault(self.generation);
        }

        /// Only a validated exact stream/frontier ACK supplies remote attestation.
        /// Protocol rejection settles the outstanding read as failure and aborts.
        pub fn completeAck(self: *Self, token: lc.Token, message: wire.Message) !void {
            try self.issued(token);
            if (token.kind != .await_ack) return error.InvalidToken;
            var candidate = self.gate;
            candidate.apply(.incoming, message) catch |err| {
                try self.controller.complete(token, .transport_failed);
                return err;
            };
            try self.controller.complete(token, .ack_received);
            self.gate = candidate;
        }

        /// Final accepted capture count comes from a qualified post-fence native
        /// snapshot. Read before aggregate storage release; counter saturation is
        /// not an exact count and must be rejected by the adapter.
        pub fn accountAbort(self: *Self, generation: u64, captured: u64) !Accounting {
            if (generation != self.generation or generation != self.controller.snapshot().generation) return error.StaleGeneration;
            const state = self.controller.snapshot();
            if (!state.held[0] or !state.worker_joined or !state.device_fenced or state.first_cause == null) return error.NotQuiescent;
            const copied = self.assembler.next_frame;
            const retained = @as(u64, self.assembler.pending_frames) + self.scratch_frames + self.queue.consumerAvailable();
            if (copied > captured or retained != captured - copied or self.uncertain_frames > self.assembler.pending_frames) return error.AccountingMismatch;
            const a: Accounting = .{ .copied_to_transport = copied, .uncertain_transfer = self.uncertain_frames, .discarded_local = retained - self.uncertain_frames };
            if (self.accounting) |previous| {
                if (!std.meta.eql(previous, a)) return error.AccountingMismatch;
                return previous;
            }
            self.accounting = a;
            return a;
        }
    };
}
