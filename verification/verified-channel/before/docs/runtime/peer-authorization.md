# Selected-peer authorization and repeat-safe admission

`src/security/peer_policy.zig` implements product authorization, and
`src/runtime/channel_admission.zig` binds it to the existing v2 Negotiation gate.
The first caller is `tests/integration/peer_policy.zig`. The policy is portable
between desktop and mobile hosts. Actual TLS verification and durable credential
storage remain outside these types and are not implemented by their tests.

## Trust boundary

A successful TLS handshake is necessary but does not mean the certificate belongs
to the device the user selected. Authorization requires all of the following:

1. Evidence belongs to the current locally assigned connection generation.
2. Mutual certificate authentication completed on that live TLS connection.
3. The verified negotiated ALPN is exactly `jcr-audio/2`.
4. The SHA-256 fingerprint of the verified leaf certificate's DER equals the
   explicitly selected peer fingerprint.
5. The copied allowlist contains that fingerprint and permits the complementary
   application role: a local sender requires an authorized receiver, and vice versa.

The host supplies Evidence. Its generation is local metadata, not a number read
from the peer, and its fingerprint must come from the verified live connection,
not a certificate file, discovery advertisement, display name or wire claim.
The inspected TLS records Engine still lacks the required public peer export;
its owner's reviewed export/regression receipt is a real integration prerequisite.
The synthetic evidence used by tests is not a production authentication shortcut.

## Policy representation and lifetime

Policy.init copies at most 32 rules into fixed storage. Each rule contains a
32-byte fingerprint and explicit allowed roles. Revision zero, duplicate peers,
empty role sets and oversized lists reject before a policy is returned. An empty
allowlist is valid and denies everyone. No default peer, test key, wildcard or
trust-on-first-use authorization is created.

Fingerprints accept exactly 64 hexadecimal characters or 32 colon-separated hex
bytes. Upper/lowercase normalize to the same bytes; whitespace, prefixes, partial
values and mixed separators reject. Display uses canonical lowercase hex. A
certificate renewal/reissue changes its DER fingerprint and therefore requires
explicit reapproval; a persistent public-key binding is not silently substituted.

Policy snapshots are immutable during use. The enclosing owner publishes a new
nonwrapping revision for approval/revocation changes and closes old session
admission before replacement. Channel.apply checks the supplied current policy
revision against the bound permit. Supplying an old cached revision after a global
revocation would violate the host contract; this type cannot observe a hidden
external settings change by itself.

## Idempotence without replay

Channel.init requires a nonzero generation, local role and selected fingerprint.
The lifecycle owner allocates a fresh nonwrapping generation; this constructor
does not replace the lifecycle ledger or reclaim previous owners.

| Call | Result and failure semantics |
| --- | --- |
| `authorize(policy, evidence)` | Establish one permit and authorize Negotiation. Repeating the identical live binding returns unchanged without resetting format, stream, phase or frame frontier. |
| Changed current authentication, selected identity, policy revision or role authorization | Revoke permission and retain stream/frontier diagnostics. A fresh generation is required to recover; do not retry into an existing stream. |
| Stale authorize/apply/drain/revoke | Return StaleGeneration before changing the replacement channel. |
| `apply(generation, revision, direction, message)` | Apply one logical record to the actual v2 gate. Unauthenticated input, wrong revision or invalid protocol order closes admission. Partial transport retries do not reapply records. |
| `confirmDrained(...)` | Preserve the existing receiver-only drain attestation. Repetition in draining is harmless; native/worker quiescence remains a caller obligation. |
| `revoke(generation)` | Repeating current-generation revocation converges to the same state and clears the permit. It does not close a socket, stop callbacks or free storage. |

These rules deliberately distinguish repeatable control intent from media replay.
Repeated Connect/Stop UI events should not create extra owners or replay accepted
audio. Only the authorization/revocation portion is implemented here; the future
host controller must also deduplicate actual acquisition/start/stop effects and
obey the existing lifecycle ledger's joins and outstanding-operation rules.

The safety argument is local: the only permit-creation path checks the full
conjunction, applying records first checks the permit/revision, and any current
failure destroys that permit. Stale operations return before mutation. Repeating
authorization checks equality of all permit fields before returning, so no
Negotiation reinitialization can lose a frontier. Work and storage are bounded:
at most 32 fingerprint comparisons per authorization, 32-rule copied policy,
constant channel state, no allocation, network, locks or cryptographic operations.

## Evidence and limits

Tests independently enumerate 128 combinations of generation, authentication,
ALPN, selected peer, allowlist membership and role. They exercise all 256 byte
values through fingerprint formats, rule-copy independence and bounds, actual v2
OFFER/ACCEPT/AUDIO/END/ACK transitions in both roles, repeated authorization after
media, stale platform events, changed identities/revisions and terminal rejection.
Target builds and exact source hashes are in
[receiver-platforms results](../../verification/receiver-platforms/RESULTS.md).

No cryptographic validation, persisted key security, native Apple callbacks,
mobile permission flow or physical audio is proved by these tests. Existing
sender/receiver drain helpers still require a real worker that binds the permit
to its controller generation and propagates revocation to every publication path.

`policy-object-check` emits target object code without SDK linking or execution.
The full iOS `policy-check` still requires Apple libSystem/SDK closure and must
remain a separately recorded gate; an object-only pass does not replace it.
