//! Explicit foreground configuration. No fixture credentials or clock defaults.
const std = @import("std");
const builtin = @import("builtin");
const runtime = @import("stream_runtime");
const platform = @import("platform_host");
const policy = @import("peer_policy");
const wire = @import("lan_audio").wire_v2;
const supervisor = @import("session_supervisor");
const config = @import("config.zig");

const Display = struct {
    io: std.Io,
    allocator: std.mem.Allocator,
    fn completed(context: *anyopaque, event: supervisor.Event) !void {
        const self: *Display = @ptrCast(@alignCast(context));
        const report = event.report;
        const text = try std.json.Stringify.valueAlloc(self.allocator, .{
            .attempt = event.attempt,
            .buffer_ms = event.prefill_frames / 48,
            .frames = report.frames,
            .failure = if (report.failure) |err| @errorName(err) else null,
            .lifecycle = report.lifecycle,
            .audio = report.audio,
            .active_ms = report.active_ms,
            .starved = report.starved,
            .unplayed_frames = report.unplayed_frames,
            .clock_keepalive = report.keepalive_fenced,
            .media_priority = report.media_priority,
            .delivery_timing = report.delivery_timing,
        }, .{});
        defer self.allocator.free(text);
        try std.Io.File.stdout().writeStreamingAll(self.io, text);
        try std.Io.File.stdout().writeStreamingAll(self.io, "\n");
    }
};

pub fn run(init: std.process.Init, args: []const [:0]const u8) !void {
    const sender = std.mem.eql(u8, args[1], "send");
    var address: ?[:0]const u8 = null;
    var ca: ?[:0]const u8 = null;
    var certificate: ?[:0]const u8 = null;
    var key: ?[:0]const u8 = null;
    var fingerprint: ?[]const u8 = null;
    var peer_name: ?[:0]const u8 = null;
    var device: ?[]const u8 = null;
    var port: u16 = 46321;
    var buffer_ms: u32 = 40;
    var seconds: u32 = 0;
    var max_buffer_ms: u32 = 120;
    var reconnect = true;
    var seen: u16 = 0;
    const names = [_][]const u8{ "--address", "--ca", "--cert", "--key", "--peer-fingerprint", "--peer-name", "--device", "--port", "--buffer-ms", "--seconds", "--max-buffer-ms", "--reconnect" };
    var i: usize = 2;
    while (i < args.len) : (i += 2) {
        if (i + 1 >= args.len or args[i + 1].len == 0) return error.MissingOptionValue;
        const index = for (names, 0..) |name, n| {
            if (std.mem.eql(u8, args[i], name)) break n;
        } else return error.UnknownOption;
        const bit = @as(u16, 1) << @as(u4, @intCast(index));
        if (seen & bit != 0) return error.DuplicateOption;
        seen |= bit;
        const value = args[i + 1];
        switch (index) {
            0 => address = value,
            1 => ca = value,
            2 => certificate = value,
            3 => key = value,
            4 => fingerprint = value,
            5 => peer_name = value,
            6 => device = value,
            7 => port = try std.fmt.parseInt(u16, value, 10),
            8 => buffer_ms = try std.fmt.parseInt(u32, value, 10),
            9 => seconds = try std.fmt.parseInt(u32, value, 10),
            10 => max_buffer_ms = try std.fmt.parseInt(u32, value, 10),
            11 => {
                if (std.mem.eql(u8, value, "on")) reconnect = true else if (std.mem.eql(u8, value, "off")) reconnect = false else return error.InvalidOptions;
            },
            else => unreachable,
        }
    }
    if (address == null or ca == null or certificate == null or key == null or fingerprint == null) return error.RequiredOptions;
    return runEffective(init, .{
        .role = if (sender) .send else .receive,
        .address = address.?,
        .ca = ca.?,
        .cert = certificate.?,
        .key = key.?,
        .peer_fingerprint = fingerprint.?,
        .peer_name = peer_name,
        .device = device,
        .port = port,
        .buffer_ms = buffer_ms,
        .max_buffer_ms = max_buffer_ms,
        .seconds = seconds,
        .reconnect = reconnect,
    });
}

pub fn runFile(init: std.process.Init, args: []const [:0]const u8) !void {
    const saved = std.mem.eql(u8, args[1], "start") or std.mem.eql(u8, args[1], "check");
    var filename: ?[]const u8 = null;
    var profile: ?[]const u8 = null;
    var i: usize = 2;
    while (i < args.len) : (i += 2) {
        if (i + 1 >= args.len or args[i + 1].len == 0) return error.MissingOptionValue;
        if (std.mem.eql(u8, args[i], "--config")) {
            if (filename != null) return error.DuplicateOption;
            filename = args[i + 1];
        } else if (std.mem.eql(u8, args[i], "--profile")) {
            if (profile != null) return error.DuplicateOption;
            profile = args[i + 1];
        } else return error.UnknownOption;
    }
    const allocator = init.arena.allocator();
    if (saved) {
        if (filename == null) {
            const executable = try std.process.executablePathAlloc(init.io, allocator);
            filename = try std.fs.path.join(allocator, &.{ std.fs.path.dirname(executable).?, "lan-audio.json" });
        }
        if (profile == null) profile = "home";
    }
    if (filename == null or profile == null) return error.RequiredOptions;
    const absolute = try std.Io.Dir.cwd().realPathFileAlloc(init.io, filename.?, allocator);
    const bytes = try std.Io.Dir.cwd().readFileAlloc(init.io, absolute, allocator, .limited(config.maximum_bytes));
    const parsed = try config.parse(allocator, bytes);
    defer parsed.deinit();
    var effective = try config.resolve(parsed.value, profile.?);
    // Credentials are references, never config-embedded key material. Resolve
    // relative references against the actual file's directory, independent of cwd.
    const directory = std.fs.path.dirname(absolute).?;
    effective.ca = try std.fs.path.resolve(allocator, &.{ directory, effective.ca });
    effective.cert = try std.fs.path.resolve(allocator, &.{ directory, effective.cert });
    effective.key = try std.fs.path.resolve(allocator, &.{ directory, effective.key });
    try checkPlatform(effective);
    if (std.mem.eql(u8, args[1], "validate") or std.mem.eql(u8, args[1], "check")) {
        const text = try std.json.Stringify.valueAlloc(allocator, .{
            .schema = 1,
            .valid = true,
            .profile = profile.?,
            .role = effective.role,
            .buffer_ms = effective.buffer_ms,
            .max_buffer_ms = effective.max_buffer_ms,
            .reconnect = effective.reconnect,
            .capture = if (effective.role == .send) "system_output" else null,
            .credentials_checked = false,
            .device_checked = false,
            .network_checked = false,
        }, .{});
        try std.Io.File.stdout().writeStreamingAll(init.io, text);
        try std.Io.File.stdout().writeStreamingAll(init.io, "\n");
        return;
    }
    return runEffective(init, effective);
}

fn checkPlatform(effective: config.Effective) !void {
    if (effective.role == .send and builtin.os.tag != .windows) return error.UnsupportedCapturePlatform;
    if (effective.role == .receive and builtin.os.tag != .windows and builtin.os.tag != .macos) return error.UnsupportedPlaybackPlatform;
}

fn runEffective(init: std.process.Init, effective: config.Effective) !void {
    try config.validate(effective);
    try checkPlatform(effective);
    const allocator = init.arena.allocator();
    const sender = effective.role == .send;
    var stream_id: wire.StreamId = undefined;
    try std.Io.randomSecure(init.io, &stream_id);
    const options: runtime.Options = .{
        .role = if (sender) .sender else .receiver,
        .profile = if (sender) (if (builtin.os.tag == .windows) .windows_loopback else return error.UnsupportedCapturePlatform) else switch (builtin.os.tag) {
            .windows => .windows_playback,
            .macos => .mac_playback,
            else => return error.UnsupportedPlaybackPlatform,
        },
        .endpoint = .{ .address = try allocator.dupeSentinel(u8, effective.address, 0), .port = effective.port },
        .family = if (std.mem.indexOfScalar(u8, effective.address, ':') != null) .ipv6 else .ipv4,
        .listen = !sender,
        .ca = try allocator.dupeSentinel(u8, effective.ca, 0),
        .certificate = try allocator.dupeSentinel(u8, effective.cert, 0),
        .key = try allocator.dupeSentinel(u8, effective.key, 0),
        .peer_name = if (effective.peer_name) |name| try allocator.dupeSentinel(u8, name, 0) else null,
        .peer_fingerprint = try policy.parseFingerprint(effective.peer_fingerprint),
        .stream_id = stream_id,
        .device = if (effective.device) |name| .{ .named = name } else .system_default,
        .prefill_frames = effective.buffer_ms * 48,
        .seconds = effective.seconds,
    };
    try platform.install();
    defer platform.restore();
    try std.Io.File.stdout().writeStreamingAll(init.io, if (sender) "Connecting to the approved receiver. Ctrl+C drains audio; press again to abort.\n" else "Starting the receiver. Ctrl+C stops it.\n");
    var display: Display = .{ .io = init.io, .allocator = init.gpa };
    const summary = try supervisor.run(init.gpa, init.io, options, .{ .stop = &platform.stop, .abort = &platform.abort, .graceful_sender = &platform.graceful_sender }, .{ .enabled = effective.reconnect, .max_prefill_frames = effective.max_buffer_ms * 48 }, .{ .context = &display, .completed = Display.completed });
    if (!summary.intentional_stop) if (summary.last_failure) |err| return err;
}
