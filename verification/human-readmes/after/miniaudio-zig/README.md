# miniaudio-zig

Use miniaudio's low-level audio APIs from Zig. This package supplies the Zig import
and matching static C library for **miniaudio 0.11.25**.

**Looking for the Windows-to-Mac speaker app?** Open the `lan-audio` project's
README (beside this package in the development checkout). This package is its
audio dependency.

## What is included?

| Included | Not included |
| --- | --- |
| Audio device input/output | An audio player or network streaming app |
| PCM conversion, resampling and buffers | Pairing, network transport or application settings |
| Raw C API through `@import("miniaudio").c` | File decoding/encoding, resource manager, node graph or high-level engine |

The build defines Windows, Linux and macOS profiles. **That is not a claim that all
devices or platforms are tested.** See [verification](docs/VERIFICATION.md) and
[remaining release checks](docs/implementation/release-readiness.md).

## Check your setup

Use Zig **`0.17.0-dev.1859+dcceb318e`** and Python 3.9+. From this package directory:

```sh
zig version
python tools/check_vendor.py
zig build test -j1 --summary all
```

On macOS, use `python3` if `python` is unavailable. Successful tests report no
failures. They use the silent test backend: **they do not play or capture sound**.
They check the Zig/C interface and selected audio operations, not your speakers.

## Add it to a Zig project

Place `miniaudio-zig` beside your application's directory. These are additions to
an existing project, not complete replacement build files.

**1. Add the dependency inside `.dependencies` in `build.zig.zon`:**

```zig
.miniaudio_zig = .{ .path = "../miniaudio-zig" },
```

**2. In `build.zig`, pass the module to your executable's root module:**

```zig
const miniaudio = b.dependency("miniaudio_zig", .{
    .target = target,
    .optimize = optimize,
}).module("miniaudio");
exe.root_module.addImport("miniaudio", miniaudio);
```

Here `b`, `target`, `optimize` and `exe` are your existing build variables.
The module links the matching C library automatically.

**3. Import the API in your Zig source:**

```zig
const audio = @import("miniaudio").c;
```

For a complete working build, see the [small consumer example](tests/consumer/build.zig)
and its [API use](tests/consumer/consumer.zig). To run it from this package directory:

```sh
cd tests/consumer
zig build test -j1 --summary all
```

Before opening a device, read the [device lifetime rules](docs/contracts/device-lifecycle.md).
This is a raw C interface: you own pointer lifetimes, stable callback storage,
error handling and device shutdown. The binding preserves upstream result codes.

## Common build questions

| Situation | Next step |
| --- | --- |
| Zig API or build errors | Check the exact compiler version above. |
| macOS framework/link errors | Check your Apple SDK and framework search environment; see [dependencies](docs/DEPENDENCIES.md). |
| Need a build without physical backends | Add `-Dnull-backend=true`. This profile cannot provide physical audio. |
| Need a Linux compile check | Run `zig build check -j1 -Dtarget=x86_64-linux-gnu` from the package root. This does not run Linux audio. |
| Vendor check fails | Restore the reviewed vendor files; do not update hashes just to make the check pass. |

## Further reading

- [Public API and ownership contract](docs/CONTRACT.md)
- [Engineering handbook](docs/README.md) and [file guide](docs/FILES.md)
- [Independent ABI checks](docs/verification/abi.md) and [source-package checks](docs/verification/source-package.md)

For optimized checks, run `zig build test -j1 -Doptimize=ReleaseSafe --summary all`.
After documentation changes, run `python tools/check_docs.py`. Run both from the
package root; use `cd ../..` first if still in `tests/consumer`.

## Version and license

The pinned upstream commit is `9634bedb5b5a2ca38c1ee7108a9358a4e233f14d`.
Its dual-license text is preserved in [the upstream license](vendor/miniaudio/LICENSE).
No license has been selected for new project-authored files; the upstream license
does not grant permission to redistribute the whole wrapper.
