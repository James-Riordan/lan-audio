//! Core, native callback and explicit hardware/transport qualification steps.
//! Physical capture runs only under capture-test; ordinary tests use no device.
const std = @import("std");
pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});
    const core = b.addModule("lan_audio", .{ .root_source_file = b.path("src/root.zig"), .target = target, .optimize = optimize });
    const tests = b.addTest(.{ .root_module = b.createModule(.{
        .root_source_file = b.path("tests/core.zig"),
        .target = target,
        .optimize = optimize,
        .imports = &.{.{ .name = "lan_audio", .module = core }},
    }) });
    b.step("test", "Run pure session, admission and playout contracts").dependOn(&b.addRunArtifact(tests).step);
    b.step("core-check", "Compile pure kernels without platform audio or TLS").dependOn(&tests.step);
    const dependency = b.dependency("miniaudio_zig", .{ .target = target, .optimize = optimize });
    const consumer = b.addTest(.{ .root_module = b.createModule(.{
        .root_source_file = b.path("tests/dependency.zig"),
        .target = target,
        .optimize = optimize,
        .imports = &.{.{ .name = "miniaudio", .module = dependency.module("miniaudio") }},
    }) });
    b.step("dependency-test", "Exercise the real linked audio package without physical I/O").dependOn(&b.addRunArtifact(consumer).step);
    const check = b.step("check", "Compile both test artifacts for the selected target");
    check.dependOn(&tests.step);
    check.dependOn(&consumer.step);
    const audio_host = b.addModule("audio_host", .{
        .root_source_file = b.path("src/audio_device.zig"),
        .target = target,
        .optimize = optimize,
        .imports = &.{ .{ .name = "lan_audio", .module = core }, .{ .name = "miniaudio", .module = dependency.module("miniaudio") } },
    });
    const callback_tests = b.addTest(.{ .root_module = b.createModule(.{
        .root_source_file = b.path("tests/audio_device.zig"),
        .target = target,
        .optimize = optimize,
        .imports = &.{.{ .name = "audio_host", .module = audio_host }},
    }) });
    b.step("audio-test", "Exercise actual callbacks on the explicit silent backend").dependOn(&b.addRunArtifact(callback_tests).step);
    b.step("audio-check", "Compile the audio adapter and null-backend test").dependOn(&callback_tests.step);
    if (target.result.os.tag == .windows) {
        const capture_test = b.addTest(.{ .root_module = b.createModule(.{
            .root_source_file = b.path("tests/windows_capture.zig"),
            .target = target,
            .optimize = optimize,
            .imports = &.{ .{ .name = "audio_host", .module = audio_host }, .{ .name = "lan_audio", .module = core } },
        }) });
        b.step("capture-test", "Explicitly capture and discard a short Windows system-output sample").dependOn(&b.addRunArtifact(capture_test).step);
    }
    if (b.option(bool, "transport-tests", "Build the Windows loopback TLS media probe") orelse false) {
        if (target.result.os.tag != .windows or target.result.cpu.arch != .x86_64)
            @panic("TLS media qualification currently requires Windows x86_64");
        const transport = b.dependency("tls_zig", .{ .target = target, .optimize = optimize });
        const probe_module = b.createModule(.{
            .root_source_file = b.path("tests/tls_probe.zig"),
            .target = target,
            .optimize = optimize,
            .imports = &.{ .{ .name = "lan_audio", .module = core }, .{ .name = "tls", .module = transport.module("tls") }, .{ .name = "audio_host", .module = audio_host } },
            .link_libc = true,
        });
        // Reuse the TLS owner's test-only Winsock adapter: loopback address, bounded
        // connect/poll, forced short sends/receives. Its bytes are in transport-lock.
        probe_module.addCSourceFile(.{ .file = transport.path("examples/consumer/socket.c"), .flags = &.{ "-Wall", "-Wextra", "-Werror" } });
        probe_module.linkSystemLibrary("ws2_32", .{});
        const probe = b.addExecutable(.{ .name = "audio-tls-probe", .root_module = probe_module });
        const install = b.step("transport-probe", "Install the synthetic-audio TLS loopback probe");
        install.dependOn(&b.addInstallArtifact(probe, .{}).step);
        for ([_][]const u8{ "libssl-3-x64.dll", "libcrypto-3-x64.dll" }) |name|
            install.dependOn(&b.addInstallBinFile(transport.namedLazyPath("runtime").path(b, name), name).step);
    }
}
