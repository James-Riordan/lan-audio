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

**Responsibility.** Build exactly one static native C implementation plus matching translated Zig ABI and platform links.

**Contract and ownership.** Target and optimization flow to every dependent artifact. Compile steps are distinct from execution; do not open devices or network as an implicit build action.

**Failure/change obligations.** Wrong targets, missing SDK/runtime and ABI/link mismatches must fail. A successful cached compile does not prove execution or correct runtime search paths.

**Verification.** Run owning native tests and independent downstream consumer after graph changes; inspect staged imports and target identity.

**Next actionable work.** WP01 extends native platform build qualification; preserve existing public module names and callback/test separation.

**Declared surface / navigation:** `build`; `std`; `target`; `optimize`; `null_only`; `native`; `translated`; `module`; `tests`.


<a id="file-build-zig-zon"></a>

## `build.zig.zon`

**Responsibility.** Own package identity, version/compiler floor, dependency declarations and distribution allowlist.

**Contract and ownership.** ZON is Zig package metadata, distinct from ZSON. Fingerprint is identity, not artifact integrity. Sibling paths are development dependencies and require a release closure.

**Failure/change obligations.** Do not silently rename identities or raise compiler floor; changes need compatibility and clean-checkout evidence. Excluded source/docs must not break packages.

**Verification.** Parse/build with pinned compiler; test package allowlist and downstream import from a clean layout.

**Next actionable work.** WP09 replaces development-only assumptions with reproducible source/package custody and includes all required handoff documents.


<a id="file-docs-contract-md"></a>

## `docs/CONTRACT.md`

**Responsibility.** Authoritative scoped guide: Binding and device contract.

**Contract and ownership.** Keep terminology, existing versus proposed behavior, source paths and acceptance claims synchronized with the owning implementation/work package.

**Failure/change obligations.** Do not duplicate conflicting protocol/API meaning or imply unexecuted platform support. Preserve useful history and label superseded claims rather than erasing evidence.

**Verification.** Validate local navigation and file index, compare referenced source behavior and evidence dates/hashes; prose quality requires review beyond automated checks.

**Next actionable work.** Read the declared sections below; update this guide whenever its owned contract changes and link to granular implementation/verification obligations.

**Declared surface / navigation:** `Binding and device contract`; `Authority and purpose`; `Storage, lifetime and concurrency`; `PCM dimensions and error behavior`; `Capability boundaries and evidence`.


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

**Responsibility.** Authoritative scoped guide: File-by-file ownership and verification.

**Contract and ownership.** Keep terminology, existing versus proposed behavior, source paths and acceptance claims synchronized with the owning implementation/work package.

**Failure/change obligations.** Do not duplicate conflicting protocol/API meaning or imply unexecuted platform support. Preserve useful history and label superseded claims rather than erasing evidence.

**Verification.** Validate local navigation and file index, compare referenced source behavior and evidence dates/hashes; prose quality requires review beyond automated checks.

**Next actionable work.** Read the declared sections below; update this guide whenever its owned contract changes and link to granular implementation/verification obligations.

**Declared surface / navigation:** `File-by-file ownership and verification`.


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

**Responsibility.** Authoritative scoped guide: miniaudio-zig.

**Contract and ownership.** Keep terminology, existing versus proposed behavior, source paths and acceptance claims synchronized with the owning implementation/work package.

**Failure/change obligations.** Do not duplicate conflicting protocol/API meaning or imply unexecuted platform support. Preserve useful history and label superseded claims rather than erasing evidence.

**Verification.** Validate local navigation and file index, compare referenced source behavior and evidence dates/hashes; prose quality requires review beyond automated checks.

**Next actionable work.** Read the declared sections below; update this guide whenever its owned contract changes and link to granular implementation/verification obligations.

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


<a id="file-tests-contract-zig"></a>

## `tests/contract.zig`

**Responsibility.** Independent ABI/version/frame-unit/default configuration and explicit null initialization tests.

**Contract and ownership.** Context/device remain in stable local storage; context outlives device; explicit null backend prevents physical-device fallback.

**Failure/change obligations.** Initialization failure must retain native error; uninitialized objects are not uninitialized again. ABI/custody discrepancies stop adoption rather than being ignored.

**Verification.** Wrapper custody check, three native adoption tests and tests/dependency.zig consumer; physical device/latency evidence is separate.

**Next actionable work.** Add platform/profile regressions as needed; active callback and application teardown tests belong to the audio host.

**Declared surface / navigation:** `std`; `c`; `config`; `backends`; `pinned upstream version and interleaved PCM units`; `configuration defaults are obtained from upstream`; `explicit null context and device retain stable storage until teardown`.


<a id="file-tools-check-vendor-py"></a>

## `tools/check_vendor.py`

**Responsibility.** Read-only validation of the adopted upstream header/license.

**Contract and ownership.** Resolve only contained declared paths and compare SHA-256; no fetch, fallback, modification or automatic new hashes.

**Failure/change obligations.** Initialization failure must retain native error; uninitialized objects are not uninitialized again. ABI/custody discrepancies stop adoption rather than being ignored.

**Verification.** Wrapper custody check, three native adoption tests and tests/dependency.zig consumer; physical device/latency evidence is separate.

**Next actionable work.** Use before any upstream adoption; retain old/new hashes and native consumer evidence.


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
