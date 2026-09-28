# `tests/quic/contract.zig`

Source: [tests/quic/contract.zig](../../../../../tests/quic/contract.zig)  
Source SHA-256: `1a01a7c469b4a05306ed16ac7f4e803b47dfbb2ce6135c43505a8158d3ea1f8e`  
Snapshot bytes: 6326. Review date: 2026-09-26.

## Responsibility

Independent admission, identity, normalization and canonical hash tests.

## Ownership, invariants and failure behavior

Covers capability rejection, whole-field override authority, explicit zero rejection, borrowed-plan drift, policy/ALPN/clock/capacity boundaries, accepted-prefix checking, unit types and owner uniqueness. Golden SHA-256 expected bytes come from separately written Python struct/hashlib encoding. No native provider or filesystem trust verification is inferred.

## Verification

[T01/T03 implementation evidence](../../../../verification/t01-implementation.md) records scope, commands and remaining gates. Update this source contract only after reviewing changed behavior.

### `config` — line 6

[Source declaration](../../../../../tests/quic/contract.zig#L6)

```zig
fn config() c.Config {
```

Independent test fixture operation; preserve explicit expected outcomes and owned resource cleanup.
