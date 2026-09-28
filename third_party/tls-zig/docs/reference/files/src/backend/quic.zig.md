# `src/backend/quic.zig`

Source: [src/backend/quic.zig](../../../../../src/backend/quic.zig)  
Source SHA-256: `45dbbea02b4fb8f0b04ab8a1ee92fe51e582bc54c4a8b0f0d300f5e395db28f0`  
Snapshot bytes: 1871. Review date: 2026-09-26.

## Responsibility

Independent Zig declarations for the actual private native ABI.

## Ownership, invariants and failure behavior

Declares fixed-width extern structures, callback calling conventions and opaque provider ownership without C translation. The native C/Zig layout probe tests these exact production declarations, including every field offset and C-to-Zig callback invocation. Optional pointers are explicit; only live, serialized provider handles may be passed. The Engine owns all calls and callback state. Windows x86_64 is the only currently qualified native ABI; LP64 runtime support remains unavailable.

## Verification

Native results are scoped to Windows x86_64; see current status, canonical completion receipts and retained qualification runs. This file alone does not establish a completed platform or production QUIC stack.

### `tlsq_query` — line 42

[Source declaration](../../../../../src/backend/quic.zig#L42)

```zig
pub extern fn tlsq_query(u32, *Capabilities) callconv(.c) u32;
```

Preserves the explicit input validation, serialization, custody and cleanup rules above. Native tests observe its results and failure effects.

### `tlsq_validate` — line 43

[Source declaration](../../../../../src/backend/quic.zig#L43)

```zig
pub extern fn tlsq_validate(*const Config, *const Callbacks) callconv(.c) u32;
```

Preserves the explicit input validation, serialization, custody and cleanup rules above. Native tests observe its results and failure effects.

### `tlsq_create` — line 44

[Source declaration](../../../../../src/backend/quic.zig#L44)

```zig
pub extern fn tlsq_create(*const Config, *const Callbacks, *?*Provider) callconv(.c) u32;
```

Preserves the explicit input validation, serialization, custody and cleanup rules above. Native tests observe its results and failure effects.

### `tlsq_step` — line 45

[Source declaration](../../../../../src/backend/quic.zig#L45)

```zig
pub extern fn tlsq_step(*Provider, usize, usize, *Result) callconv(.c) u32;
```

Preserves the explicit input validation, serialization, custody and cleanup rules above. Native tests observe its results and failure effects.

### `tlsq_close` — line 46

[Source declaration](../../../../../src/backend/quic.zig#L46)

```zig
pub extern fn tlsq_close(*Provider) callconv(.c) u32;
```

Preserves the explicit input validation, serialization, custody and cleanup rules above. Native tests observe its results and failure effects.

### `tlsq_destroy` — line 47

[Source declaration](../../../../../src/backend/quic.zig#L47)

```zig
pub extern fn tlsq_destroy(*?*Provider) callconv(.c) u32;
```

Preserves the explicit input validation, serialization, custody and cleanup rules above. Native tests observe its results and failure effects.
