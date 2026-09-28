//! Core, native callback and explicit hardware/transport qualification steps.
//! Physical capture runs only under capture-test; ordinary tests use no device.
const std = @import("std");
pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});
    const core = b.addModule("lan_audio", .{ .root_source_file = b.path("src/root.zig"), .target = target, .optimize = optimize });
    // Private project helper: available to its tests/consumer, not a new package
    // or an added public core export. Native workers can import this same module.
    const pending = b.createModule(.{
        .root_source_file = b.path("src/runtime/pending_block.zig"),
        .target = target,
        .optimize = optimize,
        .imports = &.{.{ .name = "lan_audio", .module = core }},
    });
    const tests = b.addTest(.{ .root_module = b.createModule(.{
        .root_source_file = b.path("tests/unit/core.zig"),
        .target = target,
        .optimize = optimize,
        .imports = &.{ .{ .name = "lan_audio", .module = core }, .{ .name = "pending_audio", .module = pending } },
    }) });
    const test_step = b.step("test", "Run pure session, admission, playout and lifecycle contracts");
    test_step.dependOn(&b.addRunArtifact(tests).step);
    b.step("core-check", "Compile pure kernels without platform audio or TLS").dependOn(&tests.step);
    // Private lifecycle ledger: test callers exercise actual production logic.
    const lifecycle = b.createModule(.{ .root_source_file = b.path("src/runtime/lifecycle.zig"), .target = target, .optimize = optimize });
    const receive_drain = b.createModule(.{
        .root_source_file = b.path("src/runtime/receive_drain.zig"),
        .target = target,
        .optimize = optimize,
        .imports = &.{ .{ .name = "lan_audio", .module = core }, .{ .name = "pending_audio", .module = pending }, .{ .name = "lifecycle", .module = lifecycle } },
    });
    const send_drain = b.createModule(.{
        .root_source_file = b.path("src/runtime/send_drain.zig"),
        .target = target,
        .optimize = optimize,
        .imports = &.{ .{ .name = "lan_audio", .module = core }, .{ .name = "lifecycle", .module = lifecycle } },
    });
    const lifecycle_tests = b.addTest(.{ .root_module = b.createModule(.{
        .root_source_file = b.path("tests/integration/runtime_lifecycle.zig"),
        .target = target,
        .optimize = optimize,
        .imports = &.{ .{ .name = "lifecycle", .module = lifecycle }, .{ .name = "lan_audio", .module = core }, .{ .name = "receive_drain", .module = receive_drain }, .{ .name = "send_drain", .module = send_drain } },
    }) });
    const lifecycle_run = b.addRunArtifact(lifecycle_tests);
    lifecycle_run.has_side_effects = true; // A requested qualification executes.
    b.step("lifecycle-test", "Run real lifecycle controller against independent fake owners").dependOn(&lifecycle_run.step);
    b.step("lifecycle-check", "Compile lifecycle/fake-owner contracts for the selected target").dependOn(&lifecycle_tests.step);
    test_step.dependOn(&lifecycle_run.step);
    const codec_probe = b.addLibrary(.{ .name = "audio-v2-codec-probe", .linkage = .dynamic, .root_module = b.createModule(.{
        .root_source_file = b.path("tests/integration/v2_codec_probe.zig"),
        .target = target,
        .optimize = optimize,
        .imports = &.{.{ .name = "lan_audio", .module = core }},
    }) });
    b.step("v2-codec-probe", "Install test-only C ABI for the independent v2 oracle").dependOn(&b.addInstallArtifact(codec_probe, .{}).step);
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
    check.dependOn(&lifecycle_tests.step);
    check.dependOn(&consumer.step);
    const audio_host = b.addModule("audio_host", .{
        .root_source_file = b.path("src/host/audio_device.zig"),
        .target = target,
        .optimize = optimize,
        .imports = &.{ .{ .name = "lan_audio", .module = core }, .{ .name = "miniaudio", .module = dependency.module("miniaudio") } },
    });
    const callback_tests = b.addTest(.{ .root_module = b.createModule(.{
        .root_source_file = b.path("tests/integration/audio_device.zig"),
        .target = target,
        .optimize = optimize,
        .imports = &.{.{ .name = "audio_host", .module = audio_host }},
    }) });
    b.step("audio-test", "Exercise actual callbacks on the explicit silent backend").dependOn(&b.addRunArtifact(callback_tests).step);
    b.step("audio-check", "Compile the audio adapter and null-backend test").dependOn(&callback_tests.step);
    if (target.result.os.tag == .windows) {
        const capture_test = b.addTest(.{ .root_module = b.createModule(.{
            .root_source_file = b.path("tests/hardware/windows_capture.zig"),
            .target = target,
            .optimize = optimize,
            .imports = &.{ .{ .name = "audio_host", .module = audio_host }, .{ .name = "lan_audio", .module = core } },
        }) });
        b.step("capture-test", "Explicitly capture and discard a short Windows system-output sample").dependOn(&b.addRunArtifact(capture_test).step);
        b.step("capture-check", "Compile the explicit physical capture fixture without opening devices").dependOn(&capture_test.step);
    }
    if (b.option(bool, "transport-tests", "Build the Windows loopback TLS media probe") orelse false) {
        if (target.result.os.tag != .windows or target.result.cpu.arch != .x86_64)
            @panic("TLS media qualification currently requires Windows x86_64");
        const transport = b.dependency("tls_zig", .{ .target = target, .optimize = optimize });
        const probe_module = b.createModule(.{
            .root_source_file = b.path("tests/integration/tls_receiver.zig"),
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
        const v2_install = b.step("v2-transport-probes", "Install test-only v2 application sender/receiver TLS clients");
        for ([_]bool{ true, false }) |is_sender| {
            const options = b.addOptions();
            options.addOption(bool, "sender", is_sender);
            const module = b.createModule(.{
                .root_source_file = b.path("tests/integration/tls_v2.zig"),
                .target = target,
                .optimize = optimize,
                .imports = &.{ .{ .name = "lan_audio", .module = core }, .{ .name = "pending_audio", .module = pending }, .{ .name = "tls", .module = transport.module("tls") }, .{ .name = "probe_options", .module = options.createModule() } },
                .link_libc = true,
            });
            module.addCSourceFile(.{ .file = transport.path("examples/consumer/socket.c"), .flags = &.{ "-Wall", "-Wextra", "-Werror" } });
            module.linkSystemLibrary("ws2_32", .{});
            const executable = b.addExecutable(.{ .name = if (is_sender) "audio-v2-sender-probe" else "audio-v2-receiver-probe", .root_module = module });
            v2_install.dependOn(&b.addInstallArtifact(executable, .{}).step);
        }
        for ([_][]const u8{ "libssl-3-x64.dll", "libcrypto-3-x64.dll" }) |name|
            v2_install.dependOn(&b.addInstallBinFile(transport.namedLazyPath("runtime").path(b, name), name).step);
    }
}
