# Verified TLS records on the native socket owner

`src/host/verified_channel.zig` connects the real native Socket, reviewed TLS
Driver, copied peer policy and v2 channel guard. Its first caller is the bounded
`tests/integration/verified_channel.zig` program, driven by an independent Python
TLS/v2 peer. This is an implemented worker-side transport component. It does not
yet connect the audio callback queues, lifecycle controller or product commands.

## Identity and ownership

Connection.init requires an already connected, stable-address Socket, explicit
CA/certificate/key paths, local audio role, selected peer fingerprint, generation,
reference DNS/IP identity for a TLS client, certificate wall time and monotonic
time. TLS client/server is independent of audio sender/receiver. Both configurations
present certificates; the server always requires client verification. The single
ALPN is fixed to `jcr-audio/2`. TLS validates certificate files/key match and peer
trust/name/time. The host does not invent credentials or silently trust discovery.

The application deliberately adopted five reviewed TLS files in this increment:
the additive records identity export and its build graph. The copied owner receipt
and adoption rationale are in `verification/verified-channel/dependency-adoption.json`.
All other 183 existing custody entries, including the SDK, Driver and public
fixtures, retain their old hashes. The imported records module has no dependency
on the additional QUIC modules configured by that build graph. This is no claim
of QUIC adoption or Apple SDK support.

After the handshake, refresh calls this Driver's
Engine.verifiedPeerLeafSha256(), obtaining an owned digest of the verified leaf
DER. Only that path constructs host Evidence. The exact-ALPN Engine invariant and
fixed certificate configuration supply its authentication premise. A client's
local handshake completion proves local verification of the server; it does not
prove that the remote application approved the client. The reverse side must
independently authenticate/authorize before accepting media. No display name,
certificate file hash or peer-supplied field can substitute for this live export.

Connection owns Driver but borrows Socket and an optional atomic cancellation
flag. Move it before borrowing, then keep all owners at stable addresses. One
worker serializes every operation and policy change. Other threads may set the
flag, but cannot free TLS, move buffers or cross-close the descriptor. deinit
destroys Driver and revokes channel permission; the enclosing socket owner closes
the descriptor only after all connection calls/borrowers finish. Repeated cleanup
is harmless. Socket close failure retains the existing retired-handle semantics.

## Data and control path

| Operation | Preconditions, custody and failures |
| --- | --- |
| handshake | Current generation and live channel. Drive TLS once, then authorize the copied identity. Repetition rechecks the live binding and preserves the negotiated frontier. |
| refresh | Export from the same live Engine and evaluate current immutable policy. Export failure or changed current binding cancels TLS and clears permission. |
| send | Current permit/revision. Parse exactly one complete record; apply it to a candidate guard before taking custody. Driver.beginWrite copies bytes, then commit the candidate once. Partial I/O cannot replay protocol admission. Any subsequent failure cancels this stream. |
| receive | Current permit/revision and unexpired absolute deadline, including already-buffered plaintext. Preserve unread plaintext suffix and incremental parser storage. Apply a complete record to the gate before returning it. The returned body is borrowed until next receive/deinit; caller must consume/copy it before then. |
| confirmDrained | Current receiver permission, draining phase, no known buffered bytes after END, and actual downstream completion supplied by caller. This checks the attestation; it does not join callbacks or prove sound reached the listener. |
| finish | END/ACK completed, no retained suffix or truncated record. Drive TLS close with the original absolute deadline; additional plaintext fails. Success also releases TLS and revokes permission. Record successful media completion before cleanup changes guard phase to failed/revoked. |
| revoke | Current generation only; repeatable terminal cleanup. A stale generation never cancels its replacement. |

All methods check generation before destructive error cleanup. Current protocol,
policy, TLS, transport, deadline or cancellation failure releases TLS and clears
permission. The enclosing worker still owns device/queue cleanup and must publish
the current policy revision; passing a stale cached revision cannot implement a
global revocation. A downstream publication failure must stop the enclosing stream.
Accepted logical records cannot be retried into this same generation after error.

send validates the identical encoded bytes that Driver copies, so an application
cannot authorize one message while transmitting another. The frontier advances
once after local copied custody, not after each socket prefix. receive advances
after authenticated parsing and before delivery; caller-side queue preservation
is a separate obligation of the [live playback worker](live-workers.md). The
Connection itself cannot attest callback consumption or device fencing.

Storage is fixed: Driver's bounded plaintext/ciphertext queues, one maximum v2
parser record, 2048 bytes of unread input and the constant channel guard. TLS may
allocate outside callbacks. The operation loop uses the actual monotonic clock and
the original deadline; socket waits check cancellation at intervals of at most
10 ms, with additional scheduler/native-call delay. It runs only on a dedicated
worker, never in audio callbacks. No latency ceiling follows from finite buffers.

## Qualification and remaining work

The independent peer checks both TLS roles, both audio roles and IPv4/IPv6. Positive
cases compare all 1285 frames as exact finite binary32 words, fingerprint the
actual peer certificate independently, fragment/coalesce records, check repeated
authorization and seven stale operations, and require clean TLS close. Negative
cases exercise wrong peer/role/approval, canceled/revoked/changed policy, early
identity access, bad ALPN/name/time, missing client certificate, wait cancellation,
absolute deadline, raw EOF, malformed ordering, truncation and trailing records.
Two explicit regressions require expiry to reject buffered plaintext and known
coalesced data after END to reject before ACK; they fail on preserved earlier code.
Every expected rejection requires a named error and both cleared permission and
released TLS; a crash or harness timeout is insufficient.

Exact results, compiled mutations, historical classifier corrections and source
snapshots are in [this increment's evidence](../../verification/verified-channel/RESULTS.md).
The test process uses explicit public fixture credentials and frozen certificate
time only in its own file. The subsequent [live-worker increment](live-workers.md)
adds actual capture/playback callers and development provisioning. Production
credential storage/pairing UX, drift handling, Apple runtime qualification and
distributable applications remain unfinished. No physical audio is opened by this
verified-channel campaign; its explicit physical counterpart is separately opt-in.
