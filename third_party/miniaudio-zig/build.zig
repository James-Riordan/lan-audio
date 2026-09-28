//! Builds a single, pinned low-level miniaudio ABI. Translation and C compilation
//! consume the same profile header; mixing profiles would invalidate struct layout.
//! No downloads, device discovery, or application policy occurs during the build.
const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});
    const null_only = b.option(bool, "null-backend", "Compile only the silent test backend") orelse false;
    // Negative qualification affects only the independent C test probe, never
    // the production library or translated public module.
    const abi_fault = b.option(enum { none, size, profile }, "abi-test-fault", "Inject a test-only ABI mismatch (none, size, profile)") orelse .none;
    switch (target.result.os.tag) {
        .windows, .linux, .macos => {},
        else => @panic("miniaudio-zig: target profile not defined"),
    }
    const native = b.addLibrary(.{ .name = "miniaudio", .linkage = .static, .root_module = b.createModule(.{
        .target = target,
        .optimize = optimize,
        .link_libc = true,
    }) });
    native.root_module.addIncludePath(b.path("vendor/miniaudio"));
    native.root_module.addCSourceFile(.{ .file = b.path("src/native.c"), .flags = &.{"-std=c99"} });
    const translated = b.addTranslateC(.{ .root_source_file = b.path("src/profile.h"), .target = target, .optimize = optimize });
    translated.addIncludePath(b.path("vendor/miniaudio"));
    if (null_only) {
        native.root_module.addCMacro("MA_ENABLE_ONLY_SPECIFIC_BACKENDS", "");
        native.root_module.addCMacro("MA_ENABLE_NULL", "");
        translated.defineCMacro("MA_ENABLE_ONLY_SPECIFIC_BACKENDS", null);
        translated.defineCMacro("MA_ENABLE_NULL", null);
    }
    switch (target.result.os.tag) {
        .windows => native.root_module.linkSystemLibrary("ole32", .{}),
        .linux => {
            for ([_][]const u8{ "m", "pthread", "dl" }) |name| native.root_module.linkSystemLibrary(name, .{});
        },
        .macos => {
            native.root_module.linkFramework("CoreFoundation", .{});
            native.root_module.linkFramework("CoreAudio", .{});
            native.root_module.linkFramework("AudioToolbox", .{});
        },
        else => unreachable,
    }
    const module = b.addModule("miniaudio", .{
        .root_source_file = b.path("src/root.zig"),
        .target = target,
        .optimize = optimize,
    });
    module.addImport("miniaudio_c", translated.createModule());
    module.linkLibrary(native);
    b.installArtifact(native);
    const tests = b.addTest(.{ .root_module = b.createModule(.{
        .root_source_file = b.path("tests/contract.zig"),
        .target = target,
        .optimize = optimize,
        .imports = &.{.{ .name = "miniaudio", .module = module }},
    }) });
    const abi_tests = b.addTest(.{ .root_module = b.createModule(.{
        .root_source_file = b.path("tests/abi.zig"),
        .target = target,
        .optimize = optimize,
        .link_libc = true,
        .imports = &.{.{ .name = "miniaudio", .module = module }},
    }) });
    abi_tests.root_module.addIncludePath(b.path("src"));
    abi_tests.root_module.addIncludePath(b.path("vendor/miniaudio"));
    abi_tests.root_module.addCSourceFile(.{ .file = b.path("tests/abi_probe.c"), .flags = &.{"-std=c99"} });
    if (null_only) {
        abi_tests.root_module.addCMacro("MA_ENABLE_ONLY_SPECIFIC_BACKENDS", "");
        abi_tests.root_module.addCMacro("MA_ENABLE_NULL", "");
    }
    switch (abi_fault) {
        .none => {},
        .size => abi_tests.root_module.addCMacro("MZ_ABI_SIZE_FAULT", "1"),
        // This documented upstream macro changes ma_device/ma_device_info layout.
        .profile => abi_tests.root_module.addCMacro("MA_MAX_DEVICE_NAME_LENGTH", "511"),
    }
    const run_abi = b.addRunArtifact(abi_tests);
    // Explicit test requests execute against current binaries; compilation can
    // remain cached. This prevents historical test success from masquerading as
    // a fresh qualification run.
    run_abi.has_side_effects = true;
    const run_contract = b.addRunArtifact(tests);
    run_contract.has_side_effects = true;
    b.step("check-abi", "Compile independent C/Zig ABI probes without device access").dependOn(&abi_tests.step);
    b.step("test-abi", "Run independent C/Zig layout and callback ABI probes").dependOn(&run_abi.step);
    const check = b.step("check", "Compile API and ABI contract tests without opening a device");
    check.dependOn(&tests.step);
    check.dependOn(&abi_tests.step);
    const test_step = b.step("test", "Run independent ABI, PCM and explicit null-backend tests");
    test_step.dependOn(&run_contract.step);
    test_step.dependOn(&run_abi.step);
}
