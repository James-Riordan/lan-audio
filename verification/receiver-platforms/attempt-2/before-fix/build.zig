//! Core, native callback and explicit hardware/transport qualification steps.
//! Physical capture runs only under capture-test; ordinary tests use no device.
const std = @import("std");
pub fn build(b: *std.Build) void {
    var target = b.standardTargetOptions(.{});
    // Monterey is the receiver compatibility baseline, independent of the SDK
    // used to compile. Explicit -Dtarget OS version ranges remain authoritative.
    if (target.result.os.tag == .macos and target.query.os_version_min == null) {
        var query = target.query;
        query.os_version_min = .{ .semver = .{ .major = 12, .minor = 0, .patch = 0 } };
        target = b.resolveTargetQuery(query);
    }
    const optimize = b.standardOptimizeOption(.{});
    const network = b.addModule("network_host", .{
        .root_source_file = b.path("src/host/net/socket.zig"),
        .target = target,
        .optimize = optimize,
        .link_libc = true,
    });
    const network_c = b.addTranslateC(.{ .root_source_file = b.path("src/host/net/native.h"), .target = target, .optimize = optimize });
    network.addImport("network_c", network_c.createModule());
    network.addIncludePath(b.path("src/host/net"));
    network.addCSourceFile(.{ .file = b.path("src/host/net/native.c"), .flags = &.{ "-std=c11", "-Wall", "-Wextra", "-Werror" } });
    if (target.result.os.tag == .windows) network.linkSystemLibrary("ws2_32", .{});
    const network_tests = b.addTest(.{ .root_module = b.createModule(.{
        .root_source_file = b.path("tests/integration/network_host.zig"),
        .target = target,
        .optimize = optimize,
        .imports = &.{.{ .name = "network_host", .module = network }},
    }) });
    const network_run = b.addRunArtifact(network_tests);
    network_run.has_side_effects = true;
    b.step("network-test", "Exercise real nonblocking TCP ownership without TLS or audio").dependOn(&network_run.step);
    b.step("network-check", "Compile the native network owner for the selected target").dependOn(&network_tests.step);
    const core = b.addModule("lan_audio", .{ .root_source_file = b.path("src/root.zig"), .target = target, .optimize = optimize });
    const peer_policy = b.createModule(.{
        .root_source_file = b.path("src/security/peer_policy.zig"),
        .target = target,
        .optimize = optimize,
        .imports = &.{.{ .name = "lan_audio", .module = core }},
    });
    const channel_admission = b.createModule(.{
        .root_source_file = b.path("src/runtime/channel_admission.zig"),
        .target = target,
        .optimize = optimize,
        .imports = &.{ .{ .name = "lan_audio", .module = core }, .{ .name = "peer_policy", .module = peer_policy } },
    });
    const policy_tests = b.addTest(.{ .root_module = b.createModule(.{
        .root_source_file = b.path("tests/integration/peer_policy.zig"),
        .target = target,
        .optimize = optimize,
        .imports = &.{ .{ .name = "lan_audio", .module = core }, .{ .name = "peer_policy", .module = peer_policy }, .{ .name = "channel_admission", .module = channel_admission } },
    }) });
    const policy_run = b.addRunArtifact(policy_tests);
    policy_run.has_side_effects = true;
    b.step("policy-test", "Exercise copied peer policy and idempotent channel admission").dependOn(&policy_run.step);
    b.step("policy-check", "Compile shared peer policy for the selected target").dependOn(&policy_tests.step);
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
    const app = b.addExecutable(.{ .name = "lan-audio", .root_module = b.createModule(.{
        .root_source_file = b.path("src/app/main.zig"),
        .target = target,
        .optimize = optimize,
        .imports = &.{.{ .name = "audio_host", .module = audio_host }},
    }) });
    b.step("app", "Install the foreground device-inspection command").dependOn(&b.addInstallArtifact(app, .{}).step);
    const app_run = b.addRunArtifact(app);
    if (b.args) |args| app_run.addArgs(args);
    b.step("run", "Run the foreground device-inspection command").dependOn(&app_run.step);
    const callback_tests = b.addTest(.{ .root_module = b.createModule(.{
        .root_source_file = b.path("tests/integration/audio_device.zig"),
        .target = target,
        .optimize = optimize,
        .imports = &.{.{ .name = "audio_host", .module = audio_host }},
    }) });
    const host_contract_tests = b.addTest(.{ .root_module = audio_host });
    const audio_test_step = b.step("audio-test", "Exercise selection contracts and callbacks on the explicit silent backend");
    const callback_run = b.addRunArtifact(callback_tests);
    callback_run.has_side_effects = true;
    audio_test_step.dependOn(&callback_run.step);
    const host_contract_run = b.addRunArtifact(host_contract_tests);
    host_contract_run.has_side_effects = true;
    audio_test_step.dependOn(&host_contract_run.step);
    const audio_check_step = b.step("audio-check", "Compile audio selection contracts and null-backend tests");
    audio_check_step.dependOn(&callback_tests.step);
    audio_check_step.dependOn(&host_contract_tests.step);
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
