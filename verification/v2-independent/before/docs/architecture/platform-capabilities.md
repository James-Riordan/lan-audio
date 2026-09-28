# Platform awareness and graceful incompatibility

Status: design contract for production adapters and UI. Existing native audio
profiles are limited; Windows/Mac readiness is defined by observed execution,
not by the existence of a backend enum or a successful cross-compile.

## Capability records, not operating-system guesses

The control owner obtains a fresh descriptor containing endpoint identity,
capture/loopback/playback roles, supported application formats, native conversion
policy, current availability and applicable permission state. Availability and
format support are revalidated when opening the selected device. A cached device
name is presentation text, never a stable identity or peer credential.

| Condition | Required behavior | Evidence before support claim |
| --- | --- | --- |
| Windows system output | Select explicit WASAPI loopback endpoint; preserve source-discontinuity reporting. | Actual capture plus format/device-change tests. |
| 2019 Intel Mac playback | Build x86_64 with compatible SDK/private TLS runtime; open selected CoreAudio device. | Native execution on the actual macOS/device. |
| Different OS/architecture | Build pure core where supported; report unavailable host features accurately. | Native ABI, backend, cancellation and callback qualification. |
| Unsupported rate/layout | Explain supported alternatives; require deliberate compatible selection. | No silent precision/rate downgrade in protocol tests or UI flow. |
| Device disappears | Stop/abort owned stream, retain actionable cause; offer reselect/reconnect. | Hotplug and default-device-change injection. |
| Permission denied | Explain which action needs permission and how the user can retry. | Real platform permission flow; no repeated hidden prompts. |
| Network unavailable | Bounded cancel/timeout and clear reconnect state. | Actual adapter faults plus repeatable impairment cases. |

Do not advertise a platform from a compiler target alone. Source portability,
dependency availability, native execution and packaged installation are separate
gates. The core currently restricts queue atomic qualification to x86_64/aarch64;
supporting another architecture requires an actual memory/ABI review.

## Plain-language control states

The planned product presents selected source and destination, connection/permission
status and the current operation. Distinguish disconnected, connecting, waiting
for audio, playing, recovering, stopping and stopped. Each transition has one
runtime cause and a bounded cancellation path. "Connected" must not imply that
samples are playing; "stopped" must not appear while native owners still run.

Actions are contextual: choose endpoints, connect, start, stop, retry, inspect an
actionable error. Preserve the cause when recovery fails. Details such as ALPN,
frame frontiers and TLS error codes belong in an expandable diagnostic/export,
not the main flow. Do not require the user to understand cryptography to distinguish
their own approved Mac from an unrecognized peer.

Accessibility includes keyboard operation, readable text scaling, non-color-only
status, discoverable focus, and announcements for meaningful failures. Validate
these in each actual UI framework; this chapter does not imply a UI exists.
