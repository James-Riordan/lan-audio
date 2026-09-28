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
        self.fenced = false;
        self.synchronous_fence_supported = false;
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
        // The pinned native synchronous loop returns from onData before setting
        // stopped/signalling stopEvent. Async backend mapping remains unqualified.
        self.synchronous_fence_supported = profile != .mac_playback and
            (self.context.callbacks.onDeviceRead != null or self.context.callbacks.onDeviceWrite != null or self.context.callbacks.onDeviceDataLoop != null);
        self.state = .ready;
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
