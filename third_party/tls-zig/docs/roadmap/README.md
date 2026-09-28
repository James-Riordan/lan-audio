# Dependency-ordered implementation roadmap

Status: all cards below are proposed, not implemented. Existing primitives remain documented in the file catalog. Milestones group capability exit gates; exact file completion prerequisites are defined in the [shared graph](implementation-plan.json) and [work guide](work-graph.md). Tests may be authored before prerequisites close.

## Milestone dependencies

```text
T0 -> T1 -> Q1 -> Q2 -> Q3 -> Q4 -> Q5
T0 -> T2 -> T3 -> T4
Q5 release also requires T4 and native platform qualification.
```

| Milestone | Outcome | Exit gate |
| --- | --- | --- |
| T0 | Records baseline hardening | Explicit downloader integrity checks, reproducible exact SDK verification, current documentation and package consumer proof. |
| T1 | Recordless TLS seam | Capability probe and real authenticated per-level handshake; event custody and secret installation fully tested. No streams required yet. |
| T2 | Platform boundary | Explicit target matrix and native Windows/Linux/macOS build/ABI checks; unsupported systems fail clearly. |
| T3 | Operational security/resource policy | Credential/trust rotation, revocation profile and measured/enforced admission/resource limits. |
| T4 | TLS release qualification | Independent provider matrix, packaging, upgrade evidence and deployment-specific security review. |
| Q1 | Real authenticated handshake | TLS T1 consumed without record-layer tunneling; peer identity, ALPN and parameters gate completion. |
| Q2 | Application protection and multi-space recovery | 1-RTT keys, updates, coordinated timers, key discard and shared congestion accounting. |
| Q3 | Bounded connection and streams | Endpoint, transactional receive/send and flow-controlled streams pass deterministic network simulation. |
| Q4 | Path and lifecycle completion | Migration/path validation, PMTU, CID lifecycle, reset/version policies pass adversarial traces. |
| Q5 | QUIC release qualification | Independent peers, fuzzing, native platform matrix, performance envelope and external review. |

## Proposed files

| Package | Milestone | Planned path | Exact prerequisites | Card |
| --- | --- | --- | --- | --- |
| T00 | T0 | `tools/verify-backend.py` | none | [Read](files/tools/verify-backend.py.md) |
| T01 | T1 | `src/quic/contract.zig` | T00 | [Read](files/src/quic/contract.zig.md) |
| T02 | T1 | `src/quic/engine.zig` | T03, T04, T05 | [Read](files/src/quic/engine.zig.md) |
| T03 | T1 | `src/quic/events.zig` | T01 | [Read](files/src/quic/events.zig.md) |
| T04 | T1 | `src/backend/quic.c` | T05, T03 | [Read](files/src/backend/quic.c.md) |
| T05 | T1 | `src/backend/quic.h` | T01 | [Read](files/src/backend/quic.h.md) |
| T06 | T1 | `tests/quic_contract.zig` | T02 | [Read](files/tests/quic_contract.zig.md) |
| T07 | T2 | `build/backend.zig` | T00 | [Read](files/build/backend.zig.md) |
| T08 | T2 | `examples/consumer/socket_posix.c` | T07 | [Read](files/examples/consumer/socket_posix.c.md) |
| T09 | T2 | `tests/abi.zig` | T07 | [Read](files/tests/abi.zig.md) |
| T10 | T3 | `src/policy/credentials.zig` | T07, T09 | [Read](files/src/policy/credentials.zig.md) |
| T11 | T3 | `src/policy/verification.zig` | T10 | [Read](files/src/policy/verification.zig.md) |
| T12 | T3 | `tests/resource_limits.zig` | T02, T10, T11 | [Read](files/tests/resource_limits.zig.md) |
| T13 | T4 | `tests/interop/matrix.py` | T06, T08, T09, T12 | [Read](files/tests/interop/matrix.py.md) |
| T14 | T4 | `bench/engine.zig` | T12 | [Read](files/bench/engine.zig.md) |

## Extensions requiring a separate decision

Resumption and early data, additional QUIC versions, DATAGRAM/HTTP/3 integration, alternate congestion algorithms, FIPS profiles, OS trust discovery and general duplex TLS are not implied by this target. Add a consumer-driven decision and requirement/test matrix before adding those files.

## Implementation lifecycle and unresolved decisions

[Takeover entry point](takeover.md) · [Completion evidence protocol](completion-protocol.md) · [Decision register](decision-register.md). Schema 2 supports progress and completion; all current nodes remain planned.
