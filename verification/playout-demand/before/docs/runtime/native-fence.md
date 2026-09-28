# Callback source faults and the synchronous native fence

This C03 subset adds live source-fault publication to CallbackBridge and
AudioDevice, plus an explicit non-destructive `fence()` and `finalSnapshot()` in
[`audio_device.zig`](../../src/host/audio_device.zig). It is source-inspected for
the selected synchronous backend path and executed on the silent null backend.
It is not a blanket native or cross-platform qualification.

## Fault publication and finite representation

One data-callback owner updates the capture queue, reason bits and diagnostic
counters. Native notification owners may also store true to capture_failed and
playback_failed, as explained in [native events](native-events.md). The data callback publishes
sticky capture_failed and capture_faults atomics; the worker loads capture_failed
with acquire ordering. Fault bits are overrun=1, missing_input=2,
invalid_samples=4 and counter_exhausted=8. Only that callback owner ORs the bitset,
so no atomic read-modify-write or callback lock is required. Reinitialization is
permitted only after all earlier owners have joined.

captureInput first validates every sample word in the supplied callback input.
Finite words, including negative zero and subnormals, retain their exact bits.
Nonfinite input is rejected before any part of that callback is published.
Queue overflow retains the fitting prefix and marks the remaining source gap.
After any source fault, later callback inputs are counted as dropped without
publishing additional frames that could look contiguous. capture_overrun remains
available with its narrower original meaning; senders use capture_failed.

Positive-frame null capture input invokes `missingInput` from the actual installed
native callback. It records loss rather than inventing zero-valued samples.
Zero-frame input creates no source loss. Saturating additions publish
counters_exact=false before an exact diagnostic claim can be made; capture-counter
overflow also stops the source. Output-counter overflow marks inexact diagnostics,
without labeling ordinary startup/tail silence as a source fault.

There is no callback allocation, blocking, logging, network operation or device
control. Validation and copies are O(frames * channels). This adds an input scan;
its real callback timing/overhead remains to be measured on physical devices.

## Native source mapping and its scope

The inspected, pinned [miniaudio source](../../../miniaudio-zig/vendor/miniaudio/miniaudio.h)
selects its synchronous audio loop when onDeviceRead, onDeviceWrite or
onDeviceDataLoop exists. That loop returns from the data path and backend stop
before storing stopped and signalling stopEvent. ma_device_stop waits for this
event on the synchronous path. Its already-stopped result is safe for the same
data-callback premise. Application control methods must remain serialized.

AudioDevice records this backend shape at initialization and excludes mac_playback
from the qualified subset. It does not call miniaudio's private helper or add a
vendor API. `fence` checks the subset, refuses failed native state, performs stop
when running, and publishes fenced only after return. Native device and context
storage remain initialized. Repeating a successful fence is harmless. Starting
again invalidates fenced before calling the native API.

This establishes a non-destructive *data-callback* boundary for the selected
mapping. An application [notification callback](native-events.md) now publishes
only atomic flags and remains a separate native borrower until deinit. Other native
borrowers must still be declared by the future executor. Queue/worker ownership
survives the fence, and destruction still requires the worker's separate join.
Backend physical drain and sound at the listener are not claimed by this fence.

The original deinit remains the final native reclamation operation. After it
returns, snapshots are also allowed while the containing AudioDevice storage
still exists. No snapshot is permitted on a fresh/unfenced/running device.
Snapshots copy only callback-owned totals, fault bits and the exactness flag;
they do not read live queue indices on behalf of a third owner.

UnsupportedFence and UnresolvedNativeFailure retain device ownership. A blocked
native stop retains the issued lifecycle operation. A deadline does not set
fenced or authorize freeing memory. Failed/partial native acquisition and
asynchronous backend recovery still need explicit executor mappings; this change
does not disguise deinit as a non-destructive fence while a worker needs a device.

## Actual observations and remaining C03 gates

The silent native suite verifies callback transfer, eight reconstruction cycles,
snapshot rejection before fencing, stable totals after non-destructive fencing,
pause/resume invalidation and null-input fault publication through the actual
installed C callback pointer on a never-started null device. It does not modify
callback pointers, introduce a production test bypass or access physical audio.
The controlled callback invocation is an ABI test, not an observed driver fault.

The separate fake-owner suite pauses callbacks between queue release and return,
and checks that no ACK/free occurs before fence completion. That remains an
independent model of the native contract, not execution of a paused OS callback.

Explicit endpoint selection and post-open format validation now have the bounded
contract below. Still open: native start/stop partial-failure injection and recovery, physical hotplug and
backend notification coverage, CoreAudio/other asynchronous fences, and actual WASAPI capture timing.
Mac/other OS native execution and packaging remain separate acceptance gates.

## Selected endpoints and the callback format boundary

`initWithOptions` accepts separate playback/capture Endpoint selectors and a
conversion policy. `init(profile)` keeps its existing system-default behavior with
conversion allowed. A selector is either system_default or an exact backend name.
Named selectors are borrowed only during the call. Empty, oversized or embedded-NUL
names fail before creating a context; selectors for unused directions also fail.
Names are case-sensitive bytes, not persistent hardware identities. Duplicate names
are ambiguous and fail; a missing name fails rather than opening a different device.
A future discovery/UI adapter must expose these limitations and support stronger
identity selection where the backend provides it.

Selection enumerates once in the newly owned context, scans each required list,
and copies the selected native ID before initializing the device. Enumeration
storage belongs to miniaudio; no pointer escapes the call. A WASAPI loopback source
selects from the playback list, but passes its ID in config.capture.pDeviceID.
This follows the native loopback role rather than selecting a microphone. The
native header documents enumeration pointer invalidation on another enumeration
or context destruction, and copying device IDs during device initialization.
All control calls remain serialized. Enumeration can allocate and block on this
control path; no selection or probing runs in the callback. Work is linear in the
number of enumerated devices times the bounded device-name length, with two copied
IDs and fixed stack storage beyond the native enumeration allocation.

The application callback contract is 48,000 frames/second, binary32, two channels
in front-left/front-right order. Initialization now requests that channel map and
checks the actual callback rate, sample representation, channel count and map after
native initialization, before setting ready. A mismatch destroys the successfully
created device and then its context. Enumeration/selection failures destroy only
the successfully created context. Native initialization failure retains the existing
documented native failure cleanup contract; no uninitialized device is uninitialized.
Every rejected acquisition begun from empty leaves the application state empty
and cannot be started. Calling init on an existing device returns InvalidState
without disturbing that existing owner.

`openedFormat()` returns an immutable acquisition-time copy of native sample
representation, count, rate and left/right-map agreement for each active direction.
It does not read native fields while rerouting can mutate them. It is rejected after
a known health fault and invalid after deinit. With conversion=allow,
miniaudio may convert between this native format and the validated callback contract.
With require_native, every active direction must match all four dimensions or the
open returns NativeConversionRequired after device/context cleanup. This detects
the native format conversion requirement; it does not establish bypass of OS
mixing, gains, endpoint effects, physical resampling or acoustic fidelity. Future
runtime format changes and notifications must invalidate/reconstruct the generation.

The selection tests use independent synthetic device names/IDs for absent and
duplicate matches, and enumerate/open the real silent backend for selected playback
and duplex operation. They repeatedly reject a missing name, reconstruct successfully,
discard borrowed name storage, then start and fence. Dimension checks reject a
different sample representation, channel count, rate or channel map in either direction.
These are separate host-root test artifacts: merely placing tests in an imported
module does not execute them from the integration-test root.

The [native-selection evidence](../../verification/native-selection/RESULTS.md)
distinguishes these executions from unexecuted driver failure paths. No physical
device or foreign OS was opened. Hotplug between enumeration and open still relies
on the native open returning an error; stable IDs, discovery UX, physical format-change/notification qualification, asynchronous fencing and actual
failure injection remain open.
