# First concrete work orders

## T0: make dependency acquisition checks unconditional

Affected existing files: tls-zig/tools/fetch-openssl.py, tools/pin-backend.py and the Python interop runners. Preserve the current release/hash until a separate upgrade is chosen. Replace security/integrity asserts with explicit exceptions. Tests must simulate a wrong digest, incorrect Content-Range, short body, ignored range request and interrupted extraction under normal Python and Python -O. Stage extraction into a new directory; an existing Configure file must not stand in for a complete verified extraction. The read-only verifier must reject extra as well as missing/changed SDK files. Do not auto-repin after a failure.

## T1: qualify the real recordless provider seam

Read docs/contracts/quic-tls.md and docs/contracts/recordless-events.md. The existing Windows SDK has passed the initial callback probe; preserve its exact lock. Work in dependency order T01 contract, T03 event queue/T05 ABI, T04 backend, T02 public owner and T06 conformance. Add nonempty receive-release, both directional secrets, peer-parameter decisions and complete real client/server handshakes with negative identity/ALPN cases. Do not infer those behaviors from ClientHello output or rebuild the backend without a demonstrated missing requirement.

## Q1: integrate one real handshake journey

Keep current codecs and frozen fixture tests. Add the TLS adapter and integration tests using real provider output. Preserve packet-number history across Retry, independent Initial/Handshake replay state and complete preflight before callbacks. Record no app-delivery event before TLS identity/ALPN and peer parameters pass. No stream API is needed for this milestone.

## Q2 review item: loss threshold with skipped packet numbers

Current recovery.detectLoss counts actual subsequently sent packets, and recovery_tests explicitly locks in that policy. Review it against RFC 9002 before generalizing. Create a trace with deliberately skipped numbers and compare timing/loss outcomes against the intended standard algorithm and an independent peer. Record the selected interpretation and update implementation/tests together if a deviation is found. Do not silently treat the current regression as a compliance proof.
