//! Builds the pure audio-session kernel and an independent miniaudio consumer.
//! There is deliberately no executable that claims to stream before transport
//! admission, device integration and platform qualification have been completed.
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
}
