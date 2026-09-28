# `tests/quic/negative/generation-as-sequence.zig`

Source: [tests/quic/negative/generation-as-sequence.zig](../../../../../../tests/quic/negative/generation-as-sequence.zig)  
Source SHA-256: `298b368d0707b3d95b47fe1368c97d8a97f480851109456de51487d078a002b7`  
Snapshot bytes: 183. Review date: 2026-09-26.

## Responsibility

Compiler misuse control for distinct recordless semantic types.

## Ownership, invariants and failure behavior

valid.zig must compile; other fixtures must fail with expected-type/found diagnostics for the intended unit/domain mismatch. These are intentionally invalid Zig programs, consumed only by tools/test-quic-types.py. They are excluded from native executable test roots.

## Verification

[T01/T03 implementation evidence](../../../../../verification/t01-implementation.md) records scope, commands and remaining gates. Update this source contract only after reviewing changed behavior.

### `typeCheck` — line 2

[Source declaration](../../../../../../tests/quic/negative/generation-as-sequence.zig#L2)

```zig
export fn typeCheck() void {
```

Independent test fixture operation; preserve explicit expected outcomes and owned resource cleanup.
