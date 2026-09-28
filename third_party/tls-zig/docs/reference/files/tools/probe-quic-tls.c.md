# `tools/probe-quic-tls.c`

Source: [tools/probe-quic-tls.c](../../../../tools/probe-quic-tls.c)  
Source SHA-256: `a043a574fed8815e0b0ddc14983a2ab80ae3eee8ddb6606b89f48c5e71370948`  
Snapshot bytes: 5904. Review: 2026-09-26 revision 2.

## Responsibility and operational contract

Test-only native exercise of external QUIC TLS ClientHello output and failure behavior.

Test-only Windows native probe. No sockets or completed peer handshake. Fixture credentials remain test data. The runner verifies external SDK bytes and writes only new scratch artifacts. Every error must preserve logs and leave the SDK/lock unchanged.

## Declaration-by-declaration obligations

### `send_crypto` — line 16

[Source declaration](../../../../tools/probe-quic-tls.c#L16)

```c
static int send_crypto(SSL *ssl, const unsigned char *bytes, size_t length,
```

Set consumed to zero first. Copy min(offered,budget) only after fixed-array capacity check; report exactly copied bytes. Injected failure accepts zero bytes; zero budget is nonfatal backpressure.

### `receive_crypto` — line 32

[Source declaration](../../../../tools/probe-quic-tls.c#L32)

```c
static int receive_crypto(SSL *ssl, const unsigned char **bytes, size_t *length, void *context) {
```

Count request and return an empty successful offer; this probe has no peer input. It cannot exercise a nonempty provider input lease.

### `release_crypto` — line 40

[Source declaration](../../../../tools/probe-quic-tls.c#L40)

```c
static int release_crypto(SSL *ssl, size_t length, void *context) {
```

Count unexpected release callbacks; no input was leased. Implementation must later validate matching release length and exactly-once retirement.

### `yield_secret` — line 46

[Source declaration](../../../../tools/probe-quic-tls.c#L46)

```c
static int yield_secret(SSL *ssl, uint32_t level, int direction,
```

Count calls without retaining or logging secret material. Any call prevents the expected initial-only success result.

### `peer_parameters` — line 53

[Source declaration](../../../../tools/probe-quic-tls.c#L53)

```c
static int peer_parameters(SSL *ssl, const unsigned char *params, size_t length, void *context) {
```

Count calls without copying peer data; none is expected because there is no peer.

### `alert` — line 59

[Source declaration](../../../../tools/probe-quic-tls.c#L59)

```c
static int alert(SSL *ssl, unsigned char code, void *context) {
```

Count callback invocations; later tests must assert actual alert mapping. This probe does not establish alert correctness.

### `main` — line 74

[Source declaration](../../../../tools/probe-quic-tls.c#L74)

```c
int main(int argc, char **argv) {
```

Select one of three fixed cases, initialize TLS 1.3/client policy/callbacks/local parameters, classify each TLS call immediately, validate raw handshake framing/error/progress, emit JSON and destroy SSL then context. No certificate-authentication result is claimed.

## Data and callback dispatch

`probe` owns one 4096-byte array and counters; it borrows no peer input. `callbacks` maps all six provider callback identifiers to matching signatures and ends with a zero sentinel. Test parameters and ALPN are static and remain alive through SSL teardown. The 217-byte observed ClientHello length is recorded evidence, not a universal hardcoded wire-size guarantee.

## Verification and next work

Run the documented entry point and applicable negative controls; retain command/exit/source identity. See [revision-2 status](../../../verification/current.md). Do not treat a maintenance check, model or initial callback probe as native protocol qualification.
