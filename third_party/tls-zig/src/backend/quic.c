/* OpenSSL external recordless TLS adapter. Contract: quic.h.
 * Host callbacks own transport/event storage; this adapter owns SSL and copies
 * configuration retained by SSL. No record BIO, sockets or application payloads.
 */
#include "quic.h"
#include <openssl/ssl.h>
#include <openssl/err.h>
#include <openssl/core_dispatch.h>
#include <openssl/x509v3.h>
#include <limits.h>
#include <string.h>
#include <time.h>

_Static_assert(sizeof(uint32_t)==4 && sizeof(int64_t)==8, "fixed ABI widths");
struct tlsq_provider {
    SSL_CTX *ctx;
    SSL *ssl;
    tlsq_callbacks callbacks;
    unsigned char alpn[256];
    size_t alpn_length;
    unsigned char *parameters;
    size_t parameters_length, peer_parameter_limit;
    tlsq_bytes lease;
    size_t input_budget, output_budget, input_delivered, output_accepted;
    uint32_t read_level, write_level, lease_level, role, require_client;
    uint32_t busy, closed, terminal, callback_failed, local_pause, output_pause;
    uint32_t parameters_seen, seen[3][2], alert_code, peer_authentication;
};
static int qualified_target(void) {
#if defined(_WIN32) && (defined(__x86_64__) || defined(_M_X64))
    return sizeof(void *)==8 && sizeof(time_t)==8;
#else
    return 0;
#endif
}
uint32_t tlsq_query(uint32_t version, tlsq_capabilities *out) {
    tlsq_capabilities value;
    if (version!=TLSQ_ABI_VERSION || !out) return TLSQ_INVALID;
    value.abi_version=TLSQ_ABI_VERSION;
    value.compiled_recordless=1;
    value.qualified_target=(uint32_t)qualified_target();
    value.runtime_available=value.qualified_target && OpenSSL_version_num()==OPENSSL_VERSION_NUMBER;
    *out=value;
    return TLSQ_OK;
}
static int bytes_valid(tlsq_bytes b) { return b.length==0 || b.data!=NULL; }
static int text_valid(tlsq_bytes b, int required) {
    return bytes_valid(b) && (!required || b.length) && b.length<SIZE_MAX &&
        (!b.length || memchr(b.data,0,b.length)==NULL);
}
static int dns_valid(tlsq_bytes b) {
    size_t start=0;
    if (!b.length || b.length>253) return 0;
    for (size_t i=0;i<=b.length;++i) {
        unsigned char ch=i<b.length ? b.data[i] : '.';
        if (ch=='.') {
            if (i==start || i-start>63 || b.data[start]=='-' || b.data[i-1]=='-') return 0;
            start=i+1;
        } else if (!((ch>='a' && ch<='z') || (ch>='A' && ch<='Z') ||
                     (ch>='0' && ch<='9') || ch=='-')) return 0;
    }
    return 1;
}
static int ipv4_valid(const unsigned char *s,size_t n) {
    size_t i=0;
    for (unsigned part=0;part<4;++part) {
        size_t start=i;unsigned value=0;
        while (i<n && s[i]>='0' && s[i]<='9') {
            if (i-start==3) return 0;
            value=value*10u+(unsigned)(s[i++]-'0');
        }
        if (i==start || value>255 || (i-start>1 && s[start]=='0')) return 0;
        if (part==3) return i==n;
        if (i==n || s[i++]!='.') return 0;
    }
    return 0;
}
static int ip_valid(tlsq_bytes b) {
    size_t i=0;unsigned groups=0,compressed=0;
    if (!memchr(b.data,':',b.length)) return ipv4_valid(b.data,b.length);
    if (b.data[0]==':') {
        if (b.length<2 || b.data[1]!=':') return 0;
        compressed=1;i=2;
    }
    while (i<b.length) {
        size_t start=i;
        while (i<b.length && ((b.data[i]>='0' && b.data[i]<='9') ||
            (b.data[i]>='a' && b.data[i]<='f') || (b.data[i]>='A' && b.data[i]<='F'))) ++i;
        if (i<b.length && b.data[i]=='.') {
            if (!ipv4_valid(b.data+start,b.length-start)) return 0;
            groups+=2;i=b.length;break;
        }
        if (i==start || i-start>4 || ++groups>8) return 0;
        if (i==b.length) break;
        if (b.data[i++]!=':' || i==b.length) return 0;
        if (b.data[i]==':') {
            if (compressed) return 0;
            compressed=1;++i;
        }
    }
    return compressed ? groups<8:groups==8;
}
uint32_t tlsq_validate(const tlsq_config *c, const tlsq_callbacks *cb) {
    if (!c || !cb || c->abi_version!=TLSQ_ABI_VERSION || cb->abi_version!=TLSQ_ABI_VERSION ||
        c->role>TLSQ_SERVER || c->identity_kind>TLSQ_IP || c->require_client_certificate>1 ||
        !cb->send || !cb->receive || !cb->release || !cb->secret || !cb->parameters || !cb->alert ||
        c->wall_time_seconds<=0 || (int64_t)(time_t)c->wall_time_seconds!=c->wall_time_seconds ||
        !text_valid(c->trust_file, c->role==TLSQ_CLIENT || c->require_client_certificate) ||
        !text_valid(c->certificate_file,c->role==TLSQ_SERVER) ||
        !text_valid(c->private_key_file,c->role==TLSQ_SERVER) ||
        (!c->certificate_file.length != !c->private_key_file.length) ||
        !text_valid(c->identity,c->role==TLSQ_CLIENT) ||
        !bytes_valid(c->alpn) || !c->alpn.length || c->alpn.length>255 ||
        !bytes_valid(c->local_parameters) || !c->peer_parameter_limit ||
        c->local_parameters.length>c->peer_parameter_limit) return TLSQ_INVALID;
    if (c->role==TLSQ_SERVER) {
        if (c->identity.length || c->identity_kind!=TLSQ_DNS ||
            (!c->require_client_certificate && c->trust_file.length)) return TLSQ_INVALID;
    } else {
        if (c->require_client_certificate || c->identity.length>253) return TLSQ_INVALID;
        if (c->identity_kind==TLSQ_DNS) {
            if (!dns_valid(c->identity)) return TLSQ_INVALID;
        } else if (!ip_valid(c->identity)) return TLSQ_INVALID;
    }
    return TLSQ_OK;
}
static int fail_callback(tlsq_provider *p) { p->callback_failed=1;p->terminal=1;return 0; }
static int send_crypto(SSL *ssl,const unsigned char *data,size_t length,size_t *consumed,void *arg) {
    tlsq_provider *p=arg;size_t accepted=0,n=length<p->output_budget ? length:p->output_budget;
    tlsq_bytes bytes={data,n};(void)ssl;*consumed=0;
    if (p->terminal) return 0;
    if (length && !n) { p->output_pause=1;return 1; }
    if (p->callbacks.send(p->callbacks.context,p->write_level,bytes,&accepted)!=1 || accepted>n)
        return fail_callback(p);
    p->output_budget-=accepted;p->output_accepted+=accepted;*consumed=accepted;
    if (accepted<length) p->output_pause=1;
    return 1;
}
static int receive_crypto(SSL *ssl,const unsigned char **data,size_t *length,void *arg) {
    tlsq_provider *p=arg;tlsq_bytes bytes={NULL,0};(void)ssl;*data=NULL;*length=0;
    if (p->terminal) return 0;
    if (p->lease.length) return fail_callback(p);
    if (!p->input_budget) { p->local_pause=1;return 1; }
    if (p->callbacks.receive(p->callbacks.context,p->read_level,p->input_budget,&bytes)!=1 ||
        !bytes_valid(bytes) || bytes.length>p->input_budget) return fail_callback(p);
    if (!bytes.length) return 1;
    p->lease=bytes;p->lease_level=p->read_level;p->input_budget-=bytes.length;
    p->input_delivered+=bytes.length;*data=bytes.data;*length=bytes.length;
    return 1;
}
static int release_crypto(SSL *ssl,size_t length,void *arg) {
    tlsq_provider *p=arg;(void)ssl;
    if (!length || length!=p->lease.length) return fail_callback(p);
    /* Even terminal connections can receive a matching retry during SSL_free. */
    if (p->callbacks.release(p->callbacks.context,p->lease_level,p->lease)!=1) return fail_callback(p);
    p->lease.data=NULL;p->lease.length=0;
    return 1;
}
static int secret_valid(uint32_t level,uint32_t direction,tlsq_bytes bytes) {
    return (level==TLSQ_HANDSHAKE || level==TLSQ_APPLICATION) && direction<=TLSQ_WRITE &&
        bytes.data && bytes.length==32;
}
static int deliver_secret(tlsq_provider *p,uint32_t level,uint32_t direction,tlsq_bytes bytes) {
    if (p->terminal) return 0;
    if (!secret_valid(level,direction,bytes) || p->seen[level][direction]) return fail_callback(p);
    if (p->callbacks.secret(p->callbacks.context,level,direction,TLSQ_AES128GCM_SHA256,bytes)!=1)
        return fail_callback(p);
    p->seen[level][direction]=1;
    if (direction==TLSQ_WRITE) p->write_level=level;else p->read_level=level;
    return 1;
}
static int yield_secret(SSL *ssl,uint32_t level,int direction,const unsigned char *secret,size_t length,void *arg) {
    tlsq_provider *p=arg;tlsq_bytes bytes={secret,length};const SSL_CIPHER *cipher=SSL_get_current_cipher(ssl);
    if ((level!=2 && level!=3) || (direction!=0 && direction!=1) || !cipher ||
        SSL_CIPHER_get_protocol_id(cipher)!=TLSQ_AES128GCM_SHA256) return fail_callback(p);
    return deliver_secret(p,level-1,(uint32_t)direction,bytes);
}
static int peer_parameters(SSL *ssl,const unsigned char *data,size_t length,void *arg) {
    tlsq_provider *p=arg;tlsq_bytes bytes={data,length};(void)ssl;
    if (p->terminal) return 0;
    if (p->parameters_seen || !bytes_valid(bytes) || length>p->peer_parameter_limit ||
        p->callbacks.parameters(p->callbacks.context,bytes)!=1) return fail_callback(p);
    p->parameters_seen=1;return 1;
}
static int alert(SSL *ssl,unsigned char code,void *arg) {
    tlsq_provider *p=arg;(void)ssl;p->alert_code=code;
    if (p->callbacks.alert(p->callbacks.context,code)!=1) return fail_callback(p);
    return 1;
}
static int select_alpn(SSL *ssl,const unsigned char **out,unsigned char *length,const unsigned char *in,unsigned int n,void *arg) {
    tlsq_provider *p=arg;(void)ssl;
    if (SSL_select_next_proto((unsigned char **)out,length,p->alpn,(unsigned int)p->alpn_length,in,n)!=OPENSSL_NPN_NEGOTIATED)
        return SSL_TLSEXT_ERR_ALERT_FATAL;
    return SSL_TLSEXT_ERR_OK;
}
static int no_password(char *buf,int size,int writing,void *arg) {
    (void)buf;(void)size;(void)writing;(void)arg;return 0;
}
static const OSSL_DISPATCH dispatch[] = {
    {OSSL_FUNC_SSL_QUIC_TLS_CRYPTO_SEND,(void (*)(void))send_crypto},
    {OSSL_FUNC_SSL_QUIC_TLS_CRYPTO_RECV_RCD,(void (*)(void))receive_crypto},
    {OSSL_FUNC_SSL_QUIC_TLS_CRYPTO_RELEASE_RCD,(void (*)(void))release_crypto},
    {OSSL_FUNC_SSL_QUIC_TLS_YIELD_SECRET,(void (*)(void))yield_secret},
    {OSSL_FUNC_SSL_QUIC_TLS_GOT_TRANSPORT_PARAMS,(void (*)(void))peer_parameters},
    {OSSL_FUNC_SSL_QUIC_TLS_ALERT,(void (*)(void))alert},{0,NULL}
};
static char *text_copy(tlsq_bytes b) {
    char *out=OPENSSL_malloc(b.length+1);
    if (out) { if (b.length) memcpy(out,b.data,b.length);out[b.length]=0; }
    return out;
}
uint32_t tlsq_create(const tlsq_config *c,const tlsq_callbacks *callbacks,tlsq_provider **out) {
    tlsq_provider *p;tlsq_capabilities caps;uint32_t status;
    char *trust=NULL,*cert=NULL,*key=NULL,*identity=NULL;
    if (!out || *out) return TLSQ_INVALID;
    status=tlsq_validate(c,callbacks);if (status!=TLSQ_OK) return status;
    status=tlsq_query(TLSQ_ABI_VERSION,&caps);
    if (status!=TLSQ_OK || !caps.runtime_available) return TLSQ_UNAVAILABLE;
    p=OPENSSL_zalloc(sizeof *p);if (!p) return TLSQ_NO_MEMORY;
    p->callbacks=*callbacks;p->role=c->role;p->require_client=c->require_client_certificate;
    p->peer_parameter_limit=c->peer_parameter_limit;p->alert_code=UINT32_MAX;
    p->alpn[0]=(unsigned char)c->alpn.length;memcpy(p->alpn+1,c->alpn.data,c->alpn.length);
    p->alpn_length=c->alpn.length+1;
    status=TLSQ_NO_MEMORY;
    if (!(trust=text_copy(c->trust_file)) || !(cert=text_copy(c->certificate_file)) ||
        !(key=text_copy(c->private_key_file)) || !(identity=text_copy(c->identity))) goto done;
    if (c->local_parameters.length) {
        p->parameters=OPENSSL_memdup(c->local_parameters.data,c->local_parameters.length);
        if (!p->parameters) goto done;
    }
    p->parameters_length=c->local_parameters.length;
    ERR_clear_error();p->ctx=SSL_CTX_new(TLS_method());if (!p->ctx) goto done;
    status=TLSQ_CONFIGURATION;
    SSL_CTX_set_default_passwd_cb(p->ctx,no_password);
    if (!SSL_CTX_set_min_proto_version(p->ctx,TLS1_3_VERSION) || !SSL_CTX_set_max_proto_version(p->ctx,TLS1_3_VERSION) ||
        !SSL_CTX_set_ciphersuites(p->ctx,"TLS_AES_128_GCM_SHA256") || !SSL_CTX_set1_groups_list(p->ctx,"X25519") ||
        !SSL_CTX_set_num_tickets(p->ctx,0)) goto done;
    SSL_CTX_set_session_cache_mode(p->ctx,SSL_SESS_CACHE_OFF);
    SSL_CTX_set_options(p->ctx,SSL_OP_NO_TICKET);
    if (c->trust_file.length && !SSL_CTX_load_verify_locations(p->ctx,trust,NULL)) goto done;
    SSL_CTX_set_verify(p->ctx,(c->role==TLSQ_CLIENT || c->require_client_certificate) ?
        SSL_VERIFY_PEER | (c->role==TLSQ_SERVER ? SSL_VERIFY_FAIL_IF_NO_PEER_CERT:0):SSL_VERIFY_NONE,NULL);
    if (c->certificate_file.length && (!SSL_CTX_use_certificate_chain_file(p->ctx,cert) ||
        !SSL_CTX_use_PrivateKey_file(p->ctx,key,SSL_FILETYPE_PEM) || !SSL_CTX_check_private_key(p->ctx))) goto done;
    if (c->role==TLSQ_SERVER) SSL_CTX_set_alpn_select_cb(p->ctx,select_alpn,p);
    p->ssl=SSL_new(p->ctx);if (!p->ssl) goto done;
    X509_VERIFY_PARAM_set_time(SSL_get0_param(p->ssl),(time_t)c->wall_time_seconds);
    if (!X509_VERIFY_PARAM_set_flags(SSL_get0_param(p->ssl),X509_V_FLAG_X509_STRICT | X509_V_FLAG_TRUSTED_FIRST)) goto done;
    if (c->role==TLSQ_SERVER) SSL_set_accept_state(p->ssl);
    else {
        SSL_set_connect_state(p->ssl);
        SSL_set_hostflags(p->ssl,X509_CHECK_FLAG_NO_PARTIAL_WILDCARDS | X509_CHECK_FLAG_NEVER_CHECK_SUBJECT);
        if (c->identity_kind==TLSQ_DNS) {
            if (!SSL_set1_host(p->ssl,identity) || !SSL_set_tlsext_host_name(p->ssl,identity)) goto done;
        } else if (!X509_VERIFY_PARAM_set1_ip_asc(SSL_get0_param(p->ssl),identity)) goto done;
        if (SSL_set_alpn_protos(p->ssl,p->alpn,(unsigned int)p->alpn_length)) goto done;
    }
    if (!SSL_set_quic_tls_cbs(p->ssl,dispatch,p) ||
        !SSL_set_quic_tls_transport_params(p->ssl,p->parameters,p->parameters_length) ||
        !SSL_set_quic_tls_early_data_enabled(p->ssl,0)) goto done;
    status=TLSQ_OK;
done:
    OPENSSL_free(trust);OPENSSL_free(cert);OPENSSL_free(key);OPENSSL_free(identity);
    if (status==TLSQ_OK) *out=p;else (void)tlsq_destroy(&p);
    return status;
}
static uint32_t live(tlsq_provider *p) {
    if (!p) return TLSQ_INVALID;
    if (p->busy) return TLSQ_REENTRANT;
    if (p->closed) return TLSQ_CLOSED;
    return TLSQ_OK;
}
static int authenticated(tlsq_provider *p) {
    const unsigned char *alpn;unsigned int length;
    if (!SSL_is_init_finished(p->ssl) || SSL_version(p->ssl)!=TLS1_3_VERSION || !p->parameters_seen) return 0;
    SSL_get0_alpn_selected(p->ssl,&alpn,&length);
    if (length!=p->alpn_length-1 || memcmp(alpn,p->alpn+1,length)) return 0;
    for (size_t level=TLSQ_HANDSHAKE;level<=TLSQ_APPLICATION;++level)
        for (size_t direction=0;direction<2;++direction) if (!p->seen[level][direction]) return 0;
    if (p->role==TLSQ_CLIENT || p->require_client) {
        if (SSL_get_verify_result(p->ssl)!=X509_V_OK || !SSL_get0_peer_certificate(p->ssl)) return 0;
        p->peer_authentication=p->role==TLSQ_CLIENT ? TLSQ_AUTH_SERVER_IDENTITY:TLSQ_AUTH_CLIENT_CERTIFICATE;
    } else p->peer_authentication=TLSQ_AUTH_SERVER_POLICY;
    return 1;
}
uint32_t tlsq_step(tlsq_provider *p,size_t input_budget,size_t output_budget,tlsq_result *out) {
    uint32_t status=live(p);int result,error;size_t ignored_length=0;unsigned char ignored;
    tlsq_result value={0};
    if (status!=TLSQ_OK) return status;
    if (!out) return TLSQ_INVALID;
    if (p->terminal) return TLSQ_TERMINAL;
    p->busy=1;p->input_budget=input_budget;p->output_budget=output_budget;
    p->input_delivered=0;p->output_accepted=0;p->local_pause=0;p->output_pause=0;
    ERR_clear_error();
    result=SSL_is_init_finished(p->ssl) ? SSL_read_ex(p->ssl,&ignored,0,&ignored_length):SSL_do_handshake(p->ssl);
    error=SSL_get_error(p->ssl,result);
    if (error!=SSL_ERROR_NONE && error!=SSL_ERROR_WANT_READ && error!=SSL_ERROR_WANT_WRITE) p->terminal=1;
    if (SSL_is_init_finished(p->ssl) && !authenticated(p)) p->terminal=1;
    value.wait=p->output_pause ? TLSQ_EVENT_CAPACITY:p->local_pause ? TLSQ_LOCAL_WORK:
        error==SSL_ERROR_WANT_READ ? TLSQ_NETWORK_INPUT:TLSQ_PROGRESS;
    value.tls_complete=!p->terminal && SSL_is_init_finished(p->ssl);
    value.peer_authentication=p->terminal ? TLSQ_AUTH_NONE:p->peer_authentication;
    value.ssl_error=error;value.verify_error=SSL_get_verify_result(p->ssl);
    value.callback_failed=p->callback_failed;value.alert_code=p->alert_code;
    value.input_delivered=p->input_delivered;value.output_accepted=p->output_accepted;value.lease_bytes=p->lease.length;
    p->busy=0;*out=value;
    return p->terminal ? TLSQ_TERMINAL:TLSQ_OK;
}
uint32_t tlsq_close(tlsq_provider *p) {
    if (!p) return TLSQ_INVALID;
    if (p->busy) return TLSQ_REENTRANT;
    if (p->closed) return TLSQ_OK;
    p->busy=1;p->terminal=1;
    SSL_free(p->ssl);p->ssl=NULL;SSL_CTX_free(p->ctx);p->ctx=NULL;
    /* The owner may discard any unsuccessfully released input only now. */
    p->lease.data=NULL;p->lease.length=0;
    OPENSSL_clear_free(p->parameters,p->parameters_length);p->parameters=NULL;p->parameters_length=0;
    OPENSSL_cleanse(p->alpn,sizeof p->alpn);
    p->closed=1;p->busy=0;
    return TLSQ_OK;
}
uint32_t tlsq_destroy(tlsq_provider **owner) {
    uint32_t status;
    if (!owner) return TLSQ_INVALID;
    if (!*owner) return TLSQ_OK;
    status=tlsq_close(*owner);if (status!=TLSQ_OK) return status;
    OPENSSL_clear_free(*owner,sizeof **owner);*owner=NULL;
    return TLSQ_OK;
}
#ifdef TLSQ_TESTING
uint32_t tlsq_test_release(tlsq_provider *p,size_t length) {
    uint32_t status=live(p);int result;
    if (status!=TLSQ_OK) return status;
    if (!length || length!=p->lease.length) return TLSQ_INVALID;
    p->busy=1;result=release_crypto(p->ssl,length,p);p->busy=0;
    return result ? TLSQ_OK:TLSQ_TERMINAL;
}
uint32_t tlsq_test_secret(tlsq_provider *p,uint32_t level,uint32_t direction,tlsq_bytes bytes) {
    uint32_t status=live(p);int result;
    if (status!=TLSQ_OK) return status;
    if (!secret_valid(level,direction,bytes)) return TLSQ_INVALID;
    p->busy=1;result=deliver_secret(p,level,direction,bytes);p->busy=0;
    return result ? TLSQ_OK:TLSQ_TERMINAL;
}
#endif
