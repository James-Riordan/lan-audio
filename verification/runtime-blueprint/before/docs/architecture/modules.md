# Module boundaries and scale

The design grows by adding owned responsibilities with explicit contracts.
Scalability does not mean every quantity can grow without bounds: queues, record
sizes, peers and deadlines deliberately have finite limits. A changed limit can
invalidate arithmetic, latency and memory arguments and must be requalified.

## Dependency direction

```text
future user interface -> future control/runtime -> host/network/security adapters
                                      |                       |
                                      v                       v
                         protocol/session/media/audio     adopted wrappers

root.zig -> public pure modules (exports only)
protocol/negotiation -> protocol/v2 -> media/format
media/block_assembler -> media/format
session/receiver -> session/session + media/playout_window + protocol/v1
host/audio_device -> audio/callback_bridge -> audio/frame_queue
```

The diagram denotes ownership/import direction, not a second implementation graph.
Build-import, native-link, runtime-load and test-tool edges remain distinct in
[dependency documentation](../DEPENDENCIES.md). Dependency wrappers may own native
mechanisms without inheriting product pairing, latency or recovery policy.

## When to add a module, folder or package

Add a file when a coherent responsibility has a contract and a first consumer.
Add a folder when several such files have a shared vocabulary and ownership
boundary that makes navigation clearer. Add a reusable package only when actual
independent consumers justify the maintenance/versioning boundary. Product policy
does not become a Zig Lib merely because its implementation uses mathematics.

Names describe established responsibilities. Keep upstream wrappers transparent
(`miniaudio-zig`, `tls-zig`); keep v1/v2 compatibility boundaries explicit; use
function/type names for domain meaning rather than generic `utils`, `helpers` or
`manager` catchalls. Avoid broad relocations unless they remove a demonstrated
ownership or navigation problem. Stable public paths and exports are contracts.

## Per-module contract

Each module explains its domain/units, inputs, outputs, ownership, mutable state,
allocation and blocking behavior, aliasing, failure atomicity, bounds, versioning,
first consumers and independent verification. Public operations state additional
preconditions. Comments explain consequential implementation choices rather than
merely translating syntax. See [documentation maintenance](../development/documentation.md).

The pure core must remain deterministic for supplied inputs. It may neither read
ambient time nor open devices/network connections. Callback code is bounded and
nonblocking. Control owns acquisition/destruction; workers own their mutable
transport/parser/render state; callbacks own their specified queue side. No new
global registry or singleton silently bridges these owners.

## Extensibility and compatibility

A new protocol version can share a genuinely unchanged primitive; it must not
reuse an older receiver just because both have a field named sequence. V1 counts
fixed blocks; v2 counts source frames. A new channel layout changes byte products,
format echo and native capabilities together. A new platform supplies implementations
of already specified host contracts, with target evidence for ABI/lifetime behavior.

The user-facing control model remains independent of CLI/tray/menu-bar presentation.
Only one runtime owns start/stop, so a second UI cannot introduce a second lifecycle.
Idempotence is specified per operation: stop requests may coalesce, a drain
attestation may repeat, an audio packet may not replay. "Everything is idempotent"
would erase meaningful media events and is not a valid requirement.
