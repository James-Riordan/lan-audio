# Directory architecture and migration contract

## Existing, populated application structure

```text
lan-audio/
  AGENTS.md                         short agent entry and safety/ownership constraints
  README.md                         human entry; current behavior and commands
  build.zig, build.zig.zon           build graph and package metadata
  transport-lock.json               reviewed adoption identity, never a dynamic cache
  src/
    root.zig                        stable core module exports
    session/{session,receiver}.zig   admission and serialized stream composition
    media/playout_window.zig         positions and bounded copied blocks
    media/format.zig                 checked experimental v2 application dimensions
    media/block_assembler.zig        copied callback-sized prefixes and explicit commit/EOF
    protocol/v1.zig                 unchanged experimental wire meaning
    protocol/{v2,negotiation}.zig    finite f32 codec and serialized record-order gate
    runtime/pending_block.zig       private owned v2 decode and unqueued suffix cursor
    audio/{frame_queue,callback_bridge}.zig
    host/audio_device.zig            optional miniaudio owner, separate build module
  tests/
    unit/{core,wire,callback}.zig    no physical devices; real threads in queue test
    unit/protocol/{v2,negotiation}.zig independent bytes and record-order cases
    unit/media/assembler.zig         independent ordered-prefix/EOF/loss checks
    unit/runtime/pending_block.zig   independent partial-queue/borrow/abort checks
    integration/{audio_device,tls_receiver}.zig
    integration/{tls_v2,loopback_transport,v2_codec_probe}.zig
    integration/{protocol_v2_reference,protocol_v2_peer}.py
    hardware/windows_capture.zig    explicit physical-device step
    dependency.zig                  stable externally referenced wrapper consumer
  spec/
    session/SessionWindow.{tla,cfg}
    stream/EndDrain.{tla,cfg}
    concurrency/SpscPublication.{tla,cfg}
    runtime/RuntimeOwnership.{tla,cfg} design model for custody and bounded drain
    runtime/ReceiveDrain.{tla,cfg}   frame-identity/prefix/tail/fence design model
    README.md
  docs/
    PRODUCT.md, ARCHITECTURE.md, MATHEMATICS.md, DEPENDENCIES.md
    TRANSPORT.md, CALLBACKS.md, VERIFICATION.md
    implementation/                 implementation contracts and ordered work packages
    literate/                       connected explanation, derivations and proof ledger
    protocol/                       canonical implemented v2 format/state contracts
    media/                          source assembly ownership and conservation argument
    architecture/                   module direction and platform capability policy
    development/                    workflow and source-documentation requirements
    design/                         system-level proofs and assumptions
    reference/                      per-file contracts and exhaustive path index
    verification/                   product acceptance and scenario definitions
  tools/                            small, named custody/model/documentation tools
  verification/                     immutable phase evidence and before-images
```

The stable top-level documents retain their paths for existing links. Deeper
documents provide implementation detail, not competing definitions of the same
protocol. Keep a single owner for each fact. `tools/` is still small enough to be
coherent; do not split it merely to make the tree taller.

## Planned directories: create with their first real implementation

| Destination | Owns | Must not own |
| --- | --- | --- |
| `src/app/` | command configuration and lifecycle orchestration | C callbacks, cryptographic algorithms |
| `src/host/net/` | OS sockets, readiness, monotonic clock adaptation | peer trust decisions or media sample rules |
| `src/security/` | pairing policy and persisted authorized identities | custom TLS/ciphers |
| `src/runtime/` (pending helper exists) | remaining capture/send and receive/playout workers, cancellation and joins | UI rendering |
| `src/media/` | formats, assembly, clock estimation, prefill and resampling policy | socket ownership |
| `src/protocol/` | versioned bounded records and negotiation | hardware discovery |
| `src/telemetry/` | bounded measurement records and snapshots | raw audio retention |
| `tests/simulation/` | deterministic clocks, impairments and reference expectations | assertions that a simulated pass is hardware qualification |
| `tests/e2e/` | two-host acceptance orchestration | production private keys |
| `packaging/windows/`, `packaging/macos/` | release dependency closure and platform launch integration | development SDK mutation |

Do not create placeholder files. Each planned file appears in a work package with
its first caller, contract, test and deletion/extraction rule. Combine adjacent
proposed files if their interfaces prove inseparable; record the decision and
update the plan before creating redundant abstractions.

The [completion sequence](completion-sequence.md) adds concrete next-slice
destinations and per-file semantics, including runtime/pending_block.zig and its
independent tests. These remain proposed paths until real code and callers exist.

The [configuration design](../design/configuration-resolution.md) further specifies
the planned app config/settings/commands/presentation files and their unit/storage/
command tests. These refine the existing `src/app/` boundary; optional ecosystem
adapters acquire a directory only with an admitted API and a real caller.

## Dependency direction

The executable lifecycle abstraction lives at `spec/runtime/lifecycle_transactions.py`
with `tools/check_lifecycle_spec.py` as its read-only runner. It is specification
code, not a second production lifecycle or a runtime Python dependency. The
[transaction chapter](../design/lifecycle-transactions.md) maps it to the full C02
contract. [C02a](../runtime/lifecycle-core.md) now implements the acquisition/abort
subset in `src/runtime/lifecycle.zig`, with real-controller fake owners in
`tests/integration/runtime_lifecycle.zig`. Native/graceful composition stays open.

Application → runtime owners → protocol/media/queues + host adapters → technology
libraries → OS. Core code may import Zig std and sibling pure modules, but not
`audio_host`, TLS, network I/O, UI or configuration parsers. The host imports core;
core never imports the host. Product authentication policy consumes a verified TLS
channel; a record's stream ID cannot authenticate a peer.

`miniaudio-zig` and `tls-zig` keep their current independently usable source trees.
This task documents every admitted file without moving their sources or SDK. New
generic TLS platform support belongs in `tls-zig`; audio-specific scheduling and
pairing belong here. `ZSON` remains separate from Zig's `build.zig.zon`; the initial
CLI can use typed arguments without adopting a configuration language.

## Performed migration and preservation

Nineteen application source/test/model files moved into responsibility folders.
`src/root.zig` exports and build-step names remain stable; imports, build paths,
live documentation and the model runner follow the new locations. The wrapper
consumer stays at `tests/dependency.zig` because miniaudio's existing documentation
references it. No duplicate forwarding implementation was added.

`verification/handoff/migration.json` records every old/new path and the 38 authored
before-images. Existing `verification/*` history is untouched and may contain old
paths intentionally. Use the migration table to navigate historical diagnostics.
Generated caches/output are disposable, outside authored contracts, and were not
renamed into the source tree. Relocation must pass core/native/model/network checks
before being called behavior-preserving.
