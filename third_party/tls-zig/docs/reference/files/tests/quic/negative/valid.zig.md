# `tests/quic/negative/valid.zig`

Source: [tests/quic/negative/valid.zig](../../../../../../tests/quic/negative/valid.zig)  
Source SHA-256: `b6de76e36b6927171ba47b6b2030ad78858e603c662e9f42f2c74416747f3fee`  
Snapshot bytes: 198. Review date: 2026-09-26.

## Responsibility

Compiler misuse control for distinct recordless semantic types.

## Ownership, invariants and failure behavior

valid.zig must compile; other fixtures must fail with expected-type/found diagnostics for the intended unit/domain mismatch. These are intentionally invalid Zig programs, consumed only by tools/test-quic-types.py. They are excluded from native executable test roots.

## Verification

[T01/T03 implementation evidence](../../../../../verification/t01-implementation.md) records scope, commands and remaining gates. Update this source contract only after reviewing changed behavior.

### `typeCheck` — line 2

[Source declaration](../../../../../../tests/quic/negative/valid.zig#L2)

```zig
export fn typeCheck() void {
```

Independent test fixture operation; preserve explicit expected outcomes and owned resource cleanup.
