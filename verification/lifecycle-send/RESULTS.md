# Sender completion and native fault/fence subset

The application continued in place, without Git initialization, moves or dependency
pin refreshes. All 118 application files in the lifecycle-receive receipt matched
before edits; before.json and before/ preserve that baseline. The installed Zig
version remained 0.17.0-dev.1859+dcceb318e. Miniaudio's observed files also matched
the preceding receipt before native adapter work.

## Implemented behavior

C02c adds a private sender owner using the real controller, capture queue,
BlockAssembler, v2 encoder and Negotiation. It handles capture-fenced EOF,
zero/partial tails, exactly-once copied-write commit, known rejection/retry,
uncertain transfer accounting, END, validated remote ACK, secure-close outcomes,
deadline races and stale generations. Sender and receiver execute a seven-frame
record exchange with independent sample expectations. No real socket worker or
production identity default was introduced.

The C03 subset adds callback-owned source-fault publication and explicit counter
exactness. Missing positive-frame native input, nonfinite samples, queue overflow
and capture-counter exhaustion terminate the source truthfully. Later input is
counted as dropped instead of being published across a hidden source gap.

AudioDevice now supplies non-destructive fencing and coherent final snapshots for
the inspected synchronous backend path. The pinned native source returns from
the data path before setting stopped/signalling its stop event. Null-backend tests
execute this mapping; CoreAudio/asynchronous mapping remains unsupported by this
new fence. Worker lifetime and native destruction remain separate obligations.

## Executed evidence

- Debug: 76/76 tests passed: 44 pure tests and 32 actual-controller tests.
- ReleaseSafe: 32/32 controller tests passed.
- Final native adapter: 3/3 silent-backend tests passed in Debug and ReleaseSafe.
  This includes eight reconstruction cycles, non-destructive fence/snapshot,
  restart invalidation and controlled missing-input invocation through the real
  installed native callback. No physical device was captured or sounded.
- Fourteen deliberately broken source variants failed their intended executed
  tests. Four sender defects join the ten earlier resource/receiver defects:
  commit on rejected write, ignored source fault, erased uncertain frame custody
  and acceptance of a wrong ACK. Compiler failure is not counted as detection.
- Lifecycle suites compiled for x86_64 macOS and aarch64 Linux. Neither ran there.
  Android/iOS and other OS support are requested scope, without execution evidence.

final-tests.json and its logs bind the core/controller revision. native-final.json
and its logs supersede the earlier host-source observation for the added native
fence and final three-test adapter suite. mutations/results.json binds the final
controller/helper/test sources. Recorded times are observations, not latency or
callback performance guarantees.

## Preserved failures and warnings

The first sender build failed on an integer-width inference in the overflow
guard. Explicit u64 conversion repaired it. A later callback build failed because
a declaration was placed between struct fields; moving it above the fields fixed
the syntax. attempt-1-source/, attempt-4-source/ and corresponding logs preserve
the failed bytes/output. The first 27 and subsequent 31 controller tests are
intermediate observations; final evidence covers 32 cases.

Native builds emitted the previously observed Perl locale warnings, including
intermediate failure-looking text. Each cited native command nevertheless ended
with exit 0 and a complete passing build/test summary; raw output is retained.

## Scope, ownership and next gate

The user explicitly expanded the requested support scope to all OSs, including
mobile. The platform capability chapter now tracks desktop/mobile/other targets
without claiming that requested scope is implemented support. No production OS
is qualified, and the unavailable Intel Mac still blocks its native/two-host gate.

Next C03 obligations are selected endpoint/format validation, native notification
and partial-start/stop-failure recovery, and asynchronous-backend fencing. Real
socket/identity owners and production workers follow in C04/C05. Sustained drift,
network recovery, physical playback, multi-OS packaging/signing/licensing and
clean-machine qualification remain open. No universal perfection or acoustic
exactly-once guarantee is asserted.

Sibling TLS work remains independently owned. Scoped application documentation
checks and full dependency-inventory checks are recorded separately; a scoped
pass never adopts an unreviewed sibling change or refreshes a pin.
