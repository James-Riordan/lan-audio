# lan-audio: granular file contracts

Generated from reviewed `tools/reference_contracts.json`. Edit the contract data, then render; do not edit this chapter alone.


<a id="file-gitattributes"></a>

## `.gitattributes`

**Responsibility.** Preserve exact vendored bytes across Windows and macOS Git checkouts.

**Contract and ownership.** Dependency copies are binary-attributed; launch scripts retain appropriate shell line endings.

**Failure/change obligations.** Reject incomplete, conflicting or untrusted inputs; preserve original errors and saved identities. Do not turn Windows or loopback checks into Mac speaker readiness.

**Verification.** Run repository_launcher.py and desktop_setup.py plus custody and application documentation gates; inspect native Mac CI and hardware evidence separately.

**Next actionable work.** Execute the clean native Mac build and real Windows-to-Mac speaker session; preserve target-specific failures before expanding platform claims.


<a id="file-github-workflows-desktop-yml"></a>

## `.github/workflows/desktop.yml`

**Responsibility.** Run clean Windows and Intel Mac preparation and onboarding checks on GitHub.

**Contract and ownership.** Pinned checkout action with read-only repository permission; actual launcher builds and tests; no audio hardware or publication.

**Failure/change obligations.** Reject incomplete, conflicting or untrusted inputs; preserve original errors and saved identities. Do not turn Windows or loopback checks into Mac speaker readiness.

**Verification.** Run repository_launcher.py and desktop_setup.py plus custody and application documentation gates; inspect native Mac CI and hardware evidence separately.

**Next actionable work.** Execute the clean native Mac build and real Windows-to-Mac speaker session; preserve target-specific failures before expanding platform claims.


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

**Responsibility.** Build pure/native contracts, foreground streaming CLI, live worker probes and explicit Intel Mac static SDK integration.

**Contract and ownership.** Build pure core and a private pending_audio module used by tests and live receive workers; core-check compiles both. Native audio and opt-in TLS fixtures retain separate modules and explicit hardware steps; no new public package/core export. Private lifecycle module and lifecycle-test/lifecycle-check steps compile actual controller/fake owners; default test includes lifecycle execution, and check includes its compile. Requested lifecycle runs always execute. Unspecified macOS minimum versions resolve to 12.0 for Monterey compatibility; explicit target ranges are preserved. This floor does not qualify dependency load commands or execution. Streaming is enabled by default only on Windows x64; Intel Mac requires explicit streaming and static OpenSSL SDK. App runs stage runtime DLLs; ordinary tests never invoke physical capture.

**Failure/change obligations.** Wrong targets, missing SDK/runtime and ABI/link mismatches must fail. A successful cached compile does not prove execution or correct runtime search paths.

**Verification.** Core/lifecycle history plus current audio/network Debug and ReleaseSafe artifacts; network-check compiles the selected target without executing it. Monterey remains the unspecified macOS minimum.

**Next actionable work.** Live workers now consume this boundary. Preserve copied-write settlement and actual join/fence ownership; qualify native Mac and sustained multi-device operation.

**Declared surface / navigation:** `build`; `std`; `optimize`; `config_tests`; `config_run`; `network`; `network_c`; `network_tests`; `network_run`; `core`; `peer_policy`; `channel_admission`; `policy_tests`; `policy_run`; `policy_object`; `pending`; `tests`; `test_step`; `core_run`; `recovery_tests`; `recovery_run`; `timing_tests`; `timing_run`; `lifecycle`; `receive_drain`; `send_drain`; `lifecycle_tests`; `lifecycle_run`; `codec_probe`; `transport_tests`; `streaming`; `mac_openssl`; `native_audio_supported`; `unavailable`; `dependency`; `consumer`; `check`; `audio_host`; `app`; `app_options`; `app_step`; `app_run`; `app_files`; `callback_tests`; `host_contract_tests`; `audio_test_step`; `callback_run`; `host_contract_run`; `audio_check_step`; `capture_test`; `windows`; `mac`; `transport`; `tls_module`; `module`; `verified`; `platform`; `platform_c`; `platform_tests`; `platform_run`; `runtime`; `supervisor`; `recovery_probe`; `recovery_install`; `worker_probe`; `worker_install`; `verified_probe`; `verified_install`; `probe_module`; `probe`; `install`; `v2_install`; `options`; `executable`.


<a id="file-build-zig-zon"></a>

## `build.zig.zon`

**Responsibility.** Own package identity, version/compiler floor, dependency declarations and distribution allowlist.

**Contract and ownership.** ZON is Zig package metadata, distinct from ZSON. Fingerprint is identity, not artifact integrity. Sibling paths are development dependencies and require a release closure. Repository launch now uses checked-in third_party snapshots; external sibling edits do not alter adopted build inputs.

**Failure/change obligations.** Do not silently rename identities or raise compiler floor; changes need compatibility and clean-checkout evidence. Excluded source/docs must not break packages.

**Verification.** Parse/build with pinned compiler; test package allowlist and downstream import from a clean layout.

**Next actionable work.** WP09 replaces development-only assumptions with reproducible source/package custody and includes all required handoff documents.


<a id="file-docs-architecture-ecosystem-integration-md"></a>

## `docs/architecture/ecosystem-integration.md`

**Responsibility.** Translate James's JCR vision into LAN Audio ownership, optional integration, identity, lifecycle and documentation-migration requirements.

**Contract and ownership.** Keep ZApp policy distinct from technology libraries and ecosystem owners; freeze resolved operation identity/settings, revalidate capabilities, define operation-specific retries and qualified optional package closure.

**Failure/change obligations.** No ecosystem membership imports an API, account or dependency. Context changes cannot redirect a live stream; extension renaming cannot implement Docz; repeated media advance is not idempotent.

**Verification.** Review against canonical ownership, actual admitted dependency graph, current PendingBlock API and configuration-resolution obligations; local link/index checks prove navigation only.

**Next actionable work.** Implement C02-C06 first, then admit optional adapters with real callers, source-scoped equivalence/failure tests and owner-backed format migration evidence.

**Declared surface / navigation:** `LAN Audio within the JCR ecosystem`; `Product identity and dependency direction`; `Decoupling with explicit identity and capability`; `Simple operations over one engine`; `Retry, update and diagnostic laws`; `Quartz / Docz migration gate`; `Implementable obligations`.


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

**Declared surface / navigation:** `Platform awareness and graceful incompatibility`; `Capability records, not operating-system guesses`; `Plain-language control states`; `Expanded support objective (2026-09-26)`.


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

**Contract and ownership.** Keep terminology, existing versus proposed behavior, source paths and acceptance claims synchronized with the owning implementation/work package. Repository launch now uses checked-in third_party snapshots; external sibling edits do not alter adopted build inputs.

**Failure/change obligations.** Do not duplicate conflicting protocol/API meaning or imply unexecuted platform support. Preserve useful history and label superseded claims rather than erasing evidence.

**Verification.** Validate local navigation and file index, compare referenced source behavior and evidence dates/hashes; prose quality requires review beyond automated checks.

**Next actionable work.** Read the declared sections below; update this guide whenever its owned contract changes and link to granular implementation/verification obligations.

**Declared surface / navigation:** `Dependency closure and architecture decisions`; `Actual admitted graph`; `Observed candidates, with explicit admission decisions`; `Decisions and rejected shortcuts`; `Provenance`; `Records identity adoption (2026-09-26)`.


<a id="file-docs-design-configuration-resolution-md"></a>

## `docs/design/configuration-resolution.md`

**Responsibility.** Proposed typed configuration algebra and source-by-source implementation contract for C06/WP08.

**Contract and ownership.** Separate Zig build/package, ZSON profile and invocation authority; deterministic pure resolution retains provenance; mandatory policy follows precedence; immutable Effective snapshots precede native acquisition.

**Failure/change obligations.** Reject duplicate/unknown/version/unit/range errors without side effects. Preserve settings on failed publication and reject revision conflicts. Context and capability snapshots have distinct lifetimes.

**Verification.** Planned independent tests check precedence/reset/array laws, normalization idempotence, policy non-bypass, resource bounds, failure purity, native revalidation and publication fault schedules; none exists merely because this design names it.

**Next actionable work.** Create proposed app config/settings/command files only with C06 callers and tests; use typed CLI inputs before adding an owner-qualified ZSON adapter.

**Declared surface / navigation:** `Configuration resolution and operation snapshots`; `Four separate authorities`; `Pure normalization, policy and feasibility`; `Bounds, identity and time`; `Publication and restart`; `Planned files and dependency order`.


<a id="file-docs-design-lifecycle-transactions-md"></a>

## `docs/design/lifecycle-transactions.md`

**Responsibility.** C02 startup/cancel/reclaim transaction contract, explicit proposed call surface and model refinement boundary.

**Contract and ownership.** Issued acquisitions retain parents and reserved result slots; late success creates cleanup debt; exact operation tokens isolate events; native/worker fences precede release; outcome dimensions remain distinct. C02a acquisition/abort/reclaim is now implemented; its exact narrower API and evidence are in docs/runtime/lifecycle-core.md.

**Failure/change obligations.** Never erase pending work on cancel, free parent storage during startup, infer native join from queue-empty or suppress uncertain remote completion. A hanging native call retains resources.

**Verification.** Read actual C02a source and independent fake-owner tests, the unchanged earlier finite model and lifecycle-core source-scoped receipt. Preserve full-C02/native/graceful gaps.

**Next actionable work.** Extend the existing controller with graceful media custody/outcome composition, then qualify native C03 mappings; do not restart preparation or declare all C02 complete.

**Declared surface / navigation:** `Lifecycle transactions: partial startup through final reclamation`; `The ownership problem`; `State, identity and authority`; `Commands and completion transactions`; `Proposed C02 call surface`; `Cleanup dependencies and fences`; `Graceful completion and outcome ordering`; `Executable abstraction and mathematical limits`; `Implementation/refinement acceptance`.


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

**Contract and ownership.** Maintain human-first README task paths alongside engineering explanations and canonical domain/file contracts. Commands name prerequisites, shell, directory, placeholders, expected outcomes and native verification limits.

**Failure/change obligations.** Keep current and planned status distinct; update semantic source/domain owners together and preserve historical evidence. Never promote documentation coverage into correctness or product readiness.

**Verification.** Review linked canonical sources and tests, then run exact reference/import and local documentation checks.

**Next actionable work.** Revise this chapter when its ownership, implemented behavior or evidence changes; avoid duplicate format/state definitions elsewhere.

**Declared surface / navigation:** `Documentation is maintained engineering data`; `READMEs are for people first`; `Three complementary reading levels`; `Definition of a documented source change`; `Change checklist and authority`; `Concurrent dependency work`.


<a id="file-docs-development-workflow-md"></a>

## `docs/development/workflow.md`

**Responsibility.** Concrete workflow for one bounded code/document change and reproducible evidence.

**Contract and ownership.** Preserve before-images in this non-Git checkout, use pinned tools, separate code execution from cross-builds, update contracts and seal new observations without rewriting history.

**Failure/change obligations.** Keep current and planned status distinct; update semantic source/domain owners together and preserve historical evidence. Never promote documentation coverage into correctness or product readiness.

**Verification.** Review linked canonical sources and tests, then run exact reference/import and local documentation checks.

**Next actionable work.** Revise this chapter when its ownership, implemented behavior or evidence changes; avoid duplicate format/state definitions elsewhere.

**Declared surface / navigation:** `Make one complete change and leave a reproducible record`; `Choose a bounded responsibility`; `Implement and verify at the right boundary`; `Update the living explanation`; `Seal the observation`.


<a id="file-docs-first-run-md"></a>

## `docs/first-run.md`

**Responsibility.** Give explicit candidate build, private-pair setup and foreground desktop commands.

**Contract and ownership.** Ordered candidate build and one-command Windows bootstrap/Mac install with explicit directories, outputs and Mac verification limits; daily start/check use installed executable-relative profiles. Repository launch now uses checked-in third_party snapshots; external sibling edits do not alter adopted build inputs. Shared automatic launcher configuration selects environment overrides without rewriting saved profiles; final native session validation precedes audio, and help avoids downloads.

**Failure/change obligations.** Never imply production readiness, zero latency, gapless recovery or verified Apple support; no public fixture credentials for users.

**Verification.** CLI help/build, fresh-pair tests, Windows physical capture evidence; Mac instructions await native execution.

**Next actionable work.** Qualify the real Windows-to-Mac journey, then sustained clock/jitter recovery and remaining Apple/platform release gates; preserve explicit evidence limits.

**Declared surface / navigation:** `Set up Windows-to-Mac audio`; `Before starting`; `1. Run the Mac first`; `2. Run Windows and pair once`; `3. Play sound`; `Every later session`; `One configuration for both computers`; `Saved settings`; `Troubleshooting`.


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

**Declared surface / navigation:** `Decision register`; `Changes that require explicit records`; `macOS version compatibility`; `Primary reference boundaries`.


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


<a id="file-docs-implementation-takeover-readiness-md"></a>

## `docs/implementation/takeover-readiness.md`

**Responsibility.** Audit of decisions settled before implementation and facts deferred to explicit host/user/release gates.

**Contract and ownership.** Names C02 as the next unit, separates model preparation from implementation, and assigns lifetime/fidelity/transport/configuration/drift/native/UI/document/release obligations to their existing owners. C02a acquisition/abort/reclaim is now implemented; its exact narrower API and evidence are in docs/runtime/lifecycle-core.md.

**Failure/change obligations.** No readiness percentage or complete-product claim; missing hardware cannot be supplied by prose. Do not turn a candidate dependency capability into a default runtime replacement.

**Verification.** Read actual C02a source and independent fake-owner tests, the unchanged earlier finite model and lifecycle-core source-scoped receipt. Preserve full-C02/native/graceful gaps.

**Next actionable work.** Extend the existing controller with graceful media custody/outcome composition, then qualify native C03 mappings; do not restart preparation or declare all C02 complete.

**Declared surface / navigation:** `Takeover readiness: what is settled and what still needs evidence`; `The next implementable unit`; `Decisions that must not be guessed`; `Implementation order and branch conditions`; `Before declaring any slice complete`.


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

**Next actionable work.** Native Socket/TLS/verified-peer/v2 mapping is implemented. Complete credential storage, actual audio workers and per-OS Apple build/runtime qualification before closing WP03.

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

**Next actionable work.** Qualify the dependency conversion-control blockers before selecting a fine rate actuator, then implement the planned host resampler and independent plant/oracle; preserve source/output frame distinctions.

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


<a id="file-docs-implementation-work-packages-11-apple-receivers-md"></a>

## `docs/implementation/work-packages/11-apple-receivers.md`

**Responsibility.** Required MacBook/iPhone receiver integration and actual-device release gates.

**Contract and ownership.** Separate implemented shared components from proposed native application and qualification work.

**Failure/change obligations.** Do not equate synthetic policy or cross-compilation with real Apple playback or installability.

**Verification.** Source-specific tests, document/index/link checks and separately recorded native/build evidence.

**Next actionable work.** Keep exact user target, immutable evidence and next executable integration obligation current.

**Declared surface / navigation:** `WP11 — Native MacBook and iPhone receivers`; `Shared behavior, native host integration`; `Platform obligations`; `Acceptance`.


<a id="file-docs-literate-proof-ledger-md"></a>

## `docs/literate/proof-ledger.md`

**Responsibility.** Owns epistemic status of fourteen claims, including independent v2 qualification, source-prefix assembly and ordered receive/drain custody, with explicit host/refinement obligations.

**Contract and ownership.** Every claim has premises, linked reasoning, actual evidence type and remaining action. Labels manual, bounded checked and tested do not imply each other.

**Failure/change obligations.** A future work package or green unit test cannot silently become a refinement theorem. Preserve historical evidence scope as files change.

**Verification.** Cross-check against actual models, source APIs and immutable verification reports; ensure each claimed new result was executed.

**Next actionable work.** Update claim status when new code, proofs, counterexamples or measurements change the premises or evidence.

**Declared surface / navigation:** `Proof ledger: claims, premises and outstanding obligations`; `Proof work cannot be replaced by repeated assertions`; `Foreground live-worker refinement`; `Quiescent session recovery`; `Bounded operation configuration`.


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

**Declared surface / navigation:** `Runtime ownership: composition, cancellation and reclamation`; `Domain, state and deliberate abstractions`; `Actions and their implementation meaning`; `Safety theorem R1 — custody conservation`; `Safety theorem R2 — no reclamation with live references`; `Liveness theorem R3 — stop eventually reaches idle`; `Liveness theorem R4 — graceful drain has an escape`; `Refinement obligations before claiming runtime verification`; `Foreground live-worker refinement`.


<a id="file-docs-literate-stream-argument-md"></a>

## `docs/literate/stream-argument.md`

**Responsibility.** Explains the current audio path in source-frame and memory-ownership order.

**Contract and ownership.** Links actual symbols and explains callback borrowing, publication/reuse, bounded framing, trust, modulo slots, END frontiers and build/package authority. Current v1 behavior stays distinct from planned v2.

**Failure/change obligations.** A borrowed parser/native buffer must not escape its lifetime; no ring occupancy or abstract completion claim may be promoted into an acoustic guarantee.

**Verification.** Compare explanations with AudioDevice, CallbackBridge, FrameQueue, v1, Session, Receiver, Window and build sources; use independent tests named in the ledger.

**Next actionable work.** Extend the narrative with each implemented runtime stage and remove outdated assumptions only after replacement evidence.

**Declared surface / navigation:** `Following one stream: the program and its reasons`; `1. Decide what must survive the journey`; `2. Borrow native memory; publish owned memory`; `3. Prove when a slot can change owners`; `4. Serialize values without inventing trust`; `5. Authenticate the channel before authorizing a generation`; `6. Decide which position can play next`; `7. End a stream without confusing receipt with reclamation`; `8. Reproduce the program being explained`; `Foreground live-worker refinement`.


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

**Declared surface / navigation:** `Product contract`; `Ecosystem requirement`; `Purpose, scope and terminology`; `Quality and resilience requirements`; `Current experimental profile`; `Complete user journey and failure behavior`; `Acceptance obligations`; `Repeatable controls and cross-platform behavior`.


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

**Contract and ownership.** Separate application use from developer lookup; point current availability and tested behavior to the actual candidate and scoped runtime results.

**Failure/change obligations.** Keep current and planned status distinct; update semantic source/domain owners together and preserve historical evidence. Never promote documentation coverage into correctness or product readiness.

**Verification.** Review linked canonical sources and tests, then run exact reference/import and local documentation checks.

**Next actionable work.** Revise this chapter when its ownership, implemented behavior or evidence changes; avoid duplicate format/state definitions elsewhere.

**Declared surface / navigation:** `LAN Audio documentation`; `Use the application`; `Work on the code`.


<a id="file-docs-reference-api-contracts-md"></a>

## `docs/reference/api-contracts.md`

**Responsibility.** Call-by-call maintenance contract for current session, media, queue, device, TLS Engine/Driver and native ABI surfaces.

**Contract and ownership.** Owns current preconditions, state/custody effects, return/progress meanings and failure obligations; planned v2/runtime APIs stay in implementation work packages.

**Failure/change obligations.** Do not treat public field visibility as valid invariant bypass or a document as proof. API changes require source, caller and regression updates together.

**Verification.** Compare listed calls with source declarations, independent tests and formal maps; run relevant affected gates after edits.

**Next actionable work.** Use alongside the per-file chapter when changing an existing method; record new ownership/error semantics and keep future designs separately labeled.

**Declared surface / navigation:** `Existing API contracts: call-by-call maintenance guide`; `Session — src/session/session.zig`; `Window — src/media/playout_window.zig`; `V1 framing and conversion — src/protocol/v1.zig`; `Receiver — src/session/receiver.zig`; `SPSC, callback bridge and native owner`; `TLS Engine — ../tls-zig/src/root.zig`; `TLS Driver — ../tls-zig/src/driver.zig`; `Native C boundary and miniaudio adoption`; `Private receiver composition`; `Native networking and controlled device failures`; `Selected-peer policy and device inspection`; `Verified native connection`; `Session supervision`.


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


<a id="file-docs-runtime-configuration-md"></a>

## `docs/runtime/configuration.md`

**Responsibility.** Explain implemented profile commands, merge laws, authority and bounds.

**Contract and ownership.** Distinguish validation from credentials/connectivity/playback checks and supported system output from unavailable app/tab capture.

**Failure/change obligations.** Reject malformed requests before side effects; no silent substitution or rewrite of historical evidence.

**Verification.** Review against config.zig, stream_command.zig, create_pair.py and independent tests; native Mac and UI remain unqualified.

**Next actionable work.** Native Mac two-host qualification and explicit capability adapters remain separate release gates.

**Declared surface / navigation:** `Declarative operation profiles`; `First use`; `Resolution and bounds`; `Capture selection and platform limits`; `Evidence and failure interpretation`.


<a id="file-docs-runtime-desktop-setup-md"></a>

## `docs/runtime/desktop-setup.md`

**Responsibility.** Explain one-command desktop installation, saved operations, publication and repeat/recovery behavior.

**Contract and ownership.** Human commands for Windows bootstrap and Mac receiver plus strict declarative setup schema. Separate local integrity from signature/expiry/connectivity and explain exclusive publication versus power-loss durability.

**Failure/change obligations.** Do not describe target code or local staging as qualified Mac behavior, seamless updates, signed artifacts or acoustic readiness.

**Verification.** Review against actual installer, pairing helper and relocated CLI tests; check local links and contract inventory.

**Next actionable work.** Update with source-scoped native Mac and clean-machine results when available.

**Declared surface / navigation:** `Repeat-safe desktop setup`; `Use it`; `Declarative setup`; `Repeat and recover`; `Implementation and limits`; `Verification`.


<a id="file-docs-runtime-device-discovery-md"></a>

## `docs/runtime/device-discovery.md`

**Responsibility.** Copied native enumeration and foreground command contract.

**Contract and ownership.** Separate implemented shared components from proposed native application and qualification work.

**Failure/change obligations.** Do not equate synthetic policy or cross-compilation with real Apple playback or installability.

**Verification.** Source-specific tests, document/index/link checks and separately recorded native/build evidence.

**Next actionable work.** Keep exact user target, immutable evidence and next executable integration obligation current.

**Declared surface / navigation:** `Copied device discovery and the first foreground command`.


<a id="file-docs-runtime-lifecycle-core-md"></a>

## `docs/runtime/lifecycle-core.md`

**Responsibility.** Literate explanation of implemented C02a methods, resource representation, error atomicity, adapter premises, inductive argument and cleanup rank.

**Contract and ownership.** Separates actual three-resource/global-slot controller from proposed full lifecycle API; states generation identity, late cleanup debt, qualified partial acquisition, deadline semantics and fake/native evidence limits.

**Failure/change obligations.** No guarantee of wall-clock completion, truthful foreign adapters, crash exactly-once, acoustic output or complete C02. Keep native unknown-handle/partial-object recovery in explicit adapter custody.

**Verification.** Cross-check actual Zig source and independent test caller; read lifecycle-core phase results and receipt for positive/mutation/compile-only evidence.

**Next actionable work.** Read the implemented C02b receiver extension; complete sender graceful custody and truthful C03 native mappings. Keep original C02a evidence historical.

**Declared surface / navigation:** `Lifecycle core: acquisition, abort and receiver completion`; `Exact boundary and representation`; `Calls, mutation and failure`; `Ownership argument and progress limit`; `Model relationship and tests`; `Next implementation boundary`; `Sender and native extension`.


<a id="file-docs-runtime-live-workers-md"></a>

## `docs/runtime/live-workers.md`

**Responsibility.** Explain actual native worker custody, lifecycle refinement, timing and target limits.

**Contract and ownership.** Trace setup/start/finish ownership publication, fixed aggregate lifetime, copied-write settlement, receive prefill/drain, clocks and platform builds.

**Failure/change obligations.** Keep local consumption distinct from acoustic completion and short loopback evidence distinct from sustained Wi-Fi smoothness.

**Verification.** Source-bound live-worker qualification and application documentation checks.

**Next actionable work.** Qualify the real Windows-to-Mac journey, then sustained clock/jitter recovery and remaining Apple/platform release gates; preserve explicit evidence limits.

**Declared surface / navigation:** `Foreground live audio owners`; `Who may touch each object`; `Capture and copied transport custody`; `Playback and local completion`; `Identity, clocks and builds`.


<a id="file-docs-runtime-native-events-md"></a>

## `docs/runtime/native-events.md`

**Responsibility.** Explain device event publication, media-custody failure, metadata and reconstruction.

**Contract and ownership.** Separate sticky atomics preserve concurrent native reasons; expected stop intent suppresses intentional stop notifications. Failure flags stop later queue consumption. Missing output is neither media nor silence. Opening metadata is immutable; native/data lifetime boundaries remain distinct.

**Failure/change obligations.** No flag proves a native join or repairs a generation; missing event coverage, async fencing and native partial-failure recovery remain open.

**Verification.** Real installed native callback ABI and concurrent-notification tests on null devices, callback custody/counter tests and explicit evidence scopes.

**Next actionable work.** Map real worker abort and all native failure/async/physical paths before production qualification.

**Declared surface / navigation:** `Device events, media failure and reconstruction`; `Event meaning and authority`; `Custody after an output failure`; `Control state, stable metadata and final observations`; `Native source mapping and remaining evidence`.


<a id="file-docs-runtime-native-failures-md"></a>

## `docs/runtime/native-failures.md`

**Responsibility.** Controlled native API failure matrix and actual audio-owner cleanup argument.

**Contract and ownership.** Describe implemented behavior, independent evidence and assumptions; source and raw results remain canonical.

**Failure/change obligations.** Do not generalize loopback/null tests into physical or all-OS readiness. Preserve historical evidence and unresolved gates.

**Verification.** Documentation link/coverage checks plus named source-scoped executable tests.

**Next actionable work.** Update arguments and qualification limits with implementation changes.

**Declared surface / navigation:** `Native failure ownership and reconstruction`; `What the test establishes`; `Limits and next obligations`.


<a id="file-docs-runtime-native-fence-md"></a>

## `docs/runtime/native-fence.md`

**Responsibility.** Explain callback source faults, synchronous native fence and selected endpoint/format acquisition.

**Contract and ownership.** States exact-name selection, copied native-ID lifetime, loopback playback-list mapping, post-open callback ABI and strict native dimensions, partial-acquisition cleanup, synchronous data-loop mapping and coherent final snapshots.

**Failure/change obligations.** Do not infer acoustic completion, native portability, live network success or full production readiness from pure/null tests. Preserve unresolved native debt and unadopted dependency observations.

**Verification.** Native-selection and lifecycle-send evidence retain sources, actual null executions and missing physical/foreign/failure-path gates.

**Next actionable work.** Complete actual endpoint/failure/async/native/network adapters with independent platform-specific evidence before advertising support.

**Declared surface / navigation:** `Callback source faults and the synchronous native fence`; `Fault publication and finite representation`; `Native source mapping and its scope`; `Actual observations and remaining C03 gates`; `Selected endpoints and the callback format boundary`.


<a id="file-docs-runtime-network-owner-md"></a>

## `docs/runtime/network-owner.md`

**Responsibility.** State, prefix, deadline, native resource and platform argument for network_host.

**Contract and ownership.** Describe implemented behavior, independent evidence and assumptions; source and raw results remain canonical.

**Failure/change obligations.** Do not generalize loopback/null tests into physical or all-OS readiness. Preserve historical evidence and unresolved gates.

**Verification.** Documentation link/coverage checks plus named source-scoped executable tests.

**Next actionable work.** Update arguments and qualification limits with implementation changes.

**Declared surface / navigation:** `Serialized native TCP ownership`; `Why one owner`; `Calls and failure boundaries`; `Deadline and progress argument`; `Platform decisions and authority`; `Evidence and remaining gates`.


<a id="file-docs-runtime-network-recovery-md"></a>

## `docs/runtime/network-recovery.md`

**Responsibility.** Explain session recovery ownership, policy, evidence and limits.

**Contract and ownership.** Distinguish callback starvation from native fault, rebind cancellation only while idle, retire all owners before fresh authentication.

**Failure/change obligations.** No claim of clock correction, end-to-end queue bound, perfect network or native Mac qualification.

**Verification.** Source-bound recovery results and documentation checks.

**Next actionable work.** Qualify sustained clock correction and native Intel Mac playback; do not equate recovery with inaudible gaps.

**Declared surface / navigation:** `Recovering an interrupted audio stream`; `Why a fresh stream is necessary`; `Cancellation, ownership and retry`; `Keeping idle Windows capture clocked`; `Scoped media scheduling`; `Evidence and its limits`; `Measured reserve selection and clock domain`.


<a id="file-docs-runtime-peer-authorization-md"></a>

## `docs/runtime/peer-authorization.md`

**Responsibility.** Trust boundary, role/identity policy and repeat-safe admission argument.

**Contract and ownership.** Separate implemented shared components from proposed native application and qualification work.

**Failure/change obligations.** Do not equate synthetic policy or cross-compilation with real Apple playback or installability.

**Verification.** Source-specific tests, document/index/link checks and separately recorded native/build evidence.

**Next actionable work.** Keep exact user target, immutable evidence and next executable integration obligation current.

**Declared surface / navigation:** `Selected-peer authorization and repeat-safe admission`; `Trust boundary`; `Policy representation and lifetime`; `Idempotence without replay`; `Evidence and limits`.


<a id="file-docs-runtime-receive-drain-md"></a>

## `docs/runtime/receive-drain.md`

**Responsibility.** Explain the executed C02b receiver completion path, bounded custody and resource/protocol outcome separation.

**Contract and ownership.** Owns actual receiver API semantics, failure atomicity, three-resource aggregate profile, changed graceful partial order, sequence/count invariants and conditional progress premises. Native adapter statements remain premises.

**Failure/change obligations.** Do not equate queue-empty, ACK copy, secure close, resource release or acoustic completion. Keep sender/native work and fake evidence scope explicit; preserve historical receipts.

**Verification.** Review against receive_drain.zig, lifecycle.zig and independent runtime_lifecycle schedules; run documentation/reference checks and consult the source-scoped lifecycle-receive receipt.

**Next actionable work.** Extend with source-scoped sender/native evidence only after actual implementations and independent qualification.

**Declared surface / navigation:** `Receiver completion composed with resource ownership`; `Ownership profile and why the fence order changes`; `Actual calls and failure atomicity`; `Mathematics, bounds and progress premises`; `Truthful outcomes and evidence limits`.


<a id="file-docs-runtime-repository-launcher-md"></a>

## `docs/runtime/repository-launcher.md`

**Responsibility.** Explain clone-to-audio preparation, enrollment, private state and recovery.

**Contract and ownership.** Separate implemented automation from OS-owned prompts and unexecuted Mac/hardware qualification; document the trusted-PC key model and network/renewal limitations. Shared automatic launcher configuration selects environment overrides without rewriting saved profiles; final native session validation precedes audio, and help avoids downloads.

**Failure/change obligations.** Reject incomplete, conflicting or untrusted inputs; preserve original errors and saved identities. Do not turn Windows or loopback checks into Mac speaker readiness.

**Verification.** Run repository_launcher.py and desktop_setup.py plus custody and application documentation gates; inspect native Mac CI and hardware evidence separately.

**Next actionable work.** Execute the clean native Mac build and real Windows-to-Mac speaker session; preserve target-specific failures before expanding platform claims.

**Declared surface / navigation:** `Clone, prepare, pair and start`; `Build custody and repeat behavior`; `Pairing trust and failure boundary`; `Discovery and settings`; `Automatic declarative configuration`; `Qualification`; `Monterey distribution and GitHub publication`.


<a id="file-docs-runtime-send-drain-md"></a>

## `docs/runtime/send-drain.md`

**Responsibility.** Sender custody, capture fencing and remote attestation with actual interfaces and evidence limits.

**Contract and ownership.** Owns concrete method semantics, ownership/mutation boundaries, bounded representation, mathematical premises and native/source trust assumptions for this increment.

**Failure/change obligations.** Do not infer acoustic completion, native portability, live network success or full production readiness from pure/null tests. Preserve unresolved native debt and unadopted dependency observations.

**Verification.** Review against current implementation and source-scoped lifecycle-send logs/receipt; run scoped and full documentation checks separately.

**Next actionable work.** Complete actual endpoint/failure/async/native/network adapters with independent platform-specific evidence before advertising support.

**Declared surface / navigation:** `Sender custody, capture fencing and remote attestation`; `Representation and authority`; `Prefix custody and transactional writes`; `EOF and completion order`; `Conservation and bounded work`; `Evidence and remaining implementation`.


<a id="file-docs-runtime-verified-channel-md"></a>

## `docs/runtime/verified-channel.md`

**Responsibility.** Explain live verified identity mapping, record custody, native ownership and scoped evidence.

**Contract and ownership.** Match actual worker-side Connection methods and explicit independent-peer/fixture limits.

**Failure/change obligations.** Do not equate local TLS completion with remote application approval or synchronous verification with native/audio completion.

**Verification.** Source-bound integration evidence, application documentation/coverage checks.

**Next actionable work.** Update the ownership argument when actual audio workers and Apple runtime are integrated.

**Declared surface / navigation:** `Verified TLS records on the native socket owner`; `Identity and ownership`; `Data and control path`; `Qualification and remaining work`.


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

**Declared surface / navigation:** `Runtime verification obligations and independent oracles`; `Harness boundary`; `Required cases before first-sound qualification`; `Resource ledger and failure matrix`; `Trace schema for future runtime runs`; `Gates and evidence freshness`; `Current sender/native subset`.


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


<a id="file-lan-audio-launch-json"></a>

## `lan-audio.launch.json`

**Responsibility.** Provide a discoverable default declarative entry for both desktop launchers.

**Contract and ownership.** Schema 1 with empty supported-target environments preserves adaptive defaults and saved private profiles; contains no keys or device-specific assumptions.

**Failure/change obligations.** Unknown or malformed settings fail before application preparation. A custom state path must remain outside the checkout.

**Verification.** Resolve the shipped document for Windows and Intel Mac with no writes; environment and override integration tests exercise active and inactive layers.

**Next actionable work.** Extend supported target capabilities through explicit adapters without hiding unimplemented platforms behind defaults.

**Declared surface / navigation:** `schema`; `environments`.


<a id="file-readme-md"></a>

## `README.md`

**Responsibility.** Human-first product entry: current support, one setup path, daily start/stop commands and task-oriented links.

**Contract and ownership.** Lead with Windows-to-Mac use and actual platform limits; put pairing/build detail in first-run and engineering detail behind links. Everyday commands use existing JSON profiles. Repository launch now uses checked-in third_party snapshots; external sibling edits do not alter adopted build inputs. Shared automatic launcher configuration selects environment overrides without rewriting saved profiles; final native session validation precedes audio, and help avoids downloads.

**Failure/change obligations.** Do not duplicate conflicting protocol/API meaning or imply unexecuted platform support. Preserve useful history and label superseded claims rather than erasing evidence.

**Verification.** Validate local navigation and file index, compare referenced source behavior and evidence dates/hashes; prose quality requires review beyond automated checks.

**Next actionable work.** Read the declared sections below; update this guide whenever its owned contract changes and link to granular implementation/verification obligations.

**Declared surface / navigation:** `LAN Audio`; `Clone once. Run the same command each time.`; `What to expect`; `Find what you need`.


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


<a id="file-spec-runtime-lifecycle-transactions-py"></a>

## `spec/runtime/lifecycle_transactions.py`

**Responsibility.** Finite immutable-state specification of partial acquisition, native callback/worker borrowing, cancellation and resource release.

**Contract and ownership.** Three aggregate resources, one outstanding acquisition, one active callback/worker, bounded generations. BFS checks independent ledger/pending/token/lifetime predicates; reverse graph checks existential cleanup within a generation.

**Failure/change obligations.** Reject invalid bounds, unknown faults and state-budget exhaustion. Native entry may continue after cancellation until environmental sealing; reachability is not universal liveness or a measured deadline.

**Verification.** check_lifecycle_spec.py explores one/two generations and requires exact six defect witnesses. The initial unmutated draft exposed unsafe release during outstanding worker creation; preserve its source/trace.

**Next actionable work.** Map each concrete C02 event/borrow/effect to this abstraction and add real fake/native tests. Extend model bounds/owners only with explicit new evidence; do not import Python into the runtime.

**Declared surface / navigation:** `actions`; `violation`; `trace_to`; `explore`.


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


<a id="file-src-app-config-zig"></a>

## `src/app/config.zig`

**Responsibility.** Bounded data-only JSON schema 1 decoder and pure defaults/profile resolution.

**Contract and ownership.** At most 64 KiB, depth 8, 32 profiles; reject duplicate/unknown/null/wrong-type fields. Effective slices borrow parsed ownership. Explicit unsupported capture selections fail without I/O.

**Failure/change obligations.** Reject malformed requests before side effects; no silent substitution or rewrite of historical evidence.

**Verification.** Unit config-test and independent configuration.py CLI cases; retain parser allocations until supervisor returns.

**Next actionable work.** Native Mac two-host qualification and explicit capability adapters remain separate release gates.

**Declared surface / navigation:** `parse`; `checkTypes`; `validateLayer`; `resolve`; `validate`; `std`; `maximum_bytes`; `Role`; `Capture`; `Layer`; `Profile`; `Document`; `Effective`; `token`; `tree`; `parsed`; `key`; `selected`; `role`; `input`; `home`; `cases`; `oversized`; `profiles`; `profiles inherit fields deterministically and preserve false assignments`; `ambiguous and unsupported documents fail before resolution`; `resource bounds and selection policy cannot be bypassed by a profile`.


<a id="file-src-app-main-zig"></a>

## `src/app/main.zig`

**Responsibility.** Dispatch help/version/device inspection and supported explicit send/receive commands without implicit audio startup.

**Contract and ownership.** Validate commands before enumeration or streaming. Device snapshots are read-only/copy-owned. Send/receive dispatch only when the target build includes the real runtime; help never opens audio. start/check expose saved home profiles through the same file-command engine; selected setup/config errors include actionable hints.

**Failure/change obligations.** Unknown inspection arguments exit 2, unavailable platform/build exits 3, discovery/stream failures exit 1. JSON device names are escaped; plain display scrubs terminal controls.

**Verification.** Built executable smoke checks and actual repeated Windows discovery; native catalog tests verify cleanup and copied names.

**Next actionable work.** Live workers now consume this boundary. Preserve copied-write settlement and actual join/fence ownership; qualify native Mac and sustained multi-device operation.

**Declared surface / navigation:** `main`; `std`; `builtin`; `audio`; `streaming`; `help`; `args`; `stdout`; `from_file`; `command`; `json_output`; `catalog`; `message`; `View`; `text`.


<a id="file-src-app-stream-command-zig"></a>

## `src/app/stream_command.zig`

**Responsibility.** Parse explicit foreground send/receive options and present final diagnostics.

**Contract and ownership.** Direct arguments and explicit JSON config profiles validate to one Effective operation, resolve config-relative credential paths, then invoke the same supervised foreground engine. validate emits redacted feasibility only and acquires no native/network owners. start/check default to executable-relative lan-audio.json and profile home; explicit run/validate still require both. Native check remains configuration-only and does not acquire credentials, devices or network.

**Failure/change obligations.** Reject unknown/duplicate/missing options; no fixture identity, frozen product clock, implicit insecure fallback or device access for help.

**Verification.** Product CLI physical capture/discard and independent fresh-pair/invalid-argument tests.

**Next actionable work.** Qualify the real Windows-to-Mac journey, then sustained clock/jitter recovery and remaining Apple/platform release gates; preserve explicit evidence limits.

**Declared surface / navigation:** `completed`; `run`; `runFile`; `checkPlatform`; `runEffective`; `std`; `builtin`; `runtime`; `platform`; `policy`; `wire`; `supervisor`; `config`; `Display`; `report`; `text`; `sender`; `names`; `index`; `bit`; `value`; `saved`; `allocator`; `executable`; `absolute`; `bytes`; `parsed`; `directory`; `summary`.


<a id="file-src-audio-callback-bridge-zig"></a>

## `src/audio/callback_bridge.zig`

**Responsibility.** Two directional queues with callback silence, drop and diagnostic policy.

**Contract and ownership.** Fixed SPSC capture/playback queues and data-callback-owned counters/reason bits; native notification producers may only store true to shared direction failure flags. Capture gaps are sticky. Failed playback emits counted silence without consuming queued media; missing output frames have a separate saturating count. Optional guard latches playback_starved on short read; disarm before normal END tail; reset only at quiescence. A false playback_ready gates consumption/starvation while warming the native receiver; release-publish readiness after guard configuration.

**Failure/change obligations.** Read ordinary totals only after native callback teardown. A worker checks overrun after draining and before further publication, then ends/restarts the discontinuous stream. Clearing the flag while callbacks run is invalid.

**Verification.** Core queue/callback tests cover missing output custody, saturation and existing representation/overrun/ordering cases; actual installed native callbacks exercise notification faults.

**Next actionable work.** Real worker fault propagation and measured callback cost on each target; no flag replaces native joins.

**Declared surface / navigation:** `CallbackBridge`; `failCapture`; `addCaptureCount`; `missingInput`; `missingOutput`; `captureInput`; `renderOutput`; `FrameQueue`; `std`; `Self`; `Queue`; `CaptureFault`; `previous`; `frames`; `accepted`; `ready`; `guarded`; `available`.


<a id="file-src-audio-frame-queue-zig"></a>

## `src/audio/frame_queue.zig`

**Responsibility.** Sole-producer/sole-consumer interleaved frame transfer with fixed storage and modular cursors.

**Contract and ownership.** K is power-of-two <=2^30, channels 1..32, target x86_64/aarch64. write copies at most two spans before release publication; read copies before release reuse. Remote cursor loads acquire, own loads monotonic. producerPending belongs only to producer. Slice lengths are complete frames and must not alias storage.

**Failure/change obligations.** Full/empty return a short/zero prefix; no wait/allocation/CAS loop. Misuse of owner count, movement, live reset or direct field access invalidates the memory-order argument. Values are copied raw; finite validation belongs before playback/network publication.

**Verification.** Unit partial/full/empty/suffix and u32-wrap tests, 250,000-frame concurrent FIFO stress and spec/concurrency/SpscPublication; manual acquire/release proof remains distinct from the SC model.

**Next actionable work.** Follow C03 endpoint/format, notification and partial-failure contracts; qualify asynchronous native fences and real C04/C05 socket/identity workers. Current sender and synchronous-native subset evidence is in verification/lifecycle-send.

**Declared surface / navigation:** `FrameQueue`; `producerPending`; `consumerAvailable`; `write`; `read`; `std`; `builtin`; `Self`; `frame_capacity`; `channel_count`; `w`; `r`; `occupied`; `available`.


<a id="file-src-host-audio-device-zig"></a>

## `src/host/audio_device.zig`

**Responsibility.** Optional miniaudio control owner with explicit silent, Windows and Mac profiles.

**Contract and ownership.** Stable serialized native owner; exact-name/format acquisition, immutable initial metadata, sticky atomic native notification faults, expected stop intent, failed-start debt, data-only fences and snapshots. Notification callbacks never control devices or touch plain frame totals. Catalog copies at most 64 endpoint names before context release, marks same-direction ambiguity and never initializes a device. Native bridge uses 32768 stereo frames per direction, fixed through join/fence. Native requests bypass fixed-size callback staging; the bridge handles arbitrary whole frames and fully initializes output, so redundant native pre-clear is disabled. Backend-entry tests verify exact queue consumption for irregular requests and initialized short-read silence. Native conversion and device buffers remain separate.

**Failure/change obligations.** Invalid/unused/missing/duplicate selectors reject; context/device cleanup follows acquired-resource order. Native format mismatch rejects before ready. Failed start/stop and unsupported asynchronous fences retain native debt. No timeout permits free.

**Verification.** Native host-root and null integration artifacts test selection, format, concurrent notifications and actual missing-buffer ABI. Compile-time controlled native calls additionally exercise real-owner cleanup and reconstruction before/after start/stop failures. Discovery tests poison released native metadata, inject bad counts/names/failures, and reopen a real null endpoint by copied name.

**Next actionable work.** Qualify internal native partial-failures, stable endpoint discovery, asynchronous fences and physical targets; integrate real worker/controller fault abort.

**Declared surface / navigation:** `backendFor`; `name`; `list`; `discover`; `discoverWith`; `copy`; `matchesCallback`; `validateEndpoint`; `resolveEndpoint`; `contextInit`; `contextUninit`; `enumerate`; `Device`; `failed`; `init`; `initWithOptions`; `openedFormat`; `health`; `readOpenedFormat`; `leftRight`; `start`; `stop`; `fence`; `finalSnapshot`; `deinit`; `notification`; `callback`; `emit`; `run`; `deviceInit`; `deviceUninit`; `builtin`; `std`; `c`; `core`; `Bridge`; `Profile`; `Endpoint`; `Options`; `EndpointDescription`; `Catalog`; `capacity`; `backend`; `native_name`; `length`; `DeviceFormat`; `OpenedFormat`; `Native`; `AudioDevice`; `total`; `Fake`; `Mode`; `copied`; `expected`; `catalog`; `Self`; `Health`; `FinalSnapshot`; `has_playback`; `has_capture`; `opened`; `kind`; `count`; `Notify`; `input`; `snapshot`; `Publisher`; `Injected`; `result`; `Owner`; `callbacks`; `endpoint resolution rejects missing and duplicate names without default fallback`; `strict native format comparison checks every active direction and dimension`; `backend requests consume exactly their frames and fully initialize output`; `catalog copies native names before context release and marks ambiguity`; `real null discovery returns copied selectors usable after enumeration ends`; `installed native notifications invalidate both directions without consuming media`; `concurrent native notifications retain independent sticky reasons`; `native API failures preserve ownership cleanup and reconstruction`.


<a id="file-src-host-net-native-c"></a>

## `src/host/net/native.c`

**Responsibility.** Private Winsock/POSIX syscall boundary for the application socket owner.

**Contract and ownership.** Nonblocking TCP, per-socket Winsock reference, explicit address/scope, select/poll, SO_ERROR completion, SIGPIPE suppression and one-shot descriptor retirement.

**Failure/change obligations.** Capture OS errors immediately. Every acquired resource must be released or close uncertainty reported; never discard accepted-child cleanup failures. Post-creation inheritance flags are not atomic against process launch.

**Verification.** Compiled with C11 Wall/Wextra/Werror through the pinned Zig build; real network_host tests exercise Windows calls.

**Next actionable work.** Qualify Darwin/Linux SDKs and execution, resource-failure injection and process inheritance before those support claims.

**Declared surface / navigation:** `handle`; `failure`; `bad_address`; `retryable`; `pending_connect`; `runtime_start`; `runtime_stop`; `configure`; `la_net_open`; `address_of`; `la_net_listen`; `la_net_connect`; `la_net_finish_connect`; `la_net_accept`; `la_net_poll`; `la_net_send`; `la_net_recv`; `la_net_shutdown_write`; `la_net_port`; `la_net_close`; `la_net_now`; `la_net_clock_milliseconds`.


<a id="file-src-host-net-native-h"></a>

## `src/host/net/native.h`

**Responsibility.** Private C ABI shared by native.c and translated network_c module.

**Contract and ownership.** Fixed socket metadata and bounded result convention; public Zig owner validates states and slices before calls. Runtime/open/close-error flags track cleanup debt.

**Failure/change obligations.** No direct external mutation, ABI layout guessing or generation safety claim. Preserve translated header/C agreement.

**Verification.** Build translation and native network tests compile the same header on selected targets.

**Next actionable work.** Review ABI and platform widths when adding targets; no standalone external C API commitment.

**Declared surface / navigation:** `la_net_open`; `la_net_listen`; `la_net_connect`; `la_net_finish_connect`; `la_net_accept`; `la_net_poll`; `la_net_send`; `la_net_recv`; `la_net_shutdown_write`; `la_net_port`; `la_net_close`; `la_net_now`; `la_net_clock_milliseconds`.


<a id="file-src-host-net-socket-zig"></a>

## `src/host/net/socket.zig`

**Responsibility.** Serialized native TCP owner and borrowed TLS-signature transport adapters.

**Contract and ownership.** Numeric explicit endpoints, independent accepted ownership, positive prefix/null would-block/zero EOF, half-close, absolute monotonic waits and caller-owned cancellation. One owner; stable address while borrowed.

**Failure/change obligations.** Invalid input preserves applicable state; native I/O failure retains close debt. Native close uncertainty retires storage without retry or reinit. No concurrent descriptor close.

**Verification.** Real Windows IPv4/IPv6 loopback, refusal, deadline/cancel, exact prefixes, half-close, repeated teardown and stalled-peer backpressure; recorded target builds.

**Next actionable work.** Native foreign execution, independent peer and native failure injection, TLS identity/worker composition; see docs/runtime/network-owner.md.

**Declared surface / navigation:** `nowMilliseconds`; `init`; `endpointValid`; `listen`; `connect`; `finishConnect`; `accept`; `fail`; `lastNativeError`; `localPort`; `send`; `receive`; `shutdownWrite`; `wait`; `close`; `transportSend`; `transportReceive`; `std`; `c`; `Family`; `Endpoint`; `Interest`; `Error`; `frequencies`; `ticks`; `wide`; `status`; `Socket`; `Self`; `now`; `result`; `after`; `native clock conversion matches wide integer oracle without partial results`.


<a id="file-src-host-platform-c"></a>

## `src/host/platform.c`

**Responsibility.** Implement Windows waitable timers/control hook and POSIX nanosleep/signal hooks.

**Contract and ownership.** Prefer Windows high-resolution timer with normal fallback; retain process-lifetime callback pointer during deregistration; restore prior POSIX handlers. Optional same-thread MMCSS Audio registration on Windows; single token, duplicate entry rejects unchanged, idempotent successful revert; unavailable on POSIX.

**Failure/change obligations.** Reject invalid waits/duplicate registration; preserve native failures; no Windows handle inheritance or GUI launch.

**Verification.** Repeated timer/handler lifetime test on Windows; POSIX execution remains unqualified.

**Next actionable work.** Qualify the real Windows-to-Mac journey, then sustained clock/jitter recovery and remaining Apple/platform release gates; preserve explicit evidence limits.

**Declared surface / navigation:** `la_audio_task_enter`; `la_audio_task_leave`; `void`; `control`; `la_control_install`; `la_control_restore`; `la_pacer_init`; `la_pacer_wait`; `la_pacer_close`; `la_wall_seconds`.


<a id="file-src-host-platform-h"></a>

## `src/host/platform.h`

**Responsibility.** Declare small C ABI for foreground flags, real wall time and worker pacing.

**Contract and ownership.** One serialized foreground owner; signal hook only publishes static lock-free flags; timer storage is owned until close. Optional same-thread MMCSS Audio registration on Windows; single token, duplicate entry rejects unchanged, idempotent successful revert; unavailable on POSIX.

**Failure/change obligations.** No process-wide timer resolution changes or callback-side waiting; unavailable primitives fail explicitly.

**Verification.** Platform lifetime unit test and live worker callers.

**Next actionable work.** Qualify the real Windows-to-Mac journey, then sustained clock/jitter recovery and remaining Apple/platform release gates; preserve explicit evidence limits.

**Declared surface / navigation:** `la_pacer_init`; `la_pacer_wait`; `la_pacer_close`; `la_audio_task_enter`; `la_audio_task_leave`; `la_wall_seconds`; `la_control_install`; `la_control_restore`.


<a id="file-src-host-platform-zig"></a>

## `src/host/platform.zig`

**Responsibility.** Expose worker timers and process-lifetime atomic stop/abort flags to foreground CLI.

**Contract and ownership.** Control owner serializes install/restore, rejected duplicate registration preserves flags; first active sender Ctrl+C drains and later/urgent stops abort. Optional same-thread MMCSS Audio registration on Windows; single token, duplicate entry rejects unchanged, idempotent successful revert; unavailable on POSIX.

**Failure/change obligations.** Never reset active stop state on a rejected install or borrow thread-local handler storage.

**Verification.** Repeated registration/cleanup tests and timed cancellation through actual worker integration.

**Next actionable work.** Qualify the real Windows-to-Mac journey, then sustained clock/jitter recovery and remaining Apple/platform release gates; preserve explicit evidence limits.

**Declared surface / navigation:** `requested`; `install`; `restore`; `wallSeconds`; `init`; `wait`; `deinit`; `std`; `c`; `now`; `Pacer`; `AudioTask`; `token`; `multimedia priority registration restores and can be reacquired`; `foreground handlers and timer can be released and reacquired`.


<a id="file-src-host-verified-channel-zig"></a>

## `src/host/verified_channel.zig`

**Responsibility.** Serialized real Socket/TLS/verified-identity/v2 host connection used by the independent peer probe.

**Contract and ownership.** Own Driver, borrow connected Socket and flag at stable addresses; explicit credentials/time/name/selected fingerprint; exact ALPN; live Engine digest only; copied send custody and bounded borrowed receive records. beginSend exposes exact copied custody; finishSend completes that same write without reapplying its record. bindCancellation borrows a new live flag only for current uncanceled generation and no active operation; rejection preserves binding.

**Failure/change obligations.** Current policy/protocol/TLS/transport/deadline failure releases TLS and permission; stale generation preserves replacement. Socket/device cleanup belongs to outer owner; no callback I/O or fabricated drain fence.

**Verification.** Both TLS/audio roles and IPv4/IPv6 independent peer campaign; rejection cleanup, cancellation/deadline, EOF, repeat/stale controls, compiled mutations and legacy media regressions.

**Next actionable work.** Live workers now consume this boundary. Preserve copied-write settlement and actual join/fence ownership; qualify native Mac and sustained multi-device operation.

**Declared surface / navigation:** `init`; `deinit`; `current`; `bindCancellation`; `permitted`; `run`; `handshake`; `refresh`; `send`; `beginSend`; `finishSend`; `receive`; `confirmDrained`; `finish`; `revoke`; `std`; `tls`; `net`; `core`; `policy`; `admission`; `wire`; `Config`; `Error`; `Connection`; `channel`; `permit`; `result`; `leaf`; `operation`; `length`; `fed`.


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


<a id="file-src-runtime-capture-sender-zig"></a>

## `src/runtime/capture_sender.zig`

**Responsibility.** Drain actual capture callbacks through SendDrain into authenticated copied TLS records.

**Contract and ownership.** Settle copied write token immediately after beginSend, before finishSend; preserve queue/assembler prefix through native capture fence and final END.

**Failure/change obligations.** Capture health/cancellation abort; downstream failure after copy retains committed frontier and unknown remote observation.

**Verification.** Independent silent-capture conservation plus explicit physical Windows product capture/discard.

**Next actionable work.** Qualify the real Windows-to-Mac journey, then sustained clock/jitter recovery and remaining Apple/platform release gates; preserve explicit evidence limits.

**Declared surface / navigation:** `run`; `core`; `Sender`; `net`; `started`; `got`; `deadline`; `bytes`; `message`.


<a id="file-src-runtime-channel-admission-zig"></a>

## `src/runtime/channel_admission.zig`

**Responsibility.** Shared generation-bound peer authorization composed with the actual v2 gate.

**Contract and ownership.** Identical repeated authorization preserves stream/frontier. Current failure revokes; stale operations preserve replacement. Apply once per logical record, not per I/O retry.

**Failure/change obligations.** Revocation clears permission without claiming native cleanup. Host must supply current policy revision and fresh generation, then propagate revocation to real workers.

**Verification.** Real v2 offer/accept/audio/end/ack tests in both roles, repeat/stale/revocation and unauthorized-record tests.

**Next actionable work.** Real worker/Controller/verified-TLS mapping and Apple callback lifecycle remain open.

**Declared surface / navigation:** `init`; `current`; `authorize`; `admitted`; `apply`; `confirmDrained`; `invalidate`; `revoke`; `snapshot`; `std`; `core`; `security`; `Error`; `Authorization`; `Snapshot`; `Channel`; `candidate`; `permit`.


<a id="file-src-runtime-delivery-timing-zig"></a>

## `src/runtime/delivery_timing.zig`

**Responsibility.** Worker-owned local receive/publication cadence for bounded recovery decisions.

**Contract and ownership.** Worker-owned checked publication totals and local intervals. Before enabling playback, sample origin; after producer queue observation, sample time. Published minus queued yields a monotone consumed frontier without reading callback-owned counters. Nominal 48 kHz lead uses wide arithmetic and is diagnostic, not an acoustic clock. Rejected observations preserve state; read report after join.

**Failure/change obligations.** Clock regression rejects; the final observation can be censored by starvation and is not a complete network outage estimate.

**Verification.** Pure gap/start/consumed-frontier tests, delayed or regressing clocks, extreme arithmetic and rejection atomicity. Native integration compares final custody counts; no callback clock queries.

**Next actionable work.** Native Wi-Fi and independent-clock qualification remain open.

**Declared surface / navigation:** `published`; `beginPlayback`; `observePlayback`; `received`; `starved`; `observedGap`; `std`; `Timing`; `total`; `start`; `consumed`; `before`; `exhausted`; `publication gaps exclude startup and preserve state on clock regression`; `worker queue frontiers expose demand lead without callback counter races`.


<a id="file-src-runtime-lifecycle-zig"></a>

## `src/runtime/lifecycle.zig`

**Responsibility.** Application-private C02a single-owner acquisition, abort and reclamation controller with no I/O or allocation.

**Contract and ownership.** One serialized control owner; three stable aggregate resources and one globally reserved effect/result. Full generation/serial/executor/kind/resource token matching retains late/partial acquisition debt. Abort joins worker before device release; graceful receiver closes publication, fences non-destructively, sends ACK and closes transport before joins/releases. Deadline never frees debt. Sender mode adds offered AUDIO, capture-fenced EOF, END copied custody, validated remote ACK and close outcomes; receive/send roles cannot coexist in one generation. transportFailed preserves prior copied custody when later network output fails without an outstanding token.

**Failure/change obligations.** Rejected tokens/results and counter exhaustion are atomic. Cancel/deadline never erase pending work. Definitive cleanup failure blocks until explicit retry; uncertain work remains pending. Adapter truthfulness and stable handle slots are required.

**Verification.** Run lifecycle-test in Debug/ReleaseSafe against independent fake acquisition/release/callback/worker ledgers; replay pending-parent trace and six isolated implementation guard mutations. Foreign-target lifecycle-check is compile-only.

**Next actionable work.** Live workers now consume this boundary. Preserve copied-write settlement and actual join/fence ownership; qualify native Mac and sustained multi-device operation.

**Declared surface / navigation:** `configureSender`; `requestSendDrain`; `offerAudio`; `observeSourceDrained`; `mediaFault`; `transportFailed`; `requestDrain`; `observeQueueDrained`; `begin`; `requestStop`; `deadline`; `retryCleanup`; `takeEffect`; `complete`; `snapshot`; `stopBecause`; `normalize`; `nextOperation`; `std`; `Resource`; `Executor`; `Kind`; `Phase`; `Cause`; `SendOutcome`; `ReceiveOutcome`; `Token`; `Result`; `Snapshot`; `Controller`; `s`; `r`; `next`; `pending`; `legal`; `empty`; `Operation`.


<a id="file-src-runtime-pending-block-zig"></a>

## `src/runtime/pending_block.zig`

**Responsibility.** Private pure receiver custody: decode/copy one complete v2 AUDIO and retain its unqueued whole-frame suffix.

**Contract and ownership.** One serialized owner; immutable validated format; fixed 2048-f32 storage; nonwrapping source range and 0<=offset<=frames. admit borrows disjoint wire bytes only until return and uses the existing decoder; peek borrows until mutation; advance transfers only an already-copied prefix.

**Failure/change obligations.** Busy, Aborted, invalid kind/profile/range/payload and excessive advance never partially change state. abort returns only locally pending discard once, poisons further operations and performs no queue cleanup or joins. Positive advance is not idempotent.

**Verification.** Seven independent unit cases cover varied capacities/records/finite words, short/zero writes, failure atomicity, u64 frontier, Busy, abort and parser reuse/candidate gate commit. The authenticated v2 fixture is a real composed caller with a synchronous queue sink.

**Next actionable work.** Use this private pending_audio build module in the future playback_receiver; add real cancellation/native callback fences and preserve the documented gate-versus-publication frontier distinction.

**Declared surface / navigation:** `init`; `admit`; `peek`; `advance`; `abort`; `core`; `wire`; `PendingBlock`; `Error`; `Block`; `count`; `discarded`.


<a id="file-src-runtime-playback-receiver-zig"></a>

## `src/runtime/playback_receiver.zig`

**Responsibility.** Publish authorized copied records through ReceiveDrain to actual playback callbacks.

**Contract and ownership.** One pending block, short-write retention, contiguous prefill, short/empty END handling, single absolute drain deadline; fence before ACK and execute close after ACK. Arm starvation before normal playback; disarm on END; streaming queue above maximum aborts to fresh session. takeStart now publishes callback readiness for an already warm device, including short-END release; empty remains gated.

**Failure/change obligations.** Malformed/stalled/canceled streams stop and join; protocol completion does not bypass secure close; ACK is not acoustic completion.

**Verification.** Independent paced null playback, short/empty, cancellation, duplicate/stall and listener cases; preserved first-attempt close-loop failure.

**Next actionable work.** Qualify the real Windows-to-Mac journey, then sustained clock/jitter recovery and remaining Apple/platform release gates; preserve explicit evidence limits.

**Declared surface / navigation:** `run`; `Receiver`; `wire`; `net`; `started`; `message`; `publication_deadline`; `copied`; `queued`; `bytes`.


<a id="file-src-runtime-receive-drain-zig"></a>

## `src/runtime/receive_drain.zig`

**Responsibility.** Private C02b negotiated receiver owner composing PendingBlock, FrameQueue, Negotiation and the actual lifecycle controller.

**Contract and ownership.** Stable borrowed controller/queue; initialized after authorized negotiation and ready resource acquisition. Serialized generation checks, copied AUDIO admission, exact prefix publication, one tail-start authority, END closure, token-bound ACK commit and post-fence abort accounting before storage release. No public core export or native I/O. Requires a stable output-fault atomic; known failure requests media_fault before admission/publication/start/drain/new ACK, while late copied ACK results retain truthful issued custody. Post-copy fault checks preserve the queued/pending partition.

**Failure/change obligations.** Busy preserves pending custody; other protocol rejection requests abort. Wrong token/generation/results preserve control state. ACK copy is not remote confirmation. Accounting requires worker join/native fence and exact unsaturated final counts; unresolved work never permits release.

**Verification.** Execute lifecycle-test in Debug and ReleaseSafe plus independent frame-word/fake-owner tests and isolated dropped-tail, prefill, publication-closure and callback-fence mutations. See verification/lifecycle-receive. Native-events receiver tests cover each output-fault gate, immutable invalid-token rejection, late ACK custody and real CallbackBridge missing-output accounting.

**Next actionable work.** Complete sender graceful custody and real C03/C04 fault, start, final snapshot, native fence and network mappings before production worker adoption.

**Declared surface / navigation:** `ReceiveDrain`; `init`; `live`; `admit`; `publish`; `takeStart`; `pollDrain`; `ackDescriptor`; `ackMessage`; `completeAck`; `accountAbort`; `std`; `core`; `lc`; `Pending`; `wire`; `Self`; `Queue`; `Error`; `AbortAccounting`; `phase`; `block`; `queued`; `issued`; `message`; `state`; `pending`.


<a id="file-src-runtime-recovery-policy-zig"></a>

## `src/runtime/recovery_policy.zig`

**Responsibility.** Pure bounded retry and between-session reserve policy.

**Contract and ownership.** Pure bounded retry policy. Starvation grows reserve by at least 20 ms or measured delivery gap plus one-ms quantization margin plus max(two callback requests, observed nominal playback lead), rounded to 5 ms and capped. Queue overload allows separate 10 ms burst headroom. Checked deadline backoff gives cancellation priority at expiry; identity/cleanup policy unchanged.

**Failure/change obligations.** Only named recoverable failures retry; client identity and cleanup failures stop. Counters saturate.

**Verification.** Two unit tests exercise saturation, security/cleanup stop, healthy reset and budget bounds.

**Next actionable work.** Qualify sustained clock correction and native Intel Mac playback; do not equate recovery with inaudible gaps.

**Declared surface / navigation:** `queueLimit`; `init`; `poll`; `failed`; `failedObserved`; `std`; `Decision`; `Observation`; `maximum_queue_frames`; `limit`; `Backoff`; `Step`; `before`; `Policy`; `retry`; `gap_frames`; `margin`; `measured`; `reserve ceiling leaves bounded room for publication bursts`; `retry waiting uses one deadline and cancellation wins at expiry`; `retry schedule is bounded and identity/cleanup faults cannot enable retry`; `measured reserve skips inadequate retries, rounds up and respects every budget`; `starvation adds bounded reserve without changing the requested budget`.


<a id="file-src-runtime-send-drain-zig"></a>

## `src/runtime/send_drain.zig`

**Responsibility.** Private C02c sender media owner composing capture queue, assembler, encoder, negotiation and actual lifecycle controller.

**Contract and ownership.** Stable borrowed queue/controller/sticky-fault addresses; one bounded scratch and record. No EOF before native fence plus empty capture/assembler. Record preparation retains exact token; copied acceptance commits once, rejected writes retain block, unknown writes abort with explicit uncertain frame partition.

**Failure/change obligations.** Invalid samples retain scratch; faults forbid successful END. Stale/illegal results preserve pending debt. Final accounting occurs after worker/device fences and before aggregate storage release; no replay on uncertain transfer.

**Verification.** 32 real-controller tests cover both roles and a seven-frame record exchange. Sender mutants reject commit-on-rejection, ignored faults, lost uncertain frames and unvalidated ACK. Actual socket workers remain unimplemented.

**Next actionable work.** Integrate selected endpoint/native failure and qualified socket/identity adapters with actual workers; measure bounded recovery on real hosts.

**Declared surface / navigation:** `SendDrain`; `init`; `live`; `healthy`; `requestStop`; `pump`; `issued`; `prepareRecord`; `completeRecord`; `completeAck`; `accountAbort`; `std`; `core`; `lc`; `wire`; `Self`; `Queue`; `Accounting`; `assembler`; `generation`; `state`; `space`; `accepted`; `pending`; `encoded`; `block`; `copied`; `retained`.


<a id="file-src-runtime-session-supervisor-zig"></a>

## `src/runtime/session_supervisor.zig`

**Responsibility.** Supervise fresh fully quiescent streaming attempts.

**Contract and ownership.** Persistent listener; fresh random stream identity and authenticated session every attempt; report before retry; cancelable 10 ms waits.

**Failure/change obligations.** Unresolved cleanup exceptions escape; internal cancellation never becomes persistent user stop; clean END returns.

**Verification.** Independent recovery peers in both roles and ciphertext proxy between actual supervisors.

**Next actionable work.** Qualify sustained clock correction and native Intel Mac playback; do not equate recovery with inaudible gaps.

**Declared surface / navigation:** `run`; `std`; `stream`; `platform`; `net`; `Policy`; `Backoff`; `Config`; `Event`; `Observer`; `Summary`; `report`; `failure`; `decision`.


<a id="file-src-runtime-stream-zig"></a>

## `src/runtime/stream.zig`

**Responsibility.** Own stable native audio/network aggregate and transfer serialized controller ownership to one real media thread.

**Contract and ownership.** Main owns setup; atomic start publication hands ledger to worker; atomic finish returns ownership; actual join/fence/socket release precede allocator destruction. Setup uses external abort; media uses fresh internal abort after idle connection rebind; optional borrowed listener and starvation/backlog guards. Authenticated device initialization precedes OFFER/ACCEPT, preventing media during receiver setup. Receiver native start completes before ACCEPT while callback consumption is gated; sender capture starts after negotiation. OFFER/ACCEPT executes on the actual media worker after ownership transfer; no acceptance before thread readiness. Windows loopback adds a fixed silent playback device in the native aggregate; rollback/fence/release covers both, and either health fault cancels. Worker scopes MMCSS Audio registration through exit, reports availability, and treats failed restore as terminal; no global priority edits.

**Failure/change obligations.** Never free unresolved native storage, close a concurrently borrowed socket or settle an acquisition without rollback; failure is reported distinctly from clean END/ACK.

**Verification.** Independent live worker peer across roles, listener/client, cancellation, EOF, protocol error and stall; real Windows capture caller.

**Next actionable work.** Qualify the real Windows-to-Mac journey, then sustained clock/jitter recovery and remaining Apple/platform release gates; preserve explicit evidence limits.

**Declared surface / navigation:** `deadline`; `audioFailed`; `deinitDevices`; `healthy`; `fence`; `runMedia`; `work`; `setup`; `cleanup`; `run`; `std`; `audio`; `platform`; `net`; `host`; `policy`; `lc`; `wire`; `capture`; `playback`; `Timing`; `recovery_policy`; `Controls`; `Options`; `Report`; `State`; `options`; `offer`; `format`; `queued`; `connect_deadline`; `listener`; `rules`; `device_token`; `worker_token`; `generation`; `allocation`; `state`; `snapshot`.


<a id="file-src-security-peer-policy-zig"></a>

## `src/security/peer_policy.zig`

**Responsibility.** Bounded copied product allowlist after mutual TLS verification.

**Contract and ownership.** At most 32 peers; explicit complementary roles, selected leaf-DER SHA256, exact v2 ALPN and local generation. No keys, clocks or persistence.

**Failure/change obligations.** Reject duplicate rules, empty roles, oversized policy, malformed hex, stale or unauthenticated evidence, wrong peer/protocol/role. Empty policy denies all.

**Verification.** Independent authorization truth table, rule-copy/bounds and fingerprint-format cases in peer_policy integration tests.

**Next actionable work.** Live mapping now in verified_channel; restrictive identity store and real native workers remain open.

**Declared surface / navigation:** `parseFingerprint`; `formatFingerprint`; `allows`; `init`; `authorize`; `std`; `core`; `Fingerprint`; `Role`; `max_peers`; `Error`; `offset`; `high`; `low`; `hex`; `Roles`; `Rule`; `Evidence`; `Permit`; `Policy`.


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


<a id="file-start"></a>

## `start`

**Responsibility.** Provide the single Mac source-launch command.

**Contract and ownership.** Detect Intel macOS and Apple tools, request the OS installer if missing, then use Apple Python 3.9+ without a package manager. Shared automatic launcher configuration selects environment overrides without rewriting saved profiles; final native session validation precedes audio, and help avoids downloads.

**Failure/change obligations.** Reject incomplete, conflicting or untrusted inputs; preserve original errors and saved identities. Do not turn Windows or loopback checks into Mac speaker readiness.

**Verification.** Run repository_launcher.py and desktop_setup.py plus custody and application documentation gates; inspect native Mac CI and hardware evidence separately.

**Next actionable work.** Execute the clean native Mac build and real Windows-to-Mac speaker session; preserve target-specific failures before expanding platform claims.


<a id="file-start-cmd"></a>

## `start.cmd`

**Responsibility.** Provide the memorable Windows source-launch command.

**Contract and ownership.** Forward arguments to the checkout-local PowerShell entry with process-only policy bypass and propagate its exit code.

**Failure/change obligations.** Reject incomplete, conflicting or untrusted inputs; preserve original errors and saved identities. Do not turn Windows or loopback checks into Mac speaker readiness.

**Verification.** Run repository_launcher.py and desktop_setup.py plus custody and application documentation gates; inspect native Mac CI and hardware evidence separately.

**Next actionable work.** Execute the clean native Mac build and real Windows-to-Mac speaker session; preserve target-specific failures before expanding platform claims.


<a id="file-start-ps1"></a>

## `start.ps1`

**Responsibility.** Prepare the checked-in launcher using private pinned Windows Python.

**Contract and ownership.** Serialize extraction, hash official archive before use, keep runtime under ignored clone cache, and propagate Python status without global configuration changes. Shared automatic launcher configuration selects environment overrides without rewriting saved profiles; final native session validation precedes audio, and help avoids downloads.

**Failure/change obligations.** Reject incomplete, conflicting or untrusted inputs; preserve original errors and saved identities. Do not turn Windows or loopback checks into Mac speaker readiness.

**Verification.** Run repository_launcher.py and desktop_setup.py plus custody and application documentation gates; inspect native Mac CI and hardware evidence separately.

**Next actionable work.** Execute the clean native Mac build and real Windows-to-Mac speaker session; preserve target-specific failures before expanding platform claims.


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


<a id="file-tests-hardware-windows-live-capture-py"></a>

## `tests/hardware/windows_live_capture.py`

**Responsibility.** Explicitly qualify physical Windows capture through the actual product CLI to a discard-only independent TLS peer.

**Contract and ownership.** Explicit --run Windows loopback capture through installed CLI and independent mTLS peer. --from-config uses generated config-relative identities. Optional --test-tone loops a quiet generated 1 kHz WAV, stops it in finally, and requires aggregate received-signal detection. Captured PCM is never persisted. Default capture plays nothing. --self-test checks the streaming meter without device/network acquisition.

**Failure/change obligations.** Default capture plays nothing. Stop the optional generated stimulus in finally; never persist captured PCM. Retain only aggregate metrics and lifecycle diagnostics, and fail signal qualification if the requested tone is not detected.

**Verification.** Analytic 1 kHz amplitude/phase with irregular chunk sizes, rejected silence/500 Hz/1500 Hz/nonfinite inputs; explicit idle and tone runs require zero drops, frame conservation, authentication and quiescent cleanup. Signal detection does not establish acoustic fidelity or Mac playback.

**Next actionable work.** Qualify the real Windows-to-Mac journey, then sustained clock/jitter recovery and remaining Apple/platform release gates; preserve explicit evidence limits.

**Declared surface / navigation:** `stimulus`; `meter_self_test`; `exercise`.


<a id="file-tests-integration-audio-device-zig"></a>

## `tests/integration/audio_device.zig`

**Responsibility.** Actual null-backend callbacks and repeated safe reconstruction.

**Contract and ownership.** Exercises actual silent/null initialization, callbacks, selected playback/duplex endpoint names, strict matching formats, malformed/missing selector rejection and reconstruction, borrowed-name release, stable fence snapshots, restart invalidation and installed null-input callback ABI. Also verifies expected native stops remain healthy and missing output fails without consuming queued frames; the missing-input test supplies valid output to isolate its cause.

**Failure/change obligations.** Assertions must fail on unexpected behavior; no arbitrary crash counts as expected rejection. Threads/devices/sockets must be reclaimed on every test exit.

**Verification.** audio-test runs this integration artifact plus separate host-root selection/format contract tests in Debug and ReleaseSafe.

**Next actionable work.** Inject native start/stop and format failure paths without substituting the production owner; qualify physical endpoints and other OSs separately.

**Declared surface / navigation:** `std`; `audio`; `formats`; `playback_name`; `capture_name`; `callbacks`; `before`; `observed`; `snapshot`; `selected silent endpoint survives name borrow and rejected opens are reusable`; `selected silent duplex validates both native directions`; `null duplex callbacks transfer frames and permit quiescent reconstruction`; `silent native fence preserves device storage and grants a stable final snapshot`; `native null device callback publishes missing input through the installed callback`; `native null output reports unavailable frames without consuming queued audio`.


<a id="file-tests-integration-configuration-py"></a>

## `tests/integration/configuration.py`

**Responsibility.** Independent installed CLI config acceptance without physical audio.

**Contract and ownership.** Uses temporary files, absent credentials and an occupied loopback listener. Validation must not acquire audio/network or expose credential paths/hashes.

**Failure/change obligations.** Reject malformed requests before side effects; no silent substitution or rewrite of historical evidence.

**Verification.** Run after app build; nonzero assertions retain failures. No fixture keys, device opens or sample recording.

**Next actionable work.** Native Mac two-host qualification and explicit capability adapters remain separate release gates.

**Declared surface / navigation:** `exercise`.


<a id="file-tests-integration-desktop-setup-py"></a>

## `tests/integration/desktop_setup.py`

**Responsibility.** Exercise actual desktop provisioning and relocated application startup without physical audio.

**Contract and ownership.** Fresh temporary identities plus real installed executable and runtime DLLs. Independent hashes preserve operation edits and identity custody; controlled failure/race schedules verify publication. Occupied loopback listener rejects start before audio.

**Failure/change obligations.** Failures remain failures; all temporary private material removed. Windows results do not imply native Mac or clean-machine deployment.

**Verification.** Run against Debug and ReleaseSafe app builds. Preserve exact test output, inputs and source hashes in a fresh qualification phase.

**Next actionable work.** Add native Mac host execution and clean-machine setup before claiming production installation support.

**Declared surface / navigation:** `hashes`; `DesktopSetup`.


<a id="file-tests-integration-live-worker-zig"></a>

## `tests/integration/live_worker.zig`

**Responsibility.** Provide explicit null-audio consumer of the real foreground runtime.

**Contract and ownership.** Public test identities/frozen time are isolated here; actual worker/device/socket lifecycle and optional timed cancellation; report final ledger/counters.

**Failure/change obligations.** No physical audio; borrowed cancellation timer is joined; nonzero exit on failed runtime.

**Verification.** Independent Python TLS/v2 peer controls data and checks frame counts/cleanup.

**Next actionable work.** Qualify the real Windows-to-Mac journey, then sustained clock/jitter recovery and remaining Apple/platform release gates; preserve explicit evidence limits.

**Declared surface / navigation:** `main`; `run`; `std`; `runtime`; `policy`; `args`; `sender`; `listener`; `cancel`; `Canceler`; `canceler`; `report`; `text`.


<a id="file-tests-integration-live-worker-peer-py"></a>

## `tests/integration/live_worker_peer.py`

**Responsibility.** Independently qualify actual threads/queues and TLS on loopback.

**Contract and ownership.** Use Python TLS and independent v2 codec; paced frames, real null callbacks, bounded process/socket/watchdog; new report files only. Absolute source-frame pacing sleeps only for positive remaining time; overdue records never call sleep(0), which yields a Windows time slice. Completion and reserve assertions remain unchanged.

**Failure/change obligations.** Timeout/crash/false cleanup is failure; distinguish aggregate tail silence from measured network glitches.

**Verification.** Twelve scenarios in Debug and ReleaseSafe including both audio roles as TLS listener/client.

**Next actionable work.** Qualify the real Windows-to-Mac journey, then sustained clock/jitter recovery and remaining Apple/platform release gates; preserve explicit evidence limits.

**Declared surface / navigation:** `run_case`; `main`.


<a id="file-tests-integration-loopback-transport-zig"></a>

## `tests/integration/loopback_transport.zig`

**Responsibility.** Shared test-only Windows short-transfer network owner for the two v2 application-role probes.

**Contract and ownership.** Wrap reviewed demo C socket; one owner, explicit open/close, would-block null, bounded polling against unchanged Driver deadline. No configurable remote address or production identity policy.

**Failure/change obligations.** Close exactly once after users/Driver finish. Transport EOF, failure and would-block remain distinct; no ambient fallback endpoints or deadline renewal.

**Verification.** Both v2 probe roles execute against independent Python peers, including stalled/abrupt/fragmented cases and mandatory thread/process termination.

**Next actionable work.** Production WP03 networking must replace loopback fixture policy with real endpoint/readiness/cancellation contracts; this helper is not a production transport.

**Declared surface / navigation:** `demo_now`; `demo_name`; `demo_open`; `demo_close`; `demo_send`; `demo_recv`; `demo_poll`; `open`; `close`; `send`; `recv`; `run`; `tls`; `Network`; `socket`; `n`; `result`; `now`.


<a id="file-tests-integration-network-host-zig"></a>

## `tests/integration/network_host.zig`

**Responsibility.** Real loopback TCP behavioral qualification without TLS, audio or persistent listener.

**Contract and ownership.** Ephemeral explicit IPv4/IPv6 endpoints; independent byte comparisons, absolute deadlines, atomic-only cancellation, owner cleanup and bounded backpressure fixture.

**Failure/change obligations.** Unexpected error, missing would-block below 64 MiB, lost prefix or false successful connect fails. All owners close on test exit; no fixture endpoint enters product policy.

**Verification.** Run zig build network-test in Debug and ReleaseSafe; source hashes and target build results in verification/native-failures.

**Next actionable work.** Add independent peer and OS failure cases; actual foreign execution, TLS and Wi-Fi acceptance remain separate.

**Declared surface / navigation:** `close`; `openPair`; `sendAll`; `run`; `std`; `net`; `expect`; `eq`; `Pair`; `deadline`; `n`; `Cancel`; `thread`; `start`; `port`; `immediate`; `offset`; `IPv4 and IPv6 preserve byte prefixes and independent half close after listener release`; `cancellation and absolute deadline leave the descriptor with its original owner`; `refused connect never becomes connected merely because the socket is writable`; `invalid endpoints and destination owners reject before replacing native ownership`; `repeated connection teardown releases independent runtime ownership`; `a stalled peer applies backpressure without losing accepted byte prefixes`.


<a id="file-tests-integration-pairing-py"></a>

## `tests/integration/pairing.py`

**Responsibility.** Validate fresh provisioning with an independent Python mutual-TLS exchange.

**Contract and ownership.** Temporary private keys are removed; use paths with spaces, verify both leaf digests and current-time trust, preserve repeated output and reject tampering.

**Failure/change obligations.** No fixture certificate substitutes for freshly generated credentials; never write private keys into reports.

**Verification.** Direct execution plus malformed product CLI options before network/device acquisition.

**Next actionable work.** Qualify the real Windows-to-Mac journey, then sustained clock/jitter recovery and remaining Apple/platform release gates; preserve explicit evidence limits.

**Declared surface / navigation:** `exercise`.


<a id="file-tests-integration-peer-policy-zig"></a>

## `tests/integration/peer_policy.zig`

**Responsibility.** Independent policy conjunction and actual v2 admission behavior.

**Contract and ownership.** Synthetic host evidence only; 128 condition combinations and actual record transitions with copied identity/role rules.

**Failure/change obligations.** Expected rejection needs an explicit oracle. No certificate, native Apple or physical audio claim follows.

**Verification.** policy-test in Debug/ReleaseSafe; policy-check records cross-target compilation separately.

**Next actionable work.** Preserve pure truth-table coverage alongside real verified-channel tests; persisted approvals remain open.

**Declared surface / navigation:** `evidence`; `policy`; `std`; `core`; `security`; `admission`; `eq`; `expect`; `lower`; `valid`; `copied`; `permit`; `empty`; `same_generation`; `allowed`; `initial`; `trusted`; `proof`; `before`; `changed`; `offer`; `revoked`; `fingerprints preserve all byte values and reject ambiguous presentation`; `bounded policy owns its rules and refuses duplicates and invalid roles`; `independent 128-case authorization table requires every binding condition`; `repeated authorization preserves an actual negotiated frame frontier`; `changed current identity or policy revokes without reauthorizing or resetting`; `stale platform events cannot change a replacement and repeated revocation converges`; `unauthorized records and invalid stream order terminate admission`.


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


<a id="file-tests-integration-recovery-peer-py"></a>

## `tests/integration/recovery_peer.py`

**Responsibility.** Independent TLS/v2 recovery and cancellation oracle.

**Contract and ownership.** Bounded loopback children; named failure, exact frame/stream checks and final released owners; jitter explicitly uses 60 ms reserve and records actual gaps. Absolute source-frame pacing sleeps only for positive remaining time; overdue records never call sleep(0), which yields a Windows time slice. Completion and reserve assertions remain unchanged. Reports send lateness against the source-frame schedule.

**Failure/change obligations.** Timeout, reset, crash or unmatched cleanup fails; new evidence file required.

**Verification.** Debug and ReleaseSafe recovery campaigns; retain early scheduling/peer failures separately.

**Next actionable work.** Qualify sustained clock correction and native Intel Mac playback; do not equate recovery with inaudible gaps.

**Declared surface / navigation:** `run_case`; `main`.


<a id="file-tests-integration-recovery-proxy-py"></a>

## `tests/integration/recovery_proxy.py`

**Responsibility.** Inject a forwarding stall between actual product supervisors.

**Contract and ownership.** Ciphertext-only bounded TCP buffers; first connection paused 150 ms; subsequent connection forwards; both roles must close and recover. Trigger after 64000 media-direction ciphertext bytes, not connection age.

**Failure/change obligations.** No keys, PCM or NIC changes; watchdog and child/thread cleanup; no gapless claim.

**Verification.** Debug and ReleaseSafe actual sender/receiver proxy runs.

**Next actionable work.** Qualify sustained clock correction and native Intel Mac playback; do not equate recovery with inaudible gaps.

**Declared surface / navigation:** `exercise`.


<a id="file-tests-integration-recovery-session-zig"></a>

## `tests/integration/recovery_session.zig`

**Responsibility.** Explicit fixture/null caller of the product supervisor.

**Contract and ownership.** Public fixture clock/keys, max three attempts, optional joined canceler and complete per-attempt diagnostics. Backoff cancellation timer starts at first completed failure rather than process launch.

**Failure/change obligations.** Never selects a physical device or product identity; final unexpected failure exits nonzero.

**Verification.** Ten independent peer scenarios plus two-ended proxy.

**Next actionable work.** Qualify sustained clock correction and native Intel Mac playback; do not equate recovery with inaudible gaps.

**Declared surface / navigation:** `completed`; `run`; `main`; `std`; `stream`; `supervisor`; `policy`; `platform`; `net`; `Log`; `r`; `text`; `Later`; `deadline`; `args`; `sender`; `listening`; `Cancel`; `canceler`; `summary`.


<a id="file-tests-integration-repository-launcher-py"></a>

## `tests/integration/repository_launcher.py`

**Responsibility.** Exercise independent bootstrap and enrollment failure boundaries without audio.

**Contract and ownership.** Real loopback TLS and fresh private test identities; wrong pin/token rejection, exact transfer bytes, repeat preservation, bounded framing, malicious archives, OS locks and keyed discovery. Shared automatic launcher configuration selects environment overrides without rewriting saved profiles; final native session validation precedes audio, and help avoids downloads.

**Failure/change obligations.** Reject incomplete, conflicting or untrusted inputs; preserve original errors and saved identities. Do not turn Windows or loopback checks into Mac speaker readiness.

**Verification.** Run repository_launcher.py and desktop_setup.py plus custody and application documentation gates; inspect native Mac CI and hardware evidence separately.

**Next actionable work.** Execute the clean native Mac build and real Windows-to-Mac speaker session; preserve target-specific failures before expanding platform claims.

**Declared surface / navigation:** `BootstrapTests`; `PairingTests`.


<a id="file-tests-integration-runtime-lifecycle-zig"></a>

## `tests/integration/runtime_lifecycle.zig`

**Responsibility.** Deterministic fake-executor caller of the actual C02a production controller, with independent host ownership and borrow facts.

**Contract and ownership.** Validates effect authority before completion; counts real fake acquisitions/releases separately from controller bits; pauses callback return; exercises all acquisition prefixes, late results, partial ownership, five cleanup failures/retries, token fields and counter bounds. Receiver cases bind explicit output-fault flags, exercise every pre-completion gate and late copied ACK, and connect actual CallbackBridge failure to exact abort accounting.

**Failure/change obligations.** Never complete a native fence while the fake callback is active; test that timeout preserves pending debt. No OS handles, audio output, media success ACK or hardware qualification is implied.

**Verification.** 32 real-controller cases plus 14 executed deliberate mutations, independent resource borrows and source words, and actual sender/receiver record exchange. Debug/ReleaseSafe evidence is source-scoped; foreign builds compile only.

**Next actionable work.** Live workers now consume this boundary. Preserve copied-write settlement and actual join/fence ownership; qualify native Mac and sustained multi-device operation.

**Declared surface / navigation:** `readyGate`; `receiverGate`; `sourceWord`; `media`; `end`; `readMedia`; `finishAck`; `begin`; `dispatch`; `noSecondDispatch`; `finish`; `acquire`; `clean`; `success`; `senderGate`; `capture`; `checkRecord`; `recordResult`; `sourceFence`; `finishSender`; `std`; `lc`; `expect`; `eq`; `core`; `wire`; `Drain`; `Send`; `g`; `pending_before`; `queued_before`; `before`; `ack`; `accounting`; `got`; `token`; `message`; `Host`; `generation`; `r`; `stopped_intent`; `worker`; `fence`; `settled`; `failed`; `owners`; `retry`; `old`; `old_token`; `fresh`; `empty`; `debt`; `after`; `legal`; `intent`; `outcome`; `rejected`; `bytes`; `length`; `n`; `a`; `words`; `expected`; `audio`; `sg`; `rg`; `end_token`; `end_record`; `read_ack`; `write_ack`; `boundary`; `receiver output failure blocks admission publication start and drain`; `receiver rejects an already failed output without acquiring or mutating owners`; `receiver output fault blocks new ACK but reconciles an issued late copy`; `receiver actual callback failure retains queued and pending frame accounting`; `cancel before each dispatch reclaims exactly the acquired prefix`; `cancel during every acquisition retains parents for late success failure and partial debt`; `each rolled back failure and partial acquisition independently initiates cleanup`; `pending worker acquisition reserves device and storage across cancel and deadline`; `callback may enter after stop and fence cannot return while callback is paused`; `every token field and contradictory result is rejected atomically`; `each cleanup failure preserves ownership and requires explicit retry with new identity`; `old generation stop deadline and completion cannot affect restarted owner`; `namespace exhaustion never wraps and does not forget an acquired owner`; `wrong executor observes no dispatch and deadline cannot change terminal outcome`; `result matrix rejects every inappropriate tag without settling an issued effect`; `receiver zero END fences without starting and separates ACK close and cleanup`; `receiver short tail and maximum block preserve identities with zero writes and paused return`; `receiver ACK failure preserves local drain without claiming remote or secure completion`; `receiver abort full queue counts retained frames only after quiescence and before free`; `receiver deadline during issued ACK retains worker and reconciles late copied custody`; `receiver wire rejection preserves prior custody and never authorizes ACK`; `receiver late fence after deadline never enables ACK and keeps return debt`; `receiver ACK and close reject foreign tokens and every illegal result atomically`; `receiver definitive fence failure escalates to abort and retry cannot restore graceful`; `sender zero and partial EOF require actual source fence before END`; `sender rejection preserves bytes and commits once despite short transport progress`; `post-copy network failure preserves committed custody without outstanding token`; `sender stop during write retains result debt and late copied custody`; `sender uncertain write preserves exact local and uncertain frame partition`; `sender sticky source fault prevents END before read before submission or at copied completion`; `sender nonfinite capture retains scratch and aborts without a record`; `sender wrong ACK fails without claiming remote confirmation`; `sender temporary empty capture is not EOF and a later callback is preserved`; `sender and receiver exchange real records with independent seven-frame custody`; `sender record result rejection is atomic and counter exhaustion does not wrap`; `sender valid ACK remains distinct from failed secure close and late ACK after deadline`; `sender consumes the real callback sticky fault publication`.


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


<a id="file-tests-integration-verified-channel-zig"></a>

## `tests/integration/verified_channel.zig`

**Responsibility.** Executable test-only caller of the real verified host connection with finite word verification.

**Contract and ownership.** Public credentials and frozen wall time only here; explicit loopback endpoints, both TLS/audio roles; synchronous verifier only; no physical device or native callback claim.

**Failure/change obligations.** Named rejection includes permission/TLS release before explicit cleanup; actual socket cleanup occurs on exit paths. Preserve fixture-only boundaries.

**Verification.** Independent Python peer plus Debug/ReleaseSafe and compiled mutation qualification.

**Next actionable work.** Keep adversarial probes aligned with implemented host contracts; product command must never inherit fixture defaults.

**Declared surface / navigation:** `is`; `exercise`; `run`; `main`; `std`; `host`; `net`; `policy`; `core`; `wire`; `sizes`; `words`; `admitted`; `sender`; `snapshot`; `first`; `Cancel`; `canceler`; `position`; `message`; `word`; `args`; `server`; `mode`; `port`; `expected`; `ipv6`; `deadline`; `allowed_sender`; `rules`.


<a id="file-tests-integration-verified-channel-peer-py"></a>

## `tests/integration/verified_channel_peer.py`

**Responsibility.** Independent TLS/certificate-digest/v2 oracle for the native verified channel.

**Contract and ownership.** Loopback only; explicit TLS1.3 client/server certificates; independent exact bytes and DER SHA256; bounded child/socket/thread lifetimes; new evidence reports only under verification.

**Failure/change obligations.** Success requires verified peer, full exact frames and clean close; negative requires named error and both released TLS and permission. Preserve crashes/timeouts as failures and never overwrite earlier results.

**Verification.** 43-case fresh campaign, mutation/buffered-record regression witnesses and custody before/after.

**Next actionable work.** Qualify actual multi-device audio separately; do not turn test identities into application credentials.

**Declared surface / navigation:** `fingerprint`; `run_case`; `cases`; `main`.


<a id="file-tests-unit-callback-zig"></a>

## `tests/unit/callback.zig`

**Responsibility.** SPSC and bridge contracts including actual concurrent owners.

**Contract and ownership.** Check full/empty/partial transfers, untouched read suffix, signed stereo ordering, wrap and joined thread results.

**Failure/change obligations.** Assertions must fail on unexpected behavior; no arbitrary crash counts as expected rejection. Threads/devices/sockets must be reclaimed on every test exit.

**Verification.** Run its owning build step in Debug and ReleaseSafe where native execution is supported; preserve exact commands and failures. Extracted test names below enumerate current cases.

**Next actionable work.** Follow C03 endpoint/format, notification and partial-failure contracts; qualify asynchronous native fences and real C04/C05 socket/identity workers. Current sender and synchronous-native subset evidence is in verification/lifecycle-send.

**Declared surface / navigation:** `produce`; `consume`; `std`; `Bridge`; `core`; `Stress`; `total`; `wrote`; `n`; `producer`; `consumer`; `words`; `missing output and sticky playback failure preserve media custody`; `SPSC partial operations preserve stereo and output suffix`; `SPSC u32 rollover preserves distance and slots`; `callback gaps silence full tail and capture drops newest complete frames`; `SPSC simultaneous owners transfer 250000 exact ordered stereo frames`; `callback publishes missing input and nonfinite faults without false contiguous capture`; `callback counter overflow is visibly inexact and finite words are unmodified`; `warmup holds prefill unchanged until playback publication`; `recovery guard detects real starvation without treating an END tail as lost media`.


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


<a id="file-third-party-lock-json"></a>

## `third_party/lock.json`

**Responsibility.** Bind the entire copied build-source dependency closure.

**Contract and ownership.** All 1030 files come from the preserved source-package receipt; existing 188 TLS pins remain unchanged; this is integrity custody, not publisher authentication.

**Failure/change obligations.** Reject incomplete, conflicting or untrusted inputs; preserve original errors and saved identities. Do not turn Windows or loopback checks into Mac speaker readiness.

**Verification.** Run repository_launcher.py and desktop_setup.py plus custody and application documentation gates; inspect native Mac CI and hardware evidence separately.

**Next actionable work.** Execute the clean native Mac build and real Windows-to-Mac speaker session; preserve target-specific failures before expanding platform claims.

**Declared surface / navigation:** `schema`; `source_receipt_sha256`; `files`.


<a id="file-third-party-readme-md"></a>

## `third_party/README.md`

**Responsibility.** Explain ownership, provenance and trust of copied dependencies.

**Contract and ownership.** Immutable snapshots retain upstream/library ownership and public fixture status; library changes require explicit reviewed adoption.

**Failure/change obligations.** Reject incomplete, conflicting or untrusted inputs; preserve original errors and saved identities. Do not turn Windows or loopback checks into Mac speaker readiness.

**Verification.** Run repository_launcher.py and desktop_setup.py plus custody and application documentation gates; inspect native Mac CI and hardware evidence separately.

**Next actionable work.** Execute the clean native Mac build and real Windows-to-Mac speaker session; preserve target-specific failures before expanding platform claims.

**Declared surface / navigation:** `Reviewed dependencies`.


<a id="file-tools-bootstrap-py"></a>

## `tools/bootstrap.py`

**Responsibility.** Prepare pinned toolchains and verified source builds, then start saved desktop state.

**Contract and ownership.** Validate copied dependency custody; bounded hashed HTTPS downloads; reject unsafe archive members; source-keyed builds; OS locks; state outside the checkout; delegate pairing and native audio. Shared automatic launcher configuration selects environment overrides without rewriting saved profiles; final native session validation precedes audio, and help avoids downloads.

**Failure/change obligations.** Reject incomplete, conflicting or untrusted inputs; preserve original errors and saved identities. Do not turn Windows or loopback checks into Mac speaker readiness.

**Verification.** Run repository_launcher.py and desktop_setup.py plus custody and application documentation gates; inspect native Mac CI and hardware evidence separately.

**Next actionable work.** Execute the clean native Mac build and real Windows-to-Mac speaker session; preserve target-specific failures before expanding platform claims.

**Declared surface / navigation:** `digest`; `exclusive`; `atomic_json`; `verify_dependencies`; `download`; `extract`; `run`; `compiler`; `source_key`; `prepare`; `default_state`; `main`.


<a id="file-tools-bootstrap-assets-json"></a>

## `tools/bootstrap_assets.json`

**Responsibility.** Own exact download digests, ceilings, locations and compiler version.

**Contract and ownership.** Zig signatures and filenames verified against ZSF key during adoption; pinned digests bind all downloaded archives without silent version changes.

**Failure/change obligations.** Reject incomplete, conflicting or untrusted inputs; preserve original errors and saved identities. Do not turn Windows or loopback checks into Mac speaker readiness.

**Verification.** Run repository_launcher.py and desktop_setup.py plus custody and application documentation gates; inspect native Mac CI and hardware evidence separately.

**Next actionable work.** Execute the clean native Mac build and real Windows-to-Mac speaker session; preserve target-specific failures before expanding platform claims.

**Declared surface / navigation:** `schema`; `zig_version`; `zig-windows-x86_64`; `zig-macos-x86_64`; `openssl`; `python-windows-x86_64`; `provenance`.


<a id="file-tools-build-mac-candidate-py"></a>

## `tools/build_mac_candidate.py`

**Responsibility.** Build a native Intel Monterey candidate with a separately measured static OpenSSL SDK.

**Contract and ownership.** Require Intel Mac, exact Zig and verified source archive; fresh build directory, explicit 12.0 deployment, test SDK, exact static archives, retain command/source/SDK/binary receipts. Repository launch now uses checked-in third_party snapshots; external sibling edits do not alter adopted build inputs.

**Failure/change obligations.** No sibling/Windows-pin edits, ambient library choice or implied Mac runtime qualification; fail before writes on unsupported host.

**Verification.** Source/build-graph review and host rejection here; actual Apple build, SDK ABI and speaker tests remain outstanding.

**Next actionable work.** Qualify the real Windows-to-Mac journey, then sustained clock/jitter recovery and remaining Apple/platform release gates; preserve explicit evidence limits.

**Declared surface / navigation:** `main`.


<a id="file-tools-build-reference-py"></a>

## `tools/build_reference.py`

**Responsibility.** Renders reviewed per-file contracts, declarations and SDK/evidence navigation.

**Contract and ownership.** Reads the three declared sibling projects and explicit contracts; writes only docs/reference outputs. Excludes top-level verification evidence and caches, includes authored docs/verification, and inventories installed SDK assets without modifying them. Lifecycle-core receipt is excluded from its own generated evidence listing to avoid a self-hash cycle; all source contracts remain explicit. Explicit --application-only scope updates/checks only LAN Audio, preserving reviewed sibling references and making no claim about live sibling drift. Full mode remains strict. Repository launch now uses checked-in third_party snapshots; external sibling edits do not alter adopted build inputs.

**Failure/change obligations.** Missing or stale reviewed contract entries fail. Generated placeholders are overwritten during successful render; the tool must not touch pins, source, secrets or upstream bytes.

**Verification.** Run renderer then check_docs/check_handoff; require authored docs/verification chapters in the index and top-level verification evidence outside it. Review semantic contracts and verify SDK pins separately. Exercise both scopes; full mode must still reject unregistered sibling additions.

**Next actionable work.** When adding a file, write its concrete contract data first. Avoid generic filler and distinguish extracted declarations from semantic assurance.

**Declared surface / navigation:** `inventory`; `surface`; `asset_role`; `main`.


<a id="file-tools-check-docs-py"></a>

## `tools/check_docs.py`

**Responsibility.** Read-only local Markdown navigation and current authored-file coverage gate.

**Contract and ownership.** Validate links only as local navigation; ignore fenced/inline code and external schemes. Reference inventory owns complete path coverage after the handoff migration. Explicit --application-only scope updates/checks only LAN Audio, preserving reviewed sibling references and making no claim about live sibling drift. Full mode remains strict.

**Failure/change obligations.** Missing files or malformed index fail. Passing navigation is not semantic or architectural approval; links in historical receipts may intentionally use old paths.

**Verification.** Run after documentation/layout changes and pair with check_handoff. Do not silently rewrite links or generate missing source. Exercise both scopes; full mode must still reject unregistered sibling additions.

**Next actionable work.** Keep filesystem scopes explicit; extend Markdown parsing only when a real valid construct causes a minimized false positive.


<a id="file-tools-check-handoff-py"></a>

## `tools/check_handoff.py`

**Responsibility.** Read-only exact file-index/reference/contract and local-import consistency gate.

**Contract and ownership.** Compare filesystem inventory with indexed paths, require every contract field and chapter anchor, check relative Zig imports and explicit work-package exit conditions. Explicit --application-only scope updates/checks only LAN Audio, preserving reviewed sibling references and making no claim about live sibling drift. Full mode remains strict.

**Failure/change obligations.** Stale/missing/duplicate paths, broken imports and incomplete fields fail. It never calls the renderer main or updates custody.

**Verification.** Run after render and before handoff; use actual compiler/tests for semantics and syntax beyond the simple import scanner. Exercise both scopes; full mode must still reject unregistered sibling additions.

**Next actionable work.** Extend checks for machine-readable work dependencies if the roadmap grows; do not treat text-field length as proof of documentation quality.

**Declared surface / navigation:** `len`; `in`.


<a id="file-tools-check-lifecycle-spec-py"></a>

## `tools/check_lifecycle_spec.py`

**Responsibility.** Read-only runner for lifecycle finite domains and intended mutation rejection.

**Contract and ownership.** Loads the named spec, emits source/runner hashes, Python version, state/edge counts and shortest traces to stdout; checks exact named violation for every injected defect.

**Failure/change obligations.** Exceptions, missing/wrong witnesses and failed normal exploration fail the command; arbitrary nonzero exits never qualify a mutant. It writes no source/receipt and touches no native resources.

**Verification.** Run normally and with Python -O into new phase logs, require 64/127 normal states and six exact witnesses at this source revision; inspect existential progress limits.

**Next actionable work.** Keep runner classification independent of transition guard code; change expected witnesses deliberately when the contract changes and retain prior failures.

**Declared surface / navigation:** `main`.


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


<a id="file-tools-create-pair-py"></a>

## `tools/create_pair.py`

**Responsibility.** Create and exclusively publish a complete private desktop pair; verify rather than rotate existing identities.

**Contract and ownership.** Private staging with discarded issuer key, certificate purpose verification, bounded existing manifest checks, per-role identity.json metadata and optional numeric receiver address. Concurrent publication adopts only a valid winner; existing profiles are preserved.

**Failure/change obligations.** Fresh failures clean only their own unique stage; power loss may leave an unpublished private stage. Existing incomplete/corrupt pairs reject. Windows rename and Mac RENAME_EXCL prohibit replacing destination directories; no unsafe fallback.

**Verification.** Independent mTLS pairing exchange and desktop setup tests cover reused and changed pairs, role metadata, concurrent creators, controlled failure/retry, empty manifests and address conflicts.

**Next actionable work.** Native Mac provisioning and system credential-store/renewal UX remain explicit release gates.

**Declared surface / navigation:** `private_directory`; `digest`; `publish_directory`; `verify_pair`; `create`; `_create`; `main`.


<a id="file-tools-desktop-release-py"></a>

## `tools/desktop_release.py`

**Responsibility.** Package native candidates and obtain an exact-revision public GitHub build for older Intel macOS.

**Contract and ownership.** Checked runtime hashes and upstream license bytes; exact commit, source key, target, fixed contents and GitHub HTTPS/API asset digest. macOS 12/13 never attempts the compiler that requires 14. Publication is an explicit workflow-dispatch option.

**Failure/change obligations.** Missing Git metadata/public origin/candidate, unexpected URL, digest, source or files fail without substituting a latest build or rotating saved identities. Unsigned candidates are not production qualification.

**Verification.** Independent source/revision/license rejection and Monterey branch tests plus real Windows candidate packaging; native Mac release fetch and execution still require actual CI/host evidence.

**Next actionable work.** Build the Intel Mac candidate in CI, explicitly publish the tested revision, then qualify Monterey and real speaker performance before promoting a release.

**Declared surface / navigation:** `repository_name`; `revision_id`; `package`; `inspect_payload`; `fetch`.


<a id="file-tools-launcher-config-py"></a>

## `tools/launcher_config.py`

**Responsibility.** Resolve and validate shared plus per-target launcher settings without host side effects.

**Contract and ownership.** Bounded duplicate-rejecting JSON input, known environment and audio field sets, fieldwise merge, file-relative paths, exact boolean/integer types and safe authority boundaries. Omitted audio values preserve saved profile values.

**Failure/change obligations.** Reject invalid inactive layers as well as the selected target; return fresh structures and never rewrite configuration or identities.

**Verification.** Independent environment, precedence, relative-path, duplicate/unknown field, buffer-bound and unchanged-source tests; native CLI validates final session options.

**Next actionable work.** Keep GUI and future targets consuming the same declarative contract instead of adding parallel setup state.

**Declared surface / navigation:** `validate_layer`; `resolve`.


<a id="file-tools-local-pairing-py"></a>

## `tools/local_pairing.py`

**Responsibility.** Enroll the trusted PC and Mac directly and rediscover a saved receiver on the LAN.

**Contract and ownership.** Enrollment negotiates TLS1.3 or TLS1.2 restricted to ECDHE/ECDSA AES-GCM; out-of-band leaf pin before bearer token; exact bounded receiver file bytes; durable acknowledgment; HMAC nonce discovery; no audio on Python; fixed native profile authority. Shared automatic launcher configuration selects environment overrides without rewriting saved profiles; final native session validation precedes audio, and help avoids downloads.

**Failure/change obligations.** Reject incomplete, conflicting or untrusted inputs; preserve original errors and saved identities. Do not turn Windows or loopback checks into Mac speaker readiness.

**Verification.** Run repository_launcher.py and desktop_setup.py plus custody and application documentation gates; inspect native Mac CI and hardware evidence separately. Force a real enrollment client to TLS1.2 and inspect negotiated protocol/cipher; capable clients still negotiate TLS1.3. Native audio policy is unchanged.

**Next actionable work.** Execute the clean native Mac build and real Windows-to-Mac speaker session; preserve target-specific failures before expanding platform claims.

**Declared surface / navigation:** `enrollment_context`; `receive_exact`; `receive`; `send`; `local_addresses`; `invitation`; `parse_invitation`; `save_receiver`; `join`; `offer`; `proof`; `discovery_listener`; `discover`; `session_settings`; `validate_session`; `connect_and_run`.


<a id="file-tools-reference-contracts-json"></a>

## `tools/reference_contracts.json`

**Responsibility.** Reviewed semantic source of per-file documentation across the three admitted projects.

**Contract and ownership.** Each project-relative file key has purpose, contract, failure/change, verification and next-work text. Installed SDK rows use the explicit upstream asset policy instead.

**Failure/change obligations.** Do not generate meaningless prose to satisfy field length; stale keys are errors. This is navigation/engineering data, not a dependency hash lock.

**Verification.** Renderer rejects missing/stale entries; check_handoff validates exact coverage and per-file references.

**Next actionable work.** Update concrete semantics when code changes, render chapters, and review both. Proposed files remain in work packages until implemented.


<a id="file-tools-setup-desktop-py"></a>

## `tools/setup_desktop.py`

**Responsibility.** Provision and verify private Windows/Intel Mac desktop installations from explicit build and pair inputs.

**Contract and ownership.** Bounded declarative setup or explicit CLI inputs; fixed immutable runtime/identity set, matching key/cert, profile-bound authority, actual staged CLI check and exclusive directory publication. Repeats preserve edited operation profiles and all existing bytes; bootstrap may create/reuse a full private pair before sender install.

**Failure/change obligations.** Reject conflicts, unknown or duplicate configuration, tampered files, missing builds and unsupported targets. Clean only the uniquely generated private stage. No implicit update, key rotation, network/audio, global settings or signed-publisher claim.

**Verification.** Independent desktop_setup.py campaign: repeat/concurrent/interrupted setup, malformed keys/configs, immutable custody, no-write verification, path-relative config and relocated start/check; native Mac remains unexecuted.

**Next actionable work.** Execute native Mac setup and clean-host distribution, then qualify updates, permissions and sustained real speaker playback.

**Declared surface / navigation:** `unique_object`; `read_json`; `sha`; `host_target`; `snapshot`; `identity`; `check_binding`; `check_credentials`; `validate`; `install`; `main`.


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

**Contract and ownership.** Reviewed exact TLS source/SDK/fixture adoption inputs, not a generated inventory. The 2026-09-26 documentation adoption records nine reviewed README/comment/package-path changes and retains all other 179 pins; original code bodies and SDK/fixture bytes are unchanged. Repository launch now uses checked-in third_party snapshots; external sibling edits do not alter adopted build inputs.

**Failure/change obligations.** Do not hand-edit a hash to hide source drift. A new platform/dependency revision needs an explicit adoption diff and qualified binaries.

**Verification.** tools/check_transport.py and staged DLL checks; independent runtime path validation belongs to the TLS tests.

**Next actionable work.** WP01 defines target-specific Mac identity and package closure; retain original Windows/source provenance.

**Declared surface / navigation:** `adopted`; `root`; `package_version`; `profile`; `files`; `runtime_dlls`; `runtime_imports`; `upstream`; `scope`; `reviewed_documentation_adoptions`; `review_receipt`.
