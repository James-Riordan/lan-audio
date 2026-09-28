//! One media worker: authenticated records -> copied pending block -> callback FIFO.
const Receiver = @import("receive_drain").ReceiveDrain(@import("audio_host").Bridge.Queue.frame_capacity);
const wire = @import("lan_audio").wire_v2;
const net = @import("network_host");

pub fn run(state: anytype) !void {
    var receiver = try Receiver.init(state.controller, &state.audio.bridge.playback, &state.audio.bridge.playback_failed, state.connection.?.channel.gate, state.options.prefill_frames);
    var ack: [wire.header_size]u8 = undefined;
    var draining_deadline: ?u64 = null;
    while (true) {
        try state.healthy();
        if (receiver.gate.phase == .streaming and try receiver.pending.peek() == null) {
            const started = try net.nowMilliseconds();
            const message = try state.connection.?.receive(state.generation, 1, try state.deadline());
            try state.delivery_timing.received(started, try net.nowMilliseconds());
            try receiver.admit(state.generation, message);
            state.frames = receiver.gate.next_frame;
            if (receiver.gate.phase == .draining) {
                state.audio.bridge.playback_guard.store(false, .release);
                draining_deadline = try state.deadline();
            }
        }
        const publication_deadline = draining_deadline orelse try state.deadline();
        if (state.options.recover_playback and receiver.gate.phase == .streaming and
            state.audio.bridge.playback.producerPending() > state.options.max_queue_frames)
            return error.PlaybackBacklog;
        while (try receiver.pending.peek() != null) {
            try state.healthy();
            if (try net.nowMilliseconds() >= publication_deadline) return error.PlaybackStalled;
            const copied = try receiver.publish(state.generation);
            if (copied != 0) {
                try state.delivery_timing.published(try net.nowMilliseconds(), copied);
                const queued = state.audio.bridge.playback.producerPending();
                try state.delivery_timing.observePlayback(queued, try net.nowMilliseconds());
            }
            if (try receiver.takeStart(state.generation)) {
                if (state.options.recover_playback and receiver.gate.phase == .streaming)
                    state.audio.bridge.playback_guard.store(true, .release);
                state.active_since = try net.nowMilliseconds();
                try state.delivery_timing.beginPlayback(state.active_since.?);
                state.audio.bridge.playback_ready.store(true, .release);
                @import("std").debug.print("Playback started: 48 kHz stereo.\n", .{});
            }
            if (copied == 0) try state.pacer.wait(1);
        }
        // END releases short-stream prefill; an empty stream remains gated silent.
        if (try receiver.takeStart(state.generation)) {
            state.active_since = try net.nowMilliseconds();
            try state.delivery_timing.beginPlayback(state.active_since.?);
            state.audio.bridge.playback_ready.store(true, .release);
            @import("std").debug.print("Playback started: 48 kHz stereo.\n", .{});
        }
        if (receiver.gate.phase != .draining and receiver.gate.phase != .complete) continue;
        if (try net.nowMilliseconds() >= draining_deadline.?) return error.PlaybackStalled;
        if (receiver.gate.phase == .draining) try receiver.pollDrain(state.generation);
        if (try state.controller.takeEffect(.native)) |token| try state.fence(token);
        if (try state.controller.takeEffect(.transport)) |token| {
            switch (token.kind) {
                .send_ack => {
                    const message = receiver.ackMessage(token) catch |err| {
                        try receiver.completeAck(token, .transport_failed);
                        return err;
                    };
                    state.connection.?.confirmDrained(state.generation, 1) catch |err| {
                        try receiver.completeAck(token, .transport_failed);
                        return err;
                    };
                    const bytes = try wire.encodeControl(&ack, .ack, message.stream, message.position);
                    state.connection.?.beginSend(state.generation, 1, bytes, draining_deadline.?) catch |err| {
                        try receiver.completeAck(token, .transport_failed);
                        return err;
                    };
                    try receiver.completeAck(token, .ack_copied);
                    state.connection.?.finishSend(state.generation, 1, draining_deadline.?) catch |err| {
                        try state.controller.transportFailed(state.generation);
                        return err;
                    };
                },
                .close_transport => {
                    state.connection.?.finish(state.generation, 1, draining_deadline.?) catch |err| {
                        try state.controller.complete(token, .transport_failed);
                        return err;
                    };
                    try state.controller.complete(token, .transport_closed);
                    return;
                },
                else => return error.InvalidEffect,
            }
        } else try state.pacer.wait(1);
    }
}
