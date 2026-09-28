# `tests/quic/negative/wall-as-monotonic.zig`

Source: [tests/quic/negative/wall-as-monotonic.zig](../../../../../../tests/quic/negative/wall-as-monotonic.zig)  
Source SHA-256: `120f8a4b7b31c4d9206dc6513927d91091e6a4786b720c6204be10bb1369848d`  
Snapshot bytes: 186. Review date: 2026-09-26.

## Responsibility

Compiler misuse control for distinct recordless semantic types.

## Ownership, invariants and failure behavior

valid.zig must compile; other fixtures must fail with expected-type/found diagnostics for the intended unit/domain mismatch. These are intentionally invalid Zig programs, consumed only by tools/test-quic-types.py. They are excluded from native executable test roots.

## Verification

[T01/T03 implementation evidence](../../../../../verification/t01-implementation.md) records scope, commands and remaining gates. Update this source contract only after reviewing changed behavior.

### `typeCheck` — line 2

[Source declaration](../../../../../../tests/quic/negative/wall-as-monotonic.zig#L2)

```zig
export fn typeCheck() void {
```

Independent test fixture operation; preserve explicit expected outcomes and owned resource cleanup.
