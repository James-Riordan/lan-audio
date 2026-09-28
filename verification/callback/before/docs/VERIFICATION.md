# Verification, evidence and next gates

Current transport results are in `verification/transport/RESULTS.md`; the original
`verification/RESULTS.md` and source snapshot are historical kernel-preparation
evidence. They must not be used as freshness certificates for version 0.2.

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

Results belong in `verification/RESULTS.md`, raw model output in `models.json`,
and observed source/tool/dependency hashes in `source-snapshot.json`. A build failure
is retained as diagnosis, then a corrected run is recorded; it is never relabeled
as a successful earlier run. Generated evidence records do not own runtime meaning.

## Required next gates

1. TLS/TCP and bounded PCM framing now have Windows synthetic-media qualification.
   Extend the transport host to real credentials/pairing and Mac deployment before
   claiming a product. The local QUIC candidate remains incomplete.
2. Implement SPSC callback handoff, prove/check publication ordering and test
   overflow, cancellation, pacing and memory reclamation under actual concurrency.
3. Implement Windows loopback and Mac playback behind explicit capability checks.
   Validate stop, hotplug, permission denial and repeated restart under active work.
4. Integrate clocks/deadlines and measured drift correction. Run impairment simulation
   and physical end-to-end latency/resource tests against `PRODUCT.md` acceptance.
5. Add the user-facing executable, packaging and permission/lifecycle flows; verify
   clean-machine installation and removal. Select product identity/license before release.

These are remaining product work, not evidence that the documentation task achieved
finished streaming. Further package extraction must be earned by independent use.
