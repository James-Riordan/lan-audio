# `tools/qualify-quic-backend.py`

Source: [tools/qualify-quic-backend.py](../../../../tools/qualify-quic-backend.py)  
Source SHA-256: `56f148da0377b5cb36dc207f29aa185504490b3c8fb2bafd3ab7d1ef80c09e56`  
Snapshot bytes: 5659. Review date: 2026-09-26.

## Responsibility

Offline source-bound native C adapter and ABI qualification.

## Ownership, invariants and failure behavior

Requires a new empty evidence directory, exact compiler/SDK target and owning SDK location. Validates the complete locked SDK before and after Debug/ReleaseSafe runs. Requires all 25 native scenario records plus two actual ABI tests, exit success and stable source/fixture hashes. Records commands, logs, hashes, failures and scoped observations without relying on Python assertions. Windows-only evidence; no native LP64 result is inferred. Existing evidence is never overwritten.

## Verification

Native results are scoped to Windows x86_64; see current status, canonical completion receipts and retained qualification runs. This file alone does not establish a completed platform or production QUIC stack.

### `digest` — line 23

[Source declaration](../../../../tools/qualify-quic-backend.py#L23)

```py
def digest(path):
```

Preserves the explicit input validation, serialization, custody and cleanup rules above. Native tests observe its results and failure effects.

### `qualify` — line 27

[Source declaration](../../../../tools/qualify-quic-backend.py#L27)

```py
def qualify(root, scratch, zig):
```

Preserves the explicit input validation, serialization, custody and cleanup rules above. Native tests observe its results and failure effects.

### `any` — line 29

[Source declaration](../../../../tools/qualify-quic-backend.py#L29)

```py
    if any(scratch.iterdir()):
```

Preserves the explicit input validation, serialization, custody and cleanup rules above. Native tests observe its results and failure effects.

### `ValueError` — line 30

[Source declaration](../../../../tools/qualify-quic-backend.py#L30)

```py
        raise ValueError('use a new empty work directory; preserve existing evidence')
```

Preserves the explicit input validation, serialization, custody and cleanup rules above. Native tests observe its results and failure effects.

### `RuntimeError` — line 32

[Source declaration](../../../../tools/qualify-quic-backend.py#L32)

```py
        raise RuntimeError('current native provider qualification is Windows x86_64 only')
```

Preserves the explicit input validation, serialization, custody and cleanup rules above. Native tests observe its results and failure effects.

### `RuntimeError` — line 35

[Source declaration](../../../../tools/qualify-quic-backend.py#L35)

```py
        raise RuntimeError('unqualified SDK target or owning-build root')
```

Preserves the explicit input validation, serialization, custody and cleanup rules above. Native tests observe its results and failure effects.

### `RuntimeError` — line 38

[Source declaration](../../../../tools/qualify-quic-backend.py#L38)

```py
        raise RuntimeError('unqualified compiler: ' + version)
```

Preserves the explicit input validation, serialization, custody and cleanup rules above. Native tests observe its results and failure effects.

### `any` — line 86

[Source declaration](../../../../tools/qualify-quic-backend.py#L86)

```py
    if any(digest(root/p) != sha for p, sha in inputs.items()):
```

Preserves the explicit input validation, serialization, custody and cleanup rules above. Native tests observe its results and failure effects.

### `RuntimeError` — line 87

[Source declaration](../../../../tools/qualify-quic-backend.py#L87)

```py
        raise RuntimeError('source changed during qualification; evidence cannot close a package')
```

Preserves the explicit input validation, serialization, custody and cleanup rules above. Native tests observe its results and failure effects.

### `main` — line 93

[Source declaration](../../../../tools/qualify-quic-backend.py#L93)

```py
def main():
```

Preserves the explicit input validation, serialization, custody and cleanup rules above. Native tests observe its results and failure effects.

### `SystemExit` — line 106

[Source declaration](../../../../tools/qualify-quic-backend.py#L106)

```py
    raise SystemExit(main())
```

Preserves the explicit input validation, serialization, custody and cleanup rules above. Native tests observe its results and failure effects.
