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

    pub const FinalSnapshot = struct {
        captured_frames: u64,
        dropped_frames: u64,
        rendered_frames: u64,
        silent_frames: u64,
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
        self.fenced = false;
        self.synchronous_fence_supported = false;
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
        const channel_map = [_]c.ma_channel{ c.MA_CHANNEL_FRONT_LEFT, c.MA_CHANNEL_FRONT_RIGHT };
        config.playback.pChannelMap = &channel_map;
        config.capture.pChannelMap = &channel_map;
        config.dataCallback = callback;
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
        if (options.conversion == .require_native and !self.readOpenedFormat().matchesCallback())
            return error.NativeConversionRequired;
        // The pinned native synchronous loop returns from onData before setting
        // stopped/signalling stopEvent. Async backend mapping remains unqualified.
        self.synchronous_fence_supported = profile != .mac_playback and
            (self.context.callbacks.onDeviceRead != null or self.context.callbacks.onDeviceWrite != null or self.context.callbacks.onDeviceDataLoop != null);
        self.state = .ready;
    }

    /// Native format information remains valid for the initialized device only.
    /// Call on the serialized control owner; re-query after reconstruction.
    pub fn openedFormat(self: *const Self) !OpenedFormat {
        if (self.state == .empty) return error.InvalidState;
        return self.readOpenedFormat();
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
        self.fenced = false;
        self.last_result = c.ma_device_start(&self.device);
        if (self.last_result != c.MA_SUCCESS) {
            self.state = .failed;
            return error.DeviceStart;
        }
        self.state = .running;
    }

    pub fn stop(self: *Self) !void {
        if (self.state != .running) return error.InvalidState;
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
            .invalid_buffers = self.invalid_buffers,
            .capture_faults = self.bridge.capture_faults.load(.acquire),
            .counters_exact = self.bridge.counters_exact.load(.acquire),
        };
    }

    // Always uninitializes a created device, even after a start/stop error. This is
    // the reclamation boundary; a successful stop alone does not authorize reset.
    pub fn deinit(self: *Self) void {
        if (self.state == .empty) return;
        c.ma_device_uninit(&self.device);
        _ = c.ma_context_uninit(&self.context);
        self.state = .empty;
        self.fenced = true;
    }

    fn callback(device: [*c]c.ma_device, output: ?*anyopaque, input: ?*const anyopaque, frames: c.ma_uint32) callconv(.c) void {
        const self: *Self = @ptrCast(@alignCast(device.*.pUserData.?));
        const samples: usize = @as(usize, frames) * 2;
        if (output) |ptr| {
            const out: [*]f32 = @ptrCast(@alignCast(ptr));
            self.bridge.renderOutput(out[0..samples]);
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
