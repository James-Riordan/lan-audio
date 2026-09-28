# Source ownership and reading order

The public pure entry is [root.zig](root.zig); native audio is a separately built
module. Read [the stream argument](../docs/literate/stream-argument.md), then the
module contract and corresponding tests before changing an algorithm.

| Directory / files | Responsibility and allowed direction |
| --- | --- |
| `media/format.zig` | Checked v2 application dimensions; no protocol or host imports. |
| `media/block_assembler.zig` | Single-worker copied frame prefixes, commit frontier, final partial block and terminal discontinuity; depends only on Format. |
| `media/playout_window.zig` | Serialized fixed-block window, used by the existing v1 receiver; independent of I/O. |
| `protocol/v1.zig` | Existing PCM16 bytes and parser; compatibility boundary. |
| `protocol/v2.zig` | Finite f32 bytes/parser; depends on Format, not on a host or state machine. |
| `protocol/negotiation.zig` | v2 role/phase/frontier policy over validated records; depends on v2. |
| `runtime/pending_block.zig` | Private module importing the public core: copied AUDIO admission and unqueued frame cursor; no native lifecycle or public core export. |
| `runtime/lifecycle.zig` | Private resource ledger plus receiver fence/ACK/close effects; one reserved result, late ownership retained. |
| `runtime/receive_drain.zig` | Private negotiated receiver owner composing pending custody, queue, tail start and terminal protocol; see [contract](../docs/runtime/receive-drain.md). |
| `runtime/send_drain.zig` | Private sender queue/assembler/write custody, native-fenced EOF and exact END/ACK outcomes. |
| `session/session.zig` | Existing serialized authentication/generation lifecycle kernel. |
| `session/receiver.zig` | Existing v1 composition of Session, Window and v1 wire. |
| `audio/frame_queue.zig` | Fixed concurrent SPSC mechanism; knows frames/channels, not wire versions. |
| `audio/callback_bridge.zig` | Fixed capture/playback queues, overrun/silence policy and owned diagnostics. |
| `host/audio_device.zig` | Native miniaudio device lifetime/backend profiles; depends on pure bridge and upstream wrapper. |

Do not have a lower-level module import root.zig to reach another pure module;
use its direct relative dependency. Root exports public names without constructing
owners. Do not have the core import audio_host, TLS, sockets, UI or a runtime singleton.
Tests import the public module to catch broken exports and use independent oracles
for observable behavior. The full [module rules](../docs/architecture/modules.md)
explain when a new directory is justified.

Planned runtime, network-host, security and app directories are described in
[the layout](../docs/implementation/layout.md). They become populated directories
when real code and its first consumer exist. An empty file with a future-looking
name is not implementation progress.
