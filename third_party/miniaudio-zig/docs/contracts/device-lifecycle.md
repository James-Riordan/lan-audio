# Devices, borrowed lists and callback lifetimes

This chapter refines [CONTRACT.md](../CONTRACT.md) using the exact adopted header.
The transitions below are an application ownership discipline, not a new wrapper
API. Public exports remain raw `c` declarations.

## Acquisition ledger and stable storage

Use control-owned states `empty -> context_ready -> device_ready -> starting ->
running -> stopping -> device_ready -> destroyed`. Keep a separate acquired flag
for context and device. Failed start/stop adds a failure outcome while preserving
the obligation to destroy an already acquired device. Do not infer resource
ownership from whether the most recent operation succeeded.

For context C, device D and userdata U:

`live(D) => live(C)` and `callback_active(D) => live(D) and live(U)`.

Their addresses remain constant throughout the corresponding live intervals.
Returning an initialized aggregate by value, reallocating its containing array,
or replacing it while a worker retains a pointer violates this discipline.
Configuration structs may be temporary; retained pointees such as callback
userdata and custom allocator state need their own lifetime contract.

| Operation | Preconditions / linearization at the application boundary | Failure and retained ownership |
| --- | --- | --- |
| `ma_context_init` | Stable destination, explicit backend list for tests, no live object at destination | Only success acquires context; report original `ma_result` |
| `ma_device_config_init` | Chosen device direction; set fields on the returned defaults | Do not substitute zero initialization for upstream defaults |
| `ma_device_init` | Live context, stable destination and userdata, valid requested format | Success acquires a stopped device; failure leaves the caller responsible for its own previously acquired context, not an invented live device |
| `ma_device_start` | All callback-readable fields and buffers initialized; priming policy satisfied | May obtain initial playback data before returning; failure does not release the acquired device |
| `ma_device_stop` | Serialized non-callback control owner; device retained throughout call | May block; retain resource and callback-visible storage after error until authoritative teardown |
| `ma_device_uninit` | No competing control calls; userdata retained through return | Stops device as part of teardown; void return does not quantify acoustic tail or OS latency |
| `ma_context_uninit` | All devices using context are uninitialized; no list borrows remain | Preserve result where available; do not promise device operation after context teardown |

Never call device init/start/stop/uninit from a native callback. Application
serialization is stricter than some upstream APIs' thread-safety guarantees and
makes rollback reviewable. Cleanup follows dependencies: revoke admission,
request/wake workers, join the owners that can still access shared buffers,
uninitialize the device at the appropriate fence, then free shared storage and
context. Exact worker-versus-device join order depends on which owner needs the
other to make progress. There is no universal reverse-call-stack shortcut.

## The start-time callback trap

The declaration comments for `ma_device_start` describe obtaining initial playback
data before the call returns. Therefore an application `state = running` assignment
after successful start cannot be the callback's permission to use initialized
storage. Establish callback-visible readiness before calling start; use a separate
control transition to record the outcome. Do not read a plain control-owned state
from the callback to guess whether the transition has finished.

The current LAN Audio callback reads bridge/userdata and does not branch on
`AudioDevice.state`; keep that separation. A fake-native lifecycle test must invoke
the callback synchronously during start, then inject start failure and verify
cleanup. A test that only invokes callbacks after start returns misses this case.

## Enumeration has a different ownership boundary

`ma_context_get_devices` returns context-owned lists. The next call invalidates
previous pointers, as does context destruction. Do not free those pointers. Copy
the selected ID and display data under one control owner's serialization before
refreshing or publishing a UI snapshot. Treat names as display text, not stable
identity; the first enumerated item is not necessarily the default.

`ma_context_enumerate_devices` offers callback enumeration. Keep the callback
simple; do not initialize a device or call `ma_context_get_device_info` from it.
Detailed information may require opening/probing the native backend. The pinned
comment for `ma_context_get_device_info` discusses share mode, but the declaration
has no share-mode argument. Follow the actual declaration and inspected backend
behavior; do not invent a parameter from descriptive prose.

A saved endpoint ID is backend-specific and may become stale after disconnection,
reboot or device replacement. The product must explicitly choose between reopening
that endpoint, reporting its absence, or asking for a replacement. It must not
silently turn a selected loopback endpoint into a microphone or another output.

## Callbacks, diagnostics and completion

For each invocation, process only the provided frame count and active directions.
Input/output pointers are borrowed for that invocation. Copy captured frames to
owned bounded storage; fill the requested playback output, including deliberate
silence for any shortage. Buffer-size hints are not a promise of callback length.
All callback work must remain bounded by that invocation's frame count.

Publish only qualified atomics or bounded messages from a callback. Plain counters
may be read after the native fence; a control flag, callback count, empty queue or
notification is not itself that fence. Callback return, native uninitialization,
worker join and the last audible sample are distinct events. A timeout diagnoses
a slow or stuck native operation; it does not grant permission to free its memory.

Unexpected stop/hotplug notifications require a separate bounded notification
adapter and generation tag before automatic recovery is added. Notifications do
not transfer device ownership. LAN Audio's current adapter has no installed
notification callback; the behavior is proposed in [Q03](../implementation/qualification.md#q03).
