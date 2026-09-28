# `tools/probe-quic-pair.c`

Source: [tools/probe-quic-pair.c](../../../../tools/probe-quic-pair.c)  
Source SHA-256: `3f30826b0ffbd28cf60ed238b45876468fefec704dfad5d2fdce8fedf358a442`  
Snapshot bytes: 14683. Review: revision 5, 2026-09-26.

## Responsibility and limits

Offline authenticated recordless provider diagnostic. No production API or sockets. See [experiment and reproducible evidence](../../../verification/quic-provider-pair.md). Fixed arrays and test policy are deliberately scoped; do not copy them as production capacity or security policy.

## Declaration-by-declaration contract

### `observe` — line 33

[Source declaration](../../../../tools/probe-quic-pair.c#L33)

```c
static int observe(struct peer *p, int kind) {
```

Count total/control callbacks for the current provider call. Inject only the selected nonzero callback kind. This observes test traces, not a universal bound.

### `send_crypto` — line 39

[Source declaration](../../../../tools/probe-quic-pair.c#L39)

```c
static int send_crypto(SSL *ssl, const unsigned char *data, size_t length, size_t *consumed, void *arg) {
```

Initialize consumed to zero; cap accepted bytes by per-drive budget and fixed destination capacity. Copy before committing counters. Use current write level; append only so outstanding input pointers do not move.

### `receive_crypto` — line 49

[Source declaration](../../../../tools/probe-quic-pair.c#L49)

```c
static int receive_crypto(SSL *ssl, const unsigned char **data, size_t *length, void *arg) {
```

Reject a second outstanding lease. Select current read level; withhold beyond per-call byte budget, returning empty availability. Bound each lease by fragmentation size; record offset/length before returning stable storage.

### `release_crypto` — line 64

[Source declaration](../../../../tools/probe-quic-pair.c#L64)

```c
static int release_crypto(SSL *ssl, size_t length, void *arg) {
```

Validate the sole outstanding lease and exact length. On the injected first failure retain custody and counters. On a matching later release commit retirement once; record teardown invocations separately.

### `yield_secret` — line 76

[Source declaration](../../../../tools/probe-quic-pair.c#L76)

```c
static int yield_secret(SSL *ssl, uint32_t level, int direction, const unsigned char *secret, size_t length, void *arg) {
```

Accept only Handshake/Application, read/write and 32-byte secrets in this suite-specific experiment. Reject duplicates. Copy without logging; update only the corresponding current level after successful copy.

### `peer_parameters` — line 86

[Source declaration](../../../../tools/probe-quic-pair.c#L86)

```c
static int peer_parameters(SSL *ssl, const unsigned char *params, size_t length, void *arg) {
```

Require exactly one callback and the opposite peer's known bytes. This tests direction and callback delivery, not semantic QUIC transport-parameter validation.

### `alert` — line 94

[Source declaration](../../../../tools/probe-quic-pair.c#L94)

```c
static int alert(SSL *ssl, unsigned char code, void *arg) {
```

Record the outgoing alert code and selected failure injection. Do not send a record or claim peer close delivery.

### `select_alpn` — line 98

[Source declaration](../../../../tools/probe-quic-pair.c#L98)

```c
static int select_alpn(SSL *ssl, const unsigned char **out, unsigned char *length, const unsigned char *in, unsigned int n, void *arg) {
```

Choose the exact offered test protocol or deliberately reject. Return a fatal ALPN outcome for refusal; returned selection references provider/static storage under the native callback contract.

### `new_session` — line 104

[Source declaration](../../../../tools/probe-quic-pair.c#L104)

```c
static int new_session(SSL *ssl, SSL_SESSION *session) {
```

Count session notifications and return zero so the application keeps no session reference. Used only to observe post-handshake ticket processing; never attempts resumption.

### `no_password` — line 108

[Source declaration](../../../../tools/probe-quic-pair.c#L108)

```c
static int no_password(char *buf, int size, int writing, void *arg) {
```

Return zero without prompting. Encrypted fixture keys fail construction instead of opening an interactive credential request.

### `setup` — line 119

[Source declaration](../../../../tools/probe-quic-pair.c#L119)

```c
static int setup(struct peer *p, const char *fixtures, const char *scenario) {
```

Check bounded fixture paths, TLS version/suite/group, explicit CA, certificate/key consistency, fixed verification time, strict SAN policy, ALPN, callbacks and parameters. Partially created contexts remain visible for cleanup. Client certificate is supplied only in mutual mode; tickets only in the ticket experiment.

### `step` — line 157

[Source declaration](../../../../tools/probe-quic-pair.c#L157)

```c
static void step(struct peer *p, int post_handshake) {
```

Replenish independent input/output budgets, clear native errors, invoke handshake or zero-length post-handshake read, then immediately classify the result. Record fatal/blocked/completion facts and observed per-call counts. Do not conflate WANT_READ with actual absence of locally queued data.

### `successful_pair` — line 171

[Source declaration](../../../../tools/probe-quic-pair.c#L171)

```c
static int successful_pair(struct peer *c, struct peer *s, int mtls) {
```

Require both roles complete under the intended peer policy, actual certificate presence, selected ALPN, opposite-direction Handshake/Application secret equality, parameters and complete successful input retirement. No key bytes are serialized; server client identity is claimed only in mutual mode.

### `main` — line 188

[Source declaration](../../../../tools/probe-quic-pair.c#L188)

```c
int main(int argc, char **argv) {
```

Select a fixed scenario, initialize both peers, drive with a finite turn cap, optionally process tickets, evaluate role-specific positive/negative oracles, and keep state live through SSL destruction. Explicitly verify failed-release cleanup; print metadata and cleanse secret arrays. Fatal alerts are not transported to the opposite peer.

## Data and failure invariants

The C peer owns four 64 KiB input arrays, directional secret copies, one lease record and counters. Destination arrays never move or reclaim space during a scenario. Output acceptance cannot exceed copied bytes. Release failure leaves the outstanding lease intact; provider teardown happens while both peers and all callback targets are alive. The 10,000-turn cap and 10-second case timeout detect stalls but do not prove a real-time bound. The Python runner requires new scratch to avoid stale binary replacement and preserves case/compile logs. Errors do not rewrite SDK or lock.

## Verification and maintenance

Run all 17 cases at O0 and O2 with the pinned compiler/SDK. Refresh this card and source inventory only after reviewing changes; retain old scoped receipts. No C assert or Python assert carries a required runtime check. Public native-library tests become necessary when production implementation changes.
