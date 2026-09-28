const std = @import("std");
pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});
    const dep = b.dependency("tls_zig", .{ .target = target, .optimize = optimize });
    const module = b.createModule(.{ .root_source_file = b.path("main.zig"), .target = target, .optimize = optimize, .imports = &.{.{ .name = "tls_quic", .module = dep.module("tls_quic") }} });
    const exe = b.addExecutable(.{ .name = "quic-contract-consumer", .root_module = module });
    b.installArtifact(exe);
    b.step("run", "Run fixture with exported contract and real event queue").dependOn(&b.addRunArtifact(exe).step);
}
