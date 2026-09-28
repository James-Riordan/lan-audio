/* Engineering contract (2026-09-26)
 * Small OpenSSL records adapter owning SSL_CTX, SSL, paired BIOs and immutable pending write data.
 * File contract: docs/reference/files/src/backend.c.md
 * Ownership and invariant: Clear the OpenSSL error queue before a TLS operation and classify its
 * result immediately. TLS 1.3 only; explicit trust, SAN checking, single owned ALPN, no early-data
 * API. Two 32 KiB BIO buffers and one 16 KiB write block do not cap all provider allocation.
 * Shutdown preserves unread plaintext with peek and retries blocked alerts.
 * Next implementation obligation: Keep QUIC callbacks in a separate backend translation unit after
 * capability probing. Add provider initialization failure injection, time_t range handling and
 * allocation accounting. Review environment/provider loading policy before deployment. The C ABI
 * is internal; its constructors do not replicate all public Zig Config validation.
 * Verification: tests/transport.zig, tests/driver.zig
 */

#include "backend.h"
#include <openssl/ssl.h>
#include <openssl/err.h>
#include <openssl/x509v3.h>
#include <string.h>

struct tz_engine {
    SSL_CTX *ctx;
    SSL *ssl;
    BIO *wire;
    int ready, failed, closing, close_sent, eof, alert;
    long verify_error;
    unsigned long reason;
    size_t pending;
    unsigned char protocol[256]; /* length prefix plus one owned ALPN identifier */
    unsigned char write_buf[16384];
};
static int no_password(char *buf, int size, int writing, void *arg) {
    (void)buf; (void)size; (void)writing; (void)arg;
    return 0; /* Encrypted keys fail instead of prompting on the host's console. */
}
static int select_alpn(SSL *s, const unsigned char **out, unsigned char *len,
                       const unsigned char *in, unsigned int n, void *arg) {
    tz_engine *e = arg;
    (void)s;
    if (SSL_select_next_proto((unsigned char **)out, len, e->protocol, (unsigned)e->protocol[0] + 1, in, n)
        != OPENSSL_NPN_NEGOTIATED) return SSL_TLSEXT_ERR_ALERT_FATAL;
    return SSL_TLSEXT_ERR_OK;
}
static void info(const SSL *s, int where, int ret) {
    tz_engine *e = SSL_get_app_data(s);
    if (e && (where & SSL_CB_ALERT) && (where & SSL_CB_READ)) e->alert = ret & 255;
}
static int result(tz_engine *e, int r) {
    int err = SSL_get_error(e->ssl, r); /* Must precede every other OpenSSL call. */
    if (err == SSL_ERROR_WANT_READ) return 1;
    if (err == SSL_ERROR_WANT_WRITE) return 2;
    if (err == SSL_ERROR_ZERO_RETURN) return 3;
    e->verify_error = SSL_get_verify_result(e->ssl);
    e->reason = ERR_peek_last_error();
    e->failed = 1;
    return e->verify_error != X509_V_OK ||
        ERR_GET_REASON(e->reason) == SSL_R_PEER_DID_NOT_RETURN_A_CERTIFICATE ? -2 : -1;
}
tz_engine *tz_new(int server, const char *ca, const char *cert, const char *key,
                  const char *peer, int ip, int require_client, int64_t wall_time) {
    static const unsigned char http[] = "http/1.1";
    return tz_new_with_alpn(server, ca, cert, key, peer, ip, require_client,
                            wall_time, http, sizeof http - 1);
}
tz_engine *tz_new_with_alpn(int server, const char *ca, const char *cert, const char *key,
                  const char *peer, int ip, int require_client, int64_t wall_time,
                  const unsigned char *protocol, size_t protocol_length) {
    if (!protocol || protocol_length == 0 || protocol_length > 255) return NULL;
    tz_engine *e = OPENSSL_zalloc(sizeof *e);
    BIO *internal = NULL;
    if (!e) return NULL;
    e->protocol[0] = (unsigned char)protocol_length;
    memcpy(e->protocol + 1, protocol, protocol_length);
    e->alert = -1;
    ERR_clear_error();
    e->ctx = SSL_CTX_new(TLS_method());
    if (!e->ctx) goto fail;
    SSL_CTX_set_default_passwd_cb(e->ctx, no_password);
    if (!SSL_CTX_set_min_proto_version(e->ctx, TLS1_3_VERSION) ||
        !SSL_CTX_set_max_proto_version(e->ctx, TLS1_3_VERSION)) goto fail;
    SSL_CTX_set_options(e->ctx, SSL_OP_NO_TICKET | SSL_OP_NO_RENEGOTIATION);
    SSL_CTX_clear_options(e->ctx, SSL_OP_IGNORE_UNEXPECTED_EOF);
    SSL_CTX_clear_mode(e->ctx, SSL_MODE_ENABLE_PARTIAL_WRITE | SSL_MODE_ACCEPT_MOVING_WRITE_BUFFER);
    SSL_CTX_set_post_handshake_auth(e->ctx, 0);
    SSL_CTX_set_session_cache_mode(e->ctx, SSL_SESS_CACHE_OFF);
    if (!SSL_CTX_set_num_tickets(e->ctx, 0) || !SSL_CTX_set_max_early_data(e->ctx, 0)) goto fail;
    SSL_CTX_set_max_cert_list(e->ctx, 65536);
    SSL_CTX_set_verify_depth(e->ctx, 8);
    SSL_CTX_set_security_level(e->ctx, 2);
    if (!server || require_client) {
        if (!ca || !SSL_CTX_load_verify_locations(e->ctx, ca, NULL)) goto fail;
        SSL_CTX_set_verify(e->ctx, SSL_VERIFY_PEER | (server ? SSL_VERIFY_FAIL_IF_NO_PEER_CERT : 0), NULL);
    }
    if (server || cert) {
        if (!cert || !key || !SSL_CTX_use_certificate_chain_file(e->ctx, cert) ||
            !SSL_CTX_use_PrivateKey_file(e->ctx, key, SSL_FILETYPE_PEM) ||
            !SSL_CTX_check_private_key(e->ctx)) goto fail;
    }
    if (server) SSL_CTX_set_alpn_select_cb(e->ctx, select_alpn, e);
    e->ssl = SSL_new(e->ctx);
    if (!e->ssl) goto fail;
    SSL_set_app_data(e->ssl, e);
    SSL_set_info_callback(e->ssl, info);
    X509_VERIFY_PARAM *param = SSL_get0_param(e->ssl);
    X509_VERIFY_PARAM_set_time(param, (time_t)wall_time);
    if (!X509_VERIFY_PARAM_set_flags(param, X509_V_FLAG_X509_STRICT | X509_V_FLAG_TRUSTED_FIRST)) goto fail;
    if (!server) {
        if (!peer || !*peer) goto fail;
        SSL_set_hostflags(e->ssl, X509_CHECK_FLAG_NO_PARTIAL_WILDCARDS | X509_CHECK_FLAG_NEVER_CHECK_SUBJECT);
        if (ip) {
            if (!X509_VERIFY_PARAM_set1_ip_asc(param, peer)) goto fail;
        } else if (!SSL_set1_host(e->ssl, peer) || !SSL_set_tlsext_host_name(e->ssl, peer)) goto fail;
        if (SSL_set_alpn_protos(e->ssl, e->protocol, (unsigned)e->protocol[0] + 1) != 0) goto fail;
        SSL_set_connect_state(e->ssl);
    } else SSL_set_accept_state(e->ssl);
    /* Both directions have fixed capacity. OpenSSL's other allocations are NOT capped. */
    if (!BIO_new_bio_pair(&internal, 32768, &e->wire, 32768)) goto fail;
    SSL_set_bio(e->ssl, internal, internal);
    return e;
fail:
    tz_free(e);
    return NULL;
}
void tz_free(tz_engine *e) {
    if (!e) return;
    SSL_free(e->ssl);
    BIO_free(e->wire);
    SSL_CTX_free(e->ctx);
    OPENSSL_clear_free(e, sizeof *e);
}
int tz_handshake(tz_engine *e) {
    if (e->failed || e->closing) return -4;
    if (e->ready) return 0;
    ERR_clear_error();
    int r = SSL_do_handshake(e->ssl);
    if (r != 1) return result(e, r);
    const unsigned char *selected;
    unsigned int n;
    SSL_get0_alpn_selected(e->ssl, &selected, &n);
    if (n != e->protocol[0] || memcmp(selected, e->protocol + 1, n)) { e->failed = 1; return -3; }
    e->ready = 1;
    return 0;
}
int tz_feed(tz_engine *e, const unsigned char *p, size_t n, size_t *used) {
    *used = 0;
    if (e->failed || e->eof) return -4;
    if (!n) return 0;
    if (n > 16384) n = 16384;
    int r = BIO_write(e->wire, p, (int)n);
    if (r <= 0) return BIO_should_retry(e->wire) ? 4 : -1;
    *used = (size_t)r;
    return 0;
}
int tz_drain(tz_engine *e, unsigned char *p, size_t n, size_t *used) {
    *used = 0;
    if (!n) return 0;
    if (n > 16384) n = 16384;
    int r = BIO_read(e->wire, p, (int)n);
    if (r <= 0) return BIO_should_retry(e->wire) ? 1 : 0;
    *used = (size_t)r;
    return 0;
}
int tz_read(tz_engine *e, unsigned char *p, size_t n, size_t *used) {
    *used = 0;
    if (!e->ready || e->failed || e->pending || !n) return -4;
    if (n > 16384) n = 16384;
    ERR_clear_error();
    int r = SSL_read_ex(e->ssl, p, n, used);
    return r == 1 ? 0 : result(e, r);
}
int tz_write(tz_engine *e, const unsigned char *p, size_t n) {
    if (!e->ready || e->failed || e->closing || e->pending || !n || n > sizeof e->write_buf) return -4;
    memcpy(e->write_buf, p, n);
    e->pending = n;
    return 0;
}
int tz_flush(tz_engine *e) {
    if (!e->ready || e->failed) return -4;
    if (!e->pending) return 0;
    size_t n;
    ERR_clear_error();
    int r = SSL_write_ex(e->ssl, e->write_buf, e->pending, &n);
    if (r != 1) return result(e, r);
    OPENSSL_cleanse(e->write_buf, e->pending);
    e->pending = 0;
    return 0;
}
int tz_shutdown(tz_engine *e) {
    if (!e->ready || e->failed || e->pending) return -4;
    e->closing = 1;
    ERR_clear_error();
    if (e->close_sent) {
        /* SSL_shutdown would fail on unread application data. Peek preserves it
         * for the host and processes close_notify only after that data is read. */
        unsigned char byte;
        size_t n;
        int r = SSL_peek_ex(e->ssl, &byte, 1, &n);
        return r == 1 ? 5 : result(e, r);
    }
    int r = SSL_shutdown(e->ssl);
    /* SSL_SENT_SHUTDOWN alone is insufficient: it is set before a blocked alert
     * has been written. Retry SSL_shutdown on WANT_WRITE until it returns >= 0. */
    if (r >= 0) e->close_sent = 1;
    if (r == 1) return 3;
    if (r == 0) return 1;
    return result(e, r);
}
int tz_eof(tz_engine *e) {
    if (e->failed || e->eof) return -4;
    e->eof = 1;
    return BIO_shutdown_wr(e->wire) == 1 ? 0 : -1;
}
long tz_verify_error(tz_engine *e) { return e->verify_error; }
unsigned long tz_reason(tz_engine *e) { return e->reason; }
int tz_alert(tz_engine *e) { return e->alert; }
int tz_verified_peer_leaf_sha256(tz_engine *e, unsigned char *out, size_t capacity) {
    /* X509_V_OK alone also occurs without a peer certificate or verification. */
    if (!e || !out || capacity < 32) return -4;
    if (!e->ready || e->failed || e->closing || e->eof ||
        !SSL_is_init_finished(e->ssl) || SSL_get_shutdown(e->ssl) != 0 ||
        !(SSL_get_verify_mode(e->ssl) & SSL_VERIFY_PEER) ||
        SSL_get_verify_result(e->ssl) != X509_V_OK) return -4;
    X509 *peer = SSL_get0_peer_certificate(e->ssl);
    if (!peer) return -4;
    unsigned char digest[EVP_MAX_MD_SIZE];
    unsigned int length = 0;
    /* No SSL operation is pending classification; subsequent operations clear
     * the provider error queue. Query failure does not poison the connection. */
    int ok = X509_digest(peer, EVP_sha256(), digest, &length) == 1 && length == 32;
    if (ok) memcpy(out, digest, 32);
    OPENSSL_cleanse(digest, sizeof digest);
    return ok ? 0 : -1;
}
const char *tz_version(void) { return OpenSSL_version(OPENSSL_VERSION); }
