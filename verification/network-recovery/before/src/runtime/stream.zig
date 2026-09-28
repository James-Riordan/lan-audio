//! Foreground control owner and one actual media thread. Fixed heap aggregate until
//! worker join, native fence and socket cleanup. Ordinary tests select null audio.
const std = @import("std");
const audio = @import("audio_host");
const platform = @import("platform_host");
const net = @import("network_host");
const host = @import("verified_channel");
const policy = @import("peer_policy");
const lc = @import("lifecycle");
const wire = @import("lan_audio").wire_v2;
const capture = @import("capture_sender.zig");
const playback = @import("playback_receiver.zig");

pub const Controls = struct { stop: *const std.atomic.Value(bool), abort: *std.atomic.Value(bool), graceful_sender: ?*std.atomic.Value(bool) = null };
pub const Options = struct {
    role: policy.Role,
    profile: audio.Profile,
    endpoint: net.Endpoint,
    family: net.Family,
    listen: bool,
    ca: [:0]const u8,
    certificate: [:0]const u8,
    key: [:0]const u8,
    peer_name: ?[:0]const u8,
    peer_fingerprint: policy.Fingerprint,
    /// Test-only explicit clock override. Product reads wall time after connect,
    /// so a long-lived listener never verifies against its startup timestamp.
    wall_seconds: ?i64 = null,
    stream_id: wire.StreamId,
    device: audio.Endpoint = .system_default,
    prefill_frames: u32 = 960,
    seconds: u32 = 0,
    operation_ms: u32 = 2000,
};
pub const Report = struct {
    frames: u64,
    failure: ?anyerror,
    lifecycle: lc.Snapshot,
    audio: ?audio.AudioDevice.FinalSnapshot,
};

const State = struct {
    controller: *lc.Controller,
    generation: u64,
    options: Options,
    controls: Controls,
    audio: audio.AudioDevice = .{},
    socket: net.Socket = .{},
    connection: ?host.Connection = null,
    pacer: *platform.Pacer,
    worker: ?std.Thread = null,
    started: std.atomic.Value(bool) = .init(false),
    finished: std.atomic.Value(bool) = .init(false),
    failure: ?anyerror = null,
    frames: u64 = 0,

    pub fn deadline(self: *const State) !u64 {
        return std.math.add(u64, try net.nowMilliseconds(), self.options.operation_ms);
    }
    pub fn healthy(self: *State) !void {
        if (self.audio.health().failed()) {
            try self.controller.mediaFault(self.generation);
            return error.NativeAudioFault;
        }
        if (self.controls.abort.load(.acquire)) return error.Canceled;
    }
    pub fn fence(self: *State, token: lc.Token) !void {
        if (token.kind != .fence_device) return error.InvalidEffect;
        // CoreAudio's non-destructive stop fence is not qualified. Destruction is
        // the existing native reclamation boundary; aggregate/bridge stay alive.
        self.audio.fence() catch {
            self.audio.deinit();
        };
        try self.controller.complete(token, .fenced);
        try self.healthy();
    }

    fn work(self: *State) void {
        while (!self.started.load(.acquire)) std.atomic.spinLoopHint();
        (if (self.options.role == .sender) capture.run(self) else playback.run(self)) catch |err| {
            self.failure = if (self.audio.health().failed()) error.NativeAudioFault else err;
            self.connection.?.deinit();
            if (self.audio.health().failed()) self.controller.mediaFault(self.generation) catch unreachable else if (err == error.Canceled) self.controller.requestStop(self.generation) catch unreachable else self.controller.transportFailed(self.generation) catch unreachable;
        };
        self.finished.store(true, .release); // Controller ownership returns after this publication.
    }

    fn setup(self: *State) !void {
        const options = self.options;
        const connect_deadline = try net.nowMilliseconds() + 10_000;
        if (options.listen) {
            var listener: net.Socket = .{};
            defer listener.close() catch @panic("listener close failed");
            try listener.init(options.family);
            try listener.listen(options.endpoint, 1);
            std.debug.print("Listening on {s}:{d}; waiting for the approved peer.\n", .{ options.endpoint.address, try listener.localPort() });
            while (!try listener.accept(&self.socket)) {
                listener.wait(.input, try net.nowMilliseconds() + 1000, self.controls.abort) catch |err| {
                    if (err == error.Deadline) continue;
                    return err;
                };
            }
        } else {
            try self.socket.init(options.family);
            if (!try self.socket.connect(options.endpoint)) {
                while (true) {
                    try self.socket.wait(.output, connect_deadline, self.controls.abort);
                    if (try self.socket.finishConnect()) break;
                }
            }
        }
        self.connection = try host.Connection.init(&self.socket, .{
            .transport_role = if (options.listen) .server else .client,
            .local_role = options.role,
            .generation = self.generation,
            .expected_peer = options.peer_fingerprint,
            .ca_file = options.ca,
            .certificate_file = options.certificate,
            .private_key_file = options.key,
            .reference_identity = if (options.peer_name) |name| .{ .dns = name } else null,
            .wall_time_seconds = options.wall_seconds orelse try platform.wallSeconds(),
            .now_ms = try net.nowMilliseconds(),
        }, self.controls.abort);
        const rules = try policy.Policy.init(1, &.{.{ .peer = options.peer_fingerprint, .roles = .{ .sender = options.role == .receiver, .receiver = options.role == .sender } }});
        _ = try self.connection.?.handshake(self.generation, &rules, try net.nowMilliseconds() + 5000);
        var record: [wire.header_size + wire.profile_size]u8 = undefined;
        if (options.role == .sender) {
            try self.connection.?.send(self.generation, 1, try wire.encodeProfile(&record, .offer, options.stream_id, .{ .max_frames = 240 }), try self.deadline());
            _ = try self.connection.?.receive(self.generation, 1, try self.deadline());
        } else {
            const offer = try self.connection.?.receive(self.generation, 1, try self.deadline());
            const format = try wire.profile(offer);
            if (format.sample_rate != 48000) return error.UnsupportedDeviceRate;
            try self.connection.?.send(self.generation, 1, try wire.encodeProfile(&record, .accept, offer.stream, format), try self.deadline());
        }
        const device_token = (try self.controller.takeEffect(.native)) orelse return error.InvalidEffect;
        self.audio.initWithOptions(options.profile, if (options.role == .sender) .{ .capture = options.device } else .{ .playback = options.device }) catch |err| {
            try self.controller.complete(device_token, .failed_rolled_back);
            return err;
        };
        try self.controller.complete(device_token, .acquired);
        const worker_token = (try self.controller.takeEffect(.joiner)) orelse return error.InvalidEffect;
        self.worker = std.Thread.spawn(.{}, State.work, .{self}) catch |err| {
            try self.controller.complete(worker_token, .failed_rolled_back);
            return err;
        };
        try self.controller.complete(worker_token, .acquired);
        if (self.controls.graceful_sender) |flag| flag.store(options.role == .sender, .release);
        self.started.store(true, .release);
    }

    fn cleanup(self: *State) !void {
        if (self.controller.snapshot().phase != .reclaiming) try self.controller.requestStop(self.generation);
        // Called only before spawn failure or after finished publication.
        while (self.controller.snapshot().phase != .stopped) {
            var acted = false;
            for ([_]lc.Executor{ .joiner, .native, .allocator }) |executor| {
                if (try self.controller.takeEffect(executor)) |token| {
                    acted = true;
                    switch (token.kind) {
                        .join_worker => {
                            self.worker.?.join();
                            self.worker = null;
                            try self.controller.complete(token, .joined);
                        },
                        .fence_device => {
                            self.audio.deinit(); // Join native callbacks even after a failed stop/start.
                            try self.controller.complete(token, .fenced);
                        },
                        .release => {
                            switch (token.resource) {
                                .device => self.audio.deinit(),
                                .worker => {}, // Thread already joined; transport released below.
                                .storage => {
                                    if (self.connection) |*connection| connection.deinit();
                                    self.socket.close() catch |err| {
                                        try self.controller.complete(token, .failure_no_change);
                                        return err;
                                    };
                                }, // Outer scope destroys only after all cleanup succeeds.
                            }
                            try self.controller.complete(token, .released);
                        },
                        else => return error.InvalidEffect,
                    }
                }
            }
            if (!acted) return error.CleanupBlocked;
        }
    }
};

/// Installs no signal handlers. Caller owns Controls through return. Connection
/// and device operations run only on main/control or the one admitted worker.
pub fn run(allocator: std.mem.Allocator, options: Options, controls: Controls) !Report {
    if (options.prefill_frames == 0 or options.prefill_frames > 2880 or options.operation_ms < 100 or options.operation_ms > 30_000) return error.InvalidOptions;
    if ((options.role == .sender and options.profile != .windows_loopback and options.profile != .null_duplex) or
        (options.role == .receiver and options.profile != .windows_playback and options.profile != .mac_playback and options.profile != .null_playback)) return error.InvalidOptions;
    if (options.listen == (options.peer_name != null)) return error.InvalidOptions;
    var controller: lc.Controller = .{};
    const generation = try controller.begin();
    const allocation = (try controller.takeEffect(.allocator)).?;
    const state = allocator.create(State) catch |err| {
        try controller.complete(allocation, .failed_rolled_back);
        return err;
    };
    var pacer = platform.Pacer.init() catch |err| {
        allocator.destroy(state);
        try controller.complete(allocation, .failed_rolled_back);
        return err;
    };
    defer pacer.deinit();
    var watch = platform.Pacer.init() catch |err| {
        allocator.destroy(state);
        try controller.complete(allocation, .failed_rolled_back);
        return err;
    };
    defer watch.deinit();
    defer if (controls.graceful_sender) |flag| flag.store(false, .release);
    state.* = .{ .controller = &controller, .generation = generation, .options = options, .controls = controls, .pacer = &pacer };
    try controller.complete(allocation, .acquired);
    state.setup() catch |err| {
        state.failure = err;
    };
    if (state.worker != null) {
        // Control loop does not touch the ledger while the media thread owns it.
        // Only monotone atomics and live native health are observed concurrently.
        while (!state.finished.load(.acquire)) {
            if (state.audio.health().failed()) controls.abort.store(true, .release);
            watch.wait(10) catch {
                controls.abort.store(true, .release);
            };
        }
    }
    state.cleanup() catch |err| {
        // Never free an aggregate with unresolved native/worker debt. A caller
        // cannot retry using the lost handle; this exceptional state is terminal.
        return err;
    };
    const snapshot = if (state.audio.fenced) try state.audio.finalSnapshot() else null;
    const report: Report = .{ .frames = state.frames, .failure = state.failure, .lifecycle = controller.snapshot(), .audio = snapshot };
    allocator.destroy(state);
    return report;
}
