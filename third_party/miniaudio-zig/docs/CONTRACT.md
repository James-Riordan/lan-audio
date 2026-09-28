# Binding and device contract

## Authority and purpose

The pinned header is authoritative for upstream C declarations. `src/profile.h`
selects one ABI; both translation and native compilation include it. `src/root.zig`
exports that translation without inventing a second device object hierarchy.
An upstream upgrade is an explicit source/profile/API review and consumer test,
not an automatic response to a version number.

## Storage, lifetime and concurrency

Let `C` be a context, `D` a device and `U` its callback userdata. For their live
intervals, `address(C)` and `address(D)` are constant. A successful device init
creates an ownership obligation; failed init does not justify calling uninit on
an uninitialized object. The context outlives every device using it. Userdata and
its reachable buffers outlive every callback. Configuration values are temporary;
any pointer fields with longer upstream lifetimes retain those obligations.

The partial order for safe destruction is:

`close application admission < stop/join callbacks < device uninit < free U < context uninit`.

`ma_device_uninit` can itself stop the device; the order describes required effects,
not a demand to invoke stop twice. Stopping/uninitializing/starting devices inside
the data callback is forbidden by upstream because it can deadlock. Request a
control-owner action instead. A flag alone is not a join and does not establish
that a callback can no longer access memory.

The binding adds no synchronization. Operations must follow upstream thread-safety
contracts. Borrowed callback input/output is valid only for that invocation. Do not
retain it in a network queue: copy a bounded amount into owned storage. Initialize
the entire requested playback output, using silence for missing frames. Never read
capture input on a playback-only callback or write absent playback output.

For deadline-sensitive callbacks the application contract forbids heap allocation,
blocking locks, file/socket I/O, logging/formatting and unbounded work. Upstream
initialization may allocate and load OS libraries on the control thread. This wrapper
does not prove worst-case execution time of upstream conversion or device drivers.

## PCM dimensions and error behavior

For `N` frames, `C > 0` channels, `S` bytes/sample and sample rate `F > 0`:

`samples = N*C`, `bytes = N*C*S`, `duration_seconds = N/F`.

All allocation/index products must be checked for integer overflow before use.
Interleaved element `(frame, channel)` has index `frame*C + channel`, with
`0 <= frame < N` and `0 <= channel < C`. Device PCM is native-endian; a network
representation needs an explicit byte order and conversion. `f32` nonfinite
values must not enter the playout kernel. Amplitude limiting, dithering and integer
quantization policy belong to the media adapter; this binding leaves upstream
conversion results intact.

Preserve `ma_result` at the boundary. Report backend absence, permission denial,
unsupported configuration and disconnection distinctly where upstream identifies
them. No error should be converted into apparent successful silence during device
setup. Silence is a deliberate streaming underrun result, not proof of device health.

## Capability boundaries and evidence

Capture, playback, duplex and loopback are separate capabilities. The pinned
upstream manual describes loopback as WASAPI-specific. Do not promise macOS system
audio capture from the presence of a CoreAudio backend; a separate supported host
capture adapter or virtual device may be needed. Device playback on macOS is a
different requirement from macOS system capture.

`tests/contract.zig` verifies version constants, frame-size calculations, initialized
configuration and null-context/device teardown in stable local storage. It does
not prove active-callback reclamation, backend permissions or acoustic performance.
The session model in `../lan-audio/spec` formalizes the application's ownership
obligations; it is not a formal proof of miniaudio internals.

The separate [ABI probes](verification/abi.md) compare C-produced sizes, alignments,
selected offsets and enum values with translated Zig facts. A synthetic guarded
callback checks the tested calling convention. These tests add bounded ABI
evidence and deliberate mismatch rejection, not active device-lifetime evidence.

Sources: [pinned miniaudio header](https://github.com/mackron/miniaudio/blob/9634bedb5b5a2ca38c1ee7108a9358a4e233f14d/miniaudio.h)
and [upstream programming manual](https://miniaud.io/docs/manual/index.html).
The pinned header controls if the live manual changes.
