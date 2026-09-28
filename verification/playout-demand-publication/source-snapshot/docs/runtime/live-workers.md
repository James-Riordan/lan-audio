# Foreground live audio owners

The application now has actual `send` and `receive` commands. This increment
connects the existing native socket, verified channel, lifecycle ledger and media
drain owners to a real worker thread and real callback queues. Windows execution
is qualified separately from the Intel Mac build recipe. No iPhone app exists yet.
See [first-run instructions](../first-run.md) and the phase
[evidence](../../verification/live-workers/RESULTS.md).

## Who may touch each object

`stream.run` allocates one fixed heap State containing AudioDevice, its bridge and
queues, Socket, Connection and the thread handle. The Windows sender also owns a
silent playback device to keep idle WASAPI capture clocked; both devices belong
to the same native aggregate and must be fenced/released together. The stack controller and two
native timers outlive State cleanup. Setup alone owns the ledger until the worker
acquisition completes. An atomic release/acquire start flag transfers ownership to
the worker. The control loop then observes only atomic health/completion flags;
it neither dispatches ledger effects nor closes the worker's socket. The worker
publishes completion with release semantics. Control acquires that publication,
joins the thread, fences/uninitializes the device and releases the connection and
socket before freeing the aggregate. A cleanup failure retains storage instead of
freeing an unresolved native owner; this exceptional terminal path is not recovery.

Callbacks retain their original restrictions: no network, allocation, logging,
waiting or device control. Each queue still has exactly one producer and consumer.
The extra worker timers never run on a callback. Windows uses a high-resolution
waitable timer when available, with a normal waitable-timer fallback; POSIX uses
`nanosleep`. Neither changes global timer resolution. The process-wide foreground
signal hook writes only static atomic flags. Registration and timer destruction
are tested through repeated cycles.

## Capture and copied transport custody

Sender captures 48,000 stereo frames per second through WASAPI loopback. A block
contains at most 240 frames (5 ms); finite f32 words retain their representation.
The 32,768-frame capture queue provides about 682.7 ms of local capacity, not a bound
on latency elsewhere. The worker pumps SendDrain and waits one millisecond when
no work is available. Socket readiness waits are cancelable and bounded.

The important boundary is `Connection.beginSend`: TLS has copied a complete
validated record when it returns. The worker settles the exact lifecycle token
and commits the assembler frontier there, before calling `finishSend` to drive
network output. A later network failure must not relabel accepted bytes as a
rejected write. `Controller.transportFailed` preserves that committed frontier,
marks remote observation unknown and initiates cleanup. A regression test checks
this ordering, stale generation rejection and repeated fault handling.

First Ctrl+C after setup requests graceful capture stop. The worker fences capture,
drains every queued frame and the final partial block, sends END, verifies ACK and
closes TLS. Second Ctrl+C, Ctrl+Break, receiver Ctrl+C, or setup cancellation aborts.
Native overrun/reroute/interruption faults remain sticky and abort the generation.
There is no silent splice over missing source frames. The [supervisor](network-recovery.md)
now reconstructs fully closed sessions after eligible failures.

## Playback and local completion

Receiver reads one authorized record, copies its samples into PendingBlock, then
publishes only accepted queue prefixes. It cannot overwrite a retained suffix by
reading the next record. The CLI starts playback after 1920 contiguous frames by default
(40 ms), configurable from 5 ms to the maximum buffer budget (at most 240 ms).
The lower-level runtime defaults to 20 ms. END starts a nonempty shorter stream; an
empty stream never releases media; the native receiver has already started
gated silent before ACCEPT. Fixed queue/pending/parser buffers bound local
storage, although the native TLS provider can allocate internally.

END begins one absolute drain deadline. Queue exhaustion, callback fencing, ACK
copied custody and TLS closure are distinct transitions. The original live-loop
attempt skipped the close effect after ACK and hung; the independent peer's
watchdog exposed it. The repaired loop handles the complete protocol gate while
executing TLS close. Normal, short, empty, cancellation, malformed, disconnect and
stall cases now check actual joined/fenced/released states.

CoreAudio's non-destructive stop fence remains unqualified. The Mac candidate
therefore uses the existing destructive `AudioDevice.deinit` boundary before ACK;
the bridge aggregate survives until worker join. Pinned miniaudio disposes both
AudioUnit instances before returning from its CoreAudio uninit path. This is a
reclamation premise still requiring native validation, not proof the last sample
has physically left a speaker. ACK attests local callback consumption/fencing,
never acoustic completion. `silent_frames` includes startup/tail zero fill; this
aggregate alone is not a measurement of mid-stream Wi-Fi dropouts.

## Identity, clocks and builds

The product requires explicit private credentials and the approved peer's leaf
certificate SHA-256. No fixture key, frozen clock or permissive trust fallback is
in the CLI. Wall time is read after connect/accept, so waiting for a peer does not
freeze certificate validation at application startup. Only the test probe injects
a fixture time. Pair creation generates new private keys and a private CA, discards
the CA signing key, and produces separate launch folders. Repeating creation checks
the existing manifest; it never silently rotates credentials. This is a development
provisioning tool, not OS-keychain enrollment, renewal or a complete pairing UI.

Windows keeps the reviewed TLS package export and staged DLLs. Intel Mac explicitly
links the same pinned records sources to a caller-supplied static OpenSSL SDK. The
app-owned recipe verifies the reviewed archive digest, targets Monterey 12, runs
OpenSSL tests and retains SDK/build/binary receipts. No sibling package is edited
and no Windows lock is refreshed. The Mac recipe has not run on this Windows host.
Its success, eventual bundle signing, CoreAudio behavior on Monterey/current macOS
and a real two-host run remain separate gates.

There is no clock-drift correction yet. Bounded between-session reserve growth
and automatic reconnect now exist; see [recovery and its limits](network-recovery.md). TCP can stall
behind lost packets, device clocks can diverge, and a finite prefill cannot solve
either indefinitely. Short successful loopback runs therefore do not establish
gaming latency, long-session smoothness, every-OS support or production readiness.

Platform references: [Windows waitable timers](https://learn.microsoft.com/windows/win32/api/synchapi/nf-synchapi-createwaitabletimerexw),
[OpenSSL build options](https://github.com/openssl/openssl/blob/master/INSTALL.md?plain=1),
[Apple deployment targets](https://help.apple.com/xcode/mac/current/en.lproj/deve69552ee5.html).
