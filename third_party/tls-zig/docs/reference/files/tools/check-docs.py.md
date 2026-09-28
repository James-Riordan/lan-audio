# `tools/check-docs.py`

Source: [tools/check-docs.py](../../../../tools/check-docs.py)  
Source SHA-256: `be34383f3ec878381ea6140f504b91af3213dcbb955aa35c0dffc63aa503a0be`  
Snapshot bytes: 9896. Review: 2026-09-26 revision 2.

## Responsibility and operational contract

Read-only integrity gate for source contracts, declaration locations, documentation links and registrations.

Read-only on the project. Self-tests mutate disposable copies only. Source/document hashes detect drift, not maliciously coordinated changes or correctness of prose. Safe paths are checked before source reads.

## Declaration-by-declaration obligations

### `digest` — line 21

[Source declaration](../../../../tools/check-docs.py#L21)

```python
def digest(p):
```

Read exact bytes and return SHA-256; no newline normalization or source edits.

### `safe` — line 25

[Source declaration](../../../../tools/check-docs.py#L25)

```python
def safe(root, value):
```

Require canonical relative POSIX spelling and resolved containment. Reject traversal, absolute/drive paths, backslashes and symlink escape before reading.

### `universe` — line 38

[Source declaration](../../../../tools/check-docs.py#L38)

```python
def universe(root):
```

Prune caches, SDK, generated output and documentation before walking first-party files. Ignore log files; do not follow directory symlinks. This is the declared coverage universe, not all disk bytes.

### `check` — line 49

[Source declaration](../../../../tools/check-docs.py#L49)

```python
def check(root, with_sdk=False):
```

Convert malformed/unreadable evidence into a diagnostic list; no traceback is required for expected input failure. Never repair hashes automatically.

### `check_contents` — line 57

[Source declaration](../../../../tools/check-docs.py#L57)

```python
def check_contents(root, with_sdk=False):
```

Compare complete first-party set and hashes, contract existence/hash, registered declaration locations, artifact set and local file links. Optional SDK mode checks exact set/hashes against dependency inventory and lock. Location checks cover declared snippets, not semantic completeness or arbitrary Markdown anchors.

### `self_test` — line 133

[Source declaration](../../../../tools/check-docs.py#L133)

```python
def self_test(root):
```

Use a disposable copy without SDK; inject source drift, missing coverage, broken link, stale declaration, unsafe path, malformed JSON and missing card. Require each distinct expected diagnostic; restore fixtures between cases.

### `main` — line 180

[Source declaration](../../../../tools/check-docs.py#L180)

```python
def main():
```

Resolve root from script, run checks and optional negative controls, emit JSON and nonzero for drift. Python optimization must not disable checks.

## Verification and next work

Run the documented entry point and applicable negative controls; retain command/exit/source identity. See [revision-2 status](../../../verification/current.md). Do not treat a maintenance check, model or initial callback probe as native protocol qualification.
