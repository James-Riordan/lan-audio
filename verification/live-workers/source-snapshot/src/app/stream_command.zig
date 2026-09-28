//! Explicit foreground configuration. No fixture credentials or clock defaults.
const std = @import("std");
const builtin = @import("builtin");
const runtime = @import("stream_runtime");
const platform = @import("platform_host");
const policy = @import("peer_policy");
const wire = @import("lan_audio").wire_v2;

pub fn run(init: std.process.Init, args: []const [:0]const u8) !void {
    const sender = std.mem.eql(u8, args[1], "send");
    var address: ?[:0]const u8 = null;
    var ca: ?[:0]const u8 = null;
    var certificate: ?[:0]const u8 = null;
    var key: ?[:0]const u8 = null;
    var fingerprint: ?policy.Fingerprint = null;
    var peer_name: ?[:0]const u8 = null;
    var device: ?[]const u8 = null;
    var port: u16 = 46321;
    var buffer_ms: u32 = 20;
    var seconds: u32 = 0;
    var seen: u16 = 0;
    const names = [_][]const u8{ "--address", "--ca", "--cert", "--key", "--peer-fingerprint", "--peer-name", "--device", "--port", "--buffer-ms", "--seconds" };
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
            4 => fingerprint = try policy.parseFingerprint(value),
            5 => peer_name = value,
            6 => device = value,
            7 => port = try std.fmt.parseInt(u16, value, 10),
            8 => buffer_ms = try std.fmt.parseInt(u32, value, 10),
            9 => seconds = try std.fmt.parseInt(u32, value, 10),
            else => unreachable,
        }
    }
    if (address == null or ca == null or certificate == null or key == null or fingerprint == null) return error.RequiredOptions;
    if (sender != (peer_name != null) or port == 0 or buffer_ms < 5 or buffer_ms > 60 or seconds > 86400 or (!sender and seconds != 0)) return error.InvalidOptions;
    var stream_id: wire.StreamId = undefined;
    try std.Io.randomSecure(init.io, &stream_id);
    const options: runtime.Options = .{
        .role = if (sender) .sender else .receiver,
        .profile = if (sender) (if (builtin.os.tag == .windows) .windows_loopback else return error.UnsupportedCapturePlatform) else switch (builtin.os.tag) {
            .windows => .windows_playback,
            .macos => .mac_playback,
            else => return error.UnsupportedPlaybackPlatform,
        },
        .endpoint = .{ .address = address.?, .port = port },
        .family = if (std.mem.indexOfScalar(u8, address.?, ':') != null) .ipv6 else .ipv4,
        .listen = !sender,
        .ca = ca.?,
        .certificate = certificate.?,
        .key = key.?,
        .peer_name = peer_name,
        .peer_fingerprint = fingerprint.?,
        .stream_id = stream_id,
        .device = if (device) |name| .{ .named = name } else .system_default,
        .prefill_frames = buffer_ms * 48,
        .seconds = seconds,
    };
    try platform.install();
    defer platform.restore();
    try std.Io.File.stdout().writeStreamingAll(init.io, if (sender) "Connecting to the approved receiver. Ctrl+C drains audio; press again to abort.\n" else "Starting the receiver. Ctrl+C stops it.\n");
    const report = try runtime.run(init.gpa, options, .{ .stop = &platform.stop, .abort = &platform.abort, .graceful_sender = &platform.graceful_sender });
    const text = try std.json.Stringify.valueAlloc(init.gpa, .{ .frames = report.frames, .failure = if (report.failure) |err| @errorName(err) else null, .lifecycle = report.lifecycle, .audio = report.audio }, .{});
    defer init.gpa.free(text);
    try std.Io.File.stdout().writeStreamingAll(init.io, text);
    try std.Io.File.stdout().writeStreamingAll(init.io, "\n");
    if (report.failure) |err| return err;
}
