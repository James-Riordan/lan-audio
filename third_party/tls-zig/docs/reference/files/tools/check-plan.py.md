# `tools/check-plan.py`

Source: [tools/check-plan.py](../../../../tools/check-plan.py)  
Source SHA-256: `304aecf9670355b237408259b32058530b8fa9cf22fa414a1e7952859b01e12d`  
Snapshot bytes: 17521. Review: revision 3, 2026-09-26.

## Responsibility and limits

Validate work lifecycle and source-bound completion evidence. Read-only on real projects. Synthetic fixtures do not prove native protocol behavior. Required assertions remain active under Python -O.

## Declaration-by-declaration contract

### `relative` — line 17

[Source declaration](../../../../tools/check-plan.py#L17)

```python
def relative(value):
```

Reject ambiguous/absolute/traversing paths before any filesystem reference; keep cross-platform canonical spelling.

### `validate` — line 27

[Source declaration](../../../../tools/check-plan.py#L27)

```python
def validate(plan):
```

Validate schema-2 node identity, unique paths/tests, lifecycle/evidence relation and acyclic prerequisites. A complete node cannot depend on unfinished work. This is current-state consistency, not an append-only transition proof.

### `fingerprint` — line 78

[Source declaration](../../../../tools/check-plan.py#L78)

```python
def fingerprint(row):
```

Canonicalize all work obligation fields except status/evidence. Changes to tests, dependencies, purpose or file identity invalidate previous completion attribution.

### `checked_file` — line 84

[Source declaration](../../../../tools/check-plan.py#L84)

```python
def checked_file(root, reference):
```

Resolve under the selected project, reject malformed digest/reference, and compare exact bytes. Hashes detect drift; they do not attest trusted content or command execution.

### `evidence_check` — line 97

[Source declaration](../../../../tools/check-plan.py#L97)

```python
def evidence_check(root, row, nodes, roots, inventory):
```

Require current obligation/design, timezone-bearing attribution, gap-free declaration, recorded environment, mandatory source/build/contract inputs, exact acceptance-to-run coverage, retained passing logs and every prerequisite receipt. Review still owns complete transitive input scope and adequacy of assertions/native matrix.

### `local_check` — line 186

[Source declaration](../../../../tools/check-plan.py#L186)

```python
def local_check(root,plan,project,roots=None):
```

Keep design cards for every lifecycle state. For present source, verify inventory/hash/contract; for complete state, validate receipt against both roots. Reject missing/unindexed cards, stale obligation text and planned state concealing source.

### `self_test` — line 221

[Source declaration](../../../../tools/check-plan.py#L221)

```python
def self_test(plan):
```

Retain nine independent malformed-graph/schema controls. False completion without canonical evidence must fail. Positive lifecycle and on-disk evidence mutations live in test-plan-lifecycle.py.

### `main` — line 243

[Source declaration](../../../../tools/check-plan.py#L243)

```python
def main():
```

Resolve roots by inventory project identity; require identical shared plans and both peers once any node is complete. Validate all available local sources/receipts, return status counts, deterministic order and dependency-ready package IDs. Never mutate the roadmap.

## Verification

Run check-plan.py with --self-test and --peer, plus test-plan-lifecycle.py, both normally and with Python -O. Retain negative-control names and exit status. See [completion protocol](../../../roadmap/completion-protocol.md). Do not refresh hashes to conceal source or evidence drift.

## T00 implementation update

The false-completion negative control explicitly removes evidence, including when the baseline first node is already complete. The lifecycle suite exercises this complete-baseline regression.
