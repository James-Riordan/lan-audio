# `tools/probe-quic-tls.py`

Source: [tools/probe-quic-tls.py](../../../../tools/probe-quic-tls.py)  
Source SHA-256: `0968b64497a446be0d59f2c0df8bfe59c4bd38e6986f669cbc1cf7567d53ebcb`  
Snapshot bytes: 5063. Review: 2026-09-26 revision 2.

## Responsibility and operational contract

Compile and run the Windows native initial-callback probe against an exact verified SDK.

Test-only Windows native probe. No sockets or completed peer handshake. Fixture credentials remain test data. The runner verifies external SDK bytes and writes only new scratch artifacts. Every error must preserve logs and leave the SDK/lock unchanged.

## Declaration-by-declaration obligations

### `digest` — line 19

[Source declaration](../../../../tools/probe-quic-tls.py#L19)

```python
def digest(p):
```

Compute SHA-256 from exact source/SDK/runtime bytes for verification and evidence.

### `run` — line 23

[Source declaration](../../../../tools/probe-quic-tls.py#L23)

```python
def run(root, scratch, zig, sdk_override=None):
```

Require Windows and new empty scratch; validate lock paths and all SDK files, pinned compiler, staged DLL hashes, warnings-as-errors compile and three bounded native cases. Optional SDK location never changes required identity. Keep stdout/stderr logs; no network or SDK mutation.

### `main` — line 82

[Source declaration](../../../../tools/probe-quic-tls.py#L82)

```python
def main():
```

Accept scratch/compiler/optional SDK path, resolve own source root, report structured expected failure and meaningful exit code. A successful report remains only the stated initial-callback capability.

## Verification and next work

Run the documented entry point and applicable negative controls; retain command/exit/source identity. See [revision-2 status](../../../verification/current.md). Do not treat a maintenance check, model or initial callback probe as native protocol qualification.
