//! Optional native host adapter; never imported by the platform-independent core.
//! Control calls are serialized and forbidden on callbacks. Keep this value at its
//! original address from init through deinit; stop/join worker access before reuse.
const builtin = @import("builtin");
const std = @import("std");
const c = @import("miniaudio").c;
const core = @import("lan_audio");
pub const Bridge = core.CallbackBridge(4096, 2);
pub const Profile = enum { null_duplex, null_playback, windows_loopback, windows_playback, mac_playback };

pub const AudioDevice = struct {
    const Self = @This();
    context: c.ma_context = undefined,
    device: c.ma_device = undefined,
    bridge: Bridge = .{},
    state: enum { empty, ready, running, failed } = .empty,
    last_result: c.ma_result = c.MA_SUCCESS,
    callback_count: std.atomic.Value(u32) = .init(0),
    invalid_buffers: u64 = 0, // callback-owned; read only after deinit

    pub fn init(self: *Self, profile: Profile) !void {
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
        // This reset is legal only with all earlier callback and worker owners joined.
        self.bridge = .{};
        self.invalid_buffers = 0;
        self.callback_count.store(0, .monotonic);
        self.last_result = c.ma_context_init(&backend, 1, null, &self.context);
        if (self.last_result != c.MA_SUCCESS) return error.ContextInit;
        errdefer _ = c.ma_context_uninit(&self.context);
        var config = c.ma_device_config_init(kind);
        config.sampleRate = 48000;
        config.periodSizeInFrames = 240; // hint only; callbacks may have other sizes
        config.playback.format = c.ma_format_f32;
        config.playback.channels = 2;
        config.capture.format = c.ma_format_f32;
        config.capture.channels = 2;
        config.dataCallback = callback;
        config.pUserData = self;
        self.last_result = c.ma_device_init(&self.context, &config, &self.device);
        if (self.last_result != c.MA_SUCCESS) return error.DeviceInit;
        self.state = .ready;
    }

    pub fn start(self: *Self) !void {
        if (self.state != .ready) return error.InvalidState;
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

    // Always uninitializes a created device, even after a start/stop error. This is
    // the reclamation boundary; a successful stop alone does not authorize reset.
    pub fn deinit(self: *Self) void {
        if (self.state == .empty) return;
        c.ma_device_uninit(&self.device);
        _ = c.ma_context_uninit(&self.context);
        self.state = .empty;
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
        } else if (device.*.type == c.ma_device_type_loopback or device.*.type == c.ma_device_type_duplex) {
            self.invalid_buffers +|= 1;
        }
        // Diagnostic only: modulo counter is not a completion/lifetime fence.
        const count = self.callback_count.load(.monotonic);
        self.callback_count.store(count +% 1, .monotonic);
    }
};
