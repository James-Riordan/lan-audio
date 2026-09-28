# WP02 — Fidelity-preserving v2 wire profile

Status: **locally qualified protocol components; product integration pending**.
Format, codec and negotiation have unit, bounded differential and independent
authenticated application-peer evidence. Real transport/device integration remains
WP03/04 work. Acceptance: contributes to A3/A8;
does not yet close them. Existing v1 stays intact. Canonical implemented contracts
are [v2](../../protocol/v2.md) and [negotiation](../../protocol/negotiation.md).

## Files and first consumers

| File / status | Responsibility / first caller |
| --- | --- |
| `src/media/format.zig` (implemented) | Checked rate/channel/representation/block dimensions; consumed by negotiation, capture assembly and renderer. |
| `src/protocol/v2.zig` (implemented) | Bounded parser/encoder for the specification below; consumed first by independent protocol tests, then runtime workers. |
| `src/protocol/negotiation.zig` (implemented) | Offer/accept state, role/format/stream binding and phase validation; one control/worker owner. |
| `tests/unit/protocol/v2.zig` (implemented) | Independent golden layouts, malformed records, maximum splits and bit-pattern preservation. |
| `tests/unit/protocol/negotiation.zig` (implemented) | Both roles, exact echo, continuity/drain and 140 control combinations. |
| `tests/integration/protocol_v2_peer.py` (implemented) | Independent fixture-mTLS byte producer/consumer over both application roles and fragmentation; no production credentials. |
| `tests/integration/protocol_v2_reference.py` (implemented) | Independent Python integer-word construction/validation for fuzz and peer expectations. |
| `tests/integration/v2_codec_probe.zig`, `tools/test_v2_differential.py` (implemented) | Test-only C ABI and killable bounded differential campaign with retained reproducer. |
| `tests/integration/tls_v2.zig`, `loopback_transport.zig` (implemented) | Short-transfer loopback client fixtures; both application directions, no native device. |

The core export and unit-test imports are updated. Preserve v1 PCM16, its ALPN
and golden bytes. `jcr-audio/2` is the separate experimental codec/gate identity;
its production transport use remains unqualified.

## Implemented boundary and remaining work

The canonical 48-byte layout, legal formats, exact finite-word representation,
parser bound and API contracts are now maintained in `docs/protocol/v2.md`.
The role/phase/continuity/drain table and transport commit point are maintained
in `docs/protocol/negotiation.md`. Review those canonical chapters rather than
keeping a second competing layout in this work package.

The code exports Format, wire_v2 and Negotiation from the pure core. Existing v1
exports, bytes and ALPN are unchanged. Pure tests cover literal golden vectors,
131,072 finite words, maximum-record split positions, malformed fields, both roles
and 140 control combinations. This is not authenticated transport qualification.

Independent peers and a bounded differential campaign are now implemented; see
[qualification scope](../../verification/v2-independent.md). Both native programs
are TLS clients, with opposite application roles; this is not native TLS-server or
LAN-device qualification. Next integrate the local contracts with real
endpoints/credentials and the one-owner runtime;
validate real source/sink format capabilities before outgoing ACCEPT. Keep the
new profile distinct from the v1 Receiver's block-index semantics. New session
identity/generation generation, capture assembly and callback/device integration
remain host work. Failed channels do not silently retry or fall back to v1.

## Tests and completion

Compare original f32 bit patterns with decoded words, including ±0, smallest/largest
subnormals, normal boundaries, finite extrema and seeded random finite patterns.
Test bad lengths, overflow, unknown flags/kinds, unsupported rates, NaN/Inf, wrong
stream, phase violations, early/truncated EOF, duplicate/overlapping positions,
empty END, last partial block and all split positions of maximum records. Test
short output leaves caller-visible output unchanged. Fuzz bounded parsing with
an independent decoder and a strict time/memory budget.

Exit: all tests pass, both independent peers agree on golden bytes, v1 regressions
remain green, finite-sample equality is demonstrated before resampling and docs
identify every conversion outside that boundary. Add a protocol/state model if
negotiation complexity exceeds the enumerated transitions; do not claim the v1
model proves v2 automatically.
