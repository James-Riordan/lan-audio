# `tests/fixtures/wrong-purpose.key`

Source: [tests/fixtures/wrong-purpose.key](../../../../../tests/fixtures/wrong-purpose.key)  
Source SHA-256: `8554260b7cf446acb9855c309c6ccd526d03720ad4014b79f5fb46fc8c43a575`  
Snapshot bytes: 241. Review date: 2026-09-26.

## Responsibility

Public disposable private test key for the wrong-purpose TLS test role.

## Contract, ownership and failure behavior

All fixture credentials are local-test-only. Positive and negative trust/SAN/validity/EKU cases depend on preserving the paired set and supplied verification time. Hash these bytes; do not edit PEM text by hand.

## Next implementation work

Regenerate deliberately with tools/make_fixtures.py, review certificate fields independently and rerun every identity/interoperability case. The generation process creates new random keys and is not byte-idempotent.

## Verification obligations

Run the owning build or maintenance entry point described in the [verification guide](../../../../verification/strategy.md). A passive fixture/record is verified by hash and by its named consumers; it is not an executable test.

## Fixture oracle

Client-auth EKU credential deliberately used to test server-purpose rejection.
