# Device events, media failure and reconstruction

The C03 native adapter now installs miniaudio's notification callback. This closes
the case where a device stops and no later data callback arrives to tell the
sender that its source is gone. It also stops future playback-queue consumption
after a known output failure. The implementation remains in
[`audio_device.zig`](../../src/host/audio_device.zig) and
[`callback_bridge.zig`](../../src/audio/callback_bridge.zig), with actual installed
callback ABI tests. This is a failure-publication boundary, not a complete recovery
executor or a qualification of physical hotplug on every backend.

## Event meaning and authority

Notifications may arrive from different native producers. Each fault reason has
its own atomic boolean: unexpected_stop, rerouted, interrupted and
unknown_notification. Producers only store true. A second true store cannot erase
the first; separate booleans avoid a lossy read/OR/write bitset and avoid an atomic
read-modify-write loop in a callback. Reinitialization may clear them only after
all earlier native and worker owners have joined. The native enum is mapped as follows:

| Native event | Application effect |
| --- | --- |
| started | No failure and no clearing of an earlier failure |
| stopped | Unexpected stop unless the control owner has published expected_stop |
| rerouted | Sticky fault; the selected endpoint/format contract must be re-established |
| interruption_began | Sticky fault; this generation cannot silently resume |
| interruption_ended | Does not clear a fault or restart a device |
| unlocked | No fault; this browser-specific event is not an interruption |
| unknown future type | Sticky unknown_notification fault |

Before initialization, stop or deinit, the control owner publishes expected_stop.
Before starting it publishes false. Notification producers never mutate the
control-owned state enum, call native control APIs or touch plain frame counters.
An actual failure racing an intentional stop may be classified as expected; the
stream is already stopping, and this intent flag does not certify delivery or
acoustic completion. Synchronous stop ordering prevents an old stopped event from
arriving after a later start under the reviewed native mapping. The asynchronous
mapping still needs native evidence and remains unsupported by fence().

A fault notification stores true directly to capture_failed and/or playback_failed
for the active device directions. This works even if no further data callback runs.
The capture reason bitset remains data-callback-owned; an external native fault
can therefore set capture_failed while capture_faults is zero. health() exposes the
separate native reasons. It consists of monotone atomic observations, not one
simultaneous snapshot: a true flag is evidence of a fault, while a false observation
cannot rule out a concurrent/future event. Notifications have no allocation,
blocking operation, retry loop, logging or I/O. Work and storage are constant.

## Custody after an output failure

Before failure, renderOutput copies a queue prefix and then fills its remaining
destination with silence. Once playback_failed is observed, it writes only silence
and leaves all queued media in the queue. With Q the queue sequence and O a later
failed-state callback output, this branch preserves Q'=Q and emits zero-valued O.
It increments silent_frames, never rendered_frames. Capture similarly retains its
already-published prefix and counts later inputs as dropped through its existing
sticky capture_failed branch. No fault flag grants reclamation or resets a cursor.

A positive-frame callback with no required output destination invokes missingOutput.
Those frames are counted as missing_output_frames rather than rendered media or
written silence; playback_failed is published and the queue is unchanged. A zero
frame callback has no missing-buffer fault. Invalid input/output buffers are counted
separately, so a duplex callback missing both contributes two invalid buffers.
All frame counters saturate and counters_exact becomes false on exhaustion.

A callback that already passed its flag load can complete a copy concurrently with
a fault publication. The implementation does not claim instantaneous preemption or
that no sound reaches a newly selected endpoint before a post-reroute notification.
The generation is failed regardless of such a final copy. Media helpers observe
failure before reporting graceful completion and must still join/fence owners.
The sender already observes capture_failed directly. ReceiveDrain now requires an
output_fault atomic at construction and checks it on admission, publication,
start authorization, drain polling and ACK preparation. Bind this to the actual
bridge.playback_failed in the native worker. Tests bind it both to an independent
fake-device flag and the real CallbackBridge. The full native worker still remains
to be implemented; no success is inferred merely because a queue can become empty.

If failure arrives during a receiver queue write, the copied prefix is committed
to PendingBlock's cursor before the subsequent fault check requests media_fault.
This preserves the partition into copied, queued and pending frames. ACK preparation
validates its exact operation token before observing health; a foreign token or
illegal result does not mutate the controller. It then rejects known output failure
before returning a new descriptor. Completion uses separate token validation so
already-issued debt can still settle after abort. A late actual copied ACK remains
copied while media_fault prevents a graceful overall outcome; the adapter cannot
retract bytes already submitted. A failure that occurs after preparation is checked
again during completion. A known-not-submitted ACK is settled with the existing
transport_failed result, which conservatively classifies its remote observation as
unknown. No second ACK is issued to repair that outcome.

## Control state, stable metadata and final observations

start rejects an already failed generation without clearing its flags. If the
native start returns an error, or health is failed when a successful native start
returns, state becomes failed and native ownership remains until deinit. Stop/fence
does not repair health. Deinit requests an expected stop and uninitializes native
device/context before permitting a new init to clear the flags. A failed or blocked
native call still retains its original lifetime debt; no timer frees its storage.

openedFormat now returns an immutable copy made during acquisition. It does not
read fields that native automatic rerouting might mutate while running. A known
fault rejects that descriptor. This is opening-time metadata, not proof that an
unreported native reroute never happened. Backends without complete event reporting
still require an additional endpoint/format observation strategy.

finalSnapshot copies data-callback-owned counters, including missing_output_frames,
only after the existing data-callback fence or deinit. It does not incorporate the
live native notification booleans. Those can still change after a data fence and
must be read using health(). Native storage remains alive until native uninit
completes; a data fence does not join arbitrary notification producers.

## Native source mapping and remaining evidence

The pinned miniaudio header documents that stopped is separate from rerouted,
rerouted is sent after a route change, and event coverage differs by backend.
Its unlocked event is emitted on Emscripten. Its synchronous audio loop calls the
application stopped notification before signalling completion. CoreAudio's
stopEvent is signalled by its property listener, including interruption paths;
that event alone is not adopted here as proof that every data/notification callback
has returned. The existing Mac fence exclusion is preserved.

Tests invoke the actual installed callback pointers on never-started null devices,
exercise repeated normal null start/stop, and concurrently publish three different
notification types from real threads. They verify that no event clears another,
no queued media disappears after failure, no missing buffer is counted as silence,
and only reconstruction clears the failed generation. These controlled ABI
invocations are not observed driver failures. The
[native-events receipt](../../verification/native-events/RESULTS.md) identifies exact
sources, commands, failures, targets and limits. Native start/stop failure injection,
real hotplug, CoreAudio lifetime qualification, workers and two-host acceptance
remain open.
