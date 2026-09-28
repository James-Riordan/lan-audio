/* Test-only external QUIC TLS capability probe. No sockets, peer or completed handshake.
 * Contract: docs/reference/files/tools/probe-quic-tls.c.md.
 * Build/run through probe-quic-tls.py so SDK identity and runtime staging are checked.
 */
#include <openssl/ssl.h>
#include <openssl/err.h>
#include <openssl/core_dispatch.h>
#include <stdio.h>
#include <string.h>

struct probe {
    unsigned char bytes[4096];
    size_t length, budget, sends, receives, releases, secrets, parameters, alerts;
    int fail_send;
};
static int send_crypto(SSL *ssl, const unsigned char *bytes, size_t length,
                       size_t *consumed, void *context) {
    struct probe *p = context;
    size_t n;
    (void)ssl;
    ++p->sends;
    *consumed = 0;
    if (p->fail_send) return 0;
    n = length < p->budget ? length : p->budget;
    if (n > sizeof p->bytes - p->length) return 0;
    if (n) memcpy(p->bytes + p->length, bytes, n);
    p->length += n;
    p->budget -= n;
    *consumed = n;
    return 1;
}
static int receive_crypto(SSL *ssl, const unsigned char **bytes, size_t *length, void *context) {
    struct probe *p = context;
    (void)ssl;
    ++p->receives;
    *bytes = NULL;
    *length = 0;
    return 1;
}
static int release_crypto(SSL *ssl, size_t length, void *context) {
    struct probe *p = context;
    (void)ssl; (void)length;
    ++p->releases;
    return 1;
}
static int yield_secret(SSL *ssl, uint32_t level, int direction,
                        const unsigned char *secret, size_t length, void *context) {
    struct probe *p = context;
    (void)ssl; (void)level; (void)direction; (void)secret; (void)length;
    ++p->secrets;
    return 1;
}
static int peer_parameters(SSL *ssl, const unsigned char *params, size_t length, void *context) {
    struct probe *p = context;
    (void)ssl; (void)params; (void)length;
    ++p->parameters;
    return 1;
}
static int alert(SSL *ssl, unsigned char code, void *context) {
    struct probe *p = context;
    (void)ssl; (void)code;
    ++p->alerts;
    return 1;
}
static const OSSL_DISPATCH callbacks[] = {
    { OSSL_FUNC_SSL_QUIC_TLS_CRYPTO_SEND, (void (*)(void))send_crypto },
    { OSSL_FUNC_SSL_QUIC_TLS_CRYPTO_RECV_RCD, (void (*)(void))receive_crypto },
    { OSSL_FUNC_SSL_QUIC_TLS_CRYPTO_RELEASE_RCD, (void (*)(void))release_crypto },
    { OSSL_FUNC_SSL_QUIC_TLS_YIELD_SECRET, (void (*)(void))yield_secret },
    { OSSL_FUNC_SSL_QUIC_TLS_GOT_TRANSPORT_PARAMS, (void (*)(void))peer_parameters },
    { OSSL_FUNC_SSL_QUIC_TLS_ALERT, (void (*)(void))alert },
    { 0, NULL }
};
int main(int argc, char **argv) {
    static const unsigned char params[] = {15, 0}; /* Empty local source CID, test only. */
    static const unsigned char alpn[] = {10, 'q','u','i','c','-','p','r','o','b','e'};
    struct probe p = {0};
    SSL_CTX *ctx = NULL;
    SSL *ssl = NULL;
    int registered = 0, first_error = 0, last_error = 0, result = 0, passed = 0;
    int blocked = 0, fatal = 0;
    size_t first_bytes = 0, encoded_length = 0;
    if (argc != 3) return 2;
    blocked = strcmp(argv[1], "backpressure") == 0;
    fatal = strcmp(argv[1], "fatal-send") == 0;
    if (!blocked && !fatal && strcmp(argv[1], "full") != 0) return 2;
    p.budget = blocked ? 17 : sizeof p.bytes;
    p.fail_send = fatal;
    ctx = SSL_CTX_new(TLS_method());
    if (!ctx) goto finish;
    if (!SSL_CTX_set_min_proto_version(ctx, TLS1_3_VERSION) ||
        !SSL_CTX_set_max_proto_version(ctx, TLS1_3_VERSION) ||
        !SSL_CTX_set_ciphersuites(ctx, "TLS_AES_128_GCM_SHA256") ||
        !SSL_CTX_set1_groups_list(ctx, "X25519") ||
        !SSL_CTX_load_verify_locations(ctx, argv[2], NULL)) goto finish;
    SSL_CTX_set_verify(ctx, SSL_VERIFY_PEER, NULL);
    ssl = SSL_new(ctx);
    if (!ssl) goto finish;
    SSL_set_connect_state(ssl);
    if (!SSL_set1_host(ssl, "localhost") || !SSL_set_tlsext_host_name(ssl, "localhost") ||
        SSL_set_alpn_protos(ssl, alpn, sizeof alpn) != 0) goto finish;
    registered = SSL_set_quic_tls_cbs(ssl, callbacks, &p);
    if (!registered || !SSL_set_quic_tls_transport_params(ssl, params, sizeof params) ||
        !SSL_set_quic_tls_early_data_enabled(ssl, 0)) goto finish;
    ERR_clear_error();
    result = SSL_do_handshake(ssl);
    first_error = SSL_get_error(ssl, result);
    first_bytes = p.length;
    last_error = first_error;
    if (blocked && first_error == SSL_ERROR_WANT_WRITE) {
        p.budget = sizeof p.bytes - p.length;
        ERR_clear_error();
        result = SSL_do_handshake(ssl);
        last_error = SSL_get_error(ssl, result);
    }
    if (p.length >= 4)
        encoded_length = 4 + ((size_t)p.bytes[1] << 16) + ((size_t)p.bytes[2] << 8) + p.bytes[3];
    passed = registered && !SSL_is_init_finished(ssl) && p.secrets == 0 && p.parameters == 0;
    if (fatal) passed = passed && first_error == SSL_ERROR_SSL && p.length == 0;
    else passed = passed && last_error == SSL_ERROR_WANT_READ && p.length > 4 &&
                  p.bytes[0] == 1 && encoded_length == p.length && p.receives > 0 &&
                  (!blocked || (first_error == SSL_ERROR_WANT_WRITE && first_bytes == 17));
finish:
    printf("{\"case\":\"%s\",\"passed\":%s,\"registered\":%d,"
           "\"first_ssl_error\":%d,\"last_ssl_error\":%d,\"first_bytes\":%zu,"
           "\"handshake_bytes\":%zu,\"send_callbacks\":%zu,\"receive_callbacks\":%zu,"
           "\"release_callbacks\":%zu,\"secret_callbacks\":%zu,\"parameter_callbacks\":%zu,"
           "\"alert_callbacks\":%zu,\"handshake_complete\":%s,\"peer_authenticated\":false}\n",
           argv[1], passed ? "true" : "false", registered, first_error, last_error,
           first_bytes, p.length, p.sends, p.receives, p.releases, p.secrets, p.parameters,
           p.alerts, ssl && SSL_is_init_finished(ssl) ? "true" : "false");
    if (!passed) ERR_print_errors_fp(stderr);
    SSL_free(ssl);
    SSL_CTX_free(ctx);
    return passed ? 0 : 1;
}
