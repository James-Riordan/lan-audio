# Make one complete change and leave a reproducible record

Start with [the engineering explanation](../literate/README.md), the current proof
ledger and relevant domain/source contracts. Consult AGENTS.md and inspect local
changes before edits. This checkout currently has no Git repository metadata;
preserve before-images with hashes and review changed paths rather than assuming
a clean Git status. Do not initialize or publish a repository implicitly.

## Choose a bounded responsibility

Select the first useful implementation whose dependencies are available. Missing
Mac execution does not prevent pure protocol work, but it prevents Mac support
claims. Specify the exact observable behavior, owners and test evidence that will
complete the chosen change. Populate new files with working code, not placeholder
success. Keep unrelated dependencies and reviewed adoption locks unchanged.

## Implement and verify at the right boundary

Use the pinned Zig toolchain in the root README. `zig build test -j1 --summary all`
runs pure core tests, including v1/v2. Repeat with `-Doptimize=ReleaseSafe` for
optimization-sensitive bit/overflow behavior. `core-check -Dtarget=x86_64-macos`
checks target compilation only. Native audio, physical capture and network peers
have separate explicitly selected commands; do not start hardware to validate prose.

Preserve a failing command's output, diagnose it and record the repaired run
separately. Do not weaken an assertion or silently expand a trust manifest to make
a check pass. Use independent expected bytes/state transitions and test failed
operations' state/output effects, not just their error codes.

## Update the living explanation

Apply [the documentation standard](documentation.md). Register new paths in
`tools/reference_contracts.json`, run `python tools/build_reference.py`, then
`python tools/check_docs.py` and `python tools/check_handoff.py`. The latter name is
historical; it checks inventory/import/contract coverage. It does not grade design.
Dependency custody uses its separate checkers.

## Seal the observation

Use a fresh `verification/<phase>/` directory for commands, logs, tool versions,
source/config/dependency hashes and a human RESULTS.md with limitations. Keep
before-images. Final receipts may be hashed after documentation generation; avoid
self-hash cycles and record which files were intentionally excluded. A build is
not execution, an expected rejection is not a successful operation, and a bounded
model pass is not an implementation proof.

Mark work packages partial until all their exit criteria are observed. Report
what changed, the evidence and the next unmet boundary. The user should be able
to understand both the advance and its limits without reading every tool log.
