# `tools/tcp_upload_interop.py`

Source: [tools/tcp_upload_interop.py](../../../../tools/tcp_upload_interop.py)  
Source SHA-256: `84b1dee1314093d7c52b84245fee8439fed6275da4a8fe2ed96106516a37e080`  
Snapshot bytes: 4817. Review date: 2026-09-26.

## Responsibility

Runner for five early-response TCP upload cases.

## Contract, ownership and failure behavior

Honor bounded timeouts, preserve peer error output and clean up owned resources. Runtime/backend versions and case outcomes must be recorded. Existing interop assertions require normal Python mode; the new check tools use unconditional failures.

## Next implementation work

Run this runner after the producer and required separate consumer are built. Missing prerequisites must fail clearly, never be counted as a pass. Extend negative cases with independent peer expectations; do not weaken assertions to accommodate a regression.

## Verification obligations

Run the owning build or maintenance entry point described in the [verification guide](../../../verification/strategy.md). A passive fixture/record is verified by hash and by its named consumers; it is not an executable test.

## Declaration-by-declaration work map

Each entry points to the exact current source. Adjacent source documentation is retained below. Direct error names and assigned self fields are mechanically extracted navigation cues; they exclude transitive errors, pointer writes and full branch reasoning. Use the module contract above for obligations.

### `case` — line 19

[Source declaration](../../../../tools/tcp_upload_interop.py#L19)

```python
def case(mode):
```

Review `case` as part of this file’s responsibility: Runner for five early-response TCP upload cases. Preserve the stated ownership/failure contract when extending this entry point.

### `serve` — line 31

[Source declaration](../../../../tools/tcp_upload_interop.py#L31)

```python
def serve():
```

Review `serve` as part of this file’s responsibility: Runner for five early-response TCP upload cases. Preserve the stated ownership/failure contract when extending this entry point.

## T00 implementation update

Entry refuses -O/PYTHONOPTIMIZE before imports with runtime or network side effects; existing assertion-based test oracles remain required.
