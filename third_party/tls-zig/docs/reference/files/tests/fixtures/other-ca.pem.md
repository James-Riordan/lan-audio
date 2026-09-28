# `tests/fixtures/other-ca.pem`

Source: [tests/fixtures/other-ca.pem](../../../../../tests/fixtures/other-ca.pem)  
Source SHA-256: `c15ad0dafef51faf044dcfeec829d87c4039a9d4cc30c0720a7acb984c7fa7a2`  
Snapshot bytes: 599. Review date: 2026-09-26.

## Responsibility

Public disposable certificate for the other-ca TLS test role.

## Contract, ownership and failure behavior

All fixture credentials are local-test-only. Positive and negative trust/SAN/validity/EKU cases depend on preserving the paired set and supplied verification time. Hash these bytes; do not edit PEM text by hand.

## Next implementation work

Regenerate deliberately with tools/make_fixtures.py, review certificate fields independently and rerun every identity/interoperability case. The generation process creates new random keys and is not byte-idempotent.

## Verification obligations

Run the owning build or maintenance entry point described in the [verification guide](../../../../verification/strategy.md). A passive fixture/record is verified by hash and by its named consumers; it is not an executable test.

## Fixture oracle

Unrelated root used to prove trust isolation.
