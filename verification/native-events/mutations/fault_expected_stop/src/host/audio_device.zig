//! Optional native host adapter; never imported by the platform-independent core.
//! Control calls are serialized and forbidden on callbacks. Keep this value at its
//! original address from init through deinit; stop/join worker access before reuse.
const builtin = @import("builtin");
const std = @import("std");
const c = @import("miniaudio").c;
const core = @import("lan_audio");
pub const Bridge = core.CallbackBridge(4096, 2);
pub const Profile = enum { null_duplex, null_playback, windows_loopback, windows_playback, mac_playback };

/// Names match the selected backend's enumeration exactly. Duplicate names fail
/// closed; these are session selectors, not persistent hardware identities.
pub const Endpoint = union(enum) { system_default, named: []const u8 };
pub const Options = struct {
    playback: Endpoint = .system_default,
    capture: Endpoint = .system_default,
    conversion: enum { allow, require_native } = .allow,
};

pub const DeviceFormat = struct {
    sample_format: c.ma_format,
    channels: u32,
    sample_rate: u32,
    left_right: bool,

    pub fn matchesCallback(self: DeviceFormat) bool {
        return self.sample_format == c.ma_format_f32 and self.channels == 2 and self.sample_rate == 48000 and self.left_right;
    }
};

/// Control-owner observation of the opened device, not an acoustic fidelity claim.
pub const OpenedFormat = struct {
    playback: ?DeviceFormat,
    capture: ?DeviceFormat,

    pub fn matchesCallback(self: OpenedFormat) bool {
        if (self.playback) |f| if (!f.matchesCallback()) return false;
        if (self.capture) |f| if (!f.matchesCallback()) return false;
        return true;
    }
};

fn validateEndpoint(endpoint: Endpoint) !void {
    switch (endpoint) {
        .system_default => {},
        .named => |name| if (name.len == 0 or name.len > c.MA_MAX_DEVICE_NAME_LENGTH or std.mem.indexOfScalar(u8, name, 0) != null)
            return error.InvalidEndpointName,
    }
}

fn resolveEndpoint(endpoint: Endpoint, infos: []const c.ma_device_info) !?c.ma_device_id {
    const name = switch (endpoint) {
        .system_default => return null,
        .named => |value| value,
    };
    var selected: ?c.ma_device_id = null;
    for (infos) |info| {
        if (std.mem.eql(u8, name, std.mem.sliceTo(&info.name, 0))) {
            if (selected != null) return error.AmbiguousEndpoint;
            selected = info.id;
        }
    }
    return selected orelse error.EndpointNotFound;
}

test "endpoint resolution rejects missing and duplicate names without default fallback" {
    var infos: [2]c.ma_device_info = @splat(std.mem.zeroes(c.ma_device_info));
    @memcpy(infos[0].name[0..5], "Exact");
    infos[0].id.nullbackend = 17;
    @memcpy(infos[1].name[0..5], "Other");
    infos[1].id.nullbackend = 29;
    try std.testing.expect((try resolveEndpoint(.system_default, &infos)) == null);
    try std.testing.expectEqual(@as(c_int, 17), (try resolveEndpoint(.{ .named = "Exact" }, &infos)).?.nullbackend);
    try std.testing.expectError(error.EndpointNotFound, resolveEndpoint(.{ .named = "exact" }, &infos));
    try std.testing.expectError(error.EndpointNotFound, resolveEndpoint(.{ .named = "Missing" }, &.{}));
    infos[1].name = infos[0].name;
    try std.testing.expectError(error.AmbiguousEndpoint, resolveEndpoint(.{ .named = "Exact" }, &infos));
}

test "strict native format comparison checks every active direction and dimension" {
    const matching: DeviceFormat = .{ .sample_format = c.ma_format_f32, .channels = 2, .sample_rate = 48000, .left_right = true };
    try std.testing.expect((OpenedFormat{ .playback = matching, .capture = null }).matchesCallback());
    try std.testing.expect((OpenedFormat{ .playback = null, .capture = matching }).matchesCallback());
    for (0..4) |field| {
        var changed = matching;
        switch (field) {
            0 => changed.sample_format = c.ma_format_s16,
            1 => changed.channels = 1,
            2 => changed.sample_rate = 44100,
            3 => changed.left_right = false,
            else => unreachable,
        }
        try std.testing.expect(!(OpenedFormat{ .playback = changed, .capture = matching }).matchesCallback());
        try std.testing.expect(!(OpenedFormat{ .playback = matching, .capture = changed }).matchesCallback());
    }
}

pub const AudioDevice = struct {
    const Self = @This();
    context: c.ma_context = undefined,
    device: c.ma_device = undefined,
    bridge: Bridge = .{},
    state: enum { empty, ready, running, failed } = .empty,
    last_result: c.ma_result = c.MA_SUCCESS,
    callback_count: std.atomic.Value(u32) = .init(0),
    invalid_buffers: u64 = 0, // callback-owned; read only after fence/deinit
    fenced: bool = false,
    synchronous_fence_supported: bool = false,
    initial_format: ?OpenedFormat = null,
    // Only the control owner writes expected_stop. Notification producers only
    // publish sticky true values to separate atomic flags; no RMW or lock.
    expected_stop: std.atomic.Value(bool) = .init(true),
    unexpected_stop: std.atomic.Value(bool) = .init(false),
    rerouted: std.atomic.Value(bool) = .init(false),
    interrupted: std.atomic.Value(bool) = .init(false),
    unknown_notification: std.atomic.Value(bool) = .init(false),

    pub const Health = struct {
        capture_failed: bool,
        playback_failed: bool,
        unexpected_stop: bool,
        rerouted: bool,
        interrupted: bool,
        unknown_notification: bool,

        pub fn failed(self: Health) bool {
            return self.capture_failed or self.playback_failed or self.unexpected_stop or
                self.rerouted or self.interrupted or self.unknown_notification;
        }
    };

    pub const FinalSnapshot = struct {
        captured_frames: u64,
        dropped_frames: u64,
        rendered_frames: u64,
        silent_frames: u64,
        missing_output_frames: u64,
        invalid_buffers: u64,
        capture_faults: u32,
        counters_exact: bool,
    };

    pub fn init(self: *Self, profile: Profile) !void {
        return self.initWithOptions(profile, .{});
    }

    /// Fully acquires a stopped device or releases all successfully acquired
    /// native resources. Endpoint slices are borrowed only until this returns.
    pub fn initWithOptions(self: *Self, profile: Profile, options: Options) !void {
        if (self.state != .empty) return error.InvalidState;
        if ((profile == .windows_loopback or profile == .windows_playback) and builtin.os.tag != .windows)
            return error.UnsupportedPlatform;
        if (profile == .mac_playback and builtin.os.tag != .macos) return error.UnsupportedPlatform;
        const backend: c.ma_backend = switch (profile) {
            .null_duplex, .null_playback => c.ma_backend_null,
            .windows_loopback, .windows_playback => c.ma_backend_wasapi,
            .mac_playback => c.ma_backend_coreaudio,
        };
        const kind: c.ma_device_type = switch (profile) {
            .null_duplex => c.ma_device_type_duplex,
            .windows_loopback => c.ma_device_type_loopback,
            .null_playback, .windows_playback, .mac_playback => c.ma_device_type_playback,
        };
        const has_playback = kind == c.ma_device_type_playback or kind == c.ma_device_type_duplex;
        const has_capture = kind == c.ma_device_type_loopback or kind == c.ma_device_type_duplex;
        if ((!has_playback and options.playback != .system_default) or
            (!has_capture and options.capture != .system_default)) return error.UnusedEndpoint;
        try validateEndpoint(options.playback);
        try validateEndpoint(options.capture);
        // This reset is legal only with all earlier callback and worker owners joined.
        self.bridge = .{};
        self.expected_stop.store(true, .monotonic);
        self.unexpected_stop.store(false, .monotonic);
        self.rerouted.store(false, .monotonic);
        self.interrupted.store(false, .monotonic);
        self.unknown_notification.store(false, .monotonic);
        self.fenced = false;
        self.synchronous_fence_supported = false;
        self.initial_format = null;
        self.invalid_buffers = 0;
        self.callback_count.store(0, .monotonic);
        self.last_result = c.ma_context_init(&backend, 1, null, &self.context);
        if (self.last_result != c.MA_SUCCESS) return error.ContextInit;
        errdefer _ = c.ma_context_uninit(&self.context);
        var playback_id: ?c.ma_device_id = null;
        var capture_id: ?c.ma_device_id = null;
        if (options.playback != .system_default or options.capture != .system_default) {
            var playback_infos: [*c]c.ma_device_info = null;
            var capture_infos: [*c]c.ma_device_info = null;
            var playback_count: c.ma_uint32 = 0;
            var capture_count: c.ma_uint32 = 0;
            self.last_result = c.ma_context_get_devices(&self.context, &playback_infos, &playback_count, &capture_infos, &capture_count);
            if (self.last_result != c.MA_SUCCESS) return error.DeviceEnumeration;
            playback_id = try resolveEndpoint(options.playback, playback_infos[0..playback_count]);
            // WASAPI loopback captures a playback endpoint, never a microphone.
            capture_id = try resolveEndpoint(options.capture, if (kind == c.ma_device_type_loopback)
                playback_infos[0..playback_count]
            else
                capture_infos[0..capture_count]);
        }
        var config = c.ma_device_config_init(kind);
        config.playback.pDeviceID = if (playback_id) |*id| id else null;
        config.capture.pDeviceID = if (capture_id) |*id| id else null;
        config.sampleRate = 48000;
        config.periodSizeInFrames = 240; // hint only; callbacks may have other sizes
        config.playback.format = c.ma_format_f32;
        config.playback.channels = 2;
        config.capture.format = c.ma_format_f32;
        config.capture.channels = 2;
        var channel_map = [_]c.ma_channel{ c.MA_CHANNEL_FRONT_LEFT, c.MA_CHANNEL_FRONT_RIGHT };
        config.playback.pChannelMap = &channel_map;
        config.capture.pChannelMap = &channel_map;
        config.dataCallback = callback;
        config.notificationCallback = notification;
        config.pUserData = self;
        self.last_result = c.ma_device_init(&self.context, &config, &self.device);
        if (self.last_result != c.MA_SUCCESS) return error.DeviceInit;
        errdefer c.ma_device_uninit(&self.device);
        // Validate the actual callback ABI before any start can access fixed
        // stereo storage. Native formats may differ through miniaudio conversion.
        if (self.device.sampleRate != 48000 or
            (has_playback and (self.device.playback.format != c.ma_format_f32 or self.device.playback.channels != 2 or !leftRight(&self.device.playback.channelMap))) or
            (has_capture and (self.device.capture.format != c.ma_format_f32 or self.device.capture.channels != 2 or !leftRight(&self.device.capture.channelMap))))
            return error.CallbackFormatMismatch;
        const opened = self.readOpenedFormat();
        if (options.conversion == .require_native and !opened.matchesCallback())
            return error.NativeConversionRequired;
        if (self.health().failed()) return error.NativeFault;
        // The pinned native synchronous loop returns from onData before setting
        // stopped/signalling stopEvent. Async backend mapping remains unqualified.
        self.synchronous_fence_supported = profile != .mac_playback and
            (self.context.callbacks.onDeviceRead != null or self.context.callbacks.onDeviceWrite != null or self.context.callbacks.onDeviceDataLoop != null);
        self.initial_format = opened;
        self.state = .ready;
    }

    /// Immutable opening-time observation; never read native fields that an
    /// automatic reroute could mutate. Call on the serialized control owner.
    pub fn openedFormat(self: *const Self) !OpenedFormat {
        if (self.state == .empty) return error.InvalidState;
        if (self.health().failed()) return error.NativeFault;
        return self.initial_format.?;
    }

    /// Live monotone observations, not a simultaneous snapshot or native join.
    /// Any fault invalidates graceful media completion for this generation.
    pub fn health(self: *const Self) Health {
        return .{
            .capture_failed = self.bridge.capture_failed.load(.acquire),
            .playback_failed = self.bridge.playback_failed.load(.acquire),
            .unexpected_stop = self.unexpected_stop.load(.acquire),
            .rerouted = self.rerouted.load(.acquire),
            .interrupted = self.interrupted.load(.acquire),
            .unknown_notification = self.unknown_notification.load(.acquire),
        };
    }

    fn readOpenedFormat(self: *const Self) OpenedFormat {
        const has_playback = self.device.type == c.ma_device_type_playback or self.device.type == c.ma_device_type_duplex;
        const has_capture = self.device.type == c.ma_device_type_loopback or self.device.type == c.ma_device_type_duplex;
        return .{
            .playback = if (has_playback) .{
                .sample_format = self.device.playback.internalFormat,
                .channels = self.device.playback.internalChannels,
                .sample_rate = self.device.playback.internalSampleRate,
                .left_right = leftRight(&self.device.playback.internalChannelMap),
            } else null,
            .capture = if (has_capture) .{
                .sample_format = self.device.capture.internalFormat,
                .channels = self.device.capture.internalChannels,
                .sample_rate = self.device.capture.internalSampleRate,
                .left_right = leftRight(&self.device.capture.internalChannelMap),
            } else null,
        };
    }

    fn leftRight(channel_map: []const c.ma_channel) bool {
        return channel_map[0] == c.MA_CHANNEL_FRONT_LEFT and channel_map[1] == c.MA_CHANNEL_FRONT_RIGHT;
    }

    pub fn start(self: *Self) !void {
        if (self.state != .ready) return error.InvalidState;
        if (self.health().failed()) return error.NativeFault;
        self.fenced = false;
        self.expected_stop.store(false, .release);
        self.last_result = c.ma_device_start(&self.device);
        if (self.last_result != c.MA_SUCCESS) {
            self.state = .failed;
            return error.DeviceStart;
        }
        if (self.health().failed()) {
            self.state = .failed;
            return error.NativeFault;
        }
        self.state = .running;
    }

    pub fn stop(self: *Self) !void {
        if (self.state != .running) return error.InvalidState;
        self.expected_stop.store(true, .release);
        self.last_result = c.ma_device_stop(&self.device);
        if (self.last_result != c.MA_SUCCESS) {
            self.state = .failed;
            return error.DeviceStop;
        }
        self.state = .ready;
    }

    /// Non-destructive callback fence for the reviewed synchronous backend path.
    /// Control owner only. May block inside native stop; timeout is not permission
    /// to reclaim storage. Unsupported/failed backends retain their native debt.
    pub fn fence(self: *Self) !void {
        if (self.state == .empty) return error.InvalidState;
        if (!self.synchronous_fence_supported) return error.UnsupportedFence;
        if (self.state == .failed) return error.UnresolvedNativeFailure;
        if (self.fenced) return;
        if (self.state == .running) try self.stop();
        self.fenced = true;
    }

    /// Coherent callback-owned facts only after fence/deinit. Queue cursors remain
    /// their producer/consumer's responsibility; snapshot does not inspect them.
    pub fn finalSnapshot(self: *const Self) !FinalSnapshot {
        if (!self.fenced) return error.NotFenced;
        return .{
            .captured_frames = self.bridge.captured_frames,
            .dropped_frames = self.bridge.dropped_frames,
            .rendered_frames = self.bridge.rendered_frames,
            .silent_frames = self.bridge.silent_frames,
            .missing_output_frames = self.bridge.missing_output_frames,
            .invalid_buffers = self.invalid_buffers,
            .capture_faults = self.bridge.capture_faults.load(.acquire),
            .counters_exact = self.bridge.counters_exact.load(.acquire),
        };
    }

    // Always uninitializes a created device, even after a start/stop error. This is
    // the reclamation boundary; a successful stop alone does not authorize reset.
    pub fn deinit(self: *Self) void {
        if (self.state == .empty) return;
        self.expected_stop.store(true, .release);
        c.ma_device_uninit(&self.device);
        _ = c.ma_context_uninit(&self.context);
        self.state = .empty;
        self.fenced = true;
    }

    fn notification(event: [*c]const c.ma_device_notification) callconv(.c) void {
        const self: *Self = @ptrCast(@alignCast(event.*.pDevice.*.pUserData.?));
        switch (event.*.type) {
            c.ma_device_notification_type_started,
            c.ma_device_notification_type_interruption_ended,
            c.ma_device_notification_type_unlocked,
            => return, // Resuming/unlocking never clears an earlier fault.
            c.ma_device_notification_type_stopped => {
                // Deliberately classify every normal stop as a fault.
                self.unexpected_stop.store(true, .release);
            },
            c.ma_device_notification_type_rerouted => self.rerouted.store(true, .release),
            c.ma_device_notification_type_interruption_began => self.interrupted.store(true, .release),
            else => self.unknown_notification.store(true, .release),
        }
        // Notifications can run without another data callback ever arriving.
        // Publish directly to the flags observed by media owners. Plain counters
        // and the callback-only capture reason bitset are never touched here.
        const kind = event.*.pDevice.*.type;
        if (kind == c.ma_device_type_loopback or kind == c.ma_device_type_duplex)
            self.bridge.capture_failed.store(true, .release);
        if (kind == c.ma_device_type_playback or kind == c.ma_device_type_duplex)
            self.bridge.playback_failed.store(true, .release);
    }

    fn callback(device: [*c]c.ma_device, output: ?*anyopaque, input: ?*const anyopaque, frames: c.ma_uint32) callconv(.c) void {
        const self: *Self = @ptrCast(@alignCast(device.*.pUserData.?));
        const samples: usize = @as(usize, frames) * 2;
        if (output) |ptr| {
            const out: [*]f32 = @ptrCast(@alignCast(ptr));
            self.bridge.renderOutput(out[0..samples]);
        } else if (frames > 0 and (device.*.type == c.ma_device_type_playback or device.*.type == c.ma_device_type_duplex)) {
            if (self.invalid_buffers == std.math.maxInt(u64)) self.bridge.counters_exact.store(false, .release);
            self.invalid_buffers +|= 1;
            self.bridge.missingOutput(frames);
        }
        if (input) |ptr| {
            const in: [*]const f32 = @ptrCast(@alignCast(ptr));
            self.bridge.captureInput(in[0..samples]);
        } else if (frames > 0 and (device.*.type == c.ma_device_type_loopback or device.*.type == c.ma_device_type_duplex)) {
            if (self.invalid_buffers == std.math.maxInt(u64)) self.bridge.counters_exact.store(false, .release);
            self.invalid_buffers +|= 1;
            self.bridge.missingInput(frames);
        }
        // Diagnostic only: modulo counter is not a completion/lifetime fence.
        const count = self.callback_count.load(.monotonic);
        self.callback_count.store(count +% 1, .monotonic);
    }
};

test "installed native notifications invalidate both directions without consuming media" {
    const Notify = struct {
        fn emit(host: *AudioDevice, kind: c.ma_device_notification_type) void {
            var event: c.ma_device_notification = std.mem.zeroes(c.ma_device_notification);
            event.pDevice = &host.device;
            event.type = kind;
            host.device.onNotification.?(&event);
        }
    };
    for ([_]c.ma_device_notification_type{
        c.ma_device_notification_type_rerouted,
        c.ma_device_notification_type_interruption_began,
        std.math.maxInt(c.ma_device_notification_type),
    }) |fault| {
        var host: AudioDevice = .{};
        defer host.deinit();
        try host.init(.null_duplex);
        // Never started: installed callback ABI, no physical/native producer.
        for ([_]c.ma_device_notification_type{
            c.ma_device_notification_type_started,
            c.ma_device_notification_type_stopped,
            c.ma_device_notification_type_interruption_ended,
            c.ma_device_notification_type_unlocked,
        }) |ordinary| Notify.emit(&host, ordinary);
        try std.testing.expect(!host.health().failed());
        try std.testing.expectEqual(2, host.bridge.playback.write(&.{ 1, -1, 2, -2 }));
        host.bridge.captureInput(&.{ 3, -3 });
        Notify.emit(&host, fault);
        const health = host.health();
        try std.testing.expect(health.capture_failed and health.playback_failed);
        try std.testing.expectEqual(fault == c.ma_device_notification_type_rerouted, health.rerouted);
        try std.testing.expectEqual(fault == c.ma_device_notification_type_interruption_began, health.interrupted);
        try std.testing.expectEqual(fault == std.math.maxInt(c.ma_device_notification_type), health.unknown_notification);
        Notify.emit(&host, c.ma_device_notification_type_interruption_ended);
        Notify.emit(&host, c.ma_device_notification_type_started);
        var output: [4]f32 = @splat(9);
        const input = [_]f32{ 4, -4, 5, -5 };
        host.device.onData.?(&host.device, &output, &input, 2);
        try std.testing.expectEqualSlices(f32, &@as([4]f32, @splat(0)), &output);
        try std.testing.expectEqual(@as(u32, 2), host.bridge.playback.consumerAvailable());
        try std.testing.expectEqual(@as(u32, 1), host.bridge.capture.consumerAvailable());
        try std.testing.expectError(error.NativeFault, host.start());
        try std.testing.expectError(error.NativeFault, host.openedFormat());
        try host.fence();
        const snapshot = try host.finalSnapshot();
        try std.testing.expectEqual(@as(u64, 0), snapshot.rendered_frames);
        try std.testing.expectEqual(@as(u64, 2), snapshot.silent_frames);
        try std.testing.expectEqual(@as(u64, 2), snapshot.dropped_frames);
        try std.testing.expect(host.health().failed()); // fence is not recovery.
        host.deinit();
        try std.testing.expect(host.health().failed());
        try host.init(.null_duplex); // Only complete reconstruction clears faults.
        try std.testing.expect(!host.health().failed());
    }
}

test "concurrent native notifications retain independent sticky reasons" {
    const Publisher = struct {
        host: *AudioDevice,
        kind: c.ma_device_notification_type,
        fn run(self: *@This()) void {
            var event: c.ma_device_notification = std.mem.zeroes(c.ma_device_notification);
            event.pDevice = &self.host.device;
            event.type = self.kind;
            for (0..10000) |_| self.host.device.onNotification.?(&event);
        }
    };
    var host: AudioDevice = .{};
    defer host.deinit();
    try host.init(.null_duplex);
    host.expected_stop.store(false, .release); // Controlled active intent, no driver.
    var publishers = [_]Publisher{
        .{ .host = &host, .kind = c.ma_device_notification_type_stopped },
        .{ .host = &host, .kind = c.ma_device_notification_type_rerouted },
        .{ .host = &host, .kind = c.ma_device_notification_type_interruption_began },
    };
    var threads: [3]std.Thread = undefined;
    var started: usize = 0;
    defer for (threads[0..started]) |thread| thread.join();
    for (&publishers) |*publisher| {
        threads[started] = try std.Thread.spawn(.{}, Publisher.run, .{publisher});
        started += 1;
    }
    for (threads) |thread| thread.join();
    started = 0;
    const health = host.health();
    try std.testing.expect(health.unexpected_stop and health.rerouted and health.interrupted);
    try std.testing.expect(health.capture_failed and health.playback_failed);
    try std.testing.expectEqual(@as(u64, 0), host.bridge.dropped_frames);
    try std.testing.expectEqual(@as(u64, 0), host.bridge.silent_frames);
    try std.testing.expectError(error.NativeFault, host.start());
}
