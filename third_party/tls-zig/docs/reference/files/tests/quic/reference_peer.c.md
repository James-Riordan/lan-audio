# `tests/quic/reference_peer.c`

Source: [tests/quic/reference_peer.c](../../../../../tests/quic/reference_peer.c)  
Source SHA-256: `e6372055edd9cf4d0c1ea801e60a6fc739d2ff4eee9f7f878b4780dc741d51e7`  
Snapshot bytes: 7177. Review date: 2026-09-26.

## Responsibility

Direct OpenSSL test peer, independent byte ledgers and QUIC packet encryption.

## Ownership, invariants and failure behavior

Includes the preserved probe-quic-pair.c diagnostic with its main renamed, and drives its direct SSL callbacks without importing the new adapter. Owns separate stable input/output queues; accepted output prefixes are poisoned only after the Zig consumer copied them. Independent EVP SHA-256 ledgers compare exact transferred bytes per level/direction. All contexts and buffers are released or cleared at teardown. Fixture credentials, wall time, ALPN and opaque parameter bytes are explicit test inputs.

Exports test-only peer creation, advancement, transfer/retirement, readiness/secret inspection, digest snapshots and packet encryption. Constructs a short-header packet with an eight-byte DCID, four-byte packet number 1, PING/padding plaintext, AES-128-GCM authentication and AES header protection. QUIC key/iv/hp derivation uses separately authored TLS-label HKDF expansion via HMAC. Keys are compared only in memory; no secret material is logged. It remains a same-OpenSSL reference, not an independent production QUIC implementation.

## Verification

Native results are scoped to Windows x86_64; see current status, canonical completion receipts and retained qualification runs. This file alone does not establish a completed platform or production QUIC stack.

### `reference_destroy` — line 11

[Source declaration](../../../../../tests/quic/reference_peer.c#L11)

```c
void reference_destroy(struct reference_peer **owner);
```

Preserves the explicit input validation, serialization, custody and cleanup rules above. Native tests observe its results and failure effects.

### `reference_level` — line 12

[Source declaration](../../../../../tests/quic/reference_peer.c#L12)

```c
static unsigned reference_level(uint32_t level) { return level==0 ? 0:level==1 ? 2:3; }
```

Preserves the explicit input validation, serialization, custody and cleanup rules above. Native tests observe its results and failure effects.

### `reference_create` — line 13

[Source declaration](../../../../../tests/quic/reference_peer.c#L13)

```c
int32_t reference_create(uint32_t role,const char *fixtures,int32_t tickets,struct reference_peer **out) {
```

Preserves the explicit input validation, serialization, custody and cleanup rules above. Native tests observe its results and failure effects.

### `reference_destroy` — line 30

[Source declaration](../../../../../tests/quic/reference_peer.c#L30)

```c
void reference_destroy(struct reference_peer **owner) {
```

Preserves the explicit input validation, serialization, custody and cleanup rules above. Native tests observe its results and failure effects.

### `reference_advance` — line 39

[Source declaration](../../../../../tests/quic/reference_peer.c#L39)

```c
int32_t reference_advance(struct reference_peer *p) {
```

Preserves the explicit input validation, serialization, custody and cleanup rules above. Native tests observe its results and failure effects.

### `reference_offer` — line 44

[Source declaration](../../../../../tests/quic/reference_peer.c#L44)

```c
int32_t reference_offer(struct reference_peer *p,uint32_t level,const unsigned char *data,size_t length,size_t *accepted) {
```

Preserves the explicit input validation, serialization, custody and cleanup rules above. Native tests observe its results and failure effects.

### `reference_peek` — line 52

[Source declaration](../../../../../tests/quic/reference_peer.c#L52)

```c
int32_t reference_peek(struct reference_peer *p,uint32_t level,const unsigned char **data,size_t *length) {
```

Preserves the explicit input validation, serialization, custody and cleanup rules above. Native tests observe its results and failure effects.

### `reference_retire` — line 57

[Source declaration](../../../../../tests/quic/reference_peer.c#L57)

```c
int32_t reference_retire(struct reference_peer *p,uint32_t level,size_t length) {
```

Preserves the explicit input validation, serialization, custody and cleanup rules above. Native tests observe its results and failure effects.

### `reference_ledger` — line 65

[Source declaration](../../../../../tests/quic/reference_peer.c#L65)

```c
int32_t reference_ledger(struct reference_peer *p,uint32_t level,uint32_t direction,unsigned char *digest,size_t *bytes) {
```

Preserves the explicit input validation, serialization, custody and cleanup rules above. Native tests observe its results and failure effects.

### `reference_ready` — line 72

[Source declaration](../../../../../tests/quic/reference_peer.c#L72)

```c
int32_t reference_ready(struct reference_peer *p) {
```

Preserves the explicit input validation, serialization, custody and cleanup rules above. Native tests observe its results and failure effects.

### `reference_secret` — line 82

[Source declaration](../../../../../tests/quic/reference_peer.c#L82)

```c
int32_t reference_secret(struct reference_peer *p,uint32_t level,uint32_t direction,unsigned char *out) {
```

Preserves the explicit input validation, serialization, custody and cleanup rules above. Native tests observe its results and failure effects.

### `reference_expand` — line 88

[Source declaration](../../../../../tests/quic/reference_peer.c#L88)

```c
static int reference_expand(const unsigned char *secret,const char *label,unsigned char *out,size_t length) {
```

Preserves the explicit input validation, serialization, custody and cleanup rules above. Native tests observe its results and failure effects.

### `reference_packet` — line 100

[Source declaration](../../../../../tests/quic/reference_peer.c#L100)

```c
int32_t reference_packet(struct reference_peer *p,unsigned char *out,size_t capacity,size_t *written) {
```

Preserves the explicit input validation, serialization, custody and cleanup rules above. Native tests observe its results and failure effects.
