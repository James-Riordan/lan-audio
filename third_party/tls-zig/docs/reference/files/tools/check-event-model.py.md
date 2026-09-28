# `tools/check-event-model.py`

Source: [tools/check-event-model.py](../../../../tools/check-event-model.py)  
Source SHA-256: `5dfd556d01f501d39d5de8a7335df674d84851fcb27605c7f8c174276de6dd38`  
Snapshot bytes: 4525. Review: 2026-09-26 revision 2.

## Responsibility and operational contract

Exhaustively explore finite proposed event custody and require three defect counterexamples.

No I/O except JSON output. Finite model state is independent of actual C/Zig queues; see the formal event model for abstraction limits and refinement work. All safety checks remain active under Python -O.

## Declaration-by-declaration obligations

### `State` — line 14

[Source declaration](../../../../tools/check-event-model.py#L14)

```python
class State:
```

Immutable/hashable state supports visited-set equality. copied/retired are ghost history sets, not payload storage. Fixed finite emission count keeps exploration bounded.

### `successors` — line 24

[Source declaration](../../../../tools/check-event-model.py#L24)

```python
def successors(s,capacity,fault):
```

Generate serialized guarded transitions plus rejection stutters for every modeled token. Fault parameter deliberately weakens exactly one rule; never enable these transitions in a real provider.

### `invariant` — line 52

[Source declaration](../../../../tools/check-event-model.py#L52)

```python
def invariant(s):
```

Check custody partition, unique queue membership, copy-before-retirement and borrowed-head/terminal conditions independently of the queue update code.

### `transition_invariant` — line 63

[Source declaration](../../../../tools/check-event-model.py#L63)

```python
def transition_invariant(before,action,after):
```

Check acknowledgement issuer/sequence on every mutating acknowledgement, independently from acceptance predicate in successors.

### `explore` — line 71

[Source declaration](../../../../tools/check-event-model.py#L71)

```python
def explore(capacity,fault=None):
```

Breadth-first search each unique state; count inspected transitions and return first shortest violating trace. Exhaustion means only the finite declared state space passed.

### `main` — line 86

[Source declaration](../../../../tools/check-event-model.py#L86)

```python
def main():
```

Run normal capacities 1/2 and three fault variants. Overall success requires normal passes AND every injected defect detected; print precise scope and results.

## Verification and next work

Run the documented entry point and applicable negative controls; retain command/exit/source identity. See [revision-2 status](../../../verification/current.md). Do not treat a maintenance check, model or initial callback probe as native protocol qualification.
