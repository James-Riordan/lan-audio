# `src/backend.c`

Source: [src/backend.c](../../../../src/backend.c)  
Source SHA-256: `dfcc61371663a4fc54b7b6aad16518f966707cf376ab7cb4f83bf8689de622a4`  
Snapshot bytes: 10411. Review date: 2026-09-26.

## Responsibility

Small OpenSSL records adapter owning SSL_CTX, SSL, paired BIOs and immutable pending write data.

## Contract, ownership and failure behavior

Clear the OpenSSL error queue before a TLS operation and classify its result immediately. TLS 1.3 only; explicit trust, SAN checking, single owned ALPN, no early-data API. Two 32 KiB BIO buffers and one 16 KiB write block do not cap all provider allocation. Shutdown preserves unread plaintext with peek and retries blocked alerts.

## Next implementation work

Keep QUIC callbacks in a separate backend translation unit after capability probing. Add provider initialization failure injection, time_t range handling and allocation accounting. Review environment/provider loading policy before deployment. The C ABI is internal; its constructors do not replicate all public Zig Config validation.

## Verification obligations

- [tests/transport.zig](../../../../tests/transport.zig): preserve existing regression assertions and add any changed-boundary cases.
- [tests/driver.zig](../../../../tests/driver.zig): preserve existing regression assertions and add any changed-boundary cases.

## Declaration-by-declaration work map

Each entry points to the exact current source. Adjacent source documentation is retained below. Direct error names and assigned self fields are mechanically extracted navigation cues; they exclude transitive errors, pointer writes and full branch reasoning. Use the module contract above for obligations.

### `no_password` — line 32

[Source declaration](../../../../src/backend.c#L32)

```c
static int no_password(char *buf, int size, int writing, void *arg) {
```

Always return zero so encrypted PEM keys fail initialization without opening an interactive password prompt. The callback borrows its arguments and retains none.

### `select_alpn` — line 36

[Source declaration](../../../../src/backend.c#L36)

```c
static int select_alpn(SSL *s, const unsigned char **out, unsigned char *len,
                       const unsigned char *in, unsigned int n, void *arg) {
```

Select the connection-owned length-prefixed protocol from the peer list. Return a fatal negotiation result if there is no match. Keep callback context alive for the SSL lifetime.

### `info` — line 44

[Source declaration](../../../../src/backend.c#L44)

```c
static void info(const SSL *s, int where, int ret) {
```

Capture only the received TLS alert number from OpenSSL callbacks. This diagnostic does not authorize plaintext or prove orderly closure.

### `result` — line 48

[Source declaration](../../../../src/backend.c#L48)

```c
static int result(tz_engine *e, int r) {
```

Call SSL_get_error immediately for the failed TLS call. WANT_READ/WANT_WRITE are progress; ZERO_RETURN is authenticated closure. Otherwise retain verify/reason diagnostics, mark failed and distinguish certificate authentication from general TLS failure.

### `tz_new` — line 59

[Source declaration](../../../../src/backend.c#L59)

```c
tz_engine *tz_new(int server, const char *ca, const char *cert, const char *key,
                  const char *peer, int ip, int require_client, int64_t wall_time) {
```

Compatibility constructor: forward to tz_new_with_alpn with http/1.1. Do not duplicate security configuration or diverge between constructor paths.

### `tz_new_with_alpn` — line 65

[Source declaration](../../../../src/backend.c#L65)

```c
tz_engine *tz_new_with_alpn(int server, const char *ca, const char *cert, const char *key,
                  const char *peer, int ip, int require_client, int64_t wall_time,
                  const unsigned char *protocol, size_t protocol_length) {
```

Validate/copy ALPN, allocate a zeroed owner, configure TLS version/trust/credentials/identity/policy, create SSL and paired BIOs, then transfer internal BIO ownership to SSL. Any failure calls tz_free on the partially constructed owner. Zig Config performs additional validation before invoking this internal ABI.

### `tz_free` — line 124

[Source declaration](../../../../src/backend.c#L124)

```c
void tz_free(tz_engine *e) {
```

Null is harmless; release SSL (including its internal BIO), the wire-side BIO and context, then clear/free owner memory. Call exactly once for each non-null live handle; repeated use of a freed non-null C pointer is invalid.

### `tz_handshake` — line 131

[Source declaration](../../../../src/backend.c#L131)

```c
int tz_handshake(tz_engine *e) {
```

Reject failed/closing owners. A ready owner returns complete; otherwise run one SSL_do_handshake and verify the selected opaque ALPN before setting ready.

### `tz_feed` — line 144

[Source declaration](../../../../src/backend.c#L144)

```c
int tz_feed(tz_engine *e, const unsigned char *p, size_t n, size_t *used) {
```

Set used=0 before work; reject failed/EOF owners; empty input is not EOF. Write at most 16 KiB into the wire BIO and report the accepted prefix or input_full. The caller retains every suffix.

### `tz_drain` — line 154

[Source declaration](../../../../src/backend.c#L154)

```c
int tz_drain(tz_engine *e, unsigned char *p, size_t n, size_t *used) {
```

Copy at most 16 KiB of pending ciphertext out of the wire BIO. It is deliberately callable after TLS failure so a generated alert can be sent. No byte count implies no ciphertext custody transfer.

### `tz_read` — line 163

[Source declaration](../../../../src/backend.c#L163)

```c
int tz_read(tz_engine *e, unsigned char *p, size_t n, size_t *used) {
```

Require ready, not failed, no pending write and nonempty destination. Make one SSL_read_ex for at most 16 KiB; classify its result immediately. Caller uses only the returned initialized prefix.

### `tz_write` — line 171

[Source declaration](../../../../src/backend.c#L171)

```c
int tz_write(tz_engine *e, const unsigned char *p, size_t n) {
```

Require ready, not failed/closing and no pending block. Copy 1..16384 plaintext bytes into owner storage and mark pending; this is local acceptance, not encryption completion or delivery.

### `tz_flush` — line 177

[Source declaration](../../../../src/backend.c#L177)

```c
int tz_flush(tz_engine *e) {
```

Repeat SSL_write_ex using the same copied block and length. Preserve pending data across WANT_READ/WANT_WRITE. Only success cleanses the block and clears pending.

### `tz_shutdown` — line 188

[Source declaration](../../../../src/backend.c#L188)

```c
int tz_shutdown(tz_engine *e) {
```

Reject pending writes, mark closing, and retry SSL_shutdown until the close alert is actually accepted. After close_sent, SSL_peek_ex preserves final application bytes; plaintext_available requires host reads before shutdown can finish.

### `tz_eof` — line 208

[Source declaration](../../../../src/backend.c#L208)

```c
int tz_eof(tz_engine *e) {
```

Signal raw EOF once through BIO_shutdown_wr. EOF does not synthesize close_notify; the following TLS operation exposes truncation when closure was unauthenticated.

### `tz_verify_error` — line 213

[Source declaration](../../../../src/backend.c#L213)

```c
long tz_verify_error(tz_engine *e) { return e->verify_error; }
```

Return the captured certificate verification code while the owner remains alive; zero alone does not prove the handshake succeeded.

### `tz_reason` — line 214

[Source declaration](../../../../src/backend.c#L214)

```c
unsigned long tz_reason(tz_engine *e) { return e->reason; }
```

Return the captured packed OpenSSL error reason. Preserve its provider-version context when displaying diagnostics.

### `tz_alert` — line 215

[Source declaration](../../../../src/backend.c#L215)

```c
int tz_alert(tz_engine *e) { return e->alert; }
```

Return the last received alert number, or the initialized negative sentinel if none was observed.

### `tz_version` — line 234

[Source declaration](../../../../src/backend.c#L234)

```c
const char *tz_version(void) { return OpenSSL_version(OPENSSL_VERSION); }
```

Return a borrowed provider-owned NUL-terminated runtime version string. Qualification additionally verifies loaded module paths and bytes.

## Verified peer leaf export increment

The new digest query checks ready, failure, local closing, raw EOF, completed provider handshake, provider shutdown bits, SSL_VERIFY_PEER, successful verification and a present peer leaf. X509_V_OK alone is not proof. X509_digest with EVP_sha256 hashes the entire leaf DER into a temporary; only exact 32-byte success copies to the caller. The temporary is cleansed, the SSL-owned certificate is never freed or exported, and query failure does not change engine state. This adds no persistent fields or cached identity lifetime.

See the [identity guide](../../../guides/peer-identity.md) for the application boundary and current evidence.

### `tz_verified_peer_leaf_sha256` — line 216

[Source declaration](../../../../src/backend.c#L216)

```c
int tz_verified_peer_leaf_sha256(tz_engine *e, unsigned char *out, size_t capacity) {
```

The new digest query checks ready, failure, local closing, raw EOF, completed provider handshake, provider shutdown bits, SSL_VERIFY_PEER, successful verification and a present peer leaf. X509_V_OK alone is not proof. X509_digest with EVP_sha256 hashes the entire leaf DER into a temporary; only exact 32-byte success copies to the caller. The temporary is cleansed, the SSL-owned certificate is never freed or exported, and query failure does not change engine state. This adds no persistent fields or cached identity lifetime.
