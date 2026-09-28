# `tests/transport.zig`

Source: [tests/transport.zig](../../../../tests/transport.zig)  
Source SHA-256: `c97defce062ed89884aa56049df477b10d38e1c26b3f25e35b47c89bc345f2c4`  
Snapshot bytes: 23282. Review date: 2026-09-26.

## Responsibility

Executable regression suite for transport.

## Contract, ownership and failure behavior

Tests use explicit expected values and failure-path state comparisons. Test discovery depends on the owning build/root imports; names alone are not evidence that a test ran. Imports: std, tls.

## Next implementation work

Retain every named regression below. Add a minimized counterexample for changed behavior, including state before/after failure and externally visible output. Avoid generating expected wire bytes with the implementation being tested.

## Verification obligations

- [tests/transport.zig](../../../../tests/transport.zig): preserve existing regression assertions and add any changed-boundary cases.

## Dependency edges

`std`, `tls`. External module names resolve through the owning build graph; relative paths resolve from this source file.

## Declaration-by-declaration work map

Each entry points to the exact current source. Adjacent source documentation is retained below. Direct error names and assigned self fields are mechanically extracted navigation cues; they exclude transitive errors, pointer writes and full branch reasoning. Use the module contract above for obligations.

### `clientConfig` — line 175

[Source declaration](../../../../tests/transport.zig#L175)

```zig
fn clientConfig() tls.Config {
```

Review `clientConfig` as part of this file’s responsibility: Executable regression suite for transport. Preserve the stated ownership/failure contract when extending this entry point.

### `serverConfig` — line 178

[Source declaration](../../../../tests/transport.zig#L178)

```zig
fn serverConfig() tls.Config {
```

Review `serverConfig` as part of this file’s responsibility: Executable regression suite for transport. Preserve the stated ownership/failure contract when extending this entry point.

### `transfer` — line 181

[Source declaration](../../../../tests/transport.zig#L181)

```zig
fn transfer(from: *tls.Engine, to: *tls.Engine, fragment: usize) !usize {
```

Review `transfer` as part of this file’s responsibility: Executable regression suite for transport. Preserve the stated ownership/failure contract when extending this entry point.

### `handshake` — line 187

[Source declaration](../../../../tests/transport.zig#L187)

```zig
fn handshake(client: *tls.Engine, server: *tls.Engine, fragment: usize) !void {
```

Review `handshake` as part of this file’s responsibility: Executable regression suite for transport. Preserve the stated ownership/failure contract when extending this entry point.

Direct error exits in the syntactic region: `TestHandshakeStalled`.

### `connected` — line 197

[Source declaration](../../../../tests/transport.zig#L197)

```zig
fn connected() !struct { client: tls.Engine, server: tls.Engine } {
```

Review `connected` as part of this file’s responsibility: Executable regression suite for transport. Preserve the stated ownership/failure contract when extending this entry point.

## Executable regression inventory

19 named tests in this file. The build receipt, not this count, determines which tests ran.

- Line 19: **custom ALPN is owned by each connection and bounds are checked** — retain the existing independent expectations; a behavior change must explain why this oracle changes.
- Line 39: **ALPN mismatch rejects handshake before application data** — retain the existing independent expectations; a behavior change must explain why this oracle changes.
- Line 51: **opaque ALPN accepts the maximum legal identifier** — retain the existing independent expectations; a behavior change must explain why this oracle changes.
- Line 64: **qualified runtime backend is OpenSSL 3.5.8** — retain the existing independent expectations; a behavior change must explain why this oracle changes.
- Line 99: **TLS13 HTTP1 roundtrip with single-byte handshake fragments** — retain the existing independent expectations; a behavior change must explain why this oracle changes.
- Line 122: **wrong DNS name fails before application access** — retain the existing independent expectations; a behavior change must explain why this oracle changes.
- Line 135: **explicit trust excludes an unrelated CA** — retain the existing independent expectations; a behavior change must explain why this oracle changes.
- Line 146: **expired certificate and future validity use supplied wall time** — retain the existing independent expectations; a behavior change must explain why this oracle changes.
- Line 166: **client-only EKU cannot authenticate a server** — retain the existing independent expectations; a behavior change must explain why this oracle changes.
- Line 178: **IP SAN succeeds and wrong IP fails** — retain the existing independent expectations; a behavior change must explain why this oracle changes.
- Line 193: **mTLS requires a trusted client certificate** — retain the existing independent expectations; a behavior change must explain why this oracle changes.
- Line 214: **AEAD record tampering is terminal and releases no plaintext** — retain the existing independent expectations; a behavior change must explain why this oracle changes.
- Line 230: **clean close_notify differs from raw EOF and truncated record** — retain the existing independent expectations; a behavior change must explain why this oracle changes.
- Line 251: **shutdown preserves final records in both roles and still rejects truncation** — retain the existing independent expectations; a behavior change must explain why this oracle changes.
- Line 301: **shutdown retries a blocked close alert before reading final peer data** — retain the existing independent expectations; a behavior change must explain why this oracle changes.
- Line 336: **bounded output retains write data across WANT_WRITE** — retain the existing independent expectations; a behavior change must explain why this oracle changes.
- Line 361: **input bounds, empty input, and explicit EOF** — retain the existing independent expectations; a behavior change must explain why this oracle changes.
- Line 374: **absolute deadline, backward clock, and idempotent cancel** — retain the existing independent expectations; a behavior change must explain why this oracle changes.
- Line 387: **invalid configuration and mismatched credentials fail at creation** — retain the existing independent expectations; a behavior change must explain why this oracle changes.

Test review checklist: setup uses isolated state; expected values are independent; a negative case checks the entire affected state/output; resource/time bounds include exact-limit and one-beyond cases; new files are reachable from the build.

## Verified peer leaf export increment

Four new tests check both-role mTLS fingerprints against fixed Python DER/SHA-256 oracles, one-byte fragmentation, copied ownership, pre-completion/cancel/deinit denial, no-mTLS server denial, local/remote close and raw EOF, C null/capacity/output atomicity and untouched success suffix, application traffic after queries, and revocation following a tampered record after a successful export. Existing identity/trust/ALPN/mTLS/deadline negatives additionally check stable query denial. All nineteen original named regressions remain; total twenty-three. Digest-provider allocation/failure injection is not covered by these tests.

See the [identity guide](../../../guides/peer-identity.md) for the application boundary and current evidence.

### `fixtureDigest` — line 21

[Source declaration](../../../../tests/transport.zig#L21)

```zig
fn fixtureDigest(comptime hex: []const u8) [32]u8 {
```

Four new tests check both-role mTLS fingerprints against fixed Python DER/SHA-256 oracles, one-byte fragmentation, copied ownership, pre-completion/cancel/deinit denial, no-mTLS server denial, local/remote close and raw EOF, C null/capacity/output atomicity and untouched success suffix, application traffic after queries, and revocation following a tampered record after a successful export. Existing identity/trust/ALPN/mTLS/deadline negatives additionally check stable query denial. All nineteen original named regressions remain; total twenty-three. Digest-provider allocation/failure injection is not covered by these tests.
