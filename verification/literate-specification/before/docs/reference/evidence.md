# Evidence, preserved versions and generated outputs

Every existing evidence file is listed below. Source before-images preserve old bytes; logs and receipts are observations at their recorded revision, not current-source proofs. Read the associated phase RESULTS/receipt and migration map before interpreting old paths. The final handoff receipt is generated after this guide to avoid a self-hash cycle.

| Project-relative evidence path | Responsibility / handling |
| --- | --- |
| `lan-audio/verification/callback/before/.gitignore` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/callback/before/build.zig` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/callback/before/build.zig.zon` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/callback/before/docs/ARCHITECTURE.md` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/callback/before/docs/DEPENDENCIES.md` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/callback/before/docs/MATHEMATICS.md` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/callback/before/docs/PRODUCT.md` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/callback/before/docs/TRANSPORT.md` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/callback/before/docs/VERIFICATION.md` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/callback/before/README.md` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/callback/before/spec/EndDrain.cfg` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/callback/before/spec/EndDrain.tla` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/callback/before/spec/README.md` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/callback/before/spec/SessionWindow.cfg` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/callback/before/spec/SessionWindow.tla` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/callback/before/src/receiver.zig` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/callback/before/src/root.zig` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/callback/before/src/session.zig` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/callback/before/src/window.zig` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/callback/before/src/wire.zig` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/callback/before/tests/core.zig` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/callback/before/tests/dependency.zig` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/callback/before/tests/tls_probe.zig` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/callback/before/tests/wire.zig` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/callback/before/tools/check_docs.py` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/callback/before/tools/check_models.py` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/callback/before/tools/check_transport.py` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/callback/before/tools/test_transport.py` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/callback/before/transport-lock.json` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/callback/capture-retry.json` | Phase source/migration/command observations; verify named paths and hashes before drawing a freshness claim. |
| `lan-audio/verification/callback/capture-retry.log` | Raw command output; interpret with command, return code and target. Preserve failures; never relabel the text. |
| `lan-audio/verification/callback/core-0.log` | Raw command output; interpret with command, return code and target. Preserve failures; never relabel the text. |
| `lan-audio/verification/callback/core-1.log` | Raw command output; interpret with command, return code and target. Preserve failures; never relabel the text. |
| `lan-audio/verification/callback/core-2.log` | Raw command output; interpret with command, return code and target. Preserve failures; never relabel the text. |
| `lan-audio/verification/callback/core-3.log` | Raw command output; interpret with command, return code and target. Preserve failures; never relabel the text. |
| `lan-audio/verification/callback/core-4.log` | Raw command output; interpret with command, return code and target. Preserve failures; never relabel the text. |
| `lan-audio/verification/callback/core-runs.json` | Phase source/migration/command observations; verify named paths and hashes before drawing a freshness claim. |
| `lan-audio/verification/callback/device-0.log` | Raw command output; interpret with command, return code and target. Preserve failures; never relabel the text. |
| `lan-audio/verification/callback/device-1.log` | Raw command output; interpret with command, return code and target. Preserve failures; never relabel the text. |
| `lan-audio/verification/callback/device-2.log` | Raw command output; interpret with command, return code and target. Preserve failures; never relabel the text. |
| `lan-audio/verification/callback/device-runs.json` | Phase source/migration/command observations; verify named paths and hashes before drawing a freshness claim. |
| `lan-audio/verification/callback/interop-debug.json` | Independent peer observations; distinguish expected negative cases from harness defects. |
| `lan-audio/verification/callback/interop-first-run.json` | Independent peer observations; distinguish expected negative cases from harness defects. |
| `lan-audio/verification/callback/interop-safe-run.log` | Raw command output; interpret with command, return code and target. Preserve failures; never relabel the text. |
| `lan-audio/verification/callback/interop.json` | Independent peer observations; distinguish expected negative cases from harness defects. |
| `lan-audio/verification/callback/receipt.json` | Phase source/migration/command observations; verify named paths and hashes before drawing a freshness claim. |
| `lan-audio/verification/callback/RESULTS.md` | Human interpretation of this phase, including measured limits; historical when later source changes. |
| `lan-audio/verification/callback/spsc-model.json` | Bounded model execution and mutations; check spec/config/tool hashes and expected violations. |
| `lan-audio/verification/callback/transport-safe-build.json` | Phase source/migration/command observations; verify named paths and hashes before drawing a freshness claim. |
| `lan-audio/verification/callback/transport-safe-build.log` | Raw command output; interpret with command, return code and target. Preserve failures; never relabel the text. |
| `lan-audio/verification/consumer-debug.log` | Raw command output; interpret with command, return code and target. Preserve failures; never relabel the text. |
| `lan-audio/verification/consumer-linux.log` | Raw command output; interpret with command, return code and target. Preserve failures; never relabel the text. |
| `lan-audio/verification/consumer-macos.log` | Raw command output; interpret with command, return code and target. Preserve failures; never relabel the text. |
| `lan-audio/verification/core-debug.log` | Raw command output; interpret with command, return code and target. Preserve failures; never relabel the text. |
| `lan-audio/verification/core-runs.json` | Phase source/migration/command observations; verify named paths and hashes before drawing a freshness claim. |
| `lan-audio/verification/core-safe.log` | Raw command output; interpret with command, return code and target. Preserve failures; never relabel the text. |
| `lan-audio/verification/handoff/before/.gitignore` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/handoff/before/build.zig` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/handoff/before/build.zig.zon` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/handoff/before/docs/ARCHITECTURE.md` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/handoff/before/docs/CALLBACKS.md` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/handoff/before/docs/DEPENDENCIES.md` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/handoff/before/docs/MATHEMATICS.md` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/handoff/before/docs/PRODUCT.md` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/handoff/before/docs/TRANSPORT.md` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/handoff/before/docs/VERIFICATION.md` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/handoff/before/README.md` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/handoff/before/spec/EndDrain.cfg` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/handoff/before/spec/EndDrain.tla` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/handoff/before/spec/README.md` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/handoff/before/spec/SessionWindow.cfg` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/handoff/before/spec/SessionWindow.tla` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/handoff/before/spec/SpscPublication.cfg` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/handoff/before/spec/SpscPublication.tla` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/handoff/before/src/audio_device.zig` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/handoff/before/src/callback_bridge.zig` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/handoff/before/src/frame_queue.zig` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/handoff/before/src/receiver.zig` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/handoff/before/src/root.zig` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/handoff/before/src/session.zig` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/handoff/before/src/window.zig` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/handoff/before/src/wire.zig` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/handoff/before/tests/audio_device.zig` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/handoff/before/tests/callback.zig` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/handoff/before/tests/core.zig` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/handoff/before/tests/dependency.zig` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/handoff/before/tests/tls_probe.zig` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/handoff/before/tests/windows_capture.zig` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/handoff/before/tests/wire.zig` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/handoff/before/tools/check_docs.py` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/handoff/before/tools/check_models.py` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/handoff/before/tools/check_transport.py` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/handoff/before/tools/test_transport.py` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/handoff/before/transport-lock.json` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/handoff/core-0.log` | Raw command output; interpret with command, return code and target. Preserve failures; never relabel the text. |
| `lan-audio/verification/handoff/core-1.log` | Raw command output; interpret with command, return code and target. Preserve failures; never relabel the text. |
| `lan-audio/verification/handoff/core-2.log` | Raw command output; interpret with command, return code and target. Preserve failures; never relabel the text. |
| `lan-audio/verification/handoff/core-3.log` | Raw command output; interpret with command, return code and target. Preserve failures; never relabel the text. |
| `lan-audio/verification/handoff/core-4.log` | Raw command output; interpret with command, return code and target. Preserve failures; never relabel the text. |
| `lan-audio/verification/handoff/core-runs.json` | Phase source/migration/command observations; verify named paths and hashes before drawing a freshness claim. |
| `lan-audio/verification/handoff/EndDrain-model.json` | Bounded model execution and mutations; check spec/config/tool hashes and expected violations. |
| `lan-audio/verification/handoff/interop.json` | Independent peer observations; distinguish expected negative cases from harness defects. |
| `lan-audio/verification/handoff/migration.json` | Phase source/migration/command observations; verify named paths and hashes before drawing a freshness claim. |
| `lan-audio/verification/handoff/models-0.log` | Raw command output; interpret with command, return code and target. Preserve failures; never relabel the text. |
| `lan-audio/verification/handoff/models-1.log` | Raw command output; interpret with command, return code and target. Preserve failures; never relabel the text. |
| `lan-audio/verification/handoff/models-2.log` | Raw command output; interpret with command, return code and target. Preserve failures; never relabel the text. |
| `lan-audio/verification/handoff/models-runs.json` | Bounded model execution and mutations; check spec/config/tool hashes and expected violations. |
| `lan-audio/verification/handoff/native-0.log` | Raw command output; interpret with command, return code and target. Preserve failures; never relabel the text. |
| `lan-audio/verification/handoff/native-1.log` | Raw command output; interpret with command, return code and target. Preserve failures; never relabel the text. |
| `lan-audio/verification/handoff/native-2.log` | Raw command output; interpret with command, return code and target. Preserve failures; never relabel the text. |
| `lan-audio/verification/handoff/native-3.log` | Raw command output; interpret with command, return code and target. Preserve failures; never relabel the text. |
| `lan-audio/verification/handoff/native-4.log` | Raw command output; interpret with command, return code and target. Preserve failures; never relabel the text. |
| `lan-audio/verification/handoff/native-5.log` | Raw command output; interpret with command, return code and target. Preserve failures; never relabel the text. |
| `lan-audio/verification/handoff/native-runs.json` | Phase source/migration/command observations; verify named paths and hashes before drawing a freshness claim. |
| `lan-audio/verification/handoff/report-guards.json` | Phase source/migration/command observations; verify named paths and hashes before drawing a freshness claim. |
| `lan-audio/verification/handoff/RESULTS.md` | Human interpretation of this phase, including measured limits; historical when later source changes. |
| `lan-audio/verification/handoff/SessionWindow-model.json` | Bounded model execution and mutations; check spec/config/tool hashes and expected violations. |
| `lan-audio/verification/handoff/SpscPublication-model.json` | Bounded model execution and mutations; check spec/config/tool hashes and expected violations. |
| `lan-audio/verification/models.json` | Bounded model execution and mutations; check spec/config/tool hashes and expected violations. |
| `lan-audio/verification/RESULTS.md` | Human interpretation of this phase, including measured limits; historical when later source changes. |
| `lan-audio/verification/source-snapshot.json` | Phase source/migration/command observations; verify named paths and hashes before drawing a freshness claim. |
| `lan-audio/verification/transport/before/lan-audio/build.zig` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/transport/before/lan-audio/build.zig.zon` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/transport/before/lan-audio/docs/ARCHITECTURE.md` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/transport/before/lan-audio/docs/DEPENDENCIES.md` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/transport/before/lan-audio/docs/MATHEMATICS.md` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/transport/before/lan-audio/docs/PRODUCT.md` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/transport/before/lan-audio/docs/VERIFICATION.md` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/transport/before/lan-audio/README.md` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/transport/before/lan-audio/spec/README.md` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/transport/before/lan-audio/src/root.zig` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/transport/before/lan-audio/tests/core.zig` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/transport/before/lan-audio/tools/check_models.py` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/transport/before/tls-zig/build.zig.zon` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/transport/before/tls-zig/README.md` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/transport/before/tls-zig/src/backend.c` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/transport/before/tls-zig/src/backend.h` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/transport/before/tls-zig/src/backend.zig` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/transport/before/tls-zig/src/root.zig` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/transport/before/tls-zig/tests/transport.zig` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/transport/core-0.log` | Raw command output; interpret with command, return code and target. Preserve failures; never relabel the text. |
| `lan-audio/verification/transport/core-1.log` | Raw command output; interpret with command, return code and target. Preserve failures; never relabel the text. |
| `lan-audio/verification/transport/core-2.log` | Raw command output; interpret with command, return code and target. Preserve failures; never relabel the text. |
| `lan-audio/verification/transport/core-3.log` | Raw command output; interpret with command, return code and target. Preserve failures; never relabel the text. |
| `lan-audio/verification/transport/core-4.log` | Raw command output; interpret with command, return code and target. Preserve failures; never relabel the text. |
| `lan-audio/verification/transport/core-runs.json` | Phase source/migration/command observations; verify named paths and hashes before drawing a freshness claim. |
| `lan-audio/verification/transport/end-model.json` | Bounded model execution and mutations; check spec/config/tool hashes and expected violations. |
| `lan-audio/verification/transport/interop.json` | Independent peer observations; distinguish expected negative cases from harness defects. |
| `lan-audio/verification/transport/receipt.json` | Phase source/migration/command observations; verify named paths and hashes before drawing a freshness claim. |
| `lan-audio/verification/transport/RESULTS.md` | Human interpretation of this phase, including measured limits; historical when later source changes. |
| `lan-audio/verification/transport/tls-0.log` | Raw command output; interpret with command, return code and target. Preserve failures; never relabel the text. |
| `lan-audio/verification/transport/tls-1.log` | Raw command output; interpret with command, return code and target. Preserve failures; never relabel the text. |
| `lan-audio/verification/transport/tls-2.log` | Raw command output; interpret with command, return code and target. Preserve failures; never relabel the text. |
| `lan-audio/verification/transport/tls-3.log` | Raw command output; interpret with command, return code and target. Preserve failures; never relabel the text. |
| `lan-audio/verification/transport/tls-runs.json` | Phase source/migration/command observations; verify named paths and hashes before drawing a freshness claim. |
| `lan-audio/verification/vendor.log` | Raw command output; interpret with command, return code and target. Preserve failures; never relabel the text. |
| `lan-audio/verification/wrapper-debug.log` | Raw command output; interpret with command, return code and target. Preserve failures; never relabel the text. |
| `lan-audio/verification/wrapper-linux.log` | Raw command output; interpret with command, return code and target. Preserve failures; never relabel the text. |
| `lan-audio/verification/wrapper-null.log` | Raw command output; interpret with command, return code and target. Preserve failures; never relabel the text. |
| `lan-audio/verification/wrapper-runs.json` | Phase source/migration/command observations; verify named paths and hashes before drawing a freshness claim. |
| `lan-audio/verification/wrapper-safe.log` | Raw command output; interpret with command, return code and target. Preserve failures; never relabel the text. |

`verification/handoff/receipt.json` is the final handoff observation. `.zig-cache/`, `.zig-global-cache/`, `zig-out/`, `__pycache__/` and TLC `states/` are generated artifacts, not authored contracts. They must be reproducible or safely disposable; never move their contents into source or treat a cached executable as fresh evidence.
