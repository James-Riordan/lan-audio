> Current engineering handoff (2026-09-26): [documentation index](docs/README.md), [current source and verification](docs/verification/current.md), [file contracts](docs/reference/catalog.md), and [implementation roadmap](docs/roadmap/README.md). Earlier test counts below describe their original snapshots.

# tls-zig revision 2 — private OpenSSL 3.5.8 backend

Package 0.1.5 adds `Config.alpn`: one opaque 1..255-byte protocol identifier,
copied during initialization. The default remains `http/1.1`; applications such
as LAN audio explicitly use their own identifier. Missing/mismatched negotiation
fails before plaintext admission. A mismatch may report `AlpnMismatch` after
handshake completion or `TlsFailure` when the peer's fatal alert ends negotiation.
The old `tz_new` C ABI retains HTTP/1.1 behavior; new callers use
`tz_new_with_alpn`. Generic transport owns negotiation mechanics; products own
their identifiers and the meaning of the protocol. This does not add peer policy
or make the current OpenSSL build portable to new targets.

TLS 1.3 client/server records for a host-owned reliable byte stream. The Zig module
`tls` delegates cryptography, handshake processing and certificate validation to
OpenSSL through a small C shim. This is an isolated ZCE candidate, not an installed
Zap dependency or a production qualification.

## Run

Compiler: `0.17.0-dev.1859+dcceb318e`, Windows x86_64. The default backend is the
private `deps/openssl-install` built from the official OpenSSL **3.5.8** release.
Its source archive SHA-256 is
`a8f84a39918ec6415ce765d9b429d313ba97b8143169c172e734b9514464f5b2`.
OpenSSL's official page listed this as the current 3.5 LTS patch on September 13,
2026, with branch support through April 8, 2030. Provenance is recorded in
`evidence/source-provenance.json`; downloaded metadata and build logs remain in the
candidate's evidence directory. No PGP signature verification is claimed.

The dependency build uses the existing read-only MSYS2 Bash/Perl environment and
Strawberry MinGW GCC 13.2.0 / native GNU make 4.4.1. The initial attempt used a
privately extracted, checksum-pinned MSYS2 make package; the final reproduction
script uses native make to reduce MSYS process overhead. Both tools are recorded
where used. The fetcher needs Python 3.12+ (tested on 3.14.3). No global installation
or package-manager update is performed.
The upstream test harness uses native Strawberry Perl for Windows path semantics;
the test script normalizes generated harness paths without changing OpenSSL source
or compiled libraries. `evidence/build-recovery.md` records the recovered build and
harness failures.

From this candidate directory:

```powershell
python tools/fetch-openssl.py
& 'C:/Applications/Development/msys64/usr/bin/bash.exe' --noprofile --norc tools/build-openssl.sh
& 'C:/Applications/Development/msys64/usr/bin/bash.exe' --noprofile --norc tools/test-openssl.sh
python tools/pin-backend.py
./tools/qualify.ps1
```

If using the delivered SDK archive, extract it into the same parent directory as
the source archive; both share the `tls-zig-r2` top-level directory. Then run
`./tools/qualify.ps1` directly. The runner verifies every SDK file against the
delivered backend lock before testing. Rebuilding from source uses the full
sequence above and produces a new lock for that build.

The committed synthetic certificates and keys are public test fixtures, valid
2025–2030 except the intentionally expired fixture. Tests freeze verification time
in 2026. `python tools/make_fixtures.py` regenerates them with cryptography 48.0.0;
normal testing needs no cryptography package. Interoperability tests use Python's
standard `ssl` and `ctypes`. Qualification checks the exact backend version and
loaded Windows DLL paths; it cannot silently use the baseline 3.3.0 installation.
The build links the exact `.dll.a` import archives and stages each executable or
interop DLL beside copies of the pinned OpenSSL DLLs. This is necessary on the
qualification host because Windows otherwise finds a system-directory OpenSSL
3.4.1 before PATH. Interoperability checks verify the staged paths and bytes.
Consumers of the `tls` module must also deploy the pinned DLLs beside their own
executable. The PowerShell runner sets and restores process-local DLL search/cache
settings and verifies all 166 installed SDK file hashes before testing.
It accepts an optional `-BuildRunner` path to a cached runner from the exact pinned
Zig compiler, avoiding the compiler's initial runner bootstrap. Underneath it runs
`zig build test`, `host-test`, `interop` and `example`, sequentially with `-j1`.
The tests need no ports, network access, background services, or live credentials;
fetching the pinned dependencies requires HTTPS access. Upstream tests are limited
to certificate verification and six selected TLS BIO-pair configurations.

Consumers use `dependency.module("tls")`, then `@import("tls")`. See
`examples/roundtrip.zig` for the public API. The example exchanges actual encrypted
records between two engines and returns an HTTP response; it is not an HTTP parser
or a listening web server.

### Separate TCP consumer

`examples/consumer` is a separate Zig build using `b.dependency("tls_zig", ...)`
and `dependency.module("tls")`. The dependency also exports
`dependency.namedLazyPath("runtime")` for installing the matching OpenSSL DLLs.
The Windows-only example owns nonblocking Winsock outside the library and uses
`tls.Driver` to preserve partial socket writes and unconsumed TLS input. It sends
a request, closes its TLS write direction, reads the final
response using `plaintext_available`, and requires authenticated close_notify.

From this candidate directory, with the pinned Zig compiler available:

```powershell
Push-Location examples/consumer
zig build -j1
Pop-Location
python tools/tcp_interop.py
python tools/tcp_server_interop.py
python tools/tcp_upload_interop.py
```

The harness opens an ephemeral IPv4 loopback listener, uses Python's independent
TLS server, and checks clean closure, TCP EOF without close_notify, and a wrong
hostname, stalled-peer deadline, and cancellation from a separate thread. All five
cases passed. Installed DLL bytes match the pinned SDK. Polling uses at most 25 ms
slices bounded by the current absolute deadline. The example uses public fixtures,
a fixed verification time and a bounded response; it is not a general HTTP client
or Zap deployment. See [HOST-DRIVER.md](HOST-DRIVER.md) for the reusable driver's
callback contract, ownership, deadlines, cancellation and serialized-operation limit.

The same consumer executable also has a one-connection server mode. Its harness
starts a nonblocking listener on a system-assigned loopback port and uses Python
as the independent client. Four cases passed: a mutual-TLS HTTP exchange, missing
and untrusted client-certificate rejection, and raw EOF rejection. The server uses
the same public driver; all socket ownership stays in the consumer example.

## Verified current source results

- 16 Zig tests passed against OpenSSL 3.5.8, including runtime version, identity,
  certificate failures, tampering, truncation, backpressure, deadlines and mTLS.
- 17 interoperability cases passed against Python SSL / OpenSSL 3.0.18, with both
  TLS roles, authenticated HTTP records, ALPN/version rejection and mTLS failures.
- Shutdown preserves final peer data in both roles, including multiple records and
  partial reads, and still rejects missing/truncated close_notify. Blocked outgoing
  close alerts are retried before waiting for peer closure.
- The public HTTP roundtrip example passed, and Zig formatting checks passed.
- Selected upstream certificate verification and TLS recipes passed: 212 top-level
  tests covering certificate verification and six TLS configurations. The harness
  applies its normal configuration/platform skips; this is not the entire upstream suite.

## Host contract

`Engine.init(Config)` synchronously loads PEM credentials and explicit trust anchors.
Strings are borrowed for initialization only. Encrypted private keys are rejected
without a password prompt. The engine owns its context and credentials. Use one
engine per connection, never copy an initialized handle, serialize all calls, and
call `deinit` exactly once; repeated cancellation/deinitialization is harmless.

1. Supply independently configured DNS/IP identity, CA file, wall-clock Unix seconds,
   initial monotonic milliseconds and an absolute handshake timeout. ASCII DNS names
   use SAN validation; partial wildcards and CN fallback are disabled. IDNA conversion
   belongs to the host. Servers either require a trusted client certificate or
   explicitly use the default no-client-certificate policy. mTLS establishes certificate
   trust/EKU, not application authorization or a route-specific client identity.
2. Call `tick(now_ms)` before every scheduling round. A backward clock is rejected;
   the deadline never extends with progress. Call `handshake`, feed ordered encrypted
   bytes with `feedRecords`, and drain all pending output with `drainRecords` before
   waiting for input, even when an operation returns `need_input`.
3. Preserve every unconsumed input suffix. Feed/drain transfer at most 16 KiB per call.
   A full input BIO returns zero consumption/`input_full`: drive the current TLS
   operation to consume input and drain any output before retrying. Empty input is
   a no-op; `transportEof` explicitly marks raw EOF. The host owns bounded queues,
   socket readiness, partial writes, and fairness between connections.
4. `authenticated` means the handshake and this endpoint's required peer checks and
   ALPN passed. On servers without mTLS it does **not** mean the client has a certified
   identity. Only then may the host call `readPlaintext` or `queuePlaintext`.
5. `queuePlaintext` copies one nonempty block up to 16 KiB. Call `flushPlaintext` until
   `complete`, servicing input/output as requested. Do not queue another block or
   read plaintext during a pending write. Copied retry data stays immutable inside
   the backend. Acceptance is local custody, never proof of peer delivery. No retry
   of application requests, replay, reconnection, or plaintext fallback occurs.
6. On raw EOF, continue the current handshake/read operation to expose truncation.
   Only `closed` authenticates peer `close_notify`. For local close, call `shutdown`,
   drain records and drive the peer response until `closed`. If `shutdown` returns
   `plaintext_available`, call `readPlaintext` to consume the pending peer data,
   then retry shutdown. Repeated shutdown calls preserve that data; waiting for
   more transport input alone cannot make progress while plaintext is pending.
   No new plaintext may be queued after starting local close. The host enforces a
   separate shutdown deadline and can call `cancel` at any time. Errors are terminal
   except `InvalidState`; after a TLS failure, output may still be drained to send
   the generated alert. Do not attempt protocol shutdown after a fatal error.

Errors distinguish configuration/backend initialization, invalid state, cancellation,
deadline, certificate authentication, ALPN mismatch, and TLS failure. Diagnostics retain
OpenSSL's verification code, packed reason and received TLS alert number. A missing
required client certificate is an authentication error even when verification code
is zero. Backend creation currently reports one aggregate initialization error.

## Supported profile and limits

- TLS 1.3 only; one configured ALPN identifier (`http/1.1` by default); server/client certificate authentication;
  optional required mTLS; default OpenSSL security level 2 and TLS 1.3 ciphers.
- Explicit trust, SAN DNS/IP, validity at supplied time, strict X.509 path checking,
  EKU/key use and depth 8. No OS trust discovery or verification-off client option.
- Two fixed 32 KiB transport BIO buffers, one 16 KiB pending plaintext write, maximum
  64 KiB peer certificate-list setting. These do **not** bound all OpenSSL allocations
  or CPU work. One public progress call makes at most one SSL operation, which can
  internally process multiple protocol messages. Host admission limits remain required.
- No session cache, ticket issuance, early data API, PSK API, QUIC handshake mode,
  traffic-secret export, injected entropy provider, revocation/OCSP/CRL policy,
  credential handle generations, or asynchronous peer policy callbacks. RNG and
  residual provider initialization use OpenSSL and the OS. Post-handshake client
  authentication is not enabled. No claim of complete RFC 9846 provider qualification.

Revision 2 replaces the baseline's old OpenSSL 3.3.0 dependency with a private,
supported patch release. This is a bounded qualification of this adapter and build,
not full OpenSSL certification, a FIPS claim or production readiness. Deployment
still requires broader provider qualification and real Zap integration. The prior
candidate and outputs remain preserved in their separate directories.

## Design evidence and primary references

The legacy directory `C:/OldWorkspaces/Zigadel/code/Zig Libs/tls-zig` was empty.
The read-only transport-contract prototype of 2026-09-09 proposes a substantially
larger event/QUIC/host-provider API; this candidate does not claim to implement it.
The named Zap source declares HTTPS and certificate/key configuration in its example,
but provides no working TLS adapter. That supports this narrow records boundary.
QUIC, PASETO, ACME and route policy remain separate components.

- [TLS 1.3, RFC 9846](https://www.rfc-editor.org/info/rfc9846/)
- [OpenSSL BIO pairs and output flushing](https://docs.openssl.org/3.3/man3/BIO_s_bio/)
- [Expected hostname validation](https://docs.openssl.org/3.3/man3/SSL_set1_host/)
- [Retry and error ordering](https://docs.openssl.org/3.3/man3/SSL_get_error/)
- [Immutable write retries](https://docs.openssl.org/3.3/man3/SSL_write/)
- [Authenticated shutdown](https://docs.openssl.org/3.3/man3/SSL_shutdown/)
- [Release support policy](https://openssl-library.org/policies/releasestrat/)
- [OpenSSL 3.5 advisories](https://openssl-library.org/news/vulnerabilities-3.5/)

The source archive excludes OpenSSL binaries. The separate private SDK archive
contains the built runtime, libraries, headers, configuration and OpenSSL license.
