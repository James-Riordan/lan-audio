# `examples/consumer/build.zig.zon`

Source: [examples/consumer/build.zig.zon](../../../../../examples/consumer/build.zig.zon)  
Source SHA-256: `08021454f3c86bdf6fd55e42885a4d00259fd99b6b7889497d2bbf62d3b37f0c`  
Snapshot bytes: 285. Review date: 2026-09-26.

## Responsibility

Standalone consumer package metadata.

## Contract, ownership and failure behavior

Uses a relative ../.. producer path for this local demo. The pinned minimum compiler and declared package paths define the consumer source closure.

## Next implementation work

A distribution consumer test must replace local dependency with the released archive/hash and prove a clean package can build with an explicitly provided SDK.

## Verification obligations

Run the owning build or maintenance entry point described in the [verification guide](../../../../verification/strategy.md). A passive fixture/record is verified by hash and by its named consumers; it is not an executable test.
