# WP08 — Usable control and recovery

Status: planned. Depends on WP03–05; use WP07 snapshots. Acceptance: A1/A2/A4/A6.

The [configuration resolution contract](../../design/configuration-resolution.md)
defines pure validation, settings precedence/provenance, immutable operation
snapshots, bounded publication and per-file tests. The
[ecosystem integration contract](../../architecture/ecosystem-integration.md)
keeps all user surfaces on one engine and optional integrations outside mandatory
audio closure. Implement these contracts with the C06 command path; no separate
UI-owned engine or ambient context mutation may bypass them.

| Planned file | Contract / first surface |
| --- | --- |
| `src/app/commands.zig` | Typed devices/send/receive/status/stop commands; validate before any capture or listener side effect. |
| `src/app/presentation.zig` | Stable user-facing statuses/recovery messages from runtime snapshots, without exposing internal implementation choices. |
| `src/app/settings.zig` | Versioned owned settings, atomic writes, bounds and unknown-version behavior; CLI and later UI share validation. |
| `tests/integration/commands.zig` | Help/status no side effects, invalid input no device start, coherent exit codes and interrupt cleanup. |

Present source, destination, format, connection/trust state and latency profile
before start. Device selection must use an actual capability descriptor and handle
stale enumeration. Distinguish connecting, awaiting authorization, priming, playing,
rebuffering, device lost and stopped. A green status must reflect active delivery;
silence substitution cannot be disguised as recovered media. User stop always has
an immediate visible acknowledgement plus truthful stopping/completed state.

The first CLI may require explicit peer address and credentials for an alpha. For
normal use, provide a pairing workflow with understandable identity verification
and revocation. Do not silently trust a newly discovered or changed peer. Offer
latency/fidelity choices in understandable terms, preserving the fidelity-first
default once the user preference is established. Do not present raw TLS structures,
ring sizes or ZSON syntax as the main user workflow.

Add tray/menu-bar presentation only after the same application lifecycle works.
It must dispatch the same typed commands and consume the same snapshots. No second
audio/network engine belongs in UI code. Launch-at-login is explicit and reversible.
Shutdown during every displayed state must release all owned resources.

Exit: a user can select the two devices, authorize the peer, start, see failures,
recover and stop without editing source. Keyboard/accessibility and error messages
must be checked on actual selected surfaces. No claim of a finished GUI from a CLI
test or screenshot alone.
