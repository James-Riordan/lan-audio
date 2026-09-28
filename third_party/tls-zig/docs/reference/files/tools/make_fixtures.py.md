# `tools/make_fixtures.py`

Source: [tools/make_fixtures.py](../../../../tools/make_fixtures.py)  
Source SHA-256: `ac8d59c6da99f23f6db1484db277a101930925e731cb61fd52e5d007251ea1e3`  
Snapshot bytes: 2479. Review date: 2026-09-26.

## Responsibility

Generate disposable local-test certificates and public private-key fixtures.

## Contract, ownership and failure behavior

Uses fresh EC keys and serials; reruns are intentionally not byte-idempotent. CA private keys are not persisted. SAN, validity and EKU differences encode test expectations.

## Next implementation work

Add a fixture manifest describing roles, SANs, validity and expected failures. Run only when deliberately rotating test fixtures; update all related credentials together and retain independent negative oracles.

## Verification obligations

Run the owning build or maintenance entry point described in the [verification guide](../../../verification/strategy.md). A passive fixture/record is verified by hash and by its named consumers; it is not an executable test.

## Declaration-by-declaration work map

Each entry points to the exact current source. Adjacent source documentation is retained below. Direct error names and assigned self fields are mechanically extracted navigation cues; they exclude transitive errors, pointer writes and full branch reasoning. Use the module contract above for obligations.

### `issue` — line 18

[Source declaration](../../../../tools/make_fixtures.py#L18)

```python
def issue(name, issuer=None, ca=False, expired=False, client=False):
```

Review `issue` as part of this file’s responsibility: Generate disposable local-test certificates and public private-key fixtures. Preserve the stated ownership/failure contract when extending this entry point.
