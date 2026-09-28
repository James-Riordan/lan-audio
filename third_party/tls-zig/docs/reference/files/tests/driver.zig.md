# `tests/driver.zig`

Source: [tests/driver.zig](../../../../tests/driver.zig)  
Source SHA-256: `ebd171a3e78d7e0a9cf0111f57c05f3aafb4dc12b4d5e929e60f5f28a6281d09`  
Snapshot bytes: 17276. Review date: 2026-09-26.

## Responsibility

Executable regression suite for driver.

## Contract, ownership and failure behavior

Tests use explicit expected values and failure-path state comparisons. Test discovery depends on the owning build/root imports; names alone are not evidence that a test ran. Imports: std, tls.

## Next implementation work

Retain every named regression below. Add a minimized counterexample for changed behavior, including state before/after failure and externally visible output. Avoid generating expected wire bytes with the implementation being tested.

## Verification obligations

- [tests/driver.zig](../../../../tests/driver.zig): preserve existing regression assertions and add any changed-boundary cases.

## Dependency edges

`std`, `tls`. External module names resolve through the owning build graph; relative paths resolve from this source file.

## Declaration-by-declaration work map

Each entry points to the exact current source. Adjacent source documentation is retained below. Direct error names and assigned self fields are mechanically extracted navigation cues; they exclude transitive errors, pointer writes and full branch reasoning. Use the module contract above for obligations.

### `transport` — line 35

[Source declaration](../../../../tests/driver.zig#L35)

```zig
fn transport(self: *Socket) tls.host.Transport {
```

Review `transport` as part of this file’s responsibility: Executable regression suite for driver. Preserve the stated ownership/failure contract when extending this entry point.

### `send` — line 38

[Source declaration](../../../../tests/driver.zig#L38)

```zig
fn send(context: *anyopaque, bytes: []const u8) error{TransportFailure}!?usize {
```

Review `send` as part of this file’s responsibility: Executable regression suite for driver. Preserve the stated ownership/failure contract when extending this entry point.

Directly assigned owner fields in the syntactic region: `sends`.

### `recv` — line 54

[Source declaration](../../../../tests/driver.zig#L54)

```zig
fn recv(context: *anyopaque, buffer: []u8) error{TransportFailure}!?usize {
```

Review `recv` as part of this file’s responsibility: Executable regression suite for driver. Preserve the stated ownership/failure contract when extending this entry point.

Directly assigned owner fields in the syntactic region: `recvs`.

### `init` — line 75

[Source declaration](../../../../tests/driver.zig#L75)

```zig
fn init(self: *Pair) !void {
```

Review `init` as part of this file’s responsibility: Executable regression suite for driver. Preserve the stated ownership/failure contract when extending this entry point.

Directly assigned owner fields in the syntactic region: `client`, `client_socket`, `server`, `server_socket`.

### `deinit` — line 82

[Source declaration](../../../../tests/driver.zig#L82)

```zig
fn deinit(self: *Pair) void {
```

Review `deinit` as part of this file’s responsibility: Executable regression suite for driver. Preserve the stated ownership/failure contract when extending this entry point.

### `handshake` — line 86

[Source declaration](../../../../tests/driver.zig#L86)

```zig
fn handshake(self: *Pair) !void {
```

Review `handshake` as part of this file’s responsibility: Executable regression suite for driver. Preserve the stated ownership/failure contract when extending this entry point.

Direct error exits in the syntactic region: `HandshakeStalled`.

### `finish` — line 99

[Source declaration](../../../../tests/driver.zig#L99)

```zig
fn finish(driver: *tls.Driver) !Result {
```

Review `finish` as part of this file’s responsibility: Executable regression suite for driver. Preserve the stated ownership/failure contract when extending this entry point.

Direct error exits in the syntactic region: `OperationStalled`.

### `probe` — line 110

[Source declaration](../../../../tests/driver.zig#L110)

```zig
fn probe(driver: *tls.Driver, buffer: []u8) !tls.host.ProbeResult {
```

Review `probe` as part of this file’s responsibility: Executable regression suite for driver. Preserve the stated ownership/failure contract when extending this entry point.

Direct error exits in the syntactic region: `ProbeStalled`.

## Executable regression inventory

11 named tests in this file. The build receipt, not this count, determines which tests ran.

- Line 118: **peer probe observes early response without changing blocked ciphertext or deadline** — retain the existing independent expectations; a behavior change must explain why this oracle changes.
- Line 162: **peer probe during blocked write honors cancel deadline and raw EOF** — retain the existing independent expectations; a behavior change must explain why this oracle changes.
- Line 192: **idle probe output flush preserves order before next application write** — retain the existing independent expectations; a behavior change must explain why this oracle changes.
- Line 216: **host driver preserves partial writes and received suffixes across reads** — retain the existing independent expectations; a behavior change must explain why this oracle changes.
- Line 247: **host shutdown preserves deadline across final plaintext reads and rejects raw EOF** — retain the existing independent expectations; a behavior change must explain why this oracle changes.
- Line 276: **host operation deadline expires despite slow transport progress** — retain the existing independent expectations; a behavior change must explain why this oracle changes.
- Line 291: **atomic cancellation stops blocked reads and writes without touching transport** — retain the existing independent expectations; a behavior change must explain why this oracle changes.
- Line 321: **host cannot extend a shutdown deadline by switching to read** — retain the existing independent expectations; a behavior change must explain why this oracle changes.
- Line 337: **host rejects invalid transport counts and backward clocks** — retain the existing independent expectations; a behavior change must explain why this oracle changes.
- Line 357: **host authentication failure flushes fragmented alert and retains diagnostics** — retain the existing independent expectations; a behavior change must explain why this oracle changes.
- Line 386: **host raw EOF during handshake is terminal even when alert delivery blocks** — retain the existing independent expectations; a behavior change must explain why this oracle changes.

Test review checklist: setup uses isolated state; expected values are independent; a negative case checks the entire affected state/output; resource/time bounds include exact-limit and one-beyond cases; new files are reachable from the build.
