# Fidelity core, source structure and documentation revision

This revision implements a coherent pure v2 foundation and explains it at source,
domain and architecture levels. It does not finish the Windows-to-Mac application.

## Implemented and documented

`src/media/format.zig` validates stereo binary32 application dimensions and bounded
sample/byte products. `src/protocol/v2.zig` supplies the 48-byte experimental header,
finite-f32 bit-preserving encoder/decoder and fixed 8240-byte incremental parser.
`src/protocol/negotiation.zig` enforces role/direction, authorization attestation,
exact format echo, stream identity, contiguous frame positions and receiver drain
attestation before ACK. Their exports are separate from existing v1 semantics.

The canonical protocol documentation explains every header field, API, borrow,
aliasing condition, error effect, bound and state transition. The connected source
guide, documentation map, module/capability chapters and development standards
give readers a structured path through current code and remaining work. Existing
queue/bridge comments now state overlapping-buffer restrictions, transfer prefixes,
counter units and callback-versus-acoustic completion explicitly.

The source tree gained three real modules and a protocol test subdirectory with
two test files. Eight new documentation files include source-level navigation and
domain/architecture/development reading paths. No empty planned modules were
created. The complete reference contains 311 entries: 145 authored/support files
and 166 installed SDK assets. Inventory size is not a correctness score.

## Executed checks

| Check | Observed result |
| --- | --- |
| Formatting | Pass |
| Pure core Debug | 29/29 tests pass |
| Pure core ReleaseSafe | 29/29 tests pass |
| Intel macOS pure test artifact | x86_64-macos compilation passes; not executed on Mac |
| ARM64 Linux pure test artifact | aarch64-linux-gnu compilation passes; not executed on Linux |

Raw outputs and commands are in `final-*.log` and `final-commands.json`. The earlier
28-test run is preserved separately; the final run adds the complete transition
permission table. V2 checks include independent literal bytes, independent byte
shifts over 131,072 finite words including signed-zero/subnormal/extreme boundaries,
all 8240 incomplete split positions of a maximal record, coalescing/truncation,
malformed fields, nonfinite rejection and unchanged outputs after errors. Gate
tests cover both roles, empty/partial streams, replay, wrong stream/format/direction,
oversized negotiated blocks, early ACK and 140 phase/role/kind/direction cases.

The first compile failed because the u64 overflow subtraction inferred the u32
frame-count operand type. Frames are now explicitly widened before subtraction.
The initial diagnostic is preserved in `compile-attempt1-note.txt`; the captured
corrected source is labeled `compile-attempt2-source.zig`. This was a development
failure, not a passing earlier run. The final native/cross builds use the repair.

The final receipt records source/tool identity and documentation/reference/custody
checks. Historical formal results remain scoped to their unchanged model sources;
the v1 models are not asserted to prove the new v2 gate. No formal model was changed
or rerun in this revision. The gate's transition argument and finite table tests
are stated as such, not as a whole-system refinement theorem.

## Boundaries and next implementation

Before-images of 73 pre-edit application files and their hashes are preserved.
Existing v1 codec/receiver behavior and dependency source/SDK/adoption bytes remain
unchanged. No physical device, network peer, new credentials or user-facing app was
started by these tests. The source checkout has no Git metadata; no repository was
initialized or published.

WP02 is partial. It still requires independently implemented authenticated v2 peers,
bounded differential fuzzing and transport/device integration. WP04 must respect
the gate's one-record commit boundary, actual endpoint capability validation and
real worker/callback drain before ACK. Native Mac qualification, timing/drift,
measured faulty-NIC recovery, pairing/UI and packaging remain open. The documented
UI/capability flows are design contracts, not implemented screens or OS support.
