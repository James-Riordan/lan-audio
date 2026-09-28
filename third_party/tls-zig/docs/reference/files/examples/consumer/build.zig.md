# `examples/consumer/build.zig`

Source: [examples/consumer/build.zig](../../../../../examples/consumer/build.zig)  
Source SHA-256: `8e67d1e2b2c25053c3c6b097a71f92d7e81bd8ef7920787d0c8032de94fdb620`  
Snapshot bytes: 1441. Review date: 2026-09-26.

## Responsibility

Standalone consumer build that imports the public TLS package.

## Contract, ownership and failure behavior

Links Winsock and stages TLS-exported runtime DLLs next to the executable. Its dependency comes from the sibling package manifest.

## Next implementation work

T2 adds target-specific linkage with explicit unsupported-target errors. Keep this external import regression whenever public exports or runtime packaging change.

## Verification obligations

Run the owning build or maintenance entry point described in the [verification guide](../../../../verification/strategy.md). A passive fixture/record is verified by hash and by its named consumers; it is not an executable test.

## Dependency edges

`std`. External module names resolve through the owning build graph; relative paths resolve from this source file.

## Declaration-by-declaration work map

Each entry points to the exact current source. Adjacent source documentation is retained below. Direct error names and assigned self fields are mechanically extracted navigation cues; they exclude transitive errors, pointer writes and full branch reasoning. Use the module contract above for obligations.

### `build` — line 11

[Source declaration](../../../../../examples/consumer/build.zig#L11)

```zig
pub fn build(b: *std.Build) void {
```

Review `build` as part of this file’s responsibility: Standalone consumer build that imports the public TLS package. Preserve the stated ownership/failure contract when extending this entry point.
