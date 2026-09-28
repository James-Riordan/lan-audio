# `examples/quic-contract/build.zig.zon`

Source: [examples/quic-contract/build.zig.zon](../../../../../examples/quic-contract/build.zig.zon)  
Source SHA-256: `66d19bd2e2988378a8da716257ec83840a7b52fc14122ad324044a9e2ac72057`  
Snapshot bytes: 299. Review date: 2026-09-26.

## Responsibility

Separate package consumer of the pure recordless contract and event queue.

## Ownership, invariants and failure behavior

Builds against dep.module("tls_quic") without SDK artifacts. provider.zig is explicitly a synthetic contract fixture, not TLS. Construction verifies the plan before incrementing observable counters; the host checks unavailable capability rejection, exact input prefix, real secret-event copy/ack and terminal cancellation. Uses a fixed local allocator, no sockets, filesystem credentials or native provider. Package fingerprint is newly generated for this example; existing package pins remain unchanged.

## Verification

[T01/T03 implementation evidence](../../../../verification/t01-implementation.md) records scope, commands and remaining gates. Update this source contract only after reviewing changed behavior.
