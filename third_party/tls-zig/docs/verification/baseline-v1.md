# Current source and verification â€” 2026-09-26

Current maintained directory observed for this work: `C:/Projects/tls-zig`. SOURCE-ORIGIN.json and older checkpoints contain historical relocation paths. This directory is not a Git checkout; a byte-hashed baseline was preserved before edits.

Package version: 0.1.5. Compiler: `0.17.0-dev.1859+dcceb318e`.

Baseline native Debug tests passed before documentation edits: 19 TLS Engine tests and 11 Driver tests. Final annotated-source qualification **passed**; commands, exit codes and logs are recorded in [run-results.json](run-results.json). Historical counts in older docs are not substituted for the current run.

## Present capability

TLS 1.3 records Engine with configurable single owned ALPN (0.1.5), explicit trust/identity checks and serialized Driver with early-response probes. Windows private OpenSSL 3.5.8 build. No recordless QUIC API, total provider resource bound or revocation profile.

## Documentation scope

46 existing first-party/fixture/metadata/maintenance files have source-bound contracts. 166 upstream SDK files have individual provenance/role/maintenance records. 15 proposed implementation/test files have design cards. New docs are indexed separately to avoid recursive dossier generation. This pass adds comments, documentation, maintenance checks and package documentation paths; it does not change protocol algorithms.

## Commands

```text
python tools/check-docs.py --self-test --with-sdk
python tools/check-models.py
zig build test -j1 --summary all
zig build test -j1 -Doptimize=ReleaseSafe --summary all
zig build host-test interop example -j1 --summary all
```

TLS additionally builds examples/consumer and runs tools/tcp_interop.py, tools/tcp_server_interop.py and tools/tcp_upload_interop.py without Python optimization. SDK acquisition/rebuild is not needed when the locked dependency is present and verified. The source-only handoff archive excludes SDK binaries and caches; supply the locked SDK separately.

## Final results

Debug and ReleaseSafe each passed all 19 Engine and 11 Driver tests. The public example, standalone consumer build, 17 memory-BIO interoperability cases and 14 TCP client/server/upload cases passed. Formatting and all 166 SDK hashes/file-set checks passed.

The documentation checker passed its four negative controls; the three bounded safety models passed and each detected its injected fault. See [requirement traceability](requirements.md), [change audit](change-audit.json) and [run receipt](run-results.json). These are scoped checks, not proof of production readiness.
