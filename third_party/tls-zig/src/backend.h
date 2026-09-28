/* Engineering contract (2026-09-26)
 * Internal C ABI declarations and status-number vocabulary.
 * File contract: docs/reference/files/src/backend.h.md
 * Ownership and invariant: Keep C and Zig signatures aligned for size_t, integer widths, nullable
 * pointers and ownership. tz_free accepts null; operations require a live handle. Constructor
 * failure is null. The status comment includes -5 although the current implementation does not
 * emit it.
 * Next implementation obligation: Remove or formalize the unused -5 status in a focused ABI
 * cleanup. Add compile/link ABI checks for every supported target; validate argument order and
 * length parameters for custom ALPN. Do not promote this test-facing ABI to a compatibility
 * promise accidentally.
 * Verification: tests/transport.zig
 */

#ifndef TLS_ZIG_BACKEND_H
#define TLS_ZIG_BACKEND_H
#include <stddef.h>
#include <stdint.h>
typedef struct tz_engine tz_engine;
/* Status: 0 complete, 1 needs input, 2 needs output, 3 clean close, 4 input full,
 * 5 shutdown needs the host to read pending plaintext;
 * -1 TLS failure, -2 authentication, -3 ALPN, -4 misuse, -5 configuration. */
tz_engine *tz_new(int server, const char *ca, const char *cert, const char *key,
                  const char *peer, int ip, int require_client, int64_t wall_time);
/* Copies one opaque ALPN identifier (1..255 bytes). The original constructor
 * remains an HTTP/1.1 compatibility entry point for existing C ABI consumers. */
tz_engine *tz_new_with_alpn(int server, const char *ca, const char *cert, const char *key,
                  const char *peer, int ip, int require_client, int64_t wall_time,
                  const unsigned char *protocol, size_t protocol_length);
void tz_free(tz_engine *e);
int tz_handshake(tz_engine *e);
int tz_feed(tz_engine *e, const unsigned char *p, size_t n, size_t *used);
int tz_drain(tz_engine *e, unsigned char *p, size_t n, size_t *used);
int tz_read(tz_engine *e, unsigned char *p, size_t n, size_t *used);
int tz_write(tz_engine *e, const unsigned char *p, size_t n);
int tz_flush(tz_engine *e);
int tz_shutdown(tz_engine *e);
int tz_eof(tz_engine *e);
long tz_verify_error(tz_engine *e);
unsigned long tz_reason(tz_engine *e);
int tz_alert(tz_engine *e);
/* Copied SHA-256 of verified peer leaf DER; live serialized handle or NULL.
 * Requires completed peer-verified TLS, no failure, shutdown or EOF. Writes
 * exactly 32 bytes only on success; all output remains unchanged on failure.
 * Query-specific results: 0 success, -4 unavailable/invalid arguments,
 * -1 digest export failure. Neither query failure changes connection state. */
int tz_verified_peer_leaf_sha256(tz_engine *e, unsigned char *out, size_t capacity);
const char *tz_version(void);
#endif
