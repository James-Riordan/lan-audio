# `tools/pin-backend.py`

Source: [tools/pin-backend.py](../../../../tools/pin-backend.py)  
Source SHA-256: `bcac3b4fa4eaf4780be32793b879eb7fc09b1535283a8c118f833d88beea2d24`  
Snapshot bytes: 2998. Review date: 2026-09-26.

## Responsibility

Explicit atomic provenance producer after a controlled backend build.

## Contract, ownership and failure behavior

Import is read-only. main is the deliberate lock-generation entry point; never invoke it to hide verification failure. It executes the candidate openssl version command and validates the exact application/library version line with an unconditional exception, then hashes SDK files and historical tools. Only after all collection succeeds does it write/fsync a unique sibling temporary file and replace backend-lock.json. Failure before replacement preserves the old lock. validate_version is tested under normal Python and -O. Source provenance, absolute tool paths and runtime version text retain their existing schema; this is not independent verification or loaded-library provenance. T00 did not run lock generation.

## Verification

See [T00 implementation status](../../../verification/t00-implementation.md). Retain command outputs and keep source inventory and acceptance evidence current.

## Declaration contracts

### `sha256` — line 9

[Source declaration](../../../../tools/pin-backend.py#L9)

```python
def sha256(path):
```

Part of the file contract above; preserve explicit failure checks, ownership and read/write boundaries.

### `validate_version` — line 16

[Source declaration](../../../../tools/pin-backend.py#L16)

```python
def validate_version(version):
```

Reject a different backend even when Python assertions are disabled.

### `main` — line 22

[Source declaration](../../../../tools/pin-backend.py#L22)

```python
def main():
```

Explicit lock generation after an authorized build; import is read-only.
