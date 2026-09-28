# Selected native endpoints and format admission

This continuation adds exact backend-name selection and post-open callback/native
format checks to the existing private audio host. It is a C03 subset, not a
production platform qualification. No physical audio is captured or played.

The preceding sealed controller/callback increment remains immutable at
`verification/lifecycle-send/receipt.json`. Its 76 core/controller tests, 32
ReleaseSafe lifecycle tests and 14 detected controller/custody mutations apply to
their recorded source revisions. This increment changes the audio host, its tests,
the audio build steps and explanatory contracts; it does not rerun or relabel the
earlier mutation campaign as endpoint qualification.

## Behavior and observations

- Named selection copies the unique exact match's ID from the owned native context.
  Missing or duplicate names fail without choosing a default. Loopback selects a
  playback endpoint through the capture configuration. Names are session selectors,
  not stable identities; discovery/identity UX remains future work.
- The actual callback ABI must be 48 kHz f32 stereo front-left/right before ready.
  openedFormat exposes the active native dimensions. require_native rejects a
  differing representation, count, rate or channel map before any start.
- Successful native objects are reclaimed in device-then-context order on later
  validation failure. Selection failures reclaim the context. Repeated missing
  selections followed by a valid silent open/start/fence/deinit execute this
  context-only failure recovery path.
- Two independent host-root tests cover synthetic IDs, duplicate/missing names,
  and all native-format dimension mismatches in both directions. Five native
  integration tests exercise selected playback and duplex devices, caller-name
  storage release, lifecycle cycles, stable fences/snapshots and missing-input ABI.
  Tests execute only the explicit null backend on the local Windows host.

The first exploratory native run passed five integration tests. Imported-module
test declarations were not executed by that root, so the build now explicitly
includes a second host-root test artifact. During channel-map hardening, a compile
failure exposed the C API's mutable channel-map pointer type. Its source/log and
failed command record are retained as attempt-2; the final code supplies a mutable
stack array whose lifetime encloses native initialization. Final Debug and
ReleaseSafe commands, durations, exit codes and source hashes are in tests.json.
Their logs must each report seven passing tests across the two artifacts.
Upstream build locale warnings remain in the raw logs; success requires the
actual zero exit and completed test summary, not an isolated warning line.

## Limits

Real driver rejection of the callback ABI or strict native-format policy, native
start/stop partial failures, notification/hotplug handling, asynchronously changing
formats, persistent endpoint IDs and discovery UI remain unexecuted/unimplemented
gates. Dimension comparison tests do not execute those driver cleanup failures.
The inspected native miniaudio source is unchanged; its runtime guarantees remain
part of the trust boundary. No native Mac, Linux, mobile or other OS execution,
physical endpoint timing, two-host networking, signing or installation is claimed.

Scoped reference/doc/handoff checks passed. The transport-custody check FAILED
because the independently owned TLS build.zig changed during this continuation.
checks.json and transport-custody.log retain the executed failure; attempt-seal.py
retains the original failed sealing procedure. No pin was refreshed. The final
receipt records every current transport-lock mismatch as a blocked adoption gate,
alongside passing native evidence. The native suite does not enable transport-tests
or link TLS; its miniaudio source custody remains unchanged.

The active TLS/QUIC owner was informed and asked to identify a sealed source receipt,
build-interface change and TLS regression evidence for later consumer review.
That coordination does not adopt the in-progress build or a QUIC runtime. Prior
full checks retain their separate unadopted observations. The receipt records
current application bytes and unchanged core/controller/native dependencies without
overwriting earlier records or reporting the transport gate as passed.
