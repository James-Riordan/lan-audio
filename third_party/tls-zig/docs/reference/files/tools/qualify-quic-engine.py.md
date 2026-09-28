# `tools/qualify-quic-engine.py`

Source: [tools/qualify-quic-engine.py](../../../../tools/qualify-quic-engine.py)  
Source SHA-256: `ae57a810fbfdac4304439f97ee2852ae25e52e3de9c3075dfa2b8cf30756a617`  
Snapshot bytes: 5277. Review date: 2026-09-26.

## Responsibility

Offline source-bound native Engine and standalone production consumer qualification.

## Ownership, invariants and failure behavior

Checks exact compiler and Windows x86_64 SDK before work; verifies the complete locked SDK before and after native Debug/ReleaseSafe Engine tests and separate consumer runs. Requires ten executed Engine tests and the consumer success marker, not merely a zero build exit. Records exact source closure including the preserved direct peer, fixtures and external build, commands, logs and hashes. Rejects changed source during the run and nonempty evidence directories; checks remain enabled under Python -O. This does not qualify macOS/Linux runtime or independent QUIC interoperability.

## Verification

Native results are scoped to Windows x86_64; see current status, canonical completion receipts and retained qualification runs. This file alone does not establish a completed platform or production QUIC stack.

### `digest` — line 17

[Source declaration](../../../../tools/qualify-quic-engine.py#L17)

```py
def digest(path):
```

Preserves the explicit input validation, serialization, custody and cleanup rules above. Native tests observe its results and failure effects.

### `qualify` — line 21

[Source declaration](../../../../tools/qualify-quic-engine.py#L21)

```py
def qualify(root, scratch, zig):
```

Preserves the explicit input validation, serialization, custody and cleanup rules above. Native tests observe its results and failure effects.

### `any` — line 23

[Source declaration](../../../../tools/qualify-quic-engine.py#L23)

```py
    if any(scratch.iterdir()):
```

Preserves the explicit input validation, serialization, custody and cleanup rules above. Native tests observe its results and failure effects.

### `ValueError` — line 24

[Source declaration](../../../../tools/qualify-quic-engine.py#L24)

```py
        raise ValueError('use a new empty work directory; preserve existing evidence')
```

Preserves the explicit input validation, serialization, custody and cleanup rules above. Native tests observe its results and failure effects.

### `RuntimeError` — line 28

[Source declaration](../../../../tools/qualify-quic-engine.py#L28)

```py
        raise RuntimeError('current native Engine qualification is Windows x86_64 only')
```

Preserves the explicit input validation, serialization, custody and cleanup rules above. Native tests observe its results and failure effects.

### `RuntimeError` — line 31

[Source declaration](../../../../tools/qualify-quic-engine.py#L31)

```py
        raise RuntimeError('unqualified compiler: '+version)
```

Preserves the explicit input validation, serialization, custody and cleanup rules above. Native tests observe its results and failure effects.

### `any` — line 79

[Source declaration](../../../../tools/qualify-quic-engine.py#L79)

```py
    if any(digest(root/p) != sha for p, sha in inputs.items()):
```

Preserves the explicit input validation, serialization, custody and cleanup rules above. Native tests observe its results and failure effects.

### `RuntimeError` — line 80

[Source declaration](../../../../tools/qualify-quic-engine.py#L80)

```py
        raise RuntimeError('source changed during qualification; evidence cannot close a package')
```

Preserves the explicit input validation, serialization, custody and cleanup rules above. Native tests observe its results and failure effects.

### `main` — line 86

[Source declaration](../../../../tools/qualify-quic-engine.py#L86)

```py
def main():
```

Preserves the explicit input validation, serialization, custody and cleanup rules above. Native tests observe its results and failure effects.

### `SystemExit` — line 99

[Source declaration](../../../../tools/qualify-quic-engine.py#L99)

```py
    raise SystemExit(main())
```

Preserves the explicit input validation, serialization, custody and cleanup rules above. Native tests observe its results and failure effects.
