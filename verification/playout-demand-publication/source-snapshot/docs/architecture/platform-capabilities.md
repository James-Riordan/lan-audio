# Platform awareness and graceful incompatibility

Status: design contract for production adapters and UI. Existing native audio
profiles are limited; Windows/Mac readiness is defined by observed execution,
not by the existence of a backend enum or a successful cross-compile.

Host requirement updated 2026-09-26: Windows 10 game audio over Wi-Fi to the
2019 Intel MacBook Pro speakers or iPhone playback, with no Bluetooth requirement. Monterey (macOS 12)
compatibility is explicitly required, plus newer releases supported by the hardware.
James will perform the final MacBook test after a release candidate is ready. The
exact installed OS/build, model and device remain uninspected; a required minimum
is distinct from a verified native result.

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

## Expanded support objective (2026-09-26)

James explicitly requested all OSs, including mobile. Treat this as the engineering
scope, with capability-specific support evidence, not an existing universal
support promise. Prioritize the original Windows-to-Intel-Mac route while keeping
portable owners independent of host APIs. No production OS is qualified yet.

| Target family | Current evidence | Required before production support |
| --- | --- | --- |
| Windows x86_64 | Pure/controller and silent-native execution; earlier physical capture observations have their own historical receipt | Selected device/format, real credentials/network workers, failure/recovery, installer and physical sustained qualification |
| macOS Intel / Apple Silicon | This increment compiles lifecycle tests for Intel only; user's Intel Mac remains unavailable | Actual OS/SDK/device and permission inspection, native fence/network qualification, signing and installation |
| Linux x86_64 / ARM64 | This increment compiles ARM64 lifecycle tests only | Host audio/network adapters, actual distributions/devices, permissions, packaging and sustained runs |
| Android | Requested target; no application adapter/build/execution evidence | Capability/API investigation on selected versions, permission/lifecycle tests, audio/network adapters and signed installation |
| iOS / iPadOS | iPhone receiver is now a primary requirement; shared policy compilation is checked separately from the still-unimplemented native app | Capability/API investigation on selected versions, permission/lifecycle tests, audio/network adapters and signed installation |
| Other OS/architecture families | Requested broad scope; no support claim | Identify actual host/SDK/API capabilities and memory model, then implement and qualify each advertised role |

Capture, system-output capture, playback, networking, background operation and
installation must each receive an explicit supported/unavailable/unqualified
status. A playback-capable host is not automatically a system-capture source.
No platform API or missing ecosystem abstraction is invented to satisfy a label.
Physical hosts and signing/release decisions remain necessary acceptance inputs.

The [Apple receiver work package](../implementation/work-packages/11-apple-receivers.md)
specifies shared semantics, native mobile lifecycle, local-network permission,
locked playback and signed installation. The [receiver-platforms phase](../../verification/receiver-platforms/RESULTS.md)
records actual current target-check outcomes; a provisional iOS 16 compile target
is not an asserted user-device minimum.
