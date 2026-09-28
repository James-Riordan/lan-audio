# WP02 — Fidelity-preserving v2 wire profile

Status: proposed implementation specification. Acceptance: A3/A8; existing v1 stays intact.

## Files and first consumers

| Planned file | Responsibility / first caller |
| --- | --- |
| `src/media/format.zig` | Checked rate/channel/representation/block dimensions; consumed by negotiation, capture assembly and renderer. |
| `src/protocol/v2.zig` | Bounded parser/encoder for the specification below; consumed first by independent protocol tests, then runtime workers. |
| `src/protocol/negotiation.zig` | Offer/accept state, role/format/stream binding and phase validation; one control/worker owner. |
| `tests/unit/protocol_v2.zig` | Independent golden layouts, malformed records and bit-pattern preservation; never generate expectations with the production encoder. |
| `tests/integration/protocol_v2_peer.py` | Independent byte producer/consumer over authenticated transport, both roles and fragmentation; no production credentials. |

Update `src/root.zig`, `build.zig`, contracts and parser limits. Do not change v1
PCM16, its ALPN or golden bytes. `jcr-audio/2` is the proposed experimental ALPN;
implement it only with this contract and a new compatibility statement.

## Proposed fixed header: 48 bytes

| Offset / width | Field / validity |
| --- | --- |
| 0 / 4 | ASCII `JCR2` |
| 4 / 1 | Version 2 |
| 5 / 1 | Kind: OFFER=1, ACCEPT=2, AUDIO=3, END=4, ACK=5 |
| 6 / 2 | Header length 48, unsigned big-endian |
| 8 / 4 | Body length, unsigned big-endian; kind-specific exact validation |
| 12 / 4 | Flags zero; reject unknown semantics |
| 16 / 16 | Nonzero stream ID, identical throughout one authenticated negotiation |
| 32 / 8 | Source frame position, unsigned big-endian |
| 40 / 4 | Frame count, unsigned big-endian |
| 44 / 4 | Reserved zero |

OFFER/ACCEPT have position/count zero and a 16-byte body: rate u32 BE, channels
u16 BE (=2), representation u16 BE (=1 for f32 little-endian), max_frames u32 BE
(1..1024), reserved u32 BE (=0). Initially support 44100/48000/96000 frames/s only
when both actual endpoint profiles support the selected application format. The
receiver must echo the complete accepted offer, not silently substitute a rate.
Default experimental max_frames is 240; its duration depends on rate.

AUDIO has 1..negotiated_max_frames frames and exactly `count*2*4` body bytes.
Serialize finite binary32 patterns as little-endian u32 words without arithmetic;
preserve negative zero/subnormals. Reject nonfinite samples before publishing any
block. Maximum record is 48+1024*8 = 8240 bytes, below the current 16 KiB TLS write
limit. This is a TCP record limit, not a safe UDP payload size.

The initial ordered-stream receiver requires frame_position exactly equal to next
expected source frame, then advances by count with checked addition. Source gaps,
duplicates, replay and overflow fail that stream; future recovery transports need
their own explicit frame-range admission policy. END has empty body, count zero
and position equal to exclusive final frame. ACK echoes that end only after the
agreed receiver drain/join boundary. Empty streams may end at zero.

## State and error behavior

Windows capture client offers after mutual TLS and authorized roles; Mac playback
server accepts only after capability validation. No AUDIO precedes ACCEPT. The
sender waits for ACCEPT before starting capture or publishing samples. Failed
offers close with a local typed reason; no silent v1 fallback. One stream per
connection initially. Reconnect uses fresh identity/generation binding. Byte
fragmentation/coalescing and partial writes are independent of media records.

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
