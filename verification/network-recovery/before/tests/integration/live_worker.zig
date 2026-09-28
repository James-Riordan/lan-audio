//! Explicit public fixtures and null callbacks. Never imported by the product CLI.
const std = @import("std");
const runtime = @import("stream_runtime");
const policy = @import("peer_policy");
pub fn main(init: std.process.Init) !void {
    const args = try init.minimal.args.toSlice(init.arena.allocator());
    if (args.len != 5) return error.Arguments;
    const sender = std.mem.eql(u8, args[1], "sender");
    const listener = std.mem.eql(u8, args[4], "listener");
    const cancel = std.mem.eql(u8, args[4], "cancel");
    var stop: std.atomic.Value(bool) = .init(false);
    var abort: std.atomic.Value(bool) = .init(false);
    const Canceler = struct {
        fn run(io: std.Io, flag: *std.atomic.Value(bool)) void {
            std.Io.sleep(io, .fromMilliseconds(500), .awake) catch @panic("fixture timer failed");
            flag.store(true, .release);
        }
    };
    const canceler = if (cancel) try std.Thread.spawn(.{}, Canceler.run, .{ init.io, &abort }) else null;
    defer if (canceler) |thread| thread.join();
    const report = try runtime.run(init.gpa, .{
        .role = if (sender) .sender else .receiver,
        .profile = if (sender) .null_duplex else .null_playback,
        .endpoint = .{ .address = "127.0.0.1", .port = try std.fmt.parseInt(u16, args[2], 10) },
        .family = .ipv4,
        .listen = listener,
        .ca = "tests/fixtures/ca.pem",
        .certificate = if (listener) "tests/fixtures/server.pem" else "tests/fixtures/client.pem",
        .key = if (listener) "tests/fixtures/server.key" else "tests/fixtures/client.key",
        .peer_name = if (listener) null else "localhost",
        .peer_fingerprint = try policy.parseFingerprint(args[3]),
        .wall_seconds = 1_789_300_000,
        .stream_id = .{ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16 },
        .seconds = if (sender) 2 else 0,
    }, .{ .stop = &stop, .abort = &abort });
    const text = try std.json.Stringify.valueAlloc(init.gpa, .{ .frames = report.frames, .failure = if (report.failure) |err| @errorName(err) else null, .lifecycle = report.lifecycle, .audio = report.audio }, .{});
    defer init.gpa.free(text);
    try std.Io.File.stdout().writeStreamingAll(init.io, text);
    try std.Io.File.stdout().writeStreamingAll(init.io, "\n");
    if (report.failure) |err| return err;
}
