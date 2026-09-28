# Independent v2 qualification and capture block assembly

Observed on Windows, 2026-09-26. This phase qualifies bounded protocol components
and implements the pure capture block assembler. It does not qualify a finished
Windows-to-Mac audio product. The final [receipt](receipt.json) records source,
tool, executable and evidence hashes after documentation checks.

## Implemented and documented

- An independent Python v2 oracle and a test-only Zig shared-library boundary
  compare acceptance and exact encoded bytes without sharing parsing code.
- Independent authenticated loopback peers exercise both application roles. Both
  Zig executables are TLS clients; the Python fixture is the TLS server. This
  distinction matters when reproducing or interpreting the tests.
- `BlockAssembler` copies arbitrary complete stereo-frame prefixes into bounded
  protocol blocks, preserves unaccepted suffix ownership, commits positions only
  after downstream custody, handles final partial blocks, and terminates on
  explicitly reported source discontinuity.
- The [assembly argument](../../docs/media/assembly.md) gives invariants, operation
  contracts, conservation/order arguments, ownership and remaining host duties.
  The [qualification guide](../../docs/verification/v2-independent.md) specifies
  the independent oracle, resource limits, failure interpretation and commands.
- Ten new authored files and updated contracts extend the reference to 323 files:
  157 authored/support files across the application and its two dependencies,
  plus 166 installed SDK assets. This includes two existing verification chapters
  omitted by the former inventory filter. Upstream source/assets are preserved.

## Recorded execution

| Check | Result | Evidence |
| --- | --- | --- |
| Pure core, Debug | 35/35 tests passed | [captured tool observation](core-debug-observation.json) |
| Pure core, ReleaseSafe | 35/35 tests passed | [raw output](final-1.log) |
| Intel Mac and ARM64 Linux pure core | Both compiled; neither executed on target | [commands](final-commands.json), `final-2.log`, `final-3.log` |
| Independent differential corpus, Debug | 13,631 cases passed: 1,017 accepted; 12,614 rejected | [Debug report](differential-debug.json) |
| Same corpus, ReleaseSafe | Same counts and corpus hash; all passed | [ReleaseSafe report](differential-safe.json) |
| Independent v2 mutual TLS scenarios | 22/22 passed, including expected protocol/identity failures | [final peer report](interop-final.json) |
| Existing v1 transport regression | 16/16 passed, including null-backend callback scenarios | [v1 report](v1-regression.json) |
| Harness report-path guards | Four rejection/preservation checks passed | [guard observations](report-guards.json) |
| Formatting | Passed | [commands](final-commands.json) |

The differential seed is `0x4A435232`; both modes report corpus SHA-256
`27be576a11754eb00d7a86a1060f08fd35dcf5e9af6331243c79e5798e0a18f3`.
It includes every incomplete prefix of a maximum-size record, header bit flips,
legal profiles and finite-word edge cases, and seeded mutations. This is a finite
test corpus, not exhaustive verification. Negative native probe results are
internal disagreements/misuse, never accepted as successful protocol rejection.
The harness bounds case/input counts and worker time; it is not an OS memory quota.

The installed codec probe was rebuilt in Debug after its ReleaseSafe run. Each
report names the binary hash it actually tested; do not infer that the current
DLL matches both reports. The final TLS executables are ReleaseSafe, and their
hashes appear in the final peer report. The recorded commands use the pinned Zig
toolchain and process-local `LC_ALL=C`, `LANG=C` for native TLS builds.

## Failure retained and repaired

The first assembler test run had 34 passing tests and one test-index overflow:
Zig inferred an integer slice bound narrower than usize, and multiplying it by
two overflowed. Explicitly typing that bound as usize repaired the test. The
[failed test version](assembler-test-attempt1.zig),
[raw failure](assembler-attempt1.log) and
[command observation](assembler-command-attempt1.json) remain unchanged.
This was a test indexing defect, not evidence of a discovered assembler runtime
failure. The subsequent Debug and ReleaseSafe suites both pass.

The first documentation render also exposed an overbroad inventory exclusion:
it skipped any directory named verification, including authored docs/verification
chapters. The filter now excludes only top-level generated verification evidence.
The acceptance matrix and scenario chapter now receive explicit contracts; the
new qualification chapter is also included. The failed render/check observations
remain in [the first check report](document-checks.json), followed by the repaired
[final checks](document-checks-final.json). This repairs a documentation coverage
claim; it does not retroactively change any historical receipt.

## Limits and next gates

The v2 fixture receiver checks sample words synchronously; its END acknowledgement
attests to that bounded verification sink, not speaker playback or callback drain.
The fixture uses public test credentials, a test verification time and a loopback
socket adapter. None is a production pairing or networking implementation.

Native capture-to-assembler integration, sustained playback, clock drift control,
bounded buffering/recovery, credential lifecycle, user-facing controls and the
real two-host path remain open. New v2 tests do not operate physical audio devices.
The v1 regression uses the null backend. No physical audio or native Mac test was
performed in this phase. On 2026-09-26 the user reported the Mac unavailable and
its OS probably Monterey; this is unconfirmed, not a measured deployment target.

The existing v1/v2 codecs, negotiation gate, dependency source/SDK pins and TLA+
models are unchanged. Historical bounded model results remain historical; the
models were not rerun here. The new assembler argument is a documented manual
argument plus executable tests, not a machine-checked refinement proof.
Network stalls beyond the available latency/buffer budget cannot be erased:
recovery must report discontinuities truthfully instead of claiming preserved
audio. See the [implementation entry](../../docs/implementation/START_HERE.md)
and WP02/WP04 for the remaining integration work.
