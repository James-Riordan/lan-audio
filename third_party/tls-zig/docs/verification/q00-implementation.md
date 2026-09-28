# Current implementation — real QUIC/TLS adapter

Q00 is complete within scope: the QUIC public module now exports an explicitly injected recordless TLS adapter, qualified against the real tls_quic_engine in a separate dual-package consumer. **8 of 37 packages are complete; 29 remain unfinished and all 89 obligations are retained.** This is not a full production endpoint or universal OS release.

The adapter copies ordered CRYPTO prefixes into native TLS, retains outgoing bytes for retransmission, installs four directional packet keys before acknowledging secret events, validates/copied peer parameters against observed connection IDs, and exposes readiness once after acknowledged configured authentication. ClientHello can precede learning the server SCID: the packet owner binds validated Initial/Retry observations exactly once before peer parameters. Unbound parameters, rebinding and stale tokens cannot authorize traffic.

One scheduler turn performs at most one native advance and the configured byte/event work. Zero acceptance plus network wait does not spin; retained contiguous bytes can make deferred local progress without a new datagram. Invalid counts, unsupported suite, capacity exhaustion, surplus old-level data, parameter/identity/ALPN failures and overflow are explicit. Terminal cleanup clears adapter keys/buffers; native teardown retains its own copied custody until safe release. Lifetime CRYPTO history is bounded and does not reclaim acknowledged offsets; Q04 owns reclamation.

## Executed qualification

- Sixteen adapter tests and a separate production consumer pass in Debug and ReleaseSafe, including both native roles, mutual TLS, protected Handshake packet decryption, copied parameters/CIDs, deferred observation binding, every native/scripted event cancellation prefix, zero/partial/excess provider input, capacity/token/suite/clock failures, one-byte local scheduling, permitted discarded NewSessionTicket and forbidden KeyUpdate (0x10a).
- All 122 existing QUIC tests and four offline examples pass in both modes, including independently generated complete Handshake packet/key vectors. The sealed T06 prerequisite additionally binds direct-provider ledgers and independent packet encryption. This remains short of independent full QUIC endpoint interoperability.
- Four pure examples compile for seven additional targets: x86/aarch64 Windows, x86_64/aarch64 Linux musl, x86_64/aarch64 macOS, and x86_64 FreeBSD. These are compile-only results and do not qualify native TLS/runtime support.
- Models pass normally and under Python -O. The exact 166-file TLS SDK passes before and after qualification. Existing TLS source, sealed records identity APIs, root package fingerprints, frozen QUIC fixture and SDK files are unchanged during Q00.

The QUIC peer contains `docs/verification/completions/Q00.json` and `q00-bound-adapter-runs`. The earlier `q00-adapter-runs` was deliberately interrupted after native and two cross-build successes to correct construction-time-only CID binding; its logs and interruption record are retained. No completed package relies on that earlier design.

## Remaining work

Q01 adds actual TLS over protected packet loss/reordering and accepted Retry, with per-space ledgers. Application packet codec, full connection/recovery/stream/endpoint work, provider resource limits, packaging and native other-OS tests remain open. MacBook native tests stay at the final GitHub clone/test stage per the user's plan; CI/CD follows later. No GitHub publication or pin update has been performed.

The standalone native consumer is run from its package directory. The pinned Zig build's alternate `--build-file` invocation from another working directory still has relative dependency-path failures; this belongs to the open packaging/platform work. No TLS verification was bypassed to compensate for build-path or network issues.

[Final maintenance gates](q00-final-gates.json) and [change audit](q00-change-audit.json) verify the documentation, shared plan and source closure. The earlier [records identity checkpoint](peer-identity-implementation.md) remains sealed and unchanged.
