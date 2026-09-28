# `tools/qualify-quic-core.py`

Source: [tools/qualify-quic-core.py](../../../../tools/qualify-quic-core.py)  
Source SHA-256: `841881e76e98316ec9f317a480de23f385f193b2f692b2ea6a2b2b8cf57ec2e0`  
Snapshot bytes: 3042. Review date: 2026-09-26.

## Responsibility

Retain native pure-core runs and optional cross-build evidence separately.

## Ownership, invariants and failure behavior

Requires a new empty output directory to preserve receipts. Verifies compiler version, captures both streams and bounded timeout for every command, runs Debug/ReleaseSafe tests and consumer, and optionally builds seven other OS/architecture targets. Failed/missing/timeout cells remain nonpassing; cross builds never claim runtime qualification. Output directory is caller-owned; concurrent source changes invalidate evidence. It does not qualify native TLS or install SDKs.

## Verification

[T01/T03 implementation evidence](../../../verification/t01-implementation.md) records scope, commands and remaining gates. Update this source contract only after reviewing changed behavior.

### `qualify` — line 14

[Source declaration](../../../../tools/qualify-quic-core.py#L14)

```py
def qualify(root, scratch, zig, cross=False):
```

Implements the file responsibility and validated ownership/serialization rules above; no hidden network or provider side effects.

### `main` — line 52

[Source declaration](../../../../tools/qualify-quic-core.py#L52)

```py
def main():
```

Implements the file responsibility and validated ownership/serialization rules above; no hidden network or provider side effects.
