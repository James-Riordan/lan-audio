# WP01 — Native target and dependency builds

Status: planned. Acceptance: A6/A7 contribution; prerequisite for Mac execution.

## Inspect first

Read `build.zig`, `../miniaudio-zig/build.zig`, `../tls-zig/build.zig`, both manifests,
the TLS source/provenance and backend lock, and the dependency file reference.
Record exact Windows adapter/driver/OS, Mac model/macOS/CPU, available Apple SDK,
Zig executable hash and C toolchain. The 2019 Mac target is x86_64; ARM64 remains
a separate optional qualification. Do not infer the deployment target from the
latest available SDK or install/upgrade the user's OS.

## Files and changes

| File | Implement / preserve |
| --- | --- |
| `../tls-zig/build.zig` | Split target-specific import/runtime linking: retain Windows DLL import libraries; add validated Darwin library linking and runtime location without ambient global-library dependence. |
| `../tls-zig/tools/build-openssl-macos.sh` (planned) | Reproduce the adopted OpenSSL source on Intel Mac with explicit SDK/deployment target; validate source hash; keep build/install inside its own designated paths. |
| `../tls-zig/backend-lock.macos.json` (planned) | Record target-specific SDK artifacts, source/config/tool identities and runtime dependency closure; never overwrite the Windows lock to add Mac. |
| `../miniaudio-zig/build.zig` | Supply/verify Apple SDK framework resolution; retain one matching C/translation profile and Linux/Windows behavior. No second copy of miniaudio implementation. |
| `build.zig` | Build core and optional audio/TLS host modules for the selected target; make unsupported combinations fail descriptively before installing a wrong binary. |
| `tools/check_transport.py`, `transport-lock.json` | After deliberate dependency adoption, support target-specific reviewed custody. Preserve previous pins and receipts; verifier cannot regenerate them. |

## Procedure and gates

Build existing core, null audio and independent TLS consumer on both actual hosts.
On Mac, inspect Mach-O architecture and dynamic imports, run with a clean runtime
search environment and prove it loads the packaged/private libraries. Confirm
compiler/SDK/deployment compatibility against the actual installed OS. Run TLS
authentication, ALPN and closure regressions on both platforms; Linux compile
must not be relabeled as execution. Preserve HTTP-default and original C ABI tests.

Mac audio initialization plus active callback teardown is required; an object file
or translated C header is insufficient. Save build logs and native error diagnostics.
No product credentials or source capture are needed to validate null callbacks.

## Failure and completion

Missing SDK/host is a recorded blocker for the Mac gate. Continue WP02 and simulation.
Never solve missing runtime files by trusting arbitrary PATH/DYLD search results.
On build failure, retain source and logs, clean only the identified generated build
directory when necessary, and preserve prior working SDKs. Complete when both native
host receipts pass and runtime custody matches the intended target.
