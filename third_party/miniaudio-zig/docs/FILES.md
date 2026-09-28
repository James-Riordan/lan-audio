# File-by-file ownership and verification

The [detailed every-file handbook](reference/files.md) and
[exact catalogue](reference/catalog.json) cover all current authored/vendor files,
including the expanded documentation and its read-only integrity tooling. The
table below retains the original compact source-role overview; use the catalogue
for exact coverage and the [reading guide](README.md) for conceptual order.

The tree is intentionally shallow. `src/` owns the ABI, `tests/` owns adoption
evidence, `vendor/` owns pinned third-party custody, `docs/` explains contracts,
and `tools/` contains read-only integrity checks plus explicit qualification
runners that create new evidence. Generated translations and compiled libraries
belong only in the build cache/output, never in authored source.

| File | Responsibility, rationale and failure/verification contract |
|---|---|
| `README.md` | Entry point, classification, commands and honest status; links must resolve |
| `build.zig` | One static C artifact, matching translated module, target links and separate compile/run steps; unsupported targets fail explicitly; no network effects |
| `build.zig.zon` | Package identity/version, compiler floor and distribution allowlist; no invented ZSON manifest; fingerprint is package identity, not an integrity hash |
| `src/profile.h` | Sole compile-feature definition; ABI consistency requires every consumer to use the exported module |
| `src/native.c` | Sole definition of `MINIAUDIO_IMPLEMENTATION`; avoids duplicate native symbols |
| `src/root.zig` | Exports `c`; documents stable-address and borrowed-lifetime rules without claiming memory safety for arbitrary C calls |
| `tests/contract.zig` | Version/frame units/config/null-device tests; must never silently fall back to a physical device |
| `UPSTREAM.json` | Exact tag/commit, source hashes and provenance limits; changes require deliberate review |
| `vendor/miniaudio/miniaudio.h` | Upstream declarations, implementation, embedded manual and backend/DSP algorithms; preserved unmodified; adoption is not line-by-line correctness certification |
| `vendor/miniaudio/LICENSE` | Upstream legal text, preserved byte-for-byte; does not license new wrapper code |
| `tools/check_vendor.py` | Hashes only declared paths contained within this root; missing/mismatched files fail; no repair or fetch |
| `docs/CONTRACT.md` | PCM units, ownership, callback ordering, failure interpretation and platform boundaries |
| `docs/DEPENDENCIES.md` | Full source/toolchain/platform closure for the admitted profile; optional upstream backends are capabilities, not hidden guaranteed services |
| `docs/FILES.md` | Compact original-role overview; the exact current inventory lives in the linked catalogue and every-file handbook |
| `docs/VERIFICATION.md` | Exact executed adoption results and platform limitations; not an upstream correctness certificate |
| `.gitignore` | Excludes generated build/log artifacts, never vendor provenance or authored contracts |

`verification/` may contain generated run logs; they are evidence, not API source.
Zig tests access C through the public module; independent C probes include the
shared profile without defining another native implementation. Exploratory probes
delivered as verification evidence do not expand the production API/build graph.
