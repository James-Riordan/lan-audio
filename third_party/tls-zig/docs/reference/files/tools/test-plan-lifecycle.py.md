# `tools/test-plan-lifecycle.py`

Source: [tools/test-plan-lifecycle.py](../../../../tools/test-plan-lifecycle.py)  
Source SHA-256: `a70b4cc785552c002c2ad746e6573d3e469ccfeb99def60dee9dff68ebcc4d92`  
Snapshot bytes: 8805. Review: revision 3, 2026-09-26.

## Responsibility and limits

Exercise lifecycle/evidence validation with disposable positive and negative fixtures. Read-only on real projects. Synthetic fixtures do not prove native protocol behavior. Required assertions remain active under Python -O.

## Declaration-by-declaration contract

### `digest` — line 15

[Source declaration](../../../../tools/test-plan-lifecycle.py#L15)

```python
def digest(path):
```

Compute exact fixture hashes independently of the checker hash helper.

### `write` — line 20

[Source declaration](../../../../tools/test-plan-lifecycle.py#L20)

```python
def write(root,relative,body):
```

Create fixture files only below the temporary roots supplied by the test; no production source or receipt is authored.

### `fixture` — line 26

[Source declaration](../../../../tools/test-plan-lifecycle.py#L26)

```python
def fixture(base,checker):
```

Create two synthetic tool sources, contracts, input scopes, retained synthetic logs and a cross-project dependency. Explicitly mark all data as fixture-only; no recorded command is executed.

### `verify` — line 55

[Source declaration](../../../../tools/test-plan-lifecycle.py#L55)

```python
def verify(checker,roots,plan):
```

Apply graph validation and local/evidence checks to both fixture projects with the same root mapping, so dependency source/log drift cannot hide in an unchecked peer.

### `main` — line 61

[Source declaration](../../../../tools/test-plan-lifecycle.py#L61)

```python
def main():
```

Load sibling checker, require positive complete/reopened/in-progress/planned cases, inject each invalid receipt independently, restore bytes between cases and require rejection. TemporaryDirectory owns cleanup. Exceptions fail the tool even with Python optimization.

## Verification

Run check-plan.py with --self-test and --peer, plus test-plan-lifecycle.py, both normally and with Python -O. Retain negative-control names and exit status. See [completion protocol](../../../roadmap/completion-protocol.md). Do not refresh hashes to conceal source or evidence drift.

## T00 implementation update

The false-completion negative control explicitly removes evidence, including when the baseline first node is already complete. The lifecycle suite exercises this complete-baseline regression.
