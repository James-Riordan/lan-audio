// Engineering contract (2026-09-26)
// Standalone consumer build that imports the public TLS package.
// File contract: docs/reference/files/examples/consumer/build.zig.md
// Ownership and invariant: Links Winsock and stages TLS-exported runtime DLLs next to the
// executable. Its dependency comes from the sibling package manifest.
// Next implementation obligation: T2 adds target-specific linkage with explicit unsupported-target
// errors. Keep this external import regression whenever public exports or runtime packaging
// change.

const std = @import("std");
pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});
    const dep = b.dependency("tls_zig", .{ .target = target, .optimize = optimize });
    const mod = b.createModule(.{ .root_source_file = b.path("main.zig"), .target = target, .optimize = optimize, .imports = &.{.{ .name = "tls", .module = dep.module("tls") }}, .link_libc = true });
    mod.addCSourceFile(.{ .file = b.path("socket.c"), .flags = &.{ "-Wall", "-Wextra", "-Werror" } });
    mod.linkSystemLibrary("ws2_32", .{});
    const exe = b.addExecutable(.{ .name = "tls-tcp-consumer", .root_module = mod });
    b.installArtifact(exe);
    for ([_][]const u8{ "libssl-3-x64.dll", "libcrypto-3-x64.dll" }) |name|
        b.getInstallStep().dependOn(&b.addInstallBinFile(dep.namedLazyPath("runtime").path(b, name), name).step);
}
