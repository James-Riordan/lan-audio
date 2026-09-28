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
    const policy_object = b.addTest(.{ .name = "peer-policy-object", .root_module = policy_tests.root_module, .emit_object = true });
    b.step("policy-object-check", "Compile policy test code without SDK linking or execution").dependOn(&policy_object.step);
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
    const core_run = b.addRunArtifact(tests);
    core_run.has_side_effects = true;
    test_step.dependOn(&core_run.step);
    const recovery_tests = b.addTest(.{ .root_module = b.createModule(.{ .root_source_file = b.path("src/runtime/recovery_policy.zig"), .target = target, .optimize = optimize }) });
    const recovery_run = b.addRunArtifact(recovery_tests);
    recovery_run.has_side_effects = true;
    test_step.dependOn(&recovery_run.step);
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
    const transport_tests = b.option(bool, "transport-tests", "Build the Windows loopback TLS media probe") orelse false;
    const streaming = b.option(bool, "streaming", "Build authenticated live audio commands") orelse (target.result.os.tag == .windows and target.result.cpu.arch == .x86_64);
    const mac_openssl = b.option([]const u8, "mac-openssl-root", "Explicit Monterey-compatible static OpenSSL SDK (include and lib)");
    const native_audio_supported = switch (target.result.os.tag) {
        .windows, .macos, .linux => true,
        else => false,
    };
    if (!native_audio_supported) {
        // Portable checks do not configure an unavailable native dependency.
        // Named native steps still fail explicitly; no unsupported success stub.
        const unavailable = b.addFail("Native audio/application profile is not implemented for this target. Shared core, policy and lifecycle checks remain available.");
        for ([_][]const u8{ "audio-test", "audio-check", "dependency-test", "app", "run", "check" }) |name|
            b.step(name, "Unavailable native audio/application target").dependOn(&unavailable.step);
        if (transport_tests) {
            b.step("transport-probe", "Unavailable native transport probe").dependOn(&unavailable.step);
            b.step("v2-transport-probes", "Unavailable native transport probes").dependOn(&unavailable.step);
            b.step("verified-transport-probe", "Unavailable native verified transport probe").dependOn(&unavailable.step);
        }
        return;
    }
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
    const app_options = b.addOptions();
    app_options.addOption(bool, "streaming", streaming);
    app.root_module.addOptions("app_options", app_options);
    const app_step = b.step("app", "Install the foreground audio application");
    app_step.dependOn(&b.addInstallArtifact(app, .{}).step);
    const app_run = std.Build.Step.Run.create(b, "Run installed LAN Audio");
    const app_files = b.addWriteFiles();
    app_run.addFileArg(app_files.addCopyFile(app.getEmittedBin(), app.out_filename));
    app_run.addPassthruArgs();
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
    if (streaming or transport_tests) {
        const windows = target.result.os.tag == .windows and target.result.cpu.arch == .x86_64;
        const mac = target.result.os.tag == .macos and target.result.cpu.arch == .x86_64;
        if (!windows and !mac) @panic("Live desktop streaming currently requires Windows x86_64 or Intel macOS");
        if (transport_tests and !windows) @panic("Public fixture transport probes currently require Windows x86_64");
        if (mac and mac_openssl == null) @panic("Intel Mac streaming requires -Dmac-openssl-root pointing to a reviewed static OpenSSL SDK");
        const transport = b.dependency("tls_zig", .{ .target = target, .optimize = optimize });
        // App-owned target integration of unchanged, pinned records sources.
        // The sibling's default build remains Windows-only. No dependency edits
        // or ambient OpenSSL search; Mac archives must be built for Monterey.
        const tls_module = if (mac) blk: {
            const module = b.createModule(.{ .root_source_file = transport.path("src/root.zig"), .target = target, .optimize = optimize, .link_libc = true });
            const sdk: std.Build.LazyPath = .{ .cwd_relative = mac_openssl.? };
            module.addIncludePath(transport.path("src"));
            module.addSystemIncludePath(sdk.path(b, "include"));
            module.addObjectFile(sdk.path(b, "lib/libssl.a"));
            module.addObjectFile(sdk.path(b, "lib/libcrypto.a"));
            module.addCSourceFile(.{ .file = transport.path("src/backend.c"), .flags = &.{ "-std=c11", "-Wall", "-Wextra", "-Werror" } });
            break :blk module;
        } else transport.module("tls");
        const verified = b.createModule(.{
            .root_source_file = b.path("src/host/verified_channel.zig"),
            .target = target,
            .optimize = optimize,
            .imports = &.{ .{ .name = "tls", .module = tls_module }, .{ .name = "network_host", .module = network }, .{ .name = "lan_audio", .module = core }, .{ .name = "peer_policy", .module = peer_policy }, .{ .name = "channel_admission", .module = channel_admission } },
        });
        const platform = b.createModule(.{ .root_source_file = b.path("src/host/platform.zig"), .target = target, .optimize = optimize, .link_libc = true });
        const platform_c = b.addTranslateC(.{ .root_source_file = b.path("src/host/platform.h"), .target = target, .optimize = optimize });
        platform.addImport("platform_c", platform_c.createModule());
        platform.addIncludePath(b.path("src/host"));
        platform.addCSourceFile(.{ .file = b.path("src/host/platform.c"), .flags = &.{ "-std=c11", "-Wall", "-Wextra", "-Werror" } });
        if (target.result.os.tag == .windows) platform.linkSystemLibrary("avrt", .{});
        const platform_tests = b.addTest(.{ .root_module = platform });
        const platform_run = b.addRunArtifact(platform_tests);
        platform_run.has_side_effects = true;
        b.step("platform-test", "Exercise foreground timer and signal registration lifetimes").dependOn(&platform_run.step);
        const runtime = b.createModule(.{
            .root_source_file = b.path("src/runtime/stream.zig"),
            .target = target,
            .optimize = optimize,
            .imports = &.{ .{ .name = "platform_host", .module = platform }, .{ .name = "audio_host", .module = audio_host }, .{ .name = "network_host", .module = network }, .{ .name = "verified_channel", .module = verified }, .{ .name = "peer_policy", .module = peer_policy }, .{ .name = "lan_audio", .module = core }, .{ .name = "lifecycle", .module = lifecycle }, .{ .name = "send_drain", .module = send_drain }, .{ .name = "receive_drain", .module = receive_drain } },
        });
        const supervisor = b.createModule(.{
            .root_source_file = b.path("src/runtime/session_supervisor.zig"),
            .target = target,
            .optimize = optimize,
            .imports = &.{ .{ .name = "stream_runtime", .module = runtime }, .{ .name = "platform_host", .module = platform }, .{ .name = "network_host", .module = network } },
        });
        if (streaming) {
            app.root_module.addImport("stream_runtime", runtime);
            app.root_module.addImport("session_supervisor", supervisor);
            app.root_module.addImport("platform_host", platform);
            app.root_module.addImport("peer_policy", peer_policy);
            app.root_module.addImport("lan_audio", core);
            if (windows) {
                for ([_][]const u8{ "libssl-3-x64.dll", "libcrypto-3-x64.dll" }) |name|
                    app_step.dependOn(&b.addInstallBinFile(transport.namedLazyPath("runtime").path(b, name), name).step);
                for ([_][]const u8{ "libssl-3-x64.dll", "libcrypto-3-x64.dll" }) |name|
                    _ = app_files.addCopyFile(transport.namedLazyPath("runtime").path(b, name), name);
            }
        }
        if (!transport_tests) return;
        const recovery_probe = b.addExecutable(.{ .name = "audio-recovery-probe", .root_module = b.createModule(.{
            .root_source_file = b.path("tests/integration/recovery_session.zig"),
            .target = target,
            .optimize = optimize,
            .imports = &.{ .{ .name = "stream_runtime", .module = runtime }, .{ .name = "session_supervisor", .module = supervisor }, .{ .name = "peer_policy", .module = peer_policy } },
        }) });
        const recovery_install = b.step("recovery-probe", "Install null-audio automatic recovery probe");
        recovery_install.dependOn(&b.addInstallArtifact(recovery_probe, .{}).step);
        for ([_][]const u8{ "libssl-3-x64.dll", "libcrypto-3-x64.dll" }) |name|
            recovery_install.dependOn(&b.addInstallBinFile(transport.namedLazyPath("runtime").path(b, name), name).step);
        const worker_probe = b.addExecutable(.{ .name = "audio-worker-probe", .root_module = b.createModule(.{
            .root_source_file = b.path("tests/integration/live_worker.zig"),
            .target = target,
            .optimize = optimize,
            .imports = &.{ .{ .name = "stream_runtime", .module = runtime }, .{ .name = "peer_policy", .module = peer_policy } },
        }) });
        const worker_install = b.step("worker-probe", "Install explicit null-audio live worker probe");
        worker_install.dependOn(&b.addInstallArtifact(worker_probe, .{}).step);
        for ([_][]const u8{ "libssl-3-x64.dll", "libcrypto-3-x64.dll" }) |name|
            worker_install.dependOn(&b.addInstallBinFile(transport.namedLazyPath("runtime").path(b, name), name).step);
        const verified_probe = b.addExecutable(.{ .name = "audio-verified-probe", .root_module = b.createModule(.{
            .root_source_file = b.path("tests/integration/verified_channel.zig"),
            .target = target,
            .optimize = optimize,
            .imports = &.{ .{ .name = "verified_channel", .module = verified }, .{ .name = "network_host", .module = network }, .{ .name = "lan_audio", .module = core }, .{ .name = "peer_policy", .module = peer_policy } },
        }) });
        const verified_install = b.step("verified-transport-probe", "Install real Socket/TLS/authorization integration probe; no audio device");
        verified_install.dependOn(&b.addInstallArtifact(verified_probe, .{}).step);
        for ([_][]const u8{ "libssl-3-x64.dll", "libcrypto-3-x64.dll" }) |name|
            verified_install.dependOn(&b.addInstallBinFile(transport.namedLazyPath("runtime").path(b, name), name).step);
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
