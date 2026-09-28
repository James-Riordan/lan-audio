# `tools/build-openssl.sh`

Source: [tools/build-openssl.sh](../../../../tools/build-openssl.sh)  
Source SHA-256: `935c6f9e7e03265544d099c1182eb4b8af6bc785f93a001734485c39a5435c4f`  
Snapshot bytes: 1080. Review date: 2026-09-26.

## Responsibility

Windows/MSYS/MinGW private SDK build recipe.

## Contract, ownership and failure behavior

Uses existing absolute host tools, one worker, shared libraries, no-quic and no-docs. An existing Makefile avoids reconfiguration. Outputs live under deps.

## Next implementation work

T1 must probe external QUIC TLS symbols in the actual locked build; upstream API availability is not local capability evidence. T2 replaces hard-coded paths with validated inputs and fails if a stale configuration differs from the requested build.

## Verification obligations

Run the owning build or maintenance entry point described in the [verification guide](../../../verification/strategy.md). A passive fixture/record is verified by hash and by its named consumers; it is not an executable test.

## Revision-2 callback capability evidence

The locked no-quic Windows SDK executes the initial external QUIC TLS callback probe successfully. This removes a speculative rebuild prerequisite for that exercised capability only. Nonempty receive-release, secret direction, peer parameters and an authenticated handshake still require native qualification; preserve the exact backend lock until a concrete requirement justifies an upgrade. See docs/verification/quic-provider-probe.md.
