# `tests/quic/negative/raw-byte-count.zig`

Source: [tests/quic/negative/raw-byte-count.zig](../../../../../../tests/quic/negative/raw-byte-count.zig)  
Source SHA-256: `bea0f5c4ea60a6f41d6bc716930439e8a09a628f7dd69bf190f8adafe8306f54`  
Snapshot bytes: 158. Review date: 2026-09-26.

## Responsibility

Compiler misuse control for distinct recordless semantic types.

## Ownership, invariants and failure behavior

valid.zig must compile; other fixtures must fail with expected-type/found diagnostics for the intended unit/domain mismatch. These are intentionally invalid Zig programs, consumed only by tools/test-quic-types.py. They are excluded from native executable test roots.

## Verification

[T01/T03 implementation evidence](../../../../../verification/t01-implementation.md) records scope, commands and remaining gates. Update this source contract only after reviewing changed behavior.

### `typeCheck` — line 2

[Source declaration](../../../../../../tests/quic/negative/raw-byte-count.zig#L2)

```zig
export fn typeCheck() void {
```

Independent test fixture operation; preserve explicit expected outcomes and owned resource cleanup.
