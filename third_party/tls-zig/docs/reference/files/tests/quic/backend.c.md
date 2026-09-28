# `tests/quic/backend.c`

Source: [tests/quic/backend.c](../../../../../tests/quic/backend.c)  
Source SHA-256: `b92fa2cff94104386fc6a88e80b78fb2c27c197543235dbafbdeead63073513f`  
Snapshot bytes: 17834. Review date: 2026-09-26.

## Responsibility

Independent native host, wire ledger, callback faults and OpenSSL allocation instrumentation.

## Ownership, invariants and failure behavior

Runs actual quic.c symbols with separate client/server wire and custody ledgers. Covers full/one-byte-fragmented/partial-output handshakes, both-role reentry, mutual TLS, missing client cert, wrong CA/identity/ALPN, IP identity, opaque ALPN bytes, caller configuration mutation, each of six callback failures, overconsumption, oversized/null leases, parameter overflow and zero/input budgets. Directional secrets are compared across peers and never logged. Release poisoning occurs only after the provider declared that exact lease unused. A rejected release is retained through SSL_free; wrong-length and duplicate safe-hook releases cannot change custody. All handles remain allocated during invalid-call tests.

Custom OpenSSL allocation hooks observe every library allocation/reallocation/free. Invalid admission/ABI operations preserve allocation counters and output bytes. Each scenario destroys both providers, invokes OpenSSL global cleanup, and requires zero live tracked allocations/bytes. This is same-thread native Windows evidence, not provider memory-cap enforcement, race safety or exhaustive allocator failure injection. Failing test assertions produce nonzero exit and a line/expression diagnostic; stdout scenario success alone cannot establish success without the process exit.

## Verification

Native results are scoped to Windows x86_64; see current status, canonical completion receipts and retained qualification runs. This file alone does not establish a completed platform or production QUIC stack.

### `tracked_malloc` — line 18

[Source declaration](../../../../../tests/quic/backend.c#L18)

```c
static void *tracked_malloc(size_t n,const char *file,int line) {
```

Preserves the explicit input validation, serialization, custody and cleanup rules above. Native tests observe its results and failure effects.

### `tracked_free` — line 24

[Source declaration](../../../../../tests/quic/backend.c#L24)

```c
static void tracked_free(void *ptr,const char *file,int line) {
```

Preserves the explicit input validation, serialization, custody and cleanup rules above. Native tests observe its results and failure effects.

### `tracked_realloc` — line 29

[Source declaration](../../../../../tests/quic/backend.c#L29)

```c
static void *tracked_realloc(void *ptr,size_t n,const char *file,int line) {
```

Preserves the explicit input validation, serialization, custody and cleanup rules above. Native tests observe its results and failure effects.

### `bytes` — line 50

[Source declaration](../../../../../tests/quic/backend.c#L50)

```c
static tlsq_bytes bytes(const void *p,size_t n) { tlsq_bytes b={(const unsigned char *)p,n};return b; }
```

Preserves the explicit input validation, serialization, custody and cleanup rules above. Native tests observe its results and failure effects.

### `text` — line 51

[Source declaration](../../../../../tests/quic/backend.c#L51)

```c
static tlsq_bytes text(const char *s) { return bytes(s,strlen(s)); }
```

Preserves the explicit input validation, serialization, custody and cleanup rules above. Native tests observe its results and failure effects.

### `reenter` — line 52

[Source declaration](../../../../../tests/quic/backend.c#L52)

```c
static int reenter(struct peer *p) {
```

Preserves the explicit input validation, serialization, custody and cleanup rules above. Native tests observe its results and failure effects.

### `reject` — line 62

[Source declaration](../../../../../tests/quic/backend.c#L62)

```c
static int reject(struct peer *p,unsigned kind) {
```

Preserves the explicit input validation, serialization, custody and cleanup rules above. Native tests observe its results and failure effects.

### `send_bytes` — line 66

[Source declaration](../../../../../tests/quic/backend.c#L66)

```c
static int32_t send_bytes(void *arg,uint32_t level,tlsq_bytes b,size_t *accepted) {
```

Preserves the explicit input validation, serialization, custody and cleanup rules above. Native tests observe its results and failure effects.

### `receive_bytes` — line 79

[Source declaration](../../../../../tests/quic/backend.c#L79)

```c
static int32_t receive_bytes(void *arg,uint32_t level,size_t maximum,tlsq_bytes *lease) {
```

Preserves the explicit input validation, serialization, custody and cleanup rules above. Native tests observe its results and failure effects.

### `release_bytes` — line 93

[Source declaration](../../../../../tests/quic/backend.c#L93)

```c
static int32_t release_bytes(void *arg,uint32_t level,tlsq_bytes lease) {
```

Preserves the explicit input validation, serialization, custody and cleanup rules above. Native tests observe its results and failure effects.

### `secret` — line 105

[Source declaration](../../../../../tests/quic/backend.c#L105)

```c
static int32_t secret(void *arg,uint32_t level,uint32_t direction,uint32_t suite,tlsq_bytes b) {
```

Preserves the explicit input validation, serialization, custody and cleanup rules above. Native tests observe its results and failure effects.

### `peer_parameters` — line 113

[Source declaration](../../../../../tests/quic/backend.c#L113)

```c
static int32_t peer_parameters(void *arg,tlsq_bytes b) {
```

Preserves the explicit input validation, serialization, custody and cleanup rules above. Native tests observe its results and failure effects.

### `alert` — line 119

[Source declaration](../../../../../tests/quic/backend.c#L119)

```c
static int32_t alert(void *arg,uint32_t code) {
```

Preserves the explicit input validation, serialization, custody and cleanup rules above. Native tests observe its results and failure effects.

### `reenter` — line 121

[Source declaration](../../../../../tests/quic/backend.c#L121)

```c
    return reenter(p) && !reject(p,6);
```

Preserves the explicit input validation, serialization, custody and cleanup rules above. Native tests observe its results and failure effects.

### `callbacks` — line 123

[Source declaration](../../../../../tests/quic/backend.c#L123)

```c
static tlsq_callbacks callbacks(struct peer *p) {
```

Preserves the explicit input validation, serialization, custody and cleanup rules above. Native tests observe its results and failure effects.

### `config` — line 126

[Source declaration](../../../../../tests/quic/backend.c#L126)

```c
static tlsq_config config(struct peer *p,char *ca,char *cert,char *key,const char *scenario) {
```

Preserves the explicit input validation, serialization, custody and cleanup rules above. Native tests observe its results and failure effects.

### `validation` — line 140

[Source declaration](../../../../../tests/quic/backend.c#L140)

```c
static int validation(struct peer *p,tlsq_config c,tlsq_callbacks cb) {
```

Preserves the explicit input validation, serialization, custody and cleanup rules above. Native tests observe its results and failure effects.

### `run` — line 182

[Source declaration](../../../../../tests/quic/backend.c#L182)

```c
static int run(const char *scenario,const char *fixtures) {
```

Preserves the explicit input validation, serialization, custody and cleanup rules above. Native tests observe its results and failure effects.

### `main` — line 276

[Source declaration](../../../../../tests/quic/backend.c#L276)

```c
int main(int argc,char **argv) {
```

Preserves the explicit input validation, serialization, custody and cleanup rules above. Native tests observe its results and failure effects.
