# WP03 — Authorized peers and real network endpoints

Status: native socket and copied peer-policy/channel guard implemented; real TLS
identity export, credential storage and native Apple gates remain open.
Depends on WP01 for full target qualification. Acceptance: A2/A4/A7.
See the [implemented socket argument](../../runtime/network-owner.md).

| Implemented / planned file | Contract / first caller |
| --- | --- |
| `src/host/net/socket.zig` (implemented) | Platform-neutral nonblocking socket owner; owns handle until close on its serialized worker; implements TLS Transport prefix/would-block/EOF contract. |
| `src/host/net/native.c` and `native.h` (implemented; D24) | Application-owned conditional Winsock/POSIX boundary replaces the proposed Windows/Mac Zig files. It does not reuse the TLS fixture C shim. Native target execution remains separately qualified. |
| `src/security/peer_policy.zig` (implemented) | Authorized certificate/role/ALPN/stream policy; called after cryptographic validation and before media admission. |
| `../tls-zig/src/root.zig`, `src/backend.c/.h/.zig` | The inspected Engine has no public verified-peer identity export. Add a generic verified certificate identity/fingerprint export with bounded copied output and explicit lifetime; choose certificate versus key binding and renewal semantics explicitly. Keep product allow/deny policy outside TLS. |
| `src/security/identity_store.zig` | Per-device credential/authorized-peer storage, atomic updates and restrictive access; never logs secrets. |
| `tests/integration/network_host.zig` (implemented) | Fragmentation, refused connection, half-close, cancellation, IPv4/IPv6 and handle cleanup. |
| `tests/integration/peer_policy.zig` (implemented synthetic policy subset) | Trusted-but-unauthorized peer, wrong role/name/key, changed identity and damaged store. |

Implement explicit bind/connect endpoints and device-role selection. Do not use
`../tls-zig/examples/consumer/socket.c` as the product network layer: it intentionally
uses loopback, short I/O and test environment variables. Reuse its contracts and
tests, not its fixture policy. The current seam accepts numeric addresses only. Future name resolution and connect must have absolute deadlines;
readiness waits are interruptible for cancellation and never restart a total deadline.

First alpha may use separately provisioned real mutual certificates with explicit
paths/authorized fingerprints. Validate current certificate wall time and private
key match; keep monotonic operation time separate. Prefer an established credential
workflow, not a custom handshake. Product pairing must display/verify the intended
peer and persist authorization before unattended reconnection. Automatic discovery
is optional and always untrusted until policy approves the peer.

At every ownership transfer, name who closes the socket on connect, TLS init,
handshake, role negotiation and runtime failures. Other threads signal cancellation
and wake the owner; they never concurrently free the Driver or native descriptor.
Test hostile transport counts and stale callbacks. No production command accepts
the repository's public fixture keys or a frozen certificate clock by default.

Exit: Windows and Mac authenticate a deliberately provisioned authorized peer;
wrong peers fail before capture/playback admission; cancellation terminates within
the chosen bounded wait cadence; repeated failures leave no handles/threads alive.
Record IPv4 and IPv6 support separately. Do not claim multicast/discovery support
from ordinary TCP operation.

The [implemented authorization contract](../../runtime/peer-authorization.md)
uses `src/runtime/channel_admission.zig` to compose policy with the actual v2 gate.
The peer fingerprint is still synthetic in these tests; the real TLS export and
identity-store integration must not be bypassed to label this package complete.
