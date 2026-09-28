# miniaudio-zig

Zig bindings to pinned **miniaudio 0.11.25**, commit
`9634bedb5b5a2ca38c1ee7108a9358a4e233f14d`. This is a **Zig Lib**, named after its
upstream technology. It owns build integration and a documented low-level ABI;
it does not own network-audio sessions, pairing, product policy or Mediaz facts.

The exported module is `miniaudio`; its `c` namespace preserves upstream names,
result codes and pointer ownership. The profile includes device I/O, PCM conversion,
resampling and buffers. File decoding/encoding, resource management, node graphs
and the high-level engine are disabled in one shared header. It is not a claim
that all upstream APIs or operating systems have been qualified.

## Build and use

Exact qualification compiler: `0.17.0-dev.1859+dcceb318e`.

```powershell
python tools/check_vendor.py
zig build test -j1 --summary all
zig build test -j1 -Doptimize=ReleaseSafe --summary all
zig build check -j1 -Dtarget=x86_64-linux-gnu
```

Tests explicitly select the silent null backend; they do not capture or play audio.
The default test step includes five independent C/Zig ABI probes and the original
three adoption tests. `test-abi` runs the probes alone; `check-abi` only compiles
them. [ABI qualification](docs/verification/abi.md) documents the four-profile
matrix, actual-layout mutations and independent downstream package consumer.
The default build compiles native backend support. `-Dnull-backend=true` narrows
the compiled profile to the null backend; it must never be advertised as a physical
audio implementation. Cross-compilation is compile evidence only. macOS additionally
requires a compatible SDK/framework search environment.

A sibling package declares `.miniaudio_zig = .{ .path = "../miniaudio-zig" }` in
its `build.zig.zon`, obtains `b.dependency("miniaudio_zig", .{ .target = target,
.optimize = optimize }).module("miniaudio")`, and imports it as `miniaudio`.
The module brings the matching static C library with it. The separate consumer is
`../lan-audio/tests/dependency.zig` with build step `dependency-test`.

Read [the lifetime and mathematical contract](docs/CONTRACT.md) before opening a
device. [The complete file guide](docs/FILES.md) identifies each source and its
verification obligation. [Dependency custody](docs/DEPENDENCIES.md) covers upstream,
toolchain and platform libraries, including what remains unverified.

The [engineering handbook](docs/README.md) adds source-specific explanations,
start-time callback and enumeration ownership contracts, conversion accounting,
and concrete ABI/device qualification gates. Run `python tools/check_docs.py`
to check exact file coverage, local links, source anchors and vendor custody.

The package file list is explicit so nested caches cannot enter source distribution.
Run `python tools/test_package.py --output verification/source-package-new` to
verify actual compiler selection and an archive-derived relocated consumer.
See [source-package evidence](docs/verification/source-package.md) and the
[remaining release gates](docs/implementation/release-readiness.md).

## Status and licensing

This is an initial binding/adoption, not a production or hard-real-time certificate.
The exact executed checks are reported in
[`docs/VERIFICATION.md`](docs/VERIFICATION.md).
Device permissions, actual endpoint operation, loopback, hotplug, teardown during
live callbacks and sustained audio need platform integration tests.

Upstream retains its original dual-license text in `vendor/miniaudio/LICENSE`.
No repository-wide license for new JCR-authored files has been selected; do not
infer a redistribution grant for those files from the upstream license.
