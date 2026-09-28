# WP04 — Complete Windows-to-Mac audio path

Status: runtime planned; the pure BlockAssembler and its tests are implemented.
Depends on WP01–03. Exit milestone: first real two-host sound (A1).

The [runtime ownership specification](../../literate/runtime-argument.md) now gives
the executable design model and explicit refinement obligations. Extend it for
partial initialization, multiple in-flight records and actual owner granularity
while implementing this package; its bounded checks do not prove this future code.

Use the [runtime blueprint](../runtime-blueprint.md) for exact ownership/commit
ordering, the [completion sequence](../completion-sequence.md) for the next slice,
and [R01-R15](../../verification/runtime-obligations.md) for independently observable
failure cases. [ReceiveDrain](../../design/receive-drain.md) checks variable-block
prefix custody, short-stream progress and the callback-return fence.

| Planned/changed file | Responsibility and required behavior |
| --- | --- |
| `src/app/main.zig` | Thin command dispatch; no hidden device start on launch/help/status. |
| `src/app/config.zig` | Typed validated send/receive settings; endpoint, peer identity, selected devices, format and finite resource limits. |
| `src/runtime/lifecycle.zig` | One control owner and rollback ledger for configuration, connection, priming, run, drain, abort and stop. |
| `src/runtime/capture_sender.zig` | Own assembler/TLS driver, drain captured frames, preserve partial block/write custody, detect overrun and emit END on graceful stop. |
| `src/runtime/playback_receiver.zig` | Own parser/negotiation/playout state, prime queue, submit complete validated sample ranges and drain before ACK. |
| `src/runtime/pending_block.zig` | One private fixed-capacity decoded block; retain unqueued suffix, advance only by accepted whole frames; never overwrite pending custody. |
| `src/media/block_assembler.zig` (implemented) | Copied finite frame prefixes, explicit downstream commit, final partial block and terminal discontinuity; native queue/worker integration remains. |
| `src/host/audio_device.zig` | Add explicit device IDs/formats and native failure mapping; keep fixed-address ownership and callback restrictions. |
| `tests/integration/runtime_lifecycle.zig` | Fake devices/transports verify every partial initialization failure and cancellation point frees each acquired resource once. |
| `tests/e2e/two_host.py` | Explicitly selected Windows/Mac endpoints, run metadata, bounded cleanup and no automatic secret copying. |

## Exact first workflow

Mac runs `lan-audio receive` with selected output, listener and authorized identity.
Windows runs `lan-audio send` with selected system-output source, peer and its own
identity. These commands are planned, not currently available. Connect/authenticate,
offer/accept format and initialize stable owners. After ACCEPT, admit capture and
start sending; the receiver accumulates contiguous prefill before starting playback.
Do not wait for playback priming before allowing the source to produce its first frames.
The first successful run must use actual Windows capture and Mac speakers/output;
Python fixture media and null callbacks remain useful tests but cannot satisfy A1.

Control owns worker handles and device storage. Workers own parser/encoder/transport
state. Callbacks own only their queue side and diagnostics. Do not pass Session or
Window methods into native callbacks. For failure cleanup, close admission, signal
and wake workers, bound drain, join owners, uninitialize devices, then free state.
Graceful stop and abort have distinct results; stale buffered media never crosses
into a new generation. Test start-stop-start under active traffic.

Block assembly retains partial input until complete; final partial blocks are
represented accurately by v2 counts. Capture overrun aborts the initial stream and
reports its cause. A queue short write preserves the unwritten suffix and checks
deadline/cancel before retrying. Do not busy-spin in the production worker as the
small integration probe does; use event/readiness wakeups with explicit deadlines.

Exit: an independently observed two-host run records real endpoint IDs/formats,
credential policy, binary hashes, start/stop behavior and audible output. At this
milestone limited-duration drift remains a known deficiency until WP05. Run failure
injection at every resource acquisition and signal termination while queues are
full/empty. Do not add an unattended service to obtain this milestone.
