const std = @import("std");
pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});
    const dep = b.dependency("tls_zig", .{ .target = target, .optimize = optimize });
    const exe = b.addExecutable(.{ .name = "recordless-consumer", .root_module = b.createModule(.{
        .root_source_file = b.path("main.zig"),
        .target = target,
        .optimize = optimize,
        .imports = &.{.{ .name = "tls", .module = dep.module("tls_quic_engine") }},
    }) });
    b.installArtifact(exe);
    const files = b.addWriteFiles();
    for ([_][]const u8{ "libssl-3-x64.dll", "libcrypto-3-x64.dll" }) |name| {
        const runtime = dep.namedLazyPath("runtime").path(b, name);
        _ = files.addCopyFile(runtime, name);
        b.getInstallStep().dependOn(&b.addInstallBinFile(runtime, name).step);
    }
    const run = std.Build.Step.Run.create(b, "external recordless consumer");
    run.addFileArg(files.addCopyFile(exe.getEmittedBin(), "recordless-consumer.exe"));
    run.setCwd(dep.path("."));
    // Runtime fixture inputs are tracked even though main uses stable relative paths.
    run.addDirectoryArg(dep.path("tests/fixtures"));
    b.step("run", "Authenticate a recordless pair through the production public module").dependOn(&run.step);
}
