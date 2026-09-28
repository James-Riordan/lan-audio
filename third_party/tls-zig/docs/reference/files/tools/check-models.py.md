# `tools/check-models.py`

Source: [tools/check-models.py](../../../../tools/check-models.py)  
Source SHA-256: `ed5e57b103ca09e7fb519d46553f7db6b132245802196364672f5925e225acda`  
Snapshot bytes: 3870. Review date: 2026-09-26.

## Responsibility

Runner for finite abstract safety models with injected-fault counterexamples.

## Contract, ownership and failure behavior

Honor bounded timeouts, preserve peer error output and clean up owned resources. Runtime/backend versions and case outcomes must be recorded. Existing interop assertions require normal Python mode; the new check tools use unconditional failures.

## Next implementation work

Run this runner after the producer and required separate consumer are built. Missing prerequisites must fail clearly, never be counted as a pass. Extend negative cases with independent peer expectations; do not weaken assertions to accommodate a regression.

## Verification obligations

Run the owning build or maintenance entry point described in the [verification guide](../../../verification/strategy.md). A passive fixture/record is verified by hash and by its named consumers; it is not an executable test.

## Declaration-by-declaration work map

Each entry points to the exact current source. Adjacent source documentation is retained below. Direct error names and assigned self fields are mechanically extracted navigation cues; they exclude transitive errors, pointer writes and full branch reasoning. Use the module contract above for obligations.

### `explore` — line 6

[Source declaration](../../../../tools/check-models.py#L6)

```python
def explore(initial, successors, invariant):
```

Review `explore` as part of this file’s responsibility: Runner for finite abstract safety models with injected-fault counterexamples. Preserve the stated ownership/failure contract when extending this entry point.

### `ack_model` — line 22

[Source declaration](../../../../tools/check-models.py#L22)

```python
def ack_model(broken=False):
```

Review `ack_model` as part of this file’s responsibility: Runner for finite abstract safety models with injected-fault counterexamples. Preserve the stated ownership/failure contract when extending this entry point.

### `transitions` — line 24

[Source declaration](../../../../tools/check-models.py#L24)

```python
def transitions(s):
```

generated, committed, prepared ticket, greatest actually covered generation

### `custody_model` — line 38

[Source declaration](../../../../tools/check-models.py#L38)

```python
def custody_model(broken=False):
```

Review `custody_model` as part of this file’s responsibility: Runner for finite abstract safety models with injected-fault counterexamples. Preserve the stated ownership/failure contract when extending this entry point.

### `transitions` — line 41

[Source declaration](../../../../tools/check-models.py#L41)

```python
def transitions(s):
```

packet states: 0 unsent, 1 in flight, 2 lost, 3 acknowledged. Two bytes carried by original packet and one retransmission.

### `shutdown_model` — line 60

[Source declaration](../../../../tools/check-models.py#L60)

```python
def shutdown_model(broken=False):
```

Review `shutdown_model` as part of this file’s responsibility: Runner for finite abstract safety models with injected-fault counterexamples. Preserve the stated ownership/failure contract when extending this entry point.

### `transitions` — line 62

[Source declaration](../../../../tools/check-models.py#L62)

```python
def transitions(s):
```

remaining authenticated application bytes, notify, eof, closed, failed.

### `main` — line 79

[Source declaration](../../../../tools/check-models.py#L79)

```python
def main():
```

Review `main` as part of this file’s responsibility: Runner for finite abstract safety models with injected-fault counterexamples. Preserve the stated ownership/failure contract when extending this entry point.
