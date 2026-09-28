# Evidence, preserved versions and generated outputs

Evidence files are listed below; the final phase receipts named at the end are generated after this guide to avoid a self-hash cycle. Source before-images preserve old bytes; logs and receipts are observations at their recorded revision, not current-source proofs. Read the associated phase RESULTS/receipt and migration map before interpreting old paths.

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
| `lan-audio/verification/ecosystem-alignment/before/.gitignore` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/ecosystem-alignment/before/AGENTS.md` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/ecosystem-alignment/before/build.zig` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/ecosystem-alignment/before/build.zig.zon` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/ecosystem-alignment/before/docs/architecture/modules.md` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/ecosystem-alignment/before/docs/architecture/platform-capabilities.md` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/ecosystem-alignment/before/docs/ARCHITECTURE.md` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/ecosystem-alignment/before/docs/CALLBACKS.md` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/ecosystem-alignment/before/docs/DEPENDENCIES.md` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/ecosystem-alignment/before/docs/design/receive-drain.md` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/ecosystem-alignment/before/docs/design/system-mathematics.md` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/ecosystem-alignment/before/docs/development/documentation.md` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/ecosystem-alignment/before/docs/development/workflow.md` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/ecosystem-alignment/before/docs/implementation/completion-sequence.md` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/ecosystem-alignment/before/docs/implementation/decisions.md` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/ecosystem-alignment/before/docs/implementation/interfaces.md` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/ecosystem-alignment/before/docs/implementation/layout.md` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/ecosystem-alignment/before/docs/implementation/roadmap.md` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/ecosystem-alignment/before/docs/implementation/runtime-blueprint.md` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/ecosystem-alignment/before/docs/implementation/START_HERE.md` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/ecosystem-alignment/before/docs/implementation/work-packages/01-target-builds.md` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/ecosystem-alignment/before/docs/implementation/work-packages/02-fidelity-protocol.md` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/ecosystem-alignment/before/docs/implementation/work-packages/03-identity-endpoints.md` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/ecosystem-alignment/before/docs/implementation/work-packages/04-first-sound.md` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/ecosystem-alignment/before/docs/implementation/work-packages/05-timing-clocks.md` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/ecosystem-alignment/before/docs/implementation/work-packages/06-network-resilience.md` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/ecosystem-alignment/before/docs/implementation/work-packages/07-observability.md` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/ecosystem-alignment/before/docs/implementation/work-packages/08-user-experience.md` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/ecosystem-alignment/before/docs/implementation/work-packages/09-packaging.md` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/ecosystem-alignment/before/docs/implementation/work-packages/10-qualification.md` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/ecosystem-alignment/before/docs/literate/proof-ledger.md` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/ecosystem-alignment/before/docs/literate/quantitative-design.md` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/ecosystem-alignment/before/docs/literate/README.md` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/ecosystem-alignment/before/docs/literate/runtime-argument.md` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/ecosystem-alignment/before/docs/literate/stream-argument.md` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/ecosystem-alignment/before/docs/MATHEMATICS.md` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/ecosystem-alignment/before/docs/media/assembly.md` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/ecosystem-alignment/before/docs/media/pending-block.md` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/ecosystem-alignment/before/docs/PRODUCT.md` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/ecosystem-alignment/before/docs/protocol/negotiation.md` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/ecosystem-alignment/before/docs/protocol/v2.md` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/ecosystem-alignment/before/docs/README.md` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/ecosystem-alignment/before/docs/reference/api-contracts.md` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/ecosystem-alignment/before/docs/reference/evidence.md` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/ecosystem-alignment/before/docs/reference/file-index.json` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/ecosystem-alignment/before/docs/reference/lan-audio.md` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/ecosystem-alignment/before/docs/reference/miniaudio-zig.md` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/ecosystem-alignment/before/docs/reference/README.md` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/ecosystem-alignment/before/docs/reference/tls-zig.md` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/ecosystem-alignment/before/docs/reference/upstream-assets.md` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/ecosystem-alignment/before/docs/TRANSPORT.md` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/ecosystem-alignment/before/docs/verification/acceptance-matrix.md` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/ecosystem-alignment/before/docs/verification/runtime-obligations.md` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/ecosystem-alignment/before/docs/verification/scenarios.md` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/ecosystem-alignment/before/docs/verification/v2-independent.md` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/ecosystem-alignment/before/docs/VERIFICATION.md` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/ecosystem-alignment/before/README.md` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/ecosystem-alignment/before/spec/concurrency/SpscPublication.cfg` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/ecosystem-alignment/before/spec/concurrency/SpscPublication.tla` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/ecosystem-alignment/before/spec/README.md` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/ecosystem-alignment/before/spec/runtime/ReceiveDrain.cfg` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/ecosystem-alignment/before/spec/runtime/ReceiveDrain.tla` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/ecosystem-alignment/before/spec/runtime/RuntimeOwnership.cfg` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/ecosystem-alignment/before/spec/runtime/RuntimeOwnership.tla` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/ecosystem-alignment/before/spec/session/SessionWindow.cfg` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/ecosystem-alignment/before/spec/session/SessionWindow.tla` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/ecosystem-alignment/before/spec/stream/EndDrain.cfg` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/ecosystem-alignment/before/spec/stream/EndDrain.tla` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/ecosystem-alignment/before/src/audio/callback_bridge.zig` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/ecosystem-alignment/before/src/audio/frame_queue.zig` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/ecosystem-alignment/before/src/host/audio_device.zig` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/ecosystem-alignment/before/src/media/block_assembler.zig` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/ecosystem-alignment/before/src/media/format.zig` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/ecosystem-alignment/before/src/media/playout_window.zig` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/ecosystem-alignment/before/src/protocol/negotiation.zig` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/ecosystem-alignment/before/src/protocol/v1.zig` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/ecosystem-alignment/before/src/protocol/v2.zig` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/ecosystem-alignment/before/src/README.md` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/ecosystem-alignment/before/src/root.zig` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/ecosystem-alignment/before/src/runtime/pending_block.zig` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/ecosystem-alignment/before/src/session/receiver.zig` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/ecosystem-alignment/before/src/session/session.zig` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/ecosystem-alignment/before/tests/dependency.zig` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/ecosystem-alignment/before/tests/hardware/windows_capture.zig` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/ecosystem-alignment/before/tests/integration/audio_device.zig` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/ecosystem-alignment/before/tests/integration/loopback_transport.zig` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/ecosystem-alignment/before/tests/integration/protocol_v2_peer.py` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/ecosystem-alignment/before/tests/integration/protocol_v2_reference.py` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/ecosystem-alignment/before/tests/integration/tls_receiver.zig` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/ecosystem-alignment/before/tests/integration/tls_v2.zig` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/ecosystem-alignment/before/tests/integration/v2_codec_probe.zig` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/ecosystem-alignment/before/tests/unit/callback.zig` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/ecosystem-alignment/before/tests/unit/core.zig` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/ecosystem-alignment/before/tests/unit/media/assembler.zig` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/ecosystem-alignment/before/tests/unit/protocol/negotiation.zig` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/ecosystem-alignment/before/tests/unit/protocol/v2.zig` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/ecosystem-alignment/before/tests/unit/runtime/pending_block.zig` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/ecosystem-alignment/before/tests/unit/wire.zig` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/ecosystem-alignment/before/tools/build_reference.py` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/ecosystem-alignment/before/tools/check_docs.py` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/ecosystem-alignment/before/tools/check_handoff.py` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/ecosystem-alignment/before/tools/check_models.py` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/ecosystem-alignment/before/tools/check_transport.py` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/ecosystem-alignment/before/tools/reference_contracts.json` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/ecosystem-alignment/before/tools/test_transport.py` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/ecosystem-alignment/before/tools/test_v2_differential.py` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/ecosystem-alignment/before/transport-lock.json` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/ecosystem-alignment/before.json` | Phase source/migration/command observations; verify named paths and hashes before drawing a freshness claim. |
| `lan-audio/verification/ecosystem-alignment/checks.json` | Phase source/migration/command observations; verify named paths and hashes before drawing a freshness claim. |
| `lan-audio/verification/ecosystem-alignment/dependency-integration.json` | Phase source/migration/command observations; verify named paths and hashes before drawing a freshness claim. |
| `lan-audio/verification/ecosystem-alignment/dependency-review-observation.json` | Phase source/migration/command observations; verify named paths and hashes before drawing a freshness claim. |
| `lan-audio/verification/ecosystem-alignment/RESULTS.md` | Human interpretation of this phase, including measured limits; historical when later source changes. |
| `lan-audio/verification/fidelity-core/before/.gitignore` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/fidelity-core/before/AGENTS.md` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/fidelity-core/before/build.zig` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/fidelity-core/before/build.zig.zon` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/fidelity-core/before/docs/ARCHITECTURE.md` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/fidelity-core/before/docs/CALLBACKS.md` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/fidelity-core/before/docs/DEPENDENCIES.md` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/fidelity-core/before/docs/design/system-mathematics.md` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/fidelity-core/before/docs/implementation/decisions.md` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/fidelity-core/before/docs/implementation/interfaces.md` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/fidelity-core/before/docs/implementation/layout.md` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/fidelity-core/before/docs/implementation/roadmap.md` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/fidelity-core/before/docs/implementation/START_HERE.md` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/fidelity-core/before/docs/implementation/work-packages/01-target-builds.md` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/fidelity-core/before/docs/implementation/work-packages/02-fidelity-protocol.md` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/fidelity-core/before/docs/implementation/work-packages/03-identity-endpoints.md` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/fidelity-core/before/docs/implementation/work-packages/04-first-sound.md` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/fidelity-core/before/docs/implementation/work-packages/05-timing-clocks.md` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/fidelity-core/before/docs/implementation/work-packages/06-network-resilience.md` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/fidelity-core/before/docs/implementation/work-packages/07-observability.md` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/fidelity-core/before/docs/implementation/work-packages/08-user-experience.md` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/fidelity-core/before/docs/implementation/work-packages/09-packaging.md` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/fidelity-core/before/docs/implementation/work-packages/10-qualification.md` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/fidelity-core/before/docs/literate/proof-ledger.md` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/fidelity-core/before/docs/literate/quantitative-design.md` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/fidelity-core/before/docs/literate/README.md` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/fidelity-core/before/docs/literate/runtime-argument.md` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/fidelity-core/before/docs/literate/stream-argument.md` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/fidelity-core/before/docs/MATHEMATICS.md` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/fidelity-core/before/docs/PRODUCT.md` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/fidelity-core/before/docs/reference/api-contracts.md` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/fidelity-core/before/docs/reference/evidence.md` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/fidelity-core/before/docs/reference/file-index.json` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/fidelity-core/before/docs/reference/lan-audio.md` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/fidelity-core/before/docs/reference/miniaudio-zig.md` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/fidelity-core/before/docs/reference/README.md` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/fidelity-core/before/docs/reference/tls-zig.md` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/fidelity-core/before/docs/reference/upstream-assets.md` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/fidelity-core/before/docs/TRANSPORT.md` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/fidelity-core/before/docs/VERIFICATION.md` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/fidelity-core/before/README.md` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/fidelity-core/before/spec/concurrency/SpscPublication.cfg` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/fidelity-core/before/spec/concurrency/SpscPublication.tla` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/fidelity-core/before/spec/README.md` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/fidelity-core/before/spec/runtime/RuntimeOwnership.cfg` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/fidelity-core/before/spec/runtime/RuntimeOwnership.tla` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/fidelity-core/before/spec/session/SessionWindow.cfg` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/fidelity-core/before/spec/session/SessionWindow.tla` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/fidelity-core/before/spec/stream/EndDrain.cfg` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/fidelity-core/before/spec/stream/EndDrain.tla` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/fidelity-core/before/src/audio/callback_bridge.zig` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/fidelity-core/before/src/audio/frame_queue.zig` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/fidelity-core/before/src/host/audio_device.zig` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/fidelity-core/before/src/media/playout_window.zig` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/fidelity-core/before/src/protocol/v1.zig` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/fidelity-core/before/src/root.zig` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/fidelity-core/before/src/session/receiver.zig` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/fidelity-core/before/src/session/session.zig` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/fidelity-core/before/tests/dependency.zig` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/fidelity-core/before/tests/hardware/windows_capture.zig` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/fidelity-core/before/tests/integration/audio_device.zig` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/fidelity-core/before/tests/integration/tls_receiver.zig` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/fidelity-core/before/tests/unit/callback.zig` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/fidelity-core/before/tests/unit/core.zig` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/fidelity-core/before/tests/unit/wire.zig` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/fidelity-core/before/tools/build_reference.py` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/fidelity-core/before/tools/check_docs.py` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/fidelity-core/before/tools/check_handoff.py` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/fidelity-core/before/tools/check_models.py` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/fidelity-core/before/tools/check_transport.py` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/fidelity-core/before/tools/reference_contracts.json` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/fidelity-core/before/tools/test_transport.py` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/fidelity-core/before/transport-lock.json` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/fidelity-core/before.json` | Phase source/migration/command observations; verify named paths and hashes before drawing a freshness claim. |
| `lan-audio/verification/fidelity-core/compile-attempt1-note.txt` | Phase source/migration/command observations; verify named paths and hashes before drawing a freshness claim. |
| `lan-audio/verification/fidelity-core/compile-attempt2-source.zig` | Phase source/migration/command observations; verify named paths and hashes before drawing a freshness claim. |
| `lan-audio/verification/fidelity-core/core-debug-attempt2.json` | Phase source/migration/command observations; verify named paths and hashes before drawing a freshness claim. |
| `lan-audio/verification/fidelity-core/core-debug-attempt2.log` | Raw command output; interpret with command, return code and target. Preserve failures; never relabel the text. |
| `lan-audio/verification/fidelity-core/document-checks.json` | Phase source/migration/command observations; verify named paths and hashes before drawing a freshness claim. |
| `lan-audio/verification/fidelity-core/final-0.log` | Raw command output; interpret with command, return code and target. Preserve failures; never relabel the text. |
| `lan-audio/verification/fidelity-core/final-1.log` | Raw command output; interpret with command, return code and target. Preserve failures; never relabel the text. |
| `lan-audio/verification/fidelity-core/final-2.log` | Raw command output; interpret with command, return code and target. Preserve failures; never relabel the text. |
| `lan-audio/verification/fidelity-core/final-3.log` | Raw command output; interpret with command, return code and target. Preserve failures; never relabel the text. |
| `lan-audio/verification/fidelity-core/final-4.log` | Raw command output; interpret with command, return code and target. Preserve failures; never relabel the text. |
| `lan-audio/verification/fidelity-core/final-commands.json` | Phase source/migration/command observations; verify named paths and hashes before drawing a freshness claim. |
| `lan-audio/verification/fidelity-core/RESULTS.md` | Human interpretation of this phase, including measured limits; historical when later source changes. |
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
| `lan-audio/verification/literate-specification/before/.gitignore` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/literate-specification/before/AGENTS.md` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/literate-specification/before/build.zig` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/literate-specification/before/build.zig.zon` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/literate-specification/before/docs/ARCHITECTURE.md` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/literate-specification/before/docs/CALLBACKS.md` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/literate-specification/before/docs/DEPENDENCIES.md` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/literate-specification/before/docs/design/system-mathematics.md` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/literate-specification/before/docs/implementation/decisions.md` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/literate-specification/before/docs/implementation/interfaces.md` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/literate-specification/before/docs/implementation/layout.md` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/literate-specification/before/docs/implementation/roadmap.md` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/literate-specification/before/docs/implementation/START_HERE.md` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/literate-specification/before/docs/implementation/work-packages/01-target-builds.md` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/literate-specification/before/docs/implementation/work-packages/02-fidelity-protocol.md` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/literate-specification/before/docs/implementation/work-packages/03-identity-endpoints.md` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/literate-specification/before/docs/implementation/work-packages/04-first-sound.md` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/literate-specification/before/docs/implementation/work-packages/05-timing-clocks.md` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/literate-specification/before/docs/implementation/work-packages/06-network-resilience.md` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/literate-specification/before/docs/implementation/work-packages/07-observability.md` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/literate-specification/before/docs/implementation/work-packages/08-user-experience.md` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/literate-specification/before/docs/implementation/work-packages/09-packaging.md` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/literate-specification/before/docs/implementation/work-packages/10-qualification.md` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/literate-specification/before/docs/MATHEMATICS.md` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/literate-specification/before/docs/PRODUCT.md` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/literate-specification/before/docs/reference/api-contracts.md` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/literate-specification/before/docs/reference/evidence.md` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/literate-specification/before/docs/reference/file-index.json` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/literate-specification/before/docs/reference/lan-audio.md` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/literate-specification/before/docs/reference/miniaudio-zig.md` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/literate-specification/before/docs/reference/README.md` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/literate-specification/before/docs/reference/tls-zig.md` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/literate-specification/before/docs/reference/upstream-assets.md` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/literate-specification/before/docs/TRANSPORT.md` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/literate-specification/before/docs/VERIFICATION.md` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/literate-specification/before/README.md` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/literate-specification/before/spec/concurrency/SpscPublication.cfg` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/literate-specification/before/spec/concurrency/SpscPublication.tla` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/literate-specification/before/spec/README.md` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/literate-specification/before/spec/session/SessionWindow.cfg` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/literate-specification/before/spec/session/SessionWindow.tla` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/literate-specification/before/spec/stream/EndDrain.cfg` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/literate-specification/before/spec/stream/EndDrain.tla` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/literate-specification/before/src/audio/callback_bridge.zig` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/literate-specification/before/src/audio/frame_queue.zig` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/literate-specification/before/src/host/audio_device.zig` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/literate-specification/before/src/media/playout_window.zig` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/literate-specification/before/src/protocol/v1.zig` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/literate-specification/before/src/root.zig` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/literate-specification/before/src/session/receiver.zig` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/literate-specification/before/src/session/session.zig` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/literate-specification/before/tests/dependency.zig` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/literate-specification/before/tests/hardware/windows_capture.zig` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/literate-specification/before/tests/integration/audio_device.zig` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/literate-specification/before/tests/integration/tls_receiver.zig` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/literate-specification/before/tests/unit/callback.zig` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/literate-specification/before/tests/unit/core.zig` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/literate-specification/before/tests/unit/wire.zig` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/literate-specification/before/tools/build_reference.py` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/literate-specification/before/tools/check_docs.py` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/literate-specification/before/tools/check_handoff.py` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/literate-specification/before/tools/check_models.py` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/literate-specification/before/tools/check_transport.py` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/literate-specification/before/tools/reference_contracts.json` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/literate-specification/before/tools/test_transport.py` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/literate-specification/before/transport-lock.json` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/literate-specification/before.json` | Phase source/migration/command observations; verify named paths and hashes before drawing a freshness claim. |
| `lan-audio/verification/literate-specification/controller-root-check.json` | Phase source/migration/command observations; verify named paths and hashes before drawing a freshness claim. |
| `lan-audio/verification/literate-specification/EndDrain-final.json` | Phase source/migration/command observations; verify named paths and hashes before drawing a freshness claim. |
| `lan-audio/verification/literate-specification/model-commands.json` | Bounded model execution and mutations; check spec/config/tool hashes and expected violations. |
| `lan-audio/verification/literate-specification/RESULTS.md` | Human interpretation of this phase, including measured limits; historical when later source changes. |
| `lan-audio/verification/literate-specification/runtime-attempt1.tla` | Phase source/migration/command observations; verify named paths and hashes before drawing a freshness claim. |
| `lan-audio/verification/literate-specification/runtime-command-attempt1.json` | Phase source/migration/command observations; verify named paths and hashes before drawing a freshness claim. |
| `lan-audio/verification/literate-specification/runtime-command.json` | Phase source/migration/command observations; verify named paths and hashes before drawing a freshness claim. |
| `lan-audio/verification/literate-specification/runtime-model-attempt1.json` | Bounded model execution and mutations; check spec/config/tool hashes and expected violations. |
| `lan-audio/verification/literate-specification/runtime-model.json` | Bounded model execution and mutations; check spec/config/tool hashes and expected violations. |
| `lan-audio/verification/literate-specification/RuntimeOwnership-final.json` | Phase source/migration/command observations; verify named paths and hashes before drawing a freshness claim. |
| `lan-audio/verification/literate-specification/SessionWindow-final.json` | Phase source/migration/command observations; verify named paths and hashes before drawing a freshness claim. |
| `lan-audio/verification/literate-specification/SpscPublication-final.json` | Phase source/migration/command observations; verify named paths and hashes before drawing a freshness claim. |
| `lan-audio/verification/models.json` | Bounded model execution and mutations; check spec/config/tool hashes and expected violations. |
| `lan-audio/verification/pending-custody/before/.gitignore` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/pending-custody/before/AGENTS.md` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/pending-custody/before/build.zig` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/pending-custody/before/build.zig.zon` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/pending-custody/before/docs/architecture/modules.md` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/pending-custody/before/docs/architecture/platform-capabilities.md` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/pending-custody/before/docs/ARCHITECTURE.md` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/pending-custody/before/docs/CALLBACKS.md` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/pending-custody/before/docs/DEPENDENCIES.md` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/pending-custody/before/docs/design/receive-drain.md` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/pending-custody/before/docs/design/system-mathematics.md` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/pending-custody/before/docs/development/documentation.md` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/pending-custody/before/docs/development/workflow.md` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/pending-custody/before/docs/implementation/completion-sequence.md` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/pending-custody/before/docs/implementation/decisions.md` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/pending-custody/before/docs/implementation/interfaces.md` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/pending-custody/before/docs/implementation/layout.md` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/pending-custody/before/docs/implementation/roadmap.md` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/pending-custody/before/docs/implementation/runtime-blueprint.md` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/pending-custody/before/docs/implementation/START_HERE.md` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/pending-custody/before/docs/implementation/work-packages/01-target-builds.md` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/pending-custody/before/docs/implementation/work-packages/02-fidelity-protocol.md` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/pending-custody/before/docs/implementation/work-packages/03-identity-endpoints.md` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/pending-custody/before/docs/implementation/work-packages/04-first-sound.md` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/pending-custody/before/docs/implementation/work-packages/05-timing-clocks.md` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/pending-custody/before/docs/implementation/work-packages/06-network-resilience.md` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/pending-custody/before/docs/implementation/work-packages/07-observability.md` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/pending-custody/before/docs/implementation/work-packages/08-user-experience.md` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/pending-custody/before/docs/implementation/work-packages/09-packaging.md` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/pending-custody/before/docs/implementation/work-packages/10-qualification.md` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/pending-custody/before/docs/literate/proof-ledger.md` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/pending-custody/before/docs/literate/quantitative-design.md` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/pending-custody/before/docs/literate/README.md` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/pending-custody/before/docs/literate/runtime-argument.md` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/pending-custody/before/docs/literate/stream-argument.md` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/pending-custody/before/docs/MATHEMATICS.md` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/pending-custody/before/docs/media/assembly.md` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/pending-custody/before/docs/PRODUCT.md` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/pending-custody/before/docs/protocol/negotiation.md` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/pending-custody/before/docs/protocol/v2.md` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/pending-custody/before/docs/README.md` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/pending-custody/before/docs/reference/api-contracts.md` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/pending-custody/before/docs/reference/evidence.md` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/pending-custody/before/docs/reference/file-index.json` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/pending-custody/before/docs/reference/lan-audio.md` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/pending-custody/before/docs/reference/miniaudio-zig.md` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/pending-custody/before/docs/reference/README.md` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/pending-custody/before/docs/reference/tls-zig.md` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/pending-custody/before/docs/reference/upstream-assets.md` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/pending-custody/before/docs/TRANSPORT.md` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/pending-custody/before/docs/verification/acceptance-matrix.md` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/pending-custody/before/docs/verification/runtime-obligations.md` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/pending-custody/before/docs/verification/scenarios.md` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/pending-custody/before/docs/verification/v2-independent.md` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/pending-custody/before/docs/VERIFICATION.md` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/pending-custody/before/README.md` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/pending-custody/before/spec/concurrency/SpscPublication.cfg` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/pending-custody/before/spec/concurrency/SpscPublication.tla` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/pending-custody/before/spec/README.md` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/pending-custody/before/spec/runtime/ReceiveDrain.cfg` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/pending-custody/before/spec/runtime/ReceiveDrain.tla` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/pending-custody/before/spec/runtime/RuntimeOwnership.cfg` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/pending-custody/before/spec/runtime/RuntimeOwnership.tla` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/pending-custody/before/spec/session/SessionWindow.cfg` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/pending-custody/before/spec/session/SessionWindow.tla` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/pending-custody/before/spec/stream/EndDrain.cfg` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/pending-custody/before/spec/stream/EndDrain.tla` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/pending-custody/before/src/audio/callback_bridge.zig` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/pending-custody/before/src/audio/frame_queue.zig` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/pending-custody/before/src/host/audio_device.zig` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/pending-custody/before/src/media/block_assembler.zig` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/pending-custody/before/src/media/format.zig` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/pending-custody/before/src/media/playout_window.zig` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/pending-custody/before/src/protocol/negotiation.zig` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/pending-custody/before/src/protocol/v1.zig` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/pending-custody/before/src/protocol/v2.zig` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/pending-custody/before/src/README.md` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/pending-custody/before/src/root.zig` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/pending-custody/before/src/session/receiver.zig` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/pending-custody/before/src/session/session.zig` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/pending-custody/before/tests/dependency.zig` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/pending-custody/before/tests/hardware/windows_capture.zig` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/pending-custody/before/tests/integration/audio_device.zig` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/pending-custody/before/tests/integration/loopback_transport.zig` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/pending-custody/before/tests/integration/protocol_v2_peer.py` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/pending-custody/before/tests/integration/protocol_v2_reference.py` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/pending-custody/before/tests/integration/tls_receiver.zig` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/pending-custody/before/tests/integration/tls_v2.zig` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/pending-custody/before/tests/integration/v2_codec_probe.zig` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/pending-custody/before/tests/unit/callback.zig` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/pending-custody/before/tests/unit/core.zig` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/pending-custody/before/tests/unit/media/assembler.zig` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/pending-custody/before/tests/unit/protocol/negotiation.zig` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/pending-custody/before/tests/unit/protocol/v2.zig` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/pending-custody/before/tests/unit/wire.zig` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/pending-custody/before/tools/build_reference.py` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/pending-custody/before/tools/check_docs.py` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/pending-custody/before/tools/check_handoff.py` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/pending-custody/before/tools/check_models.py` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/pending-custody/before/tools/check_transport.py` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/pending-custody/before/tools/reference_contracts.json` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/pending-custody/before/tools/test_transport.py` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/pending-custody/before/tools/test_v2_differential.py` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/pending-custody/before/transport-lock.json` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/pending-custody/before.json` | Phase source/migration/command observations; verify named paths and hashes before drawing a freshness claim. |
| `lan-audio/verification/pending-custody/command-0.log` | Raw command output; interpret with command, return code and target. Preserve failures; never relabel the text. |
| `lan-audio/verification/pending-custody/command-1.log` | Raw command output; interpret with command, return code and target. Preserve failures; never relabel the text. |
| `lan-audio/verification/pending-custody/command-2.log` | Raw command output; interpret with command, return code and target. Preserve failures; never relabel the text. |
| `lan-audio/verification/pending-custody/command-3.log` | Raw command output; interpret with command, return code and target. Preserve failures; never relabel the text. |
| `lan-audio/verification/pending-custody/command-4.log` | Raw command output; interpret with command, return code and target. Preserve failures; never relabel the text. |
| `lan-audio/verification/pending-custody/command-5.log` | Raw command output; interpret with command, return code and target. Preserve failures; never relabel the text. |
| `lan-audio/verification/pending-custody/command-6.log` | Raw command output; interpret with command, return code and target. Preserve failures; never relabel the text. |
| `lan-audio/verification/pending-custody/commands.json` | Phase source/migration/command observations; verify named paths and hashes before drawing a freshness claim. |
| `lan-audio/verification/pending-custody/debug-execution-observation.json` | Phase source/migration/command observations; verify named paths and hashes before drawing a freshness claim. |
| `lan-audio/verification/pending-custody/dependency-adopted/build.zig` | Phase source/migration/command observations; verify named paths and hashes before drawing a freshness claim. |
| `lan-audio/verification/pending-custody/dependency-adopted/build.zig.zon` | Phase source/migration/command observations; verify named paths and hashes before drawing a freshness claim. |
| `lan-audio/verification/pending-custody/dependency-adopted/examples/consumer/socket.c` | Phase source/migration/command observations; verify named paths and hashes before drawing a freshness claim. |
| `lan-audio/verification/pending-custody/dependency-adopted/README.md` | Phase source/migration/command observations; verify named paths and hashes before drawing a freshness claim. |
| `lan-audio/verification/pending-custody/dependency-adopted/src/backend.c` | Phase source/migration/command observations; verify named paths and hashes before drawing a freshness claim. |
| `lan-audio/verification/pending-custody/dependency-adopted/src/backend.h` | Phase source/migration/command observations; verify named paths and hashes before drawing a freshness claim. |
| `lan-audio/verification/pending-custody/dependency-adopted/src/backend.zig` | Phase source/migration/command observations; verify named paths and hashes before drawing a freshness claim. |
| `lan-audio/verification/pending-custody/dependency-adopted/src/driver.zig` | Phase source/migration/command observations; verify named paths and hashes before drawing a freshness claim. |
| `lan-audio/verification/pending-custody/dependency-adopted/src/root.zig` | Phase source/migration/command observations; verify named paths and hashes before drawing a freshness claim. |
| `lan-audio/verification/pending-custody/dependency-before/build.zig` | Phase source/migration/command observations; verify named paths and hashes before drawing a freshness claim. |
| `lan-audio/verification/pending-custody/dependency-before/build.zig.zon` | Phase source/migration/command observations; verify named paths and hashes before drawing a freshness claim. |
| `lan-audio/verification/pending-custody/dependency-before/examples/consumer/socket.c` | Phase source/migration/command observations; verify named paths and hashes before drawing a freshness claim. |
| `lan-audio/verification/pending-custody/dependency-before/README.md` | Phase source/migration/command observations; verify named paths and hashes before drawing a freshness claim. |
| `lan-audio/verification/pending-custody/dependency-before/src/backend.c` | Phase source/migration/command observations; verify named paths and hashes before drawing a freshness claim. |
| `lan-audio/verification/pending-custody/dependency-before/src/backend.h` | Phase source/migration/command observations; verify named paths and hashes before drawing a freshness claim. |
| `lan-audio/verification/pending-custody/dependency-before/src/backend.zig` | Phase source/migration/command observations; verify named paths and hashes before drawing a freshness claim. |
| `lan-audio/verification/pending-custody/dependency-before/src/driver.zig` | Phase source/migration/command observations; verify named paths and hashes before drawing a freshness claim. |
| `lan-audio/verification/pending-custody/dependency-before/src/root.zig` | Phase source/migration/command observations; verify named paths and hashes before drawing a freshness claim. |
| `lan-audio/verification/pending-custody/dependency-consumer.json` | Phase source/migration/command observations; verify named paths and hashes before drawing a freshness claim. |
| `lan-audio/verification/pending-custody/dependency-consumer.log` | Raw command output; interpret with command, return code and target. Preserve failures; never relabel the text. |
| `lan-audio/verification/pending-custody/document-checks.json` | Phase source/migration/command observations; verify named paths and hashes before drawing a freshness claim. |
| `lan-audio/verification/pending-custody/initial-compile-observation.json` | Phase source/migration/command observations; verify named paths and hashes before drawing a freshness claim. |
| `lan-audio/verification/pending-custody/interop-final.json` | Independent peer observations; distinguish expected negative cases from harness defects. |
| `lan-audio/verification/pending-custody/miniaudio-abi-integration.json` | Phase source/migration/command observations; verify named paths and hashes before drawing a freshness claim. |
| `lan-audio/verification/pending-custody/pending-test-attempt1.zig` | Phase source/migration/command observations; verify named paths and hashes before drawing a freshness claim. |
| `lan-audio/verification/pending-custody/RESULTS.md` | Human interpretation of this phase, including measured limits; historical when later source changes. |
| `lan-audio/verification/pending-custody/tls-documentation-adoption.json` | Phase source/migration/command observations; verify named paths and hashes before drawing a freshness claim. |
| `lan-audio/verification/pending-custody/tls-reference-integration.json` | Phase source/migration/command observations; verify named paths and hashes before drawing a freshness claim. |
| `lan-audio/verification/pending-custody/transport-0.log` | Raw command output; interpret with command, return code and target. Preserve failures; never relabel the text. |
| `lan-audio/verification/pending-custody/transport-1.log` | Raw command output; interpret with command, return code and target. Preserve failures; never relabel the text. |
| `lan-audio/verification/pending-custody/transport-2.log` | Raw command output; interpret with command, return code and target. Preserve failures; never relabel the text. |
| `lan-audio/verification/pending-custody/transport-3.log` | Raw command output; interpret with command, return code and target. Preserve failures; never relabel the text. |
| `lan-audio/verification/pending-custody/transport-commands.json` | Phase source/migration/command observations; verify named paths and hashes before drawing a freshness claim. |
| `lan-audio/verification/pending-custody/v1-regression.json` | Phase source/migration/command observations; verify named paths and hashes before drawing a freshness claim. |
| `lan-audio/verification/RESULTS.md` | Human interpretation of this phase, including measured limits; historical when later source changes. |
| `lan-audio/verification/runtime-blueprint/before/.gitignore` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/runtime-blueprint/before/AGENTS.md` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/runtime-blueprint/before/build.zig` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/runtime-blueprint/before/build.zig.zon` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/runtime-blueprint/before/docs/architecture/modules.md` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/runtime-blueprint/before/docs/architecture/platform-capabilities.md` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/runtime-blueprint/before/docs/ARCHITECTURE.md` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/runtime-blueprint/before/docs/CALLBACKS.md` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/runtime-blueprint/before/docs/DEPENDENCIES.md` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/runtime-blueprint/before/docs/design/system-mathematics.md` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/runtime-blueprint/before/docs/development/documentation.md` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/runtime-blueprint/before/docs/development/workflow.md` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/runtime-blueprint/before/docs/implementation/decisions.md` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/runtime-blueprint/before/docs/implementation/interfaces.md` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/runtime-blueprint/before/docs/implementation/layout.md` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/runtime-blueprint/before/docs/implementation/roadmap.md` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/runtime-blueprint/before/docs/implementation/START_HERE.md` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/runtime-blueprint/before/docs/implementation/work-packages/01-target-builds.md` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/runtime-blueprint/before/docs/implementation/work-packages/02-fidelity-protocol.md` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/runtime-blueprint/before/docs/implementation/work-packages/03-identity-endpoints.md` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/runtime-blueprint/before/docs/implementation/work-packages/04-first-sound.md` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/runtime-blueprint/before/docs/implementation/work-packages/05-timing-clocks.md` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/runtime-blueprint/before/docs/implementation/work-packages/06-network-resilience.md` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/runtime-blueprint/before/docs/implementation/work-packages/07-observability.md` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/runtime-blueprint/before/docs/implementation/work-packages/08-user-experience.md` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/runtime-blueprint/before/docs/implementation/work-packages/09-packaging.md` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/runtime-blueprint/before/docs/implementation/work-packages/10-qualification.md` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/runtime-blueprint/before/docs/literate/proof-ledger.md` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/runtime-blueprint/before/docs/literate/quantitative-design.md` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/runtime-blueprint/before/docs/literate/README.md` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/runtime-blueprint/before/docs/literate/runtime-argument.md` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/runtime-blueprint/before/docs/literate/stream-argument.md` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/runtime-blueprint/before/docs/MATHEMATICS.md` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/runtime-blueprint/before/docs/media/assembly.md` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/runtime-blueprint/before/docs/PRODUCT.md` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/runtime-blueprint/before/docs/protocol/negotiation.md` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/runtime-blueprint/before/docs/protocol/v2.md` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/runtime-blueprint/before/docs/README.md` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/runtime-blueprint/before/docs/reference/api-contracts.md` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/runtime-blueprint/before/docs/reference/evidence.md` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/runtime-blueprint/before/docs/reference/file-index.json` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/runtime-blueprint/before/docs/reference/lan-audio.md` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/runtime-blueprint/before/docs/reference/miniaudio-zig.md` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/runtime-blueprint/before/docs/reference/README.md` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/runtime-blueprint/before/docs/reference/tls-zig.md` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/runtime-blueprint/before/docs/reference/upstream-assets.md` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/runtime-blueprint/before/docs/TRANSPORT.md` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/runtime-blueprint/before/docs/verification/acceptance-matrix.md` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/runtime-blueprint/before/docs/verification/scenarios.md` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/runtime-blueprint/before/docs/verification/v2-independent.md` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/runtime-blueprint/before/docs/VERIFICATION.md` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/runtime-blueprint/before/README.md` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/runtime-blueprint/before/spec/concurrency/SpscPublication.cfg` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/runtime-blueprint/before/spec/concurrency/SpscPublication.tla` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/runtime-blueprint/before/spec/README.md` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/runtime-blueprint/before/spec/runtime/RuntimeOwnership.cfg` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/runtime-blueprint/before/spec/runtime/RuntimeOwnership.tla` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/runtime-blueprint/before/spec/session/SessionWindow.cfg` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/runtime-blueprint/before/spec/session/SessionWindow.tla` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/runtime-blueprint/before/spec/stream/EndDrain.cfg` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/runtime-blueprint/before/spec/stream/EndDrain.tla` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/runtime-blueprint/before/src/audio/callback_bridge.zig` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/runtime-blueprint/before/src/audio/frame_queue.zig` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/runtime-blueprint/before/src/host/audio_device.zig` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/runtime-blueprint/before/src/media/block_assembler.zig` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/runtime-blueprint/before/src/media/format.zig` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/runtime-blueprint/before/src/media/playout_window.zig` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/runtime-blueprint/before/src/protocol/negotiation.zig` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/runtime-blueprint/before/src/protocol/v1.zig` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/runtime-blueprint/before/src/protocol/v2.zig` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/runtime-blueprint/before/src/README.md` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/runtime-blueprint/before/src/root.zig` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/runtime-blueprint/before/src/session/receiver.zig` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/runtime-blueprint/before/src/session/session.zig` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/runtime-blueprint/before/tests/dependency.zig` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/runtime-blueprint/before/tests/hardware/windows_capture.zig` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/runtime-blueprint/before/tests/integration/audio_device.zig` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/runtime-blueprint/before/tests/integration/loopback_transport.zig` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/runtime-blueprint/before/tests/integration/protocol_v2_peer.py` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/runtime-blueprint/before/tests/integration/protocol_v2_reference.py` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/runtime-blueprint/before/tests/integration/tls_receiver.zig` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/runtime-blueprint/before/tests/integration/tls_v2.zig` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/runtime-blueprint/before/tests/integration/v2_codec_probe.zig` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/runtime-blueprint/before/tests/unit/callback.zig` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/runtime-blueprint/before/tests/unit/core.zig` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/runtime-blueprint/before/tests/unit/media/assembler.zig` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/runtime-blueprint/before/tests/unit/protocol/negotiation.zig` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/runtime-blueprint/before/tests/unit/protocol/v2.zig` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/runtime-blueprint/before/tests/unit/wire.zig` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/runtime-blueprint/before/tools/build_reference.py` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/runtime-blueprint/before/tools/check_docs.py` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/runtime-blueprint/before/tools/check_handoff.py` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/runtime-blueprint/before/tools/check_models.py` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/runtime-blueprint/before/tools/check_transport.py` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/runtime-blueprint/before/tools/reference_contracts.json` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/runtime-blueprint/before/tools/test_transport.py` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/runtime-blueprint/before/tools/test_v2_differential.py` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/runtime-blueprint/before/transport-lock.json` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/runtime-blueprint/before.json` | Phase source/migration/command observations; verify named paths and hashes before drawing a freshness claim. |
| `lan-audio/verification/runtime-blueprint/block-larger-than-queue.cfg` | Phase source/migration/command observations; verify named paths and hashes before drawing a freshness claim. |
| `lan-audio/verification/runtime-blueprint/document-checks.json` | Phase source/migration/command observations; verify named paths and hashes before drawing a freshness claim. |
| `lan-audio/verification/runtime-blueprint/formal-tools.json` | Phase source/migration/command observations; verify named paths and hashes before drawing a freshness claim. |
| `lan-audio/verification/runtime-blueprint/larger-tail-domain.cfg` | Phase source/migration/command observations; verify named paths and hashes before drawing a freshness claim. |
| `lan-audio/verification/runtime-blueprint/model-additional-bounds.json` | Bounded model execution and mutations; check spec/config/tool hashes and expected violations. |
| `lan-audio/verification/runtime-blueprint/model-receive-drain-attempt1.json` | Bounded model execution and mutations; check spec/config/tool hashes and expected violations. |
| `lan-audio/verification/runtime-blueprint/model-runtime-ownership.json` | Bounded model execution and mutations; check spec/config/tool hashes and expected violations. |
| `lan-audio/verification/runtime-blueprint/RESULTS.md` | Human interpretation of this phase, including measured limits; historical when later source changes. |
| `lan-audio/verification/runtime-blueprint/runtime-ownership-command.json` | Phase source/migration/command observations; verify named paths and hashes before drawing a freshness claim. |
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
| `lan-audio/verification/v2-independent/assembler-attempt1.log` | Raw command output; interpret with command, return code and target. Preserve failures; never relabel the text. |
| `lan-audio/verification/v2-independent/assembler-command-attempt1.json` | Phase source/migration/command observations; verify named paths and hashes before drawing a freshness claim. |
| `lan-audio/verification/v2-independent/assembler-test-attempt1.zig` | Phase source/migration/command observations; verify named paths and hashes before drawing a freshness claim. |
| `lan-audio/verification/v2-independent/before/.gitignore` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/v2-independent/before/AGENTS.md` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/v2-independent/before/build.zig` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/v2-independent/before/build.zig.zon` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/v2-independent/before/docs/architecture/modules.md` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/v2-independent/before/docs/architecture/platform-capabilities.md` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/v2-independent/before/docs/ARCHITECTURE.md` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/v2-independent/before/docs/CALLBACKS.md` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/v2-independent/before/docs/DEPENDENCIES.md` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/v2-independent/before/docs/design/system-mathematics.md` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/v2-independent/before/docs/development/documentation.md` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/v2-independent/before/docs/development/workflow.md` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/v2-independent/before/docs/implementation/decisions.md` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/v2-independent/before/docs/implementation/interfaces.md` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/v2-independent/before/docs/implementation/layout.md` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/v2-independent/before/docs/implementation/roadmap.md` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/v2-independent/before/docs/implementation/START_HERE.md` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/v2-independent/before/docs/implementation/work-packages/01-target-builds.md` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/v2-independent/before/docs/implementation/work-packages/02-fidelity-protocol.md` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/v2-independent/before/docs/implementation/work-packages/03-identity-endpoints.md` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/v2-independent/before/docs/implementation/work-packages/04-first-sound.md` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/v2-independent/before/docs/implementation/work-packages/05-timing-clocks.md` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/v2-independent/before/docs/implementation/work-packages/06-network-resilience.md` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/v2-independent/before/docs/implementation/work-packages/07-observability.md` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/v2-independent/before/docs/implementation/work-packages/08-user-experience.md` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/v2-independent/before/docs/implementation/work-packages/09-packaging.md` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/v2-independent/before/docs/implementation/work-packages/10-qualification.md` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/v2-independent/before/docs/literate/proof-ledger.md` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/v2-independent/before/docs/literate/quantitative-design.md` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/v2-independent/before/docs/literate/README.md` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/v2-independent/before/docs/literate/runtime-argument.md` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/v2-independent/before/docs/literate/stream-argument.md` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/v2-independent/before/docs/MATHEMATICS.md` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/v2-independent/before/docs/PRODUCT.md` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/v2-independent/before/docs/protocol/negotiation.md` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/v2-independent/before/docs/protocol/v2.md` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/v2-independent/before/docs/README.md` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/v2-independent/before/docs/reference/api-contracts.md` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/v2-independent/before/docs/reference/evidence.md` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/v2-independent/before/docs/reference/file-index.json` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/v2-independent/before/docs/reference/lan-audio.md` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/v2-independent/before/docs/reference/miniaudio-zig.md` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/v2-independent/before/docs/reference/README.md` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/v2-independent/before/docs/reference/tls-zig.md` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/v2-independent/before/docs/reference/upstream-assets.md` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/v2-independent/before/docs/TRANSPORT.md` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/v2-independent/before/docs/VERIFICATION.md` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/v2-independent/before/README.md` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/v2-independent/before/spec/concurrency/SpscPublication.cfg` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/v2-independent/before/spec/concurrency/SpscPublication.tla` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/v2-independent/before/spec/README.md` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/v2-independent/before/spec/runtime/RuntimeOwnership.cfg` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/v2-independent/before/spec/runtime/RuntimeOwnership.tla` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/v2-independent/before/spec/session/SessionWindow.cfg` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/v2-independent/before/spec/session/SessionWindow.tla` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/v2-independent/before/spec/stream/EndDrain.cfg` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/v2-independent/before/spec/stream/EndDrain.tla` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/v2-independent/before/src/audio/callback_bridge.zig` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/v2-independent/before/src/audio/frame_queue.zig` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/v2-independent/before/src/host/audio_device.zig` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/v2-independent/before/src/media/format.zig` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/v2-independent/before/src/media/playout_window.zig` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/v2-independent/before/src/protocol/negotiation.zig` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/v2-independent/before/src/protocol/v1.zig` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/v2-independent/before/src/protocol/v2.zig` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/v2-independent/before/src/README.md` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/v2-independent/before/src/root.zig` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/v2-independent/before/src/session/receiver.zig` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/v2-independent/before/src/session/session.zig` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/v2-independent/before/tests/dependency.zig` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/v2-independent/before/tests/hardware/windows_capture.zig` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/v2-independent/before/tests/integration/audio_device.zig` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/v2-independent/before/tests/integration/tls_receiver.zig` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/v2-independent/before/tests/unit/callback.zig` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/v2-independent/before/tests/unit/core.zig` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/v2-independent/before/tests/unit/protocol/negotiation.zig` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/v2-independent/before/tests/unit/protocol/v2.zig` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/v2-independent/before/tests/unit/wire.zig` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/v2-independent/before/tools/build_reference.py` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/v2-independent/before/tools/check_docs.py` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/v2-independent/before/tools/check_handoff.py` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/v2-independent/before/tools/check_models.py` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/v2-independent/before/tools/check_transport.py` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/v2-independent/before/tools/reference_contracts.json` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/v2-independent/before/tools/test_transport.py` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/v2-independent/before/transport-lock.json` | Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source. |
| `lan-audio/verification/v2-independent/before.json` | Phase source/migration/command observations; verify named paths and hashes before drawing a freshness claim. |
| `lan-audio/verification/v2-independent/core-debug-observation.json` | Phase source/migration/command observations; verify named paths and hashes before drawing a freshness claim. |
| `lan-audio/verification/v2-independent/differential-debug.json` | Phase source/migration/command observations; verify named paths and hashes before drawing a freshness claim. |
| `lan-audio/verification/v2-independent/differential-safe-observation.json` | Phase source/migration/command observations; verify named paths and hashes before drawing a freshness claim. |
| `lan-audio/verification/v2-independent/differential-safe.json` | Phase source/migration/command observations; verify named paths and hashes before drawing a freshness claim. |
| `lan-audio/verification/v2-independent/document-checks-final.json` | Phase source/migration/command observations; verify named paths and hashes before drawing a freshness claim. |
| `lan-audio/verification/v2-independent/document-checks.json` | Phase source/migration/command observations; verify named paths and hashes before drawing a freshness claim. |
| `lan-audio/verification/v2-independent/final-0.log` | Raw command output; interpret with command, return code and target. Preserve failures; never relabel the text. |
| `lan-audio/verification/v2-independent/final-1.log` | Raw command output; interpret with command, return code and target. Preserve failures; never relabel the text. |
| `lan-audio/verification/v2-independent/final-2.log` | Raw command output; interpret with command, return code and target. Preserve failures; never relabel the text. |
| `lan-audio/verification/v2-independent/final-3.log` | Raw command output; interpret with command, return code and target. Preserve failures; never relabel the text. |
| `lan-audio/verification/v2-independent/final-4.log` | Raw command output; interpret with command, return code and target. Preserve failures; never relabel the text. |
| `lan-audio/verification/v2-independent/final-5.log` | Raw command output; interpret with command, return code and target. Preserve failures; never relabel the text. |
| `lan-audio/verification/v2-independent/final-6.log` | Raw command output; interpret with command, return code and target. Preserve failures; never relabel the text. |
| `lan-audio/verification/v2-independent/final-7.log` | Raw command output; interpret with command, return code and target. Preserve failures; never relabel the text. |
| `lan-audio/verification/v2-independent/final-8.log` | Raw command output; interpret with command, return code and target. Preserve failures; never relabel the text. |
| `lan-audio/verification/v2-independent/final-commands.json` | Phase source/migration/command observations; verify named paths and hashes before drawing a freshness claim. |
| `lan-audio/verification/v2-independent/interop-attempt1.json` | Independent peer observations; distinguish expected negative cases from harness defects. |
| `lan-audio/verification/v2-independent/interop-attempt1.log` | Raw command output; interpret with command, return code and target. Preserve failures; never relabel the text. |
| `lan-audio/verification/v2-independent/interop-command-attempt1.json` | Independent peer observations; distinguish expected negative cases from harness defects. |
| `lan-audio/verification/v2-independent/interop-final.json` | Independent peer observations; distinguish expected negative cases from harness defects. |
| `lan-audio/verification/v2-independent/interop-source-observations.json` | Independent peer observations; distinguish expected negative cases from harness defects. |
| `lan-audio/verification/v2-independent/previously-unindexed-before/docs/verification/acceptance-matrix.md` | Phase source/migration/command observations; verify named paths and hashes before drawing a freshness claim. |
| `lan-audio/verification/v2-independent/previously-unindexed-before/docs/verification/scenarios.md` | Phase source/migration/command observations; verify named paths and hashes before drawing a freshness claim. |
| `lan-audio/verification/v2-independent/previously-unindexed-before.json` | Phase source/migration/command observations; verify named paths and hashes before drawing a freshness claim. |
| `lan-audio/verification/v2-independent/report-guards.json` | Phase source/migration/command observations; verify named paths and hashes before drawing a freshness claim. |
| `lan-audio/verification/v2-independent/RESULTS.md` | Human interpretation of this phase, including measured limits; historical when later source changes. |
| `lan-audio/verification/v2-independent/tls-build-observation.json` | Phase source/migration/command observations; verify named paths and hashes before drawing a freshness claim. |
| `lan-audio/verification/v2-independent/v1-regression.json` | Phase source/migration/command observations; verify named paths and hashes before drawing a freshness claim. |
| `lan-audio/verification/vendor.log` | Raw command output; interpret with command, return code and target. Preserve failures; never relabel the text. |
| `lan-audio/verification/wrapper-debug.log` | Raw command output; interpret with command, return code and target. Preserve failures; never relabel the text. |
| `lan-audio/verification/wrapper-linux.log` | Raw command output; interpret with command, return code and target. Preserve failures; never relabel the text. |
| `lan-audio/verification/wrapper-null.log` | Raw command output; interpret with command, return code and target. Preserve failures; never relabel the text. |
| `lan-audio/verification/wrapper-runs.json` | Phase source/migration/command observations; verify named paths and hashes before drawing a freshness claim. |
| `lan-audio/verification/wrapper-safe.log` | Raw command output; interpret with command, return code and target. Preserve failures; never relabel the text. |

`verification/handoff/receipt.json` seals the structure revision; `verification/literate-specification/receipt.json` seals the subsequent explanation/model revision; `verification/fidelity-core/receipt.json` seals the pure v2 implementation/documentation revision; `verification/v2-independent/receipt.json` seals independent v2 qualification and capture block assembly; `verification/runtime-blueprint/receipt.json` seals runtime design, receive/drain modeling and continuation contracts; `verification/pending-custody/receipt.json` seals the implemented pending receive buffer, independent authenticated queue tests and reviewed dependency documentation adoption; `verification/ecosystem-alignment/receipt.json` seals the later ecosystem/configuration contracts and dependency-owned conversion/TLS reference integration. `.zig-cache/`, `.zig-global-cache/`, `zig-out/`, `__pycache__/` and TLC `states/` are generated artifacts, not authored contracts. They must be reproducible or safely disposable; never move their contents into source or treat a cached executable as fresh evidence.
