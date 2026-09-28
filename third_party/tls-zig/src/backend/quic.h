#ifndef TLS_ZIG_QUIC_H
#define TLS_ZIG_QUIC_H
/* Private recordless ABI, version 1. Serialized and nonreentrant.
 * Integers cross the ABI with explicit widths; no C enum or bool layouts.
 * A live handle must come from create. Never pass a freed or invented pointer.
 * close destroys SSL while callbacks and input leases remain valid; destroy
 * then frees the handle and nulls the caller's pointer. No socket/record I/O.
 */
#include <stddef.h>
#include <stdint.h>
#ifdef __cplusplus
extern "C" {
#endif
#define TLSQ_ABI_VERSION 1u
#define TLSQ_OK 0u
#define TLSQ_INVALID 1u
#define TLSQ_UNAVAILABLE 2u
#define TLSQ_NO_MEMORY 3u
#define TLSQ_CONFIGURATION 4u
#define TLSQ_CLOSED 5u
#define TLSQ_REENTRANT 6u
#define TLSQ_TERMINAL 7u
#define TLSQ_INITIAL 0u
#define TLSQ_HANDSHAKE 1u
#define TLSQ_APPLICATION 2u
#define TLSQ_READ 0u
#define TLSQ_WRITE 1u
#define TLSQ_CLIENT 0u
#define TLSQ_SERVER 1u
#define TLSQ_DNS 0u
#define TLSQ_IP 1u
#define TLSQ_PROGRESS 0u
#define TLSQ_NETWORK_INPUT 1u
#define TLSQ_EVENT_CAPACITY 2u
#define TLSQ_LOCAL_WORK 3u
#define TLSQ_AUTH_NONE 0u
#define TLSQ_AUTH_SERVER_POLICY 1u
#define TLSQ_AUTH_SERVER_IDENTITY 2u
#define TLSQ_AUTH_CLIENT_CERTIFICATE 3u
#define TLSQ_AES128GCM_SHA256 0x1301u

typedef struct tlsq_provider tlsq_provider;
typedef struct tlsq_bytes { const unsigned char *data; size_t length; } tlsq_bytes;
typedef struct tlsq_capabilities {
    uint32_t abi_version, compiled_recordless, runtime_available, qualified_target;
} tlsq_capabilities;
typedef struct tlsq_config {
    uint32_t abi_version, role, identity_kind, require_client_certificate;
    int64_t wall_time_seconds;
    tlsq_bytes trust_file, certificate_file, private_key_file, identity;
    tlsq_bytes alpn, local_parameters;
    size_t peer_parameter_limit;
} tlsq_config;

/* All callbacks return 1 for committed success and 0 for fatal failure.
 * send may commit 0..bytes.length, copying before success. recv may return
 * empty (network shortage), or one stable buffer of at most maximum bytes.
 * That buffer stays immutable until an exact release succeeds, or close has
 * returned and the owner discards residual custody. A failed release retains
 * ownership and may be retried during close. Control bytes are temporary:
 * copy/derive them before returning success. Failure effects must be retry-safe.
 */
typedef struct tlsq_callbacks {
    uint32_t abi_version;
    void *context;
    int32_t (*send)(void *, uint32_t level, tlsq_bytes, size_t *accepted);
    int32_t (*receive)(void *, uint32_t level, size_t maximum, tlsq_bytes *leased);
    int32_t (*release)(void *, uint32_t level, tlsq_bytes leased);
    int32_t (*secret)(void *, uint32_t level, uint32_t direction, uint32_t suite, tlsq_bytes);
    int32_t (*parameters)(void *, tlsq_bytes);
    int32_t (*alert)(void *, uint32_t code);
} tlsq_callbacks;
typedef struct tlsq_result {
    uint32_t wait, tls_complete, peer_authentication, alert_code;
    int32_t ssl_error;
    uint32_t callback_failed;
    int64_t verify_error;
    size_t input_delivered, output_accepted, lease_bytes;
} tlsq_result;

/* Invalid calls leave caller output unchanged. Config byte pairs allow NULL
 * only for zero length; optional fields are absent only at zero length.
 * create requires an initialized NULL output handle; it cannot replace an owner.
 * Configuration is borrowed only during create; retained fields are copied.
 * Trust/credentials are explicit files. No environment defaults or password UI.
 * Only the locked native Windows x86_64 SDK is presently runtime-qualified.
 */
uint32_t tlsq_query(uint32_t abi_version, tlsq_capabilities *output);
uint32_t tlsq_validate(const tlsq_config *, const tlsq_callbacks *);
uint32_t tlsq_create(const tlsq_config *, const tlsq_callbacks *, tlsq_provider **output);
/* Budgets count newly leased/accepted bytes, not provider heap or wall time.
 * A zero budget pauses locally. TLS completion is not QUIC/application readiness.
 * step drives post-handshake CRYPTO too; no resumption state is retained.
 * A fatal first step writes its diagnostic result and returns TERMINAL;
 * subsequent terminal calls leave output unchanged.
 */
uint32_t tlsq_step(tlsq_provider *, size_t input_budget, size_t output_budget, tlsq_result *output);
uint32_t tlsq_close(tlsq_provider *);
uint32_t tlsq_destroy(tlsq_provider **);
#ifdef TLSQ_TESTING
/* Safe test hooks operate only on still-allocated live handles. Invalid
 * arguments do not dispatch callbacks or change custody. Never test freed pointers.
 */
uint32_t tlsq_test_release(tlsq_provider *, size_t length);
uint32_t tlsq_test_secret(tlsq_provider *, uint32_t level, uint32_t direction, tlsq_bytes);
#endif
#ifdef __cplusplus
}
#endif
#endif
