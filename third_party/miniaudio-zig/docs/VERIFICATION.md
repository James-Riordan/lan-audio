# Executed adoption evidence — 2026-09-25

Environment: Windows x86_64; Zig `0.17.0-dev.1859+dcceb318e`; Python 3.14.3.
The native build used the vendored 0.11.25 header, commit and SHA-256 values in
`UPSTREAM.json`. Test subprocesses used process-local `LC_ALL=C` and `LANG=C`
to avoid inherited Perl locale warnings; no global environment was modified.

| Command | Result and meaning |
|---|---|
| `python tools/check_vendor.py` | PASS; both upstream files match recorded hashes |
| `zig build test -j1 --summary all` | PASS; 3/3 tests, native backend code compiled, explicit null device executed |
| `zig build test -j1 -Doptimize=ReleaseSafe --summary all` | PASS; 3/3 tests |
| `zig build test -j1 -Dnull-backend=true --summary all` | PASS; 3/3 tests in explicitly narrowed backend profile |
| `zig build check -j1 -Dtarget=x86_64-linux-gnu --summary all` | PASS; compiled/linked test artifact, not Linux execution |
| Sibling `lan-audio`: `zig build dependency-test -j1 --summary all` | PASS; 1/1 independent package consumer test invoking native C |
| Sibling `lan-audio`: `zig build check -j1 -Dtarget=aarch64-macos --summary all` | Blocked by missing Apple SDK framework paths; pure application kernel compiled, audio consumer did not |

The wrapper has not been tested on physical capture/playback endpoints. No
microphone/system audio was recorded; no sound was emitted. macOS support remains
unqualified and requires a compatible SDK and actual device execution. No upstream
whole-library proof, ABI compatibility across releases, hard-real-time bound or
cross-platform production certification is claimed.

Initial build diagnostics led to adding required package fingerprints and typing
one translated C enum expectation explicitly. The explicit null-only profile was
reviewed against upstream backend-selection macros and tested with `MA_ENABLE_NULL`.
The final runs above followed those repairs.

Raw adoption logs are retained locally under `C:/Projects/lan-audio/verification/`,
with the final source/tool/dependency observation in `source-snapshot.json` there.
This report remains readable without those sibling artifacts, but raw reproduction
requires the original source/toolchain or equivalent freshly generated evidence.
