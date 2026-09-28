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
    protocol/v1.zig                 unchanged experimental wire meaning
    audio/{frame_queue,callback_bridge}.zig
    host/audio_device.zig            optional miniaudio owner, separate build module
  tests/
    unit/{core,wire,callback}.zig    no physical devices; real threads in queue test
    integration/{audio_device,tls_receiver}.zig
    hardware/windows_capture.zig    explicit physical-device step
    dependency.zig                  stable externally referenced wrapper consumer
  spec/
    session/SessionWindow.{tla,cfg}
    stream/EndDrain.{tla,cfg}
    concurrency/SpscPublication.{tla,cfg}
    README.md
  docs/
    PRODUCT.md, ARCHITECTURE.md, MATHEMATICS.md, DEPENDENCIES.md
    TRANSPORT.md, CALLBACKS.md, VERIFICATION.md
    implementation/                 operational handoff and ordered work packages
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
| `src/runtime/` | capture/send and receive/playout workers, cancellation and joins | UI rendering |
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

## Dependency direction

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
