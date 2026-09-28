# `tools/tcp_interop.py`

Source: [tools/tcp_interop.py](../../../../tools/tcp_interop.py)  
Source SHA-256: `0f1cf8172ae4c504ba4a0c14d0c360aba27f966e140c4b8abec3dfbbde76a3fc`  
Snapshot bytes: 4571. Review date: 2026-09-26.

## Responsibility

Runner for five TCP client cases.

## Contract, ownership and failure behavior

Honor bounded timeouts, preserve peer error output and clean up owned resources. Runtime/backend versions and case outcomes must be recorded. Existing interop assertions require normal Python mode; the new check tools use unconditional failures.

## Next implementation work

Run this runner after the producer and required separate consumer are built. Missing prerequisites must fail clearly, never be counted as a pass. Extend negative cases with independent peer expectations; do not weaken assertions to accommodate a regression.

## Verification obligations

Run the owning build or maintenance entry point described in the [verification guide](../../../verification/strategy.md). A passive fixture/record is verified by hash and by its named consumers; it is not an executable test.

## Declaration-by-declaration work map

Each entry points to the exact current source. Adjacent source documentation is retained below. Direct error names and assigned self fields are mechanically extracted navigation cues; they exclude transitive errors, pointer writes and full branch reasoning. Use the module contract above for obligations.

### `case` — line 18

[Source declaration](../../../../tools/tcp_interop.py#L18)

```python
def case(mode):
```

Review `case` as part of this file’s responsibility: Runner for five TCP client cases. Preserve the stated ownership/failure contract when extending this entry point.

### `serve` — line 29

[Source declaration](../../../../tools/tcp_interop.py#L29)

```python
def serve():
```

Review `serve` as part of this file’s responsibility: Runner for five TCP client cases. Preserve the stated ownership/failure contract when extending this entry point.

## T00 implementation update

Entry refuses -O/PYTHONOPTIMIZE before imports with runtime or network side effects; existing assertion-based test oracles remain required.
