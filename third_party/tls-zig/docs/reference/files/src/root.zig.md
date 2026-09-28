# `src/root.zig`

Source: [src/root.zig](../../../../src/root.zig)  
Source SHA-256: `99587be81255039fef2f9e8c8d803097f0243748c9ba0e5f766ae257c56dc0b3`  
Snapshot bytes: 10496. Review date: 2026-09-26.

## Responsibility

Public TLS records Engine, configuration validation and C-status translation.

## Contract, ownership and failure behavior

Engine owns the backend handle; do not copy after initialization. Config strings and opaque ALPN are copied by init. Required peer checks and ALPN must pass before plaintext access. tick uses milliseconds and an absolute handshake deadline; certificate time uses supplied Unix seconds. InvalidState is not the same as a fatal TLS error. Fatal-alert drain can remain available.

## Next implementation work

Keep the 0.1.5 configurable single-ALPN behavior. Add capability reporting and explicit platform/build rejection before portability work. Keep QUIC recordless mode separate from feedRecords. Improve aggregate backend initialization errors only with a stable diagnostic contract.

## Verification obligations

- [tests/transport.zig](../../../../tests/transport.zig): preserve existing regression assertions and add any changed-boundary cases.

## Dependency edges

`backend.zig`, `driver.zig`, `std`. External module names resolve through the owning build graph; relative paths resolve from this source file.

## Declaration-by-declaration work map

Each entry points to the exact current source. Adjacent source documentation is retained below. Direct error names and assigned self fields are mechanically extracted navigation cues; they exclude transitive errors, pointer writes and full branch reasoning. Use the module contract above for obligations.

### `init` — line 54

[Source declaration](../../../../src/root.zig#L54)

```zig
pub fn init(config: Config) Error!Engine {
```

Validate ALPN length, paired credentials, role/peer/trust policy, ASCII DNS labels, clock and timeout arithmetic before creating the backend. Return an owning Engine with a fixed handshake deadline; invalid inputs must not allocate a live connection.

Direct error exits in the syntactic region: `BackendInitialization`, `InvalidConfig`.

### `ptr` — line 91

[Source declaration](../../../../src/root.zig#L91)

```zig
fn ptr(s: ?[:0]const u8) ?[*:0]const u8 {
```

Convert an optional sentinel-terminated Zig path to the nullable C pointer used only during initialization. This conversion does not copy or validate content.

### `live` — line 94

[Source declaration](../../../../src/root.zig#L94)

```zig
fn live(self: *Engine) Error!*c.tz_engine {
```

Reject a terminal error before returning the live backend pointer. A missing handle is canceled; no operation may resurrect it.

### `status` — line 98

[Source declaration](../../../../src/root.zig#L98)

```zig
fn status(self: *Engine, code: c_int) Error!Progress {
```

Translate the internal numeric status vocabulary into Progress/Error. InvalidState remains a misuse error; other negative statuses mark the engine terminal and revoke authenticated. Keep the C header/mirror synchronized.

Directly assigned owner fields in the syntactic region: `authenticated`, `terminal`.

### `tick` — line 119

[Source declaration](../../../../src/root.zig#L119)

```zig
pub fn tick(self: *Engine, now_ms: u64) Error!void {
```

Require a live owner, reject backward monotonic time and cancel when the unauthenticated handshake reaches its fixed deadline. This is not the post-handshake operation deadline; Driver owns that.

Direct error exits in the syntactic region: `DeadlineExceeded`, `InvalidState`.

Directly assigned owner fields in the syntactic region: `last_ms`, `terminal`.

### `handshake` — line 129

[Source declaration](../../../../src/root.zig#L129)

```zig
pub fn handshake(self: *Engine) Error!Progress {
```

Drive one backend handshake operation and set authenticated only on complete. Server no-mTLS authentication has the explicitly documented no-certified-client-identity meaning.

Directly assigned owner fields in the syntactic region: `authenticated`.

### `feedRecords` — line 135

[Source declaration](../../../../src/root.zig#L135)

```zig
pub fn feedRecords(self: *Engine, bytes: []const u8) Error!Transfer {
```

Copies at most 16 KiB and reports the exact accepted prefix. Empty input is not EOF.

### `drainRecords` — line 141

[Source declaration](../../../../src/root.zig#L141)

```zig
pub fn drainRecords(self: *Engine, bytes: []u8) Error!Transfer {
```

Draining is allowed after TLS failure so the host can send a generated alert.

### `readPlaintext` — line 147

[Source declaration](../../../../src/root.zig#L147)

```zig
pub fn readPlaintext(self: *Engine, bytes: []u8) Error!Transfer {
```

Delegate one bounded authenticated read and return the exact initialized prefix plus progress. Backend enforces no pending write; never assume an input record boundary equals an application message boundary.

### `queuePlaintext` — line 154

[Source declaration](../../../../src/root.zig#L154)

```zig
pub fn queuePlaintext(self: *Engine, bytes: []const u8) Error!void {
```

Copies one nonempty block <=16 KiB. Success means local custody, not delivery. Call flushPlaintext until complete, draining output whenever necessary.

### `flushPlaintext` — line 157

[Source declaration](../../../../src/root.zig#L157)

```zig
pub fn flushPlaintext(self: *Engine) Error!Progress {
```

Drive the existing immutable copied write. Service required transport input/output and continue until complete before accepting another block.

### `shutdown` — line 162

[Source declaration](../../../../src/root.zig#L162)

```zig
pub fn shutdown(self: *Engine) Error!Progress {
```

Starts local close. On plaintext_available, readPlaintext before retrying. Pending peer data is preserved; only closed authenticates peer close_notify.

### `transportEof` — line 166

[Source declaration](../../../../src/root.zig#L166)

```zig
pub fn transportEof(self: *Engine) Error!void {
```

Signals raw transport EOF. Subsequent handshake/read must still authenticate closure.

### `diagnostics` — line 186

[Source declaration](../../../../src/root.zig#L186)

```zig
pub fn diagnostics(self: *const Engine) ?Diagnostics {
```

Read diagnostics only while the handle exists. Convert the negative alert sentinel to null; cancellation frees provider diagnostics, so copy required nonsecret diagnostics before cleanup.

### `cancel` — line 191

[Source declaration](../../../../src/root.zig#L191)

```zig
pub fn cancel(self: *Engine) void {
```

Free a present handle, null it, revoke authentication and preserve an already-selected terminal error. Repeating cancel on the Zig owner is harmless.

Directly assigned owner fields in the syntactic region: `authenticated`, `handle`, `terminal`.

### `deinit` — line 197

[Source declaration](../../../../src/root.zig#L197)

```zig
pub fn deinit(self: *Engine) void {
```

Delegate to cancel. The API is logically move-only; copying an initialized struct defeats its lifetime guarantee.

### `backendVersion` — line 202

[Source declaration](../../../../src/root.zig#L202)

```zig
pub fn backendVersion() []const u8 {
```

Expose a borrowed runtime version string for qualification and diagnostics; this is not a full SDK hash check.

## Public type vocabulary

`Error`, `Progress`, `Transfer`, `Role`, `Identity`, `Config`, `Diagnostics`, `Engine`. Changing fields/tags/errors affects consumers; define migration and negative tests before changing representation.

## Verified peer leaf export increment

Adds verifiedPeerLeafSha256 on const Engine, returning a caller-owned [32]u8 only after local completed peer-verified TLS. PeerIdentityError is a separate union; existing Error and method signatures are unchanged. Terminal errors retain precedence; pre-handshake is InvalidState; absent verified peer or closing/EOF is PeerIdentityUnavailable; digest failure is PeerIdentityExportFailed and does not terminate TLS. Copied snapshots are not revocable; callers bind them to connection generations and application authorization. A no-mTLS server cannot export a certified client identity.

See the [identity guide](../../../guides/peer-identity.md) for the application boundary and current evidence.

### `verifiedPeerLeafSha256` — line 175

[Source declaration](../../../../src/root.zig#L175)

```zig
    pub fn verifiedPeerLeafSha256(self: *const Engine) PeerIdentityError![32]u8 {
```

Adds verifiedPeerLeafSha256 on const Engine, returning a caller-owned [32]u8 only after local completed peer-verified TLS. PeerIdentityError is a separate union; existing Error and method signatures are unchanged. Terminal errors retain precedence; pre-handshake is InvalidState; absent verified peer or closing/EOF is PeerIdentityUnavailable; digest failure is PeerIdentityExportFailed and does not terminate TLS. Copied snapshots are not revocable; callers bind them to connection generations and application authorization. A no-mTLS server cannot export a certified client identity.
