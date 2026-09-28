# miniaudio-zig: granular file contracts

Generated from reviewed `tools/reference_contracts.json`. Edit the contract data, then render; do not edit this chapter alone.


<a id="file-gitignore"></a>

## `.gitignore`

**Responsibility.** Separate generated caches/output from authored source and custody.

**Contract and ownership.** Ignore only reproducible/disposable outputs; do not hide contracts, models, vendored bytes, locks or needed evidence.

**Failure/change obligations.** Broad patterns can hide new source; inspect actual inventory after edits. Ignored status is not permission to delete user data.

**Verification.** Compare source inventory with build outputs and ensure all authored files remain documented.

**Next actionable work.** Add narrowly scoped patterns when new generators require them; keep release inputs explicit.


<a id="file-build-zig"></a>

## `build.zig`

**Responsibility.** Build the production wrapper unchanged and add independent ABI compile/run artifacts plus isolated test-only fault controls.

**Contract and ownership.** Apply matching target/optimization/backend macros to C, translation and probe; test-abi runs five cases, default test runs eight freshly.

**Failure/change obligations.** abi-test-fault affects only the C probe; compiler errors are failures and never become qualified mutation detections.

**Verification.** Four Debug/ReleaseSafe native/null matrix rows each pass clean tests, reject size/profile faults and pass a separate package consumer.

**Next actionable work.** Retain existing exports and production native source/profile; extend selected ABI facts only for newly adopted surfaces.

**Declared surface / navigation:** `build`; `std`; `target`; `optimize`; `null_only`; `abi_fault`; `native`; `translated`; `module`; `tests`; `abi_tests`; `run_abi`; `run_contract`; `check`; `test_step`.


<a id="file-build-zig-zon"></a>

## `build.zig.zon`

**Responsibility.** Own package identity, version/compiler floor, dependency declarations and distribution allowlist.

**Contract and ownership.** ZON is Zig package metadata, distinct from ZSON. Fingerprint is identity, not artifact integrity. Sibling paths are development dependencies and require a release closure.

**Failure/change obligations.** Do not silently rename identities or raise compiler floor; changes need compatibility and clean-checkout evidence. Excluded source/docs must not break packages.

**Verification.** Parse/build with pinned compiler; test package allowlist and downstream import from a clean layout.

**Next actionable work.** WP09 replaces development-only assumptions with reproducible source/package custody and includes all required handoff documents.


<a id="file-docs-architecture-build-and-abi-md"></a>

## `docs/architecture/build-and-abi.md`

**Responsibility.** Explain the production build graph plus independent ABI artifacts and fresh explicit test execution.

**Contract and ownership.** Equal profile inputs are construction invariants; C-produced versus translated facts supply separate measured agreement.

**Failure/change obligations.** A successful profile on one host cannot certify all targets or every exported upstream type.

**Verification.** Check build/test graph, four-profile source-bound results, and absence of production profile/vendor changes.

**Next actionable work.** Keep test mutation macros confined to the probe and qualify each new target independently.

**Declared surface / navigation:** `One import, one profile, one implementation`; `The actual build graph`; `Feature boundary`; `Targets and dependencies`; `Build effects and packaging`.


<a id="file-docs-contract-md"></a>

## `docs/CONTRACT.md`

**Responsibility.** Keep public ownership/PCM rules and identify the independent ABI suite as additional bounded evidence.

**Contract and ownership.** C-produced sizes/alignments/offsets/constants and synthetic callback checks complement device lifetime contracts without replacing them.

**Failure/change obligations.** Matching types and a synchronous sentinel cannot establish native callback quiescence or safe arbitrary C use.

**Verification.** Confirm selected ABI facts with matrix receipts and retain separate real device/lifecycle qualification.

**Next actionable work.** Extend contracts and targeted tests when new types or operations cross the application boundary.

**Declared surface / navigation:** `Binding and device contract`; `Authority and purpose`; `Storage, lifetime and concurrency`; `PCM dimensions and error behavior`; `Capability boundaries and evidence`.


<a id="file-docs-contracts-conversion-control-md"></a>

## `docs/contracts/conversion-control.md`

**Responsibility.** Document and derive consequences of the adopted generic quantizer and stock linear uint32 phase overflow.

**Contract and ownership.** Keep requested/represented/effective ratios explicit; validate finite/range/cast bounds and actual reduced denominators.

**Failure/change obligations.** Large integer rates and the separate direct-linear helper are not automatically safe workarounds; failure atomicity is unproven.

**Verification.** O0/O2 probes reproduce plus/minus100ppm behavior, dynamic enablement and three phase transitions; widened arithmetic supplies expectations.

**Next actionable work.** Evaluate bounded explicit rates, a reviewed source fix or another backend with precision/phase/quality evidence.

**Declared surface / navigation:** `Rate control: representation, phase and adopted-source limitations`; `Three quantities must remain visible`; `R01a: the generic helper is too coarse for a presumed fine actuator`; `R01b: large integer rates are not an automatic precision fix`; `Choosing a future actuator`; `Controller contract before gain selection`.


<a id="file-docs-contracts-conversion-custody-md"></a>

## `docs/contracts/conversion-custody.md`

**Responsibility.** Define two frame-domain ledgers, proposed adapter operations, partial-publication custody and terminal lifecycle.

**Contract and ownership.** A=U+C+Ds and P=H+Q+B+Do; synthetic input and callback silence are separate; native errors do not imply rollback.

**Failure/change obligations.** No-progress is not EOF, null input is not flush, source consumption is not rendered completion, and queue empty is not a fence.

**Verification.** Hand-worked short-write trace and negative arithmetic/fence examples seed independent future adapter tests.

**Next actionable work.** Choose a finite terminal recipe and negotiate compatible converted-output acknowledgement semantics.

**Declared surface / navigation:** `Conversion custody, terminal state and completion`; `Values, buffers and clocks are separate`; `Proposed adapter seam`; `Lifecycle and terminal protocol`; `Worked prefix trace`; `Acknowledgement and discontinuity obligations`.


<a id="file-docs-contracts-device-lifecycle-md"></a>

## `docs/contracts/device-lifecycle.md`

**Responsibility.** Specify stable context/device/userdata ownership, start-time callbacks, enumeration snapshot invalidation and cleanup.

**Contract and ownership.** Callbacks may run before start returns; list pointers expire on refresh; native/control owners retain storage through fences.

**Failure/change obligations.** Start/stop failure preserves acquired-resource obligations; timeouts, queue-empty and notifications do not authorize free.

**Verification.** Q03 fake-native tests must exercise synchronous start callbacks, failed acquisition, refresh and paused callback return.

**Next actionable work.** Apply these obligations to LAN Audio C03, keeping product lifecycle policy out of the raw binding.

**Declared surface / navigation:** `Devices, borrowed lists and callback lifetimes`; `Acquisition ledger and stable storage`; `The start-time callback trap`; `Enumeration has a different ownership boundary`; `Callbacks, diagnostics and completion`.


<a id="file-docs-contracts-pcm-and-conversion-md"></a>

## `docs/contracts/pcm-and-conversion.md`

**Responsibility.** Connect existing frame/partial-count rules to reproduced rate-control constraints and detailed custody/tail contracts.

**Contract and ownership.** Source and output units remain separate; actual native counts govern; successful rate calls alone do not establish precision.

**Failure/change obligations.** Generic quantization and large-denominator phase overflow block naive adaptive control adoption.

**Verification.** Read the source-bound characterization and exact arithmetic examples; no DSP/hardware qualification implied.

**Next actionable work.** Resolve R01 before using either generic ratio or large integer-rate paths in production.

**Declared surface / navigation:** `Frames, conversion and preservation claims`; `Dimensions and representation`; `Partial conversion is normal`; `Conservation and tail accounting`; `Deliberate adoption boundaries`.


<a id="file-docs-dependencies-md"></a>

## `docs/DEPENDENCIES.md`

**Responsibility.** Authoritative scoped guide: Complete dependency boundary for this build profile.

**Contract and ownership.** Keep terminology, existing versus proposed behavior, source paths and acceptance claims synchronized with the owning implementation/work package.

**Failure/change obligations.** Do not duplicate conflicting protocol/API meaning or imply unexecuted platform support. Preserve useful history and label superseded claims rather than erasing evidence.

**Verification.** Validate local navigation and file index, compare referenced source behavior and evidence dates/hashes; prose quality requires review beyond automated checks.

**Next actionable work.** Read the declared sections below; update this guide whenever its owned contract changes and link to granular implementation/verification obligations.

**Declared surface / navigation:** `Complete dependency boundary for this build profile`.


<a id="file-docs-files-md"></a>

## `docs/FILES.md`

**Responsibility.** Keep the original compact role overview accurate alongside the exact every-file catalogue.

**Contract and ownership.** Integrity checks are read-only; explicit qualification runners write evidence; Zig and C probe roles remain distinct.

**Failure/change obligations.** The overview is not the complete current inventory; exploratory evidence is not production source.

**Verification.** Confirm catalogue and handbook navigation, tool responsibilities and unchanged production sources.

**Next actionable work.** Retain shallow source ownership and add real files only with their caller and tests.

**Declared surface / navigation:** `File-by-file ownership and verification`.


<a id="file-docs-implementation-conversion-handoff-md"></a>

## `docs/implementation/conversion-handoff.md`

**Responsibility.** Specify canonical future files, caller/owner boundaries, supporting tests/fixtures and R01-R08 decisions.

**Contract and ownership.** Follow application WP05 src/host native adapter ownership and keep pure clocks/controllers in src/media.

**Failure/change obligations.** Native control precision/phase, quality, END/ACK, resources and targets remain explicit activation gates.

**Verification.** Per-file independent oracles and the ordered fixed-rate-to-adaptive sequence make future work reviewable.

**Next actionable work.** Resolve reproduced R01 constraints in isolation after safe runtime prerequisites, without empty scaffolding.

**Declared surface / navigation:** `Conversion handoff: files, decisions and order of work`; `Ownership and the canonical future layout`; `Decisions that must exist before production activation`; `Smallest coherent implementation sequence`; `Completion record for the next implementer`.


<a id="file-docs-implementation-qualification-md"></a>

## `docs/implementation/qualification.md`

**Responsibility.** Refine Q04 with canonical application host paths, concrete preparation documents and reproduced blockers.

**Contract and ownership.** src/host/resampler.zig matches application WP05; pure media modules must not import the native C surface.

**Failure/change obligations.** Do not create the former conflicting media resampler path or count known-defect reproduction as Q04 success.

**Verification.** Follow native-control, custody, independent numerical, controller and target evidence gates.

**Next actionable work.** Resolve R01 and terminal/ACK semantics while preserving the earlier C02/C03 prerequisite order.

**Declared surface / navigation:** `Missing work with concrete exit gates`; `Q01: independently compare the C and Zig ABI`; `Q02: make the upstream upgrade transaction reviewable`; `Q03: qualify the application's device owner`; `Q04: adopt conversion with separate source/output clocks`; `Q05: package and qualify the actual supported targets`.


<a id="file-docs-readme-md"></a>

## `docs/README.md`

**Responsibility.** Navigate the expanded conversion handoff, custody/control constraints and independent verification plan.

**Contract and ownership.** Maintain distinction between existing binding/test artifacts and proposed application conversion behavior.

**Failure/change obligations.** Neither linked plans nor defect reproductions complete adaptive playback qualification.

**Verification.** Read-only catalogue/link/source/custody check covers 39 files and 46 snippets.

**Next actionable work.** Follow the conversion handoff after application lifecycle prerequisites; Q04 remains open.

**Declared surface / navigation:** `Read the binding as an engineering argument`.


<a id="file-docs-reference-catalog-json"></a>

## `docs/reference/catalog.json`

**Responsibility.** Map 39 authored/vendor files to exact handbook entries and bind 46 source snippets.

**Contract and ownership.** Add four real conversion chapters and four adopted implementation anchors without adding proposed runtime files.

**Failure/change obligations.** Unknown/missing files, stale anchors, broken links or changed vendor custody fail without repair.

**Verification.** Read-only documentation check passes against the live and delivered inventories.

**Next actionable work.** Maintain application central references through this reviewed 12-entry delta, not concurrent registry edits.

**Declared surface / navigation:** `schema`; `scope`; `files`; `source_anchors`.


<a id="file-docs-reference-files-md"></a>

## `docs/reference/files.md`

**Responsibility.** Explain purpose, contracts, failures, evidence and next work for all four new conversion chapters.

**Contract and ownership.** Per-file documentation distinguishes proposed application owners, observed native limitations and unresolved qualification.

**Failure/change obligations.** Comprehensive navigation is not whole-program proof, target support or completed resampling.

**Verification.** All catalogue anchors and chapter links resolve with unchanged native source/profile/build.

**Next actionable work.** Use the per-file first callers and evidence obligations when the application implements WP05.

**Declared surface / navigation:** `Every-file implementation handbook`; `build.zig`; `build.zig.zon`; `src/root.zig`; `src/profile.h`; `src/native.c`; `tests/contract.zig`; `tools/check_vendor.py`; `UPSTREAM.json`; `vendor/miniaudio/miniaudio.h`; `vendor/miniaudio/LICENSE`; `.gitignore`; `README.md`; `docs/CONTRACT.md`; `docs/DEPENDENCIES.md`; `docs/FILES.md`; `docs/VERIFICATION.md`; `docs/README.md`; `docs/architecture/build-and-abi.md`; `docs/contracts/device-lifecycle.md`; `docs/contracts/pcm-and-conversion.md`; `docs/reference/upstream.md`; `docs/reference/files.md`; `docs/reference/catalog.json`; `docs/implementation/qualification.md`; `docs/verification/README.md`; `tools/check_docs.py`; `tests/test_check_docs.py`; `tests/abi_probe.c`; `tests/abi.zig`; `tests/consumer/build.zig`; `tests/consumer/build.zig.zon`; `tests/consumer/consumer.zig`; `tools/test_abi.py`; `tests/test_abi_runner.py`; `docs/verification/abi.md`; `docs/implementation/conversion-handoff.md`; `docs/contracts/conversion-custody.md`; `docs/contracts/conversion-control.md`; `docs/verification/conversion.md`.


<a id="file-docs-reference-upstream-md"></a>

## `docs/reference/upstream.md`

**Responsibility.** Extend symbol-level navigation with adopted generic quantization and stock linear phase-remapping hazards.

**Contract and ownership.** Source declarations/implementation and immutable adoption hashes remain authoritative; generic and direct-linear helpers differ.

**Failure/change obligations.** Source anchor presence is not correctness, and a precise integer pair alone is not safe phase control.

**Verification.** C-only O0/O2 reproductions and read-only source-anchor/vendor checks bind these specific observations.

**Next actionable work.** Review an explicit bounded-profile or source-candidate decision; never repair vendor bytes silently.

**Declared surface / navigation:** `Navigate the adopted header without forking it`; `Review scope`; `Symbol-level route to the contract`; `Unreviewed source and platform work`.


<a id="file-docs-verification-abi-md"></a>

## `docs/verification/abi.md`

**Responsibility.** Own Q01 selector protocol, mathematical comparison, guarded sentinel, two defect controls, consumer boundary and evidence interpretation.

**Contract and ownership.** Five device-facing types, twelve offsets, eight values and synthetic callback arguments cross independently evaluated C/Zig paths.

**Failure/change obligations.** No claim of full upstream ABI, OS callback lifetime, timing, physical device operation or unsupported native targets.

**Verification.** 16 matrix commands include eight clean passes and eight expected assertion rejections; all require precise executed witnesses.

**Next actionable work.** Use new phase directories and extend targeted facts as actual application ABI use grows.

**Declared surface / navigation:** `Independent C/Zig ABI qualification`; `Why the comparison is useful`; `Coverage and selector protocol`; `Build graph and deliberate defects`; `Independent package consumer`; `Run and interpret the matrix`; `Remaining boundary`.


<a id="file-docs-verification-conversion-md"></a>

## `docs/verification/conversion.md`

**Responsibility.** Specify source-scoped reproduction, candidate record fields, failure matrix, independent numerical oracle and target completion.

**Contract and ownership.** Record algorithm/delay/boundary conventions, input/output domains, actual quantizer, limits and independently justified tolerances.

**Failure/change obligations.** Known-defect passes, zero-only signals, same-implementation oracles and absent native targets cannot establish Q04.

**Verification.** Preserved C probe logs, nine finite arithmetic checks and planned fake/native/DSP/controller campaigns have explicit evidence limits.

**Next actionable work.** Implement application tests and obtain actual Windows/Intel Mac quality, lifecycle and drift observations before activation.

**Declared surface / navigation:** `Conversion qualification: independent evidence before activation`; `What the present characterization establishes`; `Candidate record: fill facts, never copy assumed defaults`; `Functional and failure matrix`; `Numerical oracle and comparison method`; `Controller and target completion`.


<a id="file-docs-verification-readme-md"></a>

## `docs/verification/README.md`

**Responsibility.** Classify conversion-control reproductions separately from successful ABI, numerical and physical qualification.

**Contract and ownership.** A passing known-limitation reproducer demonstrates that limitation; observation receipts remain phase-specific.

**Failure/change obligations.** Do not promote a silent C state experiment into a production converter or hardware capability claim.

**Verification.** Consult conversion verification, preserved probe logs, exact source identities and arithmetic examples.

**Next actionable work.** Keep future quality and runtime evidence separate until the relevant gates have actually passed.

**Declared surface / navigation:** `Reproduce evidence without overstating it`; `What each result establishes`; `A receipt is an observation`.


<a id="file-docs-verification-md"></a>

## `docs/VERIFICATION.md`

**Responsibility.** Authoritative scoped guide: Executed adoption evidence — 2026-09-25.

**Contract and ownership.** Keep terminology, existing versus proposed behavior, source paths and acceptance claims synchronized with the owning implementation/work package.

**Failure/change obligations.** Do not duplicate conflicting protocol/API meaning or imply unexecuted platform support. Preserve useful history and label superseded claims rather than erasing evidence.

**Verification.** Validate local navigation and file index, compare referenced source behavior and evidence dates/hashes; prose quality requires review beyond automated checks.

**Next actionable work.** Read the declared sections below; update this guide whenever its owned contract changes and link to granular implementation/verification obligations.

**Declared surface / navigation:** `Executed adoption evidence — 2026-09-25`.


<a id="file-readme-md"></a>

## `README.md`

**Responsibility.** Describe actual package usage, default eight-test suite, isolated ABI steps and the new matrix/consumer qualification guide.

**Contract and ownership.** Public module and raw c namespace remain stable; native/null build profiles are distinct from physical-device execution.

**Failure/change obligations.** Do not imply other OS, physical playback or complete ABI proof from local Windows layout checks.

**Verification.** Run local documentation coverage and the source-bound Q01 matrix; retain the original adoption report as history.

**Next actionable work.** Follow docs/verification/abi.md for repeatable qualification before extending the library or its target claims.

**Declared surface / navigation:** `miniaudio-zig`; `Build and use`; `Status and licensing`.


<a id="file-src-native-c"></a>

## `src/native.c`

**Responsibility.** Sole MINIAUDIO_IMPLEMENTATION translation unit.

**Contract and ownership.** Include the shared profile; no second implementation definition in tests or consumers.

**Failure/change obligations.** Initialization failure must retain native error; uninitialized objects are not uninitialized again. ABI/custody discrepancies stop adoption rather than being ignored.

**Verification.** Wrapper custody check, three native adoption tests and tests/dependency.zig consumer; physical device/latency evidence is separate.

**Next actionable work.** Keep the wrapper thin; upstream changes require deliberate adoption, not local rewrites.


<a id="file-src-profile-h"></a>

## `src/profile.h`

**Responsibility.** Single authoritative ABI feature profile for C compilation and Zig translation.

**Contract and ownership.** Disabled high-level codecs/engine/resource-manager features must match on both paths; layout-changing macros cannot differ across consumers.

**Failure/change obligations.** Initialization failure must retain native error; uninitialized objects are not uninitialized again. ABI/custody discrepancies stop adoption rather than being ignored.

**Verification.** Wrapper custody check, three native adoption tests and tests/dependency.zig consumer; physical device/latency evidence is separate.

**Next actionable work.** Review any feature addition for symbols, dependencies, allocation/lifetime changes and all target ABI tests.


<a id="file-src-root-zig"></a>

## `src/root.zig`

**Responsibility.** Expose only the translated C API and upstream ownership/lifetime boundary.

**Contract and ownership.** The raw c import adds no pointer safety or alternate owning device hierarchy. Keep userdata/context/device addresses stable.

**Failure/change obligations.** Initialization failure must retain native error; uninitialized objects are not uninitialized again. ABI/custody discrepancies stop adoption rather than being ignored.

**Verification.** Wrapper custody check, three native adoption tests and tests/dependency.zig consumer; physical device/latency evidence is separate.

**Next actionable work.** WP04 keeps application policy in lan-audio; add wrapper abstractions only with a demonstrated reusable contract.

**Declared surface / navigation:** `c`.


<a id="file-tests-abi-zig"></a>

## `tests/abi.zig`

**Responsibility.** Compare public translated types against independent C facts and verify a C-to-Zig callback sentinel plus invalid probe requests.

**Contract and ownership.** Five tests cover object layout, selected fields, constants, guarded callback arguments and selector/null rejection.

**Failure/change obligations.** Collect layout differences before failing; synthetic callback must not allocate, throw across C or infer real device guarantees.

**Verification.** Five clean ABI tests pass in each native/null Debug/ReleaseSafe row; deliberate size/profile faults fail the exact expected groups.

**Next actionable work.** Extend only for additional real ABI use and keep independent expected names, types and selector IDs reviewable.

**Declared surface / navigation:** `mz_abi_size`; `mz_abi_align`; `mz_abi_offset`; `mz_abi_enum`; `mz_abi_call_callback`; `sentinel`; `std`; `c`; `objects`; `native_size`; `native_align`; `fields`; `translated`; `native`; `values`; `C and Zig object sizes and alignments agree`; `C and Zig callback userdata and endpoint field offsets agree`; `C and Zig adopted result and enum values agree`; `C invokes the translated callback type with intact arguments and guards`; `probe rejects invalid selectors and null callback`.


<a id="file-tests-abi-probe-c"></a>

## `tests/abi_probe.c`

**Responsibility.** Produce native C99 size/alignment/offset/enum facts and invoke a guarded six-sample synthetic callback.

**Contract and ownership.** Primitive returns avoid a circular probe struct; invalid selectors/null callback have explicit test-local sentinels.

**Failure/change obligations.** Never define MINIAUDIO_IMPLEMENTATION or pass intentionally mismatched aggregate objects to production native functions.

**Verification.** Matrix detects reported size+1 and actual MA_MAX_DEVICE_NAME_LENGTH=511 probe-only profile mismatch.

**Next actionable work.** Add C-produced facts for newly used ABI surfaces while preserving the documented selector protocol.

**Declared surface / navigation:** `mz_abi_size`; `mz_abi_align`; `mz_abi_offset`; `mz_abi_enum`; `mz_abi_call_callback`.


<a id="file-tests-consumer-build-zig"></a>

## `tests/consumer/build.zig`

**Responsibility.** Build a standalone package consumer using only dependency.module("miniaudio") and ordinary public linkage.

**Contract and ownership.** Forward target, optimization and null profile; separate compile-only check from fresh one-test execution.

**Failure/change obligations.** Private source includes or manual native linking would invalidate the independence of this consumer evidence.

**Verification.** Its test passes separately in all four local Q01 configurations with actual C symbol calls.

**Next actionable work.** Keep it minimal and add public compatibility assertions only for promised consumer behavior.

**Declared surface / navigation:** `build`; `std`; `target`; `optimize`; `null_only`; `dependency`; `tests`; `run`.


<a id="file-tests-consumer-build-zig-zon"></a>

## `tests/consumer/build.zig.zon`

**Responsibility.** Identify the miniaudio_abi_consumer fixture, compiler floor, parent-relative library dependency and three-file package closure.

**Contract and ownership.** Compiler-suggested fingerprint is test package identity, not release custody; dependency direction remains consumer to library.

**Failure/change obligations.** Parent-relative fixture success does not establish distributable application dependency closure.

**Verification.** Independent consumer builds parse the manifest and import the public module in all four local configurations.

**Next actionable work.** Preserve fixture layout/identity and keep release packaging obligations under Q05.


<a id="file-tests-consumer-consumer-zig"></a>

## `tests/consumer/consumer.zig`

**Responsibility.** Exercise public dependency import, native stereo PCM byte sizing and native configuration returned by value.

**Contract and ownership.** Known expected byte units/type/default fields are independent of the function result; no private root or ABI helper is imported.

**Failure/change obligations.** One downstream link/config test does not prove all library calls, hardware access or device lifetime safety.

**Verification.** One executed test passes in each of the four host matrix configurations with no device initialization.

**Next actionable work.** Use this seam for public API compatibility obligations without duplicating every internal test.

**Declared surface / navigation:** `std`; `c`; `config`; `external package receives the linked native PCM and configuration API`.


<a id="file-tests-contract-zig"></a>

## `tests/contract.zig`

**Responsibility.** Independent ABI/version/frame-unit/default configuration and explicit null initialization tests.

**Contract and ownership.** Context/device remain in stable local storage; context outlives device; explicit null backend prevents physical-device fallback.

**Failure/change obligations.** Initialization failure must retain native error; uninitialized objects are not uninitialized again. ABI/custody discrepancies stop adoption rather than being ignored.

**Verification.** Wrapper custody check, three native adoption tests and tests/dependency.zig consumer; physical device/latency evidence is separate.

**Next actionable work.** Add platform/profile regressions as needed; active callback and application teardown tests belong to the audio host.

**Declared surface / navigation:** `std`; `c`; `config`; `backends`; `pinned upstream version and interleaved PCM units`; `configuration defaults are obtained from upstream`; `explicit null context and device retain stable storage until teardown`.


<a id="file-tests-test-abi-runner-py"></a>

## `tests/test_abi_runner.py`

**Responsibility.** Six independent log-fixture tests constrain qualification classification, including optimized logs and cached/infrastructure/unrelated failures.

**Contract and ownership.** Importing the runner executes no builds; fake logs exercise required counts, exit statuses and size/offset witnesses.

**Failure/change obligations.** A generic nonzero exit or absent witness must not be accepted as detecting the intended defect.

**Verification.** All six tests pass alongside the 17 existing documentation checker tests.

**Next actionable work.** Update expected totals deliberately when the ABI suite changes while retaining all false-success rejection cases.

**Declared surface / navigation:** `EvidenceClassification`.


<a id="file-tests-test-check-docs-py"></a>

## `tests/test_check_docs.py`

**Responsibility.** Seventeen independent fixture tests for documentation coverage, link/anchor drift, source drift, custody and exclusions.

**Contract and ownership.** Use synthetic vendor bytes in a temporary root; assert failures and byte-for-byte absence of checker repair.

**Failure/change obligations.** Test results establish tooling behavior only, never audio device safety, ABI completeness or upstream correctness.

**Verification.** python -m unittest discover -s tests -p test_check_docs.py -v; production files are not mutated by these tests.

**Next actionable work.** Extend only for a new checker obligation or discovered regression; preserve baseline and per-fault independence.

**Declared surface / navigation:** `DocumentationGate`.


<a id="file-tools-check-docs-py"></a>

## `tools/check_docs.py`

**Responsibility.** Read-only exact file coverage, explicit anchors, simple Markdown links, source-snippet and vendor-custody validation.

**Contract and ownership.** Prune known generated caches and top-level evidence only; reject unknown files, escapes, duplicates and broken references.

**Failure/change obligations.** Return nonzero diagnostics without repair, download, rehash or device use; this is not a complete Markdown/security parser.

**Verification.** Run tests/test_check_docs.py independent temporary fixtures and verify the real 27-file project passes.

**Next actionable work.** Maintain schema/exclusion documentation and add focused negative fixtures when validation behavior changes.

**Declared surface / navigation:** `unique_object`; `read_json`; `contained`; `inventory`; `explicit_ids`; `check`; `main`.


<a id="file-tools-check-vendor-py"></a>

## `tools/check_vendor.py`

**Responsibility.** Read-only validation of the adopted upstream header/license.

**Contract and ownership.** Resolve only contained declared paths and compare SHA-256; no fetch, fallback, modification or automatic new hashes.

**Failure/change obligations.** Initialization failure must retain native error; uninitialized objects are not uninitialized again. ABI/custody discrepancies stop adoption rather than being ignored.

**Verification.** Wrapper custody check, three native adoption tests and tests/dependency.zig consumer; physical device/latency evidence is separate.

**Next actionable work.** Use before any upstream adoption; retain old/new hashes and native consumer evidence.


<a id="file-tools-test-abi-py"></a>

## `tools/test_abi.py`

**Responsibility.** Run four native ABI profiles, two deliberate defects per row and separate package consumers into a new source-bound evidence directory.

**Contract and ownership.** Record exact compiler/source/host, command logs/timing/exit codes and accepted runtime witnesses; hash sources before and after.

**Failure/change obligations.** Reject cached passes, unexpected failure, existing output paths and source drift; timeout/launch/compile failure never counts as mutation success.

**Verification.** All 16 native commands meet expectations and classifier unit fixtures guard false qualification paths.

**Next actionable work.** Retain receipts/caches as phase artifacts and rerun on actual new supported hosts; no source repair or automatic adoption.

**Declared surface / navigation:** `classify`; `source_hashes`; `main`.


<a id="file-upstream-json"></a>

## `UPSTREAM.json`

**Responsibility.** Own exact upstream tag/commit, source hashes and provenance limits.

**Contract and ownership.** Records unmodified miniaudio 0.11.25 at the adopted commit; authenticated retrieval is not signature verification.

**Failure/change obligations.** Initialization failure must retain native error; uninitialized objects are not uninitialized again. ABI/custody discrepancies stop adoption rather than being ignored.

**Verification.** Wrapper custody check, three native adoption tests and tests/dependency.zig consumer; physical device/latency evidence is separate.

**Next actionable work.** Revisit on a planned upgrade with source diff, license/profile/API review and platform qualification.

**Declared surface / navigation:** `repository`; `tag`; `commit`; `adopted`; `files`; `verification`; `local_modifications`.


<a id="file-vendor-miniaudio-license"></a>

## `vendor/miniaudio/LICENSE`

**Responsibility.** Unmodified upstream license notice.

**Contract and ownership.** Preserve byte-for-byte and include applicable notice in distributions; it does not choose a license for new JCR code.

**Failure/change obligations.** Initialization failure must retain native error; uninitialized objects are not uninitialized again. ABI/custody discrepancies stop adoption rather than being ignored.

**Verification.** Wrapper custody check, three native adoption tests and tests/dependency.zig consumer; physical device/latency evidence is separate.

**Next actionable work.** WP09 resolves new-code licensing and retains dependency notices.


<a id="file-vendor-miniaudio-miniaudio-h"></a>

## `vendor/miniaudio/miniaudio.h`

**Responsibility.** Preserved upstream declarations, manual, device backends and DSP implementation.

**Contract and ownership.** Do not annotate/reformat this 4 MB custody object. Application uses low-level devices/PCM; upstream allocation/driver timing is outside the project proof.

**Failure/change obligations.** Initialization failure must retain native error; uninitialized objects are not uninitialized again. ABI/custody discrepancies stop adoption rather than being ignored.

**Verification.** Wrapper custody check, three native adoption tests and tests/dependency.zig consumer; physical device/latency evidence is separate.

**Next actionable work.** For endpoint/resampler work inspect the exact pinned API sections and qualify behavior; never claim the whole upstream source was formally verified.
