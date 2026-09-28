/* Offline provider experiment, not the production QUIC backend.
 * Contract: docs/reference/files/tools/probe-quic-pair.c.md.
 * Fixed append-only queues keep every input lease stable through SSL_free.
 * Secret bytes are compared in memory, never serialized, then cleansed.
 */
#include <openssl/ssl.h>
#include <openssl/err.h>
#include <openssl/core_dispatch.h>
#include <openssl/x509v3.h>
#include <stdio.h>
#include <string.h>

#define CAP 65536
#define TICKS 10000
struct queue { unsigned char data[CAP]; size_t used, retired; };
struct peer {
    SSL_CTX *ctx; SSL *ssl; struct peer *other;
    struct queue input[4];
    unsigned char secrets[4][2][32]; unsigned char seen[4][2];
    size_t lease_length, lease_offset; unsigned lease_level;
    unsigned read_level, write_level;
    size_t budget, quantum, fragment, sends, receives, leases, releases, released_bytes;
    size_t params, alerts, calls, callbacks, call_callbacks, max_callbacks, blocked, tickets;
    size_t secret_calls, injected, release_failures, teardown_releases;
    size_t input_budget, input_quantum, call_controls, max_controls, budget_pauses;
    int tearing_down;
    int id, invariant, failure, done, alert_code, fail_kind, alpn_bad;
    long verify_result;
};
static const unsigned char protocol[] = {10,'q','u','i','c','-','p','r','o','b','e'};
static const unsigned char parameters[2][3] = {{15,1,0x11},{15,1,0x22}};

static int observe(struct peer *p, int kind) {
    ++p->callbacks; ++p->call_callbacks;
    if (kind>=4 && kind<=6) ++p->call_controls;
    if (kind && p->fail_kind == kind) { ++p->injected; return 0; }
    return 1;
}
static int send_crypto(SSL *ssl, const unsigned char *data, size_t length, size_t *consumed, void *arg) {
    struct peer *p=arg; struct queue *q=&p->other->input[p->write_level];
    size_t n=length < p->budget ? length : p->budget;
    (void)ssl; ++p->sends; *consumed=0;
    if (!observe(p,1)) return 0;
    if (n>CAP-q->used) { p->invariant=1; return 0; }
    if (n) memcpy(q->data+q->used,data,n);
    q->used+=n; p->budget-=n; *consumed=n;
    return 1;
}
static int receive_crypto(SSL *ssl, const unsigned char **data, size_t *length, void *arg) {
    struct peer *p=arg; struct queue *q=&p->input[p->read_level]; size_t n;
    (void)ssl; ++p->receives; *data=NULL; *length=0;
    if (p->lease_length) { p->invariant=1; return 0; }
    n=q->used-q->retired;
    if (n && !p->input_budget) ++p->budget_pauses;
    if (n>p->input_budget) n=p->input_budget;
    if (!observe(p,n ? 2 : 0)) return 0;
    if (!n) return 1;
    if (n>p->fragment) n=p->fragment;
    p->input_budget-=n;
    p->lease_length=n; p->lease_offset=q->retired; p->lease_level=p->read_level;
    ++p->leases; *data=q->data+q->retired; *length=n;
    return 1;
}
static int release_crypto(SSL *ssl, size_t length, void *arg) {
    struct peer *p=arg; struct queue *q=&p->input[p->lease_level];
    (void)ssl; ++p->releases;
    if (p->tearing_down) ++p->teardown_releases;
    if (!p->lease_length || length!=p->lease_length || q->retired!=p->lease_offset) {
        p->invariant=1; return 0;
    }
    /* A rejected release has not committed retirement; SSL_free may retry it. */
    if (!observe(p,p->release_failures ? 0 : 3)) { ++p->release_failures; return 0; }
    q->retired+=length; p->released_bytes+=length; p->lease_length=0;
    return 1;
}
static int yield_secret(SSL *ssl, uint32_t level, int direction, const unsigned char *secret, size_t length, void *arg) {
    struct peer *p=arg; (void)ssl; ++p->secret_calls;
    if (!observe(p,4)) return 0;
    if ((level!=2 && level!=3) || (direction!=0 && direction!=1) || length!=32 || p->seen[level][direction]) {
        p->invariant=1; return 0;
    }
    memcpy(p->secrets[level][direction],secret,length); p->seen[level][direction]=1;
    if (direction) p->write_level=level; else p->read_level=level;
    return 1;
}
static int peer_parameters(SSL *ssl, const unsigned char *params, size_t length, void *arg) {
    struct peer *p=arg; (void)ssl; ++p->params;
    if (!observe(p,5)) return 0;
    if (p->params!=1 || length!=sizeof parameters[0] || memcmp(params,parameters[1-p->id],length)) {
        p->invariant=1; return 0;
    }
    return 1;
}
static int alert(SSL *ssl, unsigned char code, void *arg) {
    struct peer *p=arg; (void)ssl; ++p->alerts; p->alert_code=code;
    return observe(p,6);
}
static int select_alpn(SSL *ssl, const unsigned char **out, unsigned char *length, const unsigned char *in, unsigned int n, void *arg) {
    struct peer *p=arg; (void)ssl;
    if (p->alpn_bad || SSL_select_next_proto((unsigned char **)out,length,protocol,sizeof protocol,in,n)!=OPENSSL_NPN_NEGOTIATED)
        return SSL_TLSEXT_ERR_ALERT_FATAL;
    return SSL_TLSEXT_ERR_OK;
}
static int new_session(SSL *ssl, SSL_SESSION *session) {
    struct peer *p=SSL_get_app_data(ssl); (void)session;
    ++p->tickets; return 0; /* Keep no application reference to a provider session. */
}
static int no_password(char *buf, int size, int writing, void *arg) {
    (void)buf; (void)size; (void)writing; (void)arg; return 0;
}
static const OSSL_DISPATCH callbacks[] = {
    {OSSL_FUNC_SSL_QUIC_TLS_CRYPTO_SEND,(void (*)(void))send_crypto},
    {OSSL_FUNC_SSL_QUIC_TLS_CRYPTO_RECV_RCD,(void (*)(void))receive_crypto},
    {OSSL_FUNC_SSL_QUIC_TLS_CRYPTO_RELEASE_RCD,(void (*)(void))release_crypto},
    {OSSL_FUNC_SSL_QUIC_TLS_YIELD_SECRET,(void (*)(void))yield_secret},
    {OSSL_FUNC_SSL_QUIC_TLS_GOT_TRANSPORT_PARAMS,(void (*)(void))peer_parameters},
    {OSSL_FUNC_SSL_QUIC_TLS_ALERT,(void (*)(void))alert}, {0,NULL}
};
static int setup(struct peer *p, const char *fixtures, const char *scenario) {
    char ca[4096],cert[4096],key[4096]; int tickets=!strcmp(scenario,"tickets");
    int mtls=!strcmp(scenario,"mutual") || !strcmp(scenario,"missing-client");
    int count;
    count=snprintf(ca,sizeof ca,"%s/%s",fixtures,(!p->id && !strcmp(scenario,"wrong-ca")) ? "other-ca.pem" : "ca.pem");
    if (count<0 || (size_t)count>=sizeof ca) return 0;
    count=snprintf(cert,sizeof cert,"%s/%s.pem",fixtures,p->id ? "server" : "client");
    if (count<0 || (size_t)count>=sizeof cert) return 0;
    count=snprintf(key,sizeof key,"%s/%s.key",fixtures,p->id ? "server" : "client");
    if (count<0 || (size_t)count>=sizeof key) return 0;
    p->ctx=SSL_CTX_new(TLS_method()); if (!p->ctx) return 0;
    SSL_CTX_set_default_passwd_cb(p->ctx,no_password);
    if (!SSL_CTX_set_min_proto_version(p->ctx,TLS1_3_VERSION) || !SSL_CTX_set_max_proto_version(p->ctx,TLS1_3_VERSION) ||
        !SSL_CTX_set_ciphersuites(p->ctx,"TLS_AES_128_GCM_SHA256") || !SSL_CTX_set1_groups_list(p->ctx,"X25519") ||
        !SSL_CTX_load_verify_locations(p->ctx,ca,NULL) || !SSL_CTX_set_num_tickets(p->ctx,tickets ? 1 : 0)) return 0;
    SSL_CTX_set_verify(p->ctx,(!p->id || mtls) ? SSL_VERIFY_PEER | (p->id ? SSL_VERIFY_FAIL_IF_NO_PEER_CERT : 0) : SSL_VERIFY_NONE,NULL);
    if (p->id || !strcmp(scenario,"mutual")) {
        if (!SSL_CTX_use_certificate_chain_file(p->ctx,cert) || !SSL_CTX_use_PrivateKey_file(p->ctx,key,SSL_FILETYPE_PEM) ||
            !SSL_CTX_check_private_key(p->ctx)) return 0;
    }
    if (p->id) SSL_CTX_set_alpn_select_cb(p->ctx,select_alpn,p);
    SSL_CTX_set_session_cache_mode(p->ctx,p->id ? SSL_SESS_CACHE_SERVER : SSL_SESS_CACHE_CLIENT);
    SSL_CTX_sess_set_new_cb(p->ctx,new_session);
    p->ssl=SSL_new(p->ctx); if (!p->ssl) return 0;
    SSL_set_app_data(p->ssl,p);
    /* Deterministic test-fixture time only: 2026-09-26 12:00:00 UTC. */
    X509_VERIFY_PARAM_set_time(SSL_get0_param(p->ssl),(time_t)1790424000);
    if (!X509_VERIFY_PARAM_set_flags(SSL_get0_param(p->ssl),X509_V_FLAG_X509_STRICT | X509_V_FLAG_TRUSTED_FIRST)) return 0;
    if (p->id) SSL_set_accept_state(p->ssl);
    else {
        SSL_set_connect_state(p->ssl);
        SSL_set_hostflags(p->ssl,X509_CHECK_FLAG_NO_PARTIAL_WILDCARDS | X509_CHECK_FLAG_NEVER_CHECK_SUBJECT);
        if (!SSL_set1_host(p->ssl,!strcmp(scenario,"wrong-host") || !strcmp(scenario,"fail-alert") ? "mismatch.invalid" : "localhost") ||
            !SSL_set_tlsext_host_name(p->ssl,"localhost") || SSL_set_alpn_protos(p->ssl,protocol,sizeof protocol)) return 0;
    }
    return SSL_set_quic_tls_cbs(p->ssl,callbacks,p) && SSL_set_quic_tls_transport_params(p->ssl,parameters[p->id],sizeof parameters[0]) &&
           SSL_set_quic_tls_early_data_enabled(p->ssl,0);
}
static void step(struct peer *p, int post_handshake) {
    int result,error; unsigned char ignored; size_t received=0;
    p->budget=p->quantum; p->input_budget=p->input_quantum; p->call_callbacks=0; p->call_controls=0; ++p->calls;
    ERR_clear_error();
    result=post_handshake ? SSL_read_ex(p->ssl,&ignored,0,&received) : SSL_do_handshake(p->ssl);
    error=SSL_get_error(p->ssl,result);
    if (p->call_callbacks>p->max_callbacks) p->max_callbacks=p->call_callbacks;
    if (p->call_controls>p->max_controls) p->max_controls=p->call_controls;
    if (error==SSL_ERROR_WANT_WRITE) ++p->blocked;
    if (error!=SSL_ERROR_NONE && error!=SSL_ERROR_WANT_READ && error!=SSL_ERROR_WANT_WRITE) {
        p->failure=error; p->verify_result=SSL_get_verify_result(p->ssl);
    }
    p->done=SSL_is_init_finished(p->ssl);
}
static int successful_pair(struct peer *c, struct peer *s, int mtls) {
    unsigned level,direction; const unsigned char *alpn; unsigned int n; X509 *cert;
    if (!c->done || !s->done || c->failure || s->failure || c->params!=1 || s->params!=1) return 0;
    if (SSL_get_verify_result(c->ssl)!=X509_V_OK || (mtls && SSL_get_verify_result(s->ssl)!=X509_V_OK)) return 0;
    cert=SSL_get0_peer_certificate(c->ssl); if (!cert) return 0;
    if (mtls && !SSL_get0_peer_certificate(s->ssl)) return 0;
    for (level=2;level<=3;++level) for (direction=0;direction<=1;++direction)
        if (!c->seen[level][direction] || !s->seen[level][1-direction] ||
            CRYPTO_memcmp(c->secrets[level][direction],s->secrets[level][1-direction],32)) return 0;
    for (int i=0;i<2;++i) {
        struct peer *p=i ? s : c;
        SSL_get0_alpn_selected(p->ssl,&alpn,&n);
        if (n!=10 || memcmp(alpn,protocol+1,10) || p->lease_length || p->leases!=p->releases) return 0;
        for (level=0;level<4;++level) if (p->input[level].used!=p->input[level].retired) return 0;
    }
    return 1;
}
int main(int argc, char **argv) {
    static struct peer peers[2]; struct peer *c=&peers[0],*s=&peers[1];
    const char *names[]={"full","fragmented","backpressure","combined","mutual","missing-client","wrong-host","wrong-ca","alpn","fail-send","fail-receive","fail-release","fail-secret","fail-params","fail-alert","tickets","budgeted"};
    int chosen=-1,passed=0,authenticated=0,setup_ok=0; size_t tick=0;
    if (argc!=3) return 2;
    for (int i=0;i<17;++i) if (!strcmp(argv[1],names[i])) chosen=i;
    if (chosen<0) return 2;
    for (int i=0;i<2;++i) {
        struct peer *p=&peers[i]; p->id=i; p->other=&peers[1-i]; p->alert_code=-1;
        p->fragment=(chosen==1 || chosen==3 || chosen==16) ? 1 : CAP;
        p->quantum=(chosen==2 || chosen==3) ? 17 : CAP;
        p->input_quantum=chosen==16 ? 17 : CAP;
    }
    if (chosen>=9 && chosen<=13) s->fail_kind=chosen-8;
    if (chosen==14) c->fail_kind=6;
    s->alpn_bad=chosen==8;
    if (!setup(c,argv[2],argv[1]) || !setup(s,argv[2],argv[1])) goto finish;
    setup_ok=1;
    for (tick=0;tick<TICKS;++tick) {
        if (!c->done) step(c,0);
        if (c->failure) break;
        if (!s->done) step(s,0);
        if (s->failure || (c->done && s->done)) break;
    }
    if (chosen==15 && c->done && s->done) {
        for (size_t i=0;i<100 && !c->failure && (c->input[3].retired<c->input[3].used || c->lease_length);++i) step(c,1);
    }
    if (chosen<=4 || chosen>=15) {
        authenticated=successful_pair(c,s,chosen==4);
        passed=authenticated && (chosen!=15 || c->tickets==1) &&
               ((chosen!=2 && chosen!=3) || (c->blocked && s->blocked));
        if (chosen==16) passed=passed && c->budget_pauses && s->budget_pauses;
    } else if (chosen==6 || chosen==14)
        passed=c->failure==SSL_ERROR_SSL && c->verify_result==X509_V_ERR_HOSTNAME_MISMATCH && c->alerts &&
               (chosen!=14 || c->injected);
    else if (chosen==7)
        passed=c->failure==SSL_ERROR_SSL && c->alert_code==SSL_AD_UNKNOWN_CA &&
               (c->verify_result==X509_V_ERR_UNABLE_TO_GET_ISSUER_CERT_LOCALLY ||
                c->verify_result==X509_V_ERR_UNABLE_TO_VERIFY_LEAF_SIGNATURE || c->verify_result==X509_V_ERR_SELF_SIGNED_CERT_IN_CHAIN);
    else passed=s->failure==SSL_ERROR_SSL && (chosen<9 || s->injected) &&
                (chosen!=5 || s->alert_code==SSL_AD_CERTIFICATE_REQUIRED) && (chosen!=8 || s->alert_code==SSL_AD_NO_APPLICATION_PROTOCOL);
finish:
    /* Keep callback state and leased arrays alive during provider destruction. */
    for (int i=0;i<2;++i) { peers[i].tearing_down=1; SSL_free(peers[i].ssl); peers[i].ssl=NULL; SSL_CTX_free(peers[i].ctx); }
    passed=passed && setup_ok && tick<TICKS && !c->invariant && !s->invariant;
    if (chosen==11) passed=passed && s->release_failures==1 && s->teardown_releases==1 &&
        s->leases==1 && s->releases==2 && !s->lease_length;
    printf("{\"case\":\"%s\",\"passed\":%s,\"setup\":%s,\"authenticated_pair\":%s,\"ticks\":%zu,\"peers\":[",argv[1],passed ? "true":"false",setup_ok ? "true":"false",authenticated ? "true":"false",tick+1);
    for (int i=0;i<2;++i) {
        struct peer *p=&peers[i];
        printf("%s{\"release_failures\":%zu,\"teardown_releases\":%zu,",i ? ",":"",p->release_failures,p->teardown_releases);
        printf("\"max_control_callbacks_per_call\":%zu,\"input_budget_pauses\":%zu,",p->max_controls,p->budget_pauses);
        printf("\"role\":\"%s\",\"complete\":%s,\"ssl_error\":%d,\"verify_error\":%ld,\"leases\":%zu,\"releases\":%zu,\"released_bytes\":%zu,\"lease_remaining\":%zu,\"secret_callbacks\":%zu,\"parameter_callbacks\":%zu,\"alert\":%d,\"injected_failures\":%zu,\"max_callbacks_per_call\":%zu,\"blocked_calls\":%zu,\"tickets\":%zu,\"invariant_failure\":%s}",i ? "server":"client",p->done ? "true":"false",p->failure,p->verify_result,p->leases,p->releases,p->released_bytes,p->lease_length,p->secret_calls,p->params,p->alert_code,p->injected,p->max_callbacks,p->blocked,p->tickets,p->invariant ? "true":"false");
        OPENSSL_cleanse(p->secrets,sizeof p->secrets);
    }
    puts("]}");
    if (!passed) ERR_print_errors_fp(stderr);
    return passed ? 0 : 1;
}
