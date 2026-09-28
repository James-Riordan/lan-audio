# tls-zig: granular file contracts

Generated from reviewed `tools/reference_contracts.json`. Edit the contract data, then render; do not edit this chapter alone.


<a id="file-agents-md"></a>

## `AGENTS.md`

**Responsibility.** Maintainer entry point for this project and its implementation handoff.

**Contract and ownership.** Dependency maintainer entry linking current status, public ownership constraints, exact compiler, verification commands and compatible growth. User/session authorization remains superior to repository prose. See [dependency-owned contract](../../../tls-zig/docs/reference/files/AGENTS.md.md).

**Failure/change obligations.** Do not treat a planned QUIC recordless API as implemented TLS, repin to hide drift or count a design card as a working capability.

**Verification.** Run tls-zig/tools/check-docs.py with its declared options and review the named source/test/receipt; application coverage checks establish navigation only.

**Next actionable work.** Select the next dependency-ready work order and keep application policy in consumers; preserve the existing records Engine/Driver contract.

**Declared surface / navigation:** `tls-zig: implementation handoff`.


<a id="file-backend-lock-json"></a>

## `backend-lock.json`

**Responsibility.** Exact Windows SDK artifacts and build provenance/tool identities.

**Contract and ownership.** The 166 SDK files are adopted inputs; target/tool/source metadata describes the recorded build, not a guarantee of current upstream support or signatures.

**Failure/change obligations.** Preserve exact error/custody/lifetime semantics and old users. Unexpected failures remain failures; a passing local test is not cross-platform or whole-library security certification.

**Verification.** Generic Engine/Driver tests, independent SSL/TCP consumers, exact backend/runtime checks and relevant source hashes; rerun only affected gates.

**Next actionable work.** WP01 records Mac SDK separately and retains the Windows lock; review all changed imports/provenance.

**Declared surface / navigation:** `backend`; `target`; `zig`; `compiler`; `source`; `openssl_version_a`; `sdk_root`; `sdk_files`; `build_tools`.


<a id="file-build-zig"></a>

## `build.zig`

**Responsibility.** Build Zig/C TLS wrapper against the explicit private Windows OpenSSL SDK and stage matching DLLs.

**Contract and ownership.** Target and optimization flow to every dependent artifact. Compile steps are distinct from execution; do not open devices or network as an implicit build action.

**Failure/change obligations.** Wrong targets, missing SDK/runtime and ABI/link mismatches must fail. A successful cached compile does not prove execution or correct runtime search paths.

**Verification.** Run owning native tests and independent downstream consumer after graph changes; inspect staged imports and target identity.

**Next actionable work.** WP01 extends native platform build qualification; preserve existing public module names and callback/test separation.

**Declared surface / navigation:** `staged`; `build`; `std`; `files`; `target`; `optimize`; `openssl`; `mod`; `test_mod`; `test_exe`; `tests`; `host_test_mod`; `host_test_exe`; `host_tests`; `exe`; `run`; `interop_mod`; `interop_lib`; `interop`.


<a id="file-build-zig-zon"></a>

## `build.zig.zon`

**Responsibility.** Own package identity, version/compiler floor, dependency declarations and distribution allowlist.

**Contract and ownership.** ZON is Zig package metadata, distinct from ZSON. Fingerprint is identity, not artifact integrity. Sibling paths are development dependencies and require a release closure.

**Failure/change obligations.** Do not silently rename identities or raise compiler floor; changes need compatibility and clean-checkout evidence. Excluded source/docs must not break packages.

**Verification.** Parse/build with pinned compiler; test package allowlist and downstream import from a clean layout.

**Next actionable work.** WP09 replaces development-only assumptions with reproducible source/package custody and includes all required handoff documents.


<a id="file-checkpoint-md"></a>

## `CHECKPOINT.md`

**Responsibility.** Historical engineering context: TLS current checkpoint — September 14, 2026.

**Contract and ownership.** Dated workflow/evidence observations; never independent authorization to execute commands or change unrelated repositories.

**Failure/change obligations.** Do not duplicate conflicting protocol/API meaning or imply unexecuted platform support. Preserve useful history and label superseded claims rather than erasing evidence.

**Verification.** Validate local navigation and file index, compare referenced source behavior and evidence dates/hashes; prose quality requires review beyond automated checks.

**Next actionable work.** Read the declared sections below; update this guide whenever its owned contract changes and link to granular implementation/verification obligations.

**Declared surface / navigation:** `TLS current checkpoint — September 14, 2026`; `Completed usable increment`; `Snapshot adopted by Zap`; `2026-09-15 bounded continuation: peer probe 0.1.4`; `2026-09-15 subsequent Zap adoption confirmed`.


<a id="file-docs-architecture-decisions-0001-compatible-growth-md"></a>

## `docs/architecture/decisions/0001-compatible-growth.md`

**Responsibility.** Dependency-owned authored architecture, guide, model or navigation artifact: ADR 0001: Compatible growth from the working foundations.

**Contract and ownership.** Canonical dependency documentation or evidence for this named subject; retain implemented/proposed/historical distinctions and its precise source/target scope. The application imports this navigation, not a duplicate implementation or new trust input. See [dependency-owned contract](../../../tls-zig/docs/architecture/decisions/0001-compatible-growth.md).

**Failure/change obligations.** Local documentation integrity does not establish production readiness, host availability or unbounded mathematical correctness. Review the document itself before adopting a behavioral claim.

**Verification.** Run tls-zig/tools/check-docs.py with its declared options and review the named source/test/receipt; application coverage checks establish navigation only.

**Next actionable work.** Maintain this subject with its owning TLS work order and artifact register; coordinate application-relevant API/identity/platform changes with the consumer.

**Declared surface / navigation:** `ADR 0001: Compatible growth from the working foundations`.


<a id="file-docs-architecture-decisions-0002-implementation-profile-md"></a>

## `docs/architecture/decisions/0002-implementation-profile.md`

**Responsibility.** Proposed first production implementation profile.

**Contract and ownership.** Records selected scope and prerequisites for transport implementation; choices remain bounded by current provider and host qualification. See [owner contract](../../../tls-zig/docs/architecture/decisions/0002-implementation-profile.md).

**Failure/change obligations.** Preserve planned, implemented and historically observed status. Source changes require a new owner receipt; no silent application trust/pin adoption.

**Verification.** Review acceptance obligations and unresolved decisions before implementing each profile feature.

**Next actionable work.** Continue through the owning dependency work package; application policy and credentials stay in LAN Audio.

**Declared surface / navigation:** `Decision 0002: selected implementation profile`; `Scope and capability selection`; `Public API acceptance contract`; `Compatibility and packaging`; `Revisit triggers`.


<a id="file-docs-architecture-directory-map-md"></a>

## `docs/architecture/directory-map.md`

**Responsibility.** Dependency-owned nested existing/planned source directory map: Physical and planned directory map.

**Contract and ownership.** Canonical dependency documentation or evidence for this named subject; retain implemented/proposed/historical distinctions and its precise source/target scope. The application imports this navigation, not a duplicate implementation or new trust input. See [dependency-owned contract](../../../tls-zig/docs/architecture/directory-map.md).

**Failure/change obligations.** Local documentation integrity does not establish production readiness, host availability or unbounded mathematical correctness. Review the document itself before adopting a behavioral claim.

**Verification.** Run tls-zig/tools/check-docs.py with its declared options and review the named source/test/receipt; application coverage checks establish navigation only.

**Next actionable work.** Maintain this subject with its owning TLS work order and artifact register; coordinate application-relevant API/identity/platform changes with the consumer.

**Declared surface / navigation:** `Existing and planned directory map — revision 3`.


<a id="file-docs-architecture-portability-md"></a>

## `docs/architecture/portability.md`

**Responsibility.** Dependency-owned authored architecture, guide, model or navigation artifact: Portability and resource contract.

**Contract and ownership.** Canonical dependency documentation or evidence for this named subject; retain implemented/proposed/historical distinctions and its precise source/target scope. The application imports this navigation, not a duplicate implementation or new trust input. See [dependency-owned contract](../../../tls-zig/docs/architecture/portability.md).

**Failure/change obligations.** Local documentation integrity does not establish production readiness, host availability or unbounded mathematical correctness. Review the document itself before adopting a behavioral claim.

**Verification.** Run tls-zig/tools/check-docs.py with its declared options and review the named source/test/receipt; application coverage checks establish navigation only.

**Next actionable work.** Maintain this subject with its owning TLS work order and artifact register; coordinate application-relevant API/identity/platform changes with the consumer.

**Declared surface / navigation:** `Portability and resource contract`; `Resource envelope`.


<a id="file-docs-architecture-principles-md"></a>

## `docs/architecture/principles.md`

**Responsibility.** Dependency-owned authored architecture, guide, model or navigation artifact: Engineering principles and scope.

**Contract and ownership.** Canonical dependency documentation or evidence for this named subject; retain implemented/proposed/historical distinctions and its precise source/target scope. The application imports this navigation, not a duplicate implementation or new trust input. See [dependency-owned contract](../../../tls-zig/docs/architecture/principles.md).

**Failure/change obligations.** Local documentation integrity does not establish production readiness, host availability or unbounded mathematical correctness. Review the document itself before adopting a behavioral claim.

**Verification.** Run tls-zig/tools/check-docs.py with its declared options and review the named source/test/receipt; application coverage checks establish navigation only.

**Next actionable work.** Maintain this subject with its owning TLS work order and artifact register; coordinate application-relevant API/identity/platform changes with the consumer.

**Declared surface / navigation:** `Engineering principles and scope`; `Ownership boundaries`; `Design rules`; `Versioned decisions`.


<a id="file-docs-architecture-structure-md"></a>

## `docs/architecture/structure.md`

**Responsibility.** Dependency-owned authored architecture, guide, model or navigation artifact: Directory policy and migration.

**Contract and ownership.** Canonical dependency documentation or evidence for this named subject; retain implemented/proposed/historical distinctions and its precise source/target scope. The application imports this navigation, not a duplicate implementation or new trust input. See [dependency-owned contract](../../../tls-zig/docs/architecture/structure.md).

**Failure/change obligations.** Local documentation integrity does not establish production readiness, host availability or unbounded mathematical correctness. Review the document itself before adopting a behavioral claim.

**Verification.** Run tls-zig/tools/check-docs.py with its declared options and review the named source/test/receipt; application coverage checks establish navigation only.

**Next actionable work.** Maintain this subject with its owning TLS work order and artifact register; coordinate application-relevant API/identity/platform changes with the consumer.

**Declared surface / navigation:** `Directory policy and migration`; `Migration protocol`; `Generated and external material`.


<a id="file-docs-architecture-target-tree-txt"></a>

## `docs/architecture/target-tree.txt`

**Responsibility.** Dependency-owned authored architecture, guide, model or navigation artifact: docs/architecture/target-tree.txt.

**Contract and ownership.** Canonical dependency documentation or evidence for this named subject; retain implemented/proposed/historical distinctions and its precise source/target scope. The application imports this navigation, not a duplicate implementation or new trust input. See [dependency-owned contract](../../../tls-zig/docs/architecture/target-tree.txt).

**Failure/change obligations.** Local documentation integrity does not establish production readiness, host availability or unbounded mathematical correctness. Review the document itself before adopting a behavioral claim.

**Verification.** Run tls-zig/tools/check-docs.py with its declared options and review the named source/test/receipt; application coverage checks establish navigation only.

**Next actionable work.** Maintain this subject with its owning TLS work order and artifact register; coordinate application-relevant API/identity/platform changes with the consumer.


<a id="file-docs-contracts-connection-transactions-md"></a>

## `docs/contracts/connection-transactions.md`

**Responsibility.** Future receive/send transaction and failure commit boundaries.

**Contract and ownership.** Preflight validates candidate effects before infallible commit; immutable send plans retain bytes/reservations across would-block and reject stale completions. See [owner contract](../../../tls-zig/docs/contracts/connection-transactions.md).

**Failure/change obligations.** Preserve planned, implemented and historically observed status. Source changes require a new owner receipt; no silent application trust/pin adoption.

**Verification.** Independent participant ledgers must detect partial admission, nonce/reservation reuse, double debit and cleanup errors; current source is not qualified by prose.

**Next actionable work.** Continue through the owning dependency work package; application policy and credentials stay in LAN Audio.

**Declared surface / navigation:** `Connection operations, failure boundaries and deterministic scheduling`; `One owner, one operation boundary`; `Receive transaction`; `Send plan lifecycle`; `Local error taxonomy`; `Refinement tests`.


<a id="file-docs-contracts-quic-tls-md"></a>

## `docs/contracts/quic-tls.md`

**Responsibility.** Dependency-owned authored architecture, guide, model or navigation artifact: QUIC–TLS implementation contract.

**Contract and ownership.** Canonical dependency documentation or evidence for this named subject; retain implemented/proposed/historical distinctions and its precise source/target scope. The application imports this navigation, not a duplicate implementation or new trust input. See [dependency-owned contract](../../../tls-zig/docs/contracts/quic-tls.md).

**Failure/change obligations.** Local documentation integrity does not establish production readiness, host availability or unbounded mathematical correctness. Review the document itself before adopting a behavioral claim.

**Verification.** Run tls-zig/tools/check-docs.py with its declared options and review the named source/test/receipt; application coverage checks establish navigation only.

**Next actionable work.** Maintain this subject with its owning TLS work order and artifact register; coordinate application-relevant API/identity/platform changes with the consumer.

**Declared surface / navigation:** `QUIC–TLS implementation contract`; `Required decisions before T1/Q1`; `Event and lifetime rules`; `Clocks and units`; `Receive transaction`; `Send transaction`; `First acceptance trace`.


<a id="file-docs-contracts-recordless-events-md"></a>

## `docs/contracts/recordless-events.md`

**Responsibility.** Proposed recordless TLS event ownership contract.

**Contract and ownership.** Defines bounded serialized handshake/key/parameter event custody, copy/derive before acknowledgement, issuer/sequence validation and terminal cancellation. See [owner contract](../../../tls-zig/docs/contracts/recordless-events.md).

**Failure/change obligations.** Preserve planned, implemented and historically observed status. Source changes require a new owner receipt; no silent application trust/pin adoption.

**Verification.** Review against the event model and future concrete backend; no current production API or QUIC connection is supplied.

**Next actionable work.** Continue through the owning dependency work package; application policy and credentials stay in LAN Audio.

**Declared surface / navigation:** `Recordless TLS event custody: implementation design`; `Owners and units`; `Proposed operations`; `Callback adapter and backpressure`; `Readiness and completion`; `Failures and diagnostics`; `Required evidence before T1 completion`.


<a id="file-docs-contracts-resource-budgets-md"></a>

## `docs/contracts/resource-budgets.md`

**Responsibility.** Proposed bounded ownership, storage and work budgets.

**Contract and ownership.** Assigns owners and accounting boundaries for buffers, control work, provider resources and explicit exhaustion behavior. See [owner contract](../../../tls-zig/docs/contracts/resource-budgets.md).

**Failure/change obligations.** Preserve planned, implemented and historically observed status. Source changes require a new owner receipt; no silent application trust/pin adoption.

**Verification.** Measure provider allocation/work and inject exhaustion; numeric design budgets alone are not measured runtime bounds.

**Next actionable work.** Continue through the owning dependency work package; application policy and credentials stay in LAN Audio.

**Declared surface / navigation:** `Resource, counter and scheduling budget contract`; `Capacity owners`; `Accounting model`; `Counter and time rules`; `Reclamation decision still required`; `Measurement receipt`.


<a id="file-docs-ecosystem-configuration-and-capabilities-md"></a>

## `docs/ecosystem/configuration-and-capabilities.md`

**Responsibility.** Transport configuration authority and host capability boundaries.

**Contract and ownership.** Keeps ZSON/profile policy separate from cryptographic/runtime capability and unsupported target claims. See [canonical owner document](../../../tls-zig/docs/ecosystem/configuration-and-capabilities.md).

**Failure/change obligations.** Preserve observed/planned/implemented distinctions and explicit owner boundaries; do not adopt a missing API or broaden evidence scope.

**Verification.** Run owner documentation/custody checks and review recorded inputs/receipts; this application integration is navigation and hash reconciliation.

**Next actionable work.** Implement only the selected dependency-ready work with a real caller and target-specific acceptance; retain historical receipts.

**Declared surface / navigation:** `Configuration and adaptive host capabilities`; `The actual ZSON execution boundary`; `Proposed field responsibility matrix`; `Build and runtime admission`; `Required tests`.


<a id="file-docs-ecosystem-docz-migration-md"></a>

## `docs/ecosystem/docz-migration.md`

**Responsibility.** Owner-backed transport handbook Docz migration gate.

**Contract and ownership.** Preserves canonical source, mathematics/code/link semantics and evidence; producer samples do not make full migration complete. See [canonical owner document](../../../tls-zig/docs/ecosystem/docz-migration.md).

**Failure/change obligations.** Preserve observed/planned/implemented distinctions and explicit owner boundaries; do not adopt a missing API or broaden evidence scope.

**Verification.** Run owner documentation/custody checks and review recorded inputs/receipts; this application integration is navigation and hash reconciliation.

**Next actionable work.** Implement only the selected dependency-ready work with a real caller and target-specific acceptance; retain historical receipts.

**Declared surface / navigation:** `Future README.dcz and Quartz documentation migration`; `Producer boundary observed`; `Migration inventory and mapping`; `Required gate sequence`; `Preview scope`.


<a id="file-docs-ecosystem-maintenance-and-observability-md"></a>

## `docs/ecosystem/maintenance-and-observability.md`

**Responsibility.** Transport maintenance, update and diagnostic ownership.

**Contract and ownership.** Defines bounded telemetry, explicit adoption/rollback and source-comparable findings without moving application policy into reusable protocols. See [canonical owner document](../../../tls-zig/docs/ecosystem/maintenance-and-observability.md).

**Failure/change obligations.** Preserve observed/planned/implemented distinctions and explicit owner boundaries; do not adopt a missing API or broaden evidence scope.

**Verification.** Run owner documentation/custody checks and review recorded inputs/receipts; this application integration is navigation and hash reconciliation.

**Next actionable work.** Implement only the selected dependency-ready work with a real caller and target-specific acceptance; retain historical receipts.

**Declared surface / navigation:** `One-command maintenance and bounded observability`; `Consumer-safe update journey`; `Repair packet for future Codex work`; `Operational telemetry contract`; `Workflow acceptance`.


<a id="file-docs-ecosystem-overview-md"></a>

## `docs/ecosystem/overview.md`

**Responsibility.** QUIC/TLS placement in the wider JCR ecosystem.

**Contract and ownership.** Separates reusable transport capabilities from optional integration, domain authorization and managed deployment. See [canonical owner document](../../../tls-zig/docs/ecosystem/overview.md).

**Failure/change obligations.** Preserve observed/planned/implemented distinctions and explicit owner boundaries; do not adopt a missing API or broaden evidence scope.

**Verification.** Run owner documentation/custody checks and review recorded inputs/receipts; this application integration is navigation and hash reconciliation.

**Next actionable work.** Implement only the selected dependency-ready work with a real caller and target-specific acceptance; retain historical receipts.

**Declared surface / navigation:** `QUIC and TLS within the JCR / Zigadel ecosystem`; `Ownership and composition`; `Identity before location, without losing wire facts`; `Adaptation is an explicit decision`; `Where idempotence belongs`; `Source observations and adoption`.


<a id="file-docs-ecosystem-producer-observations-json"></a>

## `docs/ecosystem/producer-observations.json`

**Responsibility.** Observed external producer/profile inputs for ecosystem readiness.

**Contract and ownership.** Records bounded observations with provenance; it is not a dependency manifest, application trust input or complete Docz compatibility certificate. See [canonical owner document](../../../tls-zig/docs/ecosystem/producer-observations.json).

**Failure/change obligations.** Preserve observed/planned/implemented distinctions and explicit owner boundaries; do not adopt a missing API or broaden evidence scope.

**Verification.** Run owner documentation/custody checks and review recorded inputs/receipts; this application integration is navigation and hash reconciliation.

**Next actionable work.** Implement only the selected dependency-ready work with a real caller and target-specific acceptance; retain historical receipts.

**Declared surface / navigation:** `scope`; `files`.


<a id="file-docs-formal-event-custody-md"></a>

## `docs/formal/event-custody.md`

**Responsibility.** Abstraction and limits of finite TLS event custody.

**Contract and ownership.** Separates safety state exploration and injected counterexamples from unbounded proof, fair progress, secret handling and native callback implementation. See [owner contract](../../../tls-zig/docs/formal/event-custody.md).

**Failure/change obligations.** Preserve planned, implemented and historically observed status. Source changes require a new owner receipt; no silent application trust/pin adoption.

**Verification.** Run the named finite model and retain its domains/violations; independently discharge implementation refinement later.

**Next actionable work.** Continue through the owning dependency work package; application policy and credentials stay in LAN Audio.

**Declared surface / navigation:** `Finite model: acknowledged event custody`; `State and transitions`; `Fault sensitivity`; `Limits and implementation obligations`.


<a id="file-docs-formal-invariants-md"></a>

## `docs/formal/invariants.md`

**Responsibility.** Dependency-owned authored architecture, guide, model or navigation artifact: State models and proof obligations.

**Contract and ownership.** Canonical dependency documentation or evidence for this named subject; retain implemented/proposed/historical distinctions and its precise source/target scope. The application imports this navigation, not a duplicate implementation or new trust input. See [dependency-owned contract](../../../tls-zig/docs/formal/invariants.md).

**Failure/change obligations.** Local documentation integrity does not establish production readiness, host availability or unbounded mathematical correctness. Review the document itself before adopting a behavioral claim.

**Verification.** Run tls-zig/tools/check-docs.py with its declared options and review the named source/test/receipt; application coverage checks establish navigation only.

**Next actionable work.** Maintain this subject with its owning TLS work order and artifact register; coordinate application-relevant API/identity/platform changes with the consumer.

**Declared surface / navigation:** `State models and proof obligations`; `CRYPTO custody and admission`; `Packet numbers and secrets`; `ACK scheduling`; `Amplification and flight accounting`; `Time and shutdown`; `Liveness assumptions and refinement`.


<a id="file-docs-formal-recovery-md"></a>

## `docs/formal/recovery.md`

**Responsibility.** Dependency-owned authored architecture, guide, model or navigation artifact: Recovery and pacing arithmetic: current implementation model.

**Contract and ownership.** Canonical dependency documentation or evidence for this named subject; retain implemented/proposed/historical distinctions and its precise source/target scope. The application imports this navigation, not a duplicate implementation or new trust input. See [dependency-owned contract](../../../tls-zig/docs/formal/recovery.md).

**Failure/change obligations.** Local documentation integrity does not establish production readiness, host availability or unbounded mathematical correctness. Review the document itself before adopting a behavioral claim.

**Verification.** Run tls-zig/tools/check-docs.py with its declared options and review the named source/test/receipt; application coverage checks establish navigation only.

**Next actionable work.** Maintain this subject with its owning TLS work order and artifact register; coordinate application-relevant API/identity/platform changes with the consumer.

**Declared surface / navigation:** `Recovery and pacing arithmetic: current implementation model`; `Independent oracle cases`.


<a id="file-docs-formal-tls-driver-md"></a>

## `docs/formal/tls-driver.md`

**Responsibility.** Dependency-owned authored architecture, guide, model or navigation artifact: TLS Driver transition model.

**Contract and ownership.** Canonical dependency documentation or evidence for this named subject; retain implemented/proposed/historical distinctions and its precise source/target scope. The application imports this navigation, not a duplicate implementation or new trust input. See [dependency-owned contract](../../../tls-zig/docs/formal/tls-driver.md).

**Failure/change obligations.** Local documentation integrity does not establish production readiness, host availability or unbounded mathematical correctness. Review the document itself before adopting a behavioral claim.

**Verification.** Run tls-zig/tools/check-docs.py with its declared options and review the named source/test/receipt; application coverage checks establish navigation only.

**Next actionable work.** Maintain this subject with its owning TLS work order and artifact register; coordinate application-relevant API/identity/platform changes with the consumer.

**Declared surface / navigation:** `TLS Driver transition model`; `Next refinement work`.


<a id="file-docs-guides-host-usage-md"></a>

## `docs/guides/host-usage.md`

**Responsibility.** Dependency-owned authored architecture, guide, model or navigation artifact: Host integration and troubleshooting.

**Contract and ownership.** Canonical dependency documentation or evidence for this named subject; retain implemented/proposed/historical distinctions and its precise source/target scope. The application imports this navigation, not a duplicate implementation or new trust input. See [dependency-owned contract](../../../tls-zig/docs/guides/host-usage.md).

**Failure/change obligations.** Local documentation integrity does not establish production readiness, host availability or unbounded mathematical correctness. Review the document itself before adopting a behavioral claim.

**Verification.** Run tls-zig/tools/check-docs.py with its declared options and review the named source/test/receipt; application coverage checks establish navigation only.

**Next actionable work.** Maintain this subject with its owning TLS work order and artifact register; coordinate application-relevant API/identity/platform changes with the consumer.

**Declared surface / navigation:** `Host integration and troubleshooting`; `TLS records sequence`; `QUIC offline sequence`.


<a id="file-docs-readme-md"></a>

## `docs/README.md`

**Responsibility.** Dependency-owned authored architecture, guide, model or navigation artifact: tls-zig engineering handoff.

**Contract and ownership.** Canonical dependency documentation or evidence for this named subject; retain implemented/proposed/historical distinctions and its precise source/target scope. The application imports this navigation, not a duplicate implementation or new trust input. See [dependency-owned contract](../../../tls-zig/docs/README.md).

**Failure/change obligations.** Local documentation integrity does not establish production readiness, host availability or unbounded mathematical correctness. Review the document itself before adopting a behavioral claim.

**Verification.** Run tls-zig/tools/check-docs.py with its declared options and review the named source/test/receipt; application coverage checks establish navigation only.

**Next actionable work.** Maintain this subject with its owning TLS work order and artifact register; coordinate application-relevant API/identity/platform changes with the consumer.

**Declared surface / navigation:** `tls-zig engineering handoff`; `How to continue`; `Review evidence`; `Revision 2 implementation detail`; `Revision 3: before implementation takeover`; `Ecosystem alignment — revision 4`.


<a id="file-docs-reference-catalog-md"></a>

## `docs/reference/catalog.md`

**Responsibility.** Dependency-owned authored architecture, guide, model or navigation artifact: Existing file catalog.

**Contract and ownership.** Canonical dependency documentation or evidence for this named subject; retain implemented/proposed/historical distinctions and its precise source/target scope. The application imports this navigation, not a duplicate implementation or new trust input. See [dependency-owned contract](../../../tls-zig/docs/reference/catalog.md).

**Failure/change obligations.** Local documentation integrity does not establish production readiness, host availability or unbounded mathematical correctness. Review the document itself before adopting a behavioral claim.

**Verification.** Run tls-zig/tools/check-docs.py with its declared options and review the named source/test/receipt; application coverage checks establish navigation only.

**Next actionable work.** Maintain this subject with its owning TLS work order and artifact register; coordinate application-relevant API/identity/platform changes with the consumer.

**Declared surface / navigation:** `Existing file catalog`; `Revision 2 maintenance and probe contracts`; `Revision 3 lifecycle tooling`.


<a id="file-docs-reference-files-agents-md-md"></a>

## `docs/reference/files/AGENTS.md.md`

**Responsibility.** Dependency-owned semantic contract and declaration navigation for tls-zig/AGENTS.md.

**Contract and ownership.** The linked card owns documentation for AGENTS.md; source remains behavioral authority. Its snapshot hash and extracted declarations are navigation/provenance, not application adoption pins or a complete refinement proof. See [dependency-owned contract](../../../tls-zig/docs/reference/files/AGENTS.md.md).

**Failure/change obligations.** Changes to AGENTS.md require review of its actual ownership/failure semantics and this card. Do not replace specific application boundary contracts with mechanically extracted declaration lists.

**Verification.** Run tls-zig/tools/check-docs.py with its declared options and review the named source/test/receipt; application coverage checks establish navigation only.

**Next actionable work.** Follow this card with the canonical AGENTS.md source and its named tests when changing that dependency boundary.

**Declared surface / navigation:** `AGENTS.md`; `Responsibility`; `Contract, ownership and failure behavior`; `Next implementation work`; `Verification obligations`.


<a id="file-docs-reference-files-backend-lock-json-md"></a>

## `docs/reference/files/backend-lock.json.md`

**Responsibility.** Dependency-owned semantic contract and declaration navigation for tls-zig/backend-lock.json.

**Contract and ownership.** The linked card owns documentation for backend-lock.json; source remains behavioral authority. Its snapshot hash and extracted declarations are navigation/provenance, not application adoption pins or a complete refinement proof. See [dependency-owned contract](../../../tls-zig/docs/reference/files/backend-lock.json.md).

**Failure/change obligations.** Changes to backend-lock.json require review of its actual ownership/failure semantics and this card. Do not replace specific application boundary contracts with mechanically extracted declaration lists.

**Verification.** Run tls-zig/tools/check-docs.py with its declared options and review the named source/test/receipt; application coverage checks establish navigation only.

**Next actionable work.** Follow this card with the canonical backend-lock.json source and its named tests when changing that dependency boundary.

**Declared surface / navigation:** `backend-lock.json`; `Responsibility`; `Contract, ownership and failure behavior`; `Next implementation work`; `Verification obligations`.


<a id="file-docs-reference-files-build-zig-md"></a>

## `docs/reference/files/build.zig.md`

**Responsibility.** Dependency-owned semantic contract and declaration navigation for tls-zig/build.zig.

**Contract and ownership.** The linked card owns documentation for build.zig; source remains behavioral authority. Its snapshot hash and extracted declarations are navigation/provenance, not application adoption pins or a complete refinement proof. See [dependency-owned contract](../../../tls-zig/docs/reference/files/build.zig.md).

**Failure/change obligations.** Changes to build.zig require review of its actual ownership/failure semantics and this card. Do not replace specific application boundary contracts with mechanically extracted declaration lists.

**Verification.** Run tls-zig/tools/check-docs.py with its declared options and review the named source/test/receipt; application coverage checks establish navigation only.

**Next actionable work.** Follow this card with the canonical build.zig source and its named tests when changing that dependency boundary.

**Declared surface / navigation:** `build.zig`; `Responsibility`; `Contract, ownership and failure behavior`; `Next implementation work`; `Verification obligations`; `Dependency edges`; `Declaration-by-declaration work map`; `staged — line 12`; `build — line 18`.


<a id="file-docs-reference-files-build-zig-zon-md"></a>

## `docs/reference/files/build.zig.zon.md`

**Responsibility.** Dependency-owned semantic contract and declaration navigation for tls-zig/build.zig.zon.

**Contract and ownership.** The linked card owns documentation for build.zig.zon; source remains behavioral authority. Its snapshot hash and extracted declarations are navigation/provenance, not application adoption pins or a complete refinement proof. See [dependency-owned contract](../../../tls-zig/docs/reference/files/build.zig.zon.md).

**Failure/change obligations.** Changes to build.zig.zon require review of its actual ownership/failure semantics and this card. Do not replace specific application boundary contracts with mechanically extracted declaration lists.

**Verification.** Run tls-zig/tools/check-docs.py with its declared options and review the named source/test/receipt; application coverage checks establish navigation only.

**Next actionable work.** Follow this card with the canonical build.zig.zon source and its named tests when changing that dependency boundary.

**Declared surface / navigation:** `build.zig.zon`; `Responsibility`; `Contract, ownership and failure behavior`; `Next implementation work`; `Verification obligations`.


<a id="file-docs-reference-files-checkpoint-md-md"></a>

## `docs/reference/files/CHECKPOINT.md.md`

**Responsibility.** Dependency-owned semantic contract and declaration navigation for tls-zig/CHECKPOINT.md.

**Contract and ownership.** The linked card owns documentation for CHECKPOINT.md; source remains behavioral authority. Its snapshot hash and extracted declarations are navigation/provenance, not application adoption pins or a complete refinement proof. See [dependency-owned contract](../../../tls-zig/docs/reference/files/CHECKPOINT.md.md).

**Failure/change obligations.** Changes to CHECKPOINT.md require review of its actual ownership/failure semantics and this card. Do not replace specific application boundary contracts with mechanically extracted declaration lists.

**Verification.** Run tls-zig/tools/check-docs.py with its declared options and review the named source/test/receipt; application coverage checks establish navigation only.

**Next actionable work.** Follow this card with the canonical CHECKPOINT.md source and its named tests when changing that dependency boundary.

**Declared surface / navigation:** `CHECKPOINT.md`; `Responsibility`; `Contract, ownership and failure behavior`; `Next implementation work`; `Verification obligations`.


<a id="file-docs-reference-files-evidence-build-recovery-md-md"></a>

## `docs/reference/files/evidence/build-recovery.md.md`

**Responsibility.** Dependency-owned semantic contract and declaration navigation for tls-zig/evidence/build-recovery.md.

**Contract and ownership.** The linked card owns documentation for evidence/build-recovery.md; source remains behavioral authority. Its snapshot hash and extracted declarations are navigation/provenance, not application adoption pins or a complete refinement proof. See [dependency-owned contract](../../../tls-zig/docs/reference/files/evidence/build-recovery.md.md).

**Failure/change obligations.** Changes to evidence/build-recovery.md require review of its actual ownership/failure semantics and this card. Do not replace specific application boundary contracts with mechanically extracted declaration lists.

**Verification.** Run tls-zig/tools/check-docs.py with its declared options and review the named source/test/receipt; application coverage checks establish navigation only.

**Next actionable work.** Follow this card with the canonical evidence/build-recovery.md source and its named tests when changing that dependency boundary.

**Declared surface / navigation:** `evidence/build-recovery.md`; `Responsibility`; `Contract, ownership and failure behavior`; `Next implementation work`; `Verification obligations`.


<a id="file-docs-reference-files-evidence-source-provenance-json-md"></a>

## `docs/reference/files/evidence/source-provenance.json.md`

**Responsibility.** Dependency-owned semantic contract and declaration navigation for tls-zig/evidence/source-provenance.json.

**Contract and ownership.** The linked card owns documentation for evidence/source-provenance.json; source remains behavioral authority. Its snapshot hash and extracted declarations are navigation/provenance, not application adoption pins or a complete refinement proof. See [dependency-owned contract](../../../tls-zig/docs/reference/files/evidence/source-provenance.json.md).

**Failure/change obligations.** Changes to evidence/source-provenance.json require review of its actual ownership/failure semantics and this card. Do not replace specific application boundary contracts with mechanically extracted declaration lists.

**Verification.** Run tls-zig/tools/check-docs.py with its declared options and review the named source/test/receipt; application coverage checks establish navigation only.

**Next actionable work.** Follow this card with the canonical evidence/source-provenance.json source and its named tests when changing that dependency boundary.

**Declared surface / navigation:** `evidence/source-provenance.json`; `Responsibility`; `Contract, ownership and failure behavior`; `Next implementation work`; `Verification obligations`.


<a id="file-docs-reference-files-examples-consumer-build-zig-md"></a>

## `docs/reference/files/examples/consumer/build.zig.md`

**Responsibility.** Dependency-owned semantic contract and declaration navigation for tls-zig/examples/consumer/build.zig.

**Contract and ownership.** The linked card owns documentation for examples/consumer/build.zig; source remains behavioral authority. Its snapshot hash and extracted declarations are navigation/provenance, not application adoption pins or a complete refinement proof. See [dependency-owned contract](../../../tls-zig/docs/reference/files/examples/consumer/build.zig.md).

**Failure/change obligations.** Changes to examples/consumer/build.zig require review of its actual ownership/failure semantics and this card. Do not replace specific application boundary contracts with mechanically extracted declaration lists.

**Verification.** Run tls-zig/tools/check-docs.py with its declared options and review the named source/test/receipt; application coverage checks establish navigation only.

**Next actionable work.** Follow this card with the canonical examples/consumer/build.zig source and its named tests when changing that dependency boundary.

**Declared surface / navigation:** `examples/consumer/build.zig`; `Responsibility`; `Contract, ownership and failure behavior`; `Next implementation work`; `Verification obligations`; `Dependency edges`; `Declaration-by-declaration work map`; `build — line 11`.


<a id="file-docs-reference-files-examples-consumer-build-zig-zon-md"></a>

## `docs/reference/files/examples/consumer/build.zig.zon.md`

**Responsibility.** Dependency-owned semantic contract and declaration navigation for tls-zig/examples/consumer/build.zig.zon.

**Contract and ownership.** The linked card owns documentation for examples/consumer/build.zig.zon; source remains behavioral authority. Its snapshot hash and extracted declarations are navigation/provenance, not application adoption pins or a complete refinement proof. See [dependency-owned contract](../../../tls-zig/docs/reference/files/examples/consumer/build.zig.zon.md).

**Failure/change obligations.** Changes to examples/consumer/build.zig.zon require review of its actual ownership/failure semantics and this card. Do not replace specific application boundary contracts with mechanically extracted declaration lists.

**Verification.** Run tls-zig/tools/check-docs.py with its declared options and review the named source/test/receipt; application coverage checks establish navigation only.

**Next actionable work.** Follow this card with the canonical examples/consumer/build.zig.zon source and its named tests when changing that dependency boundary.

**Declared surface / navigation:** `examples/consumer/build.zig.zon`; `Responsibility`; `Contract, ownership and failure behavior`; `Next implementation work`; `Verification obligations`.


<a id="file-docs-reference-files-examples-consumer-main-zig-md"></a>

## `docs/reference/files/examples/consumer/main.zig.md`

**Responsibility.** Dependency-owned semantic contract and declaration navigation for tls-zig/examples/consumer/main.zig.

**Contract and ownership.** The linked card owns documentation for examples/consumer/main.zig; source remains behavioral authority. Its snapshot hash and extracted declarations are navigation/provenance, not application adoption pins or a complete refinement proof. See [dependency-owned contract](../../../tls-zig/docs/reference/files/examples/consumer/main.zig.md).

**Failure/change obligations.** Changes to examples/consumer/main.zig require review of its actual ownership/failure semantics and this card. Do not replace specific application boundary contracts with mechanically extracted declaration lists.

**Verification.** Run tls-zig/tools/check-docs.py with its declared options and review the named source/test/receipt; application coverage checks establish navigation only.

**Next actionable work.** Follow this card with the canonical examples/consumer/main.zig source and its named tests when changing that dependency boundary.

**Declared surface / navigation:** `examples/consumer/main.zig`; `Responsibility`; `Contract, ownership and failure behavior`; `Next implementation work`; `Verification obligations`; `Dependency edges`; `Declaration-by-declaration work map`; `demo_open — line 13`; `demo_accept — line 14`; `demo_close — line 15`; `demo_send — line 16`; `demo_recv — line 17`; `demo_poll — line 18`; `demo_now — line 19`; `demo_name — line 20`; `demo_client_ca — line 21`; `demo_sleep — line 22`; `demo_setting — line 23`; `send — line 29`; `recv — line 39`; `run — line 46`; `cancelLater — line 63`; `main — line 68`; `upload — line 112`; `serve — line 174`.


<a id="file-docs-reference-files-examples-consumer-socket-c-md"></a>

## `docs/reference/files/examples/consumer/socket.c.md`

**Responsibility.** Dependency-owned semantic contract and declaration navigation for tls-zig/examples/consumer/socket.c.

**Contract and ownership.** The linked card owns documentation for examples/consumer/socket.c; source remains behavioral authority. Its snapshot hash and extracted declarations are navigation/provenance, not application adoption pins or a complete refinement proof. See [dependency-owned contract](../../../tls-zig/docs/reference/files/examples/consumer/socket.c.md).

**Failure/change obligations.** Changes to examples/consumer/socket.c require review of its actual ownership/failure semantics and this card. Do not replace specific application boundary contracts with mechanically extracted declaration lists.

**Verification.** Run tls-zig/tools/check-docs.py with its declared options and review the named source/test/receipt; application coverage checks establish navigation only.

**Next actionable work.** Follow this card with the canonical examples/consumer/socket.c source and its named tests when changing that dependency boundary.

**Declared surface / navigation:** `examples/consumer/socket.c`; `Responsibility`; `Contract, ownership and failure behavior`; `Next implementation work`; `Verification obligations`; `Declaration-by-declaration work map`; `demo_accept — line 20`; `demo_open — line 53`; `demo_close — line 83`; `demo_send — line 84`; `demo_recv — line 88`; `demo_poll — line 92`; `demo_sleep — line 96`; `demo_setting — line 97`; `demo_now — line 104`; `demo_name — line 105`; `demo_client_ca — line 109`.


<a id="file-docs-reference-files-examples-roundtrip-zig-md"></a>

## `docs/reference/files/examples/roundtrip.zig.md`

**Responsibility.** Dependency-owned semantic contract and declaration navigation for tls-zig/examples/roundtrip.zig.

**Contract and ownership.** The linked card owns documentation for examples/roundtrip.zig; source remains behavioral authority. Its snapshot hash and extracted declarations are navigation/provenance, not application adoption pins or a complete refinement proof. See [dependency-owned contract](../../../tls-zig/docs/reference/files/examples/roundtrip.zig.md).

**Failure/change obligations.** Changes to examples/roundtrip.zig require review of its actual ownership/failure semantics and this card. Do not replace specific application boundary contracts with mechanically extracted declaration lists.

**Verification.** Run tls-zig/tools/check-docs.py with its declared options and review the named source/test/receipt; application coverage checks establish navigation only.

**Next actionable work.** Follow this card with the canonical examples/roundtrip.zig source and its named tests when changing that dependency boundary.

**Declared surface / navigation:** `examples/roundtrip.zig`; `Responsibility`; `Contract, ownership and failure behavior`; `Next implementation work`; `Verification obligations`; `Dependency edges`; `Declaration-by-declaration work map`; `pump — line 15`; `main — line 20`.


<a id="file-docs-reference-files-handoff-shutdown-md-md"></a>

## `docs/reference/files/HANDOFF-shutdown.md.md`

**Responsibility.** Dependency-owned semantic contract and declaration navigation for tls-zig/HANDOFF-shutdown.md.

**Contract and ownership.** The linked card owns documentation for HANDOFF-shutdown.md; source remains behavioral authority. Its snapshot hash and extracted declarations are navigation/provenance, not application adoption pins or a complete refinement proof. See [dependency-owned contract](../../../tls-zig/docs/reference/files/HANDOFF-shutdown.md.md).

**Failure/change obligations.** Changes to HANDOFF-shutdown.md require review of its actual ownership/failure semantics and this card. Do not replace specific application boundary contracts with mechanically extracted declaration lists.

**Verification.** Run tls-zig/tools/check-docs.py with its declared options and review the named source/test/receipt; application coverage checks establish navigation only.

**Next actionable work.** Follow this card with the canonical HANDOFF-shutdown.md source and its named tests when changing that dependency boundary.

**Declared surface / navigation:** `HANDOFF-shutdown.md`; `Responsibility`; `Contract, ownership and failure behavior`; `Next implementation work`; `Verification obligations`.


<a id="file-docs-reference-files-handoff-tcp-consumer-md-md"></a>

## `docs/reference/files/HANDOFF-tcp-consumer.md.md`

**Responsibility.** Dependency-owned semantic contract and declaration navigation for tls-zig/HANDOFF-tcp-consumer.md.

**Contract and ownership.** The linked card owns documentation for HANDOFF-tcp-consumer.md; source remains behavioral authority. Its snapshot hash and extracted declarations are navigation/provenance, not application adoption pins or a complete refinement proof. See [dependency-owned contract](../../../tls-zig/docs/reference/files/HANDOFF-tcp-consumer.md.md).

**Failure/change obligations.** Changes to HANDOFF-tcp-consumer.md require review of its actual ownership/failure semantics and this card. Do not replace specific application boundary contracts with mechanically extracted declaration lists.

**Verification.** Run tls-zig/tools/check-docs.py with its declared options and review the named source/test/receipt; application coverage checks establish navigation only.

**Next actionable work.** Follow this card with the canonical HANDOFF-tcp-consumer.md source and its named tests when changing that dependency boundary.

**Declared surface / navigation:** `HANDOFF-tcp-consumer.md`; `Responsibility`; `Contract, ownership and failure behavior`; `Next implementation work`; `Verification obligations`.


<a id="file-docs-reference-files-host-driver-md-md"></a>

## `docs/reference/files/HOST-DRIVER.md.md`

**Responsibility.** Dependency-owned semantic contract and declaration navigation for tls-zig/HOST-DRIVER.md.

**Contract and ownership.** The linked card owns documentation for HOST-DRIVER.md; source remains behavioral authority. Its snapshot hash and extracted declarations are navigation/provenance, not application adoption pins or a complete refinement proof. See [dependency-owned contract](../../../tls-zig/docs/reference/files/HOST-DRIVER.md.md).

**Failure/change obligations.** Changes to HOST-DRIVER.md require review of its actual ownership/failure semantics and this card. Do not replace specific application boundary contracts with mechanically extracted declaration lists.

**Verification.** Run tls-zig/tools/check-docs.py with its declared options and review the named source/test/receipt; application coverage checks establish navigation only.

**Next actionable work.** Follow this card with the canonical HOST-DRIVER.md source and its named tests when changing that dependency boundary.

**Declared surface / navigation:** `HOST-DRIVER.md`; `Responsibility`; `Contract, ownership and failure behavior`; `Next implementation work`; `Verification obligations`.


<a id="file-docs-reference-files-readme-md-md"></a>

## `docs/reference/files/README.md.md`

**Responsibility.** Dependency-owned semantic contract and declaration navigation for tls-zig/README.md.

**Contract and ownership.** The linked card owns documentation for README.md; source remains behavioral authority. Its snapshot hash and extracted declarations are navigation/provenance, not application adoption pins or a complete refinement proof. See [dependency-owned contract](../../../tls-zig/docs/reference/files/README.md.md).

**Failure/change obligations.** Changes to README.md require review of its actual ownership/failure semantics and this card. Do not replace specific application boundary contracts with mechanically extracted declaration lists.

**Verification.** Run tls-zig/tools/check-docs.py with its declared options and review the named source/test/receipt; application coverage checks establish navigation only.

**Next actionable work.** Follow this card with the canonical README.md source and its named tests when changing that dependency boundary.

**Declared surface / navigation:** `README.md`; `Responsibility`; `Contract, ownership and failure behavior`; `Next implementation work`; `Verification obligations`; `Dependency edges`.


<a id="file-docs-reference-files-source-origin-json-md"></a>

## `docs/reference/files/SOURCE-ORIGIN.json.md`

**Responsibility.** Dependency-owned semantic contract and declaration navigation for tls-zig/SOURCE-ORIGIN.json.

**Contract and ownership.** The linked card owns documentation for SOURCE-ORIGIN.json; source remains behavioral authority. Its snapshot hash and extracted declarations are navigation/provenance, not application adoption pins or a complete refinement proof. See [dependency-owned contract](../../../tls-zig/docs/reference/files/SOURCE-ORIGIN.json.md).

**Failure/change obligations.** Changes to SOURCE-ORIGIN.json require review of its actual ownership/failure semantics and this card. Do not replace specific application boundary contracts with mechanically extracted declaration lists.

**Verification.** Run tls-zig/tools/check-docs.py with its declared options and review the named source/test/receipt; application coverage checks establish navigation only.

**Next actionable work.** Follow this card with the canonical SOURCE-ORIGIN.json source and its named tests when changing that dependency boundary.

**Declared surface / navigation:** `SOURCE-ORIGIN.json`; `Responsibility`; `Contract, ownership and failure behavior`; `Next implementation work`; `Verification obligations`.


<a id="file-docs-reference-files-src-backend-c-md"></a>

## `docs/reference/files/src/backend.c.md`

**Responsibility.** Dependency-owned semantic contract and declaration navigation for tls-zig/src/backend.c.

**Contract and ownership.** The linked card owns documentation for src/backend.c; source remains behavioral authority. Its snapshot hash and extracted declarations are navigation/provenance, not application adoption pins or a complete refinement proof. See [dependency-owned contract](../../../tls-zig/docs/reference/files/src/backend.c.md).

**Failure/change obligations.** Changes to src/backend.c require review of its actual ownership/failure semantics and this card. Do not replace specific application boundary contracts with mechanically extracted declaration lists.

**Verification.** Run tls-zig/tools/check-docs.py with its declared options and review the named source/test/receipt; application coverage checks establish navigation only.

**Next actionable work.** Follow this card with the canonical src/backend.c source and its named tests when changing that dependency boundary.

**Declared surface / navigation:** `src/backend.c`; `Responsibility`; `Contract, ownership and failure behavior`; `Next implementation work`; `Verification obligations`; `Declaration-by-declaration work map`; `no_password — line 32`; `select_alpn — line 36`; `info — line 44`; `result — line 48`; `tz_new — line 59`; `tz_new_with_alpn — line 65`; `tz_free — line 124`; `tz_handshake — line 131`; `tz_feed — line 144`; `tz_drain — line 154`; `tz_read — line 163`; `tz_write — line 171`; `tz_flush — line 177`; `tz_shutdown — line 188`; `tz_eof — line 208`; `tz_verify_error — line 213`; `tz_reason — line 214`; `tz_alert — line 215`; `tz_version — line 216`.


<a id="file-docs-reference-files-src-backend-h-md"></a>

## `docs/reference/files/src/backend.h.md`

**Responsibility.** Dependency-owned semantic contract and declaration navigation for tls-zig/src/backend.h.

**Contract and ownership.** The linked card owns documentation for src/backend.h; source remains behavioral authority. Its snapshot hash and extracted declarations are navigation/provenance, not application adoption pins or a complete refinement proof. See [dependency-owned contract](../../../tls-zig/docs/reference/files/src/backend.h.md).

**Failure/change obligations.** Changes to src/backend.h require review of its actual ownership/failure semantics and this card. Do not replace specific application boundary contracts with mechanically extracted declaration lists.

**Verification.** Run tls-zig/tools/check-docs.py with its declared options and review the named source/test/receipt; application coverage checks establish navigation only.

**Next actionable work.** Follow this card with the canonical src/backend.h source and its named tests when changing that dependency boundary.

**Declared surface / navigation:** `src/backend.h`; `Responsibility`; `Contract, ownership and failure behavior`; `Next implementation work`; `Verification obligations`; `Declaration-by-declaration work map`; `tz_new — line 23`; `tz_new_with_alpn — line 27`; `tz_free — line 30`; `tz_handshake — line 31`; `tz_feed — line 32`; `tz_drain — line 33`; `tz_read — line 34`; `tz_write — line 35`; `tz_flush — line 36`; `tz_shutdown — line 37`; `tz_eof — line 38`; `tz_verify_error — line 39`; `tz_reason — line 40`; `tz_alert — line 41`; `tz_version — line 42`.


<a id="file-docs-reference-files-src-backend-zig-md"></a>

## `docs/reference/files/src/backend.zig.md`

**Responsibility.** Dependency-owned semantic contract and declaration navigation for tls-zig/src/backend.zig.

**Contract and ownership.** The linked card owns documentation for src/backend.zig; source remains behavioral authority. Its snapshot hash and extracted declarations are navigation/provenance, not application adoption pins or a complete refinement proof. See [dependency-owned contract](../../../tls-zig/docs/reference/files/src/backend.zig.md).

**Failure/change obligations.** Changes to src/backend.zig require review of its actual ownership/failure semantics and this card. Do not replace specific application boundary contracts with mechanically extracted declaration lists.

**Verification.** Run tls-zig/tools/check-docs.py with its declared options and review the named source/test/receipt; application coverage checks establish navigation only.

**Next actionable work.** Follow this card with the canonical src/backend.zig source and its named tests when changing that dependency boundary.

**Declared surface / navigation:** `src/backend.zig`; `Responsibility`; `Contract, ownership and failure behavior`; `Next implementation work`; `Verification obligations`; `Declaration-by-declaration work map`; `tz_new — line 14`; `tz_new_with_alpn — line 15`; `tz_free — line 16`; `tz_handshake — line 17`; `tz_feed — line 18`; `tz_drain — line 19`; `tz_read — line 20`; `tz_write — line 21`; `tz_flush — line 22`; `tz_shutdown — line 23`; `tz_eof — line 24`; `tz_verify_error — line 25`; `tz_reason — line 26`; `tz_alert — line 27`; `tz_version — line 28`.


<a id="file-docs-reference-files-src-driver-zig-md"></a>

## `docs/reference/files/src/driver.zig.md`

**Responsibility.** Dependency-owned semantic contract and declaration navigation for tls-zig/src/driver.zig.

**Contract and ownership.** The linked card owns documentation for src/driver.zig; source remains behavioral authority. Its snapshot hash and extracted declarations are navigation/provenance, not application adoption pins or a complete refinement proof. See [dependency-owned contract](../../../tls-zig/docs/reference/files/src/driver.zig.md).

**Failure/change obligations.** Changes to src/driver.zig require review of its actual ownership/failure semantics and this card. Do not replace specific application boundary contracts with mechanically extracted declaration lists.

**Verification.** Run tls-zig/tools/check-docs.py with its declared options and review the named source/test/receipt; application coverage checks establish navigation only.

**Next actionable work.** Follow this card with the canonical src/driver.zig source and its named tests when changing that dependency boundary.

**Declared surface / navigation:** `src/driver.zig`; `Responsibility`; `Contract, ownership and failure behavior`; `Next implementation work`; `Verification obligations`; `Dependency edges`; `Declaration-by-declaration work map`; `init — line 75`; `deinit — line 78`; `cancel — line 83`; `abort — line 88`; `check — line 94`; `idle — line 104`; `begin — line 108`; `beginHandshake — line 118`; `beginWrite — line 124`; `beginRead — line 136`; `beginShutdown — line 141`; `beginFlush — line 148`; `probePeer — line 159`; `step — line 232`; `Public type vocabulary`.


<a id="file-docs-reference-files-src-root-zig-md"></a>

## `docs/reference/files/src/root.zig.md`

**Responsibility.** Dependency-owned semantic contract and declaration navigation for tls-zig/src/root.zig.

**Contract and ownership.** The linked card owns documentation for src/root.zig; source remains behavioral authority. Its snapshot hash and extracted declarations are navigation/provenance, not application adoption pins or a complete refinement proof. See [dependency-owned contract](../../../tls-zig/docs/reference/files/src/root.zig.md).

**Failure/change obligations.** Changes to src/root.zig require review of its actual ownership/failure semantics and this card. Do not replace specific application boundary contracts with mechanically extracted declaration lists.

**Verification.** Run tls-zig/tools/check-docs.py with its declared options and review the named source/test/receipt; application coverage checks establish navigation only.

**Next actionable work.** Follow this card with the canonical src/root.zig source and its named tests when changing that dependency boundary.

**Declared surface / navigation:** `src/root.zig`; `Responsibility`; `Contract, ownership and failure behavior`; `Next implementation work`; `Verification obligations`; `Dependency edges`; `Declaration-by-declaration work map`; `init — line 52`; `ptr — line 89`; `live — line 92`; `status — line 96`; `tick — line 117`; `handshake — line 127`; `feedRecords — line 133`; `drainRecords — line 139`; `readPlaintext — line 145`; `queuePlaintext — line 152`; `flushPlaintext — line 155`; `shutdown — line 160`; `transportEof — line 164`; `diagnostics — line 167`; `cancel — line 172`; `deinit — line 178`; `backendVersion — line 183`; `Public type vocabulary`.


<a id="file-docs-reference-files-tests-driver-zig-md"></a>

## `docs/reference/files/tests/driver.zig.md`

**Responsibility.** Dependency-owned semantic contract and declaration navigation for tls-zig/tests/driver.zig.

**Contract and ownership.** The linked card owns documentation for tests/driver.zig; source remains behavioral authority. Its snapshot hash and extracted declarations are navigation/provenance, not application adoption pins or a complete refinement proof. See [dependency-owned contract](../../../tls-zig/docs/reference/files/tests/driver.zig.md).

**Failure/change obligations.** Changes to tests/driver.zig require review of its actual ownership/failure semantics and this card. Do not replace specific application boundary contracts with mechanically extracted declaration lists.

**Verification.** Run tls-zig/tools/check-docs.py with its declared options and review the named source/test/receipt; application coverage checks establish navigation only.

**Next actionable work.** Follow this card with the canonical tests/driver.zig source and its named tests when changing that dependency boundary.

**Declared surface / navigation:** `tests/driver.zig`; `Responsibility`; `Contract, ownership and failure behavior`; `Next implementation work`; `Verification obligations`; `Dependency edges`; `Declaration-by-declaration work map`; `transport — line 35`; `send — line 38`; `recv — line 54`; `init — line 75`; `deinit — line 82`; `handshake — line 86`; `finish — line 99`; `probe — line 110`; `Executable regression inventory`.


<a id="file-docs-reference-files-tests-fixtures-ca-pem-md"></a>

## `docs/reference/files/tests/fixtures/ca.pem.md`

**Responsibility.** Dependency-owned semantic contract and declaration navigation for tls-zig/tests/fixtures/ca.pem.

**Contract and ownership.** The linked card owns documentation for tests/fixtures/ca.pem; source remains behavioral authority. Its snapshot hash and extracted declarations are navigation/provenance, not application adoption pins or a complete refinement proof. See [dependency-owned contract](../../../tls-zig/docs/reference/files/tests/fixtures/ca.pem.md).

**Failure/change obligations.** Changes to tests/fixtures/ca.pem require review of its actual ownership/failure semantics and this card. Do not replace specific application boundary contracts with mechanically extracted declaration lists.

**Verification.** Run tls-zig/tools/check-docs.py with its declared options and review the named source/test/receipt; application coverage checks establish navigation only.

**Next actionable work.** Follow this card with the canonical tests/fixtures/ca.pem source and its named tests when changing that dependency boundary.

**Declared surface / navigation:** `tests/fixtures/ca.pem`; `Responsibility`; `Contract, ownership and failure behavior`; `Next implementation work`; `Verification obligations`; `Fixture oracle`.


<a id="file-docs-reference-files-tests-fixtures-client-key-md"></a>

## `docs/reference/files/tests/fixtures/client.key.md`

**Responsibility.** Dependency-owned semantic contract and declaration navigation for tls-zig/tests/fixtures/client.key.

**Contract and ownership.** The linked card owns documentation for tests/fixtures/client.key; source remains behavioral authority. Its snapshot hash and extracted declarations are navigation/provenance, not application adoption pins or a complete refinement proof. See [dependency-owned contract](../../../tls-zig/docs/reference/files/tests/fixtures/client.key.md).

**Failure/change obligations.** Changes to tests/fixtures/client.key require review of its actual ownership/failure semantics and this card. Do not replace specific application boundary contracts with mechanically extracted declaration lists.

**Verification.** Run tls-zig/tools/check-docs.py with its declared options and review the named source/test/receipt; application coverage checks establish navigation only.

**Next actionable work.** Follow this card with the canonical tests/fixtures/client.key source and its named tests when changing that dependency boundary.

**Declared surface / navigation:** `tests/fixtures/client.key`; `Responsibility`; `Contract, ownership and failure behavior`; `Next implementation work`; `Verification obligations`; `Fixture oracle`.


<a id="file-docs-reference-files-tests-fixtures-client-pem-md"></a>

## `docs/reference/files/tests/fixtures/client.pem.md`

**Responsibility.** Dependency-owned semantic contract and declaration navigation for tls-zig/tests/fixtures/client.pem.

**Contract and ownership.** The linked card owns documentation for tests/fixtures/client.pem; source remains behavioral authority. Its snapshot hash and extracted declarations are navigation/provenance, not application adoption pins or a complete refinement proof. See [dependency-owned contract](../../../tls-zig/docs/reference/files/tests/fixtures/client.pem.md).

**Failure/change obligations.** Changes to tests/fixtures/client.pem require review of its actual ownership/failure semantics and this card. Do not replace specific application boundary contracts with mechanically extracted declaration lists.

**Verification.** Run tls-zig/tools/check-docs.py with its declared options and review the named source/test/receipt; application coverage checks establish navigation only.

**Next actionable work.** Follow this card with the canonical tests/fixtures/client.pem source and its named tests when changing that dependency boundary.

**Declared surface / navigation:** `tests/fixtures/client.pem`; `Responsibility`; `Contract, ownership and failure behavior`; `Next implementation work`; `Verification obligations`; `Fixture oracle`.


<a id="file-docs-reference-files-tests-fixtures-expired-key-md"></a>

## `docs/reference/files/tests/fixtures/expired.key.md`

**Responsibility.** Dependency-owned semantic contract and declaration navigation for tls-zig/tests/fixtures/expired.key.

**Contract and ownership.** The linked card owns documentation for tests/fixtures/expired.key; source remains behavioral authority. Its snapshot hash and extracted declarations are navigation/provenance, not application adoption pins or a complete refinement proof. See [dependency-owned contract](../../../tls-zig/docs/reference/files/tests/fixtures/expired.key.md).

**Failure/change obligations.** Changes to tests/fixtures/expired.key require review of its actual ownership/failure semantics and this card. Do not replace specific application boundary contracts with mechanically extracted declaration lists.

**Verification.** Run tls-zig/tools/check-docs.py with its declared options and review the named source/test/receipt; application coverage checks establish navigation only.

**Next actionable work.** Follow this card with the canonical tests/fixtures/expired.key source and its named tests when changing that dependency boundary.

**Declared surface / navigation:** `tests/fixtures/expired.key`; `Responsibility`; `Contract, ownership and failure behavior`; `Next implementation work`; `Verification obligations`; `Fixture oracle`.


<a id="file-docs-reference-files-tests-fixtures-expired-pem-md"></a>

## `docs/reference/files/tests/fixtures/expired.pem.md`

**Responsibility.** Dependency-owned semantic contract and declaration navigation for tls-zig/tests/fixtures/expired.pem.

**Contract and ownership.** The linked card owns documentation for tests/fixtures/expired.pem; source remains behavioral authority. Its snapshot hash and extracted declarations are navigation/provenance, not application adoption pins or a complete refinement proof. See [dependency-owned contract](../../../tls-zig/docs/reference/files/tests/fixtures/expired.pem.md).

**Failure/change obligations.** Changes to tests/fixtures/expired.pem require review of its actual ownership/failure semantics and this card. Do not replace specific application boundary contracts with mechanically extracted declaration lists.

**Verification.** Run tls-zig/tools/check-docs.py with its declared options and review the named source/test/receipt; application coverage checks establish navigation only.

**Next actionable work.** Follow this card with the canonical tests/fixtures/expired.pem source and its named tests when changing that dependency boundary.

**Declared surface / navigation:** `tests/fixtures/expired.pem`; `Responsibility`; `Contract, ownership and failure behavior`; `Next implementation work`; `Verification obligations`; `Fixture oracle`.


<a id="file-docs-reference-files-tests-fixtures-other-ca-pem-md"></a>

## `docs/reference/files/tests/fixtures/other-ca.pem.md`

**Responsibility.** Dependency-owned semantic contract and declaration navigation for tls-zig/tests/fixtures/other-ca.pem.

**Contract and ownership.** The linked card owns documentation for tests/fixtures/other-ca.pem; source remains behavioral authority. Its snapshot hash and extracted declarations are navigation/provenance, not application adoption pins or a complete refinement proof. See [dependency-owned contract](../../../tls-zig/docs/reference/files/tests/fixtures/other-ca.pem.md).

**Failure/change obligations.** Changes to tests/fixtures/other-ca.pem require review of its actual ownership/failure semantics and this card. Do not replace specific application boundary contracts with mechanically extracted declaration lists.

**Verification.** Run tls-zig/tools/check-docs.py with its declared options and review the named source/test/receipt; application coverage checks establish navigation only.

**Next actionable work.** Follow this card with the canonical tests/fixtures/other-ca.pem source and its named tests when changing that dependency boundary.

**Declared surface / navigation:** `tests/fixtures/other-ca.pem`; `Responsibility`; `Contract, ownership and failure behavior`; `Next implementation work`; `Verification obligations`; `Fixture oracle`.


<a id="file-docs-reference-files-tests-fixtures-server-key-md"></a>

## `docs/reference/files/tests/fixtures/server.key.md`

**Responsibility.** Dependency-owned semantic contract and declaration navigation for tls-zig/tests/fixtures/server.key.

**Contract and ownership.** The linked card owns documentation for tests/fixtures/server.key; source remains behavioral authority. Its snapshot hash and extracted declarations are navigation/provenance, not application adoption pins or a complete refinement proof. See [dependency-owned contract](../../../tls-zig/docs/reference/files/tests/fixtures/server.key.md).

**Failure/change obligations.** Changes to tests/fixtures/server.key require review of its actual ownership/failure semantics and this card. Do not replace specific application boundary contracts with mechanically extracted declaration lists.

**Verification.** Run tls-zig/tools/check-docs.py with its declared options and review the named source/test/receipt; application coverage checks establish navigation only.

**Next actionable work.** Follow this card with the canonical tests/fixtures/server.key source and its named tests when changing that dependency boundary.

**Declared surface / navigation:** `tests/fixtures/server.key`; `Responsibility`; `Contract, ownership and failure behavior`; `Next implementation work`; `Verification obligations`; `Fixture oracle`.


<a id="file-docs-reference-files-tests-fixtures-server-pem-md"></a>

## `docs/reference/files/tests/fixtures/server.pem.md`

**Responsibility.** Dependency-owned semantic contract and declaration navigation for tls-zig/tests/fixtures/server.pem.

**Contract and ownership.** The linked card owns documentation for tests/fixtures/server.pem; source remains behavioral authority. Its snapshot hash and extracted declarations are navigation/provenance, not application adoption pins or a complete refinement proof. See [dependency-owned contract](../../../tls-zig/docs/reference/files/tests/fixtures/server.pem.md).

**Failure/change obligations.** Changes to tests/fixtures/server.pem require review of its actual ownership/failure semantics and this card. Do not replace specific application boundary contracts with mechanically extracted declaration lists.

**Verification.** Run tls-zig/tools/check-docs.py with its declared options and review the named source/test/receipt; application coverage checks establish navigation only.

**Next actionable work.** Follow this card with the canonical tests/fixtures/server.pem source and its named tests when changing that dependency boundary.

**Declared surface / navigation:** `tests/fixtures/server.pem`; `Responsibility`; `Contract, ownership and failure behavior`; `Next implementation work`; `Verification obligations`; `Fixture oracle`.


<a id="file-docs-reference-files-tests-fixtures-wrong-purpose-key-md"></a>

## `docs/reference/files/tests/fixtures/wrong-purpose.key.md`

**Responsibility.** Dependency-owned semantic contract and declaration navigation for tls-zig/tests/fixtures/wrong-purpose.key.

**Contract and ownership.** The linked card owns documentation for tests/fixtures/wrong-purpose.key; source remains behavioral authority. Its snapshot hash and extracted declarations are navigation/provenance, not application adoption pins or a complete refinement proof. See [dependency-owned contract](../../../tls-zig/docs/reference/files/tests/fixtures/wrong-purpose.key.md).

**Failure/change obligations.** Changes to tests/fixtures/wrong-purpose.key require review of its actual ownership/failure semantics and this card. Do not replace specific application boundary contracts with mechanically extracted declaration lists.

**Verification.** Run tls-zig/tools/check-docs.py with its declared options and review the named source/test/receipt; application coverage checks establish navigation only.

**Next actionable work.** Follow this card with the canonical tests/fixtures/wrong-purpose.key source and its named tests when changing that dependency boundary.

**Declared surface / navigation:** `tests/fixtures/wrong-purpose.key`; `Responsibility`; `Contract, ownership and failure behavior`; `Next implementation work`; `Verification obligations`; `Fixture oracle`.


<a id="file-docs-reference-files-tests-fixtures-wrong-purpose-pem-md"></a>

## `docs/reference/files/tests/fixtures/wrong-purpose.pem.md`

**Responsibility.** Dependency-owned semantic contract and declaration navigation for tls-zig/tests/fixtures/wrong-purpose.pem.

**Contract and ownership.** The linked card owns documentation for tests/fixtures/wrong-purpose.pem; source remains behavioral authority. Its snapshot hash and extracted declarations are navigation/provenance, not application adoption pins or a complete refinement proof. See [dependency-owned contract](../../../tls-zig/docs/reference/files/tests/fixtures/wrong-purpose.pem.md).

**Failure/change obligations.** Changes to tests/fixtures/wrong-purpose.pem require review of its actual ownership/failure semantics and this card. Do not replace specific application boundary contracts with mechanically extracted declaration lists.

**Verification.** Run tls-zig/tools/check-docs.py with its declared options and review the named source/test/receipt; application coverage checks establish navigation only.

**Next actionable work.** Follow this card with the canonical tests/fixtures/wrong-purpose.pem source and its named tests when changing that dependency boundary.

**Declared surface / navigation:** `tests/fixtures/wrong-purpose.pem`; `Responsibility`; `Contract, ownership and failure behavior`; `Next implementation work`; `Verification obligations`; `Fixture oracle`.


<a id="file-docs-reference-files-tests-transport-zig-md"></a>

## `docs/reference/files/tests/transport.zig.md`

**Responsibility.** Dependency-owned semantic contract and declaration navigation for tls-zig/tests/transport.zig.

**Contract and ownership.** The linked card owns documentation for tests/transport.zig; source remains behavioral authority. Its snapshot hash and extracted declarations are navigation/provenance, not application adoption pins or a complete refinement proof. See [dependency-owned contract](../../../tls-zig/docs/reference/files/tests/transport.zig.md).

**Failure/change obligations.** Changes to tests/transport.zig require review of its actual ownership/failure semantics and this card. Do not replace specific application boundary contracts with mechanically extracted declaration lists.

**Verification.** Run tls-zig/tools/check-docs.py with its declared options and review the named source/test/receipt; application coverage checks establish navigation only.

**Next actionable work.** Follow this card with the canonical tests/transport.zig source and its named tests when changing that dependency boundary.

**Declared surface / navigation:** `tests/transport.zig`; `Responsibility`; `Contract, ownership and failure behavior`; `Next implementation work`; `Verification obligations`; `Dependency edges`; `Declaration-by-declaration work map`; `clientConfig — line 68`; `serverConfig — line 71`; `transfer — line 74`; `handshake — line 80`; `connected — line 90`; `Executable regression inventory`.


<a id="file-docs-reference-files-tools-build-openssl-sh-md"></a>

## `docs/reference/files/tools/build-openssl.sh.md`

**Responsibility.** Dependency-owned semantic contract and declaration navigation for tls-zig/tools/build-openssl.sh.

**Contract and ownership.** The linked card owns documentation for tools/build-openssl.sh; source remains behavioral authority. Its snapshot hash and extracted declarations are navigation/provenance, not application adoption pins or a complete refinement proof. See [dependency-owned contract](../../../tls-zig/docs/reference/files/tools/build-openssl.sh.md).

**Failure/change obligations.** Changes to tools/build-openssl.sh require review of its actual ownership/failure semantics and this card. Do not replace specific application boundary contracts with mechanically extracted declaration lists.

**Verification.** Run tls-zig/tools/check-docs.py with its declared options and review the named source/test/receipt; application coverage checks establish navigation only.

**Next actionable work.** Follow this card with the canonical tools/build-openssl.sh source and its named tests when changing that dependency boundary.

**Declared surface / navigation:** `tools/build-openssl.sh`; `Responsibility`; `Contract, ownership and failure behavior`; `Next implementation work`; `Verification obligations`; `Revision-2 callback capability evidence`.


<a id="file-docs-reference-files-tools-check-docs-py-md"></a>

## `docs/reference/files/tools/check-docs.py.md`

**Responsibility.** Dependency-owned semantic contract and declaration navigation for tls-zig/tools/check-docs.py.

**Contract and ownership.** The linked card owns documentation for tools/check-docs.py; source remains behavioral authority. Its snapshot hash and extracted declarations are navigation/provenance, not application adoption pins or a complete refinement proof. See [dependency-owned contract](../../../tls-zig/docs/reference/files/tools/check-docs.py.md).

**Failure/change obligations.** Changes to tools/check-docs.py require review of its actual ownership/failure semantics and this card. Do not replace specific application boundary contracts with mechanically extracted declaration lists.

**Verification.** Run tls-zig/tools/check-docs.py with its declared options and review the named source/test/receipt; application coverage checks establish navigation only.

**Next actionable work.** Follow this card with the canonical tools/check-docs.py source and its named tests when changing that dependency boundary.

**Declared surface / navigation:** `tools/check-docs.py`; `Responsibility and operational contract`; `Declaration-by-declaration obligations`; `digest — line 21`; `safe — line 25`; `universe — line 38`; `check — line 49`; `check_contents — line 57`; `self_test — line 133`; `main — line 180`; `Verification and next work`.


<a id="file-docs-reference-files-tools-check-event-model-py-md"></a>

## `docs/reference/files/tools/check-event-model.py.md`

**Responsibility.** Dependency-owned semantic/source navigation card for tools/check-event-model.py.

**Contract and ownership.** Canonical explanatory card; actual source remains behavioral authority, with extracted declarations used for navigation only. See [owner contract](../../../tls-zig/docs/reference/files/tools/check-event-model.py.md).

**Failure/change obligations.** Preserve planned, implemented and historically observed status. Source changes require a new owner receipt; no silent application trust/pin adoption.

**Verification.** Review the named tool, its inputs/outputs/failure conditions and owner tests; source-card coverage is not proof of semantics.

**Next actionable work.** Continue through the owning dependency work package; application policy and credentials stay in LAN Audio.

**Declared surface / navigation:** `tools/check-event-model.py`; `Responsibility and operational contract`; `Declaration-by-declaration obligations`; `State — line 14`; `successors — line 24`; `invariant — line 52`; `transition_invariant — line 63`; `explore — line 71`; `main — line 86`; `Verification and next work`.


<a id="file-docs-reference-files-tools-check-models-py-md"></a>

## `docs/reference/files/tools/check-models.py.md`

**Responsibility.** Dependency-owned semantic contract and declaration navigation for tls-zig/tools/check-models.py.

**Contract and ownership.** The linked card owns documentation for tools/check-models.py; source remains behavioral authority. Its snapshot hash and extracted declarations are navigation/provenance, not application adoption pins or a complete refinement proof. See [dependency-owned contract](../../../tls-zig/docs/reference/files/tools/check-models.py.md).

**Failure/change obligations.** Changes to tools/check-models.py require review of its actual ownership/failure semantics and this card. Do not replace specific application boundary contracts with mechanically extracted declaration lists.

**Verification.** Run tls-zig/tools/check-docs.py with its declared options and review the named source/test/receipt; application coverage checks establish navigation only.

**Next actionable work.** Follow this card with the canonical tools/check-models.py source and its named tests when changing that dependency boundary.

**Declared surface / navigation:** `tools/check-models.py`; `Responsibility`; `Contract, ownership and failure behavior`; `Next implementation work`; `Verification obligations`; `Declaration-by-declaration work map`; `explore — line 6`; `ack_model — line 22`; `transitions — line 24`; `custody_model — line 38`; `transitions — line 41`; `shutdown_model — line 60`; `transitions — line 62`; `main — line 79`.


<a id="file-docs-reference-files-tools-check-plan-py-md"></a>

## `docs/reference/files/tools/check-plan.py.md`

**Responsibility.** Dependency-owned semantic/source navigation card for tools/check-plan.py.

**Contract and ownership.** Canonical explanatory card; actual source remains behavioral authority, with extracted declarations used for navigation only. See [owner contract](../../../tls-zig/docs/reference/files/tools/check-plan.py.md).

**Failure/change obligations.** Preserve planned, implemented and historically observed status. Source changes require a new owner receipt; no silent application trust/pin adoption.

**Verification.** Review the named tool, its inputs/outputs/failure conditions and owner tests; source-card coverage is not proof of semantics.

**Next actionable work.** Continue through the owning dependency work package; application policy and credentials stay in LAN Audio.

**Declared surface / navigation:** `tools/check-plan.py`; `Responsibility and limits`; `Declaration-by-declaration contract`; `relative — line 17`; `validate — line 27`; `fingerprint — line 78`; `checked_file — line 84`; `evidence_check — line 97`; `local_check — line 186`; `self_test — line 221`; `main — line 243`; `Verification`.


<a id="file-docs-reference-files-tools-fetch-openssl-py-md"></a>

## `docs/reference/files/tools/fetch-openssl.py.md`

**Responsibility.** Dependency-owned semantic contract and declaration navigation for tls-zig/tools/fetch-openssl.py.

**Contract and ownership.** The linked card owns documentation for tools/fetch-openssl.py; source remains behavioral authority. Its snapshot hash and extracted declarations are navigation/provenance, not application adoption pins or a complete refinement proof. See [dependency-owned contract](../../../tls-zig/docs/reference/files/tools/fetch-openssl.py.md).

**Failure/change obligations.** Changes to tools/fetch-openssl.py require review of its actual ownership/failure semantics and this card. Do not replace specific application boundary contracts with mechanically extracted declaration lists.

**Verification.** Run tls-zig/tools/check-docs.py with its declared options and review the named source/test/receipt; application coverage checks establish navigation only.

**Next actionable work.** Follow this card with the canonical tools/fetch-openssl.py source and its named tests when changing that dependency boundary.

**Declared surface / navigation:** `tools/fetch-openssl.py`; `Responsibility`; `Contract, ownership and failure behavior`; `Next implementation work`; `Verification obligations`.


<a id="file-docs-reference-files-tools-interop-py-md"></a>

## `docs/reference/files/tools/interop.py.md`

**Responsibility.** Dependency-owned semantic contract and declaration navigation for tls-zig/tools/interop.py.

**Contract and ownership.** The linked card owns documentation for tools/interop.py; source remains behavioral authority. Its snapshot hash and extracted declarations are navigation/provenance, not application adoption pins or a complete refinement proof. See [dependency-owned contract](../../../tls-zig/docs/reference/files/tools/interop.py.md).

**Failure/change obligations.** Changes to tools/interop.py require review of its actual ownership/failure semantics and this card. Do not replace specific application boundary contracts with mechanically extracted declaration lists.

**Verification.** Run tls-zig/tools/check-docs.py with its declared options and review the named source/test/receipt; application coverage checks establish navigation only.

**Next actionable work.** Follow this card with the canonical tools/interop.py source and its named tests when changing that dependency boundary.

**Declared surface / navigation:** `tools/interop.py`; `Responsibility`; `Contract, ownership and failure behavior`; `Next implementation work`; `Verification obligations`; `Declaration-by-declaration work map`; `__init__ — line 32`; `close — line 37`; `drain — line 40`; `feed — line 44`; `read — line 48`; `python_peer — line 53`; `exchange — line 67`; `connect — line 76`; `case — line 95`; `final_data_during_shutdown — line 162`.


<a id="file-docs-reference-files-tools-make-fixtures-py-md"></a>

## `docs/reference/files/tools/make_fixtures.py.md`

**Responsibility.** Dependency-owned semantic contract and declaration navigation for tls-zig/tools/make_fixtures.py.

**Contract and ownership.** The linked card owns documentation for tools/make_fixtures.py; source remains behavioral authority. Its snapshot hash and extracted declarations are navigation/provenance, not application adoption pins or a complete refinement proof. See [dependency-owned contract](../../../tls-zig/docs/reference/files/tools/make_fixtures.py.md).

**Failure/change obligations.** Changes to tools/make_fixtures.py require review of its actual ownership/failure semantics and this card. Do not replace specific application boundary contracts with mechanically extracted declaration lists.

**Verification.** Run tls-zig/tools/check-docs.py with its declared options and review the named source/test/receipt; application coverage checks establish navigation only.

**Next actionable work.** Follow this card with the canonical tools/make_fixtures.py source and its named tests when changing that dependency boundary.

**Declared surface / navigation:** `tools/make_fixtures.py`; `Responsibility`; `Contract, ownership and failure behavior`; `Next implementation work`; `Verification obligations`; `Declaration-by-declaration work map`; `issue — line 18`.


<a id="file-docs-reference-files-tools-pin-backend-py-md"></a>

## `docs/reference/files/tools/pin-backend.py.md`

**Responsibility.** Dependency-owned semantic contract and declaration navigation for tls-zig/tools/pin-backend.py.

**Contract and ownership.** The linked card owns documentation for tools/pin-backend.py; source remains behavioral authority. Its snapshot hash and extracted declarations are navigation/provenance, not application adoption pins or a complete refinement proof. See [dependency-owned contract](../../../tls-zig/docs/reference/files/tools/pin-backend.py.md).

**Failure/change obligations.** Changes to tools/pin-backend.py require review of its actual ownership/failure semantics and this card. Do not replace specific application boundary contracts with mechanically extracted declaration lists.

**Verification.** Run tls-zig/tools/check-docs.py with its declared options and review the named source/test/receipt; application coverage checks establish navigation only.

**Next actionable work.** Follow this card with the canonical tools/pin-backend.py source and its named tests when changing that dependency boundary.

**Declared surface / navigation:** `tools/pin-backend.py`; `Responsibility`; `Contract, ownership and failure behavior`; `Next implementation work`; `Verification obligations`; `Declaration-by-declaration work map`; `sha256 — line 12`.


<a id="file-docs-reference-files-tools-probe-quic-tls-c-md"></a>

## `docs/reference/files/tools/probe-quic-tls.c.md`

**Responsibility.** Dependency-owned semantic/source navigation card for tools/probe-quic-tls.c.

**Contract and ownership.** Canonical explanatory card; actual source remains behavioral authority, with extracted declarations used for navigation only. See [owner contract](../../../tls-zig/docs/reference/files/tools/probe-quic-tls.c.md).

**Failure/change obligations.** Preserve planned, implemented and historically observed status. Source changes require a new owner receipt; no silent application trust/pin adoption.

**Verification.** Review the named tool, its inputs/outputs/failure conditions and owner tests; source-card coverage is not proof of semantics.

**Next actionable work.** Continue through the owning dependency work package; application policy and credentials stay in LAN Audio.

**Declared surface / navigation:** `tools/probe-quic-tls.c`; `Responsibility and operational contract`; `Declaration-by-declaration obligations`; `send_crypto — line 16`; `receive_crypto — line 32`; `release_crypto — line 40`; `yield_secret — line 46`; `peer_parameters — line 53`; `alert — line 59`; `main — line 74`; `Data and callback dispatch`; `Verification and next work`.


<a id="file-docs-reference-files-tools-probe-quic-tls-py-md"></a>

## `docs/reference/files/tools/probe-quic-tls.py.md`

**Responsibility.** Dependency-owned semantic/source navigation card for tools/probe-quic-tls.py.

**Contract and ownership.** Canonical explanatory card; actual source remains behavioral authority, with extracted declarations used for navigation only. See [owner contract](../../../tls-zig/docs/reference/files/tools/probe-quic-tls.py.md).

**Failure/change obligations.** Preserve planned, implemented and historically observed status. Source changes require a new owner receipt; no silent application trust/pin adoption.

**Verification.** Review the named tool, its inputs/outputs/failure conditions and owner tests; source-card coverage is not proof of semantics.

**Next actionable work.** Continue through the owning dependency work package; application policy and credentials stay in LAN Audio.

**Declared surface / navigation:** `tools/probe-quic-tls.py`; `Responsibility and operational contract`; `Declaration-by-declaration obligations`; `digest — line 19`; `run — line 23`; `main — line 82`; `Verification and next work`.


<a id="file-docs-reference-files-tools-qualify-ps1-md"></a>

## `docs/reference/files/tools/qualify.ps1.md`

**Responsibility.** Dependency-owned semantic contract and declaration navigation for tls-zig/tools/qualify.ps1.

**Contract and ownership.** The linked card owns documentation for tools/qualify.ps1; source remains behavioral authority. Its snapshot hash and extracted declarations are navigation/provenance, not application adoption pins or a complete refinement proof. See [dependency-owned contract](../../../tls-zig/docs/reference/files/tools/qualify.ps1.md).

**Failure/change obligations.** Changes to tools/qualify.ps1 require review of its actual ownership/failure semantics and this card. Do not replace specific application boundary contracts with mechanically extracted declaration lists.

**Verification.** Run tls-zig/tools/check-docs.py with its declared options and review the named source/test/receipt; application coverage checks establish navigation only.

**Next actionable work.** Follow this card with the canonical tools/qualify.ps1 source and its named tests when changing that dependency boundary.

**Declared surface / navigation:** `tools/qualify.ps1`; `Responsibility`; `Contract, ownership and failure behavior`; `Next implementation work`; `Verification obligations`.


<a id="file-docs-reference-files-tools-tcp-interop-py-md"></a>

## `docs/reference/files/tools/tcp_interop.py.md`

**Responsibility.** Dependency-owned semantic contract and declaration navigation for tls-zig/tools/tcp_interop.py.

**Contract and ownership.** The linked card owns documentation for tools/tcp_interop.py; source remains behavioral authority. Its snapshot hash and extracted declarations are navigation/provenance, not application adoption pins or a complete refinement proof. See [dependency-owned contract](../../../tls-zig/docs/reference/files/tools/tcp_interop.py.md).

**Failure/change obligations.** Changes to tools/tcp_interop.py require review of its actual ownership/failure semantics and this card. Do not replace specific application boundary contracts with mechanically extracted declaration lists.

**Verification.** Run tls-zig/tools/check-docs.py with its declared options and review the named source/test/receipt; application coverage checks establish navigation only.

**Next actionable work.** Follow this card with the canonical tools/tcp_interop.py source and its named tests when changing that dependency boundary.

**Declared surface / navigation:** `tools/tcp_interop.py`; `Responsibility`; `Contract, ownership and failure behavior`; `Next implementation work`; `Verification obligations`; `Declaration-by-declaration work map`; `case — line 14`; `serve — line 25`.


<a id="file-docs-reference-files-tools-tcp-server-interop-py-md"></a>

## `docs/reference/files/tools/tcp_server_interop.py.md`

**Responsibility.** Dependency-owned semantic contract and declaration navigation for tls-zig/tools/tcp_server_interop.py.

**Contract and ownership.** The linked card owns documentation for tools/tcp_server_interop.py; source remains behavioral authority. Its snapshot hash and extracted declarations are navigation/provenance, not application adoption pins or a complete refinement proof. See [dependency-owned contract](../../../tls-zig/docs/reference/files/tools/tcp_server_interop.py.md).

**Failure/change obligations.** Changes to tools/tcp_server_interop.py require review of its actual ownership/failure semantics and this card. Do not replace specific application boundary contracts with mechanically extracted declaration lists.

**Verification.** Run tls-zig/tools/check-docs.py with its declared options and review the named source/test/receipt; application coverage checks establish navigation only.

**Next actionable work.** Follow this card with the canonical tools/tcp_server_interop.py source and its named tests when changing that dependency boundary.

**Declared surface / navigation:** `tools/tcp_server_interop.py`; `Responsibility`; `Contract, ownership and failure behavior`; `Next implementation work`; `Verification obligations`; `Declaration-by-declaration work map`; `case — line 16`.


<a id="file-docs-reference-files-tools-tcp-upload-interop-py-md"></a>

## `docs/reference/files/tools/tcp_upload_interop.py.md`

**Responsibility.** Dependency-owned semantic contract and declaration navigation for tls-zig/tools/tcp_upload_interop.py.

**Contract and ownership.** The linked card owns documentation for tools/tcp_upload_interop.py; source remains behavioral authority. Its snapshot hash and extracted declarations are navigation/provenance, not application adoption pins or a complete refinement proof. See [dependency-owned contract](../../../tls-zig/docs/reference/files/tools/tcp_upload_interop.py.md).

**Failure/change obligations.** Changes to tools/tcp_upload_interop.py require review of its actual ownership/failure semantics and this card. Do not replace specific application boundary contracts with mechanically extracted declaration lists.

**Verification.** Run tls-zig/tools/check-docs.py with its declared options and review the named source/test/receipt; application coverage checks establish navigation only.

**Next actionable work.** Follow this card with the canonical tools/tcp_upload_interop.py source and its named tests when changing that dependency boundary.

**Declared surface / navigation:** `tools/tcp_upload_interop.py`; `Responsibility`; `Contract, ownership and failure behavior`; `Next implementation work`; `Verification obligations`; `Declaration-by-declaration work map`; `case — line 15`; `serve — line 27`.


<a id="file-docs-reference-files-tools-test-openssl-sh-md"></a>

## `docs/reference/files/tools/test-openssl.sh.md`

**Responsibility.** Dependency-owned semantic contract and declaration navigation for tls-zig/tools/test-openssl.sh.

**Contract and ownership.** The linked card owns documentation for tools/test-openssl.sh; source remains behavioral authority. Its snapshot hash and extracted declarations are navigation/provenance, not application adoption pins or a complete refinement proof. See [dependency-owned contract](../../../tls-zig/docs/reference/files/tools/test-openssl.sh.md).

**Failure/change obligations.** Changes to tools/test-openssl.sh require review of its actual ownership/failure semantics and this card. Do not replace specific application boundary contracts with mechanically extracted declaration lists.

**Verification.** Run tls-zig/tools/check-docs.py with its declared options and review the named source/test/receipt; application coverage checks establish navigation only.

**Next actionable work.** Follow this card with the canonical tools/test-openssl.sh source and its named tests when changing that dependency boundary.

**Declared surface / navigation:** `tools/test-openssl.sh`; `Responsibility`; `Contract, ownership and failure behavior`; `Next implementation work`; `Verification obligations`.


<a id="file-docs-reference-files-tools-test-plan-lifecycle-py-md"></a>

## `docs/reference/files/tools/test-plan-lifecycle.py.md`

**Responsibility.** Dependency-owned semantic/source navigation card for tools/test-plan-lifecycle.py.

**Contract and ownership.** Canonical explanatory card; actual source remains behavioral authority, with extracted declarations used for navigation only. See [owner contract](../../../tls-zig/docs/reference/files/tools/test-plan-lifecycle.py.md).

**Failure/change obligations.** Preserve planned, implemented and historically observed status. Source changes require a new owner receipt; no silent application trust/pin adoption.

**Verification.** Review the named tool, its inputs/outputs/failure conditions and owner tests; source-card coverage is not proof of semantics.

**Next actionable work.** Continue through the owning dependency work package; application policy and credentials stay in LAN Audio.

**Declared surface / navigation:** `tools/test-plan-lifecycle.py`; `Responsibility and limits`; `Declaration-by-declaration contract`; `digest — line 15`; `write — line 20`; `fixture — line 26`; `verify — line 55`; `main — line 61`; `Verification`.


<a id="file-docs-reference-standards-md"></a>

## `docs/reference/standards.md`

**Responsibility.** Dependency-owned authored architecture, guide, model or navigation artifact: Primary standards and provider references.

**Contract and ownership.** Canonical dependency documentation or evidence for this named subject; retain implemented/proposed/historical distinctions and its precise source/target scope. The application imports this navigation, not a duplicate implementation or new trust input. See [dependency-owned contract](../../../tls-zig/docs/reference/standards.md).

**Failure/change obligations.** Local documentation integrity does not establish production readiness, host availability or unbounded mathematical correctness. Review the document itself before adopting a behavioral claim.

**Verification.** Run tls-zig/tools/check-docs.py with its declared options and review the named source/test/receipt; application coverage checks establish navigation only.

**Next actionable work.** Maintain this subject with its owning TLS work order and artifact register; coordinate application-relevant API/identity/platform changes with the consumer.

**Declared surface / navigation:** `Primary standards and provider references`; `Revision-2 callback capability evidence`.


<a id="file-docs-roadmap-completion-protocol-md"></a>

## `docs/roadmap/completion-protocol.md`

**Responsibility.** Evidence requirements for transitioning a planned file to complete.

**Contract and ownership.** Separates source existence, implementation, actual accepted test runs and dependency completion; binds obligations, environment, source scope and logs. See [owner contract](../../../tls-zig/docs/roadmap/completion-protocol.md).

**Failure/change obligations.** Preserve planned, implemented and historically observed status. Source changes require a new owner receipt; no silent application trust/pin adoption.

**Verification.** Use schema-2 checker plus substantive review; hashes certify observed bytes, not test truth or complete semantic scope.

**Next actionable work.** Continue through the owning dependency work package; application policy and credentials stay in LAN Audio.

**Declared surface / navigation:** `Work lifecycle and completion evidence, schema 2`; `States`; `Receipt location and required fields`; `Exact authoring procedure`.


<a id="file-docs-roadmap-decision-register-md"></a>

## `docs/roadmap/decision-register.md`

**Responsibility.** Owner decisions and unresolved implementation facts.

**Contract and ownership.** Keeps accepted/proposed/open choices, their affected work and required evidence visible before implementation. See [owner contract](../../../tls-zig/docs/roadmap/decision-register.md).

**Failure/change obligations.** Preserve planned, implemented and historically observed status. Source changes require a new owner receipt; no silent application trust/pin adoption.

**Verification.** Resolve each decision through its stated evidence gate; do not treat a numbered decision as an existing API.

**Next actionable work.** Continue through the owning dependency work package; application policy and credentials stay in LAN Audio.

**Declared surface / navigation:** `Decision register before implementation`; `D08 independent sparse-number oracle`; `How to resolve an experiment`.


<a id="file-docs-roadmap-files-bench-engine-zig-md"></a>

## `docs/roadmap/files/bench/engine.zig.md`

**Responsibility.** Proposed dependency implementation card for bench/engine.zig; the path is a plan, not an implemented file.

**Contract and ownership.** Defines intended responsibility, prerequisites, ownership and verification for this named future module. Existing public records APIs and product policy boundaries remain in force. See [dependency-owned contract](../../../tls-zig/docs/roadmap/files/bench/engine.zig.md).

**Failure/change obligations.** Do not create an empty stub or promote future APIs to supported behavior because a card exists. Native/QUIC/portability claims need target-specific implementation evidence.

**Verification.** Run tls-zig/tools/check-docs.py with its declared options and review the named source/test/receipt; application coverage checks establish navigation only.

**Next actionable work.** Implement this card only when its dependency-ready milestone is selected, with its real caller and independent positive/negative tests.

**Declared surface / navigation:** `Planned bench/engine.zig`; `Responsibility and boundary`; `Invariants, data ownership and errors`; `Construction sequence`; `Acceptance cases`; `Exact work package T14`; `Observable acceptance obligations`; `Lifecycle and evidence`.


<a id="file-docs-roadmap-files-build-backend-zig-md"></a>

## `docs/roadmap/files/build/backend.zig.md`

**Responsibility.** Proposed dependency implementation card for build/backend.zig; the path is a plan, not an implemented file.

**Contract and ownership.** Defines intended responsibility, prerequisites, ownership and verification for this named future module. Existing public records APIs and product policy boundaries remain in force. See [dependency-owned contract](../../../tls-zig/docs/roadmap/files/build/backend.zig.md).

**Failure/change obligations.** Do not create an empty stub or promote future APIs to supported behavior because a card exists. Native/QUIC/portability claims need target-specific implementation evidence.

**Verification.** Run tls-zig/tools/check-docs.py with its declared options and review the named source/test/receipt; application coverage checks establish navigation only.

**Next actionable work.** Implement this card only when its dependency-ready milestone is selected, with its real caller and independent positive/negative tests.

**Declared surface / navigation:** `Planned build/backend.zig`; `Responsibility and boundary`; `Invariants, data ownership and errors`; `Construction sequence`; `Acceptance cases`; `Exact work package T07`; `Observable acceptance obligations`; `Lifecycle and evidence`; `Ecosystem boundary acceptance`.


<a id="file-docs-roadmap-files-examples-consumer-socket-posix-c-md"></a>

## `docs/roadmap/files/examples/consumer/socket_posix.c.md`

**Responsibility.** Proposed dependency implementation card for examples/consumer/socket_posix.c; the path is a plan, not an implemented file.

**Contract and ownership.** Defines intended responsibility, prerequisites, ownership and verification for this named future module. Existing public records APIs and product policy boundaries remain in force. See [dependency-owned contract](../../../tls-zig/docs/roadmap/files/examples/consumer/socket_posix.c.md).

**Failure/change obligations.** Do not create an empty stub or promote future APIs to supported behavior because a card exists. Native/QUIC/portability claims need target-specific implementation evidence.

**Verification.** Run tls-zig/tools/check-docs.py with its declared options and review the named source/test/receipt; application coverage checks establish navigation only.

**Next actionable work.** Implement this card only when its dependency-ready milestone is selected, with its real caller and independent positive/negative tests.

**Declared surface / navigation:** `Planned examples/consumer/socket_posix.c`; `Responsibility and boundary`; `Invariants, data ownership and errors`; `Construction sequence`; `Acceptance cases`; `Exact work package T08`; `Observable acceptance obligations`; `Lifecycle and evidence`.


<a id="file-docs-roadmap-files-src-backend-quic-c-md"></a>

## `docs/roadmap/files/src/backend/quic.c.md`

**Responsibility.** Proposed dependency implementation card for src/backend/quic.c; the path is a plan, not an implemented file.

**Contract and ownership.** Defines intended responsibility, prerequisites, ownership and verification for this named future module. Existing public records APIs and product policy boundaries remain in force. See [dependency-owned contract](../../../tls-zig/docs/roadmap/files/src/backend/quic.c.md).

**Failure/change obligations.** Do not create an empty stub or promote future APIs to supported behavior because a card exists. Native/QUIC/portability claims need target-specific implementation evidence.

**Verification.** Run tls-zig/tools/check-docs.py with its declared options and review the named source/test/receipt; application coverage checks establish navigation only.

**Next actionable work.** Implement this card only when its dependency-ready milestone is selected, with its real caller and independent positive/negative tests.

**Declared surface / navigation:** `Planned src/backend/quic.c`; `Responsibility and boundary`; `Invariants, data ownership and errors`; `Construction sequence`; `Acceptance cases`; `Exact work package T04`; `Observable acceptance obligations`; `Lifecycle and evidence`.


<a id="file-docs-roadmap-files-src-backend-quic-h-md"></a>

## `docs/roadmap/files/src/backend/quic.h.md`

**Responsibility.** Proposed dependency implementation card for src/backend/quic.h; the path is a plan, not an implemented file.

**Contract and ownership.** Defines intended responsibility, prerequisites, ownership and verification for this named future module. Existing public records APIs and product policy boundaries remain in force. See [dependency-owned contract](../../../tls-zig/docs/roadmap/files/src/backend/quic.h.md).

**Failure/change obligations.** Do not create an empty stub or promote future APIs to supported behavior because a card exists. Native/QUIC/portability claims need target-specific implementation evidence.

**Verification.** Run tls-zig/tools/check-docs.py with its declared options and review the named source/test/receipt; application coverage checks establish navigation only.

**Next actionable work.** Implement this card only when its dependency-ready milestone is selected, with its real caller and independent positive/negative tests.

**Declared surface / navigation:** `Planned src/backend/quic.h`; `Responsibility and boundary`; `Invariants, data ownership and errors`; `Construction sequence`; `Acceptance cases`; `Exact work package T05`; `Observable acceptance obligations`; `Lifecycle and evidence`.


<a id="file-docs-roadmap-files-src-policy-credentials-zig-md"></a>

## `docs/roadmap/files/src/policy/credentials.zig.md`

**Responsibility.** Proposed dependency implementation card for src/policy/credentials.zig; the path is a plan, not an implemented file.

**Contract and ownership.** Defines intended responsibility, prerequisites, ownership and verification for this named future module. Existing public records APIs and product policy boundaries remain in force. See [dependency-owned contract](../../../tls-zig/docs/roadmap/files/src/policy/credentials.zig.md).

**Failure/change obligations.** Do not create an empty stub or promote future APIs to supported behavior because a card exists. Native/QUIC/portability claims need target-specific implementation evidence.

**Verification.** Run tls-zig/tools/check-docs.py with its declared options and review the named source/test/receipt; application coverage checks establish navigation only.

**Next actionable work.** Implement this card only when its dependency-ready milestone is selected, with its real caller and independent positive/negative tests.

**Declared surface / navigation:** `Planned src/policy/credentials.zig`; `Responsibility and boundary`; `Invariants, data ownership and errors`; `Construction sequence`; `Acceptance cases`; `Exact work package T10`; `Observable acceptance obligations`; `Lifecycle and evidence`; `Ecosystem boundary acceptance`.


<a id="file-docs-roadmap-files-src-policy-verification-zig-md"></a>

## `docs/roadmap/files/src/policy/verification.zig.md`

**Responsibility.** Proposed dependency implementation card for src/policy/verification.zig; the path is a plan, not an implemented file.

**Contract and ownership.** Defines intended responsibility, prerequisites, ownership and verification for this named future module. Existing public records APIs and product policy boundaries remain in force. See [dependency-owned contract](../../../tls-zig/docs/roadmap/files/src/policy/verification.zig.md).

**Failure/change obligations.** Do not create an empty stub or promote future APIs to supported behavior because a card exists. Native/QUIC/portability claims need target-specific implementation evidence.

**Verification.** Run tls-zig/tools/check-docs.py with its declared options and review the named source/test/receipt; application coverage checks establish navigation only.

**Next actionable work.** Implement this card only when its dependency-ready milestone is selected, with its real caller and independent positive/negative tests.

**Declared surface / navigation:** `Planned src/policy/verification.zig`; `Responsibility and boundary`; `Invariants, data ownership and errors`; `Construction sequence`; `Acceptance cases`; `Exact work package T11`; `Observable acceptance obligations`; `Lifecycle and evidence`; `Ecosystem boundary acceptance`.


<a id="file-docs-roadmap-files-src-quic-contract-zig-md"></a>

## `docs/roadmap/files/src/quic/contract.zig.md`

**Responsibility.** Proposed dependency implementation card for src/quic/contract.zig; the path is a plan, not an implemented file.

**Contract and ownership.** Defines intended responsibility, prerequisites, ownership and verification for this named future module. Existing public records APIs and product policy boundaries remain in force. See [dependency-owned contract](../../../tls-zig/docs/roadmap/files/src/quic/contract.zig.md).

**Failure/change obligations.** Do not create an empty stub or promote future APIs to supported behavior because a card exists. Native/QUIC/portability claims need target-specific implementation evidence.

**Verification.** Run tls-zig/tools/check-docs.py with its declared options and review the named source/test/receipt; application coverage checks establish navigation only.

**Next actionable work.** Implement this card only when its dependency-ready milestone is selected, with its real caller and independent positive/negative tests.

**Declared surface / navigation:** `Planned src/quic/contract.zig`; `Responsibility and boundary`; `Invariants, data ownership and errors`; `Construction sequence`; `Acceptance cases`; `Exact work package T01`; `Observable acceptance obligations`; `Lifecycle and evidence`; `Ecosystem boundary acceptance`.


<a id="file-docs-roadmap-files-src-quic-engine-zig-md"></a>

## `docs/roadmap/files/src/quic/engine.zig.md`

**Responsibility.** Proposed dependency implementation card for src/quic/engine.zig; the path is a plan, not an implemented file.

**Contract and ownership.** Defines intended responsibility, prerequisites, ownership and verification for this named future module. Existing public records APIs and product policy boundaries remain in force. See [dependency-owned contract](../../../tls-zig/docs/roadmap/files/src/quic/engine.zig.md).

**Failure/change obligations.** Do not create an empty stub or promote future APIs to supported behavior because a card exists. Native/QUIC/portability claims need target-specific implementation evidence.

**Verification.** Run tls-zig/tools/check-docs.py with its declared options and review the named source/test/receipt; application coverage checks establish navigation only.

**Next actionable work.** Implement this card only when its dependency-ready milestone is selected, with its real caller and independent positive/negative tests.

**Declared surface / navigation:** `Planned src/quic/engine.zig`; `Responsibility and boundary`; `Invariants, data ownership and errors`; `Construction sequence`; `Acceptance cases`; `Exact work package T02`; `Observable acceptance obligations`; `Lifecycle and evidence`.


<a id="file-docs-roadmap-files-src-quic-events-zig-md"></a>

## `docs/roadmap/files/src/quic/events.zig.md`

**Responsibility.** Proposed dependency implementation card for src/quic/events.zig; the path is a plan, not an implemented file.

**Contract and ownership.** Defines intended responsibility, prerequisites, ownership and verification for this named future module. Existing public records APIs and product policy boundaries remain in force. See [dependency-owned contract](../../../tls-zig/docs/roadmap/files/src/quic/events.zig.md).

**Failure/change obligations.** Do not create an empty stub or promote future APIs to supported behavior because a card exists. Native/QUIC/portability claims need target-specific implementation evidence.

**Verification.** Run tls-zig/tools/check-docs.py with its declared options and review the named source/test/receipt; application coverage checks establish navigation only.

**Next actionable work.** Implement this card only when its dependency-ready milestone is selected, with its real caller and independent positive/negative tests.

**Declared surface / navigation:** `Planned src/quic/events.zig`; `Responsibility and boundary`; `Invariants, data ownership and errors`; `Construction sequence`; `Acceptance cases`; `Exact work package T03`; `Observable acceptance obligations`; `Lifecycle and evidence`.


<a id="file-docs-roadmap-files-tests-abi-zig-md"></a>

## `docs/roadmap/files/tests/abi.zig.md`

**Responsibility.** Proposed dependency implementation card for tests/abi.zig; the path is a plan, not an implemented file.

**Contract and ownership.** Defines intended responsibility, prerequisites, ownership and verification for this named future module. Existing public records APIs and product policy boundaries remain in force. See [dependency-owned contract](../../../tls-zig/docs/roadmap/files/tests/abi.zig.md).

**Failure/change obligations.** Do not create an empty stub or promote future APIs to supported behavior because a card exists. Native/QUIC/portability claims need target-specific implementation evidence.

**Verification.** Run tls-zig/tools/check-docs.py with its declared options and review the named source/test/receipt; application coverage checks establish navigation only.

**Next actionable work.** Implement this card only when its dependency-ready milestone is selected, with its real caller and independent positive/negative tests.

**Declared surface / navigation:** `Planned tests/abi.zig`; `Responsibility and boundary`; `Invariants, data ownership and errors`; `Construction sequence`; `Acceptance cases`; `Exact work package T09`; `Observable acceptance obligations`; `Lifecycle and evidence`; `Ecosystem boundary acceptance`.


<a id="file-docs-roadmap-files-tests-interop-matrix-py-md"></a>

## `docs/roadmap/files/tests/interop/matrix.py.md`

**Responsibility.** Proposed dependency implementation card for tests/interop/matrix.py; the path is a plan, not an implemented file.

**Contract and ownership.** Defines intended responsibility, prerequisites, ownership and verification for this named future module. Existing public records APIs and product policy boundaries remain in force. See [dependency-owned contract](../../../tls-zig/docs/roadmap/files/tests/interop/matrix.py.md).

**Failure/change obligations.** Do not create an empty stub or promote future APIs to supported behavior because a card exists. Native/QUIC/portability claims need target-specific implementation evidence.

**Verification.** Run tls-zig/tools/check-docs.py with its declared options and review the named source/test/receipt; application coverage checks establish navigation only.

**Next actionable work.** Implement this card only when its dependency-ready milestone is selected, with its real caller and independent positive/negative tests.

**Declared surface / navigation:** `Planned tests/interop/matrix.py`; `Responsibility and boundary`; `Invariants, data ownership and errors`; `Construction sequence`; `Acceptance cases`; `Exact work package T13`; `Observable acceptance obligations`; `Lifecycle and evidence`; `Ecosystem boundary acceptance`.


<a id="file-docs-roadmap-files-tests-quic-contract-zig-md"></a>

## `docs/roadmap/files/tests/quic_contract.zig.md`

**Responsibility.** Proposed dependency implementation card for tests/quic_contract.zig; the path is a plan, not an implemented file.

**Contract and ownership.** Defines intended responsibility, prerequisites, ownership and verification for this named future module. Existing public records APIs and product policy boundaries remain in force. See [dependency-owned contract](../../../tls-zig/docs/roadmap/files/tests/quic_contract.zig.md).

**Failure/change obligations.** Do not create an empty stub or promote future APIs to supported behavior because a card exists. Native/QUIC/portability claims need target-specific implementation evidence.

**Verification.** Run tls-zig/tools/check-docs.py with its declared options and review the named source/test/receipt; application coverage checks establish navigation only.

**Next actionable work.** Implement this card only when its dependency-ready milestone is selected, with its real caller and independent positive/negative tests.

**Declared surface / navigation:** `Planned tests/quic_contract.zig`; `Responsibility and boundary`; `Invariants, data ownership and errors`; `Construction sequence`; `Acceptance cases`; `Exact work package T06`; `Observable acceptance obligations`; `Lifecycle and evidence`.


<a id="file-docs-roadmap-files-tests-resource-limits-zig-md"></a>

## `docs/roadmap/files/tests/resource_limits.zig.md`

**Responsibility.** Proposed dependency implementation card for tests/resource_limits.zig; the path is a plan, not an implemented file.

**Contract and ownership.** Defines intended responsibility, prerequisites, ownership and verification for this named future module. Existing public records APIs and product policy boundaries remain in force. See [dependency-owned contract](../../../tls-zig/docs/roadmap/files/tests/resource_limits.zig.md).

**Failure/change obligations.** Do not create an empty stub or promote future APIs to supported behavior because a card exists. Native/QUIC/portability claims need target-specific implementation evidence.

**Verification.** Run tls-zig/tools/check-docs.py with its declared options and review the named source/test/receipt; application coverage checks establish navigation only.

**Next actionable work.** Implement this card only when its dependency-ready milestone is selected, with its real caller and independent positive/negative tests.

**Declared surface / navigation:** `Planned tests/resource_limits.zig`; `Responsibility and boundary`; `Invariants, data ownership and errors`; `Construction sequence`; `Acceptance cases`; `Exact work package T12`; `Observable acceptance obligations`; `Lifecycle and evidence`.


<a id="file-docs-roadmap-files-tools-verify-backend-py-md"></a>

## `docs/roadmap/files/tools/verify-backend.py.md`

**Responsibility.** Proposed dependency implementation card for tools/verify-backend.py; the path is a plan, not an implemented file.

**Contract and ownership.** Defines intended responsibility, prerequisites, ownership and verification for this named future module. Existing public records APIs and product policy boundaries remain in force. See [dependency-owned contract](../../../tls-zig/docs/roadmap/files/tools/verify-backend.py.md).

**Failure/change obligations.** Do not create an empty stub or promote future APIs to supported behavior because a card exists. Native/QUIC/portability claims need target-specific implementation evidence.

**Verification.** Run tls-zig/tools/check-docs.py with its declared options and review the named source/test/receipt; application coverage checks establish navigation only.

**Next actionable work.** Implement this card only when its dependency-ready milestone is selected, with its real caller and independent positive/negative tests.

**Declared surface / navigation:** `Planned tools/verify-backend.py`; `Responsibility and boundary`; `Invariants, data ownership and errors`; `Construction sequence`; `Acceptance cases`; `Exact work package T00`; `Observable acceptance obligations`; `Lifecycle and evidence`.


<a id="file-docs-roadmap-first-work-orders-md"></a>

## `docs/roadmap/first-work-orders.md`

**Responsibility.** Dependency-owned authored architecture, guide, model or navigation artifact: First concrete work orders.

**Contract and ownership.** Canonical dependency documentation or evidence for this named subject; retain implemented/proposed/historical distinctions and its precise source/target scope. The application imports this navigation, not a duplicate implementation or new trust input. See [dependency-owned contract](../../../tls-zig/docs/roadmap/first-work-orders.md).

**Failure/change obligations.** Local documentation integrity does not establish production readiness, host availability or unbounded mathematical correctness. Review the document itself before adopting a behavioral claim.

**Verification.** Run tls-zig/tools/check-docs.py with its declared options and review the named source/test/receipt; application coverage checks establish navigation only.

**Next actionable work.** Maintain this subject with its owning TLS work order and artifact register; coordinate application-relevant API/identity/platform changes with the consumer.

**Declared surface / navigation:** `First concrete work orders`; `T0: make dependency acquisition checks unconditional`; `T1: qualify the real recordless provider seam`; `Q1: integrate one real handshake journey`; `Q2 review item: loss threshold with skipped packet numbers`.


<a id="file-docs-roadmap-implementation-plan-json"></a>

## `docs/roadmap/implementation-plan.json`

**Responsibility.** Shared exact TLS/QUIC planned-file dependency graph.

**Contract and ownership.** Thirty-seven planned nodes and seventy-four acceptance obligations identify paths, prerequisites, stimuli, expected results and independent oracles. See [owner contract](../../../tls-zig/docs/roadmap/implementation-plan.json).

**Failure/change obligations.** Preserve planned, implemented and historically observed status. Source changes require a new owner receipt; no silent application trust/pin adoption.

**Verification.** Use check-plan before scheduling; actual file implementation requires explicit plan migration and executed evidence.

**Next actionable work.** Continue through the owning dependency work package; application policy and credentials stay in LAN Audio.

**Declared surface / navigation:** `schema`; `revision`; `semantics`; `nodes`.


<a id="file-docs-roadmap-readme-md"></a>

## `docs/roadmap/README.md`

**Responsibility.** Dependency-owned authored architecture, guide, model or navigation artifact: Dependency-ordered implementation roadmap.

**Contract and ownership.** Canonical dependency documentation or evidence for this named subject; retain implemented/proposed/historical distinctions and its precise source/target scope. The application imports this navigation, not a duplicate implementation or new trust input. See [dependency-owned contract](../../../tls-zig/docs/roadmap/README.md).

**Failure/change obligations.** Local documentation integrity does not establish production readiness, host availability or unbounded mathematical correctness. Review the document itself before adopting a behavioral claim.

**Verification.** Run tls-zig/tools/check-docs.py with its declared options and review the named source/test/receipt; application coverage checks establish navigation only.

**Next actionable work.** Maintain this subject with its owning TLS work order and artifact register; coordinate application-relevant API/identity/platform changes with the consumer.

**Declared surface / navigation:** `Dependency-ordered implementation roadmap`; `Milestone dependencies`; `Proposed files`; `Extensions requiring a separate decision`; `Implementation lifecycle and unresolved decisions`.


<a id="file-docs-roadmap-takeover-md"></a>

## `docs/roadmap/takeover.md`

**Responsibility.** Ordered transport implementation continuation entry.

**Contract and ownership.** Starts from exact source/capability status and directs dependency-ready files, acceptance evidence and remaining release limits. See [owner contract](../../../tls-zig/docs/roadmap/takeover.md).

**Failure/change obligations.** Preserve planned, implemented and historically observed status. Source changes require a new owner receipt; no silent application trust/pin adoption.

**Verification.** Confirm current registry/source/profile before choosing the next bounded implementation slice.

**Next actionable work.** Continue through the owning dependency work package; application policy and credentials stay in LAN Audio.

**Declared surface / navigation:** `Before implementation takeover`; `Start without inventing a subsystem`; `Specification that must exist before each boundary is implemented`; `What the handoff intentionally does not fabricate`; `First takeover increment`; `Ecosystem alignment — revision 4`.


<a id="file-docs-roadmap-work-graph-md"></a>

## `docs/roadmap/work-graph.md`

**Responsibility.** Human navigation of the exact dependency completion order.

**Contract and ownership.** Explains readiness and ownership from the shared plan; package DAG and temporal/event ownership remain separate contracts. See [owner contract](../../../tls-zig/docs/roadmap/work-graph.md).

**Failure/change obligations.** Preserve planned, implemented and historically observed status. Source changes require a new owner receipt; no silent application trust/pin adoption.

**Verification.** Compare IDs/prerequisites with the JSON plan; do not treat planned code as existing symbols.

**Next actionable work.** Continue through the owning dependency work package; application policy and credentials stay in LAN Audio.

**Declared surface / navigation:** `Implementing from the exact work graph`; `Current dependency-ready work`; `Closing one work package`; `Release gate beyond a topological order`.


<a id="file-docs-security-threat-model-md"></a>

## `docs/security/threat-model.md`

**Responsibility.** Dependency-owned authored architecture, guide, model or navigation artifact: Threat model and release blockers.

**Contract and ownership.** Canonical dependency documentation or evidence for this named subject; retain implemented/proposed/historical distinctions and its precise source/target scope. The application imports this navigation, not a duplicate implementation or new trust input. See [dependency-owned contract](../../../tls-zig/docs/security/threat-model.md).

**Failure/change obligations.** Local documentation integrity does not establish production readiness, host availability or unbounded mathematical correctness. Review the document itself before adopting a behavioral claim.

**Verification.** Run tls-zig/tools/check-docs.py with its declared options and review the named source/test/receipt; application coverage checks establish navigation only.

**Next actionable work.** Maintain this subject with its owning TLS work order and artifact register; coordinate application-relevant API/identity/platform changes with the consumer.

**Declared surface / navigation:** `Threat model and release blockers`; `Current limitations requiring design or evidence`; `Dependency and license custody`.


<a id="file-docs-verification-artifact-register-json"></a>

## `docs/verification/artifact-register.json`

**Responsibility.** Dependency-owned machine-readable inventory or dated verification evidence: docs/verification/artifact-register.json.

**Contract and ownership.** Canonical dependency documentation or evidence for this named subject; retain implemented/proposed/historical distinctions and its precise source/target scope. The application imports this navigation, not a duplicate implementation or new trust input. See [dependency-owned contract](../../../tls-zig/docs/verification/artifact-register.json).

**Failure/change obligations.** Local documentation integrity does not establish production readiness, host availability or unbounded mathematical correctness. Review the document itself before adopting a behavioral claim.

**Verification.** Run tls-zig/tools/check-docs.py with its declared options and review the named source/test/receipt; application coverage checks establish navigation only.

**Next actionable work.** Maintain this subject with its owning TLS work order and artifact register; coordinate application-relevant API/identity/platform changes with the consumer.

**Declared surface / navigation:** `schema`; `artifacts`.


<a id="file-docs-verification-baseline-r2-md"></a>

## `docs/verification/baseline-r2.md`

**Responsibility.** Historical r2 qualification scope.

**Contract and ownership.** Preserves r2 initial-provider/model/maintenance evidence and distinguishes new r3 planning and lifecycle-validator work. See [owner contract](../../../tls-zig/docs/verification/baseline-r2.md).

**Failure/change obligations.** Preserve planned, implemented and historically observed status. Source changes require a new owner receipt; no silent application trust/pin adoption.

**Verification.** Retain source-scoped results; no automatic promotion to current runtime or authenticated QUIC evidence.

**Next actionable work.** Continue through the owning dependency work package; application policy and credentials stay in LAN Audio.

**Declared surface / navigation:** `Current handoff — revision 2, 2026-09-26`; `New evidence and limits`; `Preserved implementation evidence`; `Reproduce maintenance checks`.


<a id="file-docs-verification-baseline-r3-md"></a>

## `docs/verification/baseline-r3.md`

**Responsibility.** Preserved r3 qualification context.

**Contract and ownership.** Retains prior implemented-tool and planned-protocol distinctions; r4 documentation does not rerun native protocol results. See [canonical owner document](../../../tls-zig/docs/verification/baseline-r3.md).

**Failure/change obligations.** Preserve observed/planned/implemented distinctions and explicit owner boundaries; do not adopt a missing API or broaden evidence scope.

**Verification.** Run owner documentation/custody checks and review recorded inputs/receipts; this application integration is navigation and hash reconciliation.

**Next actionable work.** Implement only the selected dependency-ready work with a real caller and target-specific acceptance; retain historical receipts.

**Declared surface / navigation:** `Current handoff — revision 3, 2026-09-26`.


<a id="file-docs-verification-baseline-v1-md"></a>

## `docs/verification/baseline-v1.md`

**Responsibility.** Historical baseline qualification scope.

**Contract and ownership.** Retains pre-r2 native execution/compilation/cache distinctions and links original receipts; unchanged runtime evidence stays revision-scoped. See [owner contract](../../../tls-zig/docs/verification/baseline-v1.md).

**Failure/change obligations.** Preserve planned, implemented and historically observed status. Source changes require a new owner receipt; no silent application trust/pin adoption.

**Verification.** Preserve old evidence and identify new documentation/model work separately.

**Next actionable work.** Continue through the owning dependency work package; application policy and credentials stay in LAN Audio.

**Declared surface / navigation:** `Current source and verification â€” 2026-09-26`; `Present capability`; `Documentation scope`; `Commands`; `Final results`.


<a id="file-docs-verification-change-audit-json"></a>

## `docs/verification/change-audit.json`

**Responsibility.** Dependency-owned dated verification/traceability artifact: docs/verification/change-audit.json.

**Contract and ownership.** Canonical dependency documentation or evidence for this named subject; retain implemented/proposed/historical distinctions and its precise source/target scope. The application imports this navigation, not a duplicate implementation or new trust input. See [dependency-owned contract](../../../tls-zig/docs/verification/change-audit.json).

**Failure/change obligations.** Local documentation integrity does not establish production readiness, host availability or unbounded mathematical correctness. Review the document itself before adopting a behavioral claim.

**Verification.** Run tls-zig/tools/check-docs.py with its declared options and review the named source/test/receipt; application coverage checks establish navigation only.

**Next actionable work.** Maintain this subject with its owning TLS work order and artifact register; coordinate application-relevant API/identity/platform changes with the consumer.

**Declared surface / navigation:** `project`; `date`; `baseline_files`; `changed_existing`; `preserved_original_paths`; `source_body_checks`; `scope`; `new_paths`.


<a id="file-docs-verification-current-md"></a>

## `docs/verification/current.md`

**Responsibility.** Dependency-owned authored architecture, guide, model or navigation artifact: Current source and verification â€” 2026-09-26.

**Contract and ownership.** Canonical dependency documentation or evidence for this named subject; retain implemented/proposed/historical distinctions and its precise source/target scope. The application imports this navigation, not a duplicate implementation or new trust input. See [dependency-owned contract](../../../tls-zig/docs/verification/current.md).

**Failure/change obligations.** Local documentation integrity does not establish production readiness, host availability or unbounded mathematical correctness. Review the document itself before adopting a behavioral claim.

**Verification.** Run tls-zig/tools/check-docs.py with its declared options and review the named source/test/receipt; application coverage checks establish navigation only.

**Next actionable work.** Maintain this subject with its owning TLS work order and artifact register; coordinate application-relevant API/identity/platform changes with the consumer.

**Declared surface / navigation:** `Current handoff — revision 4`.


<a id="file-docs-verification-dependency-inventory-json"></a>

## `docs/verification/dependency-inventory.json`

**Responsibility.** Dependency-owned machine-readable inventory or dated verification evidence: docs/verification/dependency-inventory.json.

**Contract and ownership.** Canonical dependency documentation or evidence for this named subject; retain implemented/proposed/historical distinctions and its precise source/target scope. The application imports this navigation, not a duplicate implementation or new trust input. See [dependency-owned contract](../../../tls-zig/docs/verification/dependency-inventory.json).

**Failure/change obligations.** Local documentation integrity does not establish production readiness, host availability or unbounded mathematical correctness. Review the document itself before adopting a behavioral claim.

**Verification.** Run tls-zig/tools/check-docs.py with its declared options and review the named source/test/receipt; application coverage checks establish navigation only.

**Next actionable work.** Maintain this subject with its owning TLS work order and artifact register; coordinate application-relevant API/identity/platform changes with the consumer.

**Declared surface / navigation:** `files`; `excluded`.


<a id="file-docs-verification-failed-attempt-121343-run-results-json"></a>

## `docs/verification/failed-attempt-121343/run-results.json`

**Responsibility.** Dependency-owned dated verification execution log: docs/verification/failed-attempt-121343/run-results.json.

**Contract and ownership.** Canonical dependency documentation or evidence for this named subject; retain implemented/proposed/historical distinctions and its precise source/target scope. The application imports this navigation, not a duplicate implementation or new trust input. See [dependency-owned contract](../../../tls-zig/docs/verification/failed-attempt-121343/run-results.json).

**Failure/change obligations.** Local documentation integrity does not establish production readiness, host availability or unbounded mathematical correctness. Review the document itself before adopting a behavioral claim.

**Verification.** Run tls-zig/tools/check-docs.py with its declared options and review the named source/test/receipt; application coverage checks establish navigation only.

**Next actionable work.** Maintain this subject with its owning TLS work order and artifact register; coordinate application-relevant API/identity/platform changes with the consumer.

**Declared surface / navigation:** `date_utc`; `project`; `source_inventory_sha256`; `zig`; `python`; `environment_overrides`; `runs`; `status`.


<a id="file-docs-verification-failed-attempt-121343-runs-debug-log"></a>

## `docs/verification/failed-attempt-121343/runs/debug.log`

**Responsibility.** Dependency verification transcript: docs/verification/failed-attempt-121343/runs/debug.log.

**Contract and ownership.** Historical command output owned by the TLS run register. Interpret together with recorded command, source, tool, target and exit code; cached build results are not fresh execution. See [dependency-owned contract](../../../tls-zig/docs/verification/failed-attempt-121343/runs/debug.log).

**Failure/change obligations.** Never edit a failed/old transcript to imply current success or infer native Mac execution from cross compilation. This file does not authorize changing a dependency lock.

**Verification.** Run tls-zig/tools/check-docs.py with its declared options and review the named source/test/receipt; application coverage checks establish navigation only.

**Next actionable work.** Retain the transcript and create a new source-scoped run for future changes; consult docs/verification/run-results.json for its context.


<a id="file-docs-verification-failed-attempt-121343-runs-format-log"></a>

## `docs/verification/failed-attempt-121343/runs/format.log`

**Responsibility.** Dependency verification transcript: docs/verification/failed-attempt-121343/runs/format.log.

**Contract and ownership.** Historical command output owned by the TLS run register. Interpret together with recorded command, source, tool, target and exit code; cached build results are not fresh execution. See [dependency-owned contract](../../../tls-zig/docs/verification/failed-attempt-121343/runs/format.log).

**Failure/change obligations.** Never edit a failed/old transcript to imply current success or infer native Mac execution from cross compilation. This file does not authorize changing a dependency lock.

**Verification.** Run tls-zig/tools/check-docs.py with its declared options and review the named source/test/receipt; application coverage checks establish navigation only.

**Next actionable work.** Retain the transcript and create a new source-scoped run for future changes; consult docs/verification/run-results.json for its context.


<a id="file-docs-verification-failed-attempt-121343-runs-models-log"></a>

## `docs/verification/failed-attempt-121343/runs/models.log`

**Responsibility.** Dependency verification transcript: docs/verification/failed-attempt-121343/runs/models.log.

**Contract and ownership.** Historical command output owned by the TLS run register. Interpret together with recorded command, source, tool, target and exit code; cached build results are not fresh execution. See [dependency-owned contract](../../../tls-zig/docs/verification/failed-attempt-121343/runs/models.log).

**Failure/change obligations.** Never edit a failed/old transcript to imply current success or infer native Mac execution from cross compilation. This file does not authorize changing a dependency lock.

**Verification.** Run tls-zig/tools/check-docs.py with its declared options and review the named source/test/receipt; application coverage checks establish navigation only.

**Next actionable work.** Retain the transcript and create a new source-scoped run for future changes; consult docs/verification/run-results.json for its context.


<a id="file-docs-verification-quic-provider-probe-md"></a>

## `docs/verification/quic-provider-probe.md`

**Responsibility.** Observed initial external QUIC TLS provider capability.

**Contract and ownership.** Explains three bounded callback cases and explicitly uncompleted peer authentication, handshake and application transport. See [owner contract](../../../tls-zig/docs/verification/quic-provider-probe.md).

**Failure/change obligations.** Preserve planned, implemented and historically observed status. Source changes require a new owner receipt; no silent application trust/pin adoption.

**Verification.** Check source/SDK hashes in r2-probe-result before adopting the capability; no complete QUIC readiness claim.

**Next actionable work.** Continue through the owning dependency work package; application policy and credentials stay in LAN Audio.

**Declared surface / navigation:** `Exact SDK external QUIC TLS capability probe`; `Reproduce`; `Consequence for the next work order`.


<a id="file-docs-verification-r2-change-audit-json"></a>

## `docs/verification/r2-change-audit.json`

**Responsibility.** Exact reviewed r2 dependency file changes.

**Contract and ownership.** Records before/after hashes, no deletions and its self-exclusion; this is an owner change receipt, not an application pin-refresh instruction. See [owner contract](../../../tls-zig/docs/verification/r2-change-audit.json).

**Failure/change obligations.** Preserve planned, implemented and historically observed status. Source changes require a new owner receipt; no silent application trust/pin adoption.

**Verification.** Verify every current after-hash and preserve baseline chain before integrating the reference.

**Next actionable work.** Continue through the owning dependency work package; application policy and credentials stay in LAN Audio.

**Declared surface / navigation:** `revision`; `status`; `project`; `baseline`; `excluded_self_path`; `deleted_paths`; `application_pins_modified`; `changes`.


<a id="file-docs-verification-r2-check-results-json"></a>

## `docs/verification/r2-check-results.json`

**Responsibility.** Owner r2 documentation, graph, finite-model and adoption observations.

**Contract and ownership.** Commands retain scope, results and negative controls; prior native regressions were retained under unchanged implementation. See [owner contract](../../../tls-zig/docs/verification/r2-check-results.json).

**Failure/change obligations.** Preserve planned, implemented and historically observed status. Source changes require a new owner receipt; no silent application trust/pin adoption.

**Verification.** Check source-inventory/plan hashes and read result limits; do not relabel retained evidence as newly executed runtime tests.

**Next actionable work.** Continue through the owning dependency work package; application policy and credentials stay in LAN Audio.

**Declared surface / navigation:** `status`; `date_utc`; `scope`; `source_inventory_sha256`; `plan_sha256`; `runs`; `filesystem_negative_controls`; `preexisting_source_preserved`; `only_preexisting_source_changed`; `native_probe_receipt`; `native_probe_negative_controls`; `live_adoption_checks`; `live_adoption_date_utc`.


<a id="file-docs-verification-r2-probe-result-json"></a>

## `docs/verification/r2-probe-result.json`

**Responsibility.** Native initial-provider callback observations and build provenance.

**Contract and ownership.** Records compiler, exact SDK/source/runtime hashes and case booleans including false handshake/peer authentication. See [owner contract](../../../tls-zig/docs/verification/r2-probe-result.json).

**Failure/change obligations.** Preserve planned, implemented and historically observed status. Source changes require a new owner receipt; no silent application trust/pin adoption.

**Verification.** Bind results to actual probe sources and distinguish successful negative-case handling from a completed secure connection.

**Next actionable work.** Continue through the owning dependency work package; application policy and credentials stay in LAN Audio.

**Declared surface / navigation:** `scope`; `date_utc`; `sdk_lock_sha256`; `source_sha256`; `runner_sha256`; `zig`; `compile_command`; `compile_exit`; `sdk_files_verified`; `staged_runtime_sha256`; `cases`; `passed`.


<a id="file-docs-verification-r3-change-audit-json"></a>

## `docs/verification/r3-change-audit.json`

**Responsibility.** Exact r3 source/documentation change receipt.

**Contract and ownership.** Records the r2-to-r3 before/after transition with its self-exclusion and unchanged application pins. See [owner contract](../../../tls-zig/docs/verification/r3-change-audit.json).

**Failure/change obligations.** Preserve planned, implemented and historically observed status. Source changes require a new owner receipt; no silent application trust/pin adoption.

**Verification.** Check complete hash chain and current after-images before importing navigation; never use it to silently refresh runtime pins.

**Next actionable work.** Continue through the owning dependency work package; application policy and credentials stay in LAN Audio.

**Declared surface / navigation:** `revision`; `project`; `status`; `excluded_self_path`; `deleted_paths`; `application_pins_modified`; `changes`.


<a id="file-docs-verification-r3-check-results-json"></a>

## `docs/verification/r3-check-results.json`

**Responsibility.** Owner r3 qualification and preservation observations.

**Contract and ownership.** Records maintenance/lifecycle validator checks and source-preservation limits separately from native protocol tests. See [owner contract](../../../tls-zig/docs/verification/r3-check-results.json).

**Failure/change obligations.** Preserve planned, implemented and historically observed status. Source changes require a new owner receipt; no silent application trust/pin adoption.

**Verification.** Bind observations to current tool/source hashes and retain synthetic versus actual execution distinctions.

**Next actionable work.** Continue through the owning dependency work package; application policy and credentials stay in LAN Audio.

**Declared surface / navigation:** `status`; `revision`; `date_utc`; `scope`; `source_inventory_sha256`; `plan_sha256`; `runs`; `preexisting_source_unchanged`; `only_preexisting_source_modified`; `actual_work_package_states`; `native_protocol_tests`; `models`; `live_adoption_checks`.


<a id="file-docs-verification-r4-change-audit-json"></a>

## `docs/verification/r4-change-audit.json`

**Responsibility.** Exact r3-to-r4 documentation after-images.

**Contract and ownership.** Binds reviewed before/after hashes and self-exclusion while preserving source/pins; never authorizes silent lock refresh. See [canonical owner document](../../../tls-zig/docs/verification/r4-change-audit.json).

**Failure/change obligations.** Preserve observed/planned/implemented distinctions and explicit owner boundaries; do not adopt a missing API or broaden evidence scope.

**Verification.** Run owner documentation/custody checks and review recorded inputs/receipts; this application integration is navigation and hash reconciliation.

**Next actionable work.** Implement only the selected dependency-ready work with a real caller and target-specific acceptance; retain historical receipts.

**Declared surface / navigation:** `revision`; `status`; `project`; `excluded_self_path`; `deleted_paths`; `application_pins_modified`; `changes`.


<a id="file-docs-verification-r4-check-results-json"></a>

## `docs/verification/r4-check-results.json`

**Responsibility.** Owner r4 ecosystem/document qualification observations.

**Contract and ownership.** Distinguishes source preservation, maintenance checks and producer sample evidence from complete native protocol or documentation migration. See [canonical owner document](../../../tls-zig/docs/verification/r4-check-results.json).

**Failure/change obligations.** Preserve observed/planned/implemented distinctions and explicit owner boundaries; do not adopt a missing API or broaden evidence scope.

**Verification.** Run owner documentation/custody checks and review recorded inputs/receipts; this application integration is navigation and hash reconciliation.

**Next actionable work.** Implement only the selected dependency-ready work with a real caller and target-specific acceptance; retain historical receipts.

**Declared surface / navigation:** `status`; `revision`; `scope`; `date_utc`; `source_inventory_sha256`; `plan_sha256`; `all_indexed_source_bytes_unchanged`; `work_packages`; `baseline_obligations`; `added_obligations`; `total_obligations`; `runs`; `live_adoption_checks`.


<a id="file-docs-verification-requirements-json"></a>

## `docs/verification/requirements.json`

**Responsibility.** Dependency-owned dated verification/traceability artifact: docs/verification/requirements.json.

**Contract and ownership.** Canonical dependency documentation or evidence for this named subject; retain implemented/proposed/historical distinctions and its precise source/target scope. The application imports this navigation, not a duplicate implementation or new trust input. See [dependency-owned contract](../../../tls-zig/docs/verification/requirements.json).

**Failure/change obligations.** Local documentation integrity does not establish production readiness, host availability or unbounded mathematical correctness. Review the document itself before adopting a behavioral claim.

**Verification.** Run tls-zig/tools/check-docs.py with its declared options and review the named source/test/receipt; application coverage checks establish navigation only.

**Next actionable work.** Maintain this subject with its owning TLS work order and artifact register; coordinate application-relevant API/identity/platform changes with the consumer.

**Declared surface / navigation:** `requirements`.


<a id="file-docs-verification-requirements-md"></a>

## `docs/verification/requirements.md`

**Responsibility.** Dependency-owned dated verification/traceability artifact: Component requirement and test traceability.

**Contract and ownership.** Canonical dependency documentation or evidence for this named subject; retain implemented/proposed/historical distinctions and its precise source/target scope. The application imports this navigation, not a duplicate implementation or new trust input. See [dependency-owned contract](../../../tls-zig/docs/verification/requirements.md).

**Failure/change obligations.** Local documentation integrity does not establish production readiness, host availability or unbounded mathematical correctness. Review the document itself before adopting a behavioral claim.

**Verification.** Run tls-zig/tools/check-docs.py with its declared options and review the named source/test/receipt; application coverage checks establish navigation only.

**Next actionable work.** Maintain this subject with its owning TLS work order and artifact register; coordinate application-relevant API/identity/platform changes with the consumer.

**Declared surface / navigation:** `Component requirement and test traceability`.


<a id="file-docs-verification-run-results-json"></a>

## `docs/verification/run-results.json`

**Responsibility.** Dependency-owned machine-readable inventory or dated verification evidence: docs/verification/run-results.json.

**Contract and ownership.** Canonical dependency documentation or evidence for this named subject; retain implemented/proposed/historical distinctions and its precise source/target scope. The application imports this navigation, not a duplicate implementation or new trust input. See [dependency-owned contract](../../../tls-zig/docs/verification/run-results.json).

**Failure/change obligations.** Local documentation integrity does not establish production readiness, host availability or unbounded mathematical correctness. Review the document itself before adopting a behavioral claim.

**Verification.** Run tls-zig/tools/check-docs.py with its declared options and review the named source/test/receipt; application coverage checks establish navigation only.

**Next actionable work.** Maintain this subject with its owning TLS work order and artifact register; coordinate application-relevant API/identity/platform changes with the consumer.

**Declared surface / navigation:** `date_utc`; `project`; `source_inventory_sha256`; `zig`; `python`; `environment_overrides`; `runs`; `status`.


<a id="file-docs-verification-runs-consumer-build-log"></a>

## `docs/verification/runs/consumer-build.log`

**Responsibility.** Dependency verification transcript: docs/verification/runs/consumer-build.log.

**Contract and ownership.** Historical command output owned by the TLS run register. Interpret together with recorded command, source, tool, target and exit code; cached build results are not fresh execution. See [dependency-owned contract](../../../tls-zig/docs/verification/runs/consumer-build.log).

**Failure/change obligations.** Never edit a failed/old transcript to imply current success or infer native Mac execution from cross compilation. This file does not authorize changing a dependency lock.

**Verification.** Run tls-zig/tools/check-docs.py with its declared options and review the named source/test/receipt; application coverage checks establish navigation only.

**Next actionable work.** Retain the transcript and create a new source-scoped run for future changes; consult docs/verification/run-results.json for its context.


<a id="file-docs-verification-runs-debug-log"></a>

## `docs/verification/runs/debug.log`

**Responsibility.** Dependency verification transcript: docs/verification/runs/debug.log.

**Contract and ownership.** Historical command output owned by the TLS run register. Interpret together with recorded command, source, tool, target and exit code; cached build results are not fresh execution. See [dependency-owned contract](../../../tls-zig/docs/verification/runs/debug.log).

**Failure/change obligations.** Never edit a failed/old transcript to imply current success or infer native Mac execution from cross compilation. This file does not authorize changing a dependency lock.

**Verification.** Run tls-zig/tools/check-docs.py with its declared options and review the named source/test/receipt; application coverage checks establish navigation only.

**Next actionable work.** Retain the transcript and create a new source-scoped run for future changes; consult docs/verification/run-results.json for its context.


<a id="file-docs-verification-runs-docs-log"></a>

## `docs/verification/runs/docs.log`

**Responsibility.** Dependency verification transcript: docs/verification/runs/docs.log.

**Contract and ownership.** Historical command output owned by the TLS run register. Interpret together with recorded command, source, tool, target and exit code; cached build results are not fresh execution. See [dependency-owned contract](../../../tls-zig/docs/verification/runs/docs.log).

**Failure/change obligations.** Never edit a failed/old transcript to imply current success or infer native Mac execution from cross compilation. This file does not authorize changing a dependency lock.

**Verification.** Run tls-zig/tools/check-docs.py with its declared options and review the named source/test/receipt; application coverage checks establish navigation only.

**Next actionable work.** Retain the transcript and create a new source-scoped run for future changes; consult docs/verification/run-results.json for its context.


<a id="file-docs-verification-runs-format-log"></a>

## `docs/verification/runs/format.log`

**Responsibility.** Dependency verification transcript: docs/verification/runs/format.log.

**Contract and ownership.** Historical command output owned by the TLS run register. Interpret together with recorded command, source, tool, target and exit code; cached build results are not fresh execution. See [dependency-owned contract](../../../tls-zig/docs/verification/runs/format.log).

**Failure/change obligations.** Never edit a failed/old transcript to imply current success or infer native Mac execution from cross compilation. This file does not authorize changing a dependency lock.

**Verification.** Run tls-zig/tools/check-docs.py with its declared options and review the named source/test/receipt; application coverage checks establish navigation only.

**Next actionable work.** Retain the transcript and create a new source-scoped run for future changes; consult docs/verification/run-results.json for its context.


<a id="file-docs-verification-runs-interop-example-log"></a>

## `docs/verification/runs/interop-example.log`

**Responsibility.** Dependency verification transcript: docs/verification/runs/interop-example.log.

**Contract and ownership.** Historical command output owned by the TLS run register. Interpret together with recorded command, source, tool, target and exit code; cached build results are not fresh execution. See [dependency-owned contract](../../../tls-zig/docs/verification/runs/interop-example.log).

**Failure/change obligations.** Never edit a failed/old transcript to imply current success or infer native Mac execution from cross compilation. This file does not authorize changing a dependency lock.

**Verification.** Run tls-zig/tools/check-docs.py with its declared options and review the named source/test/receipt; application coverage checks establish navigation only.

**Next actionable work.** Retain the transcript and create a new source-scoped run for future changes; consult docs/verification/run-results.json for its context.


<a id="file-docs-verification-runs-models-log"></a>

## `docs/verification/runs/models.log`

**Responsibility.** Dependency verification transcript: docs/verification/runs/models.log.

**Contract and ownership.** Historical command output owned by the TLS run register. Interpret together with recorded command, source, tool, target and exit code; cached build results are not fresh execution. See [dependency-owned contract](../../../tls-zig/docs/verification/runs/models.log).

**Failure/change obligations.** Never edit a failed/old transcript to imply current success or infer native Mac execution from cross compilation. This file does not authorize changing a dependency lock.

**Verification.** Run tls-zig/tools/check-docs.py with its declared options and review the named source/test/receipt; application coverage checks establish navigation only.

**Next actionable work.** Retain the transcript and create a new source-scoped run for future changes; consult docs/verification/run-results.json for its context.


<a id="file-docs-verification-runs-release-safe-log"></a>

## `docs/verification/runs/release-safe.log`

**Responsibility.** Dependency verification transcript: docs/verification/runs/release-safe.log.

**Contract and ownership.** Historical command output owned by the TLS run register. Interpret together with recorded command, source, tool, target and exit code; cached build results are not fresh execution. See [dependency-owned contract](../../../tls-zig/docs/verification/runs/release-safe.log).

**Failure/change obligations.** Never edit a failed/old transcript to imply current success or infer native Mac execution from cross compilation. This file does not authorize changing a dependency lock.

**Verification.** Run tls-zig/tools/check-docs.py with its declared options and review the named source/test/receipt; application coverage checks establish navigation only.

**Next actionable work.** Retain the transcript and create a new source-scoped run for future changes; consult docs/verification/run-results.json for its context.


<a id="file-docs-verification-runs-tcp-interop-log"></a>

## `docs/verification/runs/tcp_interop.log`

**Responsibility.** Dependency verification transcript: docs/verification/runs/tcp_interop.log.

**Contract and ownership.** Historical command output owned by the TLS run register. Interpret together with recorded command, source, tool, target and exit code; cached build results are not fresh execution. See [dependency-owned contract](../../../tls-zig/docs/verification/runs/tcp_interop.log).

**Failure/change obligations.** Never edit a failed/old transcript to imply current success or infer native Mac execution from cross compilation. This file does not authorize changing a dependency lock.

**Verification.** Run tls-zig/tools/check-docs.py with its declared options and review the named source/test/receipt; application coverage checks establish navigation only.

**Next actionable work.** Retain the transcript and create a new source-scoped run for future changes; consult docs/verification/run-results.json for its context.


<a id="file-docs-verification-runs-tcp-server-interop-log"></a>

## `docs/verification/runs/tcp_server_interop.log`

**Responsibility.** Dependency verification transcript: docs/verification/runs/tcp_server_interop.log.

**Contract and ownership.** Historical command output owned by the TLS run register. Interpret together with recorded command, source, tool, target and exit code; cached build results are not fresh execution. See [dependency-owned contract](../../../tls-zig/docs/verification/runs/tcp_server_interop.log).

**Failure/change obligations.** Never edit a failed/old transcript to imply current success or infer native Mac execution from cross compilation. This file does not authorize changing a dependency lock.

**Verification.** Run tls-zig/tools/check-docs.py with its declared options and review the named source/test/receipt; application coverage checks establish navigation only.

**Next actionable work.** Retain the transcript and create a new source-scoped run for future changes; consult docs/verification/run-results.json for its context.


<a id="file-docs-verification-runs-tcp-upload-interop-log"></a>

## `docs/verification/runs/tcp_upload_interop.log`

**Responsibility.** Dependency verification transcript: docs/verification/runs/tcp_upload_interop.log.

**Contract and ownership.** Historical command output owned by the TLS run register. Interpret together with recorded command, source, tool, target and exit code; cached build results are not fresh execution. See [dependency-owned contract](../../../tls-zig/docs/verification/runs/tcp_upload_interop.log).

**Failure/change obligations.** Never edit a failed/old transcript to imply current success or infer native Mac execution from cross compilation. This file does not authorize changing a dependency lock.

**Verification.** Run tls-zig/tools/check-docs.py with its declared options and review the named source/test/receipt; application coverage checks establish navigation only.

**Next actionable work.** Retain the transcript and create a new source-scoped run for future changes; consult docs/verification/run-results.json for its context.


<a id="file-docs-verification-source-inventory-json"></a>

## `docs/verification/source-inventory.json`

**Responsibility.** Dependency-owned machine-readable inventory or dated verification evidence: docs/verification/source-inventory.json.

**Contract and ownership.** Canonical dependency documentation or evidence for this named subject; retain implemented/proposed/historical distinctions and its precise source/target scope. The application imports this navigation, not a duplicate implementation or new trust input. See [dependency-owned contract](../../../tls-zig/docs/verification/source-inventory.json).

**Failure/change obligations.** Local documentation integrity does not establish production readiness, host availability or unbounded mathematical correctness. Review the document itself before adopting a behavioral claim.

**Verification.** Run tls-zig/tools/check-docs.py with its declared options and review the named source/test/receipt; application coverage checks establish navigation only.

**Next actionable work.** Maintain this subject with its owning TLS work order and artifact register; coordinate application-relevant API/identity/platform changes with the consumer.

**Declared surface / navigation:** `schema`; `project`; `date`; `historical_documents`; `files`; `revision`.


<a id="file-docs-verification-strategy-md"></a>

## `docs/verification/strategy.md`

**Responsibility.** Dependency-owned authored architecture, guide, model or navigation artifact: Verification and completion criteria.

**Contract and ownership.** Canonical dependency documentation or evidence for this named subject; retain implemented/proposed/historical distinctions and its precise source/target scope. The application imports this navigation, not a duplicate implementation or new trust input. See [dependency-owned contract](../../../tls-zig/docs/verification/strategy.md).

**Failure/change obligations.** Local documentation integrity does not establish production readiness, host availability or unbounded mathematical correctness. Review the document itself before adopting a behavioral claim.

**Verification.** Run tls-zig/tools/check-docs.py with its declared options and review the named source/test/receipt; application coverage checks establish navigation only.

**Next actionable work.** Maintain this subject with its owning TLS work order and artifact register; coordinate application-relevant API/identity/platform changes with the consumer.

**Declared surface / navigation:** `Verification and completion criteria`; `Required layers`; `Change-specific gates`; `Evidence schema`; `Definition of done for a roadmap item`.


<a id="file-evidence-build-recovery-md"></a>

## `evidence/build-recovery.md`

**Responsibility.** Historical engineering context: Private OpenSSL build recovery.

**Contract and ownership.** Dated workflow/evidence observations; never independent authorization to execute commands or change unrelated repositories.

**Failure/change obligations.** Do not duplicate conflicting protocol/API meaning or imply unexecuted platform support. Preserve useful history and label superseded claims rather than erasing evidence.

**Verification.** Validate local navigation and file index, compare referenced source behavior and evidence dates/hashes; prose quality requires review beyond automated checks.

**Next actionable work.** Read the declared sections below; update this guide whenever its owned contract changes and link to granular implementation/verification obligations.

**Declared surface / navigation:** `Private OpenSSL build recovery`.


<a id="file-evidence-source-provenance-json"></a>

## `evidence/source-provenance.json`

**Responsibility.** Historical upstream archive/configuration and build-recovery provenance.

**Contract and ownership.** Records URLs/hashes/config and explicitly absent signature verification. Historical support/date fields require fresh review before release claims.

**Failure/change obligations.** Preserve exact error/custody/lifetime semantics and old users. Unexpected failures remain failures; a passing local test is not cross-platform or whole-library security certification.

**Verification.** Generic Engine/Driver tests, independent SSL/TCP consumers, exact backend/runtime checks and relevant source hashes; rerun only affected gates.

**Next actionable work.** WP01/WP09 retain it, add new target/release provenance and verify source availability before rebuilding.

**Declared surface / navigation:** `release`; `make_url`; `signature_verification`; `checked_at`; `source_url`; `configure`; `support_until`; `make_checksum_source`; `make_sha256`; `release_date`; `source_sha256`; `final_make`; `build_note`; `source_checksum_url`; `official_downloads_url`; `release_policy_url`.


<a id="file-examples-consumer-build-zig"></a>

## `examples/consumer/build.zig`

**Responsibility.** Separately built downstream TLS package consumer.

**Contract and ownership.** Imports exported tls module and owns Windows Winsock C shim/linking; stages matching private runtime.

**Failure/change obligations.** Preserve exact error/custody/lifetime semantics and old users. Unexpected failures remain failures; a passing local test is not cross-platform or whole-library security certification.

**Verification.** Generic Engine/Driver tests, independent SSL/TCP consumers, exact backend/runtime checks and relevant source hashes; rerun only affected gates.

**Next actionable work.** WP01 adds target-aware external consumers as needed to catch missing transitive link propagation.

**Declared surface / navigation:** `build`; `std`; `target`; `optimize`; `dep`; `mod`; `exe`.


<a id="file-examples-consumer-build-zig-zon"></a>

## `examples/consumer/build.zig.zon`

**Responsibility.** Consumer package identity and relative library dependency.

**Contract and ownership.** Separate package boundary tests exported metadata/imports rather than direct source inclusion.

**Failure/change obligations.** Preserve exact error/custody/lifetime semantics and old users. Unexpected failures remain failures; a passing local test is not cross-platform or whole-library security certification.

**Verification.** Generic Engine/Driver tests, independent SSL/TCP consumers, exact backend/runtime checks and relevant source hashes; rerun only affected gates.

**Next actionable work.** Retain clean consumer qualification when changing root build metadata.


<a id="file-examples-consumer-main-zig"></a>

## `examples/consumer/main.zig`

**Responsibility.** Real TCP client/server and early-response demonstration host.

**Contract and ownership.** Own socket/Driver/cancellation thread and bounded response storage; public fixtures, frozen clock and demo flags are test policy. Maintain early-response ciphertext custody and shared shutdown deadline.

**Failure/change obligations.** Preserve exact error/custody/lifetime semantics and old users. Unexpected failures remain failures; a passing local test is not cross-platform or whole-library security certification.

**Verification.** Generic Engine/Driver tests, independent SSL/TCP consumers, exact backend/runtime checks and relevant source hashes; rerun only affected gates.

**Next actionable work.** Use as behavioral reference for WP03, not a source of production HTTP, address or credential defaults.

**Declared surface / navigation:** `demo_open`; `demo_accept`; `demo_close`; `demo_send`; `demo_recv`; `demo_poll`; `demo_now`; `demo_name`; `demo_client_ca`; `demo_sleep`; `demo_setting`; `send`; `recv`; `run`; `cancelLater`; `main`; `upload`; `serve`; `std`; `tls`; `Network`; `len`; `n`; `result`; `now`; `started`; `cancel_ms`; `close_deadline`; `deadline`; `progress`; `request_deadline`; `reply`; `response_deadline`; `end`.


<a id="file-examples-consumer-socket-c"></a>

## `examples/consumer/socket.c`

**Responsibility.** Windows demonstration socket adapter shared by the current audio probe.

**Contract and ownership.** Loopback-only connect/listen, nonblocking poll, forced 7-byte sends and 113-byte receives; returns explicit would-block and owns WSA/socket cleanup.

**Failure/change obligations.** Preserve exact error/custody/lifetime semantics and old users. Unexpected failures remain failures; a passing local test is not cross-platform or whole-library security certification.

**Verification.** Generic Engine/Driver tests, independent SSL/TCP consumers, exact backend/runtime checks and relevant source hashes; rerun only affected gates.

**Next actionable work.** WP03 creates real platform adapters. Modifying this pinned shared fixture requires explicit transport-lock adoption and all consumers retested.

**Declared surface / navigation:** `demo_accept`; `demo_open`; `demo_close`; `demo_send`; `demo_recv`; `demo_poll`; `demo_sleep`; `demo_setting`; `demo_now`.


<a id="file-examples-roundtrip-zig"></a>

## `examples/roundtrip.zig`

**Responsibility.** Minimal serialized TLS example under public test credentials.

**Contract and ownership.** Shows Engine pumping and authenticated data/close; never supplies production pairing, sockets or trust-store policy.

**Failure/change obligations.** Preserve exact error/custody/lifetime semantics and old users. Unexpected failures remain failures; a passing local test is not cross-platform or whole-library security certification.

**Verification.** Generic Engine/Driver tests, independent SSL/TCP consumers, exact backend/runtime checks and relevant source hashes; rerun only affected gates.

**Next actionable work.** Retain as generic library consumer; do not turn it into the audio product entry point.

**Declared surface / navigation:** `pump`; `main`; `std`; `tls`; `n`; `request`; `response`.


<a id="file-handoff-shutdown-md"></a>

## `HANDOFF-shutdown.md`

**Responsibility.** Historical engineering context: Shutdown correction — September 13, 2026.

**Contract and ownership.** Dated workflow/evidence observations; never independent authorization to execute commands or change unrelated repositories.

**Failure/change obligations.** Do not duplicate conflicting protocol/API meaning or imply unexecuted platform support. Preserve useful history and label superseded claims rather than erasing evidence.

**Verification.** Validate local navigation and file index, compare referenced source behavior and evidence dates/hashes; prose quality requires review beyond automated checks.

**Next actionable work.** Read the declared sections below; update this guide whenever its owned contract changes and link to granular implementation/verification obligations.

**Declared surface / navigation:** `Shutdown correction — September 13, 2026`.


<a id="file-handoff-tcp-consumer-md"></a>

## `HANDOFF-tcp-consumer.md`

**Responsibility.** Historical engineering context: Separate consumer over TCP — September 14, 2026.

**Contract and ownership.** Dated workflow/evidence observations; never independent authorization to execute commands or change unrelated repositories.

**Failure/change obligations.** Do not duplicate conflicting protocol/API meaning or imply unexecuted platform support. Preserve useful history and label superseded claims rather than erasing evidence.

**Verification.** Validate local navigation and file index, compare referenced source behavior and evidence dates/hashes; prose quality requires review beyond automated checks.

**Next actionable work.** Read the declared sections below; update this guide whenever its owned contract changes and link to granular implementation/verification obligations.

**Declared surface / navigation:** `Separate consumer over TCP — September 14, 2026`.


<a id="file-host-driver-md"></a>

## `HOST-DRIVER.md`

**Responsibility.** Authoritative scoped guide: Nonblocking TLS host driver.

**Contract and ownership.** Keep terminology, existing versus proposed behavior, source paths and acceptance claims synchronized with the owning implementation/work package.

**Failure/change obligations.** Do not duplicate conflicting protocol/API meaning or imply unexecuted platform support. Preserve useful history and label superseded claims rather than erasing evidence.

**Verification.** Validate local navigation and file index, compare referenced source behavior and evidence dates/hashes; prose quality requires review beyond automated checks.

**Next actionable work.** Read the declared sections below; update this guide whenever its owned contract changes and link to granular implementation/verification obligations.

**Declared surface / navigation:** `Nonblocking TLS host driver`; `Early-response probe (0.1.4)`.


<a id="file-readme-md"></a>

## `README.md`

**Responsibility.** Authoritative scoped guide: tls-zig revision 2 — private OpenSSL 3.5.8 backend.

**Contract and ownership.** Keep terminology, existing versus proposed behavior, source paths and acceptance claims synchronized with the owning implementation/work package.

**Failure/change obligations.** Do not duplicate conflicting protocol/API meaning or imply unexecuted platform support. Preserve useful history and label superseded claims rather than erasing evidence.

**Verification.** Validate local navigation and file index, compare referenced source behavior and evidence dates/hashes; prose quality requires review beyond automated checks.

**Next actionable work.** Read the declared sections below; update this guide whenever its owned contract changes and link to granular implementation/verification obligations.

**Declared surface / navigation:** `tls-zig revision 2 — private OpenSSL 3.5.8 backend`; `Run`; `Separate TCP consumer`; `Verified current source results`; `Host contract`; `Supported profile and limits`; `Design evidence and primary references`.


<a id="file-source-origin-json"></a>

## `SOURCE-ORIGIN.json`

**Responsibility.** Historical relocation provenance for an earlier TLS checkout.

**Contract and ownership.** Its source/target paths and status are dated observations; current user-selected source is C:/Projects/tls-zig.

**Failure/change obligations.** Preserve exact error/custody/lifetime semantics and old users. Unexpected failures remain failures; a passing local test is not cross-platform or whole-library security certification.

**Verification.** Generic Engine/Driver tests, independent SSL/TCP consumers, exact backend/runtime checks and relevant source hashes; rerun only affected gates.

**Next actionable work.** Preserve history; do not move repositories or assume old paths are active instructions.

**Declared surface / navigation:** `schema`; `id`; `source`; `target`; `status`; `source_retained`; `observed_utc`; `selection`; `verification_evidence`; `selection_status`.


<a id="file-src-backend-c"></a>

## `src/backend.c`

**Responsibility.** C implementation of TLS 1.3 using OpenSSL, memory BIOs and owned write/ALPN storage.

**Contract and ownership.** SSL_get_error immediately follows the SSL call. Initialize/free resources once; reject encrypted key prompting, certificate/ALPN mismatch and raw EOF. BIO/write buffers are bounded but OpenSSL total allocations are not. Shutdown preserves peer final plaintext.

**Failure/change obligations.** Preserve exact error/custody/lifetime semantics and old users. Unexpected failures remain failures; a passing local test is not cross-platform or whole-library security certification.

**Verification.** Generic Engine/Driver tests, independent SSL/TCP consumers, exact backend/runtime checks and relevant source hashes; rerun only affected gates.

**Next actionable work.** WP01 changes build/platform integration only unless a demonstrated API issue requires a separately tested backend change. Keep generic HTTP compatibility.

**Declared surface / navigation:** `no_password`; `select_alpn`; `info`; `result`; `tz_free`; `tz_handshake`; `tz_feed`; `tz_drain`; `tz_read`; `tz_write`; `tz_flush`; `tz_shutdown`; `tz_eof`; `tz_verify_error`; `tz_reason`; `tz_alert`.


<a id="file-src-backend-h"></a>

## `src/backend.h`

**Responsibility.** Small stable C ABI including old HTTP-default constructor and configurable ALPN constructor.

**Contract and ownership.** Status integers, pointer optionality, sizes and ownership must agree exactly with backend.zig and the C implementation.

**Failure/change obligations.** Preserve exact error/custody/lifetime semantics and old users. Unexpected failures remain failures; a passing local test is not cross-platform or whole-library security certification.

**Verification.** Generic Engine/Driver tests, independent SSL/TCP consumers, exact backend/runtime checks and relevant source hashes; rerun only affected gates.

**Next actionable work.** For ABI changes update C/Zig/ctypes consumers together and add independent compatibility tests; preserve old constructor behavior.

**Declared surface / navigation:** `tz_free`; `tz_handshake`; `tz_feed`; `tz_drain`; `tz_read`; `tz_write`; `tz_flush`; `tz_shutdown`; `tz_eof`; `tz_verify_error`; `tz_reason`; `tz_alert`.


<a id="file-src-backend-zig"></a>

## `src/backend.zig`

**Responsibility.** Manually maintained Zig extern mirror of backend.h.

**Contract and ownership.** Opaque Engine pointers have one owner; c_int/c_long/c_ulong/usize types follow target C ABI. Do not assume Windows C long width on Mac.

**Failure/change obligations.** Preserve exact error/custody/lifetime semantics and old users. Unexpected failures remain failures; a passing local test is not cross-platform or whole-library security certification.

**Verification.** Generic Engine/Driver tests, independent SSL/TCP consumers, exact backend/runtime checks and relevant source hashes; rerun only affected gates.

**Next actionable work.** WP01 explicitly validates Darwin ABI widths/signatures and links an external C/Zig consumer.

**Declared surface / navigation:** `tz_new`; `tz_new_with_alpn`; `tz_free`; `tz_handshake`; `tz_feed`; `tz_drain`; `tz_read`; `tz_write`; `tz_flush`; `tz_shutdown`; `tz_eof`; `tz_verify_error`; `tz_reason`; `tz_alert`; `tz_version`; `tz_engine`.


<a id="file-src-driver-zig"></a>

## `src/driver.zig`

**Responsibility.** One-owner nonblocking TLS/transport scheduler with bounded byte custody.

**Contract and ownership.** Transport send null means would-block and zero fails; receive zero means EOF. beginRead borrows output until final result; beginWrite copies into Engine. step performs bounded driver work, preserves suffixes and absolute deadlines. probePeer preserves pending ciphertext; only cancellation flag is shared.

**Failure/change obligations.** Preserve exact error/custody/lifetime semantics and old users. Unexpected failures remain failures; a passing local test is not cross-platform or whole-library security certification.

**Verification.** Generic Engine/Driver tests, independent SSL/TCP consumers, exact backend/runtime checks and relevant source hashes; rerun only affected gates.

**Next actionable work.** WP03 supplies real cross-platform socket hosts; WP04 must use fresh times, cancellation wake and ownership joins instead of concurrent Engine access.

**Declared surface / navigation:** `init`; `deinit`; `cancel`; `abort`; `check`; `idle`; `begin`; `beginHandshake`; `beginWrite`; `beginRead`; `beginShutdown`; `beginFlush`; `probePeer`; `step`; `std`; `tls`; `Transport`; `Error`; `Result`; `ProbeResult`; `Driver`; `Operation`; `r`; `n`; `op`; `progress`; `bytes`.


<a id="file-src-root-zig"></a>

## `src/root.zig`

**Responsibility.** Public Engine API, validation, error/progress translation and ownership.

**Contract and ownership.** Config strings/ALPN are copied/consumed during init; Engine is move-only and serialized. tick enforces monotonic handshake time, queuePlaintext owns a nonempty <=16 KiB block, feed/drain preserve exact prefixes, shutdown distinguishes unread final plaintext from authenticated closure. cancel/deinit are idempotent.

**Failure/change obligations.** Preserve exact error/custody/lifetime semantics and old users. Unexpected failures remain failures; a passing local test is not cross-platform or whole-library security certification.

**Verification.** Generic Engine/Driver tests, independent SSL/TCP consumers, exact backend/runtime checks and relevant source hashes; rerun only affected gates.

**Next actionable work.** WP01 preserves API semantics across native platforms. Peer policy belongs to the product; do not weaken name/CA/ALPN validation or deadlines.

**Declared surface / navigation:** `init`; `ptr`; `live`; `status`; `tick`; `handshake`; `feedRecords`; `drainRecords`; `readPlaintext`; `queuePlaintext`; `flushPlaintext`; `shutdown`; `transportEof`; `diagnostics`; `cancel`; `deinit`; `backendVersion`; `std`; `c`; `host`; `Driver`; `Error`; `Progress`; `Transfer`; `Role`; `Identity`; `Config`; `Diagnostics`; `Engine`; `deadline`; `value`; `h`; `p`; `alert`.


<a id="file-tests-driver-zig"></a>

## `tests/driver.zig`

**Responsibility.** Eleven host-driver tests including prefix custody, probing, deadlines and cancellation.

**Contract and ownership.** Fake transports inject would-block, short I/O, invalid counts and raw EOF; snapshots ensure unsent data/deadline stay unchanged.

**Failure/change obligations.** Preserve exact error/custody/lifetime semantics and old users. Unexpected failures remain failures; a passing local test is not cross-platform or whole-library security certification.

**Verification.** Generic Engine/Driver tests, independent SSL/TCP consumers, exact backend/runtime checks and relevant source hashes; rerun only affected gates.

**Next actionable work.** Add real host cancellation/reconnect cases in product tests while preserving these independent generic contracts.

**Declared surface / navigation:** `transport`; `send`; `recv`; `init`; `deinit`; `handshake`; `finish`; `probe`; `std`; `tls`; `expect`; `equal`; `expectError`; `Result`; `Pipe`; `Socket`; `pipe`; `n`; `Pair`; `result`; `start`; `end`; `ciphertext`; `early`; `r`; `first`; `second`; `calls`; `sends`; `recvs`; `peer probe observes early response without changing blocked ciphertext or deadline`; `peer probe during blocked write honors cancel deadline and raw EOF`; `idle probe output flush preserves order before next application write`; `host driver preserves partial writes and received suffixes across reads`; `host shutdown preserves deadline across final plaintext reads and rejects raw EOF`; `host operation deadline expires despite slow transport progress`; `atomic cancellation stops blocked reads and writes without touching transport`; `host cannot extend a shutdown deadline by switching to read`; `host rejects invalid transport counts and backward clocks`; `host authentication failure flushes fragmented alert and retains diagnostics`; `host raw EOF during handshake is terminal even when alert delivery blocks`.


<a id="file-tests-fixtures-ca-pem"></a>

## `tests/fixtures/ca.pem`

**Responsibility.** Public test certificate for trusted fixture authority.

**Contract and ownership.** Fixture bytes belong only to bounded local tests; identity, validity and key/certificate relationships are deliberate negative/positive inputs.

**Failure/change obligations.** Never deploy, copy into a product trust store or silently regenerate. Do not print private-key contents in diagnostics even though these fixtures are public.

**Verification.** tools/make_fixtures.py documents generation; TLS and independent peers check the corresponding auth/expiry/purpose case; downstream transport lock covers adopted bytes.

**Next actionable work.** WP03 provisions separate real credentials and rejects fixture defaults; deliberate fixture regeneration needs reviewed hashes and regression evidence.


<a id="file-tests-fixtures-client-key"></a>

## `tests/fixtures/client.key`

**Responsibility.** Public test private-key material for client authentication identity.

**Contract and ownership.** Fixture bytes belong only to bounded local tests; identity, validity and key/certificate relationships are deliberate negative/positive inputs.

**Failure/change obligations.** Never deploy, copy into a product trust store or silently regenerate. Do not print private-key contents in diagnostics even though these fixtures are public.

**Verification.** tools/make_fixtures.py documents generation; TLS and independent peers check the corresponding auth/expiry/purpose case; downstream transport lock covers adopted bytes.

**Next actionable work.** WP03 provisions separate real credentials and rejects fixture defaults; deliberate fixture regeneration needs reviewed hashes and regression evidence.


<a id="file-tests-fixtures-client-pem"></a>

## `tests/fixtures/client.pem`

**Responsibility.** Public test certificate for client authentication identity.

**Contract and ownership.** Fixture bytes belong only to bounded local tests; identity, validity and key/certificate relationships are deliberate negative/positive inputs.

**Failure/change obligations.** Never deploy, copy into a product trust store or silently regenerate. Do not print private-key contents in diagnostics even though these fixtures are public.

**Verification.** tools/make_fixtures.py documents generation; TLS and independent peers check the corresponding auth/expiry/purpose case; downstream transport lock covers adopted bytes.

**Next actionable work.** WP03 provisions separate real credentials and rejects fixture defaults; deliberate fixture regeneration needs reviewed hashes and regression evidence.


<a id="file-tests-fixtures-expired-key"></a>

## `tests/fixtures/expired.key`

**Responsibility.** Public test private-key material for deliberately expired server identity.

**Contract and ownership.** Fixture bytes belong only to bounded local tests; identity, validity and key/certificate relationships are deliberate negative/positive inputs.

**Failure/change obligations.** Never deploy, copy into a product trust store or silently regenerate. Do not print private-key contents in diagnostics even though these fixtures are public.

**Verification.** tools/make_fixtures.py documents generation; TLS and independent peers check the corresponding auth/expiry/purpose case; downstream transport lock covers adopted bytes.

**Next actionable work.** WP03 provisions separate real credentials and rejects fixture defaults; deliberate fixture regeneration needs reviewed hashes and regression evidence.


<a id="file-tests-fixtures-expired-pem"></a>

## `tests/fixtures/expired.pem`

**Responsibility.** Public test certificate for deliberately expired server identity.

**Contract and ownership.** Fixture bytes belong only to bounded local tests; identity, validity and key/certificate relationships are deliberate negative/positive inputs.

**Failure/change obligations.** Never deploy, copy into a product trust store or silently regenerate. Do not print private-key contents in diagnostics even though these fixtures are public.

**Verification.** tools/make_fixtures.py documents generation; TLS and independent peers check the corresponding auth/expiry/purpose case; downstream transport lock covers adopted bytes.

**Next actionable work.** WP03 provisions separate real credentials and rejects fixture defaults; deliberate fixture regeneration needs reviewed hashes and regression evidence.


<a id="file-tests-fixtures-other-ca-pem"></a>

## `tests/fixtures/other-ca.pem`

**Responsibility.** Public test certificate for unrelated authority used for rejection.

**Contract and ownership.** Fixture bytes belong only to bounded local tests; identity, validity and key/certificate relationships are deliberate negative/positive inputs.

**Failure/change obligations.** Never deploy, copy into a product trust store or silently regenerate. Do not print private-key contents in diagnostics even though these fixtures are public.

**Verification.** tools/make_fixtures.py documents generation; TLS and independent peers check the corresponding auth/expiry/purpose case; downstream transport lock covers adopted bytes.

**Next actionable work.** WP03 provisions separate real credentials and rejects fixture defaults; deliberate fixture regeneration needs reviewed hashes and regression evidence.


<a id="file-tests-fixtures-server-key"></a>

## `tests/fixtures/server.key`

**Responsibility.** Public test private-key material for localhost/IP server identity.

**Contract and ownership.** Fixture bytes belong only to bounded local tests; identity, validity and key/certificate relationships are deliberate negative/positive inputs.

**Failure/change obligations.** Never deploy, copy into a product trust store or silently regenerate. Do not print private-key contents in diagnostics even though these fixtures are public.

**Verification.** tools/make_fixtures.py documents generation; TLS and independent peers check the corresponding auth/expiry/purpose case; downstream transport lock covers adopted bytes.

**Next actionable work.** WP03 provisions separate real credentials and rejects fixture defaults; deliberate fixture regeneration needs reviewed hashes and regression evidence.


<a id="file-tests-fixtures-server-pem"></a>

## `tests/fixtures/server.pem`

**Responsibility.** Public test certificate for localhost/IP server identity.

**Contract and ownership.** Fixture bytes belong only to bounded local tests; identity, validity and key/certificate relationships are deliberate negative/positive inputs.

**Failure/change obligations.** Never deploy, copy into a product trust store or silently regenerate. Do not print private-key contents in diagnostics even though these fixtures are public.

**Verification.** tools/make_fixtures.py documents generation; TLS and independent peers check the corresponding auth/expiry/purpose case; downstream transport lock covers adopted bytes.

**Next actionable work.** WP03 provisions separate real credentials and rejects fixture defaults; deliberate fixture regeneration needs reviewed hashes and regression evidence.


<a id="file-tests-fixtures-wrong-purpose-key"></a>

## `tests/fixtures/wrong-purpose.key`

**Responsibility.** Public test private-key material for client-only purpose presented as a server.

**Contract and ownership.** Fixture bytes belong only to bounded local tests; identity, validity and key/certificate relationships are deliberate negative/positive inputs.

**Failure/change obligations.** Never deploy, copy into a product trust store or silently regenerate. Do not print private-key contents in diagnostics even though these fixtures are public.

**Verification.** tools/make_fixtures.py documents generation; TLS and independent peers check the corresponding auth/expiry/purpose case; downstream transport lock covers adopted bytes.

**Next actionable work.** WP03 provisions separate real credentials and rejects fixture defaults; deliberate fixture regeneration needs reviewed hashes and regression evidence.


<a id="file-tests-fixtures-wrong-purpose-pem"></a>

## `tests/fixtures/wrong-purpose.pem`

**Responsibility.** Public test certificate for client-only purpose presented as a server.

**Contract and ownership.** Fixture bytes belong only to bounded local tests; identity, validity and key/certificate relationships are deliberate negative/positive inputs.

**Failure/change obligations.** Never deploy, copy into a product trust store or silently regenerate. Do not print private-key contents in diagnostics even though these fixtures are public.

**Verification.** tools/make_fixtures.py documents generation; TLS and independent peers check the corresponding auth/expiry/purpose case; downstream transport lock covers adopted bytes.

**Next actionable work.** WP03 provisions separate real credentials and rejects fixture defaults; deliberate fixture regeneration needs reviewed hashes and regression evidence.


<a id="file-tests-transport-zig"></a>

## `tests/transport.zig`

**Responsibility.** Nineteen Engine tests for config, identity, ALPN, bytes, bounds and authenticated closure.

**Contract and ownership.** Test fixtures and frozen verification time are deterministic test inputs; preserve tamper/no-plaintext, suffix and blocked-close cases.

**Failure/change obligations.** Preserve exact error/custody/lifetime semantics and old users. Unexpected failures remain failures; a passing local test is not cross-platform or whole-library security certification.

**Verification.** Generic Engine/Driver tests, independent SSL/TCP consumers, exact backend/runtime checks and relevant source hashes; rerun only affected gates.

**Next actionable work.** Keep existing 19 cases during target port; add Mac-specific ABI/runtime regressions rather than weakening assertions.

**Declared surface / navigation:** `clientConfig`; `serverConfig`; `transfer`; `handshake`; `connected`; `std`; `tls`; `expect`; `equal`; `expectError`; `now`; `n`; `request`; `r`; `response`; `local`; `peer`; `available`; `end`; `expected`; `read`; `custom ALPN is owned by each connection and bounds are checked`; `ALPN mismatch rejects handshake before application data`; `opaque ALPN accepts the maximum legal identifier`; `qualified runtime backend is OpenSSL 3.5.8`; `TLS13 HTTP1 roundtrip with single-byte handshake fragments`; `wrong DNS name fails before application access`; `explicit trust excludes an unrelated CA`; `expired certificate and future validity use supplied wall time`; `client-only EKU cannot authenticate a server`; `IP SAN succeeds and wrong IP fails`; `mTLS requires a trusted client certificate`; `AEAD record tampering is terminal and releases no plaintext`; `clean close_notify differs from raw EOF and truncated record`; `shutdown preserves final records in both roles and still rejects truncation`; `shutdown retries a blocked close alert before reading final peer data`; `bounded output retains write data across WANT_WRITE`; `input bounds, empty input, and explicit EOF`; `absolute deadline, backward clock, and idempotent cancel`; `invalid configuration and mismatched credentials fail at creation`.


<a id="file-tools-build-openssl-sh"></a>

## `tools/build-openssl.sh`

**Responsibility.** Reproduces the historical Windows SDK build with explicit local toolchain paths.

**Contract and ownership.** Uses isolated build/install paths, shared TLS without QUIC, one-job native make and exact compiler/shell configuration.

**Failure/change obligations.** Preserve exact error/custody/lifetime semantics and old users. Unexpected failures remain failures; a passing local test is not cross-platform or whole-library security certification.

**Verification.** Generic Engine/Driver tests, independent SSL/TCP consumers, exact backend/runtime checks and relevant source hashes; rerun only affected gates.

**Next actionable work.** WP01 needs a distinct Mac build path; do not reuse mingw flags or overwrite a functioning SDK during qualification.


<a id="file-tools-check-docs-py"></a>

## `tools/check-docs.py`

**Responsibility.** Runner for documentation and source inventory integrity with negative controls.

**Contract and ownership.** Read-only exact source/declaration-location/contract/artifact/link gate with safe path validation and optional SDK custody. Temporary-copy negative controls must not mutate the live checkout; it performs no builds or pin repairs.

**Failure/change obligations.** Missing/stale files, unsafe manifest paths, incomplete contracts, broken local links and custody changes fail unconditionally. Negative controls must fail for the intended reason and preserve live project bytes.

**Verification.** Run tls-zig/tools/check-docs.py with its declared options and review the named source/test/receipt; application coverage checks establish navigation only.

**Next actionable work.** Keep source inventory and artifact registration synchronized after reviewed changes; use --self-test --with-sdk on the actual adopted checkout.

**Declared surface / navigation:** `digest`; `safe`; `universe`; `check`; `check_contents`; `self_test`; `main`.


<a id="file-tools-check-event-model-py"></a>

## `tools/check-event-model.py`

**Responsibility.** Finite proposed TLS event-custody safety explorer.

**Contract and ownership.** Serialized queue/copy/ack/cancel model with capacities 1 and 2 and three emissions; ghost ledgers and an independent acknowledgement transition check. See [owner contract](../../../tls-zig/docs/reference/files/tools/check-event-model.py.md).

**Failure/change obligations.** Preserve planned, implemented and historically observed status. Source changes require a new owner receipt; no silent application trust/pin adoption.

**Verification.** Run the owner tool and retain state counts/counterexample traces for overwrite, stale/foreign ACK and early ACK. No TLS implementation, liveness or refinement proof.

**Next actionable work.** Continue through the owning dependency work package; application policy and credentials stay in LAN Audio.

**Declared surface / navigation:** `successors`; `invariant`; `transition_invariant`; `explore`; `main`.


<a id="file-tools-check-models-py"></a>

## `tools/check-models.py`

**Responsibility.** Runner for finite abstract safety models with injected-fault counterexamples.

**Contract and ownership.** Breadth-first enumeration of three finite independent safety models: ACK tickets, late-ACK retransmission custody and authenticated TLS shutdown. Returns counterexample traces; no Zig/C execution or liveness/refinement proof. See [dependency-owned contract](../../../tls-zig/docs/reference/files/tools/check-models.py.md).

**Failure/change obligations.** A correct-model invariant violation or an undetected injected defect fails. Small hardcoded domains bound this explorer; larger inputs need an explicit resource budget.

**Verification.** Run tls-zig/tools/check-docs.py with its declared options and review the named source/test/receipt; application coverage checks establish navigation only.

**Next actionable work.** Maintain each model against its named invariant and concrete source obligations; retain raw good/bad traces and do not infer audio runtime correctness from these separate models.

**Declared surface / navigation:** `explore`; `ack_model`; `custody_model`; `shutdown_model`; `main`.


<a id="file-tools-check-plan-py"></a>

## `tools/check-plan.py`

**Responsibility.** Exact file lifecycle, dependency and acceptance evidence checker.

**Contract and ownership.** Validates schema-2 planned/in-progress/implemented/complete states, paths, acyclic prerequisites, source/card consistency and source/obligation/log/peer-receipt hashes for completion. Complete shared plans require peer verification. See [owner contract](../../../tls-zig/docs/reference/files/tools/check-plan.py.md).

**Failure/change obligations.** Preserve planned, implemented and historically observed status. Source changes require a new owner receipt; no silent application trust/pin adoption.

**Verification.** Run --self-test and synthetic lifecycle checks. Receipt consistency cannot establish that commands actually ran or prove the semantic completeness of a claimed implementation.

**Next actionable work.** Continue through the owning dependency work package; application policy and credentials stay in LAN Audio.

**Declared surface / navigation:** `relative`; `validate`; `fingerprint`; `checked_file`; `evidence_check`; `local_check`; `self_test`; `main`.


<a id="file-tools-fetch-openssl-py"></a>

## `tools/fetch-openssl.py`

**Responsibility.** Downloads the exact adopted upstream archive using HTTPS ranges and final hash.

**Contract and ownership.** Validates response range/length, bounded retries and final SHA-256 before extracting with data-only tar filtering; writes under deps.

**Failure/change obligations.** Preserve exact error/custody/lifetime semantics and old users. Unexpected failures remain failures; a passing local test is not cross-platform or whole-library security certification.

**Verification.** Generic Engine/Driver tests, independent SSL/TCP consumers, exact backend/runtime checks and relevant source hashes; rerun only affected gates.

**Next actionable work.** Only use for explicit rebuild/adoption. Existing checkout has SDK only; no source audit can be inferred from absent source trees.


<a id="file-tools-interop-py"></a>

## `tools/interop.py`

**Responsibility.** Independent Python SSL peer against the C ABI with runtime path checks.

**Contract and ownership.** Loads specified backend and verifies DLL identity; exchanges fragmented records, validates TLS/auth/ALPN/closure and pending final data.

**Failure/change obligations.** Preserve exact error/custody/lifetime semantics and old users. Unexpected failures remain failures; a passing local test is not cross-platform or whole-library security certification.

**Verification.** Generic Engine/Driver tests, independent SSL/TCP consumers, exact backend/runtime checks and relevant source hashes; rerun only affected gates.

**Next actionable work.** Run during TLS port/change; preserve old-C-ABI and independent-provider checks.

**Declared surface / navigation:** `python_peer`; `exchange`; `connect`; `case`; `final_data_during_shutdown`; `in`.


<a id="file-tools-make-fixtures-py"></a>

## `tools/make_fixtures.py`

**Responsibility.** Regenerates public certificate/key fixtures for isolated tests.

**Contract and ownership.** Writes test credentials with deliberate identity/purpose/validity differences; these private keys are public examples, never deployable identities.

**Failure/change obligations.** Preserve exact error/custody/lifetime semantics and old users. Unexpected failures remain failures; a passing local test is not cross-platform or whole-library security certification.

**Verification.** Generic Engine/Driver tests, independent SSL/TCP consumers, exact backend/runtime checks and relevant source hashes; rerun only affected gates.

**Next actionable work.** Do not run as routine verification: replacement changes pinned fixture bytes. Review intended dates/identities and requalify all users on deliberate regeneration.

**Declared surface / navigation:** `issue`.


<a id="file-tools-pin-backend-py"></a>

## `tools/pin-backend.py`

**Responsibility.** Explicit adoption writer for SDK and historical build-tool hashes.

**Contract and ownership.** Runs private openssl version and records SDK/tool identities into backend-lock.json; unlike verifiers it intentionally mutates custody.

**Failure/change obligations.** Preserve exact error/custody/lifetime semantics and old users. Unexpected failures remain failures; a passing local test is not cross-platform or whole-library security certification.

**Verification.** Generic Engine/Driver tests, independent SSL/TCP consumers, exact backend/runtime checks and relevant source hashes; rerun only affected gates.

**Next actionable work.** Never run to repair a mismatch. Review rebuilt artifacts/provenance first, then adopt and update downstream pins explicitly.

**Declared surface / navigation:** `sha256`.


<a id="file-tools-probe-quic-tls-c"></a>

## `tools/probe-quic-tls.c`

**Responsibility.** Test-only initial external QUIC TLS callback probe.

**Contract and ownership.** Bounded ClientHello capture, full/partial/failing output callbacks; requires no completed handshake or peer authentication. No network/device activity or production recordless API. See [owner contract](../../../tls-zig/docs/reference/files/tools/probe-quic-tls.c.md).

**Failure/change obligations.** Preserve planned, implemented and historically observed status. Source changes require a new owner receipt; no silent application trust/pin adoption.

**Verification.** Interpret full, backpressure and fatal-send observations only as initial provider capability; authenticated peer handshake, secrets and transport integration remain open.

**Next actionable work.** Continue through the owning dependency work package; application policy and credentials stay in LAN Audio.

**Declared surface / navigation:** `send_crypto`; `receive_crypto`; `release_crypto`; `yield_secret`; `peer_parameters`; `alert`; `main`.


<a id="file-tools-probe-quic-tls-py"></a>

## `tools/probe-quic-tls.py`

**Responsibility.** Source-bound Windows SDK probe runner.

**Contract and ownership.** Verifies exact backend-lock SDK closure/compiler, stages locked DLLs into new scratch, compiles the C probe and bounds execution; never refreshes pins. See [owner contract](../../../tls-zig/docs/reference/files/tools/probe-quic-tls.py.md).

**Failure/change obligations.** Preserve planned, implemented and historically observed status. Source changes require a new owner receipt; no silent application trust/pin adoption.

**Verification.** Check SDK/source/runtime hashes and all three case outcomes; reject existing output or drift. Preserve compilation/failure logs and do not promote callback success to authenticated QUIC.

**Next actionable work.** Continue through the owning dependency work package; application policy and credentials stay in LAN Audio.

**Declared surface / navigation:** `digest`; `run`; `main`.


<a id="file-tools-qualify-ps1"></a>

## `tools/qualify.ps1`

**Responsibility.** Windows qualification orchestration with scoped runtime paths/cache and retained logs.

**Contract and ownership.** Saves/restores process environment in finally; verifies compiler/SDK hashes before test/host-test/interop/example and formatting.

**Failure/change obligations.** Preserve exact error/custody/lifetime semantics and old users. Unexpected failures remain failures; a passing local test is not cross-platform or whole-library security certification.

**Verification.** Generic Engine/Driver tests, independent SSL/TCP consumers, exact backend/runtime checks and relevant source hashes; rerun only affected gates.

**Next actionable work.** Its message suggesting pin-backend is not permission to rehash changed bytes. Add target-aware qualification rather than weakening custody checks.


<a id="file-tools-tcp-interop-py"></a>

## `tools/tcp_interop.py`

**Responsibility.** Independent Python TCP server testing downstream client.

**Contract and ownership.** Own ephemeral listener/thread/process; bounded deadlines and exact response/clean-close/error expectations.

**Failure/change obligations.** Preserve exact error/custody/lifetime semantics and old users. Unexpected failures remain failures; a passing local test is not cross-platform or whole-library security certification.

**Verification.** Generic Engine/Driver tests, independent SSL/TCP consumers, exact backend/runtime checks and relevant source hashes; rerun only affected gates.

**Next actionable work.** Extend target executable/path selection for Mac without loosening error or cleanup oracles.

**Declared surface / navigation:** `case`; `in`.


<a id="file-tools-tcp-server-interop-py"></a>

## `tools/tcp_server_interop.py`

**Responsibility.** Independent Python TCP client testing downstream server roles.

**Contract and ownership.** Consume actual assigned port; require client certificate rejection, exact fragmented response and authenticated closure; join reader and process.

**Failure/change obligations.** Preserve exact error/custody/lifetime semantics and old users. Unexpected failures remain failures; a passing local test is not cross-platform or whole-library security certification.

**Verification.** Generic Engine/Driver tests, independent SSL/TCP consumers, exact backend/runtime checks and relevant source hashes; rerun only affected gates.

**Next actionable work.** Retain missing/untrusted-client and raw-EOF cases through backend or runtime changes.

**Declared surface / navigation:** `case`; `in`.


<a id="file-tools-tcp-upload-interop-py"></a>

## `tools/tcp_upload_interop.py`

**Responsibility.** Early final response while ciphertext transmission is deliberately blocked.

**Contract and ownership.** Require observed early headers, retained accepted first body block, no second block, bounded cancel/deadline and clean/unclean close distinctions.

**Failure/change obligations.** Preserve exact error/custody/lifetime semantics and old users. Unexpected failures remain failures; a passing local test is not cross-platform or whole-library security certification.

**Verification.** Generic Engine/Driver tests, independent SSL/TCP consumers, exact backend/runtime checks and relevant source hashes; rerun only affected gates.

**Next actionable work.** Keep as regression for any scheduling or probePeer change; application-level response policy remains caller-owned.

**Declared surface / navigation:** `case`; `in`.


<a id="file-tools-test-openssl-sh"></a>

## `tools/test-openssl.sh`

**Responsibility.** Runs selected upstream TLS/certificate recipes with known Windows Perl/make adaptations.

**Contract and ownership.** Mutates generated build metadata/wrapper paths, not adopted upstream source; preserves metadata timestamps; does not claim full upstream test coverage.

**Failure/change obligations.** Preserve exact error/custody/lifetime semantics and old users. Unexpected failures remain failures; a passing local test is not cross-platform or whole-library security certification.

**Verification.** Generic Engine/Driver tests, independent SSL/TCP consumers, exact backend/runtime checks and relevant source hashes; rerun only affected gates.

**Next actionable work.** Record exact source/build/tool prerequisites before running; unavailable historical paths require a deliberate reproduction plan.


<a id="file-tools-test-plan-lifecycle-py"></a>

## `tools/test-plan-lifecycle.py`

**Responsibility.** Disposable synthetic tests for completion-receipt validation.

**Contract and ownership.** Creates two temporary projects with clearly synthetic source/log/receipt bytes; exercises consistent completion and reopening plus malformed/stale/incomplete evidence. Never counts synthetic logs as real protocol execution. See [owner contract](../../../tls-zig/docs/reference/files/tools/test-plan-lifecycle.py.md).

**Failure/change obligations.** Preserve planned, implemented and historically observed status. Source changes require a new owner receipt; no silent application trust/pin adoption.

**Verification.** Run ordinary and optimized Python modes; all declared mutations must be rejected and temporary fixtures must leave live source/pins untouched.

**Next actionable work.** Continue through the owning dependency work package; application policy and credentials stay in LAN Audio.

**Declared surface / navigation:** `digest`; `write`; `fixture`; `verify`; `main`.
