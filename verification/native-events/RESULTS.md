# Native events, receiver output failure and Monterey targeting

This continuation prioritizes James's clarified use case: Windows 10 game audio
over Wi-Fi to a 2019 Intel MacBook Pro's speakers. Monterey compatibility is now
an explicit requirement, with newer supported macOS releases qualified separately.
Bluetooth is not a dependency. James's deferred MacBook run is the final acceptance
step after a release candidate is prepared; it has not happened and is not assumed.

## Implemented behavior

The native host installs the actual miniaudio notification callback. Concurrent
native producers publish separate sticky reason flags and mark affected capture
and playback directions failed without allocation, locks, logging, network calls
or device control. Normal requested stops are distinguished from unexpected stops.
Rerouting, interruptions and unknown events fail the generation; later started or
interruption-ended events do not repair it. Only complete reconstruction clears it.

Missing output buffers count unavailable frames separately from copied output or
written silence. Failed playback emits silence while preserving queued media.
Opening-time native format metadata is cached, avoiding later reads of fields that
automatic rerouting could mutate. Known faults invalidate that descriptor.

ReceiveDrain now requires a live output-fault atomic. It aborts on known failure
before admission, publication, start authorization, drain or new ACK preparation.
A fault detected after a queue write preserves the copied-prefix accounting. Invalid
tokens and results remain mutation-free. An ACK already in copied transport custody
can settle after a fault, but cannot restore a graceful outcome or be retracted.
Actual CallbackBridge failure tests preserve exact queued/pending abort accounting.

An unspecified macOS minimum now resolves to 12.0; explicit target version ranges
remain unchanged. This is an SDK/deployment configuration improvement, not native
execution or proof that every dependency can load on Monterey.

## Executed evidence and source scope

Before edits, all 121 application files in the prior native-selection receipt were
verified. before.json records them and the prior receipt hash. Changed source files
have preserved before copies. No vendor source, dependency pin or public core
export was changed by this continuation.

attempt-1/tests.json records the initial event revision: the combined Debug run
executed 87 tests (45 pure, 32 lifecycle, six native integration and four host-root).
All ten native tests also executed in ReleaseSafe. The native source remains at
that tested revision. The default Intel macOS target compiled as macos.12.0;
the initial explicit macos.26.0 compile is also retained.

receiver-final/tests.json supersedes the receiver helper and lifecycle-test hashes.
It records 36 lifecycle tests executed in Debug and ReleaseSafe, including the four
new output-failure cases; the unchanged 45 pure tests were cached in that later
Debug command and retain their actual execution from attempt-1. The updated receiver
compiled again for the implicit Monterey floor and explicit macOS 26 target. Neither
compile runs a Mac process, links a qualified native Mac audio/TLS closure, or checks
installation on the user's laptop.

Four isolated native implementation mutations were rejected by the intended executed
test: ignoring reroute, consuming failed output, failing normal requested stops,
and clearing failure on resume/start. Two isolated receiver mutations also produced
the intended TestExpectedError failures for ignored output faults and ACK preparation
after failure. The first receiver evidence parser incorrectly required FAIL on the
header line; Zig emitted an explanatory diagnostic before FAIL. The original logs,
false-negative results and original parser are retained. reviewed-results.json
corrects only the classification from those same verified logs; no product code was
changed to make the mutation checks pass. No timeout or compile error is counted
as an intended mutation witness.

## Limits and remaining gates

Controlled installed-callback invocations and real concurrent notification threads
use never-started null devices; they are ABI tests, not observed physical hotplug.
Normal null-backend callbacks/start/stop also execute. No physical audio, native
Mac/foreign OS execution, real production identity/socket workers, packaging or
game-audio performance qualification occurred. Native start/stop failure injection,
complete notification coverage, stable endpoint discovery, CoreAudio callback
fences and actual two-host timing remain open. The miniaudio CoreAudio stopEvent
source is specifically not promoted into a qualified all-callback fence.

Scoped documentation/reference/handoff checks and the current transport-custody
status are recorded separately in checks.json. The TLS build remains independently
owned and unadopted until its changed source is reviewed. A failing transport check
is recorded as failed, not erased by rehashing the lock. Exact mismatches belong to
the final receipt. No production-ready platform or timeless future-OS guarantee is
claimed by this evidence.
