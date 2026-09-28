# `tests/quic/backend_abi.c`

Source: [tests/quic/backend_abi.c](../../../../../tests/quic/backend_abi.c)  
Source SHA-256: `b86da4507f9fc50766a5cb14e1906036118a79e83411d7e5119936fddfb2fc6a`  
Snapshot bytes: 2767. Review date: 2026-09-26.

## Responsibility

Independent C layout probes and C-to-Zig callback invocation.

## Ownership, invariants and failure behavior

Reports sizeof, alignment and every member offset for five ABI structures compiled by C. Invokes every callback through the actual function table with known widths, levels, pointer/length pairs, direction and suite. Native Zig declarations are independently authored; no translated C reflection is used as the oracle.

## Verification

Native results are scoped to Windows x86_64; see current status, canonical completion receipts and retained qualification runs. This file alone does not establish a completed platform or production QUIC stack.

### `tlsq_abi_value` — line 4

[Source declaration](../../../../../tests/quic/backend_abi.c#L4)

```c
uint64_t tlsq_abi_value(uint32_t type,uint32_t field) {
```

Preserves the explicit input validation, serialization, custody and cleanup rules above. Native tests observe its results and failure effects.

### `tlsq_abi_invoke` — line 21

[Source declaration](../../../../../tests/quic/backend_abi.c#L21)

```c
int32_t tlsq_abi_invoke(const tlsq_callbacks *c) {
```

Preserves the explicit input validation, serialization, custody and cleanup rules above. Native tests observe its results and failure effects.
