# Foreground live workers — qualification

This increment implements actual foreground send/receive commands, a fixed native
owner aggregate, real media threads, paced capture/playback queues, fresh private
development pairing, and an explicit Intel Monterey static-SDK build route.

## Final source results

- Debug and ReleaseSafe each pass 40 build steps and 109 component tests.
- Both modes pass 12 independent live-worker scenarios: normal sender/receiver,
  short/empty receive, wrong ACK, sender disconnect, duplicate receive, sender
  stall, active cancellation in both roles and both roles as TLS listeners.
  Success requires exact frame conservation, authenticated independent peer,
  secure closure and actual joined/fenced/released ownership. Failures must exit
  with the named cause and complete cleanup. These callbacks use the null backend.
- Both modes pass all 43 existing independent verified-channel scenarios.
- Fresh pair creation passes current-time mutual TLS, independent leaf digests,
  repeated creation without rotation, altered-output rejection, private issuer
  cleanup, paths with spaces and malformed CLI rejection.
- An explicit final ReleaseSafe physical Windows CLI run captures/transfers
  480,000 frames over 10.071 seconds, reports zero capture drops, confirms remote
  ACK and clean TLS close, and releases all native owners. This run observed
  silent samples, so it does not independently establish non-silent content.
  An earlier three-second development execution observed 143,040 frames and
  453,585 nonzero bytes, with zero drops. That observation is retained separately
  as a tool-output note without pretending it is the final binary's sealed run.
- The installed-library `run -- help` path works. Intel Mac portable core,
  lifecycle and policy compile. Missing Mac static SDK and attempted Windows
  execution of the native Mac recipe explicitly reject. No Mac application build
  or device execution is claimed. All 188 dependency pins and staged DLLs match.

## Historical failures and repair

The first build attempt used a removed Zig Build API; staging the executable with
its DLLs fixed the build/run path. An inherited Perl locale warning was eliminated
for later commands by setting LANG and LC_ALL to C. The first live receiver loop
sent ACK but skipped the TLS-close effect after its protocol gate became complete;
the independent watchdog caught the hang. The corrected loop explicitly dispatches
closure in that state. Initial frame reporting also lagged copied custody on a
failed flush; the sender now records its committed frontier on every exit.

`first-debug.json` contains development observations spanning the live repair and
is not one coherent final-source qualification. `second-debug.json` and
`expanded-debug.json` record subsequent development runs. Only `final/` binds the
final Debug/ReleaseSafe executables to fresh campaigns. Private pairing keys and
PCM audio are never included in evidence.

## Limits

This is Windows 10 execution and an unexecuted Intel Mac build recipe, not a
production release. Mac SDK build, Monterey/current macOS playback, CoreAudio
destructive-fence behavior, acoustic completion, true two-host sound, Wi-Fi jitter,
clock drift, reconnect, long sessions, installation/signing and iPhone remain open.
No automatic firewall/trust-store/network-category change was made. Aggregate
silent-frame counts include tail filling and do not establish a dropout metric.
The initial runtime aborts on source loss and requires manual restart after failure.

The phase receipt preserves the prior 139-file application snapshot and previous
evidence, binds current source/commands/binaries, and records its exact limits.
