# Dependency release readiness: closure, targets and evidence

Status: Q05 decomposed into concrete gates. The source-package runner is implemented;
a passing receipt closes only its named host/source-closure subgate. LAN Audio owns
product installers, private TLS runtime closure, permissions, application settings,
signing and user-facing release behavior. This library does not need an installer.

## Identity and the release input graph

For a release candidate, record source closure S, toolchain T, build profile P,
target/SDK/runtime environment E and test/oracle policy Q. A build artifact is an
observation of `Build(S,T,P,E)`; an artifact hash alone cannot reconstruct those
inputs or imply qualification. Bind each evidence record to the appropriate tuple.

S includes authored files, adopted header/license and the package manifest. T
includes the actual compiler identity; the ZON minimum version is only a floor.
P includes C/translation feature macros and optimization. E separates compile
target and available native host facts. Q includes check revisions, required
coverage and declared exclusions. A changed tuple invalidates evidence only as
justified by the affected property, not through automatic blanket relabeling.

The source package now uses an exact file list. Let I be authored/vendor inventory,
F the compiler-selected path set and H(path) the source SHA-256 mapping. This
package's closure gate is:

```text
F = I
for every path in I: H_source(path) = H_archive(path) = H_relocated(path)
package_id(source) = package_id(noisy_relocation) = package_id(source_tar)
```

Adding an empty directory does not create a new contract. Adding a file requires a
real responsibility, catalogue entry and deliberate package inclusion. Generated
evidence/caches stay outside I/F. A source hash changes normally when documentation
changes; preserve old receipts as historical rather than force a stable hash.

## Gate ledger

| Gate | Exact completion condition | Current preparation / remaining evidence |
| --- | --- | --- |
| S01 Selected source closure | Exact compiler-selected files, unchanged hashes through archive/relocation, deliberate cache-noise exclusion and independent consumer. | Implemented `tools/test_package.py`; completion is receipt-specific, not implied by file presence. |
| S02 Public build/API compatibility | Relevant Q01 matrix and consumer pass on every claimed native target/profile after ABI-affecting changes. | Windows Q01 evidence exists for its recorded revision; new source-package smoke covers only Debug/native and ReleaseSafe/null consumer. |
| S03 Native backend/lifetime | Named endpoint/OS/driver, active callbacks, partial failures, stop/uninit/fences and error policy demonstrated. | Q03/application C03 owns these tests; null/no-device results do not close physical behavior. |
| S04 DSP capability | Used converter/control paths meet precision, phase, numerical, tail, resource and timing requirements. | Q04 remains blocked on reproduced control limitations until a qualified profile/fix/alternative is adopted. |
| S05 Runtime distribution | Actual application archive runs on clean supported hosts with its private dependency/runtime closure and OS-provided components declared. | Application WP09, including Windows and actual Intel Mac loading. A source consumer is insufficient. |
| S06 Notices and authored license | Original notices retained and an actual authored-code license/distribution decision recorded by its responsible owner. | Upstream notice preserved; do not infer the wrapper's license from miniaudio's license. |
| S07 Provenance and reproducibility | Release inputs/artifacts/evidence identities retained; scope of reproducibility explicitly measured; signing claims backed by artifacts where required. | Source tar determinism has an executable recipe. Binary determinism/signing are independent future claims. |
| S08 Update/recovery | Candidate isolation, expected-base conflict and real platform publication/recovery behavior qualify under the host protocol. | [Adoption transaction](adoption-transaction.md) is specified; no transactional updater is implemented here. |

## Target record without unsupported extrapolation

Each release-support row names target CPU/OS/ABI, compiler, SDK/deployment floor,
build profile, native execution host, actually used audio backend and evidence IDs.
Keep compile success, consumer execution, null callback tests and physical-device
qualification in separate columns. Unsupported/unavailable/unknown are real states.

The user's 2019 Intel Mac target is x86_64 macOS. Its exact installed OS is still
unconfirmed and the host is unavailable in the current work. An ARM build or a
Windows cross-compile does not supply that execution. Linux build declarations
also do not create a supported product target. Do not invent an SDK or release
floor from the latest compiler's capabilities.

For actual native runs capture OS/build, model/CPU, endpoint/driver identity,
requested and observed formats, callback frame-count range, scheduling/load,
underrun/drop facts, hotplug, start/stop duration and final fence/tail limitations.
Privacy-sensitive identifiers can be redacted for export with the original
evidence relationship retained. A selected device's name alone is insufficient.

## Concrete file responsibilities

| File / owner | Work and failure contract |
| --- | --- |
| `build.zig.zon` | Exact authored/vendor package file list; maintain package identity, compiler floor and dependency semantics independently. Do not add recursive directories to bypass a missing-file gate. |
| `docs/reference/catalog.json` | Every current authored/vendor file has a real handbook entry. The independent compiler selection must agree; neither list repairs the other during verification. |
| `tools/test_package.py` | Capture exact source selection, controlled noise, deterministic tar, compiler-produced package validation, relocation and fresh public-consumer execution. No vendor/source mutation or remote URL. |
| `tests/test_package_runner.py` | Independently challenge evidence parser/selector and archive/consumer failure cases in temporary fixtures. No native device or duplicated application packaging logic. |
| `tests/consumer/*` | Existing public module caller, executed from the relocated actual package; parent-relative dependency resolves inside that package. No original checkout path or private C link added. |
| `docs/verification/source-package.md` | Commands, selection defect history, receipt interpretation, exclusions and compiler-format compatibility scope. |
| Application `packaging/{windows,macos}/`, `tools/verify_package.py` | Existing proposed WP09 owners for actual executable/runtime closure and clean-host validation. Avoid a competing library-local installer. |

The exact root file list is intentionally explicit. Its maintenance cost is a
reviewable line per admitted file; it prevents accidental cache/binary/private-note
inclusion caused by broad directory selection. Future automated list generation,
if desired, must be an explicit reviewed editing operation, not a verifier side
effect. Keep a failure when source/docs/package responsibilities drift.

## Ready for the next implementation session

Read the latest handoff and source-bound receipts, inspect current custody, then
select the first unmet gate whose prerequisites are available. S01 can proceed
without the Mac. Q03 fake-owner preparation and Windows checks can proceed while
Mac qualification remains open. Q04 arithmetic/control constraints must precede
resampler activation; package success cannot waive them.

A release claim lists exactly which gates/targets pass and which are excluded or
blocked. Completion is an evidence-backed supported envelope, not a percentage
of files documented or an assumption of universal hardware compatibility.
