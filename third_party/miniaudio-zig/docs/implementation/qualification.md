# Missing work with concrete exit gates

Status: Q01's probes, package consumer and matrix runner are implemented; target
qualification requires a successful source-bound matrix receipt. Q02-Q05 remain
conditional/proposed work as described below. Create each missing file with its
first caller and independent evidence. These gates refine the dependency work required
by LAN Audio's WP01, C03 and WP05; they do not supersede its runtime sequence.

<a id="q01"></a>
## Q01: independently compare the C and Zig ABI

**Problem addressed.** The original contract tests exercise version constants,
frame sizes, defaults and null initialization. The new ABI suite adds C-produced
layout facts compared with translated Zig types for selected device-facing types.
Calling either suite a complete ABI proof is inaccurate.

**Implemented files and caller.** `tests/abi_probe.c` and `tests/abi.zig` use a
dedicated test artifact in `build.zig`. The probe includes `src/profile.h` and
does not define `MINIAUDIO_IMPLEMENTATION`. It uses the same target and
feature macros as the existing C artifact. Export simple primitive-valued probes
for `sizeof`, alignment and selected field offsets; do not exchange a probe struct
whose own unverified layout would make the test circular.

**Contract.** Cover `ma_context`, `ma_device`, `ma_device_config`, `ma_device_id`,
`ma_device_info`, callback field offsets and relevant enum values. Compare native
C-produced facts with Zig `@sizeOf`, `@alignOf` and `@offsetOf` from the exported
module. Check a C-to-Zig callback sentinel through the actual C calling convention.
Use the pinned compiler's supported C alignment expression, not an assumed C11
feature in the production C99 profile.

**Negative evidence.** Deliberately alter one expected size/offset and require a
test failure; separately demonstrate profile mismatch detection with a known
layout-affecting macro on the probe alone. Record which type changes. If the
chosen macro does not change a tested layout, that is not a successful mutation.

`tests/consumer/` supplies the independent package caller. The five ABI tests and
two controlled defects are specified in [ABI verification](../verification/abi.md).
`tools/test_abi.py` executes the matrix and records real rejection witnesses;
infrastructure failure cannot count as successful detection.

**Exit.** Native debug and ReleaseSafe, native/null profiles, plus independent
downstream import pass on each claimed target. Cross-compilation only contributes
compile evidence. Failures never trigger rehashing or fallback profiles.

<a id="q02"></a>
## Q02: make the upstream upgrade transaction reviewable

**Existing files.** `UPSTREAM.json`, `src/profile.h`, `tools/check_vendor.py`,
`docs/DEPENDENCIES.md`, `docs/reference/upstream.md` and new verification receipts.
No new package or updater is needed.

The [transaction specification](adoption-transaction.md) refines this gate for
future updatez/MetaOS orchestration: frozen context, isolated candidate, qualified
closure, expected-base conflict handling and an actual host publication/recovery
protocol. [Qualification records](../contracts/qualification-records.md) distinguish
persistent blockers, newly observed issues, true regressions and incomparable runs.
These are design contracts; the existing package has no transactional updater.

**Required work.** Review old/new source, exported declarations, compile macros,
backend changes, release notes and license notices. Retrieve candidate bytes into
an isolated work area, verify origin and compare hashes, then run Q01 and consumer
tests against that candidate. Keep the adopted files and manifest consistent in
one reviewed change. An upgrade script must never repair a mismatch by overwriting
the expected hash from whatever file is currently present.

**Failure/recovery.** Leave the current adoption usable if retrieval, compilation,
ABI, device qualification or licensing review fails. Preserve candidate evidence
separately. Roll back the entire profile/source/manifest set, not just the version.

**Exit.** The new source identity, rationale, target results and remaining native
gaps are explicit. Every existing documentation source anchor still resolves or
is deliberately replaced. This gate is conditional on a future upgrade; no upgrade
is proposed merely because the handbook now documents the procedure.

<a id="q03"></a>
## Q03: qualify the application's device owner

**Owner and existing files.** LAN Audio owns `src/host/audio_device.zig`,
`src/audio/callback_bridge.zig` and the application queue. Keep product behavior
out of this thin binding. No miniaudio wrapper class is needed for this work.

**First caller and proposed test.** The application's C03 lifecycle owner should
exercise `tests/integration/audio_owner_contract.zig` (proposed), using a fake
native seam that can call back synchronously during start, fail each acquisition,
and pause before callback return. Existing null-device tests then qualify the
real native seam. Reuse the application's existing runtime-lifecycle harness if
it can express these events; do not create a duplicate abstraction solely for the
proposed filename.

**Required cases.** Start-time callback before start returns; failure after context
but before device acquisition; failed start/stop followed by uninit; worker borrow
surviving stop; enumeration snapshot surviving refresh; selected device disappearing;
stale generation notification; variable and zero frame counts; missing active
direction buffer; callback work larger than the application queue capacity.

**Required outputs.** Typed fault plus original native result; acquired-resource
ledger; exact cleanup ordering; stable userdata; safely published sticky faults;
final counter snapshot only after the authoritative fence. Match callback format
to checked host configuration. The current adapter is stereo/48 kHz with a period
hint, and its plain counters cannot safely serve as live UI metrics.

**Exit.** Fake-owner negative cases reject early free/reset and illicit callback
control calls. Native null cycles pass separately. Actual Windows loopback and
Intel Mac playback each have named endpoint/OS evidence. Missing Mac hardware
blocks that target's gate, not independent fake/native Windows preparation.

<a id="q04"></a>
## Q04: adopt conversion with separate source/output clocks

**Owner.** LAN Audio WP05 owns clock estimation, scheduling and drift policy.
The binding supplies raw `ma_resampler`/`ma_data_converter` only.

**Proposed files.** Application `src/host/resampler.zig` owns the native adapter,
matching WP05, with native tests at `tests/integration/resampler.zig`. The pure
clock/controller files stay under `src/media/`. The
[conversion handoff](conversion-handoff.md) specifies each future file, its caller,
failure effects, independent oracle and order of implementation. This corrects
the earlier dependency document's conflicting `src/media/resampler.zig` proposal.
Do not create both paths or put C imports into the pure media layer.

**Blocking source findings.** The adopted generic ratio helper loses fine near-unity
adjustments; large integer-rate transitions can overflow stock linear phase
remapping, even for repeated same-rate calls. Both are reproduced in silent C-only
experiments described by [control constraints](../contracts/conversion-control.md)
and [verification](../verification/conversion.md). Q04 remains open until the chosen
control path meets a measured precision/phase contract; no vendor fix is adopted.

**Interface.** Bounded caller-owned input/output spans; separate consumed/produced
counts; explicit rates/ratio units; control-thread initialization; one mutable
converter owner; no concurrent reset/rate-change. Preserve unconsumed input and
terminal tail state. Preallocate if required, then measure/inspect remaining
allocation and timing behavior. Raw upstream export does not confer real-time
qualification.
The [custody model](../contracts/conversion-custody.md) separates real source,
synthetic padding, produced output and callback silence, and prevents reusing the
non-resampled acknowledgement frontier for converted output.

**Independent cases.** Upsample/downsample, equal rates with dynamic-rate support,
mono/stereo channel identity, impulse/DC/spectral tests, tiny output capacity,
fragmented input, no progress, rate-bound changes, cancellation and final tail.
Verify a rate-sign mutation destabilizes or violates the reference occupancy
expectation. Avoid an oracle that calls the same converter under a different name.

**Exit.** Source/output counters use separate units, tolerances are justified,
quality/CPU/memory/latency are measured on supported hardware, and the product
fidelity claim explicitly accounts for conversion. A listening impression or
equal total counts does not complete this gate.

<a id="q05"></a>
## Q05: package and qualify the actual supported targets

**Existing/proposed files.** Retain `build.zig.zon`'s source closure. Application
packaging paths remain `packaging/windows/` and `packaging/macos/` when real
release artifacts exist. The wrapper needs no parallel product installer.

**Implemented source subgate.** The root manifest now lists exact authored/vendor
files. `tools/test_package.py` verifies the pinned compiler's selection, excludes
controlled cache noise, compares deterministic source archives and executes the
public consumer from the compiler-produced relocated package. Its
[source-package chapter](../verification/source-package.md) records the former
cache leakage/missing-file defects and exact limits. The
[release ledger](release-readiness.md) separates this S01 gate from S02-S08; a
successful source-package receipt does not close all of Q05.

**Required evidence.** Clean source package import without development caches;
actual target SDK and libc; runtime system-library resolution; private application
TLS closure; original vendor notices; chosen license for authored code; compiler
and source identity. Miniaudio's upstream license does not choose the authored-code
license. Record physical endpoint/driver/OS, actual format, callback-size range,
hotplug behavior, stop duration and output-tail limitations.

**Exit.** Each advertised target has native evidence and reproducible distribution
inputs. Intel Mac means x86_64 macOS; an ARM cross-build does not establish that
gate. Unavailable hosts stay unqualified. Universal hardware/OS support is not a
meaningful acceptance condition; an explicit tested capability envelope is.
