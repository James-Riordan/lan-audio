# Current implementation — T00 backend integrity

T00 is implemented in the real TLS codebase: exact read-only SDK verification, unconditional download checks, verified extraction staging, atomic lock-file writing and early refusal of optimized assertion-based interop tests. SDK and source pins are preserved. QUIC runtime source remains unchanged.

Read the [T00 implementation status](t00-implementation.md) for changed behavior, fresh evidence, limitations and the exact next action. The shared plan retains all 37 packages and 89 acceptance obligations. Production recordless TLS and QUIC integration remain unfinished; T01 is next in that chain.

[Revision-5 preparation status](baseline-r5.md) and its diagnostic receipts remain historical evidence. Fresh record-based TLS regressions supplement T00; they do not establish production recordless TLS or full QUIC readiness.
