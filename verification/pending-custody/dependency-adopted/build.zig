// Engineering contract (2026-09-26)
// Build graph and public module/runtime export definition.
// File contract: docs/reference/files/build.zig.md
// Ownership and invariant: Exports tls and runtime; links private Windows DLL import libraries,
// stages DLLs beside executables and provides test/host-test/interop/example steps. Standard
// target options do not establish non-Windows support.
// Next implementation obligation: Verify a clean external consumer whenever exported modules,
// runtime paths or package closure change. Add explicit documented steps for new suites; do not
// leave test files unreachable.

const std = @import("std");
fn staged(b: *std.Build, artifact: *std.Build.Step.Compile, bin: std.Build.LazyPath, name: []const u8) std.Build.LazyPath {
    const files = b.addWriteFiles();
    _ = files.addCopyFile(bin.path(b, "libssl-3-x64.dll"), "libssl-3-x64.dll");
    _ = files.addCopyFile(bin.path(b, "libcrypto-3-x64.dll"), "libcrypto-3-x64.dll");
    return files.addCopyFile(artifact.getEmittedBin(), name);
}
pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});
    const openssl = b.option([]const u8, "openssl-root", "Read-only OpenSSL installation (include and lib)");
    const openssl_include: std.Build.LazyPath = if (openssl) |root| .{ .cwd_relative = b.pathJoin(&.{ root, "include" }) } else b.path("deps/openssl-install/include");
    const openssl_lib: std.Build.LazyPath = if (openssl) |root| .{ .cwd_relative = b.pathJoin(&.{ root, "lib" }) } else b.path("deps/openssl-install/lib");
    const openssl_bin: std.Build.LazyPath = if (openssl) |root| .{ .cwd_relative = b.pathJoin(&.{ root, "bin" }) } else b.path("deps/openssl-install/bin");
    b.addNamedLazyPath("runtime", openssl_bin);
    const mod = b.addModule("tls", .{ .root_source_file = b.path("src/root.zig"), .target = target, .optimize = optimize, .link_libc = true });
    mod.addIncludePath(b.path("src"));
    mod.addSystemIncludePath(openssl_include);
    // Select the DLL import archives explicitly; -lssl can pick libssl.a instead.
    mod.addObjectFile(openssl_lib.path(b, "libssl.dll.a"));
    mod.addObjectFile(openssl_lib.path(b, "libcrypto.dll.a"));
    mod.addCSourceFile(.{ .file = b.path("src/backend.c"), .flags = &.{ "-std=c11", "-Wall", "-Wextra", "-Werror" } });
    const test_mod = b.createModule(.{ .root_source_file = b.path("tests/transport.zig"), .target = target, .optimize = optimize, .imports = &.{.{ .name = "tls", .module = mod }} });
    const test_exe = b.addTest(.{ .root_module = test_mod });
    const tests = std.Build.Step.Run.create(b, "run staged TLS tests");
    tests.addFileArg(staged(b, test_exe, openssl_bin, "test.exe"));
    tests.setCwd(b.path("."));
    b.step("test", "Run TLS transport tests").dependOn(&tests.step);
    const host_test_mod = b.createModule(.{ .root_source_file = b.path("tests/driver.zig"), .target = target, .optimize = optimize, .imports = &.{.{ .name = "tls", .module = mod }} });
    const host_test_exe = b.addTest(.{ .root_module = host_test_mod });
    const host_tests = std.Build.Step.Run.create(b, "run host driver tests");
    host_tests.addFileArg(staged(b, host_test_exe, openssl_bin, "host-test.exe"));
    host_tests.setCwd(b.path("."));
    b.step("host-test", "Run nonblocking host driver regressions").dependOn(&host_tests.step);
    const exe = b.addExecutable(.{ .name = "tls-example", .root_module = b.createModule(.{
        .root_source_file = b.path("examples/roundtrip.zig"),
        .target = target,
        .optimize = optimize,
        .imports = &.{.{ .name = "tls", .module = mod }},
    }) });
    b.installArtifact(exe);
    b.getInstallStep().dependOn(&b.addInstallBinFile(openssl_bin.path(b, "libssl-3-x64.dll"), "libssl-3-x64.dll").step);
    b.getInstallStep().dependOn(&b.addInstallBinFile(openssl_bin.path(b, "libcrypto-3-x64.dll"), "libcrypto-3-x64.dll").step);
    const run = std.Build.Step.Run.create(b, "run staged TLS example");
    run.addFileArg(staged(b, exe, openssl_bin, "tls-example.exe"));
    run.setCwd(b.path("."));
    b.step("example", "TLS 1.3 authenticated HTTP roundtrip without sockets").dependOn(&run.step);
    // Test-only C ABI exposes the exact same backend to Python's independent TLS peer.
    const interop_mod = b.createModule(.{ .target = target, .optimize = optimize, .link_libc = true });
    interop_mod.addSystemIncludePath(openssl_include);
    interop_mod.addObjectFile(openssl_lib.path(b, "libssl.dll.a"));
    interop_mod.addObjectFile(openssl_lib.path(b, "libcrypto.dll.a"));
    interop_mod.addCSourceFile(.{ .file = b.path("src/backend.c"), .flags = &.{ "-std=c11", "-Wall", "-Wextra", "-Werror" } });
    const interop_lib = b.addLibrary(.{ .name = "tls-test-backend", .linkage = .dynamic, .root_module = interop_mod });
    interop_lib.rdynamic = true;
    const interop = b.addSystemCommand(&.{ "python", "tools/interop.py" });
    interop.addFileArg(staged(b, interop_lib, openssl_bin, "tls-test-backend.dll"));
    interop.setCwd(b.path("."));
    b.step("interop", "Qualify both roles against Python ssl with a distinct OpenSSL build").dependOn(&interop.step);
}
