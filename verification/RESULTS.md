# Executed verification — 2026-09-25

This is a bounded preparation result. The product does not yet stream audio.
The Obsidian vault and existing sibling projects were not modified.

## Environment and source

* Windows x86_64, Zig `0.17.0-dev.1859+dcceb318e`, Python 3.14.3.
* Temurin Java `17.0.20+8`, official TLC `1.7.4` jar.
* TLC jar SHA-256: `936a262061c914694dfd669a543be24573c45d5aa0ff20a8b96b23d01e050e88`.
* miniaudio 0.11.25, commit `9634bedb5b5a2ca38c1ee7108a9358a4e233f14d`;
  header and license hashes validated against `../miniaudio-zig/UPSTREAM.json`
  (sibling-relative from project root).
* Final source and observed candidate/tool hashes are in `source-snapshot.json`.
  No signature verification or atomic multi-repository snapshot is claimed.

## Checks

| Check | Result | Scope |
|---|---|---|
| Core Debug tests | 6/6 PASS | Includes 32,768 exhaustive five-action traces against an independent absolute-position oracle |
| Core ReleaseSafe tests | 6/6 PASS | Same contracts under optimized checked execution |
| Wrapper Debug / ReleaseSafe / null-only | 3/3 PASS in each | Real upstream C; explicit null device only |
| Independent package consumer | 1/1 PASS | Imported miniaudio module propagates native link dependency |
| Linux x86_64 GNU compile checks | PASS for wrapper and kernel/consumer | Cross-compilation/link only; nothing executed on Linux |
| macOS ARM64 compile attempt | Pure kernel compiled; audio consumer blocked | Missing CoreFoundation/CoreAudio/AudioToolbox SDK framework paths; retained `consumer-macos.log` |
| Vendor custody | PASS | Two unchanged pinned upstream files |
| Documentation map and local links | PASS | 35 authored/vendor files mapped across both packages; anchors and semantic correctness are outside this check |
| Zig formatting | PASS | Both packages' authored Zig source and manifests |
| Normal TLC model | PASS, 1,171 distinct states / 2,222 generated | Capacity 2; 3 positions; 2 epochs; safety plus fair-stop liveness |
| Missing authentication mutation | Expected counterexample | `AuthenticatedStreaming` violated |
| Stale-generation admission mutation | Expected counterexample | `WindowBounds` violated |
| Premature reclamation mutation | Expected counterexample | `QuiescentIdle` violated |
| Repeated-position mutation | Expected counterexample | `UniquePlayout` violated |

Raw TLC output including counterexamples is in `models.json`. Command receipts are
in `wrapper-runs.json` and `core-runs.json`; final freshness observations and reruns
are recorded separately in `source-snapshot.json`. Logs have descriptive names.
Source changes to callback completion added an epoch guard; core tests were rerun
after that change. Stale completion must not release a newer callback token.

## Limits and repairs

The initial build needed mandatory Zig package fingerprints and explicit enum types
in test expectations. A null-only backend option required `MA_ENABLE_NULL` as well
as `MA_ENABLE_ONLY_SPECIFIC_BACKENDS`. All were corrected before qualification.
Inherited Perl locale warnings were avoided with process-local C locale settings.

The TLA+ abstraction is not a proof of the Zig implementation, its memory model or
the upstream C library. The window has a separate manual inductive argument and
independent implementation tests. Host serialization, authenticated stream mapping,
callback quiescence and fairness remain explicit assumptions.

No physical audio, actual peer authentication, network streaming, drift correction,
macOS execution, Linux execution, hotplug stress, end-to-end latency measurements,
packaging or production release was completed. Existing QUIC/TLS/PASETO/ZSON
projects were inspected as candidates, not rewritten or independently certified.

The macOS command was `zig build check -j1 -Dtarget=aarch64-macos --summary all`.
It exited 1 due to missing Apple framework paths on this Windows host. No SDK was
silently substituted and no compile-only success is presented as device execution.
