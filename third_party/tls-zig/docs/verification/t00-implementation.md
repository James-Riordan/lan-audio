# T00 implementation status — 2026-09-26

## Changed behavior

TLS now has a read-only exact SDK verifier in `tools/verify-backend.py`. It rejects changed, missing or additional files, malformed/duplicate manifest entries, escaping paths, Windows aliases and linked/reparse paths. `tools/qualify.ps1` binds backend/root/compiler/target metadata and calls it before native qualification. Tests invoke the actual PowerShell entry with a disposable SDK and compiler fixture to verify rejection before a build. All 166 installed SDK files match the unchanged lock.

The downloader preserves the release URL, size and SHA-256. HTTP status, range, encoding, body length and final digest checks remain active under Python -O. Extraction uses a new staging directory, verifies every file against the verified archive, and promotes only a complete tree. A lone Configure file is insufficient. Incomplete or modified old trees are retained beside the destination; ordinary promotion failures restore them. Pinning is a separate explicit operation, with unconditional version validation and atomic replacement of the lock only after collection succeeds. Lock generation was not run.

Four assertion-based interoperability harnesses now refuse -O/PYTHONOPTIMIZE before runtime loading or socket/process effects. Both lifecycle checkers now test invalid completion from an already-complete baseline; this prevents the first real completion from breaking their negative controls.

## Fresh verification

- 16 offline backend test groups pass under normal Python and Python -O, with fake HTTP responses, independently known archive bytes and file-set snapshots.
- Exact installed SDK verification passes in both modes: 166 files; backend-lock SHA-256 `d4d905865bddf009683d703345873bf4fba06ba742a26d5bf2079dee1df7c2ef`.
- TLS record transport (11 tests) and host driver (19 tests) pass in Debug and ReleaseSafe with Zig `0.17.0-dev.1859+dcceb318e`.
- 17 independent Python/OpenSSL peer cases, the public TLS example, the separate existing consumer build, and 5 client + 4 server + 5 early-response TCP cases pass.
- Both projects' lifecycle, custody and safety model suites pass normally and under -O. Documentation/source and shared-plan gates are retained in the final gate receipt.

## Evidence and scope

The TLS completion receipt binds the implementation, acceptance observations, source/build/fixture closure, all locked SDK file hashes and retained stdout/stderr. Native artifacts were rebuilt or reused from Zig's content-addressed cache as reported in the logs; test executables were run. Python 3.14.3, Windows x86_64. QUIC protocol code and its type-only vendor fixture were not changed; its native protocol suites were not rerun for this tooling-only increment. Existing source snapshots and historical receipts are preserved.

Acquisition tests are offline fault-injection tests, not a fresh upstream download/build or power-loss experiment. Source promotion uses two renames when displacing a stale tree; it does not promise atomic exchange or concurrent-writer safety. A kill between renames can leave the retained old tree and no final tree; restart uses new verified staging. The verifier requires a stable input tree and does not establish loaded-module identity. Native portability, SDK rebuilding, distribution and deployment are outside this milestone. Symlink rejection uses a real link when permitted, otherwise a reparse-flag test hook; it is not a Windows junction qualification claim.

## Remaining gates and exact next action

All 37 packages and 89 acceptance obligations are retained. T00 is the first completion; the other 36 packages remain planned. The 17 historical authenticated recordless scenarios remain diagnostic evidence only.

Implement **T01, `tls-zig/src/quic/contract.zig`**, with an executable configuration/capability gate before allocation or peer input, explicit level/direction/count/time/generation types, bounded ownership operations, a separate compiling provider/host consumer fixture, and unauthorized trust/capability override rejection. Preserve records APIs and frozen QUIC fixture pins. Then follow T03/T05 → T04 → T02 → T06 → Q00/Q01. Required cleanup includes retaining failed-release custody through provider destruction; local byte-budget exhaustion must remain distinct from waiting for network input.

T07, Q09, Q12 and Q14 are independently ready in the graph. No sibling dependency repository was edited and no external chat was messaged.

[Source-bound T00 completion receipt](completions/T00.json) · [Final integrity gates](t00-final-gates.json) · [Change audit](t00-change-audit.json)
