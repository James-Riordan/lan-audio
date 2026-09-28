# `tools/probe-quic-pair.py`

Source: [tools/probe-quic-pair.py](../../../../tools/probe-quic-pair.py)  
Source SHA-256: `a50f002c744bc9143376bfb974e994f1c032d0496ba45a6124ae74a286abec0a`  
Snapshot bytes: 5850. Review: revision 5, 2026-09-26.

## Responsibility and limits

Offline authenticated recordless provider diagnostic. No production API or sockets. See [experiment and reproducible evidence](../../../verification/quic-provider-pair.md). Fixed arrays and test policy are deliberately scoped; do not copy them as production capacity or security policy.

## Declaration-by-declaration contract

### `digest` — line 19

[Source declaration](../../../../tools/probe-quic-pair.py#L19)

```python
def digest(p):
```

Hash exact file bytes with SHA-256 for provenance; never rewrite an input or infer authority from a digest.

### `run` — line 23

[Source declaration](../../../../tools/probe-quic-pair.py#L23)

```python
def run(root, scratch, zig, sdk_override=None, optimize='O0'):
```

Require Windows, valid optimization, fresh empty scratch, safe unique locked paths, exact 166-file SDK set and pinned compiler. Stage and rehash DLLs; compile with warnings as errors. Execute all 17 bounded scenarios, save raw logs and bind hashes/commands/results. A malformed result or timeout fails; actual loaded-module identity and provider heap bounds remain unverified.

### `main` — line 85

[Source declaration](../../../../tools/probe-quic-pair.py#L85)

```python
def main():
```

Parse scratch/compiler/SDK/optimization settings, derive project root from this file, convert operational errors to failed JSON and exit nonzero. Never update backend locks or fixture credentials.

## Data and failure invariants

The C peer owns four 64 KiB input arrays, directional secret copies, one lease record and counters. Destination arrays never move or reclaim space during a scenario. Output acceptance cannot exceed copied bytes. Release failure leaves the outstanding lease intact; provider teardown happens while both peers and all callback targets are alive. The 10,000-turn cap and 10-second case timeout detect stalls but do not prove a real-time bound. The Python runner requires new scratch to avoid stale binary replacement and preserves case/compile logs. Errors do not rewrite SDK or lock.

## Verification and maintenance

Run all 17 cases at O0 and O2 with the pinned compiler/SDK. Refresh this card and source inventory only after reviewing changes; retain old scoped receipts. No C assert or Python assert carries a required runtime check. Public native-library tests become necessary when production implementation changes.
