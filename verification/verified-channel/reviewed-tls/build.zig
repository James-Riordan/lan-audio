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
    // Portable data/ownership primitives. No native provider dependency is imported.
    const quic = b.addModule("tls_quic", .{ .root_source_file = b.path("src/quic.zig"), .target = target, .optimize = optimize });
    const quic_step = b.step("quic-test", "Run recordless contract and event custody tests");
    for ([_][]const u8{ "tests/quic/contract.zig", "tests/quic/events.zig" }) |path| {
        const test_module = b.createModule(.{ .root_source_file = b.path(path), .target = target, .optimize = optimize, .imports = &.{.{ .name = "tls_quic", .module = quic }} });
        const artifact = b.addTest(.{ .root_module = test_module });
        quic_step.dependOn(&b.addRunArtifact(artifact).step);
    }
    // Internal queue tests also discover the imported contract counter test.
    for ([_][]const u8{"src/quic/events.zig"}) |path| {
        const artifact = b.addTest(.{ .root_module = b.createModule(.{ .root_source_file = b.path(path), .target = target, .optimize = optimize }) });
        quic_step.dependOn(&b.addRunArtifact(artifact).step);
    }
    const openssl = b.option([]const u8, "openssl-root", "Read-only OpenSSL installation (include and lib)");
    const openssl_include: std.Build.LazyPath = if (openssl) |root| .{ .cwd_relative = b.pathJoin(&.{ root, "include" }) } else b.path("deps/openssl-install/include");
    const openssl_lib: std.Build.LazyPath = if (openssl) |root| .{ .cwd_relative = b.pathJoin(&.{ root, "lib" }) } else b.path("deps/openssl-install/lib");
    const openssl_bin: std.Build.LazyPath = if (openssl) |root| .{ .cwd_relative = b.pathJoin(&.{ root, "bin" }) } else b.path("deps/openssl-install/bin");
    const native_abi = b.createModule(.{ .root_source_file = b.path("src/backend/quic.zig"), .target = target, .optimize = optimize });
    const quic_engine = b.addModule("tls_quic_engine", .{ .root_source_file = b.path("src/quic_engine.zig"), .target = target, .optimize = optimize, .link_libc = true, .imports = &.{ .{ .name = "tls_quic", .module = quic }, .{ .name = "quic_native_abi", .module = native_abi } } });
    quic_engine.addIncludePath(b.path("src"));
    quic_engine.addSystemIncludePath(openssl_include);
    quic_engine.addObjectFile(openssl_lib.path(b, "libssl.dll.a"));
    quic_engine.addObjectFile(openssl_lib.path(b, "libcrypto.dll.a"));
    quic_engine.addCSourceFile(.{ .file = b.path("src/backend/quic.c"), .flags = &.{ "-std=c11", "-Wall", "-Wextra", "-Werror" } });
    const engine_test_mod = b.createModule(.{ .root_source_file = b.path("tests/quic_contract.zig"), .target = target, .optimize = optimize, .imports = &.{.{ .name = "tls_quic_engine", .module = quic_engine }} });
    engine_test_mod.addSystemIncludePath(openssl_include);
    engine_test_mod.addCSourceFile(.{ .file = b.path("tests/quic/reference_peer.c"), .flags = &.{ "-std=c11", "-Wall", "-Wextra", "-Werror" } });
    const engine_test = b.addTest(.{ .root_module = engine_test_mod });
    const run_engine = std.Build.Step.Run.create(b, "native recordless Engine conformance");
    run_engine.addFileArg(staged(b, engine_test, openssl_bin, "quic-engine-test.exe"));
    run_engine.setCwd(b.path("."));
    b.step("quic-engine-test", "Run native recordless Engine conformance").dependOn(&run_engine.step);
    const backend_step = b.step("quic-backend-test", "Run native recordless ABI and callback adapter qualification");
    const backend_test_mod = b.createModule(.{ .target = target, .optimize = optimize, .link_libc = true });
    backend_test_mod.addIncludePath(b.path("src"));
    backend_test_mod.addSystemIncludePath(openssl_include);
    backend_test_mod.addObjectFile(openssl_lib.path(b, "libssl.dll.a"));
    backend_test_mod.addObjectFile(openssl_lib.path(b, "libcrypto.dll.a"));
    for ([_][]const u8{ "src/backend/quic.c", "tests/quic/backend.c" }) |path| {
        backend_test_mod.addCSourceFile(.{ .file = b.path(path), .flags = &.{ "-std=c11", "-Wall", "-Wextra", "-Werror", "-DTLSQ_TESTING" } });
    }
    const backend_test_exe = b.addExecutable(.{ .name = "quic-backend-test", .root_module = backend_test_mod });
    const backend_test_bin = staged(b, backend_test_exe, openssl_bin, "quic-backend-test.exe");
    for ([_][]const u8{ "full", "fragmented", "backpressure", "combined", "mutual", "missing-client", "wrong-host", "wrong-ca", "alpn", "fail-send", "fail-receive", "fail-release", "fail-secret", "fail-params", "fail-alert", "budgeted", "zero-budget", "overconsume", "overlease", "null-lease", "params-overflow", "reentrant", "validation", "config-copy", "ip" }) |scenario| {
        const run_backend = std.Build.Step.Run.create(b, b.fmt("recordless adapter {s}", .{scenario}));
        run_backend.addFileArg(backend_test_bin);
        run_backend.addArg(scenario);
        run_backend.addDirectoryArg(b.path("tests/fixtures"));
        run_backend.setCwd(b.path("."));
        backend_step.dependOn(&run_backend.step);
    }
    const abi_mod = b.createModule(.{ .root_source_file = b.path("tests/quic/backend_abi.zig"), .target = target, .optimize = optimize, .link_libc = true, .imports = &.{.{ .name = "quic_native_abi", .module = native_abi }} });
    abi_mod.addIncludePath(b.path("src"));
    abi_mod.addSystemIncludePath(openssl_include);
    abi_mod.addObjectFile(openssl_lib.path(b, "libssl.dll.a"));
    abi_mod.addObjectFile(openssl_lib.path(b, "libcrypto.dll.a"));
    for ([_][]const u8{ "src/backend/quic.c", "tests/quic/backend_abi.c" }) |path| {
        abi_mod.addCSourceFile(.{ .file = b.path(path), .flags = &.{ "-std=c11", "-Wall", "-Wextra", "-Werror" } });
    }
    const abi_test = b.addTest(.{ .root_module = abi_mod });
    const run_abi = std.Build.Step.Run.create(b, "native recordless C and Zig ABI");
    run_abi.addFileArg(staged(b, abi_test, openssl_bin, "quic-backend-abi.exe"));
    run_abi.setCwd(b.path("."));
    backend_step.dependOn(&run_abi.step);
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
