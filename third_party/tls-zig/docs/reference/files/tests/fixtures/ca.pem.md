# `tests/fixtures/ca.pem`

Source: [tests/fixtures/ca.pem](../../../../../tests/fixtures/ca.pem)  
Source SHA-256: `5ae21a1137c70d57dde3e2e6f9344f7a3e92d60c8574cb8d4c7ed9117c86024b`  
Snapshot bytes: 583. Review date: 2026-09-26.

## Responsibility

Public disposable certificate for the ca TLS test role.

## Contract, ownership and failure behavior

All fixture credentials are local-test-only. Positive and negative trust/SAN/validity/EKU cases depend on preserving the paired set and supplied verification time. Hash these bytes; do not edit PEM text by hand.

## Next implementation work

Regenerate deliberately with tools/make_fixtures.py, review certificate fields independently and rerun every identity/interoperability case. The generation process creates new random keys and is not byte-idempotent.

## Verification obligations

Run the owning build or maintenance entry point described in the [verification guide](../../../../verification/strategy.md). A passive fixture/record is verified by hash and by its named consumers; it is not an executable test.

## Fixture oracle

Trusted local test root.
