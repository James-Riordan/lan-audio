# Directory and Codex handoff qualification

This phase restructures application source/tests/models and documents completion
work. It does not implement the planned v2 protocol, Mac TLS backend, production
sender, drift controller or release UI. The documented product remains unfinished.

## Delivered structure and documentation

Nineteen source/test/model files moved into responsibility folders. Core module
exports, existing build-step names and the externally referenced wrapper consumer
remain stable. Imports, live references, build paths and model lookup were updated.
Thirty-eight pre-edit authored files are preserved under `before/`; `migration.json`
records exact old/new paths and original hashes. Historical phase evidence was not
rewritten. Dependency source and SDK layouts/pins were not changed.

`AGENTS.md` and `docs/implementation/START_HERE.md` are the Codex entry. The handbook
includes a populated/planned layout distinction, nine cross-module interface
contracts, a decision register, ten ordered work packages, exact proposed v2 fields,
system-level mathematics, A1–A10 traceability and concrete qualification scenarios.
Current API maintenance is documented call by call. The reference covers 291 files:
125 authored/support documents, sources and fixtures, plus 166 installed SDK files.
Every existing evidence file also has a phase/handling classification; generated
caches are excluded explicitly. Upstream inventory is not a line-by-line security
audit or formal proof of vendor implementation.

## Executed relocation checks

| Check | Result |
| --- | --- |
| Core Debug and ReleaseSafe | 18/18 tests in each mode |
| Actual null audio callbacks, Debug and ReleaseSafe | Eight teardown/recreation cycles in each mode |
| Independent miniaudio package consumer | 1/1 native test |
| Explicit Windows physical capture fixture | Compile succeeds; hardware capture was not rerun for a directory change |
| Intel Mac pure core | x86_64-macos compile succeeds; no Mac SDK/audio/TLS execution claim |
| Linux native audio test artifact | x86_64-linux-gnu compile/link succeeds; no Linux execution claim |
| ReleaseSafe TLS-to-null-callback integration | All 16 independent-peer scenarios pass |
| SessionWindow / EndDrain / SpscPublication | All normal models and nine expected mutant counterexamples pass |
| Documentation and handoff coverage | Exact inventory/reference/local-link/import checks pass |
| Dependency custody | 188 TLS pins plus staged DLLs and miniaudio vendor custody verified |

The peer harness now requires a new explicit report path under `verification/` and
uses exclusive creation. Tests confirm an existing path and an outside path fail
before network startup and leave existing evidence unchanged. `capture-check` adds
a compile-only route for the physical fixture; `capture-test` retains explicit
device execution. Neither change silently starts a device during documentation checks.

## Limits and next action

Model counts and commands are in the raw model/command files. The final receipt
records current sources/evidence and dependency observations. A new source hash
does not prove a proposed interface exists. Documentation checks establish coverage
and navigation, not universal completeness or timeless correctness.

Begin with WP01 target qualification and WP02 fidelity transport. The Mac host and
its installed macOS remain necessary for native Mac evidence. The user has not yet
selected a latency ceiling, release license or signing/distribution identity; the
decision register explains which work can continue before those facts are supplied.
