//! Foreground inspection entry. Streaming commands await qualified owner wiring.
const std = @import("std");
const builtin = @import("builtin");
const audio = @import("audio_host");

const help =
    \\LAN Audio — development build
    \\
    \\Usage:
    \\  lan-audio devices [--json]  List system-output devices without starting audio
    \\  lan-audio version           Show this build's version
    \\  lan-audio help              Show this help
    \\
    \\Streaming and pairing are still under development.
    \\
;

pub fn main(init: std.process.Init) !void {
    const args = try init.minimal.args.toSlice(init.arena.allocator());
    const stdout = std.Io.File.stdout();
    if (args.len == 1 or (args.len == 2 and (std.mem.eql(u8, args[1], "help") or std.mem.eql(u8, args[1], "--help")))) {
        try stdout.writeStreamingAll(init.io, help);
        return;
    }
    if (args.len == 2 and std.mem.eql(u8, args[1], "version")) {
        try stdout.writeStreamingAll(init.io, "LAN Audio 0.3.0 development\n");
        return;
    }
    const json_output = args.len == 3 and std.mem.eql(u8, args[2], "--json");
    if ((args.len != 2 and !json_output) or !std.mem.eql(u8, args[1], "devices")) {
        try std.Io.File.stderr().writeStreamingAll(init.io, "Unknown command or option. Run 'lan-audio help'.\n");
        std.process.exit(2);
    }
    const profile: audio.Profile = switch (builtin.os.tag) {
        .windows => .windows_loopback,
        .macos => .mac_playback,
        else => {
            try std.Io.File.stderr().writeStreamingAll(init.io, "Audio-device discovery is not implemented for this platform.\n");
            std.process.exit(3);
        },
    };
    const catalog = audio.Catalog.discover(profile) catch |err| {
        var buffer: [256]u8 = undefined;
        const message = try std.fmt.bufPrint(&buffer, "Could not list audio devices ({s}). No audio stream was started.\n", .{@errorName(err)});
        try std.Io.File.stderr().writeStreamingAll(init.io, message);
        std.process.exit(1);
    };
    if (json_output) {
        const View = struct { name: []const u8, is_default: bool, selectable_by_name: bool };
        var views: [audio.Catalog.capacity]View = undefined;
        for (catalog.list(), 0..) |*entry, i| views[i] = .{ .name = entry.name(), .is_default = entry.is_default, .selectable_by_name = entry.selectable_by_name };
        const text = try std.json.Stringify.valueAlloc(init.gpa, .{ .schema = 1, .devices = views[0..catalog.count] }, .{});
        defer init.gpa.free(text);
        try stdout.writeStreamingAll(init.io, text);
        try stdout.writeStreamingAll(init.io, "\n");
    } else {
        try stdout.writeStreamingAll(init.io, "System-output devices:\n");
        if (catalog.count == 0) try stdout.writeStreamingAll(init.io, "  No devices reported.\n");
        for (catalog.list()) |*entry| {
            var clean: [256]u8 = undefined;
            for (entry.name(), 0..) |byte, i| clean[i] = if (byte < 32 or byte == 127) '?' else byte;
            try stdout.writeStreamingAll(init.io, "  ");
            try stdout.writeStreamingAll(init.io, clean[0..entry.name_length]);
            if (entry.is_default) try stdout.writeStreamingAll(init.io, " (default)");
            if (!entry.selectable_by_name) try stdout.writeStreamingAll(init.io, " (duplicate name)");
            try stdout.writeStreamingAll(init.io, "\n");
        }
    }
}
