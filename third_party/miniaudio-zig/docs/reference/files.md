# Every-file implementation handbook

This book is the semantic companion to `catalog.json`. Entries below explain the
actual files, then identify work that has not been implemented. The package keeps
`src/` small because its one responsibility is the ABI. Documentation directories
separate architecture, contracts, references, implementation gates and evidence.
Caches and `verification/` observations are excluded from authored-file coverage.

<a id="build"></a>
## `build.zig`

**Inputs and mechanics.** `target`, `optimize` and the optional `null-backend`
boolean feed the C library and header translation. Unsupported OS tags panic
before a usable target graph is produced. `native` builds one static C library;
`translated` builds the matching ABI namespace; `module` exports the public Zig
root and links `native`; `tests` imports that public module. This last edge ensures
tests use the same integration boundary as a downstream consumer.

**Outputs and failures.** Default install emits the static library. `check`
compiles/links both adoption and ABI tests; `test` executes all eight.
`check-abi`/`test-abi` isolate the five probe tests. Explicit run steps execute even
when compilation is cached. Compile/link errors must stay errors.
The null feature macros are set twice because native compilation and translation
are distinct build steps; they must remain equal. System-library names are target
contracts, not suggestions to search arbitrary local SDK copies.

**Work and verification.** The build itself opens no audio device and downloads
nothing. Native test execution allocates a null context/device. See
[the ABI graph](../architecture/build-and-abi.md) and [Q01](../implementation/qualification.md#q01)
before expanding this graph. The independent C probe is a test-only source linked
to `abi_tests`; it is not another implementation library. Its backend macros match
the production/translation pair. The `abi-test-fault` option changes only that
probe's reported size or actual header layout, never the installed library.

<a id="package"></a>
## `build.zig.zon`

**Contract.** Package name `miniaudio_zig`, version `0.1.0`, fingerprint and compiler
floor identify the existing package. The `.paths` allowlist names exact files across
docs/tools and source/tests/vendor; `.dependencies` is empty because no other Zig package
is adopted. Platform/C dependencies are documented separately. Include the catalogued
`.gitignore`; recursive directory entries previously admitted nested build/Python
caches. New authored files require both a contract and deliberate package entry.

**Failure and next action.** A sibling-path consumer is a development layout, not
a distribution proof. Q05 must build a clean source package with the same public
module and vendor custody. Do not rename the package or rotate its fingerprint
to hide compatibility problems. ZON is Zig package metadata, not a ZSON config.

<a id="root"></a>
## `src/root.zig`

**Contract.** One declaration exports `c = @import("miniaudio_c")`. It adds no
allocator, device owner, error translation, synchronization or format negotiation.
Any caller can still misuse C pointers; the raw import cannot make arbitrary C
calls memory-safe. The module comments describe stable storage and callback borrows.

**Change discipline.** Keep native results visible. A proposed owning wrapper
requires a demonstrated reusable consumer and explicit non-movable lifetime;
LAN Audio already owns its product adapter. Validate changes through the public
module plus downstream `tests/dependency.zig`, not a private include shortcut.

<a id="profile"></a>
## `src/profile.h`

**Mechanics.** A header guard prevents duplicate inclusion. Five `MA_NO_*` macros
disable codecs, resource manager, node graph and engine before including upstream.
Both native and translation paths consume this file. Device I/O and other remaining
upstream low-level APIs are available according to upstream conditions.

**Failure and evidence.** A macro mismatch can change layout or symbol visibility
while names still appear plausible. Do not let downstream callers choose independent
feature macros. Q01 compares real C/Zig layouts; any feature change also needs
dependency, allocation, platform and callback review. Current tests cover a small
subset, not every retained function.

<a id="native"></a>
## `src/native.c`

**Mechanics.** Defines `MINIAUDIO_IMPLEMENTATION` exactly once, then includes the
shared profile. This is the only production implementation translation unit.
The upstream header owns all algorithm/backend definitions; local patches are not
hidden here.

**Failure and next action.** A second definition can create duplicate symbols or
an inconsistent native library. Tests/probes include the profile without defining
the implementation macro. Any upstream fix belongs to an explicit adoption/patch
decision with old/new custody and relevant backend evidence.

<a id="tests"></a>
## `tests/contract.zig`

**Test 1.** Independently expects version 0.11.25, four bytes per f32 sample and
eight bytes per stereo frame. This challenges a wrong adoption or frame/sample
confusion without deriving the expected values from the function being tested.

**Test 2.** Obtains playback config through upstream init, expects playback type
and zero sample rate (native/default selection). It does not promise every other
configuration field or actual selected device format.

**Test 3.** Explicitly initializes a null context, then a stereo f32/48 kHz device
in stable local storage. Context cleanup is registered first; Zig runs the later
device defer first, so the device is destroyed before its context. No start occurs:
this is not an active-callback test.
Assertions inspect application-facing configured rate/channels, not an acoustic
measurement. Native calls must preserve returned errors for diagnosis.

**Next action.** The separate Q01 suite adds layout/callback-call-convention probes; Q03 qualifies
application lifetime behavior. Keep these three tests silent and deterministic.
Never allow an implicit default backend to replace the explicit null context.

<a id="vendor-check"></a>
## `tools/check_vendor.py`

**Inputs/algorithm.** Locate the repository from the script path, parse
`UPSTREAM.json`, resolve each declared relative file, reject paths outside the
root, compute SHA-256, compare to expected bytes. Runtime is linear in bytes read
plus JSON size. It does not enumerate unrelated files or fetch replacements.

**Failures.** Missing files, malformed JSON, escaped paths or mismatched hashes
fail the process; some malformed input currently produces an ordinary traceback.
This checker trusts the manifest's expected-hash authority. A modified manifest
and modified source agreeing does not prove upstream authenticity. It does not
validate a complete manifest schema or independently verify signatures.

**Next action.** Keep it read-only. A future custody-tool hardening pass can add
explicit malformed/empty/duplicate-entry tests and error categories, with no
automatic rehash. The documentation checker also checks the known two-file
manifest shape, but neither is a security audit of miniaudio.

<a id="upstream-manifest"></a>
## `UPSTREAM.json`

**Ownership.** Records repository URL, tag, exact commit, adoption date, two
digests, retrieval limits and empty local-modification list. Header and license
are unmodified at this adoption. Hashes bind bytes, not correctness or authorship.

**Change discipline.** Q02 is the update transaction. Review the actual source
diff and retained profile, retain previous evidence, then deliberately adopt.
Version constants alone cannot substitute for commit/header identity. A docs-only
pass must not refresh this manifest.

<a id="vendor-header"></a>
## `vendor/miniaudio/miniaudio.h`

**Responsibility.** Single upstream manual, declarations, native backends, DSP and
conditionally compiled higher-level implementation. Original API comments are
part of its documentation, but can contain descriptive/signature drift; follow
the actual declaration and relevant implementation when they conflict.

**Review routes.** [Upstream navigation](upstream.md) maps all 17 manual chapters
and the adopted API seam. The imported file is a custody object; local commentary
belongs here, not in the header. Function availability does not assert qualification.
Missing platform evidence remains missing even when a backend implementation is
present. Read the exact relevant backend paths before proposing a native change.

<a id="vendor-license"></a>
## `vendor/miniaudio/LICENSE`

**Contract.** Original upstream notice is preserved exactly and checked by the
manifest. It has no runtime effect. Release packaging retains the applicable
notice and resolves the separate authored-code license. Do not rewrite this file
to insert project-specific documentation or infer a license for new code.

<a id="ignore"></a>
## `.gitignore`

**Contract.** Existing patterns exclude `.zig-cache/`, `zig-out/` and direct
`verification/*.log` files. This is a version-control convenience, not a deletion
policy. Nested receipts/logs and Python caches require their own deliberate
handling; the documentation inventory excludes caches by explicit policy.

**Next action.** If new tools generate disposable files, add narrowly scoped
patterns after checking no authored input is hidden. Ignore status never proves
that a user's file is safely reconstructible.

<a id="readme"></a>
## `README.md`

**Responsibility.** Human entry, technology-based package identity, public import,
existing build commands and honest support/license scope. Link to the deeper
handbook without moving existing stable document paths. Command claims must match
the real build graph; distinguish implemented Q01 commands from missing native
target evidence and the remaining Q02-Q05 work.

<a id="contract-doc"></a>
## `docs/CONTRACT.md`

**Responsibility.** Existing canonical public lifetime/PCM/capability summary.
The deeper lifecycle/conversion chapters explain it. If new evidence changes a
rule, update this summary and the detailed owner together; do not maintain two
incompatible contracts. Formal application models are not proofs of upstream C.

<a id="dependencies-doc"></a>
## `docs/DEPENDENCIES.md`

**Responsibility.** Source/compiler/libc/platform closure and adoption authority.
Maintain against actual link graph and runtime loading. New feature macros or
backends trigger a closure review; lack of Zig package dependencies does not mean
the program has no dependencies. Preserve the distinction between dynamic OS
libraries and vendored third-party code.

<a id="files-doc"></a>
## `docs/FILES.md`

**Responsibility.** Stable short inventory entry. It now routes to this detailed
book and its exact catalogue. Keep original file-role summary useful; do not turn
it into a conflicting second source of every implementation contract.

<a id="old-verification"></a>
## `docs/VERIFICATION.md`

**Responsibility.** Historical adoption observations from 2026-09-25. Commands,
target limits and failures remain historical. Later documentation/tooling work
does not refresh the source identity behind those observations. Preserve its
bytes during this pass and create a new phase report.

<a id="docs-entry"></a>
## `docs/README.md`

**Responsibility.** Conceptual reading order from public boundary to mechanics,
per-file lookup, missing work and evidence. It explains where authority lives and
how to run the exact inventory check. Update after a new domain chapter appears.

<a id="abi-doc"></a>
## `docs/architecture/build-and-abi.md`

**Responsibility.** Reconstruct the build graph and representation obligation.
Own the distinction between equal inputs and independently demonstrated ABI
agreement. Review native/translated macro symmetry and target links after build
changes, then update Q01 evidence status only from actual probe execution.

<a id="lifecycle-doc"></a>
## `docs/contracts/device-lifecycle.md`

**Responsibility.** Define device/list/userdata ownership and the start-time
callback hazard. Source-level API documentation and current application behavior
are identified separately from proposed owner states. New asynchronous operations
must name their retained borrows and authoritative reclamation event here.

<a id="pcm-doc"></a>
## `docs/contracts/pcm-and-conversion.md`

**Responsibility.** Own dimensions, independent consumed/produced cursors, ratio
direction and conversion-tail obligations. Existing raw upstream capability is
separate from the planned application adapter. New algorithm choices need explicit
numerical tolerance, resource/timing evidence and revised fidelity claims.

<a id="upstream-doc"></a>
## `docs/reference/upstream.md`

**Responsibility.** Route review through the immutable adopted header without
editing it. Section locations are this adoption's local navigation; exact symbol
snippets in the catalogue detect changes. It states what was reviewed and what
was not, including backend/DSP internals still awaiting targeted qualification.

<a id="handbook"></a>
## `docs/reference/files.md`

**Responsibility.** This file owns source-specific explanations and maintainers'
next actions. Every catalogue entry targets an explicit anchor here. Coverage is
exact path coverage, not an assertion of equal review depth or correctness for
all source code. Update the entry whenever the file's real responsibility changes.

<a id="catalog"></a>
## `docs/reference/catalog.json`

**Schema.** `schema` is 1. `files` is a list of `{path, reference, anchor}` entries
relative to the package root. Paths are exact and unique, references are real local
Markdown files, anchors are explicit HTML IDs. `source_anchors` maps a source path
to nonempty declaration snippets that must remain present. `scope` explains the
inventory exclusions. This file indexes itself and the checker/test.

**Maintenance.** It is curated navigation, not an adoption lock or a runtime
configuration. The checker never inserts new entries automatically. New files
need an explanation/anchor and a reviewed row; removed files need deliberate row
removal. Vendor identity remains owned by `UPSTREAM.json`.

<a id="qualification-doc"></a>
## `docs/implementation/qualification.md`

**Responsibility.** Q01-Q05 specify implemented probes and concrete remaining work,
ownership, proposed files, tests and exits. They create no placeholder source. Close a gate only with
named evidence, target and scope; partial target results stay partial. Conditional
upgrade work does not block ordinary existing-version implementation.

<a id="verification-doc"></a>
## `docs/verification/README.md`

**Responsibility.** Repeatable commands and evidence interpretation. It distinguishes
documentation/custody, native null, independent layout probes and physical execution.
Record exact source/tool/target and preserve failures. Do not broaden test claims
because a command happens to exit zero.

<a id="docs-check"></a>
## `tools/check_docs.py`

**Inputs and behavior.** Read catalogue, authored-file inventory, Markdown links,
explicit IDs, source snippets and vendor custody from a selected root. Reject
missing/extra/duplicate paths, escaped references, broken local targets/anchors,
missing symbols or unexpected vendor bytes. Markdown checking intentionally covers
the simple inline-link/explicit-ID style used in this handbook, not all CommonMark.

**Side effects and failures.** Returns diagnostics and nonzero exit; performs no
fetch, file write, pin update, device operation or build. Inventory prunes only
known generated directories and top-level verification evidence. Unknown authored
files become visible failures. Complexity is linear in inspected text/bytes plus
directory traversal. Importing the module does not execute the CLI.

**Verification.** Its temporary-directory mutation tests prove the documented
negative paths fail. Link existence is not semantic correctness; source snippet
existence is not API qualification. Keep the schema and this explanation in sync.

<a id="docs-check-tests"></a>
## `tests/test_check_docs.py`

**Responsibility.** Build a minimal independent temporary fixture with curated
catalogue/anchor/source/vendor inputs, then remove or corrupt one fact per test.
Assert the appropriate error and that the checker did not repair files. Test the
baseline plus missing/stale/duplicate rows, broken links/anchors, source-anchor
loss, escaped paths, custody changes and generated-file exclusions.

**Limits.** These tests verify handbook-integrity tooling only. They neither
mirror the audio implementation nor qualify native devices. Temporary files are
cleaned by Python's fixture context; production project files are never mutated.

<a id="abi-probe"></a>
## `tests/abi_probe.c`

**Representation.** Include the adopted profile without defining an implementation.
Return C-calculated size/alignment/offset/enum facts through primitive `size_t`/`int`
results. Type IDs 0-4 and field IDs 0-11 follow the table in
[ABI verification](../verification/abi.md); invalid IDs return explicit sentinels.
The pinned compiler supports `__alignof__` in this C99 source.

**Callback and mutation boundaries.** The callback exercise passes six C-owned
samples, three stereo frames and a deliberately null synthetic device. Check the
six input+10 results and guards on both output sides before returning success.
No callback borrows outlive this call. The size macro alters only one reported
fact; the profile fault is supplied by the test build and changes real layouts.
Do not pass those intentionally mismatched device structs to native library calls.

**Evidence and next action.** The matrix must reject both faults with runtime
witnesses. Add new facts when the application adopts another type/field; this
selected seam is not every upstream function or callback signature.

<a id="abi-zig"></a>
## `tests/abi.zig`

**Mechanics.** Import `miniaudio.c` through the public module. Independently enumerate
five types, twelve fields and eight constants, compare C-produced facts, and print
all detected layout differences before failing the grouped assertion. The tests
also verify invalid selector/null-callback behavior so an absent probe result
cannot accidentally look like an ordinary successful value.

**Sentinel contract.** A C-convention Zig function validates the synthetic device,
buffer pointers and frame count before writing exactly six samples. It does not
allocate, log or throw across the C callback. Native lifecycle/thread/RT assumptions
are deliberately outside this test. Selector order is test protocol; preserve it
or update both sides and its documentation together.

<a id="consumer-build"></a>
## `tests/consumer/build.zig`

**Responsibility.** Own an independent package caller with explicit target,
optimization and null-backend forwarding. Obtain the exported `miniaudio` module
from `b.dependency`; never add private native sources or include paths. The `test`
step executes freshly and `check` compiles without device activity.

**Failure/verification.** Missing public exports, broken C linkage and unsupported
targets fail normally. The four-profile runner invokes this build separately from
the library root; success cannot be inherited from the internal probe artifact.

<a id="consumer-package"></a>
## `tests/consumer/build.zig.zon`

**Responsibility.** Identify the private `miniaudio_abi_consumer` test fixture,
pin its qualification compiler floor and declare its parent-relative library
dependency. Its allowlist is exactly its own build files and consumer test.
The compiler-suggested fingerprint is fixture identity, not a custody hash.

**Boundary.** The root package has no reverse dependency on this fixture. Its files
ship in the root's exact file allowlist, but no production application imports
the fixture. Keep parent-relative resolution tied to the documented test layout;
release artifact distribution remains Q05 work.

<a id="consumer-source"></a>
## `tests/consumer/consumer.zig`

**Responsibility.** Import only the public dependency, call native frame sizing
and config initialization, and check independently known stereo bytes and playback
defaults. Returning `ma_device_config` by value crosses a real C ABI boundary.
No device or OS permission is involved.

**Evidence.** One test per matrix profile demonstrates public build/link use.
It does not duplicate all internal layout probes or establish downstream device
lifetime correctness. Add a public compatibility assertion only when a consumer
actually depends on the corresponding promised behavior.

<a id="abi-runner"></a>
## `tools/test_abi.py`

**Inputs/outputs.** Require the exact qualification compiler and a new evidence
directory. Run Debug/ReleaseSafe crossed with native/null profiles; each executes
the eight-test library suite, two negative ABI mutations and one-test external
consumer. Write logs and a progressively sealed JSON receipt, retaining actual
nonzero mutation exit codes rather than relabeling commands as ordinary success.

**Failure policy.** Require executed counts and precise mutation witnesses.
Compiler/linker failure, launch errors, timeout and unknown fault kinds cannot
complete a gate. Stop the matrix on unexpected results and mark it incomplete.
Existing output directories are rejected. No source/adoption repair is permitted;
source hashes before and after the run must match. Cache/evidence writes are the
explicit side effects, unlike the read-only documentation checker.

**Complexity and limits.** Work is bounded by 16 subprocess commands and the
configured per-command timeout plus source hashing/log I/O. Builds may use large
caches; retained caches remain phase work, not authored source. Timeout kills the
direct process only; descendants may require inspection before cleanup. See the
ABI chapter for target scope and runtime-witness requirements.

<a id="abi-runner-tests"></a>
## `tests/test_abi_runner.py`

**Responsibility.** Six independent log-fixture tests prevent classification of
cached passes, compilation failure, missing mutation witnesses, zero-exit defects,
wrong test totals and unknown fault kinds as successful qualification, and accept
genuine optimized assertion failures without Debug stack traces. These are
tests of evidence interpretation, not redundant copies of the ABI calculations.

**Boundary.** Importing the runner performs no builds. Fixtures require no vendor
modification or temporary native devices. Update expectations deliberately when
the suite grows; retain explicit rejection of infrastructure failures.

<a id="abi-verification"></a>
## `docs/verification/abi.md`

**Responsibility.** Own the probe selector protocol, mathematical comparison,
test-only mutation scope, package-consumer boundary, executable commands and
evidence interpretation. Existing implementation is described separately from
unqualified native hosts and application lifecycle gates.

**Next action.** When a used ABI surface grows, update probe facts and independent
expectations here together. Record results in new phase receipts; do not promote
the existence of a test artifact to a hardware support claim.

<a id="conversion-handoff"></a>
## `docs/implementation/conversion-handoff.md`

**Responsibility.** Own the dependency-specific preparation for application WP05:
canonical future native/pure file split, first callers, per-file state/failure/test
contracts, supporting fixture/evidence files, R01-R08 decision owners and execution
order. Its path table follows the application's `src/host/resampler.zig` proposal.

**Boundaries and failures.** Planned files are explicitly planned and created with
their caller, not empty scaffolding. Unresolved effective-rate precision, phase
arithmetic, numerical tolerances, tail/ACK and target evidence block production
activation. This document neither edits application-owned code nor adopts a vendor
fix. App lifecycle/network prerequisites remain ahead of WP05.

**Verification/next action.** Match canonical paths to WP05 and turn each candidate
decision into a measured record. Begin with the reproduced native control limits;
the quantity of documentation is not evidence those limits have been resolved.

<a id="conversion-custody"></a>
## `docs/contracts/conversion-custody.md`

**Responsibility.** Define real-source, synthetic-input, produced-output and
callback-silence domains; separate custody identities; proposed adapter operations;
successful/failed commit behavior; finite terminal states and completion/fence
obligations. A hand-worked short-write trace is an independent test seed.

**Failure/verification.** Native failure can mutate its state; describe the last
committed ledger and uncertain attempted call instead of pretending rollback.
No-progress is not EOF, empty queue is not a fence and source consumption is not
acoustic completion. Exact-arithmetic example checks are finite specification
evidence only. Future fake/native tests must establish real ownership refinement.

**Next action.** Specify and qualify a terminal recipe and compatible completion
meaning before enabling conversion in the existing non-resampled receive path.

<a id="conversion-control"></a>
## `docs/contracts/conversion-control.md`

**Responsibility.** Separate requested, represented and effective rate; document
the adopted generic denominator-1000 quantizer and uint32 phase-product overflow;
derive sign, phase, precision and occupancy consequences with declared units.
Distinguish direct-linear and generic helpers, which have different implementations.

**Failure/verification.** Source review plus two optimization builds reproduce
the named C-only observations. Large explicit rate pairs are not an automatically
safe workaround. Conservative bounds cover one expression, not whole DSP safety.
No filter-quality, native device, Zig adapter or controller qualification is implied.

**Next action.** Compare bounded-rate, reviewed-source-fix or alternative-backend
candidates under R01. Preserve vendor/adoption bytes until a deliberate Q02 change.

<a id="conversion-verification"></a>
## `docs/verification/conversion.md`

**Responsibility.** Own characterization provenance/reproduction, candidate-record
fields, partial/failure/native cases, independent numerical oracle methodology,
controller mutations and target qualification. Name what each test cannot prove.

**Failure/verification.** Required but unknown thresholds remain open. Reproducing
a known defect is not a pass for the intended product capability. Oracle signals,
delay conventions, comparison regions and tolerances must be independent and
reviewed; exclude neither inconvenient transients nor nonfinite samples silently.
Top-level verification probes are delivered evidence, not new production sources.

**Next action.** Implement the appropriate application tests after R01 is resolved;
collect numerical/controller evidence and real supported-target measurements.

<a id="ecosystem-boundary"></a>
## `docs/architecture/ecosystem-boundary.md`

**Responsibility.** Translate the user's wider JCR vision into the dependency's
ownership, identity/locator, configuration-stage, capability and documentation
migration boundaries. Keep the binding reusable without requiring ambient context
or importing product policy. Name future owning systems without inventing their APIs.

**Failure/verification.** A compiled/exported capability may be unqualified or
unavailable at runtime. Configuration cannot activate excluded code; a document
rename does not implement Docz. Verify frozen context, typed interface equivalence,
explicit target facts and actual owner-backed document migration.

**Next action.** Add a real read-only host inspection/report caller first; keep
configuration language, GUI, publishing and migration dependencies conditional.

<a id="adoption-transaction"></a>
## `docs/implementation/adoption-transaction.md`

**Responsibility.** Specify Q02/Q05 candidate states, immutable inputs, expected-base
publication, retry identity, superseded results, closure consistency and recovery.
Map current source/manifest/checker files to their exact roles without creating
a second local updater or silently changing vendor custody.

**Failure/verification.** Multi-file writes, a lock file or a Git commit alone do
not prove atomic readers or power-loss safety. Fake conflict/idempotence models
are separate from real platform publication/flush/restart evidence. Preserve the
current adoption through failed preparation and reject rollback over later edits.

**Next action.** The updater owner implements inspection, candidate isolation and
then a qualified host transaction protocol, with fault injection at every boundary.

<a id="qualification-records"></a>
## `docs/contracts/qualification-records.md`

**Responsibility.** Define proposed structured observation semantics, per-check
comparability, multiset finding laws, coverage/unknown handling and repair-package
contents. Record intentionally varying subjects separately from fixed environment,
rule/oracle/policy. Existing tool formats remain as implemented.

**Failure/verification.** Different source hashes can be an intended comparison;
changed coverage/tools cannot be hidden. Incomplete runtime execution cannot
resolve old findings, and persistent defects remain blockers. Test hand-worked
duplicate findings, incompatible profiles and missing observations independently.

**Next action.** Adopt the owning ecosystem's real schema or versioned producer
adapter; preserve raw evidence, bounded parsing, redaction and human explanation.

<a id="ecosystem-verification"></a>
## `docs/verification/ecosystem.md`

**Responsibility.** Map future host adapter roles to inputs/outputs, ownership,
failure cases and independent tests. Specify source/publication fault schedules,
report comparison, frozen configuration/capability and Docz/Quartz acceptance.

**Failure/verification.** The delivered Python examples are a sequential abstract
model only. They do not supply filesystem atomicity, authorization, persistent
deduplication or real configuration/document APIs. Native support stays scoped.

**Next action.** Close one concrete host capability at a time with source-bound
receipts; choose actual adapter paths with its owning project instead of creating
unowned placeholders in this binding.

<a id="package-runner"></a>
## `tools/test_package.py`

**Responsibility.** Require a valid exact source inventory and pinned compiler,
compare actual compiler-selected files in live/noisy/archived locations, create
deterministic source tars, validate the compiler-produced package and execute the
public consumer after relocation. Save commands, hashes, failures and scope in
a new progressively written receipt. Never expand `.paths` or repair source.

**Failure and limits.** Reject unknown/missing selected files, duplicate/malformed
compiler records, changed archive members, nonregular entries, stale sources and
missing fresh one-test witnesses. Compiler debug format/cache layout are pinned
test interfaces. Archives are generated from known inputs, not arbitrary external
uploads; no general decompression-resource guarantee is claimed. Timeout kills
the direct process only. Build caches are explicit evidence-work effects.

**Next action.** Run on the next supported native target/compiler after deliberate
adoption. Keep source closure separate from binary reproducibility and product
runtime installation; do not add physical-device access to this gate.

<a id="package-runner-tests"></a>
## `tests/test_package_runner.py`

**Responsibility.** Seven independent temporary-fixture tests challenge compiler
record parsing, exact selected sets, executed consumer witnesses, deterministic
tar bytes and archive member/content integrity. Cached build steps may coexist
with a fresh test; a cached test line cannot establish execution.

**Failure/verification.** Reject missing/duplicate/escaped records, generated-cache
leakage, wrong content and linked/duplicate/extra tar members. The suite performs
no native compile, device access, source rewrite or adoption update.

<a id="source-package-verification"></a>
## `docs/verification/source-package.md`

**Responsibility.** Document observed old package-selection defects, the exact file
list, execution steps, compiler-format assumptions, noise/archive/consumer evidence
and specific exclusions. Explain why a source package pass does not release a product.

**Next action.** Retain new receipts per revision/target. On compiler format changes,
review the parser/cache adapter rather than ignoring unknown evidence or weakening
the expected closure. Preserve earlier faulty selection observations as history.

<a id="release-readiness"></a>
## `docs/implementation/release-readiness.md`

**Responsibility.** Split Q05 into source, API/ABI, native lifetime, DSP, product
runtime, notices/license, provenance/reproducibility and update/recovery gates.
Define release input identities, exact closure equations, support-row facts and
current/future file ownership without creating a second installer.

**Failure/verification.** Windows source/consumer evidence cannot qualify Intel Mac,
fine resampling, physical audio, signed artifacts or clean-machine deployment.
Use the first unmet gate with available prerequisites and state unsupported scope.
