# `examples/roundtrip.zig`

Source: [examples/roundtrip.zig](../../../../examples/roundtrip.zig)  
Source SHA-256: `e5e442435e8f30a7e34d9ac39dd70131bdcd7cb0cc48a0615c9f42974a4f79f0`  
Snapshot bytes: 2846. Review date: 2026-09-26.

## Responsibility

Public consumer demonstration of authenticated in-memory TLS records roundtrip.

## Contract, ownership and failure behavior

Example buffers and fixture inputs are deliberately bounded. Success covers this journey only. Network ownership, provider identity and production policy are claimed only when actually exercised; QUIC examples stay offline.

## Next implementation work

Keep the example importing the public facade. Preserve exact expected bytes and final invariants. Update its run command and fixture provenance whenever dependencies change. Add a real integration test separately from the demonstration.

## Verification obligations

Run the owning build or maintenance entry point described in the [verification guide](../../../verification/strategy.md). A passive fixture/record is verified by hash and by its named consumers; it is not an executable test.

## Dependency edges

`std`, `tls`. External module names resolve through the owning build graph; relative paths resolve from this source file.

## Declaration-by-declaration work map

Each entry points to the exact current source. Adjacent source documentation is retained below. Direct error names and assigned self fields are mechanically extracted navigation cues; they exclude transitive errors, pointer writes and full branch reasoning. Use the module contract above for obligations.

### `pump` — line 15

[Source declaration](../../../../examples/roundtrip.zig#L15)

```zig
fn pump(from: *tls.Engine, to: *tls.Engine) !void {
```

A host owns the byte transport. Replace this pump with socket queues in Zap.

Direct error exits in the syntactic region: `HostQueueRequired`.

### `main` — line 20

[Source declaration](../../../../examples/roundtrip.zig#L20)

```zig
pub fn main() !void {
```

Review `main` as part of this file’s responsibility: Public consumer demonstration of authenticated in-memory TLS records roundtrip. Preserve the stated ownership/failure contract when extending this entry point.

Direct error exits in the syntactic region: `HandshakeStalled`, `MissingCloseNotify`, `MissingRequest`.
