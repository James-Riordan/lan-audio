# `tests/fixtures/expired.pem`

Source: [tests/fixtures/expired.pem](../../../../../tests/fixtures/expired.pem)  
Source SHA-256: `f27207039e40fe80694bad38d8f9472cbf66a04625f76e29448660b81e1e2220`  
Snapshot bytes: 652. Review date: 2026-09-26.

## Responsibility

Public disposable certificate for the expired TLS test role.

## Contract, ownership and failure behavior

All fixture credentials are local-test-only. Positive and negative trust/SAN/validity/EKU cases depend on preserving the paired set and supplied verification time. Hash these bytes; do not edit PEM text by hand.

## Next implementation work

Regenerate deliberately with tools/make_fixtures.py, review certificate fields independently and rerun every identity/interoperability case. The generation process creates new random keys and is not byte-idempotent.

## Verification obligations

Run the owning build or maintenance entry point described in the [verification guide](../../../../verification/strategy.md). A passive fixture/record is verified by hash and by its named consumers; it is not an executable test.

## Fixture oracle

Expired server credential checked at the supplied fixed verification time.
