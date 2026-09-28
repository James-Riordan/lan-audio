# Dependency closure and architecture decisions

Scope means the audio project's actual transitive dependencies, plus an explicit
record of candidates needed for the eventual product. It does not silently make
every project in `C:/Projects` a runtime dependency or authorize following historical
instructions found inside another repository.

## Actual admitted graph

```text
lan-audio pure kernel ──build──> Zig std/compiler
lan-audio dependency-test ──package──> third_party/miniaudio-zig
lan-audio audio_host ──package──> third_party/miniaudio-zig
lan-audio transport-probe ──module──> audio_host (explicit null playback)
lan-audio transport-probe ──opt-in package──> third_party/tls-zig 0.1.5
tls-zig ──native──> private OpenSSL 3.5.8 SDK/DLLs ──runtime──> Windows APIs/UCRT
miniaudio-zig ──source──> miniaudio 0.11.25 (pinned, vendored)
miniaudio-zig ──link/load──> target libc/compiler runtime + OS audio backends
verification ──tool──> Python stdlib/ssl (independent OpenSSL); Java 17 + TLC 1.7.4
```

The [wrapper dependency record](../third_party/miniaudio-zig/docs/DEPENDENCIES.md) expands
every admitted source/toolchain/platform layer. The window/session kernel does not
import miniaudio; the independent consumer proves package linking separately.
The build now uses reviewed copies in `third_party/`, with all copied bytes in
`third_party/lock.json`. A lone checkout has its dependency closure. The launcher
fetches pinned compilers and prepares native builds; native Mac execution and
signed release distribution remain unqualified.

## Observed candidates, with explicit admission decisions

| Candidate / local evidence | Observed capability | Audio decision and unmet obligations |
|---|---|---|
| `C:/Projects/quic-zig/README.md`, `build.zig.zon` | Offline QUIC v1 Initial/Handshake codec, bounded CRYPTO and recovery; declares no full connection engine | Not linked. A production media transport also needs integrated TLS, application data, datagrams or a justified stream profile, congestion/pacing and host/network qualification |
| `C:/Projects/tls-zig/README.md`, `build.zig`, `build.zig.zon` | TLS 1.3 over a host-owned reliable stream; private OpenSSL 3.5.8 backend; Windows-specific imported DLL archives/staging | Admitted for opt-in Windows synthetic PCM qualification. Configurable ALPN added as version 0.1.5 with HTTP compatibility. Mac backend, product trust/pairing and deployment still unqualified |
| `C:/Projects/paseto-zig/README.md`, `build.zig.zon` | Bounded v4.local token codec, no external runtime packages declared | Not linked. Tokens alone do not supply streaming transport, handshake, peer identity policy or media replay protection |
| `C:/Projects/zson/build.zig.zon`; JCR ownership record | Existing ZSON language/schema owner | Not linked while there is no runtime configuration parser. Later adopt a real supported profile and audit actual evaluation dependencies |
| Opus / `opus-zig` | No local package found in the inspected project inventory | Not required by the initial PCM design. Add only with measured bandwidth/quality need, pinned upstream, encode/decode bounds, legal custody and impairment tests |
| mDNS / `mdns-zig` | No local package found in the inspected inventory | Optional discovery later; manual endpoint selection can precede it. Discovery never authenticates peers |
| Zap, MetaOS, Mediaz, Hydra | Separate network-policy, host-integration, catalog and orchestration owners | Optional integrations, not initial mandatory runtime dependencies |

The earlier TLS ALPN change was the only modification to an existing dependency
in version 0.2; version 0.3 leaves both dependencies unchanged. SDK/source pins were
preserved. The TLS transport, host-driver and
independent-peer regressions were executed. `transport-lock.json` records 188 files,
including all 166 SDK members, five implementation files, build/contract/provenance
files, ten public credential fixtures and the TLS owner's test-only Winsock adapter.
The checker verifies source custody before use and both staged runtime DLLs before
the loopback test. Windows DLL imports are recorded separately; the non-OS runtime
edge is libssl → the same pinned libcrypto. Windows API/UCRT components remain OS
contracts, not vendored or independently certified code.

Python's SSL/OpenSSL is an independent test peer, not part of the Zig product's
runtime. Its exact version is recorded in the interop result. No upstream whole-source
security certification or fresh OpenSSL rebuild is claimed. The current SDK keeps
its existing source/archive/build provenance. Cross-platform adoption remains gated.

## Decisions and rejected shortcuts

**D1 — Transparent upstream naming.** `miniaudio-zig` is a Zig Lib. It is not the
ZApp and not a newly declared primitive ZLib. The spelling follows upstream
`miniaudio`. The reference product retains a provisional descriptive directory
name until a product identity is selected deliberately.

**D2 — First profile uses PCM.** This removes codec complexity from initial timing
and device qualification. The bandwidth is calculated in `MATHEMATICS.md`; adoption
of Opus is conditional on measured need, not assumed because audio crosses a network.

**D3 — TLS/TCP is the first functional transport baseline.** The Windows probe uses
mutual certificate validation and `jcr-audio/1`, fixed framing, bounded buffers and
an absolute transfer deadline. TCP's head-of-line delay can violate low-latency
targets under loss; this is not the final performance decision. Callback queues
exist; production pacing and measured impairments remain necessary. QUIC Initial protection
does not authenticate a peer; PASETO tokens do not replace channel authentication.
No custom cryptographic protocol is introduced.

**D4 — Format boundaries remain distinct.** `build.zig.zon` is Zig package metadata.
It is not ZSON. No fake `.zson` manifest or schema is added to satisfy naming.
Runtime configuration and generated Sysl realizations require actual owner contracts.

**D5 — Preserve upstream and established owners.** Wrap/document upstream at the
boundary; do not restyle 4 MB of third-party code or rewrite unrelated libraries.
Miniaudio's ABI is pinned; source and compile definitions travel together.

**D6 — No unsupported platform promises.** macOS playback and macOS system capture
are separate capabilities. Upstream's low-level loopback profile is WASAPI-specific.
Windows-to-Mac is the first proposed journey; reverse-direction system capture is
an additional host design, not a consequence of the name cross-platform.

## Provenance

Local context read on 2026-09-25: supplied
`C:/Inbox/Downloads/Personal/JCR_Ecosystem_Engineering_Directive.md`;
`C:/Projects/jcr-architecture/docs/ONTOLOGY-AND-OWNERSHIP.md`;
`C:/Projects/jcr-architecture/baseline/0.1/01-ECOSYSTEM-CONSTITUTION.md`;
the candidate files above and the previously inspected Obsidian vault.

Third-party sources:
[miniaudio release 0.11.25](https://github.com/mackron/miniaudio/releases/tag/0.11.25),
[pinned source](https://github.com/mackron/miniaudio/tree/9634bedb5b5a2ca38c1ee7108a9358a4e233f14d),
[official TLC 1.7.4](https://github.com/tlaplus/tlaplus/releases/tag/v1.7.4).
The generic ALPN extension follows
[OpenSSL's ALPN API contract](https://docs.openssl.org/master/man3/SSL_CTX_set_alpn_select_cb/).
The independent peer follows [Python's SSL certificate-validation contract](https://docs.python.org/3/library/ssl.html).
Downloads were commit/release-addressed over HTTPS. Local hashes are recorded;
no signature verification or whole-upstream security audit is claimed.

## Records identity adoption (2026-09-26)

The application deliberately updates five TLS custody entries for the reviewed
leaf-DER identity export and build graph; 183 other entries retain their previous
hashes. Review authority and copied owner receipt are recorded in
`verification/verified-channel/dependency-adoption.json`. Only the records `tls`
module is imported; no QUIC module becomes an application dependency. The Windows
SDK/Driver/fixtures are unchanged. Apple TLS build/runtime qualification stays open.
