# Existing file catalog

All baseline first-party source, tests, examples, scripts, fixtures and metadata have a contract below. New maintenance tools and AGENTS.md are included. The source hash binds each contract to this snapshot; declaration excerpts and direct error/write lists are a syntactic navigation aid, not a complete control-flow proof.

| File | Responsibility | Contract |
| --- | --- | --- |
| `AGENTS.md` | Maintainer entry point for this project and its implementation handoff. | [Read](files/AGENTS.md.md) |
| `CHECKPOINT.md` | Historical provenance, checkpoint or handoff record. | [Read](files/CHECKPOINT.md.md) |
| `HANDOFF-shutdown.md` | Historical provenance, checkpoint or handoff record. | [Read](files/HANDOFF-shutdown.md.md) |
| `HANDOFF-tcp-consumer.md` | Historical provenance, checkpoint or handoff record. | [Read](files/HANDOFF-tcp-consumer.md.md) |
| `HOST-DRIVER.md` | Existing user-facing documentation: HOST-DRIVER.md. | [Read](files/HOST-DRIVER.md.md) |
| `README.md` | Existing user-facing documentation: README.md. | [Read](files/README.md.md) |
| `SOURCE-ORIGIN.json` | Historical provenance, checkpoint or handoff record. | [Read](files/SOURCE-ORIGIN.json.md) |
| `backend-lock.json` | Exact historical SDK/build-tool provenance lock. | [Read](files/backend-lock.json.md) |
| `build.zig` | Build graph and public module/runtime export definition. | [Read](files/build.zig.md) |
| `build.zig.zon` | Package identity, pinned minimum compiler and distributed source allowlist. | [Read](files/build.zig.zon.md) |
| `evidence/build-recovery.md` | Historical provenance, checkpoint or handoff record. | [Read](files/evidence/build-recovery.md.md) |
| `evidence/source-provenance.json` | Historical provenance, checkpoint or handoff record. | [Read](files/evidence/source-provenance.json.md) |
| `examples/consumer/build.zig` | Standalone consumer build that imports the public TLS package. | [Read](files/examples/consumer/build.zig.md) |
| `examples/consumer/build.zig.zon` | Standalone consumer package metadata. | [Read](files/examples/consumer/build.zig.zon.md) |
| `examples/consumer/main.zig` | External package consumer exercising client/server TLS and early-response upload probing. | [Read](files/examples/consumer/main.zig.md) |
| `examples/consumer/socket.c` | Windows-only nonblocking loopback transport demonstration. | [Read](files/examples/consumer/socket.c.md) |
| `examples/roundtrip.zig` | Public consumer demonstration of authenticated in-memory TLS records roundtrip. | [Read](files/examples/roundtrip.zig.md) |
| `src/backend.c` | Small OpenSSL records adapter owning SSL_CTX, SSL, paired BIOs and immutable pending write data. | [Read](files/src/backend.c.md) |
| `src/backend.h` | Internal C ABI declarations and status-number vocabulary. | [Read](files/src/backend.h.md) |
| `src/backend.zig` | Manual Zig extern mirror of the internal C ABI. | [Read](files/src/backend.zig.md) |
| `src/driver.zig` | Serialized nonblocking transport driver with bounded ciphertext queues and early-response probe. | [Read](files/src/driver.zig.md) |
| `src/root.zig` | Public TLS records Engine, configuration validation and C-status translation. | [Read](files/src/root.zig.md) |
| `tests/driver.zig` | Executable regression suite for driver. | [Read](files/tests/driver.zig.md) |
| `tests/fixtures/ca.pem` | Public disposable certificate for the ca TLS test role. | [Read](files/tests/fixtures/ca.pem.md) |
| `tests/fixtures/client.key` | Public disposable private test key for the client TLS test role. | [Read](files/tests/fixtures/client.key.md) |
| `tests/fixtures/client.pem` | Public disposable certificate for the client TLS test role. | [Read](files/tests/fixtures/client.pem.md) |
| `tests/fixtures/expired.key` | Public disposable private test key for the expired TLS test role. | [Read](files/tests/fixtures/expired.key.md) |
| `tests/fixtures/expired.pem` | Public disposable certificate for the expired TLS test role. | [Read](files/tests/fixtures/expired.pem.md) |
| `tests/fixtures/other-ca.pem` | Public disposable certificate for the other-ca TLS test role. | [Read](files/tests/fixtures/other-ca.pem.md) |
| `tests/fixtures/server.key` | Public disposable private test key for the server TLS test role. | [Read](files/tests/fixtures/server.key.md) |
| `tests/fixtures/server.pem` | Public disposable certificate for the server TLS test role. | [Read](files/tests/fixtures/server.pem.md) |
| `tests/fixtures/wrong-purpose.key` | Public disposable private test key for the wrong-purpose TLS test role. | [Read](files/tests/fixtures/wrong-purpose.key.md) |
| `tests/fixtures/wrong-purpose.pem` | Public disposable certificate for the wrong-purpose TLS test role. | [Read](files/tests/fixtures/wrong-purpose.pem.md) |
| `tests/transport.zig` | Executable regression suite for transport. | [Read](files/tests/transport.zig.md) |
| `tools/build-openssl.sh` | Windows/MSYS/MinGW private SDK build recipe. | [Read](files/tools/build-openssl.sh.md) |
| `tools/check-docs.py` | Runner for documentation and source inventory integrity with negative controls. | [Read](files/tools/check-docs.py.md) |
| `tools/check-models.py` | Runner for finite abstract safety models with injected-fault counterexamples. | [Read](files/tools/check-models.py.md) |
| `tools/fetch-openssl.py` | Fetch and extract one pinned upstream OpenSSL archive. | [Read](files/tools/fetch-openssl.py.md) |
| `tools/interop.py` | Runner for 17 in-memory backend/Python TLS interoperability cases. | [Read](files/tools/interop.py.md) |
| `tools/make_fixtures.py` | Generate disposable local-test certificates and public private-key fixtures. | [Read](files/tools/make_fixtures.py.md) |
| `tools/pin-backend.py` | Record local SDK and build-tool hashes after a controlled backend build. | [Read](files/tools/pin-backend.py.md) |
| `tools/qualify.ps1` | Windows qualification entry point for compiler, SDK hashes, tests, interop and example. | [Read](files/tools/qualify.ps1.md) |
| `tools/tcp_interop.py` | Runner for five TCP client cases. | [Read](files/tools/tcp_interop.py.md) |
| `tools/tcp_server_interop.py` | Runner for four TCP server cases. | [Read](files/tools/tcp_server_interop.py.md) |
| `tools/tcp_upload_interop.py` | Runner for five early-response TCP upload cases. | [Read](files/tools/tcp_upload_interop.py.md) |
| `tools/test-openssl.sh` | Selected upstream certificate and TLS recipe runner with native Perl recovery. | [Read](files/tools/test-openssl.sh.md) |

## Revision 2 maintenance and probe contracts

- [tools/check-docs.py](files/tools/check-docs.py.md): Read-only integrity gate for source contracts, declaration locations, documentation links and registrations.
- [tools/check-plan.py](files/tools/check-plan.py.md): Validate shared exact planned-file DAG, test obligations and card coverage without claiming implementation.
- [tools/check-event-model.py](files/tools/check-event-model.py.md): Exhaustively explore finite proposed event custody and require three defect counterexamples.
- [tools/probe-quic-tls.py](files/tools/probe-quic-tls.py.md): Compile and run the Windows native initial-callback probe against an exact verified SDK.
- [tools/probe-quic-tls.c](files/tools/probe-quic-tls.c.md): Test-only native exercise of external QUIC TLS ClientHello output and failure behavior.

## Revision 3 lifecycle tooling

- [check-plan.py](files/tools/check-plan.py.md): schema-2 lifecycle, receipt and readiness validation.
- [test-plan-lifecycle.py](files/tools/test-plan-lifecycle.py.md): reproducible synthetic completion and rejection fixtures.

## Revision 5 native diagnostic

- [probe-quic-pair.c](files/tools/probe-quic-pair.c.md): callback custody, authentication and fault-injection experiment.
- [probe-quic-pair.py](files/tools/probe-quic-pair.py.md): pinned-SDK verification, compilation, bounded execution and provenance.
| `tools/verify-backend.py` | Read-only exact SDK verification independent of lock generation. | [Read](files/tools/verify-backend.py.md) |
| `tools/test-backend.py` | Offline adversarial SDK, acquisition, pin-version and interop-guard acceptance tests. | [Read](files/tools/test-backend.py.md) |
| `examples/quic-contract/build.zig` | Separate package consumer of the pure recordless contract and event queue. | [Read](files/examples/quic-contract/build.zig.md) |
| `examples/quic-contract/build.zig.zon` | Separate package consumer of the pure recordless contract and event queue. | [Read](files/examples/quic-contract/build.zig.zon.md) |
| `examples/quic-contract/main.zig` | Separate package consumer of the pure recordless contract and event queue. | [Read](files/examples/quic-contract/main.zig.md) |
| `examples/quic-contract/provider.zig` | Separate package consumer of the pure recordless contract and event queue. | [Read](files/examples/quic-contract/provider.zig.md) |
| `src/quic.zig` | Pure recordless configuration and event-custody module exports. | [Read](files/src/quic.zig.md) |
| `src/quic/contract.zig` | Typed recordless protocol contract and allocation-free configuration admission. | [Read](files/src/quic/contract.zig.md) |
| `src/quic/events.zig` | Bounded queue retaining bytes, secrets, controls and acknowledged consumer custody. | [Read](files/src/quic/events.zig.md) |
| `tests/quic/contract.zig` | Independent admission, identity, normalization and canonical hash tests. | [Read](files/tests/quic/contract.zig.md) |
| `tests/quic/events.zig` | Adversarial queue traces, allocator cleanup and model refinement tests. | [Read](files/tests/quic/events.zig.md) |
| `tests/quic/negative/direction-as-level.zig` | Compiler misuse control for distinct recordless semantic types. | [Read](files/tests/quic/negative/direction-as-level.zig.md) |
| `tests/quic/negative/generation-as-sequence.zig` | Compiler misuse control for distinct recordless semantic types. | [Read](files/tests/quic/negative/generation-as-sequence.zig.md) |
| `tests/quic/negative/raw-byte-count.zig` | Compiler misuse control for distinct recordless semantic types. | [Read](files/tests/quic/negative/raw-byte-count.zig.md) |
| `tests/quic/negative/valid.zig` | Compiler misuse control for distinct recordless semantic types. | [Read](files/tests/quic/negative/valid.zig.md) |
| `tests/quic/negative/wall-as-monotonic.zig` | Compiler misuse control for distinct recordless semantic types. | [Read](files/tests/quic/negative/wall-as-monotonic.zig.md) |
| `tools/qualify-quic-core.py` | Retain native pure-core runs and optional cross-build evidence separately. | [Read](files/tools/qualify-quic-core.py.md) |
| `tools/test-quic-types.py` | Run positive and negative compiler type controls with explicit diagnostics. | [Read](files/tools/test-quic-types.py.md) |
| `src/backend/quic.h` | Private fixed-width recordless C ABI and live-handle lifetime. | [Read](files/src/backend/quic.h.md) |
| `src/backend/quic.c` | OpenSSL external recordless callback adapter and authenticated TLS state. | [Read](files/src/backend/quic.c.md) |
| `tests/quic/backend.c` | Independent native host, wire ledger, callback faults and OpenSSL allocation instrumentation. | [Read](files/tests/quic/backend.c.md) |
| `tests/quic/backend_abi.c` | Independent C layout probes and C-to-Zig callback invocation. | [Read](files/tests/quic/backend_abi.c.md) |
| `tests/quic/backend_abi.zig` | Independent Zig extern ABI declarations and native symbol tests. | [Read](files/tests/quic/backend_abi.zig.md) |
| `src/backend/quic.zig` | Independent Zig declarations for the actual private native ABI. | [Read](files/src/backend/quic.zig.md) |
| `src/quic_engine.zig` | Public native recordless Engine module exports. | [Read](files/src/quic_engine.zig.md) |
| `src/quic/engine.zig` | Stable native owner, bounded input custody, event acknowledgement and authenticated readiness. | [Read](files/src/quic/engine.zig.md) |
| `tests/quic_contract.zig` | Actual Engine conformance with separate host ledgers and direct OpenSSL reference peer. | [Read](files/tests/quic_contract.zig.md) |
| `tests/quic/reference_peer.c` | Direct OpenSSL test peer, independent byte ledgers and QUIC packet encryption. | [Read](files/tests/quic/reference_peer.c.md) |
| `tools/qualify-quic-backend.py` | Offline source-bound native C adapter and ABI qualification. | [Read](files/tools/qualify-quic-backend.py.md) |
| `tools/qualify-quic-engine.py` | Offline source-bound native Engine and standalone production consumer qualification. | [Read](files/tools/qualify-quic-engine.py.md) |
| `examples/quic-engine/build.zig` | Separate production native Engine import and runtime staging. | [Read](files/examples/quic-engine/build.zig.md) |
| `examples/quic-engine/build.zig.zon` | Standalone native recordless consumer manifest. | [Read](files/examples/quic-engine/build.zig.zon.md) |
| `examples/quic-engine/main.zig` | Production-import recordless handshake and acknowledged custody demonstration. | [Read](files/examples/quic-engine/main.zig.md) |
