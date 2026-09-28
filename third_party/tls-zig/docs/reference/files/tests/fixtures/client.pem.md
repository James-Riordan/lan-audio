# `tests/fixtures/client.pem`

Source: [tests/fixtures/client.pem](../../../../../tests/fixtures/client.pem)  
Source SHA-256: `5ea5c4a7c98d80dfe16d37ff2d1f1b6fbd30ec20bdf56ea9dcd32ee4b964bcde`  
Snapshot bytes: 652. Review date: 2026-09-26.

## Responsibility

Public disposable certificate for the client TLS test role.

## Contract, ownership and failure behavior

All fixture credentials are local-test-only. Positive and negative trust/SAN/validity/EKU cases depend on preserving the paired set and supplied verification time. Hash these bytes; do not edit PEM text by hand.

## Next implementation work

Regenerate deliberately with tools/make_fixtures.py, review certificate fields independently and rerun every identity/interoperability case. The generation process creates new random keys and is not byte-idempotent.

## Verification obligations

Run the owning build or maintenance entry point described in the [verification guide](../../../../verification/strategy.md). A passive fixture/record is verified by hash and by its named consumers; it is not an executable test.

## Fixture oracle

Client-auth credential for required mutual TLS.
