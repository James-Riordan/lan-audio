# One import, one profile, one implementation

## The actual build graph

A consumer obtains dependency module `miniaudio`, whose root is
`src/root.zig`. Its only public declaration, `c`, imports generated
`miniaudio_c`. `build.zig` translates `src/profile.h` for the selected target
and optimization, and links that module to a static library compiled from
`src/native.c`. The C file defines `MINIAUDIO_IMPLEMENTATION` and includes the
same profile. No consumer should translate the vendor header a second time or
define a competing implementation translation unit.

The representation obligation is stronger than matching names:

`layout_C(T, target, macros) = layout_Zig(T, target, macros)`

for every exchanged type T, including size, alignment, relevant offsets, enum
representation and callback calling convention. Equal profile inputs are a
necessary construction rule; they do not independently demonstrate that the
translator, compiler and linker agree. The original adoption tests call C through
the translated API. The separate [Q01 probes](../verification/abi.md) now compare
C-produced layout facts and invoke a guarded synthetic callback. Each native
target/profile still requires its own successful matrix receipt.

## Feature boundary

| Input | Existing effect | Change obligation |
| --- | --- | --- |
| `MA_NO_DECODING`, `MA_NO_ENCODING` | Exclude file-codec paths | Re-enabling requires source/dependency/license and attack-surface review |
| `MA_NO_RESOURCE_MANAGER`, `MA_NO_NODE_GRAPH`, `MA_NO_ENGINE` | Exclude high-level asset/graph/engine layers | Do not describe these as available product features |
| No additional disabling macro | Other upstream low-level facilities remain available according to the header | Export availability is broader than the small set exercised by tests; buffers, filters, waveform/noise and conversion are not all qualified |
| `-Dnull-backend=true` | Both C and translation receive `MA_ENABLE_ONLY_SPECIFIC_BACKENDS` and `MA_ENABLE_NULL` | Profile must agree on both branches; never package this artifact as physical playback |
| Default `null-backend=false` | Native backend selection remains upstream-controlled | Runtime tests still explicitly select the null backend |

Custom consumer C macros do not automatically update the translated Zig ABI.
Expose a new supported profile through this single build graph only after testing
both compilation paths and downstream use. Do not promise ABI compatibility across
upstream releases; the pinned header expressly makes no such guarantee.

## Targets and dependencies

The build accepts Windows, Linux and macOS and rejects other OS tags. This is a
build-policy list, not an execution support matrix. `link_libc` applies to the C
artifact. Windows explicitly links `ole32`; Linux links `m`, `pthread`, `dl`;
macOS links CoreFoundation, CoreAudio and AudioToolbox. Upstream may load backend
libraries at runtime. SDK discovery and successful linking cannot establish that
a real endpoint exists, permission was granted, or the requested format ran.

The package contains no external Zig dependency, but it depends on the compiler,
libc, platform SDK, system libraries and drivers. Read [DEPENDENCIES.md](../DEPENDENCIES.md).
`minimum_zig_version` is a compatibility floor. This adoption's exact development
compiler is `0.17.0-dev.1859+dcceb318e`; newer versions need new evidence.

## Build effects and packaging

The default installation emits the static native library. `check` compiles and
links the adoption and ABI test artifacts; `test` executes both. `check-abi` and
`test-abi` select the probe artifact. Test runs bypass result caching while
compilation may be reused. Neither suite means every API was
tested. Physical-device tests must remain explicit opt-in steps with named devices.
The package allowlist includes source, tests, vendor, docs and tools; generated
translations, caches and machine-specific runtime output stay outside source.
Its root `.paths` now lists exact files rather than recursive directories: the
pinned compiler included nested caches under the old directory list. The
[source-package gate](../verification/source-package.md) verifies actual compiler
selection, identity under controlled noise and a relocated archive consumer.

Do not store a generated translation as a second authored API. Do not silently
retry with a different backend or system copy of miniaudio after a build failure.
For changes, retain target/CPU/ABI, compiler identity, profile macros, source hashes,
command exit code and downstream consumer result. ReleaseSafe success does not
establish hard real-time bounds or guarantee ReleaseFast safety.
