# `src/backend.h`

Source: [src/backend.h](../../../../src/backend.h)  
Source SHA-256: `0e0f3dbfae408fe39bd33592e943e5cdce43abbaadbe906216b4d1bf93569cbd`  
Snapshot bytes: 2754. Review date: 2026-09-26.

## Responsibility

Internal C ABI declarations and status-number vocabulary.

## Contract, ownership and failure behavior

Keep C and Zig signatures aligned for size_t, integer widths, nullable pointers and ownership. tz_free accepts null; operations require a live handle. Constructor failure is null. The status comment includes -5 although the current implementation does not emit it.

## Next implementation work

Remove or formalize the unused -5 status in a focused ABI cleanup. Add compile/link ABI checks for every supported target; validate argument order and length parameters for custom ALPN. Do not promote this test-facing ABI to a compatibility promise accidentally.

## Verification obligations

- [tests/transport.zig](../../../../tests/transport.zig): preserve existing regression assertions and add any changed-boundary cases.

## Declaration-by-declaration work map

Each entry points to the exact current source. Adjacent source documentation is retained below. Direct error names and assigned self fields are mechanically extracted navigation cues; they exclude transitive errors, pointer writes and full branch reasoning. Use the module contract above for obligations.

### `tz_new` — line 23

[Source declaration](../../../../src/backend.h#L23)

```c
tz_engine *tz_new(int server, const char *ca, const char *cert, const char *key,
                  const char *peer, int ip, int require_client, int64_t wall_time);
```

Status: 0 complete, 1 needs input, 2 needs output, 3 clean close, 4 input full, 5 shutdown needs the host to read pending plaintext; -1 TLS failure, -2 authentication, -3 ALPN, -4 misuse, -5 configuration.

### `tz_new_with_alpn` — line 27

[Source declaration](../../../../src/backend.h#L27)

```c
tz_engine *tz_new_with_alpn(int server, const char *ca, const char *cert, const char *key,
                  const char *peer, int ip, int require_client, int64_t wall_time,
                  const unsigned char *protocol, size_t protocol_length);
```

Copies one opaque ALPN identifier (1..255 bytes). The original constructor remains an HTTP/1.1 compatibility entry point for existing C ABI consumers.

### `tz_free` — line 30

[Source declaration](../../../../src/backend.h#L30)

```c
void tz_free(tz_engine *e);
```

Null is harmless; release SSL (including its internal BIO), the wire-side BIO and context, then clear/free owner memory. Call exactly once for each non-null live handle; repeated use of a freed non-null C pointer is invalid. The declaration must remain ABI-compatible with the C implementation and Zig extern mirror.

### `tz_handshake` — line 31

[Source declaration](../../../../src/backend.h#L31)

```c
int tz_handshake(tz_engine *e);
```

Reject failed/closing owners. A ready owner returns complete; otherwise run one SSL_do_handshake and verify the selected opaque ALPN before setting ready. The declaration must remain ABI-compatible with the C implementation and Zig extern mirror.

### `tz_feed` — line 32

[Source declaration](../../../../src/backend.h#L32)

```c
int tz_feed(tz_engine *e, const unsigned char *p, size_t n, size_t *used);
```

Set used=0 before work; reject failed/EOF owners; empty input is not EOF. Write at most 16 KiB into the wire BIO and report the accepted prefix or input_full. The caller retains every suffix. The declaration must remain ABI-compatible with the C implementation and Zig extern mirror.

### `tz_drain` — line 33

[Source declaration](../../../../src/backend.h#L33)

```c
int tz_drain(tz_engine *e, unsigned char *p, size_t n, size_t *used);
```

Copy at most 16 KiB of pending ciphertext out of the wire BIO. It is deliberately callable after TLS failure so a generated alert can be sent. No byte count implies no ciphertext custody transfer. The declaration must remain ABI-compatible with the C implementation and Zig extern mirror.

### `tz_read` — line 34

[Source declaration](../../../../src/backend.h#L34)

```c
int tz_read(tz_engine *e, unsigned char *p, size_t n, size_t *used);
```

Require ready, not failed, no pending write and nonempty destination. Make one SSL_read_ex for at most 16 KiB; classify its result immediately. Caller uses only the returned initialized prefix. The declaration must remain ABI-compatible with the C implementation and Zig extern mirror.

### `tz_write` — line 35

[Source declaration](../../../../src/backend.h#L35)

```c
int tz_write(tz_engine *e, const unsigned char *p, size_t n);
```

Require ready, not failed/closing and no pending block. Copy 1..16384 plaintext bytes into owner storage and mark pending; this is local acceptance, not encryption completion or delivery. The declaration must remain ABI-compatible with the C implementation and Zig extern mirror.

### `tz_flush` — line 36

[Source declaration](../../../../src/backend.h#L36)

```c
int tz_flush(tz_engine *e);
```

Repeat SSL_write_ex using the same copied block and length. Preserve pending data across WANT_READ/WANT_WRITE. Only success cleanses the block and clears pending. The declaration must remain ABI-compatible with the C implementation and Zig extern mirror.

### `tz_shutdown` — line 37

[Source declaration](../../../../src/backend.h#L37)

```c
int tz_shutdown(tz_engine *e);
```

Reject pending writes, mark closing, and retry SSL_shutdown until the close alert is actually accepted. After close_sent, SSL_peek_ex preserves final application bytes; plaintext_available requires host reads before shutdown can finish. The declaration must remain ABI-compatible with the C implementation and Zig extern mirror.

### `tz_eof` — line 38

[Source declaration](../../../../src/backend.h#L38)

```c
int tz_eof(tz_engine *e);
```

Signal raw EOF once through BIO_shutdown_wr. EOF does not synthesize close_notify; the following TLS operation exposes truncation when closure was unauthenticated. The declaration must remain ABI-compatible with the C implementation and Zig extern mirror.

### `tz_verify_error` — line 39

[Source declaration](../../../../src/backend.h#L39)

```c
long tz_verify_error(tz_engine *e);
```

Return the captured certificate verification code while the owner remains alive; zero alone does not prove the handshake succeeded. The declaration must remain ABI-compatible with the C implementation and Zig extern mirror.

### `tz_reason` — line 40

[Source declaration](../../../../src/backend.h#L40)

```c
unsigned long tz_reason(tz_engine *e);
```

Return the captured packed OpenSSL error reason. Preserve its provider-version context when displaying diagnostics. The declaration must remain ABI-compatible with the C implementation and Zig extern mirror.

### `tz_alert` — line 41

[Source declaration](../../../../src/backend.h#L41)

```c
int tz_alert(tz_engine *e);
```

Return the last received alert number, or the initialized negative sentinel if none was observed. The declaration must remain ABI-compatible with the C implementation and Zig extern mirror.

### `tz_version` — line 48

[Source declaration](../../../../src/backend.h#L48)

```c
const char *tz_version(void);
```

Return a borrowed provider-owned NUL-terminated runtime version string. Qualification additionally verifies loaded module paths and bytes. The declaration must remain ABI-compatible with the C implementation and Zig extern mirror.

## Verified peer leaf export increment

The additive private query takes a live serialized handle or NULL, output pointer and size_t capacity. Capacity must be at least 32; success writes exactly 32 bytes, leaving a larger suffix unchanged. Every rejection leaves output unchanged. Query-specific status 0 succeeds, -4 denotes unavailable/invalid arguments, -1 denotes digest failure; these do not use the mutating TLS status classifier. Invalid non-NULL pointers and stale handles remain outside the ABI contract.

See the [identity guide](../../../guides/peer-identity.md) for the application boundary and current evidence.

### `tz_verified_peer_leaf_sha256` — line 47

[Source declaration](../../../../src/backend.h#L47)

```h
int tz_verified_peer_leaf_sha256(tz_engine *e, unsigned char *out, size_t capacity);
```

The additive private query takes a live serialized handle or NULL, output pointer and size_t capacity. Capacity must be at least 32; success writes exactly 32 bytes, leaving a larger suffix unchanged. Every rejection leaves output unchanged. Query-specific status 0 succeeds, -4 denotes unavailable/invalid arguments, -1 denotes digest failure; these do not use the mutating TLS status classifier. Invalid non-NULL pointers and stale handles remain outside the ABI contract.
