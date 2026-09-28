# `tools/verify-backend.py`

Source: [tools/verify-backend.py](../../../../tools/verify-backend.py)  
Source SHA-256: `267c0576fd83f7295eabe576a8eefe17cf3ed353d42b914373b9524e1fbec5a7`  
Snapshot bytes: 5078. Review date: 2026-09-26.

## Responsibility

Read-only exact SDK verification independent of lock generation.

## Contract, ownership and failure behavior

The CLI accepts a project root and optional lock file. It reads JSON without duplicate keys, validates canonical relative SDK paths, rejects Windows aliases/device names and symlinks/reparse points, then compares the exact regular-file set and SHA-256 digests. All checks are explicit under Python -O. Missing, changed, extra, malformed or unreadable inputs return JSON passed=false and exit 1. It never executes SDK binaries, regenerates pins or writes input files. Build-tool paths remain historical provenance. Python 3.12+; serialized maintenance requires the tree not to change during verification. This checks disk identity, not module loading or a hostile concurrent filesystem.

T00-01 is exercised by tools/test-backend.py with fixed known SHA-256 values and before/after byte snapshots.

## Verification

See [T00 implementation status](../../../verification/t00-implementation.md). Retain command outputs and keep source inventory and acceptance evidence current.

## Declaration contracts

### `relative` — line 15

[Source declaration](../../../../tools/verify-backend.py#L15)

```python
def relative(value):
```

Require portable canonical paths without Windows aliases or device names.

### `no_link` — line 30

[Source declaration](../../../../tools/verify-backend.py#L30)

```python
def no_link(path):
```

Reject symlinks and Windows reparse points before traversal or reads.

### `file_set` — line 38

[Source declaration](../../../../tools/verify-backend.py#L38)

```python
def file_set(sdk):
```

Enumerate regular files; unreadable paths and special files fail closed.

### `sha256` — line 60

[Source declaration](../../../../tools/verify-backend.py#L60)

```python
def sha256(path):
```

Stream the complete file without loading or modifying it.

### `unique_object` — line 66

[Source declaration](../../../../tools/verify-backend.py#L66)

```python
def unique_object(pairs):
```

Reject duplicate JSON keys instead of accepting the last value.

### `verify` — line 76

[Source declaration](../../../../tools/verify-backend.py#L76)

```python
def verify(root, lock_path):
```

Validate manifest, exact file set and digests; return scoped evidence.

### `main` — line 113

[Source declaration](../../../../tools/verify-backend.py#L113)

```python
def main():
```

Part of the file contract above; preserve explicit failure checks, ownership and read/write boundaries.
