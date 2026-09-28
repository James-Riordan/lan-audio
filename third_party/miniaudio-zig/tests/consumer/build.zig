//! Independent package caller: only the public miniaudio dependency is imported.
//! No private root, native C file, SDK include or ABI probe is linked directly.
const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});
    const null_only = b.option(bool, "null-backend", "Use the dependency's silent-only profile") orelse false;
    const dependency = b.dependency("miniaudio_zig", .{
        .target = target,
        .optimize = optimize,
        .@"null-backend" = null_only,
    });
    const tests = b.addTest(.{ .root_module = b.createModule(.{
        .root_source_file = b.path("consumer.zig"),
        .target = target,
        .optimize = optimize,
        .imports = &.{.{ .name = "miniaudio", .module = dependency.module("miniaudio") }},
    }) });
    const run = b.addRunArtifact(tests);
    run.has_side_effects = true;
    b.step("test", "Exercise the public package and linked C implementation without a device").dependOn(&run.step);
    b.step("check", "Compile the public package consumer without executing it").dependOn(&tests.step);
}
