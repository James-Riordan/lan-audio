# WP07 — Bounded observability and reproducible diagnosis

Status: planned; begin during WP04. Acceptance: A5/A7/A9/A10.

| Planned file | Required contract |
| --- | --- |
| `src/telemetry/counters.zig` | Typed cumulative frame/byte/error counters, documented saturation/wrap and owner; no data races or shared mutable ordinary fields. |
| `src/telemetry/snapshot.zig` | Bounded coherent snapshots for control/UI; sequence/version semantics; callbacks never wait for readers. |
| `src/telemetry/events.zig` | Fixed event IDs and bounded parameter records for state transitions; overflow itself is counted. |
| `src/telemetry/export.zig` | Worker/control-side serialization with schema version and redaction; no callback formatting or network/file write. |
| `tests/unit/telemetry.zig` | Counter boundaries, concurrent snapshot consistency and intentional overload behavior. |

At minimum distinguish captured, source-dropped, encoded, sent, authenticated,
decoded, recovered, late-discarded, queued, rendered-media, silence/concealment and
resampler-tail frames. Also capture device/worker errors, current generation,
queue occupancy, clock correction ratio, memory/copy counters and timing samples.
Do not assume conservation across stages without accounting for queue inventory,
abort discard, representation and resampling units.

Keep precise timestamps in named clock domains. A callback may write a bounded
event/snapshot mechanism with native atomic semantics; its diagnostics cannot
contain arbitrary strings or perform allocation. Existing callback-owned u64 totals
are readable only after deinit; implement an explicit live snapshot path before
polling them from UI. Logs redact credentials, authorization secrets and raw PCM.

Define trace schema and validation before adding exporters. Preserve schema/seed,
binary/tool versions, device identity, clock domains and lost-event count. Importers
reject invalid/unbounded data and unknown mandatory versions. Trace playback uses
a virtual clock; it must never sleep for attacker-supplied unbounded durations.

Exit: independent counter conservation checks pass for success, drop, cancellation,
resampling and reconnect; overhead and dropped telemetry are measured at load;
one observed failure can be replayed without a private credential or audio recording.
