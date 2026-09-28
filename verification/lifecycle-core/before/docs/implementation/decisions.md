# Decision register

Status words: **accepted** is a current requirement; **proposed** is a concrete
implementation default awaiting its work-package validation; **open** needs facts
or a user preference. None of these statuses means code already exists.

| ID | Status | Decision and reconsideration trigger |
| --- | --- | --- |
| D01 | accepted | First product path is Windows system output → 2019 Intel MacBook Pro playback. On 2026-09-26 James reported the laptop unavailable ("dead") and believed it runs Monterey. Treat Monterey as provisional, not an inspected deployment target; confirm exact OS/build/output device when available. |
| D02 | accepted | Preserve captured finite f32 bit patterns across the fidelity transport boundary; do not claim physical end-to-end bit perfection with unsynchronized clocks. |
| D03 | accepted | Keep v1 PCM16 byte meaning and ALPN intact. New fidelity profile is a separately negotiated v2. |
| D04 | proposed | First v2 transport remains TLS/TCP to reach a complete secure baseline using existing code. Benchmark impairment before selecting any datagram alternative. |
| D05 | proposed | First fidelity representation is interleaved little-endian IEEE binary32, stereo. Native format selection is negotiated explicitly; no silent precision downgrade. |
| D06 | open | Latency ceiling. Development trials use selectable 50/100/250/500 ms queue targets; these are experiment points, not user-approved defaults or guaranteed recovery. |
| D07 | accepted | Recovered data must arrive by its render deadline. Silence/concealment, source gaps and late discarded data have separate counters. |
| D08 | proposed | Authenticate peers with separately provisioned mutual certificates for the first two-host alpha. Pairing UX and secure per-device storage are required before normal-user release. |
| D09 | accepted | Public fixtures and frozen certificate clocks remain in tests only. No trust-all mode, plaintext fallback or unverified peer identity. |
| D10 | proposed | Version 1 user surface is an explicit CLI: devices, receive, send, status, stop. Add tray/menu-bar UI after the same lifecycle path works; no auto-start by default. |
| D11 | accepted | Fixed callback buffers and stable object addresses; control and worker teardown prove reclamation. No hidden callback allocation, waits, logging or I/O. |
| D12 | open | Exact recoverable fault envelope and clock/resampler tolerances. Establish from the adapter, Mac and latency preference; do not publish invented performance thresholds. |
| D13 | accepted | No dependency extraction merely for a named math concept. Technology wrappers remain `<upstream>-zig`; application policies stay in this product. |
| D14 | open | Release license, final product name, signing identities, distribution route and minimum supported macOS. Do not publish without resolving the applicable decisions. |
| D15 | proposed | Adaptive resampling is the likely continuous-clock solution; evaluate a qualified miniaudio path first. The dependency's [conversion-control evidence](../../../miniaudio-zig/docs/contracts/conversion-control.md) reports coarse ratio control and some overflowing phase updates. A safe actuator profile/fix/alternative and independent controller evidence are prerequisites to activation; no workaround is admitted by this decision. |
| D16 | accepted | Cap'n Proto is a design reference. No adoption or performance-equivalence claim without a measured reason and reviewed dependency closure. |
| D17 | proposed | Initial ordered v2 TLS/TCP receive path uses one pending decoded block and FIFO playback queue. Do not reuse the v1 fixed-block Window for absolute variable-frame offsets. Reconsider only with an explicit transport/scheduling contract. |
| D18 | proposed | Initial non-resampled END acknowledgement attests source-frame copying to native callback output plus downstream quiescence, not acoustic completion. Backend tail behavior and user-visible completion require native qualification. |
| D19 | proposed | First runnable CLI stays foreground with in-process status and termination. Cross-process status/stop require a separately specified local control channel; their appearance in the intended command list does not create IPC support. |
| D20 | accepted | LAN Audio is a prospective ZApp; reusable wrappers and ecosystem owners retain their contracts. Optional MetaOS/Quartz/Mediaz/Hydra integration does not become mandatory package closure. See [integration boundaries](../architecture/ecosystem-integration.md). |
| D21 | accepted | Resolve and validate an immutable operation configuration before acquisition; changing terminal context cannot redirect an active stream. Retry semantics are defined per operation, not assumed for audio consumption. |
| D22 | proposed | Ordinary settings resolve defaults, user, selected profile, explicit invocation in that order, with provenance and separate mandatory policy. The [configuration design](../design/configuration-resolution.md) defines failure purity and publication gates. ZSON needs a real admitted profile; ZON remains package metadata. |
| D23 | accepted | Future canonical documentation is intended to use Docz `.dcz`. Preserve current Markdown until producer/reader, semantic preservation, links, exports, checks and rollback pass the explicit migration gate; do not invent a local grammar or duplicate editable authorities. |

## Changes that require explicit records

For transport, format or controller changes, write the triggering measurement,
considered alternatives, selected contract, migration/compatibility effect and
verification gate here or in a linked decision document. A platform limitation
must not be solved by disabling validation. Source custody changes get reviewed
old/new hashes and fresh evidence, never an automatic verifier repair.

## Primary reference boundaries

Apple's [2019 16-inch specifications](https://support.apple.com/en-us/111932)
identify Intel processors; the exact 2019 model and installed OS still need host
inspection. The earlier ARM compile is not qualification for this laptop.
[RFC 8085](https://www.rfc-editor.org/rfc/rfc8085.html) informs congestion/message
size duties for any later UDP design. [RFC 3550](https://www.rfc-editor.org/rfc/rfc3550.html)
informs timestamp/jitter terminology; this plan does not declare RTP implemented.
[Cap'n Proto encoding](https://capnproto.org/encoding.html) illustrates representation
efficiency; it does not solve clock synchronization or packet recovery.
