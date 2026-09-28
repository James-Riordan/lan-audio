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

**Responsibility.** Own pure/audio modules and explicit core, native-null, hardware, v1 TLS, independent v2 C ABI and two v2 TLS application-role probe build steps.

**Contract and ownership.** Build pure core and a private pending_audio module used only by tests/fixture callers; core-check compiles both. Native audio and opt-in TLS fixtures retain separate modules and explicit hardware steps; no new public package/core export.

**Failure/change obligations.** Wrong targets, missing SDK/runtime and ABI/link mismatches must fail. A successful cached compile does not prove execution or correct runtime search paths.

**Verification.** Run affected core native/cross builds, Debug/ReleaseSafe independent C ABI campaigns, v2 peer cases and v1 transport regressions after graph changes; installation/build never runs devices or peers implicitly.

**Next actionable work.** WP01 extends native platform build qualification; preserve existing public module names and callback/test separation.

**Declared surface / navigation:** `build`; `std`; `target`; `optimize`; `core`; `pending`; `tests`; `codec_probe`; `dependency`; `consumer`; `check`; `audio_host`; `callback_tests`; `capture_test`; `transport`; `probe_module`; `probe`; `install`; `v2_install`; `options`; `module`; `executable`.


<a id="file-build-zig-zon"></a>

## `build.zig.zon`

**Responsibility.** Own package identity, version/compiler floor, dependency declarations and distribution allowlist.

**Contract and ownership.** ZON is Zig package metadata, distinct from ZSON. Fingerprint is identity, not artifact integrity. Sibling paths are development dependencies and require a release closure.

**Failure/change obligations.** Do not silently rename identities or raise compiler floor; changes need compatibility and clean-checkout evidence. Excluded source/docs must not break packages.

**Verification.** Parse/build with pinned compiler; test package allowlist and downstream import from a clean layout.

**Next actionable work.** WP09 replaces development-only assumptions with reproducible source/package custody and includes all required handoff documents.


<a id="file-docs-architecture-modules-md"></a>

## `docs/architecture/modules.md`

**Responsibility.** Dependency direction and justified growth rules for modules, directories and packages.

**Contract and ownership.** Preserves pure-core/host separation, wrapper ownership and explicit version boundaries; scale means qualified bounded capacities, not unconstrained invariance.

**Failure/change obligations.** Keep current and planned status distinct; update semantic source/domain owners together and preserve historical evidence. Never promote documentation coverage into correctness or product readiness.

**Verification.** Review linked canonical sources and tests, then run exact reference/import and local documentation checks.

**Next actionable work.** Revise this chapter when its ownership, implemented behavior or evidence changes; avoid duplicate format/state definitions elsewhere.

**Declared surface / navigation:** `Module boundaries and scale`; `Dependency direction`; `When to add a module, folder or package`; `Per-module contract`; `Extensibility and compatibility`.


<a id="file-docs-architecture-platform-capabilities-md"></a>

## `docs/architecture/platform-capabilities.md`

**Responsibility.** Production capability discovery, incompatibility handling and plain-language control-state design.

**Contract and ownership.** Explicitly planned; native support needs actual execution and capability checks. OS name, enum presence and cross-compilation cannot authorize feature claims.

**Failure/change obligations.** Keep current and planned status distinct; update semantic source/domain owners together and preserve historical evidence. Never promote documentation coverage into correctness or product readiness.

**Verification.** Review linked canonical sources and tests, then run exact reference/import and local documentation checks.

**Next actionable work.** Revise this chapter when its ownership, implemented behavior or evidence changes; avoid duplicate format/state definitions elsewhere.

**Declared surface / navigation:** `Platform awareness and graceful incompatibility`; `Capability records, not operating-system guesses`; `Plain-language control states`.


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


<a id="file-docs-design-receive-drain-md"></a>

## `docs/design/receive-drain.md`

**Responsibility.** Derives ordered source-frame custody across pending decoded data, playback queue, callback-held data and callback return, with truthful END acknowledgement.

**Contract and ownership.** For one healthy authenticated non-resampled generation, C concatenated with H,Q,P equals source IDs 1..r. Gives frontier mapping, action-by-action preservation, conditional fair progress via rank 3|P|+2|Q|+|H|, bounds and concrete refinement obligations.

**Failure/change obligations.** Queue empty does not prove callback return. Omitted tail priming can deadlock short streams. Abort, cryptography, weak memory, acoustic completion and numeric scheduling bounds are outside this model; do not silently extend the theorem.

**Verification.** Run ReceiveDrain normal properties and four falsifying mutations with reviewed Java/TLC; inspect exact configurations, raw traces and source/tool hashes. Review the manual rank/enabling argument separately.

**Next actionable work.** Refine the future pending helper and runtime owner actions, establish native joins and mechanically compose the healthy subprotocol with abort/generation ownership if making a whole-system proof claim.

**Declared surface / navigation:** `Ordered frame custody and truthful completion`; `Domain and representation relation`; `Initialization and preservation`; `Why queue-empty cannot justify ACK`; `Short streams and conditional progress`; `Bounds, mutants and refinement duties`.


<a id="file-docs-design-system-mathematics-md"></a>

## `docs/design/system-mathematics.md`

**Responsibility.** Authoritative scoped guide: System mathematics and measurable limits.

**Contract and ownership.** Keep terminology, existing versus proposed behavior, source paths and acceptance claims synchronized with the owning implementation/work package.

**Failure/change obligations.** Do not duplicate conflicting protocol/API meaning or imply unexecuted platform support. Preserve useful history and label superseded claims rather than erasing evidence.

**Verification.** Validate local navigation and file index, compare referenced source behavior and evidence dates/hashes; prose quality requires review beyond automated checks.

**Next actionable work.** Read the declared sections below; update this guide whenever its owned contract changes and link to granular implementation/verification obligations.

**Declared surface / navigation:** `System mathematics and measurable limits`; `M01 — Fidelity and representations`; `M02 — Payload, copies and resource bounds`; `M03 — Outage coverage and catch-up`; `M04 — Two clocks and occupancy`; `M05 — Time and identifiability`; `M06 — Lifecycle and progress`; `M07 — Evidence quality`.


<a id="file-docs-development-documentation-md"></a>

## `docs/development/documentation.md`

**Responsibility.** Maintained per-file and domain documentation standard with ownership, proofs and evidence.

**Contract and ownership.** Three reading levels share canonical definitions; tests and support files explain assumptions, independent expectations and limits without hand-editing vendor bytes.

**Failure/change obligations.** Keep current and planned status distinct; update semantic source/domain owners together and preserve historical evidence. Never promote documentation coverage into correctness or product readiness.

**Verification.** Review linked canonical sources and tests, then run exact reference/import and local documentation checks.

**Next actionable work.** Revise this chapter when its ownership, implemented behavior or evidence changes; avoid duplicate format/state definitions elsewhere.

**Declared surface / navigation:** `Documentation is maintained engineering data`; `Three complementary reading levels`; `Definition of a documented source change`; `Change checklist and authority`.


<a id="file-docs-development-workflow-md"></a>

## `docs/development/workflow.md`

**Responsibility.** Concrete workflow for one bounded code/document change and reproducible evidence.

**Contract and ownership.** Preserve before-images in this non-Git checkout, use pinned tools, separate code execution from cross-builds, update contracts and seal new observations without rewriting history.

**Failure/change obligations.** Keep current and planned status distinct; update semantic source/domain owners together and preserve historical evidence. Never promote documentation coverage into correctness or product readiness.

**Verification.** Review linked canonical sources and tests, then run exact reference/import and local documentation checks.

**Next actionable work.** Revise this chapter when its ownership, implemented behavior or evidence changes; avoid duplicate format/state definitions elsewhere.

**Declared surface / navigation:** `Make one complete change and leave a reproducible record`; `Choose a bounded responsibility`; `Implement and verify at the right boundary`; `Update the living explanation`; `Seal the observation`.


<a id="file-docs-implementation-completion-sequence-md"></a>

## `docs/implementation/completion-sequence.md`

**Responsibility.** Gives the next implementation session ordered, independently reviewable slices from pending receive custody through sustained two-host production qualification.

**Contract and ownership.** C01-C09 name first files, deliverables, dependency order and which work can proceed while the Mac is unavailable. Per-file next-slice semantics distinguish proposed paths from real APIs; foreground CLI does not imply cross-process control.

**Failure/change obligations.** No placeholder source, fabricated ready percentage or pass inferred from documentation. Preserve current changes/evidence and inspect exact toolchain/dependency custody before starting a new phase.

**Verification.** Cross-check each slice with WP01-WP10, A1-A10 and R01-R15; inspect actual file existence and acceptance evidence. Native Mac gates require a real available host and inspected OS.

**Next actionable work.** C01 PendingBlock is implemented with unit and authenticated fixture callers. Start C02 fake-owner lifecycle, then native capture/playback/identity workers; no helper test completes a two-host product milestone.

**Declared surface / navigation:** `Completion sequence for the next implementation session`; `First establish the exact starting state`; `Small complete changes, in dependency order`; `Per-file implementation contract for the next slice`; `Scope of the first usable command`; `A completed implementation change`.


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

**Contract and ownership.** Semantic system contracts, explicitly proposed where no API exists. v1 Window uses blocks; initial v2 uses frame-based pending custody and FIFO. Driver copied plaintext custody and media-role quiescence are distinguished from socket retries and the still-live ACK owner.

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


<a id="file-docs-implementation-runtime-blueprint-md"></a>

## `docs/implementation/runtime-blueprint.md`

**Responsibility.** Specifies concrete capture/send and receive/playout integration, resolving actual v1/v2 units, fixed native format, single Driver ownership and callback completion mismatches.

**Contract and ownership.** Proposed runtime behavior: stable owner/storage map, bounded worker iterations, copied-write commit, owned pending decode before parser reuse, prefix-only queue publication, short-stream priming and truthful downstream ACK fence. Existing APIs remain canonical for implemented semantics.

**Failure/change obligations.** Source discontinuity, invalid native buffers, failed writes and unclassified underrun must not become successful END. Abort revokes admission, wakes and joins owners before reclaiming; unbounded native hangs do not authorize unsafe free.

**Verification.** Inspect actual source boundaries; apply R01-R15 and the ReceiveDrain refinement map. Model success qualifies only its stated abstraction; actual device/TLS/worker execution remains required.

**Next actionable work.** Use the implemented pending helper, implement C02 lifecycle and remaining C03-C05 native/identity/workers. Confirm real format, live callback-safe faults and native fences before first sound.

**Declared surface / navigation:** `Runtime blueprint: from verified components to first sound`; `Resolve these mismatches before connecting modules`; `Owners and storage`; `Sender: a bounded iteration`; `Receiver: copy once into pending custody, publish prefixes`; `Priming, END and drain`; `Underrun and missing native input`; `Scheduling, cancellation and partial failure`.


<a id="file-docs-implementation-start-here-md"></a>

## `docs/implementation/START_HERE.md`

**Responsibility.** Engineering specification entry: connects literate explanation, mathematical evidence and concrete implementation order.

**Contract and ownership.** Keep terminology, existing versus proposed behavior, source paths and acceptance claims synchronized with the owning implementation/work package.

**Failure/change obligations.** Do not duplicate conflicting protocol/API meaning or imply unexecuted platform support. Preserve useful history and label superseded claims rather than erasing evidence.

**Verification.** Validate local navigation and file index, compare referenced source behavior and evidence dates/hashes; prose quality requires review beyond automated checks.

**Next actionable work.** Read the declared sections below; update this guide whenever its owned contract changes and link to granular implementation/verification obligations.

**Declared surface / navigation:** `Engineering specification and implementation guide`; `Objective and authority`; `Read in this order`; `Current baseline`; `One work-package cycle`; `Important boundaries`.


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

**Responsibility.** Locally qualified v2 Format/codec/gate, independent oracle and fixture-mTLS status; production credential/device integration remains separate.

**Contract and ownership.** Owns planned file destinations, dependencies, interface/failure obligations and exit criteria. Planned filenames do not assert existing implementation.

**Failure/change obligations.** Changing scope requires updating roadmap/acceptance links and evidence assumptions. Do not mark done through scaffolding or unsupported claims.

**Verification.** Follow the file-specific positive/negative scenarios and explicit exit gate in this work package; retain independent oracles and source identities.

**Next actionable work.** Implement when prerequisites are satisfied, record what passed on which host, then advance the roadmap with unresolved gates visible.

**Declared surface / navigation:** `WP02 — Fidelity-preserving v2 wire profile`; `Files and first consumers`; `Implemented boundary and remaining work`; `Tests and completion`.


<a id="file-docs-implementation-work-packages-03-identity-endpoints-md"></a>

## `docs/implementation/work-packages/03-identity-endpoints.md`

**Responsibility.** Executable implementation specification: WP03 — Authorized peers and real network endpoints.

**Contract and ownership.** Owns planned file destinations, dependencies, interface/failure obligations and exit criteria. Planned filenames do not assert existing implementation.

**Failure/change obligations.** Changing scope requires updating roadmap/acceptance links and evidence assumptions. Do not mark done through scaffolding or unsupported claims.

**Verification.** Follow the file-specific positive/negative scenarios and explicit exit gate in this work package; retain independent oracles and source identities.

**Next actionable work.** The inspected Engine lacks a public verified-peer fingerprint export. Add and test the generic library seam plus product allowlist policy; real endpoints and cancellation must qualify per OS.

**Declared surface / navigation:** `WP03 — Authorized peers and real network endpoints`.


<a id="file-docs-implementation-work-packages-04-first-sound-md"></a>

## `docs/implementation/work-packages/04-first-sound.md`

**Responsibility.** First real two-host workflow and planned runtime owners; pure block assembler exists while native queue/transport/cancellation integration remains open.

**Contract and ownership.** Owns planned file destinations, dependencies, interface/failure obligations and exit criteria. Planned filenames do not assert existing implementation.

**Failure/change obligations.** Changing scope requires updating roadmap/acceptance links and evidence assumptions. Do not mark done through scaffolding or unsupported claims.

**Verification.** Follow the file-specific positive/negative scenarios and explicit exit gate in this work package; retain independent oracles and source identities.

**Next actionable work.** Follow completion-sequence C01-C07 and runtime-blueprint; implement pending receive custody and fake-owner lifecycle first, then qualify native/authenticated workers and real two-host sound.

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


<a id="file-docs-literate-proof-ledger-md"></a>

## `docs/literate/proof-ledger.md`

**Responsibility.** Owns epistemic status of fourteen claims, including independent v2 qualification, source-prefix assembly and ordered receive/drain custody, with explicit host/refinement obligations.

**Contract and ownership.** Every claim has premises, linked reasoning, actual evidence type and remaining action. Labels manual, bounded checked and tested do not imply each other.

**Failure/change obligations.** A future work package or green unit test cannot silently become a refinement theorem. Preserve historical evidence scope as files change.

**Verification.** Cross-check against actual models, source APIs and immutable verification reports; ensure each claimed new result was executed.

**Next actionable work.** Update claim status when new code, proofs, counterexamples or measurements change the premises or evidence.

**Declared surface / navigation:** `Proof ledger: claims, premises and outstanding obligations`; `Proof work cannot be replaced by repeated assertions`.


<a id="file-docs-literate-quantitative-design-md"></a>

## `docs/literate/quantitative-design.md`

**Responsibility.** Derives burst/service backlog, reserve/retention and ideal sampled PI stability conditions with units.

**Contract and ownership.** Fluid service curve and linear controller assumptions are explicit; queue sizes and gains follow a stated model and must later be measured against the target environment.

**Failure/change obligations.** Unbounded stalls give no finite guarantee; average bandwidth is not a service lower bound; filtered/saturated/delayed control requires new analysis.

**Verification.** Review algebra and dimensions independently; numerical polynomial-root checks are corroboration only, not proof of real device stability.

**Next actionable work.** WP05/06 must select concrete controller/resource policies from measured rate/jitter/outage envelopes and independent simulations.

**Declared surface / navigation:** `Quantitative design: derive the limits before tuning`; `Q1. Rate, burst and service are different quantities`; `Q2. Playback reserves and source retention are separate`; `Q3. Derive an ideal clock-controller stability region`; `Q4. Fidelity and resilience have observable frontiers`.


<a id="file-docs-literate-readme-md"></a>

## `docs/literate/README.md`

**Responsibility.** Defines the engineering explanation as a maintained part of the product, with a conceptual reading order.

**Contract and ownership.** Prose explains canonical code; distinguish manual arguments, bounded models, tested behavior and open refinement. Knuth/Lamport are methodology references, never claimed endorsers.

**Failure/change obligations.** Do not substitute file counts, work-package tables or generated declarations for explanation; do not duplicate complete implementations as competing source.

**Verification.** Review each linked chapter and the proof ledger; run documentation and exact file-coverage checks.

**Next actionable work.** Apply the stated explanation template whenever an algorithm, adapter, build input or proof obligation changes.

**Declared surface / navigation:** `An executable engineering explanation`; `Reading the program as an argument`; `What a completed explanation must contain`; `Keeping prose and code consistent`.


<a id="file-docs-literate-runtime-argument-md"></a>

## `docs/literate/runtime-argument.md`

**Responsibility.** Gives variables, actions, induction cases, fairness and refinement obligations for RuntimeOwnership.

**Contract and ownership.** Count conservation includes every modeled custody stage; reclamation requires closed admission and absent owners/tokens. Eventual cleanup assumes fair completion, not reliable delivery.

**Failure/change obligations.** The capture owner abstracts callback and worker joins; one-flight-frame and atomic acquisition omit real TLS buffering/partial initialization. Never report that omitted code is proved.

**Verification.** Run RuntimeOwnership normal safety/temporal checks and early_free/stop_wait mutations; inspect traces and source/config/runner identities.

**Next actionable work.** Refine owner granularity and buffer representation while implementing WP04; provide code-to-action mappings and concrete cancellation evidence.

**Declared surface / navigation:** `Runtime ownership: composition, cancellation and reclamation`; `Domain, state and deliberate abstractions`; `Actions and their implementation meaning`; `Safety theorem R1 — custody conservation`; `Safety theorem R2 — no reclamation with live references`; `Liveness theorem R3 — stop eventually reaches idle`; `Liveness theorem R4 — graceful drain has an escape`; `Refinement obligations before claiming runtime verification`.


<a id="file-docs-literate-stream-argument-md"></a>

## `docs/literate/stream-argument.md`

**Responsibility.** Explains the current audio path in source-frame and memory-ownership order.

**Contract and ownership.** Links actual symbols and explains callback borrowing, publication/reuse, bounded framing, trust, modulo slots, END frontiers and build/package authority. Current v1 behavior stays distinct from planned v2.

**Failure/change obligations.** A borrowed parser/native buffer must not escape its lifetime; no ring occupancy or abstract completion claim may be promoted into an acoustic guarantee.

**Verification.** Compare explanations with AudioDevice, CallbackBridge, FrameQueue, v1, Session, Receiver, Window and build sources; use independent tests named in the ledger.

**Next actionable work.** Extend the narrative with each implemented runtime stage and remove outdated assumptions only after replacement evidence.

**Declared surface / navigation:** `Following one stream: the program and its reasons`; `1. Decide what must survive the journey`; `2. Borrow native memory; publish owned memory`; `3. Prove when a slot can change owners`; `4. Serialize values without inventing trust`; `5. Authenticate the channel before authorizing a generation`; `6. Decide which position can play next`; `7. End a stream without confusing receipt with reclamation`; `8. Reproduce the program being explained`.


<a id="file-docs-mathematics-md"></a>

## `docs/MATHEMATICS.md`

**Responsibility.** Authoritative scoped guide: Mathematical specification and implementation argument.

**Contract and ownership.** Keep terminology, existing versus proposed behavior, source paths and acceptance claims synchronized with the owning implementation/work package.

**Failure/change obligations.** Do not duplicate conflicting protocol/API meaning or imply unexecuted platform support. Preserve useful history and label superseded claims rather than erasing evidence.

**Verification.** Validate local navigation and file index, compare referenced source behavior and evidence dates/hashes; prose quality requires review beyond automated checks.

**Next actionable work.** Read the declared sections below; update this guide whenever its owned contract changes and link to granular implementation/verification obligations.

**Declared surface / navigation:** `Mathematical specification and implementation argument`; `1. Typed objects and dimensions`; `2. State machine and ownership`; `3. Bounded playout window`; `4. Composition and refinement map`; `5. Time, drift and latency — system design obligations`; `6. Dependency and documentation mathematics`; `7. Bounded framing and PCM round trips`; `8. Terminal frontier and stream completion`; `9. SPSC publication and slot reuse`.


<a id="file-docs-media-assembly-md"></a>

## `docs/media/assembly.md`

**Responsibility.** Canonical BlockAssembler API, conservation proof, commit order and source-discontinuity contract.

**Contract and ownership.** Defines W/P/frontiers, finite copied prefixes, bounded cost and borrowed storage; separates source EOF, failure, transport acceptance and callback quiescence.

**Failure/change obligations.** Do not convert capture loss to normal EOF or silently skip unconsumed suffixes. Manual conservation assumptions do not establish actual worker scheduling or native joins.

**Verification.** Cross-check source and six independent tests; keep failed test evidence and current run links accurate.

**Next actionable work.** WP04 extends this chapter with actual queue/overrun/cancellation/custody integration evidence.

**Declared surface / navigation:** `Capture block assembly: preserve the source timeline`; `Problem, owner and representation`; `Operations and their boundaries`; `Conservation and ordering argument`; `Commit with the protocol and transport`; `Source overflow is not EOF`; `Evidence`.


<a id="file-docs-media-pending-block-md"></a>

## `docs/media/pending-block.md`

**Responsibility.** Explains the implemented pending AUDIO API, ordered-prefix representation, failure atomicity, lifetime and gate/queue composition.

**Contract and ownership.** Separates accepted whole-record frontier from copied queue-prefix frontier; derives a+offset ranges, count conservation, terminal discard and operation/storage bounds. Labels synchronous fixtures separately from native callback completion.

**Failure/change obligations.** Never promise idempotence of positive advance, retry expired message borrows, treat Busy as admission, or use local discard totals as acoustic delivery evidence. Input/storage aliasing and direct field mutation violate the API contract.

**Verification.** Check all five methods against source, seven named test cases and authenticated queue observations; compare the implementation relation with ReceiveDrain rather than treating bounded model success as refinement.

**Next actionable work.** Maintain the explanation as native workers acquire a caller; lifecycle and callback/native fences remain the next concrete implementation obligation.

**Declared surface / navigation:** `Pending receive block: retain every unqueued frame`; `Problem and placement`; `Representation and lifetime`; `Call-by-call contract`; `Preservation and failure atomicity`; `Composition with gate, parser and queue`; `Independent evidence`.


<a id="file-docs-product-md"></a>

## `docs/PRODUCT.md`

**Responsibility.** Authoritative scoped guide: Product contract.

**Contract and ownership.** Keep terminology, existing versus proposed behavior, source paths and acceptance claims synchronized with the owning implementation/work package.

**Failure/change obligations.** Do not duplicate conflicting protocol/API meaning or imply unexecuted platform support. Preserve useful history and label superseded claims rather than erasing evidence.

**Verification.** Validate local navigation and file index, compare referenced source behavior and evidence dates/hashes; prose quality requires review beyond automated checks.

**Next actionable work.** Read the declared sections below; update this guide whenever its owned contract changes and link to granular implementation/verification obligations.

**Declared surface / navigation:** `Product contract`; `Purpose, scope and terminology`; `Quality and resilience requirements`; `Current experimental profile`; `Complete user journey and failure behavior`; `Acceptance obligations`.


<a id="file-docs-protocol-negotiation-md"></a>

## `docs/protocol/negotiation.md`

**Responsibility.** Canonical implemented gate transition table, host attestations and transport commit semantics.

**Contract and ownership.** Explains roles, one-record application, failed-state behavior, exact echo, continuity, drain ACK and local-copy commit; no implied host joins or cryptographic proof.

**Failure/change obligations.** Keep current and planned status distinct; update semantic source/domain owners together and preserve historical evidence. Never promote documentation coverage into correctness or product readiness.

**Verification.** Review linked canonical sources and tests, then run exact reference/import and local documentation checks.

**Next actionable work.** Revise this chapter when its ownership, implemented behavior or evidence changes; avoid duplicate format/state definitions elsewhere.

**Declared surface / navigation:** `Version 2: one connection, one ordered stream`; `State and transition table`; `The commit point across transport calls`; `Inductive argument and its limits`.


<a id="file-docs-protocol-v2-md"></a>

## `docs/protocol/v2.md`

**Responsibility.** Canonical implemented v2 wire layout, API contracts and finite-bit/parser/overflow arguments.

**Contract and ownership.** Separates implemented codec and local independent-peer qualification from unfinished real host/device integration; exact bytes, units, aliasing, failure effects and bounded cost have one canonical owner.

**Failure/change obligations.** Keep current and planned status distinct; update semantic source/domain owners together and preserve historical evidence. Never promote documentation coverage into correctness or product readiness.

**Verification.** Review linked canonical sources and tests, then run exact reference/import and local documentation checks.

**Next actionable work.** Revise this chapter when its ownership, implemented behavior or evidence changes; avoid duplicate format/state definitions elsewhere.

**Declared surface / navigation:** `Version 2: preserve samples and bound the byte stream`; `Domain and layer boundaries`; `Canonical wire representation`; `Why finite values survive exactly`; `Streaming parser argument`; `Call-by-call contract`; `Cost and evidence`.


<a id="file-docs-readme-md"></a>

## `docs/README.md`

**Responsibility.** Reader-oriented documentation map and current project availability boundary.

**Contract and ownership.** Links conceptual, architecture, protocol, implementation, per-file and evidence reading paths; no available product is implied.

**Failure/change obligations.** Keep current and planned status distinct; update semantic source/domain owners together and preserve historical evidence. Never promote documentation coverage into correctness or product readiness.

**Verification.** Review linked canonical sources and tests, then run exact reference/import and local documentation checks.

**Next actionable work.** Revise this chapter when its ownership, implemented behavior or evidence changes; avoid duplicate format/state definitions elsewhere.

**Declared surface / navigation:** `Project documentation`; `Choose a reading path`.


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


<a id="file-docs-verification-acceptance-matrix-md"></a>

## `docs/verification/acceptance-matrix.md`

**Responsibility.** Maps product acceptance IDs A1-A10 to implementation responsibilities, required independent observations and current partial/open status.

**Contract and ownership.** The product requirements own acceptance meaning; each row preserves the boundary between component evidence and the complete two-host product. Run records identify source/tool/target/environment, measurements and limits without private keys or raw audio.

**Failure/change obligations.** Do not promote a row to complete from a fixture, compilation-only result or documentation existence. Preserve historical results and distinguish unavailable targets from failed executions.

**Verification.** Resolve every acceptance ID against PRODUCT.md; inspect linked phase receipts and the independent oracle for each claimed result. Inventory and local-link checks establish navigation only.

**Next actionable work.** Attach real runtime and two-host evidence as each gate passes; A8 still requires actual capture-to-decoder equality and measured conversion/rate-correction behavior.

**Declared surface / navigation:** `Acceptance traceability and evidence rules`; `Evidence schema for each run`; `Release review`.


<a id="file-docs-verification-runtime-obligations-md"></a>

## `docs/verification/runtime-obligations.md`

**Responsibility.** Defines fifteen concrete runtime verification obligations, independent source-ledger oracles, resource-failure schedules and a proposed versioned event trace schema.

**Contract and ownership.** Fake owners and virtual time exercise real lifecycle/worker state machines; source frame identities and sample words come from a separate oracle. Native tests validate adapter assumptions afterward. Explicitly labels tests planned and models actually executable.

**Failure/change obligations.** Production counters are not independent oracles. Stalled native joins retain live storage; saturated counters invalidate exact accounting. Sorting unrelated host clocks cannot create causality; no physical raw audio/private keys in routine telemetry.

**Verification.** Implement R01-R15 as their callers arrive; preserve acquisition/borrow/release event order, negative error categories, exact commands and failure traces. Use actual endpoints and OS identity for R15.

**Next actionable work.** R01-R02 now have component/pending-fixture checks. Implement R03-R15 for actual lifecycle/native workers, preserving independent source/resource oracles and target-scoped evidence.

**Declared surface / navigation:** `Runtime verification obligations and independent oracles`; `Harness boundary`; `Required cases before first-sound qualification`; `Resource ledger and failure matrix`; `Trace schema for future runtime runs`; `Gates and evidence freshness`.


<a id="file-docs-verification-scenarios-md"></a>

## `docs/verification/scenarios.md`

**Responsibility.** Defines qualification stimuli, independent oracles and stop conditions for representation, framing, lifecycle, network faults, clocks, efficiency, authorization and release.

**Contract and ownership.** Numeric fault levels are experiment inputs rather than promises. Reports use deterministic seeds, explicit time domains, generation/frame ledgers, complete loss accounting and named source/device/network boundaries.

**Failure/change obligations.** Synthetic packet loss does not establish the real adapter fault model. Never relabel concealment as recovered samples, count duplicates twice, or report acoustic latency from unrelated clocks.

**Verification.** For each implemented scenario, preserve actual stimulus, oracle, source hashes and failure traces; compare critical algorithms with analytic bounds and an independently implemented scheduler or ledger.

**Next actionable work.** Implement the remaining runtime fault scenarios and acquire a characterized adapter trace; retain these experiment definitions until actual measured recovery limits justify a supported envelope.

**Declared surface / navigation:** `Qualification scenarios and oracles`; `Observed-adapter scenarios`; `Replay and interpretation`.


<a id="file-docs-verification-v2-independent-md"></a>

## `docs/verification/v2-independent.md`

**Responsibility.** Explains independent oracle relations, bounded campaign and fixture-mTLS qualification scope.

**Contract and ownership.** Records exact-one-record wrapper behavior, negative ABI semantics, resource limits, command reproduction, both application roles and synchronous sink frontier.

**Failure/change obligations.** Both Zig programs are TLS clients; no native TLS-server, device, LAN or universal semantic proof follows. Case-count evidence is finite and source/binary scoped.

**Verification.** Inspect actual differential and 22-case peer reports and associated hashes; run local navigation/reference gates.

**Next actionable work.** Extend qualification with measured host integration while keeping fixtures and production claims separate.

**Declared surface / navigation:** `Independent v2 checks and authenticated application roles`; `Independent oracle and fixed-storage probe`; `Reproduction and resource bounds`; `Authenticated interoperability and exact scope`; `What remains`.


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

**Declared surface / navigation:** `Executable models and their limits`; `Callback publication model`; `Composed runtime ownership model`; `Variable-frame receive and drain model`.


<a id="file-spec-runtime-receivedrain-cfg"></a>

## `spec/runtime/ReceiveDrain.cfg`

**Responsibility.** Selects finite receive/drain bounds and the exact safety/temporal properties checked by TLC.

**Contract and ownership.** Capacity=2, Prefill=2, MaxFrames=3, MaxBlock=2, Fault=none. Checks five invariants and EndProgress; intended terminal stuttering is allowed with CHECK_DEADLOCK FALSE, while temporal progress remains enabled.

**Failure/change obligations.** These bounds are exploration parameters, not device buffer defaults or a production recovery envelope. Larger/different capacities need separately recorded configurations; never weaken properties to suppress a counterexample.

**Verification.** Normal profile currently explores 73 states; runner mutates only Fault and requires four falsifying results. Additional capacities are recorded under verification/runtime-blueprint with their exact config hashes.

**Next actionable work.** Retain this small fast regression and add targeted domains when new semantics require them, including blocks larger than queue capacity and short streams below prefill.


<a id="file-spec-runtime-receivedrain-tla"></a>

## `spec/runtime/ReceiveDrain.tla`

**Responsibility.** Executable finite design model for variable-frame receive custody, partial publication, callback return, short-stream priming and END acknowledgement.

**Contract and ownership.** Admit creates the next frame IDs only with empty pending storage. Publish/Enter/Return move prefixes between ordered sequences. Quiesce attests downstream closure; Ack requires it. Weak fairness of positive transfers, priming and fences supports ended leads-to acked.

**Failure/change obligations.** Four explicit Fault variants overwrite pending, lose a suffix, bypass the ACK fence or suppress END tail priming. No native timing, payload, cryptography, weak-memory or abort semantics are hidden inside the abstraction.

**Verification.** check_models.py --model ReceiveDrain must pass TypeOK, FrameOrder, CallbackCustody, AckFence, Quiescent and EndProgress normally; mutations must yield the named invariant or temporal counterexample, never parser/evaluator errors.

**Next actionable work.** Keep the sequence representation relation connected to future runtime code. Extend only for a concrete missing semantic distinction and preserve old configurations/results; do not claim implementation refinement from bounded enumeration.

**Declared surface / navigation:** `vars`; `Prefix`; `Suffix`; `Frames`; `Init`; `Admit`; `Publish`; `End`; `Prime`; `Enter`; `Return`; `Quiesce`; `Ack`; `PublishSome`; `EnterSome`; `Next`; `Spec`; `TypeOK`; `FrameOrder`; `CallbackCustody`; `AckFence`; `Quiescent`; `EndProgress`.


<a id="file-spec-runtime-runtimeownership-cfg"></a>

## `spec/runtime/RuntimeOwnership.cfg`

**Responsibility.** Sets the reviewed finite exploration bounds and checked properties for RuntimeOwnership.

**Contract and ownership.** Capacity/prefill two, MaxFrames three, MaxEpoch two and DrainTicks two; six invariants and Progress. Intentional final idling is allowed with CHECK_DEADLOCK FALSE.

**Failure/change obligations.** Do not remove fairness/property checks to obtain a pass or confuse logical drain ticks with wall-clock timeout. Changing bounds invalidates old state counts as current evidence.

**Verification.** Run normal and both mutated configurations; compare config hash, state counts and temporal counterexample output.

**Next actionable work.** Add separate larger or adversarial configurations when extending the model and record their resource bounds.


<a id="file-spec-runtime-runtimeownership-tla"></a>

## `spec/runtime/RuntimeOwnership.tla`

**Responsibility.** Executable design state machine for composed frame custody, callback/worker quiescence and bounded graceful drain.

**Contract and ownership.** Finite configuration abstracts capture/transport queues, one in-flight frame and callback-held frame. Custody, IdleEmpty, HeldByCallback, LiveStorage and AuthorizedUse are safety predicates; Progress is conditional temporal liveness.

**Failure/change obligations.** No network fairness is assumed; stop_wait intentionally blocks exit on unreachable drain, early_free bypasses quiescence. Model is not the unimplemented runtime or an audio fidelity/weak-memory proof.

**Verification.** Use check_models.py --model RuntimeOwnership with explicit Java/TLC; normal must pass and both mutants must fail in their named safety/temporal class.

**Next actionable work.** Extend partial-init and multiple-buffer abstractions with WP04 and establish concrete refinement, retaining counterexample sensitivity.

**Declared surface / navigation:** `Roles`; `Phases`; `AsNat`; `vars`; `Init`; `Begin`; `Authorize`; `Capture`; `Send`; `Deliver`; `Prime`; `Graceful`; `Enter`; `Return`; `Empty`; `DrainComplete`; `Clock`; `Deadline`; `Abort`; `StopDevice`; `OwnerExit`; `Free`; `Next`; `Spec`; `TypeOK`; `Custody`; `IdleEmpty`; `HeldByCallback`; `LiveStorage`; `AuthorizedUse`; `Progress`.


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


<a id="file-src-media-block-assembler-zig"></a>

## `src/media/block_assembler.zig`

**Responsibility.** Single-worker bounded copied source-frame assembly before v2 transport.

**Contract and ownership.** Validated immutable Format; pending frames at most negotiated maximum; finite words copied in original order. peek borrows a ready/full or sealed partial block; only commit advances the source frontier. finish and discontinue are explicitly idempotent.

**Failure/change obligations.** Input/storage must not overlap. Reject odd-length/nonfinite accepted prefix/overflow before writes; retain unaccepted suffix at caller. Terminal discontinuity discards pending data and forbids publication; no queue/device actions are hidden.

**Verification.** Independent 1031-frame/chunk oracle at four capacities; EOF/backpressure/partial/error/overflow cases and codec/gate composition in tests/unit/media/assembler.zig, Debug and ReleaseSafe.

**Next actionable work.** WP04 must join source callbacks, drain retained suffixes, observe sticky overrun coherently and commit only after real copied transport custody; assembler alone cannot establish those host facts.

**Declared surface / navigation:** `init`; `push`; `peek`; `commit`; `finish`; `endPosition`; `discontinue`; `std`; `Format`; `BlockAssembler`; `Error`; `Block`; `pending`; `block`.


<a id="file-src-media-format-zig"></a>

## `src/media/format.zig`

**Responsibility.** Checked initial application v2 stereo/f32/rate/block dimensions, independent of host capability.

**Contract and ownership.** Format validates 44100/48000/96000 frames/s, two channels, representation one and 1..1024 max frames. Checked frame counts precede bounded sample/byte products; eql compares every field.

**Failure/change obligations.** Unsupported profile or zero/oversize media counts return typed errors without state. A valid format does not attest that a native endpoint supports it.

**Verification.** tests/unit/protocol/v2.zig checks supported rates, largest products and invalid dimensions/counts.

**Next actionable work.** Use the existing type in real endpoint negotiation and assembly; extend supported representations only with wire, arithmetic and platform evidence.

**Declared surface / navigation:** `validate`; `sampleCount`; `byteCount`; `eql`; `Format`; `Error`; `bytes_per_sample`.


<a id="file-src-media-playout-window-zig"></a>

## `src/media/playout_window.zig`

**Responsibility.** Fixed-storage block-position admission and one-tick media/silence commitment.

**Contract and ownership.** Window(K,M) requires positive dimensions. init binds an epoch. insert checks finite complete PCM, epoch, reserved max sequence and [next,next+K) membership before copying. tick requires nonaliasing M-sample output and fills it completely before advancing.

**Failure/change obligations.** Stale, late, far, duplicate, malformed or exhausted positions fail without publication. No counter wrap; reinitialize only after all old owners stop. It is not a concurrent queue.

**Verification.** Core boundary tests and the independent non-ring oracle exercise 32,768 traces, repeated modulo reuse, silence and exhaustion.

**Next actionable work.** WP05 supplies actual scheduling/contiguous prefill. If v2 uses variable frame ranges, define a separate range-based contract rather than assuming this fixed-block algebra still applies.

**Declared surface / navigation:** `Window`; `init`; `insert`; `tick`; `std`; `Self`; `Error`; `Result`.


<a id="file-src-protocol-negotiation-zig"></a>

## `src/protocol/negotiation.zig`

**Responsibility.** Single-owner sender/receiver v2 authorization, exact format echo, ordered-frame and drain-ACK gate.

**Contract and ownership.** apply handles one logical record once; auth and drain are host attestations. Exact stream/format and contiguous nonwrapping frame ranges; protocol failures change phase to failed without altering prior frontier/binding.

**Failure/change obligations.** No retransmission/retry may reapply a record. Public field mutation is forbidden outside deliberate tests. Control misuse preserves state; failed record cannot be skipped or resumed on the same connection.

**Verification.** tests/unit/protocol/negotiation.zig checks both roles, mismatch, replay, oversized negotiated blocks, empty/partial streams, early ACK and all 140 role/phase/kind/direction cases.

**Next actionable work.** Runtime must enforce host capabilities, transport-custody commit point, actual joins and new-generation reconnect; this gate provides no cryptography or I/O.

**Declared surface / navigation:** `init`; `authorizeChannel`; `confirmDrained`; `apply`; `std`; `v2`; `Negotiation`; `Role`; `Direction`; `Phase`; `Error`; `format`.


<a id="file-src-protocol-v1-zig"></a>

## `src/protocol/v1.zig`

**Responsibility.** Owns the complete experimental jcr-audio/1 binary and quantization contract.

**Contract and ownership.** Header is 36 bytes, maximum record 996; START profile is 48 kHz stereo 240-frame s16LE. Parser.feed returns one borrowed message plus consumed prefix; process before the next feed. Encoders validate bounds/finite samples before writing; decode uses bounded temporary storage.

**Failure/change obligations.** Unknown/malformed header, invalid ID/profile/sequence/length, nonfinite samples and truncation fail explicitly. Parser errors are terminal. Encode input/output cannot overlap; decode permits overlap.

**Verification.** Independent golden bytes, every split position, coalescing/truncation, hostile lengths and all 65,536 s16 round trips in tests/unit/wire.zig; live TLS tests verify stream behavior.

**Next actionable work.** Freeze v1 semantics. WP02 adds protocol/v2.zig for finite f32 bit preservation; never label existing PCM16 quantization lossless for arbitrary captured f32.

**Declared surface / navigation:** `bodySize`; `validId`; `kindOf`; `header`; `validate`; `parse`; `feed`; `finish`; `writeHeader`; `encodeStart`; `encodeEnd`; `encodeAck`; `encodeAudio`; `decodeAudio`; `std`; `alpn`; `StreamId`; `sample_rate`; `channels`; `frames`; `samples`; `header_size`; `pcm_size`; `max_record`; `Kind`; `Error`; `Message`; `kind`; `seq`; `b`; `h`; `Parser`; `Feed`; `n`; `message`; `size`; `record`.


<a id="file-src-protocol-v2-zig"></a>

## `src/protocol/v2.zig`

**Responsibility.** Pure bounded finite-binary32 v2 framing and encoding, independent of record order and transport.

**Contract and ownership.** Fixed 48-byte BE header and LE sample words, at most 8240 bytes. Parse/feed messages borrow input/storage; every word is finite; encode/decode reject before writes and require disjoint buffers.

**Failure/change obligations.** Malformed parser input permanently poisons. Widen frame count before u64 end-overflow check. Unknown kind/flags/profile, truncation and short outputs fail explicitly; never silently resynchronize or quantize.

**Verification.** Literal golden vectors, 131072 finite patterns, every incomplete maximum-record split, coalescing, malformed fields, output atomicity and Debug/ReleaseSafe/cross-target builds.

**Next actionable work.** Maintain the independent oracle/fixture-mTLS regressions while integrating real host/device owners and extending targeted fuzzing; preserve v1 byte compatibility.

**Declared surface / navigation:** `validId`; `kindOf`; `finiteWord`; `bodySize`; `header`; `readProfile`; `validate`; `profile`; `parse`; `feed`; `finish`; `writeHeader`; `encodeProfile`; `encodeControl`; `encodeAudio`; `decodeAudio`; `std`; `Format`; `alpn`; `StreamId`; `header_size`; `profile_size`; `max_samples`; `max_record`; `Kind`; `Error`; `Message`; `kind`; `position`; `frames`; `size`; `h`; `Parser`; `Feed`; `count`; `message`; `body`; `record`; `b`.


<a id="file-src-readme-md"></a>

## `src/README.md`

**Responsibility.** Source ownership map, public entry and dependency reading order.

**Contract and ownership.** Names real files and their import direction; planned folders remain in the design until working code has a first consumer.

**Failure/change obligations.** Keep current and planned status distinct; update semantic source/domain owners together and preserve historical evidence. Never promote documentation coverage into correctness or product readiness.

**Verification.** Review linked canonical sources and tests, then run exact reference/import and local documentation checks.

**Next actionable work.** Revise this chapter when its ownership, implemented behavior or evidence changes; avoid duplicate format/state definitions elsewhere.

**Declared surface / navigation:** `Source ownership and reading order`.


<a id="file-src-root-zig"></a>

## `src/root.zig`

**Responsibility.** Stable pure core exports v1 kernels/queues, v2 Format/codec/Negotiation and bounded BlockAssembler without constructing host owners.

**Contract and ownership.** No native backend or runtime owner is constructed here. Imports point into responsibility folders; preserve public export names during relocation.

**Failure/change obligations.** Adding host imports creates an architectural cycle and makes pure target checks require platform SDKs. New exports require a consumer and a named contract.

**Verification.** Compile core on native Windows, Intel Mac target and optional ARM target; existing core tests consume only this public module.

**Next actionable work.** Preserve distinct v1 block-index and v2 frame-index APIs while production runtime integration is added; keep native/TLS/UI imports outside this module.

**Declared surface / navigation:** `Session`; `Window`; `wire`; `Format`; `BlockAssembler`; `wire_v2`; `Negotiation`; `Receiver`; `FrameQueue`; `CallbackBridge`.


<a id="file-src-runtime-pending-block-zig"></a>

## `src/runtime/pending_block.zig`

**Responsibility.** Private pure receiver custody: decode/copy one complete v2 AUDIO and retain its unqueued whole-frame suffix.

**Contract and ownership.** One serialized owner; immutable validated format; fixed 2048-f32 storage; nonwrapping source range and 0<=offset<=frames. admit borrows disjoint wire bytes only until return and uses the existing decoder; peek borrows until mutation; advance transfers only an already-copied prefix.

**Failure/change obligations.** Busy, Aborted, invalid kind/profile/range/payload and excessive advance never partially change state. abort returns only locally pending discard once, poisons further operations and performs no queue cleanup or joins. Positive advance is not idempotent.

**Verification.** Seven independent unit cases cover varied capacities/records/finite words, short/zero writes, failure atomicity, u64 frontier, Busy, abort and parser reuse/candidate gate commit. The authenticated v2 fixture is a real composed caller with a synchronous queue sink.

**Next actionable work.** Use this private pending_audio build module in the future playback_receiver; add real cancellation/native callback fences and preserve the documented gate-versus-publication frontier distinction.

**Declared surface / navigation:** `init`; `admit`; `peek`; `advance`; `abort`; `core`; `wire`; `PendingBlock`; `Error`; `Block`; `count`; `discarded`.


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


<a id="file-tests-integration-loopback-transport-zig"></a>

## `tests/integration/loopback_transport.zig`

**Responsibility.** Shared test-only Windows short-transfer network owner for the two v2 application-role probes.

**Contract and ownership.** Wrap reviewed demo C socket; one owner, explicit open/close, would-block null, bounded polling against unchanged Driver deadline. No configurable remote address or production identity policy.

**Failure/change obligations.** Close exactly once after users/Driver finish. Transport EOF, failure and would-block remain distinct; no ambient fallback endpoints or deadline renewal.

**Verification.** Both v2 probe roles execute against independent Python peers, including stalled/abrupt/fragmented cases and mandatory thread/process termination.

**Next actionable work.** Production WP03 networking must replace loopback fixture policy with real endpoint/readiness/cancellation contracts; this helper is not a production transport.

**Declared surface / navigation:** `demo_now`; `demo_name`; `demo_open`; `demo_close`; `demo_send`; `demo_recv`; `demo_poll`; `open`; `close`; `send`; `recv`; `run`; `tls`; `Network`; `socket`; `n`; `result`; `now`.


<a id="file-tests-integration-protocol-v2-peer-py"></a>

## `tests/integration/protocol_v2_peer.py`

**Responsibility.** Independent Python fixture-mTLS server for both Zig media-role clients.

**Contract and ownership.** Ephemeral loopback, real certificate/ALPN checks, independently constructed expected records/words, bounded sockets/processes/threads, fresh report with binary hashes. Successful receive role cross-checks Zig exact-word marker and ACK frontier.

**Failure/change obligations.** Unexpected crash/timeout/thread leak fails; protocol-negative scenarios require their named error and no success marker. Existing/outside report paths reject before network setup. Public fixtures are not production credentials.

**Verification.** Run all 22 scenarios against freshly built binaries and reviewed pins. Receiver successes require exact QUEUE frame total, and nonempty success requires positive short/zero-write observations, in addition to the independent bytes/ACK/clean-close oracle.

**Next actionable work.** Add native TLS-server/platform/device qualification separately and preserve independent byte comparison rather than importing Zig-generated expectations.

**Declared surface / navigation:** `receive_exact`; `receive_record`; `fragmented_send`; `run_case`; `main`.


<a id="file-tests-integration-protocol-v2-reference-py"></a>

## `tests/integration/protocol_v2_reference.py`

**Responsibility.** Independent Python struct/integer-word oracle and synthetic media constructor for v2.

**Contract and ownership.** Reads canonical 48-byte schema, bounds lengths/count/frontier and finite exponent bits without production Zig helpers or float conversions. record deliberately permits malformed bodies for negative tests.

**Failure/change obligations.** Reject unsupported/unknown header or profile fields and exact extent mismatches; unexpected oracle exceptions fail qualification rather than being treated as protocol rejection.

**Verification.** Literal vectors and differential corpus, plus full independent expected-byte comparisons in the TLS application peers.

**Next actionable work.** Extend only when canonical wire semantics change; preserve algorithmic independence and reference byte patterns.

**Declared surface / navigation:** `record`; `profile`; `samples`; `decode`.


<a id="file-tests-integration-tls-receiver-zig"></a>

## `tests/integration/tls_receiver.zig`

**Responsibility.** Synthetic mTLS receiver delivering v1 PCM through null playback callbacks.

**Contract and ownership.** Authenticate before media, own parser/receiver/device/Driver, retain partial writes, bound the total transfer, drain callback copying before ACK and require clean close.

**Failure/change obligations.** Assertions must fail on unexpected behavior; no arbitrary crash counts as expected rejection. Threads/devices/sockets must be reclaimed on every test exit.

**Verification.** Run its owning build step in Debug and ReleaseSafe where native execution is supported; preserve exact commands and failures. Extracted test names below enumerate current cases.

**Next actionable work.** WP04 builds real runtime owners separately; frozen fixture wall time, public keys and loopback transport never become production defaults.

**Declared surface / navigation:** `demo_open`; `demo_close`; `demo_send`; `demo_recv`; `demo_poll`; `demo_now`; `demo_name`; `send`; `recv`; `run`; `main`; `std`; `tls`; `core`; `audio`; `wire`; `Network`; `n`; `result`; `now`; `started`; `transfer_deadline`; `fed`; `count`; `ack`; `ending`.


<a id="file-tests-integration-tls-v2-zig"></a>

## `tests/integration/tls_v2.zig`

**Responsibility.** Test-only Zig application sender/receiver clients exercising v2 over authenticated loopback TLS.

**Contract and ownership.** Both application-role executables are fixture TLS clients. Receiver candidate gate commits after PendingBlock copied admission, then an eight-frame queue and synchronous three-frame verifier force short/zero writes and compare independent expected words. ACK attests this sink only.

**Failure/change obligations.** Bound receiver fixture to 1285 frames and total transfer deadline; reject wrong protocol order/sample/frontier and trailing plaintext. ACK means synchronous test verification only; never claim actual device drain.

**Verification.** Twenty-two independent Python peer scenarios across both application roles, with successful clean shutdown and exact expected errors for negative cases.

**Next actionable work.** Retain as independent regression while real endpoints/credentials and callback/device owners are implemented; TLS server and native Mac roles remain separate gates.

**Declared surface / navigation:** `drain`; `next`; `sendRecord`; `main`; `std`; `tls`; `core`; `Pending`; `wire`; `Gate`; `net`; `sender`; `sizes`; `words`; `QueuedVerifier`; `accepted`; `consumed`; `Reader`; `fed`; `result`; `started`; `deadline`; `ack`; `message`; `ending`.


<a id="file-tests-integration-v2-codec-probe-zig"></a>

## `tests/integration/v2_codec_probe.zig`

**Responsibility.** Test-only C ABI adapter comparing direct parsing, fragmented parsing and byte-preserving re-encoding.

**Contract and ownership.** Bound input to 8241 bytes, parser to 8240, fixed decode scratch; positive return is encoded length, zero semantic rejection, negative harness misuse/internal disagreement. Borrow pointers only for the call.

**Failure/change obligations.** A parser error must poison later calls. Exactly-one-record policy rejects leftover bytes. Negative status or mutated output on rejection must fail the external harness, not be counted as expected rejection.

**Verification.** Build v2-codec-probe and run the independent Python campaign against Debug and ReleaseSafe DLLs; retain binary hash, seed and last in-flight case.

**Next actionable work.** Keep this ABI confined to tests; do not deploy it or bypass production ownership with raw foreign pointers.

**Declared surface / navigation:** `std`; `v2`; `bytes`; `direct`; `fed`; `accepted`; `message`; `original`; `out`; `record`; `samples`; `jcr_v2_probe`.


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

**Contract and ownership.** Collect unit suites for session/window, v1/v2 framing, negotiation, SPSC callbacks, capture assembly and private pending receive custody through their actual build modules; no physical device or network access.

**Failure/change obligations.** Assertions must fail on unexpected behavior; no arbitrary crash counts as expected rejection. Threads/devices/sockets must be reclaimed on every test exit.

**Verification.** Run its owning build step in Debug and ReleaseSafe where native execution is supported; preserve exact commands and failures. Extracted test names below enumerate current cases.

**Next actionable work.** WP04 adds composed lifecycle tests separately; do not replace this oracle with the production ring algorithm.

**Declared surface / navigation:** `std`; `core`; `expect`; `first`; `second`; `result`; `action`; `available`; `authentication and callback drain gate restart`; `reorder duplicate loss and late arrival preserve media positions`; `malformed and stale input cannot publish a block`; `ring reuse matches expected ordered blocks across many revolutions`; `finite counters fail before wrap and leave output untouched`; `all 32768 five-action traces agree with an independent non-ring oracle`.


<a id="file-tests-unit-media-assembler-zig"></a>

## `tests/unit/media/assembler.zig`

**Responsibility.** Adversarial whole-frame and source-frontier tests for BlockAssembler independent of hardware.

**Contract and ownership.** Uses absolute input indices and integer sample words across differing callback chunk and block sizes; tests both healthy conservation and deliberate terminal discontinuity.

**Failure/change obligations.** Use usize for slice endpoints before multiplying by channel count; preserve initial inferred-width test failure as evidence. Deliberate frontier injection only tests u64 boundaries, not normal application access to internals.

**Verification.** Six cases run through the public core test entry in Debug/ReleaseSafe; compare word identity, exact positions, preserved state on rejection and late EOF/commit behavior.

**Next actionable work.** Add real capture queue/overrun races and transport backpressure tests when the worker owner exists; do not replace the independent sequence oracle with a copy of assembler logic.

**Declared surface / navigation:** `std`; `core`; `Assembler`; `expect`; `total`; `chunks`; `copied`; `input`; `block`; `before`; `tail`; `record`; `end`; `assembly preserves arbitrary callback prefixes and final partial block`; `assembly backpressure leaves block and caller suffix intact`; `assembly rejected accepted prefix leaves previous data unchanged`; `assembly EOF and discontinuity have different terminal meanings`; `assembly checks terminal u64 frontier before storing samples`; `assembly output composes with v2 encoding and exact frame negotiation`.


<a id="file-tests-unit-protocol-negotiation-zig"></a>

## `tests/unit/protocol/negotiation.zig`

**Responsibility.** Exercise the published v2 phase/role/direction table and semantic stream-continuity failures.

**Contract and ownership.** Real workflow tests construct states via methods; table test deliberately injects seven states and uses literal permission masks over two roles, five kinds and two directions.

**Failure/change obligations.** Early ACK requires actual host attestation in production; test attestations do not imply native joining. Rejected apply must become terminal without advancing frontier.

**Verification.** Run the imported core suite in both modes; inspect all 140 control combinations plus payload mismatch and discontinuity tests.

**Next actionable work.** Extend state table and independent expected masks together when protocol semantics change; later runtime tests must add transport/backpressure/cleanup interactions.

**Declared surface / navigation:** `streaming`; `std`; `core`; `v2`; `Gate`; `expect`; `audio`; `end`; `ack`; `offer`; `altered`; `gap`; `wrong`; `oversized`; `allowed`; `phases`; `kinds`; `directions`; `record`; `direction_index`; `permitted`; `v2 both roles preserve partial-block frontier and require receiver drain`; `v2 unauthorized, wrong-role and altered-accept records fail closed`; `v2 discontinuities wrong-stream oversized blocks and early ACK are terminal`; `v2 empty streams complete but replay and audio-before-accept cannot`; `v2 explicit role phase kind direction table covers 140 combinations`.


<a id="file-tests-unit-protocol-v2-zig"></a>

## `tests/unit/protocol/v2.zig`

**Responsibility.** Independent representation expectations and adversarial framing/value/format tests for the v2 pure codec.

**Contract and ownership.** Literal header/body vectors and byte shifts do not call production serialization to create their expected values; seeded sample corpus is finite and reproducible. Exhaust every incomplete split of maximum record.

**Failure/change obligations.** Compare float words, not numeric equality, to preserve negative zero. Check unchanged output after errors and parser poison rather than testing only happy-path round trips.

**Verification.** Included by tests/unit/core.zig and executed in Debug/ReleaseSafe; compile pure test artifact for Intel Mac and ARM64 Linux.

**Next actionable work.** Maintain unit coverage alongside the independent corpus/peers; broaden explicit boundary cases when fields or failure evidence change. Current samples do not exhaust all byte strings or float words.

**Declared surface / navigation:** `std`; `core`; `v2`; `expect`; `offer`; `audio`; `boundary`; `record`; `first`; `second`; `a`; `b`; `offsets`; `before`; `v2 independent literal offer and AUDIO bytes`; `v2 finite boundaries and seeded words preserve exact little endian bits`; `v2 every maximum record split and coalescing respect borrowed boundaries`; `v2 malformed fields poison parsers without resynchronization`; `v2 all rejected encodes and nonfinite decodes preserve caller output`; `v2 checked formats bound dimensions before products`.


<a id="file-tests-unit-runtime-pending-block-zig"></a>

## `tests/unit/runtime/pending_block.zig`

**Responsibility.** Independent source-indexed sample-word oracle for pending receiver custody and explicit parser/gate lifetime cases.

**Contract and ownership.** Construct payload integer words separately from production encoding; compare every consumed word through queue capacities 1,8,32,4096 and records 1,17,240,1024,3. Bound loop counts; initialize all compared storage in failure-atomicity checks.

**Failure/change obligations.** Losing/reordering an unqueued suffix, moving a candidate gate on Busy, reusing parser storage as owned PCM, wrapping source range or duplicate discard must fail a named check. No devices, network or mathematical-proof claim.

**Verification.** Run the pure test step in Debug and ReleaseSafe and compile the pure suite for Intel Mac/ARM Linux. The initial invalid array-literal-index syntax and pre-repair test are preserved separately.

**Next actionable work.** Extend with actual native worker failure/cancel scheduling when C02/C05 exist, keeping expectations derived from a separate source ledger rather than production counters.

**Declared surface / navigation:** `word`; `audio`; `checkSamples`; `std`; `core`; `wire`; `Pending`; `expect`; `edges`; `accepted`; `requests`; `requested`; `got`; `before`; `stable`; `suffix`; `a`; `b`; `first`; `second`; `pending prefixes preserve independent source words through varied queue capacities`; `pending admission failures preserve all initialized storage and metadata`; `pending busy rejection and cursor boundaries do not consume the suffix`; `pending terminal abort reports only local outstanding custody once`; `pending permits a nonwrapping exclusive u64 end but no wrapped range`; `pending rejects invalid initialization profiles and zero AUDIO`; `pending copied ownership survives parser reuse and blocked gate admission`.


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

**Contract and ownership.** Reads the three declared sibling projects and explicit contracts; writes only docs/reference outputs. Excludes top-level verification evidence and caches, includes authored docs/verification, and inventories installed SDK assets without modifying them.

**Failure/change obligations.** Missing or stale reviewed contract entries fail. Generated placeholders are overwritten during successful render; the tool must not touch pins, source, secrets or upstream bytes.

**Verification.** Run renderer then check_docs/check_handoff; require authored docs/verification chapters in the index and top-level verification evidence outside it. Review semantic contracts and verify SDK pins separately.

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

**Responsibility.** Runs five bounded TLC design/component models and their falsifying mutations in isolated temporary directories.

**Contract and ownership.** Explicit Java/jar inputs; per-model folder, bounds and expected invariant/temporal failure. Reports model, configuration, runner and jar hashes; prints JSON and returns failure if any expected result is absent.

**Failure/change obligations.** Parser/evaluation errors and timeouts are not counterexamples. TEMPORAL classification requires TLC temporal-property violation text. Preserve unsuccessful attempts and never weaken a property to obtain a pass.

**Verification.** Select the affected model with explicit Java/TLC. All five profiles together define five normal checks and fifteen expected counterexamples; archive exact source/config/tool hashes and raw output. New ReceiveDrain has four faults.

**Next actionable work.** Add an explicitly reviewed profile only with its model/config, scoped argument, assumptions and mutation expectations; do not infer source refinement from tool success.

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

**Next actionable work.** Retain the v1 regression while the separate v2 independent peers qualify protocol behavior. WP04 adds real host/device/credential integration and two-host evidence; preserve distinct fresh report paths.

**Declared surface / navigation:** `record`; `pcm`; `peer_context`; `receive_exact`; `run_case`.


<a id="file-tools-test-v2-differential-py"></a>

## `tools/test_v2_differential.py`

**Responsibility.** Fixed-seed bounded independent record acceptance/round-trip campaign in a killable native child.

**Contract and ownership.** At most 14000 cases, 8241 bytes/input, 120-second child deadline; exact acceptance/bytes/rejection-sentinel checks; exclusive fresh verification report and an in-flight reproducer for crashes/hangs.

**Failure/change obligations.** Existing/outside report paths or missing/outside test libraries fail before loading. A timeout, negative ABI result or disagreement fails; structural memory bounds are not a whole-process OS memory quota.

**Verification.** Current corpus has 13631 cases and identical hash in Debug/ReleaseSafe, with 1017 accepted and 12614 rejected; report guards checked separately.

**Next actionable work.** Broaden targeted/generated cases when a new field or counterexample warrants it. Preserve seeds/reproducers and never silently change expected outcomes to match Zig.

**Declared surface / navigation:** `corpus`; `worker`; `main`.


<a id="file-transport-lock-json"></a>

## `transport-lock.json`

**Responsibility.** Reviewed exact TLS source/SDK/fixture adoption identity for current Windows integration.

**Contract and ownership.** Reviewed exact TLS source/SDK/fixture adoption inputs, not a generated inventory. The 2026-09-26 documentation adoption records nine reviewed README/comment/package-path changes and retains all other 179 pins; original code bodies and SDK/fixture bytes are unchanged.

**Failure/change obligations.** Do not hand-edit a hash to hide source drift. A new platform/dependency revision needs an explicit adoption diff and qualified binaries.

**Verification.** tools/check_transport.py and staged DLL checks; independent runtime path validation belongs to the TLS tests.

**Next actionable work.** WP01 defines target-specific Mac identity and package closure; retain original Windows/source provenance.

**Declared surface / navigation:** `adopted`; `root`; `package_version`; `profile`; `files`; `runtime_dlls`; `runtime_imports`; `upstream`; `scope`; `reviewed_documentation_adoptions`.
