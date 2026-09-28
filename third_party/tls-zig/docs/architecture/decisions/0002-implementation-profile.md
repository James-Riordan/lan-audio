# Decision 0002: selected implementation profile

Status: selected design for future implementation, 2026-09-26. Existing exports and behavior are preserved. This decision fixes the initial scope so a future implementation does not silently grow an unqualified feature set.

## Scope and capability selection

Target QUIC v1 with TLS 1.3. Begin the recordless integration with AES-128-GCM/SHA-256, matching the current Handshake codec. Negotiate only implemented suites; reject unsupported suite, version or required capability explicitly. Keep records Engine/Driver and recordless owner as separate entry points with no implicit mode conversion. Preserve existing module names and the pinned type-only transport fixture until a reviewed consumer migration replaces its use.

The first Q1 milestone is an authenticated handshake, including required peer policy, opaque ALPN and transport-parameter acceptance, without application streams. Q2/Q3 add Application protection, recovery and streams only behind capability gates. Resumption, 0-RTT, HTTP/3, DATAGRAM extension, extra QUIC versions, FIPS claims and fully concurrent duplex TLS are separate decisions with separate threat/test work.

Host owns sockets, scheduling, monotonic clocks, entropy source, expected identity, trust material, admission policy and application authorization. Libraries own protocol state and copied in-flight data. A library call does not initiate network access or silently discover a replacement trust/provider configuration. Certificate wall time is separate from monotonic deadlines.

## Public API acceptance contract

Public configuration is validated before any peer input: version/suite, role, required identity/trust, ALPN length/content policy, transport parameters, capacities, clock representability and backend capability. Defaults must not weaken a caller's explicit authentication requirement. A server without mTLS can accept its configured peer policy but cannot report a certified client identity.

One owner serializes connection operations. Return a stable typed outcome: progress, blocked on specified input/output/capacity, application event, or terminal reason. Do not encode all outcomes as a boolean or reinterpret empty input as EOF. Byte counts are exact initialized/accepted prefixes; nonblocking output preserves pending custody. A public future handle needs explicit move/borrow rules and cannot rely on callers copying opaque live state safely.

No public implementation names are reserved by illustrative prose here; final Zig signatures are chosen in T01/Q06/Q12 with compiling consumer fixtures. The semantic operations and ownership are fixed by the contract documents. Export additions must have a real consumer example and documented failure behavior; internal helper layout can evolve without unnecessary public aliases.

## Compatibility and packaging

Keep current source paths while introducing the planned modules. Consolidate only after a real dependency/ownership reason exists. Public package allowlists must include actual source closure and user documentation, while excluding local SDK binaries, build caches and private runtime material. Test installation from the packaged artifact in a clean separate consumer directory, not only from the repository root.

The current native qualification is Windows x86_64 with the pinned Zig/OpenSSL identities. Linux/macOS support requires native build, ABI, runtime provenance, consumer and behavior checks. Portability of pure data logic is a design property; support for a target is an evidence claim.

## Revisit triggers

Add a new suite/version/extension only for a concrete consumer need with independent vectors/interop and resource analysis. Add concurrent ownership only with a synchronization/lifetime model and race tests. Change trust or revocation defaults only through explicit policy/version review. Change a dependency lock only for an intentional upgrade or demonstrated missing capability, retaining before/after regression evidence.
