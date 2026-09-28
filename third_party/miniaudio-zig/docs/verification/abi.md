# Independent C/Zig ABI qualification

The Q01 probes are implemented. Qualification is per host, compiler, optimization
and feature profile; a result on Windows x86_64 does not qualify macOS or Linux.
The public `miniaudio.c` API and production profile remain unchanged. This work
adds test artifacts and explicit build steps, not a new runtime API.

## Why the comparison is useful

`tests/abi_probe.c` is compiled as C99 against `src/profile.h`. It returns native
`sizeof`, `__alignof__`, `offsetof` and enum facts as primitive `size_t`/`int` values.
`tests/abi.zig` imports the public module and computes corresponding facts with
Zig's `@sizeOf`, `@alignOf` and `@offsetOf`. No probe struct crosses the boundary,
so an unverified struct does not encode its own expected layout.

Both paths deliberately share the same header/profile/compiler distribution;
the independence is between C-produced facts and the translated Zig types,
not independently specified upstream semantics or unrelated toolchains.
Matching layout does not prove arbitrary callers' memory safety. Ownership and
lifecycle contracts still apply.

## Coverage and selector protocol

| Probe | Selector order / fact checked |
| --- | --- |
| `mz_abi_size`, `mz_abi_align` | 0 context, 1 device, 2 device config, 3 device ID, 4 device info |
| `mz_abi_offset` 0-4 | Config dataCallback, notificationCallback, pUserData, playback, capture |
| `mz_abi_offset` 5-8 | Device onData, pUserData, playback, capture |
| `mz_abi_offset` 9-11 | Device-info name, isDefault, nativeDataFormats |
| `mz_abi_enum` 0-7 | MA_SUCCESS, MA_INVALID_ARGS, f32 format, playback/capture/duplex/loopback types, null backend |
| `mz_abi_call_callback` | C invokes the translated callback with three stereo frames; Zig reads six inputs and writes six outputs; C checks exact values and both guards |

Selector IDs are a test-local protocol independently enumerated in each language.
Changing order requires reviewing both sides and this table. Invalid size/align/
offset selectors return `SIZE_MAX`; unknown enum selectors return 2147483647.
Null callback returns -1. These are test sentinels, not upstream result codes.

The callback probe is synchronous and synthetic. Its device pointer is null by
design; it passes known C stack buffers and a fixed frame count. The Zig sentinel
checks those arguments, then writes input+10. It creates no context, OS thread or
device. It establishes the tested call/argument convention and buffer footprint,
not real callback scheduling, lifetime fences or timing.

## Build graph and deliberate defects

`test-abi` runs five ABI tests; `check-abi` compiles/links without execution.
Default `test` now runs those five plus the original three null-device/PCM tests;
`check` compiles both artifacts. Explicit run steps bypass result caching,
while compilation may remain cached. Test-only symbols are compiled into the ABI
test artifact, never the production static library or translated module.

Native and null-only profiles apply matching backend macros to the native
library, translation and C probe. `-Dabi-test-fault` affects the probe alone:

| Option | Injected defect | Required observed rejection |
| --- | --- | --- |
| `none` (default) | None | 8/8 default tests pass |
| `size` | Report `sizeof(ma_device)+1` | Size witness plus one failed layout test; 4/5 ABI tests pass |
| `profile` | Probe alone uses `MA_MAX_DEVICE_NAME_LENGTH=511` instead of default 255 | Device/device-info size and isDefault-offset witnesses; two failed ABI tests; 3/5 pass |

The profile mutation changes actual header-defined layouts. It neither patches a
golden number nor alters the adopted header. Mismatched native objects are never
passed to the production library: tests compare facts and use the separate
synthetic sample callback. Fault controls do not change release artifacts or pins.

## Independent package consumer

`tests/consumer/` has its own build graph and package manifest. It obtains only
dependency module `miniaudio` through the normal package API, forwarding target,
optimization and null-profile choice. It never includes private C files, imports
the wrapper root by path or links the ABI probe.

Its one test calls native PCM sizing and native config initialization, then checks
known stereo byte units and returned defaults. This tests real C linkage and
struct return through a public downstream import without a device. The fixture's
fingerprint is package identity, not trust. Its parent-relative dependency is test
layout, not a claim that application distribution has been solved.

## Run and interpret the matrix

From the library root, choose a new phase directory:

```text
python tools/test_abi.py --output verification/abi-YYYYMMDD-new
```

The runner requires the exact qualification compiler recorded in package metadata.
It crosses Debug/ReleaseSafe with native/null-only profiles. Each row performs:
default eight-test run, size fault, profile fault and separate one-test consumer.
The 16 commands comprise eight clean successes and eight expected runtime assertion
rejections. Clean success requires executed test counts; cached results are not
accepted as fresh evidence.

Mutation classification requires named failed layout tests, specific size/offset
witnesses, expected pass/fail totals and exit code 1. It does not require Debug
stack frames, which ReleaseSafe may omit. Missing compiler,
linker failure, timeout or an unrelated assertion cannot count as detecting the
intended defect. `tests/test_abi_runner.py` challenges classification with
independent positive/negative log fixtures.

The runner sets locale only for subprocesses, writes logs and a progressively
updated receipt to a new directory, and never overwrites an old phase. Build cache
stays within that phase. All authored/vendor input hashes are recorded before
execution and compared afterward; concurrent edits fail source consistency.
A failed command stops the remaining matrix and records it as incomplete.
Timeout terminates the direct command; inspect remaining descendant compiler
processes before cleaning a failed run's cache.

## Remaining boundary

Coverage includes selected device-facing types, fields and constants. It does not
exercise every struct, calling-convention variant, SIMD ABI, conversion algorithm
or backend. New used surfaces need targeted facts and behavioral checks. Native
Mac/Linux execution, real audio callbacks, physical devices, end-to-end fidelity
and sustained timing remain separate gates.
