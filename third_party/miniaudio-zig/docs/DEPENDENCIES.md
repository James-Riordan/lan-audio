# Complete dependency boundary for this build profile

| Layer | Dependency and purpose | Custody / qualification boundary |
|---|---|---|
| Zig package | No external Zig packages | `.dependencies = .{}` is accurate; C/platform dependencies still exist |
| Upstream source | miniaudio 0.11.25 header, exact commit in `UPSTREAM.json` | Unmodified header and license; SHA-256 check before adoption/build qualification |
| Profile | Low-level devices and DSP | Built-in file codecs, resource manager, graph and engine disabled; no Opus, Vorbis, FLAC or MP3 package adopted |
| Compiler/build | Zig 0.17.0-dev.1859+dcceb318e, its std/build support and C toolchain | Exact compiler recorded; `minimum_zig_version` is a floor, not a compatibility proof or toolchain lock |
| C runtime | Target libc and compiler runtime | Supplied by target toolchain/OS; allocator, threading and loader behavior remain platform contracts |
| Windows | `ole32` link and upstream dynamically loaded Windows backend APIs | OS components are not vendored; default native build is distinct from explicit null-backend execution |
| Linux | libc, libm, pthread/dl, available ALSA/PulseAudio/JACK backend libraries | Upstream probes available backends; no claim that every optional backend is present; compile alone does not qualify playback |
| macOS | CoreFoundation, CoreAudio, AudioToolbox, system runtime and SDK | Build declarations supplied; requires a compatible SDK and actual Mac execution for qualification |
| Custody tool | Python standard library | `tools/check_vendor.py` is read-only, has no third-party Python dependency and no network access |

Builds use local vendored bytes and perform no downloads. Vendor SHA-256 records
establish exact observed bytes, not a signed upstream release or a vulnerability
audit. No upstream source-file rewriting is required to make the adoption literate:
the original manual/comments remain intact, and this repository owns the boundary.

Promotion requires reviewing upstream changes, verifying the same profile on C
and Zig sides, rerunning native and consumer checks, reviewing every new system
dependency, and qualifying physical devices separately. A previously passed test
does not qualify a changed OS, driver, compiler, profile or dependency revision.

The [ecosystem boundary](architecture/ecosystem-boundary.md) records how future
MetaOS/updatez/ZSON/Docz/Quartz adapters interact with this reusable binding.
Those integrations are proposed; this package has no new runtime/build dependency
on them. [Adoption transactions](implementation/adoption-transaction.md) require
isolated candidates, explicit comparison/publication policy and recoverable host
ownership, preserving source/profile/compiler identity across retries.
