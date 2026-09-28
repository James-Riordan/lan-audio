# `tests/fixtures/server.pem`

Source: [tests/fixtures/server.pem](../../../../../tests/fixtures/server.pem)  
Source SHA-256: `763d572834ff319bef34a5a4410a5592ca5070093597a14da3b52623ae014cc4`  
Snapshot bytes: 648. Review date: 2026-09-26.

## Responsibility

Public disposable certificate for the server TLS test role.

## Contract, ownership and failure behavior

All fixture credentials are local-test-only. Positive and negative trust/SAN/validity/EKU cases depend on preserving the paired set and supplied verification time. Hash these bytes; do not edit PEM text by hand.

## Next implementation work

Regenerate deliberately with tools/make_fixtures.py, review certificate fields independently and rerun every identity/interoperability case. The generation process creates new random keys and is not byte-idempotent.

## Verification obligations

Run the owning build or maintenance entry point described in the [verification guide](../../../../verification/strategy.md). A passive fixture/record is verified by hash and by its named consumers; it is not an executable test.

## Fixture oracle

Server-auth credential with localhost and loopback IP SAN.
