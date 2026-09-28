# Directory policy and migration

The authoritative existing/planned path list is [target-tree.txt](target-tree.txt). The [file catalog](../reference/catalog.md) documents every baseline first-party file, fixture and metadata file. Planned implementation files have design cards in [the roadmap](../roadmap/README.md); they are intentionally not empty compilable source stubs.

| Area | Responsibility | Creation/movement rule |
| --- | --- | --- |
| src/ | Library implementation | Keep current public paths; add one owner at a time with tests. |
| tests/ | Integration, ABI, simulation, fuzz and policy tests | Existing QUIC tests remain imported beside the core until a dedicated migration is verified. |
| examples/ | Minimal executable public consumer journeys | Never imply a demonstration is a reusable HTTP or socket implementation. |
| tools/ | Build, verification and maintenance commands | State reads/writes, prerequisites, exit status and platform assumptions. |
| docs/guides/ | Getting started and host usage | Commands distinguish existing from proposed steps. |
| docs/architecture/ | Boundaries, directory map and decisions | Keep capability claims aligned with the current source. |
| docs/contracts/ | Cross-component integration and API rules | Resolve ownership and failure semantics before coding. |
| docs/reference/files/ | Per-file contracts and declaration/test indexes | Source hashes detect stale commentary; regeneration needs review. |
| docs/roadmap/ | Ordered milestones and proposed-file cards | Each card names prerequisites, invariants and acceptance tests. |
| docs/formal/ | State relations and executable bounded models | State assumptions, abstraction and proof limits. |
| docs/verification/ | Current machine-readable inventory and dated results | Never overwrite historical evidence to resemble a new run. |
| docs/security/ | Threat model and qualification gates | Profile-specific requirements, not blanket certification. |
| deps/ | External SDK/build material | TLS SDK is inventoried, hash-verified and documented as upstream-owned. |
| vendor/ | Frozen imported contract fixture in QUIC | Preserve exact bytes until a coordinated contract replacement. |

## Migration protocol

Select a single cohesive move. Enumerate @import, @embedFile, package .paths, script working directories, fixture locations and external consumer references. Move with compatibility forwarding modules where needed. Run both build modes, examples and an external package consumer. Compare observable outputs and source closure. Update the file catalog and source links in the same change. A source move is complete only when old paths are either supported explicitly or documented as a breaking release change.

Do not create modules for a speculative feature merely to fill a tree. Early data, resumption and additional versions/extensions require a chosen consumer and a separate decision. The current implementation target is interoperable authenticated v1 transport with bounded streams; HTTP/3 remains an application-layer project.

## Generated and external material

Caches (.zig-cache, .zig-global-cache), zig-out, Python bytecode and run logs are excluded from the source-file review universe. Their lifecycle is regeneration, not hand editing. SDK files are covered individually in dependency-inventory.json, with role, hash and maintenance action; cryptographic library internals are not independently audited by this documentation pass. New documentation is indexed by artifact-register.json rather than recursively generating documentation about generated documentation.
