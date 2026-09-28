# `tests/quic/negative/direction-as-level.zig`

Source: [tests/quic/negative/direction-as-level.zig](../../../../../../tests/quic/negative/direction-as-level.zig)  
Source SHA-256: `40f075f1ba0b63bcbba6a47bd32a8309e148710282f154ff1c72522ee36d5162`  
Snapshot bytes: 174. Review date: 2026-09-26.

## Responsibility

Compiler misuse control for distinct recordless semantic types.

## Ownership, invariants and failure behavior

valid.zig must compile; other fixtures must fail with expected-type/found diagnostics for the intended unit/domain mismatch. These are intentionally invalid Zig programs, consumed only by tools/test-quic-types.py. They are excluded from native executable test roots.

## Verification

[T01/T03 implementation evidence](../../../../../verification/t01-implementation.md) records scope, commands and remaining gates. Update this source contract only after reviewing changed behavior.

### `typeCheck` — line 2

[Source declaration](../../../../../../tests/quic/negative/direction-as-level.zig#L2)

```zig
export fn typeCheck() void {
```

Independent test fixture operation; preserve explicit expected outcomes and owned resource cleanup.
