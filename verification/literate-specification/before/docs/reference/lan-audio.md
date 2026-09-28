# lan-audio: granular file contracts

Generated from reviewed `tools/reference_contracts.json`. Edit the contract data, then render; do not edit this chapter alone.


<a id="file-gitignore"></a>

## `.gitignore`

**Responsibility.** Separate generated caches/output from authored source and custody.

**Contract and ownership.** Ignore only reproducible/disposable outputs; do not hide contracts, models, vendored bytes, locks or needed evidence.

**Failure/change obligations.** Broad patterns can hide new source; inspect actual inventory after edits. Ignored status is not permission to delete user data.

**Verification.** Compare source inventory with build outputs and ensure all authored files remain documented.

**Next actionable work.** Add narrowly scoped patterns when new generators require them; keep release inputs explicit.


<a id="file-agents-md"></a>

## `AGENTS.md`

**Responsibility.** Authoritative scoped guide: Implementation entry point.

**Contract and ownership.** Keep terminology, existing versus proposed behavior, source paths and acceptance claims synchronized with the owning implementation/work package.

**Failure/change obligations.** Do not duplicate conflicting protocol/API meaning or imply unexecuted platform support. Preserve useful history and label superseded claims rather than erasing evidence.

**Verification.** Validate local navigation and file index, compare referenced source behavior and evidence dates/hashes; prose quality requires review beyond automated checks.

**Next actionable work.** Read the declared sections below; update this guide whenever its owned contract changes and link to granular implementation/verification obligations.

**Declared surface / navigation:** `Implementation entry point`.


<a id="file-build-zig"></a>

## `build.zig`

**Responsibility.** Own core/audio_host modules and separate pure, native-null, explicit hardware and TLS probe steps.

**Contract and ownership.** Target and optimization flow to every dependent artifact. Compile steps are distinct from execution; do not open devices or network as an implicit build action.

**Failure/change obligations.** Wrong targets, missing SDK/runtime and ABI/link mismatches must fail. A successful cached compile does not prove execution or correct runtime search paths.

**Verification.** Run owning native tests and independent downstream consumer after graph changes; inspect staged imports and target identity.

**Next actionable work.** WP01 extends native platform build qualification; preserve existing public module names and callback/test separation.

**Declared surface / navigation:** `build`; `std`; `target`; `optimize`; `core`; `tests`; `dependency`; `consumer`; `check`; `audio_host`; `callback_tests`; `capture_test`; `transport`; `probe_module`; `probe`; `install`.


<a id="file-build-zig-zon"></a>

## `build.zig.zon`

**Responsibility.** Own package identity, version/compiler floor, dependency declarations and distribution allowlist.

**Contract and ownership.** ZON is Zig package metadata, distinct from ZSON. Fingerprint is identity, not artifact integrity. Sibling paths are development dependencies and require a release closure.

**Failure/change obligations.** Do not silently rename identities or raise compiler floor; changes need compatibility and clean-checkout evidence. Excluded source/docs must not break packages.

**Verification.** Parse/build with pinned compiler; test package allowlist and downstream import from a clean layout.

**Next actionable work.** WP09 replaces development-only assumptions with reproducible source/package custody and includes all required handoff documents.


<a id="file-docs-architecture-md"></a>

## `docs/ARCHITECTURE.md`

**Responsibility.** Authoritative scoped guide: Architecture, directory structure and file contracts.

**Contract and ownership.** Keep terminology, existing versus proposed behavior, source paths and acceptance claims synchronized with the owning implementation/work package.

**Failure/change obligations.** Do not duplicate conflicting protocol/API meaning or imply unexecuted platform support. Preserve useful history and label superseded claims rather than erasing evidence.

**Verification.** Validate local navigation and file index, compare referenced source behavior and evidence dates/hashes; prose quality requires review beyond automated checks.

**Next actionable work.** Read the declared sections below; update this guide whenever its owned contract changes and link to granular implementation/verification obligations.

**Declared surface / navigation:** `Architecture, directory structure and file contracts`; `Ownership and dependency direction`; `Present tree`; `Concurrency and future implementation seams`; `Primary file map`; `Build metadata and structured data`.


<a id="file-docs-callbacks-md"></a>

## `docs/CALLBACKS.md`

**Responsibility.** Authoritative scoped guide: Audio callbacks, frame queues and reclamation.

**Contract and ownership.** Keep terminology, existing versus proposed behavior, source paths and acceptance claims synchronized with the owning implementation/work package.

**Failure/change obligations.** Do not duplicate conflicting protocol/API meaning or imply unexecuted platform support. Preserve useful history and label superseded claims rather than erasing evidence.

**Verification.** Validate local navigation and file index, compare referenced source behavior and evidence dates/hashes; prose quality requires review beyond automated checks.

**Next actionable work.** Read the declared sections below; update this guide whenever its owned contract changes and link to granular implementation/verification obligations.

**Declared surface / navigation:** `Audio callbacks, frame queues and reclamation`; `Representation and ownership`; `Native device lifetime`; `Checks and scope`.


<a id="file-docs-dependencies-md"></a>

## `docs/DEPENDENCIES.md`

**Responsibility.** Authoritative scoped guide: Dependency closure and architecture decisions.

**Contract and ownership.** Keep terminology, existing versus proposed behavior, source paths and acceptance claims synchronized with the owning implementation/work package.

**Failure/change obligations.** Do not duplicate conflicting protocol/API meaning or imply unexecuted platform support. Preserve useful history and label superseded claims rather than erasing evidence.

**Verification.** Validate local navigation and file index, compare referenced source behavior and evidence dates/hashes; prose quality requires review beyond automated checks.

**Next actionable work.** Read the declared sections below; update this guide whenever its owned contract changes and link to granular implementation/verification obligations.

**Declared surface / navigation:** `Dependency closure and architecture decisions`; `Actual admitted graph`; `Observed candidates, with explicit admission decisions`; `Decisions and rejected shortcuts`; `Provenance`.


<a id="file-docs-design-system-mathematics-md"></a>

## `docs/design/system-mathematics.md`

**Responsibility.** Authoritative scoped guide: System mathematics and measurable limits.

**Contract and ownership.** Keep terminology, existing versus proposed behavior, source paths and acceptance claims synchronized with the owning implementation/work package.

**Failure/change obligations.** Do not duplicate conflicting protocol/API meaning or imply unexecuted platform support. Preserve useful history and label superseded claims rather than erasing evidence.

**Verification.** Validate local navigation and file index, compare referenced source behavior and evidence dates/hashes; prose quality requires review beyond automated checks.

**Next actionable work.** Read the declared sections below; update this guide whenever its owned contract changes and link to granular implementation/verification obligations.

**Declared surface / navigation:** `System mathematics and measurable limits`; `M01 — Fidelity and representations`; `M02 — Payload, copies and resource bounds`; `M03 — Outage coverage and catch-up`; `M04 — Two clocks and occupancy`; `M05 — Time and identifiability`; `M06 — Lifecycle and progress`; `M07 — Evidence quality`.


<a id="file-docs-implementation-decisions-md"></a>

## `docs/implementation/decisions.md`

**Responsibility.** Authoritative scoped guide: Decision register.

**Contract and ownership.** Keep terminology, existing versus proposed behavior, source paths and acceptance claims synchronized with the owning implementation/work package.

**Failure/change obligations.** Do not duplicate conflicting protocol/API meaning or imply unexecuted platform support. Preserve useful history and label superseded claims rather than erasing evidence.

**Verification.** Validate local navigation and file index, compare referenced source behavior and evidence dates/hashes; prose quality requires review beyond automated checks.

**Next actionable work.** Read the declared sections below; update this guide whenever its owned contract changes and link to granular implementation/verification obligations.

**Declared surface / navigation:** `Decision register`; `Changes that require explicit records`; `Primary reference boundaries`.


<a id="file-docs-implementation-interfaces-md"></a>

## `docs/implementation/interfaces.md`

**Responsibility.** Authoritative scoped guide: Cross-module implementation contracts.

**Contract and ownership.** Keep terminology, existing versus proposed behavior, source paths and acceptance claims synchronized with the owning implementation/work package.

**Failure/change obligations.** Do not duplicate conflicting protocol/API meaning or imply unexecuted platform support. Preserve useful history and label superseded claims rather than erasing evidence.

**Verification.** Validate local navigation and file index, compare referenced source behavior and evidence dates/hashes; prose quality requires review beyond automated checks.

**Next actionable work.** Read the declared sections below; update this guide whenever its owned contract changes and link to granular implementation/verification obligations.

**Declared surface / navigation:** `Cross-module implementation contracts`; `I01 — Format, identity and time`; `I02 — Source and sink capabilities`; `I03 — Capture assembly and discontinuity`; `I04 — Versioned byte boundary`; `I05 — Authenticated transport owner`; `I06 — Rendering and scheduling`; `I07 — Clock correction`; `I08 — Control, persistence and telemetry`; `I09 — Errors and operations`.


<a id="file-docs-implementation-layout-md"></a>

## `docs/implementation/layout.md`

**Responsibility.** Authoritative scoped guide: Directory architecture and migration contract.

**Contract and ownership.** Keep terminology, existing versus proposed behavior, source paths and acceptance claims synchronized with the owning implementation/work package.

**Failure/change obligations.** Do not duplicate conflicting protocol/API meaning or imply unexecuted platform support. Preserve useful history and label superseded claims rather than erasing evidence.

**Verification.** Validate local navigation and file index, compare referenced source behavior and evidence dates/hashes; prose quality requires review beyond automated checks.

**Next actionable work.** Read the declared sections below; update this guide whenever its owned contract changes and link to granular implementation/verification obligations.

**Declared surface / navigation:** `Directory architecture and migration contract`; `Existing, populated application structure`; `Planned directories: create with their first real implementation`; `Dependency direction`; `Performed migration and preservation`.


<a id="file-docs-implementation-roadmap-md"></a>

## `docs/implementation/roadmap.md`

**Responsibility.** Authoritative scoped guide: Ordered implementation roadmap.

**Contract and ownership.** Keep terminology, existing versus proposed behavior, source paths and acceptance claims synchronized with the owning implementation/work package.

**Failure/change obligations.** Do not duplicate conflicting protocol/API meaning or imply unexecuted platform support. Preserve useful history and label superseded claims rather than erasing evidence.

**Verification.** Validate local navigation and file index, compare referenced source behavior and evidence dates/hashes; prose quality requires review beyond automated checks.

**Next actionable work.** Read the declared sections below; update this guide whenever its owned contract changes and link to granular implementation/verification obligations.

**Declared surface / navigation:** `Ordered implementation roadmap`; `Milestones a user can understand`; `Validation rules`.


<a id="file-docs-implementation-start-here-md"></a>

## `docs/implementation/START_HERE.md`

**Responsibility.** Authoritative scoped guide: Codex implementation handoff.

**Contract and ownership.** Keep terminology, existing versus proposed behavior, source paths and acceptance claims synchronized with the owning implementation/work package.

**Failure/change obligations.** Do not duplicate conflicting protocol/API meaning or imply unexecuted platform support. Preserve useful history and label superseded claims rather than erasing evidence.

**Verification.** Validate local navigation and file index, compare referenced source behavior and evidence dates/hashes; prose quality requires review beyond automated checks.

**Next actionable work.** Read the declared sections below; update this guide whenever its owned contract changes and link to granular implementation/verification obligations.

**Declared surface / navigation:** `Codex implementation handoff`; `Objective and authority`; `Read in this order`; `Current baseline`; `One work-package cycle`; `Important boundaries`.


<a id="file-docs-implementation-work-packages-01-target-builds-md"></a>

## `docs/implementation/work-packages/01-target-builds.md`

**Responsibility.** Executable implementation specification: WP01 — Native target and dependency builds.

**Contract and ownership.** Owns planned file destinations, dependencies, interface/failure obligations and exit criteria. Planned filenames do not assert existing implementation.

**Failure/change obligations.** Changing scope requires updating roadmap/acceptance links and evidence assumptions. Do not mark done through scaffolding or unsupported claims.

**Verification.** Follow the file-specific positive/negative scenarios and explicit exit gate in this work package; retain independent oracles and source identities.

**Next actionable work.** Implement when prerequisites are satisfied, record what passed on which host, then advance the roadmap with unresolved gates visible.

**Declared surface / navigation:** `WP01 — Native target and dependency builds`; `Inspect first`; `Files and changes`; `Procedure and gates`; `Failure and completion`.


<a id="file-docs-implementation-work-packages-02-fidelity-protocol-md"></a>

## `docs/implementation/work-packages/02-fidelity-protocol.md`

**Responsibility.** Executable implementation specification: WP02 — Fidelity-preserving v2 wire profile.

**Contract and ownership.** Owns planned file destinations, dependencies, interface/failure obligations and exit criteria. Planned filenames do not assert existing implementation.

**Failure/change obligations.** Changing scope requires updating roadmap/acceptance links and evidence assumptions. Do not mark done through scaffolding or unsupported claims.

**Verification.** Follow the file-specific positive/negative scenarios and explicit exit gate in this work package; retain independent oracles and source identities.

**Next actionable work.** Implement when prerequisites are satisfied, record what passed on which host, then advance the roadmap with unresolved gates visible.

**Declared surface / navigation:** `WP02 — Fidelity-preserving v2 wire profile`; `Files and first consumers`; `Proposed fixed header: 48 bytes`; `State and error behavior`; `Tests and completion`.


<a id="file-docs-implementation-work-packages-03-identity-endpoints-md"></a>

## `docs/implementation/work-packages/03-identity-endpoints.md`

**Responsibility.** Executable implementation specification: WP03 — Authorized peers and real network endpoints.

**Contract and ownership.** Owns planned file destinations, dependencies, interface/failure obligations and exit criteria. Planned filenames do not assert existing implementation.

**Failure/change obligations.** Changing scope requires updating roadmap/acceptance links and evidence assumptions. Do not mark done through scaffolding or unsupported claims.

**Verification.** Follow the file-specific positive/negative scenarios and explicit exit gate in this work package; retain independent oracles and source identities.

**Next actionable work.** Implement when prerequisites are satisfied, record what passed on which host, then advance the roadmap with unresolved gates visible.

**Declared surface / navigation:** `WP03 — Authorized peers and real network endpoints`.


<a id="file-docs-implementation-work-packages-04-first-sound-md"></a>

## `docs/implementation/work-packages/04-first-sound.md`

**Responsibility.** Executable implementation specification: WP04 — Complete Windows-to-Mac audio path.

**Contract and ownership.** Owns planned file destinations, dependencies, interface/failure obligations and exit criteria. Planned filenames do not assert existing implementation.

**Failure/change obligations.** Changing scope requires updating roadmap/acceptance links and evidence assumptions. Do not mark done through scaffolding or unsupported claims.

**Verification.** Follow the file-specific positive/negative scenarios and explicit exit gate in this work package; retain independent oracles and source identities.

**Next actionable work.** Implement when prerequisites are satisfied, record what passed on which host, then advance the roadmap with unresolved gates visible.

**Declared surface / navigation:** `WP04 — Complete Windows-to-Mac audio path`; `Exact first workflow`.


<a id="file-docs-implementation-work-packages-05-timing-clocks-md"></a>

## `docs/implementation/work-packages/05-timing-clocks.md`

**Responsibility.** Executable implementation specification: WP05 — Pacing, buffering and independent audio clocks.

**Contract and ownership.** Owns planned file destinations, dependencies, interface/failure obligations and exit criteria. Planned filenames do not assert existing implementation.

**Failure/change obligations.** Changing scope requires updating roadmap/acceptance links and evidence assumptions. Do not mark done through scaffolding or unsupported claims.

**Verification.** Follow the file-specific positive/negative scenarios and explicit exit gate in this work package; retain independent oracles and source identities.

**Next actionable work.** Implement when prerequisites are satisfied, record what passed on which host, then advance the roadmap with unresolved gates visible.

**Declared surface / navigation:** `WP05 — Pacing, buffering and independent audio clocks`.


<a id="file-docs-implementation-work-packages-06-network-resilience-md"></a>

## `docs/implementation/work-packages/06-network-resilience.md`

**Responsibility.** Executable implementation specification: WP06 — Measured resilience to the actual network adapter.

**Contract and ownership.** Owns planned file destinations, dependencies, interface/failure obligations and exit criteria. Planned filenames do not assert existing implementation.

**Failure/change obligations.** Changing scope requires updating roadmap/acceptance links and evidence assumptions. Do not mark done through scaffolding or unsupported claims.

**Verification.** Follow the file-specific positive/negative scenarios and explicit exit gate in this work package; retain independent oracles and source identities.

**Next actionable work.** Implement when prerequisites are satisfied, record what passed on which host, then advance the roadmap with unresolved gates visible.

**Declared surface / navigation:** `WP06 — Measured resilience to the actual network adapter`.


<a id="file-docs-implementation-work-packages-07-observability-md"></a>

## `docs/implementation/work-packages/07-observability.md`

**Responsibility.** Executable implementation specification: WP07 — Bounded observability and reproducible diagnosis.

**Contract and ownership.** Owns planned file destinations, dependencies, interface/failure obligations and exit criteria. Planned filenames do not assert existing implementation.

**Failure/change obligations.** Changing scope requires updating roadmap/acceptance links and evidence assumptions. Do not mark done through scaffolding or unsupported claims.

**Verification.** Follow the file-specific positive/negative scenarios and explicit exit gate in this work package; retain independent oracles and source identities.

**Next actionable work.** Implement when prerequisites are satisfied, record what passed on which host, then advance the roadmap with unresolved gates visible.

**Declared surface / navigation:** `WP07 — Bounded observability and reproducible diagnosis`.


<a id="file-docs-implementation-work-packages-08-user-experience-md"></a>

## `docs/implementation/work-packages/08-user-experience.md`

**Responsibility.** Executable implementation specification: WP08 — Usable control and recovery.

**Contract and ownership.** Owns planned file destinations, dependencies, interface/failure obligations and exit criteria. Planned filenames do not assert existing implementation.

**Failure/change obligations.** Changing scope requires updating roadmap/acceptance links and evidence assumptions. Do not mark done through scaffolding or unsupported claims.

**Verification.** Follow the file-specific positive/negative scenarios and explicit exit gate in this work package; retain independent oracles and source identities.

**Next actionable work.** Implement when prerequisites are satisfied, record what passed on which host, then advance the roadmap with unresolved gates visible.

**Declared surface / navigation:** `WP08 — Usable control and recovery`.


<a id="file-docs-implementation-work-packages-09-packaging-md"></a>

## `docs/implementation/work-packages/09-packaging.md`

**Responsibility.** Executable implementation specification: WP09 — Reproducible distribution and rollback.

**Contract and ownership.** Owns planned file destinations, dependencies, interface/failure obligations and exit criteria. Planned filenames do not assert existing implementation.

**Failure/change obligations.** Changing scope requires updating roadmap/acceptance links and evidence assumptions. Do not mark done through scaffolding or unsupported claims.

**Verification.** Follow the file-specific positive/negative scenarios and explicit exit gate in this work package; retain independent oracles and source identities.

**Next actionable work.** Implement when prerequisites are satisfied, record what passed on which host, then advance the roadmap with unresolved gates visible.

**Declared surface / navigation:** `WP09 — Reproducible distribution and rollback`.


<a id="file-docs-implementation-work-packages-10-qualification-md"></a>

## `docs/implementation/work-packages/10-qualification.md`

**Responsibility.** Executable implementation specification: WP10 — Product acceptance and supported envelope.

**Contract and ownership.** Owns planned file destinations, dependencies, interface/failure obligations and exit criteria. Planned filenames do not assert existing implementation.

**Failure/change obligations.** Changing scope requires updating roadmap/acceptance links and evidence assumptions. Do not mark done through scaffolding or unsupported claims.

**Verification.** Follow the file-specific positive/negative scenarios and explicit exit gate in this work package; retain independent oracles and source identities.

**Next actionable work.** Implement when prerequisites are satisfied, record what passed on which host, then advance the roadmap with unresolved gates visible.

**Declared surface / navigation:** `WP10 — Product acceptance and supported envelope`.


<a id="file-docs-mathematics-md"></a>

## `docs/MATHEMATICS.md`

**Responsibility.** Authoritative scoped guide: Mathematical specification and implementation argument.

**Contract and ownership.** Keep terminology, existing versus proposed behavior, source paths and acceptance claims synchronized with the owning implementation/work package.

**Failure/change obligations.** Do not duplicate conflicting protocol/API meaning or imply unexecuted platform support. Preserve useful history and label superseded claims rather than erasing evidence.

**Verification.** Validate local navigation and file index, compare referenced source behavior and evidence dates/hashes; prose quality requires review beyond automated checks.

**Next actionable work.** Read the declared sections below; update this guide whenever its owned contract changes and link to granular implementation/verification obligations.

**Declared surface / navigation:** `Mathematical specification and implementation argument`; `1. Typed objects and dimensions`; `2. State machine and ownership`; `3. Bounded playout window`; `4. Composition and refinement map`; `5. Time, drift and latency — system design obligations`; `6. Dependency and documentation mathematics`; `7. Bounded framing and PCM round trips`; `8. Terminal frontier and stream completion`; `9. SPSC publication and slot reuse`.


<a id="file-docs-product-md"></a>

## `docs/PRODUCT.md`

**Responsibility.** Authoritative scoped guide: Product contract.

**Contract and ownership.** Keep terminology, existing versus proposed behavior, source paths and acceptance claims synchronized with the owning implementation/work package.

**Failure/change obligations.** Do not duplicate conflicting protocol/API meaning or imply unexecuted platform support. Preserve useful history and label superseded claims rather than erasing evidence.

**Verification.** Validate local navigation and file index, compare referenced source behavior and evidence dates/hashes; prose quality requires review beyond automated checks.

**Next actionable work.** Read the declared sections below; update this guide whenever its owned contract changes and link to granular implementation/verification obligations.

**Declared surface / navigation:** `Product contract`; `Purpose, scope and terminology`; `Quality and resilience requirements`; `Current experimental profile`; `Complete user journey and failure behavior`; `Acceptance obligations`.


<a id="file-docs-reference-api-contracts-md"></a>

## `docs/reference/api-contracts.md`

**Responsibility.** Call-by-call maintenance contract for current session, media, queue, device, TLS Engine/Driver and native ABI surfaces.

**Contract and ownership.** Owns current preconditions, state/custody effects, return/progress meanings and failure obligations; planned v2/runtime APIs stay in implementation work packages.

**Failure/change obligations.** Do not treat public field visibility as valid invariant bypass or a document as proof. API changes require source, caller and regression updates together.

**Verification.** Compare listed calls with source declarations, independent tests and formal maps; run relevant affected gates after edits.

**Next actionable work.** Use alongside the per-file chapter when changing an existing method; record new ownership/error semantics and keep future designs separately labeled.

**Declared surface / navigation:** `Existing API contracts: call-by-call maintenance guide`; `Session — src/session/session.zig`; `Window — src/media/playout_window.zig`; `V1 framing and conversion — src/protocol/v1.zig`; `Receiver — src/session/receiver.zig`; `SPSC, callback bridge and native owner`; `TLS Engine — ../tls-zig/src/root.zig`; `TLS Driver — ../tls-zig/src/driver.zig`; `Native C boundary and miniaudio adoption`.


<a id="file-docs-reference-evidence-md"></a>

## `docs/reference/evidence.md`

**Responsibility.** Generated reference/evidence navigation: docs/reference/evidence.md.

**Contract and ownership.** Derived from reviewed per-file contract data and current bounded inventory. SDK hashes are observations; dependency locks remain authoritative.

**Failure/change obligations.** Direct edits are overwritten by the renderer; change source contracts instead. Do not confuse a file row with a semantic audit or a history link with current proof.

**Verification.** Run tools/build_reference.py, tools/check_docs.py and tools/check_handoff.py; inspect generated changes for accurate meaning.

**Next actionable work.** Refresh after source/layout/contract changes; preserve historical evidence and review new dependency scope explicitly.


<a id="file-docs-reference-file-index-json"></a>

## `docs/reference/file-index.json`

**Responsibility.** Exact machine-readable path-to-contract navigation for all three admitted project surfaces.

**Contract and ownership.** Each current authored/support/SDK file has one project-relative entry and a reference chapter/anchor. Cache/evidence classification is separate; this is not a trust lock.

**Failure/change obligations.** Do not hand-edit to conceal missing source or dependency drift. Regenerate from reviewed contract data and explicit inventory scope.

**Verification.** tools/check_handoff.py compares indexed and actual paths, field coverage and reference anchors; dependency verifiers separately validate bytes.

**Next actionable work.** Regenerate after every authored-file addition/move and review newly admitted paths before claiming coverage.


<a id="file-docs-reference-lan-audio-md"></a>

## `docs/reference/lan-audio.md`

**Responsibility.** Generated reference/evidence navigation: docs/reference/lan-audio.md.

**Contract and ownership.** Derived from reviewed per-file contract data and current bounded inventory. SDK hashes are observations; dependency locks remain authoritative.

**Failure/change obligations.** Direct edits are overwritten by the renderer; change source contracts instead. Do not confuse a file row with a semantic audit or a history link with current proof.

**Verification.** Run tools/build_reference.py, tools/check_docs.py and tools/check_handoff.py; inspect generated changes for accurate meaning.

**Next actionable work.** Refresh after source/layout/contract changes; preserve historical evidence and review new dependency scope explicitly.


<a id="file-docs-reference-miniaudio-zig-md"></a>

## `docs/reference/miniaudio-zig.md`

**Responsibility.** Generated reference/evidence navigation: docs/reference/miniaudio-zig.md.

**Contract and ownership.** Derived from reviewed per-file contract data and current bounded inventory. SDK hashes are observations; dependency locks remain authoritative.

**Failure/change obligations.** Direct edits are overwritten by the renderer; change source contracts instead. Do not confuse a file row with a semantic audit or a history link with current proof.

**Verification.** Run tools/build_reference.py, tools/check_docs.py and tools/check_handoff.py; inspect generated changes for accurate meaning.

**Next actionable work.** Refresh after source/layout/contract changes; preserve historical evidence and review new dependency scope explicitly.


<a id="file-docs-reference-readme-md"></a>

## `docs/reference/README.md`

**Responsibility.** Authoritative scoped guide: File reference and review scope.

**Contract and ownership.** Keep terminology, existing versus proposed behavior, source paths and acceptance claims synchronized with the owning implementation/work package.

**Failure/change obligations.** Do not duplicate conflicting protocol/API meaning or imply unexecuted platform support. Preserve useful history and label superseded claims rather than erasing evidence.

**Verification.** Validate local navigation and file index, compare referenced source behavior and evidence dates/hashes; prose quality requires review beyond automated checks.

**Next actionable work.** Read the declared sections below; update this guide whenever its owned contract changes and link to granular implementation/verification obligations.

**Declared surface / navigation:** `File reference and review scope`.


<a id="file-docs-reference-tls-zig-md"></a>

## `docs/reference/tls-zig.md`

**Responsibility.** Generated reference/evidence navigation: docs/reference/tls-zig.md.

**Contract and ownership.** Derived from reviewed per-file contract data and current bounded inventory. SDK hashes are observations; dependency locks remain authoritative.

**Failure/change obligations.** Direct edits are overwritten by the renderer; change source contracts instead. Do not confuse a file row with a semantic audit or a history link with current proof.

**Verification.** Run tools/build_reference.py, tools/check_docs.py and tools/check_handoff.py; inspect generated changes for accurate meaning.

**Next actionable work.** Refresh after source/layout/contract changes; preserve historical evidence and review new dependency scope explicitly.


<a id="file-docs-reference-upstream-assets-md"></a>

## `docs/reference/upstream-assets.md`

**Responsibility.** Generated reference/evidence navigation: docs/reference/upstream-assets.md.

**Contract and ownership.** Derived from reviewed per-file contract data and current bounded inventory. SDK hashes are observations; dependency locks remain authoritative.

**Failure/change obligations.** Direct edits are overwritten by the renderer; change source contracts instead. Do not confuse a file row with a semantic audit or a history link with current proof.

**Verification.** Run tools/build_reference.py, tools/check_docs.py and tools/check_handoff.py; inspect generated changes for accurate meaning.

**Next actionable work.** Refresh after source/layout/contract changes; preserve historical evidence and review new dependency scope explicitly.


<a id="file-docs-transport-md"></a>

## `docs/TRANSPORT.md`

**Responsibility.** Authoritative scoped guide: Experimental JCR audio/1 transport contract.

**Contract and ownership.** Keep terminology, existing versus proposed behavior, source paths and acceptance claims synchronized with the owning implementation/work package.

**Failure/change obligations.** Do not duplicate conflicting protocol/API meaning or imply unexecuted platform support. Preserve useful history and label superseded claims rather than erasing evidence.

**Verification.** Validate local navigation and file index, compare referenced source behavior and evidence dates/hashes; prose quality requires review beyond automated checks.

**Next actionable work.** Read the declared sections below; update this guide whenever its owned contract changes and link to granular implementation/verification obligations.

**Declared surface / navigation:** `Experimental JCR audio/1 transport contract`; `Channel and identities`; `Exact record format`; `Framing, memory and failure behavior`; `Current host and dependency boundary`; `Performance and remaining scope`.


<a id="file-docs-verification-md"></a>

## `docs/VERIFICATION.md`

**Responsibility.** Authoritative scoped guide: Verification, evidence and next gates.

**Contract and ownership.** Keep terminology, existing versus proposed behavior, source paths and acceptance claims synchronized with the owning implementation/work package.

**Failure/change obligations.** Do not duplicate conflicting protocol/API meaning or imply unexecuted platform support. Preserve useful history and label superseded claims rather than erasing evidence.

**Verification.** Validate local navigation and file index, compare referenced source behavior and evidence dates/hashes; prose quality requires review beyond automated checks.

**Next actionable work.** Read the declared sections below; update this guide whenever its owned contract changes and link to granular implementation/verification obligations.

**Declared surface / navigation:** `Verification, evidence and next gates`; `Reproduction`; `What the checks establish`; `Required next gates`.


<a id="file-readme-md"></a>

## `README.md`

**Responsibility.** Authoritative scoped guide: LAN audio — authenticated media and callback foundation.

**Contract and ownership.** Keep terminology, existing versus proposed behavior, source paths and acceptance claims synchronized with the owning implementation/work package.

**Failure/change obligations.** Do not duplicate conflicting protocol/API meaning or imply unexecuted platform support. Preserve useful history and label superseded claims rather than erasing evidence.

**Verification.** Validate local navigation and file index, compare referenced source behavior and evidence dates/hashes; prose quality requires review beyond automated checks.

**Next actionable work.** Read the declared sections below; update this guide whenever its owned contract changes and link to granular implementation/verification obligations.

**Declared surface / navigation:** `LAN audio — authenticated media and callback foundation`; `Read and verify`; `Engineering intent`.


<a id="file-spec-concurrency-spscpublication-cfg"></a>

## `spec/concurrency/SpscPublication.cfg`

**Responsibility.** Separate copy/publication and copy/release actions for a two-slot FIFO. Finite TLC configuration.

**Contract and ownership.** Four frames, two slots; fair producer/consumer completion and early-publish/early-release corruption mutations. Sequential consistency only; modular-counter and acquire/release compilation arguments remain separate.

**Failure/change obligations.** Do not suppress deadlock/invariant/liveness failures without changing the stated model contract. Bounds or fairness changes require new raw results; earlier state counts are historical.

**Verification.** Run tools/check_models.py --model SpscPublication with explicit Java/TLC paths; require normal pass and every expected counterexample.

**Next actionable work.** WP04–05 adds a composed runtime model for worker wait graphs and cancellation; do not infer composition correctness by adding individual PASS labels.


<a id="file-spec-concurrency-spscpublication-tla"></a>

## `spec/concurrency/SpscPublication.tla`

**Responsibility.** Separate copy/publication and copy/release actions for a two-slot FIFO. Transition system.

**Contract and ownership.** Four frames, two slots; fair producer/consumer completion and early-publish/early-release corruption mutations. Sequential consistency only; modular-counter and acquire/release compilation arguments remain separate.

**Failure/change obligations.** Do not suppress deadlock/invariant/liveness failures without changing the stated model contract. Bounds or fairness changes require new raw results; earlier state counts are historical.

**Verification.** Run tools/check_models.py --model SpscPublication with explicit Java/TLC paths; require normal pass and every expected counterexample.

**Next actionable work.** WP04–05 adds a composed runtime model for worker wait graphs and cancellation; do not infer composition correctness by adding individual PASS labels.

**Declared surface / navigation:** `vars`; `Init`; `CopyIn`; `Publish`; `LateCopyIn`; `CopyOut`; `Release`; `LateCopyOut`; `Produce`; `Consume`; `Next`; `Spec`; `TypeOK`; `NoCorruption`; `Completes`.


<a id="file-spec-readme-md"></a>

## `spec/README.md`

**Responsibility.** Authoritative scoped guide: Executable session and playout model.

**Contract and ownership.** Keep terminology, existing versus proposed behavior, source paths and acceptance claims synchronized with the owning implementation/work package.

**Failure/change obligations.** Do not duplicate conflicting protocol/API meaning or imply unexecuted platform support. Preserve useful history and label superseded claims rather than erasing evidence.

**Verification.** Validate local navigation and file index, compare referenced source behavior and evidence dates/hashes; prose quality requires review beyond automated checks.

**Next actionable work.** Read the declared sections below; update this guide whenever its owned contract changes and link to granular implementation/verification obligations.

**Declared surface / navigation:** `Executable session and playout model`; `Callback publication model`.


<a id="file-spec-session-sessionwindow-cfg"></a>

## `spec/session/SessionWindow.cfg`

**Responsibility.** Abstract authentication/generation/window/callback lifecycle. Finite TLC configuration.

**Contract and ownership.** Two generations, three positions, capacity two; weak fairness of callback return/stop; four named safety mutations. Manual Session/Window map; real callbacks and weak memory are outside this model.

**Failure/change obligations.** Do not suppress deadlock/invariant/liveness failures without changing the stated model contract. Bounds or fairness changes require new raw results; earlier state counts are historical.

**Verification.** Run tools/check_models.py --model SessionWindow with explicit Java/TLC paths; require normal pass and every expected counterexample.

**Next actionable work.** WP04–05 adds a composed runtime model for worker wait graphs and cancellation; do not infer composition correctness by adding individual PASS labels.


<a id="file-spec-session-sessionwindow-tla"></a>

## `spec/session/SessionWindow.tla`

**Responsibility.** Abstract authentication/generation/window/callback lifecycle. Transition system.

**Contract and ownership.** Two generations, three positions, capacity two; weak fairness of callback return/stop; four named safety mutations. Manual Session/Window map; real callbacks and weak memory are outside this model.

**Failure/change obligations.** Do not suppress deadlock/invariant/liveness failures without changing the stated model contract. Bounds or fairness changes require new raw results; earlier state counts are historical.

**Verification.** Run tools/check_models.py --model SessionWindow with explicit Java/TLC paths; require normal pass and every expected counterexample.

**Next actionable work.** WP04–05 adds a composed runtime model for worker wait graphs and cancellation; do not infer composition correctness by adding individual PASS labels.

**Declared surface / navigation:** `vars`; `Packet`; `Packets`; `Init`; `Begin`; `Authenticate`; `Start`; `Receive`; `EnterCallback`; `Tick`; `LeaveCallback`; `RequestStop`; `FinishStop`; `Next`; `Spec`; `TypeOK`; `AuthenticatedStreaming`; `QuiescentIdle`; `WindowBounds`; `UniquePlayout`; `StopCompletes`.


<a id="file-spec-stream-enddrain-cfg"></a>

## `spec/stream/EndDrain.cfg`

**Responsibility.** Exclusive terminal frontier and no post-END admission. Finite TLC configuration.

**Contract and ownership.** Capacity two, three positions; fair tick and three falsifying mutations for early completion/end bound/post-end input. Map receiver finish_sequence, window.next/present and ended; completion is serialized, not acoustic.

**Failure/change obligations.** Do not suppress deadlock/invariant/liveness failures without changing the stated model contract. Bounds or fairness changes require new raw results; earlier state counts are historical.

**Verification.** Run tools/check_models.py --model EndDrain with explicit Java/TLC paths; require normal pass and every expected counterexample.

**Next actionable work.** WP04–05 adds a composed runtime model for worker wait graphs and cancellation; do not infer composition correctness by adding individual PASS labels.


<a id="file-spec-stream-enddrain-tla"></a>

## `spec/stream/EndDrain.tla`

**Responsibility.** Exclusive terminal frontier and no post-END admission. Transition system.

**Contract and ownership.** Capacity two, three positions; fair tick and three falsifying mutations for early completion/end bound/post-end input. Map receiver finish_sequence, window.next/present and ended; completion is serialized, not acoustic.

**Failure/change obligations.** Do not suppress deadlock/invariant/liveness failures without changing the stated model contract. Bounds or fairness changes require new raw results; earlier state counts are historical.

**Verification.** Run tools/check_models.py --model EndDrain with explicit Java/TLC paths; require normal pass and every expected counterexample.

**Next actionable work.** WP04–05 adds a composed runtime model for worker wait graphs and cancellation; do not infer composition correctness by adding individual PASS labels.

**Declared surface / navigation:** `NoEnd`; `vars`; `Init`; `Receive`; `End`; `Tick`; `Next`; `Spec`; `TypeOK`; `Bounded`; `Drained`; `NoPostEndAdmission`; `EndDrains`.


<a id="file-src-audio-callback-bridge-zig"></a>

## `src/audio/callback_bridge.zig`

**Responsibility.** Two directional queues with callback silence, drop and diagnostic policy.

**Contract and ownership.** captureInput writes the fitting whole-frame prefix, saturates captured/dropped totals and sets sticky capture_overrun on loss. renderOutput reads available frames and zeros the entire missing tail. Capture and playback have opposite producer/consumer owners.

**Failure/change obligations.** Read ordinary totals only after native callback teardown. A worker checks overrun after draining and before further publication, then ends/restarts the discontinuous stream. Clearing the flag while callbacks run is invalid.

**Verification.** Unit gap/tail/overflow tests plus actual null callback lifecycle and live TLS-to-null playback cover ownership paths.

**Next actionable work.** WP04 integrates sender discontinuity handling; WP07 creates race-free live diagnostics. Keep logging, encoding, clocks and device control out of this callback policy.

**Declared surface / navigation:** `CallbackBridge`; `captureInput`; `renderOutput`; `FrameQueue`; `std`; `Self`; `Queue`; `accepted`; `available`.


<a id="file-src-audio-frame-queue-zig"></a>

## `src/audio/frame_queue.zig`

**Responsibility.** Sole-producer/sole-consumer interleaved frame transfer with fixed storage and modular cursors.

**Contract and ownership.** K is power-of-two <=2^30, channels 1..32, target x86_64/aarch64. write copies at most two spans before release publication; read copies before release reuse. Remote cursor loads acquire, own loads monotonic. producerPending belongs only to producer. Slice lengths are complete frames and must not alias storage.

**Failure/change obligations.** Full/empty return a short/zero prefix; no wait/allocation/CAS loop. Misuse of owner count, movement, live reset or direct field access invalidates the memory-order argument. Values are copied raw; finite validation belongs before playback/network publication.

**Verification.** Unit partial/full/empty/suffix and u32-wrap tests, 250,000-frame concurrent FIFO stress and spec/concurrency/SpscPublication; manual acquire/release proof remains distinct from the SC model.

**Next actionable work.** WP04 preserves fixed addresses and joins. WP07 adds a separately designed snapshot if needed; never poll mutable queue internals from a third observer.

**Declared surface / navigation:** `FrameQueue`; `producerPending`; `write`; `read`; `std`; `builtin`; `Self`; `frame_capacity`; `channel_count`; `w`; `r`; `occupied`; `available`.


<a id="file-src-host-audio-device-zig"></a>

## `src/host/audio_device.zig`

**Responsibility.** Optional miniaudio control owner with explicit silent, Windows and Mac profiles.

**Contract and ownership.** Initialize at final address; userdata points back to self. Context outlives device. init resets only under quiescence; start/stop are serialized off-callback; deinit uninitializes any created device even after start/stop errors. Callback copies f32 stereo into/from bridge and increments diagnostics.

**Failure/change obligations.** UnsupportedPlatform/InvalidState and native context/device/start/stop errors remain distinct; last_result retains native cause. No implicit backend fallback or microphone profile. Failed start/stop still requires deinit before storage reuse.

**Verification.** Eight null lifecycle cycles in tests/integration/audio_device.zig; explicit physical WASAPI fixture in tests/hardware/windows_capture.zig. Mac source declaration is not execution evidence.

**Next actionable work.** WP01 qualifies Intel Mac; WP04 adds selected native IDs and negotiated formats; WP05 adds clock observations without breaking callback bounds.

**Declared surface / navigation:** `init`; `start`; `stop`; `deinit`; `callback`; `builtin`; `std`; `c`; `core`; `Bridge`; `Profile`; `AudioDevice`; `Self`; `count`.


<a id="file-src-media-playout-window-zig"></a>

## `src/media/playout_window.zig`

**Responsibility.** Fixed-storage block-position admission and one-tick media/silence commitment.

**Contract and ownership.** Window(K,M) requires positive dimensions. init binds an epoch. insert checks finite complete PCM, epoch, reserved max sequence and [next,next+K) membership before copying. tick requires nonaliasing M-sample output and fills it completely before advancing.

**Failure/change obligations.** Stale, late, far, duplicate, malformed or exhausted positions fail without publication. No counter wrap; reinitialize only after all old owners stop. It is not a concurrent queue.

**Verification.** Core boundary tests and the independent non-ring oracle exercise 32,768 traces, repeated modulo reuse, silence and exhaustion.

**Next actionable work.** WP05 supplies actual scheduling/contiguous prefill. If v2 uses variable frame ranges, define a separate range-based contract rather than assuming this fixed-block algebra still applies.

**Declared surface / navigation:** `Window`; `init`; `insert`; `tick`; `std`; `Self`; `Error`; `Result`.


<a id="file-src-protocol-v1-zig"></a>

## `src/protocol/v1.zig`

**Responsibility.** Owns the complete experimental jcr-audio/1 binary and quantization contract.

**Contract and ownership.** Header is 36 bytes, maximum record 996; START profile is 48 kHz stereo 240-frame s16LE. Parser.feed returns one borrowed message plus consumed prefix; process before the next feed. Encoders validate bounds/finite samples before writing; decode uses bounded temporary storage.

**Failure/change obligations.** Unknown/malformed header, invalid ID/profile/sequence/length, nonfinite samples and truncation fail explicitly. Parser errors are terminal. Encode input/output cannot overlap; decode permits overlap.

**Verification.** Independent golden bytes, every split position, coalescing/truncation, hostile lengths and all 65,536 s16 round trips in tests/unit/wire.zig; live TLS tests verify stream behavior.

**Next actionable work.** Freeze v1 semantics. WP02 adds protocol/v2.zig for finite f32 bit preservation; never label existing PCM16 quantization lossless for arbitrary captured f32.

**Declared surface / navigation:** `bodySize`; `validId`; `kindOf`; `header`; `validate`; `parse`; `feed`; `finish`; `writeHeader`; `encodeStart`; `encodeEnd`; `encodeAck`; `encodeAudio`; `decodeAudio`; `std`; `alpn`; `StreamId`; `sample_rate`; `channels`; `frames`; `samples`; `header_size`; `pcm_size`; `max_record`; `Kind`; `Error`; `Message`; `kind`; `seq`; `b`; `h`; `Parser`; `Feed`; `n`; `message`; `size`; `record`.


<a id="file-src-root-zig"></a>

## `src/root.zig`

**Responsibility.** Stable public core module entry; exports existing session, window, v1 wire, receiver and queue/bridge mechanisms.

**Contract and ownership.** No native backend or runtime owner is constructed here. Imports point into responsibility folders; preserve public export names during relocation.

**Failure/change obligations.** Adding host imports creates an architectural cycle and makes pure target checks require platform SDKs. New exports require a consumer and a named contract.

**Verification.** Compile core on native Windows, Intel Mac target and optional ARM target; existing core tests consume only this public module.

**Next actionable work.** WP02 adds intentional Format/v2 exports; keep experimental v1 compatibility and do not expose all future runtime internals.

**Declared surface / navigation:** `Session`; `Window`; `wire`; `Receiver`; `FrameQueue`; `CallbackBridge`.


<a id="file-src-session-receiver-zig"></a>

## `src/session/receiver.zig`

**Responsibility.** Composes authenticated-channel attestation, v1 stream identity and one bounded playout window.

**Contract and ownership.** authorizeChannel is a once-only host attestation. accept validates bytes/profile before state admission, binds START once, decodes/copies AUDIO, and admits END only beyond all buffered frames. tick advances one block; completeIfDrained closes the serialized session.

**Failure/change obligations.** WrongStream, UnexpectedMessage, Ended and InvalidEnd supplement parser/session/window errors. Reaching ended proves serialized array consumption, not native callback reclamation.

**Verification.** tests/unit/wire.zig checks unauthorized input, stream mismatch, END bounds and draining holes; spec/stream/EndDrain explores completion with three mutations.

**Next actionable work.** Do not retrofit variable-frame v2 positions into this v1-specific type silently. WP02/04 introduces explicitly versioned composition and keeps each owner serialized.

**Declared surface / navigation:** `Receiver`; `authorizeChannel`; `accept`; `tick`; `completeIfDrained`; `std`; `wire`; `Session`; `Window`; `Self`; `Buffer`; `Error`; `epoch`; `id`; `distance`; `result`.


<a id="file-src-session-session-zig"></a>

## `src/session/session.zig`

**Responsibility.** Serialized generation, authentication-attestation and stop state machine.

**Contract and ownership.** begin increments a nonwrapping u64 epoch only from idle; authenticate binds the current negotiating epoch; start requires attestation; admit is a pure gate. enter/leaveCallback model one token. requestStop closes admission; finishStop requires no token and clears authentication.

**Failure/change obligations.** InvalidState, StaleEpoch, Unauthenticated, CallbackActive, NoCallback and EpochExhausted preserve state. The token does not join OS callbacks; one owner serializes methods.

**Verification.** tests/unit/core.zig covers gates and rejection preservation; spec/session/SessionWindow checks bounded safety and fair-stop progress plus four mutants.

**Next actionable work.** WP04 owns real worker/device joins outside this type. Extend only if the abstract lifecycle changes; map every new state to a composed runtime model.

**Declared surface / navigation:** `begin`; `authenticate`; `start`; `admit`; `enterCallback`; `leaveCallback`; `requestStop`; `finishStop`; `std`; `Session`; `Phase`; `Error`.


<a id="file-tests-dependency-zig"></a>

## `tests/dependency.zig`

**Responsibility.** Stable external package consumer referenced by miniaudio-zig documentation.

**Contract and ownership.** Import the wrapper module and invoke native PCM unit helpers to prove transitive native linking.

**Failure/change obligations.** Assertions must fail on unexpected behavior; no arbitrary crash counts as expected rejection. Threads/devices/sockets must be reclaimed on every test exit.

**Verification.** Run its owning build step in Debug and ReleaseSafe where native execution is supported; preserve exact commands and failures. Extracted test names below enumerate current cases.

**Next actionable work.** Keep this path stable unless the wrapper documentation is deliberately updated under custody review.

**Declared surface / navigation:** `std`; `c`; `miniaudio dependency supplies the pinned PCM ABI`.


<a id="file-tests-hardware-windows-capture-zig"></a>

## `tests/hardware/windows_capture.zig`

**Responsibility.** Explicit WASAPI system-output acquisition and finite wire encoding.

**Contract and ownership.** Silent playback keeps engine active; bounded worker batches drain capture, validate/encode, then discard samples. Never save/transmit recorded PCM or use microphone.

**Failure/change obligations.** Assertions must fail on unexpected behavior; no arbitrary crash counts as expected rejection. Threads/devices/sockets must be reclaimed on every test exit.

**Verification.** Run its owning build step in Debug and ReleaseSafe where native execution is supported; preserve exact commands and failures. Extracted test names below enumerate current cases.

**Next actionable work.** Rerun only for relevant physical changes; distinguish idle-source NoCaptureFrames from a passed run, and add actual selected-device/driver evidence.

**Declared surface / navigation:** `std`; `audio`; `wire`; `got`; `Windows system-output capture supplies finite encodable stereo frames`.


<a id="file-tests-integration-audio-device-zig"></a>

## `tests/integration/audio_device.zig`

**Responsibility.** Actual null-backend callbacks and repeated safe reconstruction.

**Contract and ownership.** Keep explicit null selection, callback progress bound, join/deinit before counter reads and eight lifecycle cycles.

**Failure/change obligations.** Assertions must fail on unexpected behavior; no arbitrary crash counts as expected rejection. Threads/devices/sockets must be reclaimed on every test exit.

**Verification.** Run its owning build step in Debug and ReleaseSafe where native execution is supported; preserve exact commands and failures. Extracted test names below enumerate current cases.

**Next actionable work.** Extend error-acquisition and cancellation fixtures as the real runtime grows; physical tests remain opt-in.

**Declared surface / navigation:** `std`; `audio`; `callbacks`; `null duplex callbacks transfer frames and permit quiescent reconstruction`.


<a id="file-tests-integration-tls-receiver-zig"></a>

## `tests/integration/tls_receiver.zig`

**Responsibility.** Synthetic mTLS receiver delivering v1 PCM through null playback callbacks.

**Contract and ownership.** Authenticate before media, own parser/receiver/device/Driver, retain partial writes, bound the total transfer, drain callback copying before ACK and require clean close.

**Failure/change obligations.** Assertions must fail on unexpected behavior; no arbitrary crash counts as expected rejection. Threads/devices/sockets must be reclaimed on every test exit.

**Verification.** Run its owning build step in Debug and ReleaseSafe where native execution is supported; preserve exact commands and failures. Extracted test names below enumerate current cases.

**Next actionable work.** WP04 builds real runtime owners separately; frozen fixture wall time, public keys and loopback transport never become production defaults.

**Declared surface / navigation:** `demo_open`; `demo_close`; `demo_send`; `demo_recv`; `demo_poll`; `demo_now`; `demo_name`; `send`; `recv`; `run`; `main`; `std`; `tls`; `core`; `audio`; `wire`; `Network`; `n`; `result`; `now`; `started`; `transfer_deadline`; `fed`; `count`; `ack`; `ending`.


<a id="file-tests-unit-callback-zig"></a>

## `tests/unit/callback.zig`

**Responsibility.** SPSC and bridge contracts including actual concurrent owners.

**Contract and ownership.** Check full/empty/partial transfers, untouched read suffix, signed stereo ordering, wrap and joined thread results.

**Failure/change obligations.** Assertions must fail on unexpected behavior; no arbitrary crash counts as expected rejection. Threads/devices/sockets must be reclaimed on every test exit.

**Verification.** Run its owning build step in Debug and ReleaseSafe where native execution is supported; preserve exact commands and failures. Extracted test names below enumerate current cases.

**Next actionable work.** Add minimized counterexamples from real races; external test timeout is required if a broken producer/consumer stalls.

**Declared surface / navigation:** `produce`; `consume`; `std`; `core`; `Stress`; `total`; `wrote`; `n`; `producer`; `consumer`; `SPSC partial operations preserve stereo and output suffix`; `SPSC u32 rollover preserves distance and slots`; `callback gaps silence full tail and capture drops newest complete frames`; `SPSC simultaneous owners transfer 250000 exact ordered stereo frames`.


<a id="file-tests-unit-core-zig"></a>

## `tests/unit/core.zig`

**Responsibility.** Session/window invariants and independent finite operation oracle.

**Contract and ownership.** Retain independent absolute-position expectations, all 32,768 traces, finite checks and rejected-transition state checks.

**Failure/change obligations.** Assertions must fail on unexpected behavior; no arbitrary crash counts as expected rejection. Threads/devices/sockets must be reclaimed on every test exit.

**Verification.** Run its owning build step in Debug and ReleaseSafe where native execution is supported; preserve exact commands and failures. Extracted test names below enumerate current cases.

**Next actionable work.** WP04 adds composed lifecycle tests separately; do not replace this oracle with the production ring algorithm.

**Declared surface / navigation:** `std`; `core`; `expect`; `first`; `second`; `result`; `action`; `available`; `authentication and callback drain gate restart`; `reorder duplicate loss and late arrival preserve media positions`; `malformed and stale input cannot publish a block`; `ring reuse matches expected ordered blocks across many revolutions`; `finite counters fail before wrap and leave output untouched`; `all 32768 five-action traces agree with an independent non-ring oracle`.


<a id="file-tests-unit-wire-zig"></a>

## `tests/unit/wire.zig`

**Responsibility.** V1 golden layouts, quantization and receiver end-state behavior.

**Contract and ownership.** Retain independently spelled bytes, every fragmentation boundary, all s16 values and hostile state/profile cases.

**Failure/change obligations.** Assertions must fail on unexpected behavior; no arbitrary crash counts as expected rejection. Threads/devices/sockets must be reclaimed on every test exit.

**Verification.** Run its owning build step in Debug and ReleaseSafe where native execution is supported; preserve exact commands and failures. Extracted test names below enumerate current cases.

**Next actionable work.** WP02 adds separate v2 tests; old v1 fixtures stay byte-identical.

**Declared surface / navigation:** `std`; `core`; `wire`; `expect`; `bytes`; `golden`; `encoded`; `before`; `a`; `b`; `first`; `second`; `start`; `wire has independent golden header and quantization vectors`; `every possible single split preserves a complete PCM record`; `coalesced records preserve unconsumed suffix and partial close fails`; `hostile lengths versions profiles and ids fail without resynchronization`; `receiver requires channel authorization and binds exactly one stream`; `end drains buffered positions and fills missing positions once`; `all s16 values survive decode and re-encode exactly`.


<a id="file-tools-build-reference-py"></a>

## `tools/build_reference.py`

**Responsibility.** Renders reviewed per-file contracts, declarations and SDK/evidence navigation.

**Contract and ownership.** Reads declared three sibling projects and explicit contract data; writes only docs/reference outputs. Excludes caches and inventories installed SDK assets without modifying them.

**Failure/change obligations.** Missing or stale reviewed contract entries fail. Generated placeholders are overwritten during successful render; the tool must not touch pins, source, secrets or upstream bytes.

**Verification.** Run renderer then check_docs/check_handoff; review source-specific contract text and generated diff; verify exact SDK pins separately.

**Next actionable work.** When adding a file, write its concrete contract data first. Avoid generic filler and distinguish extracted declarations from semantic assurance.

**Declared surface / navigation:** `inventory`; `surface`; `asset_role`; `main`.


<a id="file-tools-check-docs-py"></a>

## `tools/check_docs.py`

**Responsibility.** Read-only local Markdown navigation and current authored-file coverage gate.

**Contract and ownership.** Validate links only as local navigation; ignore fenced/inline code and external schemes. Reference inventory owns complete path coverage after the handoff migration.

**Failure/change obligations.** Missing files or malformed index fail. Passing navigation is not semantic or architectural approval; links in historical receipts may intentionally use old paths.

**Verification.** Run after documentation/layout changes and pair with check_handoff. Do not silently rewrite links or generate missing source.

**Next actionable work.** Keep filesystem scopes explicit; extend Markdown parsing only when a real valid construct causes a minimized false positive.


<a id="file-tools-check-handoff-py"></a>

## `tools/check_handoff.py`

**Responsibility.** Read-only exact file-index/reference/contract and local-import consistency gate.

**Contract and ownership.** Compare filesystem inventory with indexed paths, require every contract field and chapter anchor, check relative Zig imports and explicit work-package exit conditions.

**Failure/change obligations.** Stale/missing/duplicate paths, broken imports and incomplete fields fail. It never calls the renderer main or updates custody.

**Verification.** Run after render and before handoff; use actual compiler/tests for semantics and syntax beyond the simple import scanner.

**Next actionable work.** Extend checks for machine-readable work dependencies if the roadmap grows; do not treat text-field length as proof of documentation quality.

**Declared surface / navigation:** `len`; `in`.


<a id="file-tools-check-models-py"></a>

## `tools/check_models.py`

**Responsibility.** Runs selected bounded TLC models and their falsifying mutations.

**Contract and ownership.** Select model folder/profile by explicit name; copy source/config into owned temporary storage; bound Java subprocess at 120 seconds and record tool/model hashes and named violations.

**Failure/change obligations.** Absent Java/JAR, invalid model, timeout or missing expected counterexample is a failed/unexecuted qualification, never an inferred pass. Temporary model state is not a source mutation.

**Verification.** Execute all three profiles after path/runner changes; inspect results and model hashes, not only the shell pipeline exit code.

**Next actionable work.** Add a reviewed profile for the composed runtime model in WP04; retain explicit bounds and failure mutations.

**Declared surface / navigation:** `SystemExit`.


<a id="file-tools-check-transport-py"></a>

## `tools/check_transport.py`

**Responsibility.** Read-only TLS adoption and staged-runtime custody verifier.

**Contract and ownership.** Resolve each lock path within the declared dependency root, compare exact SHA-256, and optionally compare the two installed DLLs with SDK pins. No fetch/repair/repin.

**Failure/change obligations.** Missing, escaped or changed paths and staged DLL mismatches fail. A content mismatch needs review, not automatic lock regeneration.

**Verification.** Run before transport tests and packaging; inject a mismatch in isolated fixtures if the verifier changes.

**Next actionable work.** WP01 adds target-specific reviewed Mac custody while preserving Windows evidence and explicit update semantics.

**Declared surface / navigation:** `verify`.


<a id="file-tools-reference-contracts-json"></a>

## `tools/reference_contracts.json`

**Responsibility.** Reviewed semantic source of per-file documentation across the three admitted projects.

**Contract and ownership.** Each project-relative file key has purpose, contract, failure/change, verification and next-work text. Installed SDK rows use the explicit upstream asset policy instead.

**Failure/change obligations.** Do not generate meaningless prose to satisfy field length; stale keys are errors. This is navigation/engineering data, not a dependency hash lock.

**Verification.** Renderer rejects missing/stale entries; check_handoff validates exact coverage and per-file references.

**Next actionable work.** Update concrete semantics when code changes, render chapters, and review both. Proposed files remain in work packages until implemented.


<a id="file-tools-test-transport-py"></a>

## `tools/test_transport.py`

**Responsibility.** Independent Python SSL sender and expected-failure oracle for the audio TLS probe.

**Contract and ownership.** Own ephemeral loopback sockets, server thread and bounded Zig process. Verify SDK first; public credentials and known PCM have independent ACK/checksum expectations. Require callback frame counts and clean TLS close. Mandatory --output selects a new report inside verification/; existing reports fail before networking and final write uses exclusive creation.

**Failure/change obligations.** Negative cases need named client errors and no PASS; untrusted-client additionally needs independent server certificate rejection. Cleanup is bounded. Current output targets callback evidence; preserve old files before reruns.

**Verification.** Sixteen scenarios: fragmented success; wrong name/ALPN/missing ALPN/expired/untrusted identity; size/profile/order/stream/duplicate/truncation/end/EOF/stall failures.

**Next actionable work.** WP02 adds v2 independent peers; WP04 adds two-host evidence. Keep per-run output paths unique and preserve both failure and corrected-run reports.

**Declared surface / navigation:** `record`; `pcm`; `peer_context`; `receive_exact`; `run_case`.


<a id="file-transport-lock-json"></a>

## `transport-lock.json`

**Responsibility.** Reviewed exact TLS source/SDK/fixture adoption identity for current Windows integration.

**Contract and ownership.** Contains 188 approved files, runtime DLL names/import observations and upstream build provenance; sibling root is local development layout.

**Failure/change obligations.** Do not hand-edit a hash to hide source drift. A new platform/dependency revision needs an explicit adoption diff and qualified binaries.

**Verification.** tools/check_transport.py and staged DLL checks; independent runtime path validation belongs to the TLS tests.

**Next actionable work.** WP01 defines target-specific Mac identity and package closure; retain original Windows/source provenance.

**Declared surface / navigation:** `adopted`; `root`; `package_version`; `profile`; `files`; `runtime_dlls`; `runtime_imports`; `upstream`; `scope`.
