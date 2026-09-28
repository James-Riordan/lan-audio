# `src/backend/quic.h`

Source: [src/backend/quic.h](../../../../../src/backend/quic.h)  
Source SHA-256: `f8db26c414fe4e00f98d0d43046b40a1272e0d2ec68751d3fd2a8007015856bd`  
Snapshot bytes: 4716. Review date: 2026-09-26.

## Responsibility

Private fixed-width recordless C ABI and live-handle lifetime.

## Ownership, invariants and failure behavior

All ABI enums/statuses are uint32_t constants, callbacks return int32_t, wall time uses int64_t, and byte lengths use size_t. No C enum/bool layout is assumed. Pointer/length pairs allow NULL only at zero length; absent optional text has zero length. Create requires an initialized NULL output handle and leaves it unchanged on failure. Configuration retained by OpenSSL is copied. The callback table/context and input leases remain live until close returns. Only valid, still-allocated handles are accepted; dangling/raw invented pointers cannot be safely validated.

Calls are serialized. Callback reentry into step/close/destroy fails without effects. send copies a committed prefix; receive grants one immutable lease up to the explicit maximum. Matching release retires only on callback success. A failed release retains custody and can be retried by SSL_free. close destroys SSL first, then clears retained configuration; after close, the owner may discard residual leases. destroy closes and frees the handle once, nulling the owner's pointer. Budgets count bytes, not total heap or wall time. Completion is TLS/identity/ALPN/parameter-callback/key-callback completion only; QUIC policy and installed keys still gate application readiness in T02/Q00.

Current runtime availability is restricted to the exact linked/header OpenSSL version on Windows x86_64 with 64-bit time_t. LP64 and other targets remain explicitly unavailable until native platform qualification; a portable header is not a supported provider. Test hooks are compiled only with TLSQ_TESTING and accept still-live handles, never freed pointers.

## Verification

Native results are scoped to Windows x86_64; see current status, canonical completion receipts and retained qualification runs. This file alone does not establish a completed platform or production QUIC stack.

### `tlsq_query` — line 88

[Source declaration](../../../../../src/backend/quic.h#L88)

```h
uint32_t tlsq_query(uint32_t abi_version, tlsq_capabilities *output);
```

Preserves the explicit input validation, serialization, custody and cleanup rules above. Native tests observe its results and failure effects.

### `tlsq_validate` — line 89

[Source declaration](../../../../../src/backend/quic.h#L89)

```h
uint32_t tlsq_validate(const tlsq_config *, const tlsq_callbacks *);
```

Preserves the explicit input validation, serialization, custody and cleanup rules above. Native tests observe its results and failure effects.

### `tlsq_create` — line 90

[Source declaration](../../../../../src/backend/quic.h#L90)

```h
uint32_t tlsq_create(const tlsq_config *, const tlsq_callbacks *, tlsq_provider **output);
```

Preserves the explicit input validation, serialization, custody and cleanup rules above. Native tests observe its results and failure effects.

### `tlsq_step` — line 97

[Source declaration](../../../../../src/backend/quic.h#L97)

```h
uint32_t tlsq_step(tlsq_provider *, size_t input_budget, size_t output_budget, tlsq_result *output);
```

Preserves the explicit input validation, serialization, custody and cleanup rules above. Native tests observe its results and failure effects.

### `tlsq_close` — line 98

[Source declaration](../../../../../src/backend/quic.h#L98)

```h
uint32_t tlsq_close(tlsq_provider *);
```

Preserves the explicit input validation, serialization, custody and cleanup rules above. Native tests observe its results and failure effects.

### `tlsq_destroy` — line 99

[Source declaration](../../../../../src/backend/quic.h#L99)

```h
uint32_t tlsq_destroy(tlsq_provider **);
```

Preserves the explicit input validation, serialization, custody and cleanup rules above. Native tests observe its results and failure effects.

### `tlsq_test_release` — line 104

[Source declaration](../../../../../src/backend/quic.h#L104)

```h
uint32_t tlsq_test_release(tlsq_provider *, size_t length);
```

Preserves the explicit input validation, serialization, custody and cleanup rules above. Native tests observe its results and failure effects.

### `tlsq_test_secret` — line 105

[Source declaration](../../../../../src/backend/quic.h#L105)

```h
uint32_t tlsq_test_secret(tlsq_provider *, uint32_t level, uint32_t direction, tlsq_bytes);
```

Preserves the explicit input validation, serialization, custody and cleanup rules above. Native tests observe its results and failure effects.
