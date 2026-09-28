# `tests/fixtures/expired.key`

Source: [tests/fixtures/expired.key](../../../../../tests/fixtures/expired.key)  
Source SHA-256: `79416a6c509e4a057ede8e36441d6768b0a81b6e082d594b0a1443ad5f8a3bf6`  
Snapshot bytes: 241. Review date: 2026-09-26.

## Responsibility

Public disposable private test key for the expired TLS test role.

## Contract, ownership and failure behavior

All fixture credentials are local-test-only. Positive and negative trust/SAN/validity/EKU cases depend on preserving the paired set and supplied verification time. Hash these bytes; do not edit PEM text by hand.

## Next implementation work

Regenerate deliberately with tools/make_fixtures.py, review certificate fields independently and rerun every identity/interoperability case. The generation process creates new random keys and is not byte-idempotent.

## Verification obligations

Run the owning build or maintenance entry point described in the [verification guide](../../../../verification/strategy.md). A passive fixture/record is verified by hash and by its named consumers; it is not an executable test.

## Fixture oracle

Expired server credential checked at the supplied fixed verification time.
