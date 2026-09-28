# Experimental JCR audio/1 transport contract

Status: implemented pure framing/receiver and Windows x86_64 synthetic TLS/TCP probe.
This is a project-specific experimental protocol, not a registered interoperability
standard or a deployable product. The mathematical argument is in `MATHEMATICS.md`.

## Channel and identities

Use TLS 1.3 with exactly `jcr-audio/1` as the negotiated ALPN identifier. Authenticate
the remote certificate and intended identity under explicit product trust policy;
the probe validates the server DNS name and supplies a trusted client certificate.
The independent server requires and validates that certificate. Peer policy is not
equivalent to merely completing a server-side TLS handshake without client checks.

The adopted TLS engine disables early data/resumption and tickets. The application
must not release plaintext into the receiver until channel authentication, ALPN and
peer authorization have succeeded. The host's `authorizeChannel()` is an attestation
boundary; it cannot verify a certificate by itself. The test uses a private fixture
CA with public keys/credentials, frozen certificate-validation time on the Zig side
and localhost identity. These credentials are unsuitable for actual use.

One stream belongs to one connection. START supplies a fresh, nonzero 128-bit opaque
stream ID. Production senders must obtain it from a cryptographically secure source;
the test's deterministic ID is only a fixture. All subsequent records must carry
that ID. The receiver maps it to its own local epoch and never accepts an untrusted
wire epoch as local authority. Reconnection creates a new connection and stream.
This ID is not a key, peer identity or independent anti-replay protocol: TLS and
connection lifecycle supply channel replay protection.

## Exact record format

All header integers are unsigned big-endian. A record has a 36-byte header:

| Offset | Width | Meaning |
|---|---|---|
| 0 | 4 | ASCII `JCRA` |
| 4 | 1 | Protocol version 1 |
| 5 | 1 | Kind: START=1, AUDIO=2, END=3, ACK=4 |
| 6 | 2 | Header size, exactly 36 |
| 8 | 4 | Body length, exact length required for the kind |
| 12 | 8 | Block position; zero for START, exclusive terminal position for END/ACK |
| 20 | 16 | Nonzero stream ID |

START has a 12-byte body: sample rate `u32=48000`, channels `u16=2`, frames/block
`u16=240`, encoding `u16=1`, reserved `u16=0`, all big-endian. Encoding 1 means
signed PCM16, little-endian sample bytes, interleaved left/right channels. This
version accepts only that profile; unsupported profiles fail rather than renegotiate
implicitly. START is accepted once, before audio.

AUDIO has exactly 960 body bytes (480 samples). Positions begin at zero and must
be below `2^64-1`; holes can be rendered as silence by playout policy. The window
rejects duplicate, late or too-far positions. TCP ordinarily preserves order, but
the application enforces these bounds independently of that expectation.

END and ACK have empty bodies. END names the exclusive final position. It must
not precede the receiver's next position, be more than one window capacity ahead,
or exclude any already-buffered block. Once accepted, no further inbound record
is admitted. The receiver drains exactly to the terminal position, using silence
for holes, then completes. ACK echoes the stream ID and exclusive terminal position.
It means the receiver submitted all positions through that boundary to its current
consumer. In the probe that consumer is a local array; ACK does not prove audible
playback, durable storage, physical device completion or clean TLS closure.

There is no record extension, unknown-kind skipping, compression, arbitrary metadata
or length-driven allocation in this version. The maximum record is 996 bytes.
TCP packets and TLS records can split/combine application records arbitrarily.

## Framing, memory and failure behavior

`wire.Parser` owns a fixed 996-byte buffer. A successful `feed` consumes through at
most one complete record and reports the exact consumed prefix. The caller processes
the returned borrowed message before the next feed and retains any unconsumed suffix.
Input must not overlap parser storage. Invalid headers, sizes, profiles or identities
poison the parser permanently; a new authenticated lifecycle is needed for a new
parser. There is no scan-to-magic recovery that could reinterpret attacker bytes.

`finish()` rejects partial records. Truncated application framing is an error even
when TLS itself closes cleanly. Conversely, a complete END does not excuse raw TCP
EOF: the probe still requires authenticated TLS close_notify. Data after END is an
error, including a partial trailing header. Errors cannot retract media positions
already submitted; recovery begins a new explicitly identified stream.

The receiver and parser are single-owner components. They contain no locks, clocks,
network calls or allocation. The receiver's `ended` denotes completion of this
serialized consumer; it is not an operating-system callback join. A physical adapter
must separately drain/join device and worker ownership before reclaiming storage.

For finite `f32` encoding, round `32768*clamp(x,-1,1)` to nearest with ties away
from zero, then saturate to `[-32768,32767]`. Decode divides the signed integer by
32768. All input samples are validated before writing output; caller input/output
must not overlap on encode. Decode uses a bounded temporary and permits overlap.

## Current host and dependency boundary

The test-only Windows host reuses the TLS owner's loopback Winsock adapter. It owns
the socket, readiness polling and monotonic clock, forces short sends/receives and
uses at most 25 ms polling slices. Handshake has a three-second deadline; all media,
ACK and close operations share one four-second absolute deadline. Partial progress
never extends that deadline. These are probe limits, not product latency budgets.

The `tls.Driver` owns fixed input/output custody and serialized TLS operations;
OpenSSL's total allocation and per-call CPU are not bounded by those buffers. The
audio callback must never execute TLS or socket operations. The future product
needs a worker and bounded SPSC queues, with memory-order and reclamation evidence.

TLS 0.1.5 adds a copied, opaque 1..255-byte ALPN setting. Its HTTP default and old
`tz_new` C ABI remain compatible; `tz_new_with_alpn` exposes the generic extension.
The original HTTP, authentication, shutdown and independent-peer tests remain gates.

`transport-lock.json` pins 188 source/SDK/fixture files. The verifier checks all
166 OpenSSL SDK members and both staged runtime DLLs. Runtime PE import observations
show libssl depends on the pinned libcrypto plus Windows APIs/UCRT; libcrypto imports
Windows APIs/UCRT. Optional SDK modules remain hash-covered. Python SSL/OpenSSL is
the independent test peer and is recorded separately. The existing OpenSSL source
provenance is retained; no new source rebuild or signature verification was performed.

## Performance and remaining scope

TLS/TCP is an initial functional baseline. Loss stalls later bytes behind missing
TCP data, so this test does not establish the target playout latency under impairment.
The 20-block probe is not paced at an audio clock and measures neither drift nor
acoustic latency. Choosing a datagram transport later requires the same authenticated
stream, framing/admission and ownership obligations plus a separate transport proof.

Remaining: real pairing/credential lifecycle, a product sender, backpressure/pacing,
SPSC callback transfer, Windows loopback capture, Mac playback/TLS qualification,
clock control, impairment measurements and installation. Source/math documentation
does not manufacture those capabilities.

Sources: [OpenSSL ALPN API](https://docs.openssl.org/master/man3/SSL_CTX_set_alpn_select_cb/)
and [Python SSL](https://docs.python.org/3/library/ssl.html); the adopted local source,
lock and executed tests establish the implementation-specific evidence.
