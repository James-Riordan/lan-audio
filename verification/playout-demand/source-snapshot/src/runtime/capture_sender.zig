//! One media worker: callback capture queue -> assembler -> copied TLS custody.
const core = @import("lan_audio");
const Sender = @import("send_drain").SendDrain(@import("audio_host").Bridge.Queue.frame_capacity);
const net = @import("network_host");

pub fn run(state: anytype) !void {
    try state.healthy();
    var sender = try Sender.init(state.controller, &state.audio.bridge.capture, &state.audio.bridge.capture_failed, state.connection.?.channel.gate);
    defer state.frames = sender.gate.next_frame;
    try state.audio.start();
    @import("std").debug.print("Capture started: 48 kHz stereo.\n", .{});
    const started = try net.nowMilliseconds();
    state.active_since = started;
    while (true) {
        try state.healthy();
        if (!state.controller.snapshot().send.?.draining and
            (state.controls.stop.load(.acquire) or (state.options.seconds != 0 and try net.nowMilliseconds() - started >= @as(u64, state.options.seconds) * 1000)))
            try sender.requestStop(state.generation);
        if (try state.controller.takeEffect(.native)) |token| try state.fence(token);
        const got = try sender.pump(state.generation);
        if (try state.controller.takeEffect(.transport)) |token| {
            const deadline = try state.deadline();
            switch (token.kind) {
                .send_audio, .send_end => {
                    const bytes = sender.prepareRecord(token) catch |err| {
                        try sender.completeRecord(token, if (token.kind == .send_audio) .write_rejected else .transport_failed);
                        return err;
                    };
                    state.connection.?.beginSend(state.generation, 1, bytes, deadline) catch |err| {
                        try sender.completeRecord(token, if (token.kind == .send_audio) .write_rejected else .transport_failed);
                        return err;
                    };
                    // Exactly at copied custody, before network flush can fail.
                    try sender.completeRecord(token, if (token.kind == .send_audio) .write_copied else .end_copied);
                    state.connection.?.finishSend(state.generation, 1, deadline) catch |err| {
                        try state.controller.transportFailed(state.generation);
                        return err;
                    };
                },
                .await_ack => {
                    const message = state.connection.?.receive(state.generation, 1, deadline) catch |err| {
                        try state.controller.complete(token, .transport_failed);
                        return err;
                    };
                    try sender.completeAck(token, message);
                },
                .close_transport => {
                    state.connection.?.finish(state.generation, 1, deadline) catch |err| {
                        try state.controller.complete(token, .transport_failed);
                        return err;
                    };
                    try state.controller.complete(token, .transport_closed);
                    state.frames = sender.gate.next_frame;
                    return;
                },
                else => return error.InvalidEffect,
            }
        } else if (got == 0) try state.pacer.wait(1);
        state.frames = sender.gate.next_frame;
    }
}
