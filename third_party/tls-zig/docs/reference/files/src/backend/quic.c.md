# `src/backend/quic.c`

Source: [src/backend/quic.c](../../../../../src/backend/quic.c)  
Source SHA-256: `c975b22d3ecdc8b791e976db36f798610f5e831287903c69e69588112d9e0374`  
Snapshot bytes: 17800. Review date: 2026-09-26.

## Responsibility

OpenSSL external recordless callback adapter and authenticated TLS state.

## Ownership, invariants and failure behavior

Validates explicit role, trust/credential file pairs, DNS/IP identity, opaque ALPN, parameter capacity, callback table, version and representable wall time before provider allocation. DNS and IP parsing are allocation-free. No system trust defaults, password prompt, socket or record BIO is installed. Only QUIC TLS 1.3, AES-128-GCM/SHA-256 and X25519 are configured. Tickets and session caching are disabled; received post-handshake CRYPTO is driven through SSL_read_ex without exposing application record I/O.

OpenSSL levels 2/3 map explicitly to Handshake/Application, and directions map to local read/write. Initial CRYPTO uses level 0. Each directional secret is accepted once, suite and length checked, and its bytes copied by the callback before level advancement. send commits only the validated accepted prefix. receive allows at most one stable lease; exact release failures are terminal but retain that lease through provider destruction. Invalid/doubled releases cannot dispatch or retire another lease. Callback failure is terminal; a successful zero/partial send is backpressure. Input budget exhaustion reports local work, distinct from network input shortage. The byte budgets do not promise bounded OpenSSL allocation or call duration.

Parameters and ALPN retained by SSL are copied into adapter storage. Trust/credential/identity temporary strings are copied and used synchronously. SSL uses explicit certificate wall time, strict verification and independent expected DNS/IP identity. Client and mutual-TLS require a peer certificate and successful verification. A no-mTLS server reports configured policy, not authenticated client identity. TLS completion additionally checks exact ALPN, one accepted parameter callback and four successful directional-secret callbacks. Event installation and role-aware QUIC parameter validation belong to the Engine/transport owner.

Invalid ABI calls leave caller outputs unchanged. A first failing step writes diagnostic output and returns TERMINAL; later terminal calls leave output unchanged. Close sets terminal/reentry guard, destroys SSL while the host callback context and input bytes remain valid, then clears copied parameters/ALPN. Repeated close/destroy are idempotent. OpenSSL owns its cryptographic allocations; the allocator ledger tests leaks, not erasure of all provider-internal memory.

Provider API reference: https://docs.openssl.org/3.5/man3/SSL_set_quic_tls_cbs/ . The locked headers and actual native execution are the primary compatibility inputs. Initial native tests cover 25 scenarios and C/Zig ABI calls; these are same-provider handshakes, not independent QUIC interoperability.

## Verification

Native results are scoped to Windows x86_64; see current status, canonical completion receipts and retained qualification runs. This file alone does not establish a completed platform or production QUIC stack.

### `qualified_target` — line 29

[Source declaration](../../../../../src/backend/quic.c#L29)

```c
static int qualified_target(void) {
```

Preserves the explicit input validation, serialization, custody and cleanup rules above. Native tests observe its results and failure effects.

### `sizeof` — line 31

[Source declaration](../../../../../src/backend/quic.c#L31)

```c
    return sizeof(void *)==8 && sizeof(time_t)==8;
```

Preserves the explicit input validation, serialization, custody and cleanup rules above. Native tests observe its results and failure effects.

### `tlsq_query` — line 36

[Source declaration](../../../../../src/backend/quic.c#L36)

```c
uint32_t tlsq_query(uint32_t version, tlsq_capabilities *out) {
```

Preserves the explicit input validation, serialization, custody and cleanup rules above. Native tests observe its results and failure effects.

### `bytes_valid` — line 46

[Source declaration](../../../../../src/backend/quic.c#L46)

```c
static int bytes_valid(tlsq_bytes b) { return b.length==0 || b.data!=NULL; }
```

Preserves the explicit input validation, serialization, custody and cleanup rules above. Native tests observe its results and failure effects.

### `text_valid` — line 47

[Source declaration](../../../../../src/backend/quic.c#L47)

```c
static int text_valid(tlsq_bytes b, int required) {
```

Preserves the explicit input validation, serialization, custody and cleanup rules above. Native tests observe its results and failure effects.

### `bytes_valid` — line 48

[Source declaration](../../../../../src/backend/quic.c#L48)

```c
    return bytes_valid(b) && (!required || b.length) && b.length<SIZE_MAX &&
```

Preserves the explicit input validation, serialization, custody and cleanup rules above. Native tests observe its results and failure effects.

### `dns_valid` — line 51

[Source declaration](../../../../../src/backend/quic.c#L51)

```c
static int dns_valid(tlsq_bytes b) {
```

Preserves the explicit input validation, serialization, custody and cleanup rules above. Native tests observe its results and failure effects.

### `ipv4_valid` — line 64

[Source declaration](../../../../../src/backend/quic.c#L64)

```c
static int ipv4_valid(const unsigned char *s,size_t n) {
```

Preserves the explicit input validation, serialization, custody and cleanup rules above. Native tests observe its results and failure effects.

### `ip_valid` — line 78

[Source declaration](../../../../../src/backend/quic.c#L78)

```c
static int ip_valid(tlsq_bytes b) {
```

Preserves the explicit input validation, serialization, custody and cleanup rules above. Native tests observe its results and failure effects.

### `tlsq_validate` — line 103

[Source declaration](../../../../../src/backend/quic.c#L103)

```c
uint32_t tlsq_validate(const tlsq_config *c, const tlsq_callbacks *cb) {
```

Preserves the explicit input validation, serialization, custody and cleanup rules above. Native tests observe its results and failure effects.

### `fail_callback` — line 127

[Source declaration](../../../../../src/backend/quic.c#L127)

```c
static int fail_callback(tlsq_provider *p) { p->callback_failed=1;p->terminal=1;return 0; }
```

Preserves the explicit input validation, serialization, custody and cleanup rules above. Native tests observe its results and failure effects.

### `send_crypto` — line 128

[Source declaration](../../../../../src/backend/quic.c#L128)

```c
static int send_crypto(SSL *ssl,const unsigned char *data,size_t length,size_t *consumed,void *arg) {
```

Preserves the explicit input validation, serialization, custody and cleanup rules above. Native tests observe its results and failure effects.

### `fail_callback` — line 134

[Source declaration](../../../../../src/backend/quic.c#L134)

```c
        return fail_callback(p);
```

Preserves the explicit input validation, serialization, custody and cleanup rules above. Native tests observe its results and failure effects.

### `receive_crypto` — line 139

[Source declaration](../../../../../src/backend/quic.c#L139)

```c
static int receive_crypto(SSL *ssl,const unsigned char **data,size_t *length,void *arg) {
```

Preserves the explicit input validation, serialization, custody and cleanup rules above. Native tests observe its results and failure effects.

### `release_crypto` — line 151

[Source declaration](../../../../../src/backend/quic.c#L151)

```c
static int release_crypto(SSL *ssl,size_t length,void *arg) {
```

Preserves the explicit input validation, serialization, custody and cleanup rules above. Native tests observe its results and failure effects.

### `secret_valid` — line 159

[Source declaration](../../../../../src/backend/quic.c#L159)

```c
static int secret_valid(uint32_t level,uint32_t direction,tlsq_bytes bytes) {
```

Preserves the explicit input validation, serialization, custody and cleanup rules above. Native tests observe its results and failure effects.

### `deliver_secret` — line 163

[Source declaration](../../../../../src/backend/quic.c#L163)

```c
static int deliver_secret(tlsq_provider *p,uint32_t level,uint32_t direction,tlsq_bytes bytes) {
```

Preserves the explicit input validation, serialization, custody and cleanup rules above. Native tests observe its results and failure effects.

### `fail_callback` — line 167

[Source declaration](../../../../../src/backend/quic.c#L167)

```c
        return fail_callback(p);
```

Preserves the explicit input validation, serialization, custody and cleanup rules above. Native tests observe its results and failure effects.

### `yield_secret` — line 172

[Source declaration](../../../../../src/backend/quic.c#L172)

```c
static int yield_secret(SSL *ssl,uint32_t level,int direction,const unsigned char *secret,size_t length,void *arg) {
```

Preserves the explicit input validation, serialization, custody and cleanup rules above. Native tests observe its results and failure effects.

### `deliver_secret` — line 176

[Source declaration](../../../../../src/backend/quic.c#L176)

```c
    return deliver_secret(p,level-1,(uint32_t)direction,bytes);
```

Preserves the explicit input validation, serialization, custody and cleanup rules above. Native tests observe its results and failure effects.

### `peer_parameters` — line 178

[Source declaration](../../../../../src/backend/quic.c#L178)

```c
static int peer_parameters(SSL *ssl,const unsigned char *data,size_t length,void *arg) {
```

Preserves the explicit input validation, serialization, custody and cleanup rules above. Native tests observe its results and failure effects.

### `alert` — line 185

[Source declaration](../../../../../src/backend/quic.c#L185)

```c
static int alert(SSL *ssl,unsigned char code,void *arg) {
```

Preserves the explicit input validation, serialization, custody and cleanup rules above. Native tests observe its results and failure effects.

### `select_alpn` — line 190

[Source declaration](../../../../../src/backend/quic.c#L190)

```c
static int select_alpn(SSL *ssl,const unsigned char **out,unsigned char *length,const unsigned char *in,unsigned int n,void *arg) {
```

Preserves the explicit input validation, serialization, custody and cleanup rules above. Native tests observe its results and failure effects.

### `no_password` — line 196

[Source declaration](../../../../../src/backend/quic.c#L196)

```c
static int no_password(char *buf,int size,int writing,void *arg) {
```

Preserves the explicit input validation, serialization, custody and cleanup rules above. Native tests observe its results and failure effects.

### `text_copy` — line 207

[Source declaration](../../../../../src/backend/quic.c#L207)

```c
static char *text_copy(tlsq_bytes b) {
```

Preserves the explicit input validation, serialization, custody and cleanup rules above. Native tests observe its results and failure effects.

### `tlsq_create` — line 212

[Source declaration](../../../../../src/backend/quic.c#L212)

```c
uint32_t tlsq_create(const tlsq_config *c,const tlsq_callbacks *callbacks,tlsq_provider **out) {
```

Preserves the explicit input validation, serialization, custody and cleanup rules above. Native tests observe its results and failure effects.

### `live` — line 267

[Source declaration](../../../../../src/backend/quic.c#L267)

```c
static uint32_t live(tlsq_provider *p) {
```

Preserves the explicit input validation, serialization, custody and cleanup rules above. Native tests observe its results and failure effects.

### `authenticated` — line 273

[Source declaration](../../../../../src/backend/quic.c#L273)

```c
static int authenticated(tlsq_provider *p) {
```

Preserves the explicit input validation, serialization, custody and cleanup rules above. Native tests observe its results and failure effects.

### `tlsq_step` — line 286

[Source declaration](../../../../../src/backend/quic.c#L286)

```c
uint32_t tlsq_step(tlsq_provider *p,size_t input_budget,size_t output_budget,tlsq_result *out) {
```

Preserves the explicit input validation, serialization, custody and cleanup rules above. Native tests observe its results and failure effects.

### `tlsq_close` — line 309

[Source declaration](../../../../../src/backend/quic.c#L309)

```c
uint32_t tlsq_close(tlsq_provider *p) {
```

Preserves the explicit input validation, serialization, custody and cleanup rules above. Native tests observe its results and failure effects.

### `tlsq_destroy` — line 322

[Source declaration](../../../../../src/backend/quic.c#L322)

```c
uint32_t tlsq_destroy(tlsq_provider **owner) {
```

Preserves the explicit input validation, serialization, custody and cleanup rules above. Native tests observe its results and failure effects.

### `tlsq_test_release` — line 331

[Source declaration](../../../../../src/backend/quic.c#L331)

```c
uint32_t tlsq_test_release(tlsq_provider *p,size_t length) {
```

Preserves the explicit input validation, serialization, custody and cleanup rules above. Native tests observe its results and failure effects.

### `tlsq_test_secret` — line 338

[Source declaration](../../../../../src/backend/quic.c#L338)

```c
uint32_t tlsq_test_secret(tlsq_provider *p,uint32_t level,uint32_t direction,tlsq_bytes bytes) {
```

Preserves the explicit input validation, serialization, custody and cleanup rules above. Native tests observe its results and failure effects.
