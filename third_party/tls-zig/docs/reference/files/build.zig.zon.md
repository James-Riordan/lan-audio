# `build.zig.zon`

Source: [build.zig.zon](../../../build.zig.zon)  
Source SHA-256: `b49178f2ca98a3ee812e20e3b555f850673636474d84d4853b94d45ab52f3e4d`  
Snapshot bytes: 394. Review date: 2026-09-26.

## Responsibility

Package identity, pinned minimum compiler and distributed source allowlist.

## Contract, ownership and failure behavior

Package paths must include every import, embedded fixture, tool and document needed by the declared source artifact. SDK binaries are a separately provided dependency.

## Next implementation work

Rebuild from the package in a fresh directory with the pinned compiler and explicit SDK. Test missing dependencies and stale versions; do not assume development-directory success proves package closure.

## Verification obligations

Run the owning build or maintenance entry point described in the [verification guide](../../verification/strategy.md). A passive fixture/record is verified by hash and by its named consumers; it is not an executable test.
