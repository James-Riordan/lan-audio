# Verification, evidence and next gates

Latest relocation/handoff checks are in `verification/handoff/RESULTS.md`. Callback,
transport and original preparation receipts describe their recorded source revisions.
Each phase retains its own observations and failures. Documentation work does not
upgrade prior hardware measurements or qualify the unimplemented product.

## Reproduction

Use the exact Zig compiler recorded in `README.md`. From `../miniaudio-zig`, run
`python tools/check_vendor.py`, then `zig build test -j1 --summary all` in Debug
and ReleaseSafe. From this root run `zig build test`, `zig build dependency-test`
and the read-only documentation checker. `zig build check -Dtarget=x86_64-linux-gnu`
compiles test artifacts but must not be described as Linux test execution.

Run `tools/check_models.py` with explicit Java and TLC paths as described in
`spec/README.md`. Archive its JSON output. The runner checks normal invariants and
fair-stop liveness, then requires each of four mutants to produce its named
counterexample. A normal pass without those detection checks is weaker evidence.

## What the checks establish

* Core tests establish specific implementation behavior for authentication gates,
  callback drain, stale epochs, reordered/duplicate/late/far blocks, loss-to-silence,
  nonfinite rejection, repeated ring-slot reuse and counter exhaustion. An independent
  absolute-position oracle checks all 32,768 five-action traces over eight operations,
  using a different representation from the production ring.
* The wrapper tests exercise real C code and an explicit null context/device. The
  independent consumer catches missing link propagation across the package boundary.
* Vendor hashes establish the two files match the adopted upstream bytes.
* The documentation checker catches broken local links, missing file-map entries
  and unmapped authored files. It does not grade prose, mathematics or architecture.
* TLC establishes the configured finite model's properties under its assumptions.
  It does not establish C/Zig refinement or the actual host's progress.

New results belong in a new `verification/<run>/` directory with a human report,
raw model/command output and a source/tool/dependency receipt. Preserve existing
phase files; the original root evidence is historical. A build failure
is retained as diagnosis, then a corrected run is recorded; it is never relabeled
as a successful earlier run. Generated evidence records do not own runtime meaning.

## Required next gates

1. TLS/TCP and bounded PCM framing now have Windows synthetic-media qualification.
   Extend the transport host to real credentials/pairing and Mac deployment before
   claiming a product. The local QUIC candidate remains incomplete.
2. SPSC callback handoff now has publication/reuse arguments, bounded model checks,
   concurrent frame tests and actual null-device teardown/recreation. Integrate
   production cancellation, pacing and worker joins; qualify weak-memory execution.
3. Explicit Windows loopback/playback and Mac playback profiles exist. Qualify Mac
   SDK/device execution and both platforms' hotplug, permission and endpoint changes.
4. Integrate clocks/deadlines and measured drift correction. Run impairment simulation
   and physical end-to-end latency/resource tests against `PRODUCT.md` acceptance.
5. Add the user-facing executable, packaging and permission/lifecycle flows; verify
   clean-machine installation and removal. Select product identity/license before release.

These are remaining product work, not evidence that the documentation task achieved
finished streaming. Further package extraction must be earned by independent use.

The live TLS harness requires `--output verification/<new-run>/interop.json` and
refuses existing reports before starting a peer. It requires
all samples to pass through the null playback callback before acknowledging END.
The Windows hardware command is separate: `zig build capture-test`. Its first idle
source failure is retained, together with the subsequent silent-playback fixture
run. Failure is not converted to skip/success. See `docs/CALLBACKS.md` for commands
and the exact distinction between device callback copying and audible delivery.
