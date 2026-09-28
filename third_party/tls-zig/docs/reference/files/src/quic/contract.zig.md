# `src/quic/contract.zig`

Source: [src/quic/contract.zig](../../../../../src/quic/contract.zig)  
Source SHA-256: `ad62cafbce1be4216229585513e73165a7817d512b222fecb4cbf2ed488f95c0`  
Snapshot bytes: 14725. Review date: 2026-09-26.

## Responsibility

Typed recordless protocol contract and allocation-free configuration admission.

## Ownership, invariants and failure behavior

normalize accepts explicit host-selected environment defaults and whole-field overrides. Caller-owned OverridePolicy authorizes each field before replacement; unknown, duplicate and unauthorized fields fail. Explicit zero/empty values are validated, never replaced by defaults. The selected profile is QUIC v1, TLS 1.3, AES-128-GCM/SHA-256; early data, resumption, custom entropy and provider-memory caps are rejected. Capabilities separate compiled presence from observed runtime availability. No filesystem, network, native provider or ambient environment is consulted.

Client policy requires trust and a typed DNS/IP reference identity. DNS uses ASCII label constraints (IDNA belongs to host); IP uses the standard library literal parser. Server credentials are required; optional required client certificates have explicit trust. A no-mTLS server may report configured policy, never a certified client identity. ALPN is one opaque 1..255 byte identifier including possible NUL/non-ASCII bytes. All capacities and absolute monotonic deadline arithmetic are checked; wall time is a distinct positive Unix-seconds type.

Plan retains borrowed immutable configuration bytes. The constructing owner must call Plan.verify immediately before allocation/copy; it rejects changed effective bytes, schema, capability observations or deadline. Caller must keep the buffers stable through that transaction. Fingerprint is drift detection, not cryptographic authorization or certificate-file identity. T02 must copy retained values and preserve this gate before native construction.

The schema-1 fingerprint uses SHA-256 over the domain bytes tls-zig.recordless.plan followed by NUL. Every number is unsigned 64-bit little-endian; every byte slice is a length number followed by exact bytes. Order: schema; QUIC/TLS/suite; role; role-specific trust/identity/credential fields and presence tags; ALPN; local parameters; wall time/now/timeout; input bytes/event slots/control slots/payload bytes/parameter limit; requirements including optional memory presence/value; four compiled capability flags and runtime enum. Client=0, server=1; DNS=0, IP=1; runtime unknown=0/unavailable=1/available=2. Config validation precedes signed-wall-time conversion. The independent Python struct/hashlib calculation is frozen in the golden test.

ByteCount, direction, encryption level, generation, sequence and wall/monotonic clocks are distinct types. Transfer.acceptedPrefix checks untrusted provider counts before slicing. Module-local atomic generation allocation fails without wrap at pointer-width exhaustion; OwnerId additionally binds a domain address to distinguish loaded module instances. The module must remain loaded while tokens exist. These are process-memory handles, not serializable or security credentials. Native tests cover counter exhaustion; queues remain serialized despite thread-safe ID allocation.

## Verification

[T01/T03 implementation evidence](../../../../verification/t01-implementation.md) records scope, commands and remaining gates. Update this source contract only after reviewing changed behavior.

### `toMicrosEarly` — line 35

[Source declaration](../../../../../src/quic/contract.zig#L35)

```zig
    pub fn toMicrosEarly(self: MonotonicNs) u64 {
```

Deadlines round toward earlier wakeup; no wall-time conversion exists.

### `eql` — line 44

[Source declaration](../../../../../src/quic/contract.zig#L44)

```zig
    pub fn eql(a: OwnerId, b: OwnerId) bool {
```

Implements the file responsibility and validated ownership/serialization rules above; no hidden network or provider side effects.

### `eql` — line 51

[Source declaration](../../../../../src/quic/contract.zig#L51)

```zig
    pub fn eql(a: EventId, b: EventId) bool {
```

Implements the file responsibility and validated ownership/serialization rules above; no hidden network or provider side effects.

### `takeGeneration` — line 57

[Source declaration](../../../../../src/quic/contract.zig#L57)

```zig
fn takeGeneration(counter: *std.atomic.Value(usize)) Error!OwnerGeneration {
```

Implements the file responsibility and validated ownership/serialization rules above; no hidden network or provider side effects.

### `freshOwner` — line 68

[Source declaration](../../../../../src/quic/contract.zig#L68)

```zig
pub fn freshOwner() Error!OwnerId {
```

Fresh for this loaded module's lifetime. Domain distinguishes simultaneously loaded copies; do not unload a module while any of its handles/tokens exist.

### `validate` — line 110

[Source declaration](../../../../../src/quic/contract.zig#L110)

```zig
    pub fn validate(self: Limits) Error!void {
```

Implements the file responsibility and validated ownership/serialization rules above; no hidden network or provider side effects.

### `payloadStorageBytes` — line 116

[Source declaration](../../../../../src/quic/contract.zig#L116)

```zig
    pub fn payloadStorageBytes(self: Limits) Error!ByteCount {
```

Implements the file responsibility and validated ownership/serialization rules above; no hidden network or provider side effects.

### `verify` — line 158

[Source declaration](../../../../../src/quic/contract.zig#L158)

```zig
    pub fn verify(self: Plan, caps: Capabilities) Error!void {
```

Mandatory immediately before allocation/copy. Detects changed borrowed bytes, effective options, capability observations, schema and deadline.

### `pathValid` — line 165

[Source declaration](../../../../../src/quic/contract.zig#L165)

```zig
fn pathValid(path: []const u8) bool {
```

Implements the file responsibility and validated ownership/serialization rules above; no hidden network or provider side effects.

### `credentialsValid` — line 168

[Source declaration](../../../../../src/quic/contract.zig#L168)

```zig
fn credentialsValid(value: Credentials) bool {
```

Implements the file responsibility and validated ownership/serialization rules above; no hidden network or provider side effects.

### `validateIdentity` — line 171

[Source declaration](../../../../../src/quic/contract.zig#L171)

```zig
fn validateIdentity(identity: Identity) Error!void {
```

Implements the file responsibility and validated ownership/serialization rules above; no hidden network or provider side effects.

### `validate` — line 191

[Source declaration](../../../../../src/quic/contract.zig#L191)

```zig
fn validate(cfg: Config, caps: Capabilities) Error!MonotonicNs {
```

Implements the file responsibility and validated ownership/serialization rules above; no hidden network or provider side effects.

### `number` — line 225

[Source declaration](../../../../../src/quic/contract.zig#L225)

```zig
    fn number(self: *Hash, n: u64) void {
```

Implements the file responsibility and validated ownership/serialization rules above; no hidden network or provider side effects.

### `bytes` — line 230

[Source declaration](../../../../../src/quic/contract.zig#L230)

```zig
    fn bytes(self: *Hash, value: []const u8) void {
```

Implements the file responsibility and validated ownership/serialization rules above; no hidden network or provider side effects.

### `credentials` — line 234

[Source declaration](../../../../../src/quic/contract.zig#L234)

```zig
    fn credentials(self: *Hash, value: Credentials) void {
```

Implements the file responsibility and validated ownership/serialization rules above; no hidden network or provider side effects.

### `fingerprint` — line 239

[Source declaration](../../../../../src/quic/contract.zig#L239)

```zig
fn fingerprint(cfg: Config, caps: Capabilities) [32]u8 {
```

Implements the file responsibility and validated ownership/serialization rules above; no hidden network or provider side effects.

### `normalize` — line 299

[Source declaration](../../../../../src/quic/contract.zig#L299)

```zig
pub fn normalize(base: Config, overrides: []const Override, allowed: OverridePolicy, caps: Capabilities) Error!Plan {
```

The host supplies its selected environment defaults as base. Authorization is caller-owned, checked before applying overrides. No allocation or provider call.

### `acceptedPrefix` — line 325

[Source declaration](../../../../../src/quic/contract.zig#L325)

```zig
    pub fn acceptedPrefix(self: Transfer, offered: []const u8) Error![]const u8 {
```

A provider result is untrusted until checked against the offered slice.

## Native owner integration

The input_bytes limit is accepted input capacity per encryption level. The native Engine allocates three independent rings and checks the multiplication. Wait.input_capacity identifies partial/rejected input admission separately from output event capacity, network input and bounded local work. Pure contract exports still require no SDK. This update does not change the normalized configuration fingerprint encoding.
