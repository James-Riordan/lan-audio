# Authenticated media transport qualification — 2026-09-25

This phase implements bounded framing and a composed receiver, admits the existing
TLS/OpenSSL implementation for Windows synthetic media, and extends generic TLS
ALPN configuration without breaking its HTTP default or original C constructor.
It does not implement physical audio, a product sender, pairing or a Mac TLS backend.

## Executed behavior

An independent Python TLS server requires a trusted client certificate and sends
20 synthetic PCM blocks through deliberately fragmented/coalesced writes. The Zig
receiver authenticates the server name/certificate, requires `jcr-audio/1`, parses
bounded records, binds one stream, decodes and submits all 9,600 samples to arrays,
acknowledges the terminal frontier and requires clean TLS closure. No device or
external host is accessed. Public fixture credentials are test-only.

All 16 live scenarios pass: the positive transfer plus wrong hostname, wrong/missing
ALPN, expired server certificate, untrusted client chain, oversized body, unsupported
profile, audio before START, wrong stream ID, repeated position, truncated record,
missing END, extra data after END, raw EOF and a stalled peer. Negative cases must
report an expected error and must not emit the success marker; arbitrary crashes
do not count as correct rejection. Details are in `interop.json`.

The pure suite has 14 tests, including every single split point of a 996-byte PCM
record, all 65,536 signed PCM16 values, independent golden bytes and the retained
32,768 action-trace oracle. The generic TLS suite has 19 tests, its host driver has
11, and the original independent TLS peer has 17 cases. Existing default-HTTP and
old-C-ABI interoperability remains verified after the configurable-ALPN change.

## Formal and custody evidence

The original 1,171-state session/window model remains historical evidence at its
unchanged specification. The new END model checks 29 distinct states (62 generated),
plus expected counterexamples for early completion, terminal frontier before
buffered data, and post-END admission. Fair tick scheduling is an explicit liveness
assumption. This is not a machine-checked refinement to Zig or an OS-thread proof.

`transport-lock.json` pins 188 TLS/source/SDK/fixture files, including all 166 members
of the existing private OpenSSL SDK. The test checks both staged DLLs before launch.
PE import observations expose the libssl-to-libcrypto edge and Windows API/UCRT
dependencies. The generic TLS interoperability harness separately verifies the loaded
DLL paths. Source/SDK custody is not a signed provenance or security certification.

Exact commands, output logs and final source observations are recorded in
`receipt.json`. Before-images of 19 changed files are under `before/`: 16 were
copied before editing; three were reconstructed and verified byte-for-byte against
the prior source snapshot's SHA-256 hashes. The TLS OpenSSL SDK and miniaudio package
were not modified. The prior kernel report/source snapshot were preserved as history.

| Final recorded check | Result |
| --- | --- |
| Pure core, Debug and ReleaseSafe | 14 tests pass in each mode |
| Generic TLS / host driver, ReleaseSafe | 19 / 11 tests pass |
| Existing independent TLS interoperability | 17 cases pass |
| Synthetic audio over authenticated TLS | 16 scenarios pass |
| END model / three injected faults | 29 distinct states; all expected counterexamples found |
| Linux x86_64 core and miniaudio consumer | Compile/link succeeds; no Linux execution |
| Mac arm64 pure core | Compile succeeds; no Mac audio or TLS execution |
| Documentation navigation / dependency custody | 45 files mapped; 188 pinned files verified |

## Limitations and next work

TCP loss can stall later audio bytes. The positive test is not paced by an audio
clock and does not measure acoustic latency, drift, callback deadlines or long-run
resource behavior. Probe completion means array submission plus authenticated close,
not audible or durable delivery. There is no production credential provisioning or
per-device authorization policy. OpenSSL's total CPU/memory use is not bounded by
the driver's fixed buffers.

Physical integration still needs bounded SPSC transfer, pacing/backpressure, real
Windows loopback and Mac playback, actual callback quiescence and clock control.
The pure kernel can be cross-compiled independently; the Mac audio SDK limitation
and Windows-specific TLS build remain. These results do not certify the eventual
cross-platform product or all upstream code.

The initial END model's mutation run exposed an ambiguous Boolean assignment that
left a successor variable unassigned. Parenthesizing the assignment corrected the
specification; normal and all three mutant checks were then rerun successfully.
