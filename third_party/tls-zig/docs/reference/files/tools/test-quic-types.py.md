# `tools/test-quic-types.py`

Source: [tools/test-quic-types.py](../../../../tools/test-quic-types.py)  
Source SHA-256: `ea2b297334871d86967f8d6467d22ae4e6ecb94f087996f858e7a1f2a48d046c`  
Snapshot bytes: 1901. Review date: 2026-09-26.

## Responsibility

Run positive and negative compiler type controls with explicit diagnostics.

## Ownership, invariants and failure behavior

Checks the exact compiler, compiles a positive control and four rejected type assignments, and requires semantic type diagnostics. A missing file, unrelated syntax error or unavailable compiler cannot satisfy a negative case. Captures exact commands/stdout/stderr, uses no assert, and runs under Python -O. No network or SDK access.

## Verification

[T01/T03 implementation evidence](../../../verification/t01-implementation.md) records scope, commands and remaining gates. Update this source contract only after reviewing changed behavior.

### `main` — line 12

[Source declaration](../../../../tools/test-quic-types.py#L12)

```py
def main():
```

Implements the file responsibility and validated ownership/serialization rules above; no hidden network or provider side effects.
