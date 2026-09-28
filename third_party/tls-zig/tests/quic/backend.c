/* Independent host fixture exercising actual quic.c symbols and SSL handshakes.
 * No socket, no production Engine substitute. Append-only wire storage preserves
 * leases; released bytes are poisoned only after the release callback succeeds.
 */
#include "backend/quic.h"
#include <openssl/crypto.h>
#include <openssl/x509_vfy.h>
#include <stdio.h>
#include <string.h>
#include <stdint.h>
#include <stdlib.h>
#include <stddef.h>

#define CAP 65536u
#define REQUIRE(x) do { if (!(x)) { fprintf(stderr,"line %d: %s\n",__LINE__,#x); return 0; } } while (0)
union allocation_header { max_align_t alignment;size_t size; };
static size_t allocation_calls,free_calls,live_allocations,live_bytes;
static void *tracked_malloc(size_t n,const char *file,int line) {
    union allocation_header *p;(void)file;(void)line;
    if (n>SIZE_MAX-sizeof *p) return NULL;
    p=malloc(sizeof *p+n);if (!p) return NULL;
    p->size=n;++allocation_calls;++live_allocations;live_bytes+=n;return p+1;
}
static void tracked_free(void *ptr,const char *file,int line) {
    union allocation_header *p;(void)file;(void)line;
    if (!ptr) return;
    p=(union allocation_header *)ptr-1;--live_allocations;live_bytes-=p->size;++free_calls;free(p);
}
static void *tracked_realloc(void *ptr,size_t n,const char *file,int line) {
    union allocation_header *old,*p;size_t old_size;
    if (!ptr) return tracked_malloc(n,file,line);
    if (!n) { tracked_free(ptr,file,line);return NULL; }
    if (n>SIZE_MAX-sizeof *p) return NULL;
    old=(union allocation_header *)ptr-1;old_size=old->size;
    p=realloc(old,sizeof *p+n);if (!p) return NULL;
    p->size=n;live_bytes=live_bytes-old_size+n;++allocation_calls;return p+1;
}
struct wire { unsigned char data[CAP];size_t used,retired; };
struct peer {
    tlsq_provider *provider;struct peer *other;struct wire input[3];
    unsigned char secrets[3][2][32];unsigned seen[3][2];
    size_t lease_length,lease_offset,lease_level,last_release;
    size_t leases,releases,release_calls,teardown_releases,release_failures,secret_calls,parameter_calls,alerts;
    size_t fragment,quantum,input_quantum,local_pauses,output_pauses;
    unsigned role,fail,injected,teardown,reentrant,closed,invalid;
    tlsq_result result;uint32_t status;
};
static const unsigned char protocol[]={ 'q',0,'t',0xff };
static const unsigned char parameters[2][3]={{15,1,0x11},{15,1,0x22}};
static tlsq_bytes bytes(const void *p,size_t n) { tlsq_bytes b={(const unsigned char *)p,n};return b; }
static tlsq_bytes text(const char *s) { return bytes(s,strlen(s)); }
static int reenter(struct peer *p) {
    tlsq_result out,before;tlsq_provider *owner=p->provider;
    if (!p->reentrant) return 1;
    memset(&out,0x5a,sizeof out);before=out;
    if (tlsq_step(p->provider,1,1,&out)!=TLSQ_REENTRANT || memcmp(&out,&before,sizeof out) ||
        tlsq_close(p->provider)!=TLSQ_REENTRANT || tlsq_destroy(&owner)!=TLSQ_REENTRANT || owner!=p->provider) {
        p->invalid=1;return 0;
    }
    return 1;
}
static int reject(struct peer *p,unsigned kind) {
    if (p->fail==kind && !p->injected) { p->injected=1;return 1; }
    return 0;
}
static int32_t send_bytes(void *arg,uint32_t level,tlsq_bytes b,size_t *accepted) {
    struct peer *p=arg;struct wire *w;size_t n=b.length;
    *accepted=0;
    if (!reenter(p) || reject(p,1)) return 0;
    if (p->fail==7) { *accepted=b.length+1;p->injected=1;return 1; }
    if (level>2) { p->invalid=1;return 0; }
    w=&p->other->input[level];
    if (n>p->quantum) n=p->quantum;
    if (n>CAP-w->used) { p->invalid=1;return 0; }
    if (n) memcpy(w->data+w->used,b.data,n);
    w->used+=n;*accepted=n;
    return 1;
}
static int32_t receive_bytes(void *arg,uint32_t level,size_t maximum,tlsq_bytes *lease) {
    struct peer *p=arg;struct wire *w;size_t n;
    *lease=bytes(NULL,0);
    if (!reenter(p) || level>2 || p->lease_length) { p->invalid=1;return 0; }
    w=&p->input[level];n=w->used-w->retired;
    if (!n) return 1;
    if (reject(p,2)) return 0;
    if (p->fail==8) { *lease=bytes(w->data+w->retired,maximum+1);p->injected=1;return 1; }
    if (p->fail==9) { *lease=bytes(NULL,1);p->injected=1;return 1; }
    if (n>maximum) n=maximum;
    if (n>p->fragment) n=p->fragment;
    p->lease_length=n;p->lease_offset=w->retired;p->lease_level=level;++p->leases;
    *lease=bytes(w->data+w->retired,n);return 1;
}
static int32_t release_bytes(void *arg,uint32_t level,tlsq_bytes lease) {
    struct peer *p=arg;struct wire *w=&p->input[p->lease_level];
    ++p->release_calls;if (p->teardown) ++p->teardown_releases;
    if (!reenter(p) || !p->lease_length || level!=p->lease_level || lease.length!=p->lease_length ||
        lease.data!=w->data+p->lease_offset || w->retired!=p->lease_offset) { p->invalid=1;return 0; }
    if (reject(p,3)) { ++p->release_failures;return 0; }
    /* SSL declared the complete lease unused. Poison before returning so a
     * later provider read of released bytes corrupts the authenticated trace. */
    memset(w->data+w->retired,0xa5,lease.length);
    w->retired+=lease.length;p->last_release=lease.length;p->lease_length=0;++p->releases;
    return 1;
}
static int32_t secret(void *arg,uint32_t level,uint32_t direction,uint32_t suite,tlsq_bytes b) {
    struct peer *p=arg;++p->secret_calls;
    if (!reenter(p) || reject(p,4)) return 0;
    if (level<1 || level>2 || direction>1 || suite!=TLSQ_AES128GCM_SHA256 || b.length!=32 || p->seen[level][direction]) {
        p->invalid=1;return 0;
    }
    memcpy(p->secrets[level][direction],b.data,32);p->seen[level][direction]=1;return 1;
}
static int32_t peer_parameters(void *arg,tlsq_bytes b) {
    struct peer *p=arg;++p->parameter_calls;
    if (!reenter(p) || reject(p,5)) return 0;
    if (p->parameter_calls!=1 || b.length!=3 || memcmp(b.data,parameters[1-p->role],3)) { p->invalid=1;return 0; }
    return 1;
}
static int32_t alert(void *arg,uint32_t code) {
    struct peer *p=arg;++p->alerts;(void)code;
    return reenter(p) && !reject(p,6);
}
static tlsq_callbacks callbacks(struct peer *p) {
    tlsq_callbacks c={TLSQ_ABI_VERSION,p,send_bytes,receive_bytes,release_bytes,secret,peer_parameters,alert};return c;
}
static tlsq_config config(struct peer *p,char *ca,char *cert,char *key,const char *scenario) {
    tlsq_config c={0};
    c.abi_version=TLSQ_ABI_VERSION;c.role=p->role;c.wall_time_seconds=1790424000;
    c.alpn=bytes(protocol,sizeof protocol);c.local_parameters=bytes(parameters[p->role],3);c.peer_parameter_limit=4096;
    if (!p->role) {
        c.trust_file=text(ca);c.identity=text(!strcmp(scenario,"wrong-host") || !strcmp(scenario,"fail-alert") ? "mismatch.invalid":"localhost");
        if (!strcmp(scenario,"ip")) { c.identity_kind=TLSQ_IP;c.identity=text("127.0.0.1"); }
    }
    if (p->role || !strcmp(scenario,"mutual")) { c.certificate_file=text(cert);c.private_key_file=text(key); }
    if (p->role && (!strcmp(scenario,"mutual") || !strcmp(scenario,"missing-client"))) {
        c.require_client_certificate=1;c.trust_file=text(ca);
    }
    return c;
}
static int validation(struct peer *p,tlsq_config c,tlsq_callbacks cb) {
    tlsq_config bad;tlsq_provider *sentinel=p->provider;tlsq_capabilities cap,before;tlsq_result output,prior;
    unsigned char s[32]={0};size_t allocs=allocation_calls,frees=free_calls,live=live_allocations,used=live_bytes;
    REQUIRE(tlsq_validate(&c,&cb)==TLSQ_OK);
    memset(&cap,0x5a,sizeof cap);before=cap;
    REQUIRE(tlsq_query(2,&cap)==TLSQ_INVALID && !memcmp(&cap,&before,sizeof cap));
    REQUIRE(tlsq_query(TLSQ_ABI_VERSION,NULL)==TLSQ_INVALID);
    REQUIRE(tlsq_create(NULL,&cb,&sentinel)==TLSQ_INVALID && sentinel==p->provider);
    REQUIRE(tlsq_create(&c,NULL,&sentinel)==TLSQ_INVALID && sentinel==p->provider);
    bad=c;bad.alpn=bytes(NULL,1);
    REQUIRE(tlsq_create(&bad,&cb,&sentinel)==TLSQ_INVALID && sentinel==p->provider);
    REQUIRE(tlsq_validate(&bad,&cb)==TLSQ_INVALID);
    sentinel=NULL;REQUIRE(tlsq_create(&bad,&cb,&sentinel)==TLSQ_INVALID && !sentinel);
    sentinel=p->provider;REQUIRE(tlsq_create(&c,&cb,&sentinel)==TLSQ_INVALID && sentinel==p->provider);
    bad=c;bad.local_parameters=bytes(NULL,1);REQUIRE(tlsq_validate(&bad,&cb)==TLSQ_INVALID);
    bad=c;bad.role=2;REQUIRE(tlsq_validate(&bad,&cb)==TLSQ_INVALID);
    bad=c;bad.wall_time_seconds=0;REQUIRE(tlsq_validate(&bad,&cb)==TLSQ_INVALID);
    bad=c;bad.identity=text("bad..name");REQUIRE(tlsq_validate(&bad,&cb)==TLSQ_INVALID);
    bad=c;bad.certificate_file=text("cert-only");REQUIRE(tlsq_validate(&bad,&cb)==TLSQ_INVALID);
    bad=c;bad.alpn=bytes(NULL,0);REQUIRE(tlsq_validate(&bad,&cb)==TLSQ_INVALID);
    bad=c;bad.trust_file=bytes("ca\0tail",7);REQUIRE(tlsq_validate(&bad,&cb)==TLSQ_INVALID);
    bad=c;bad.identity_kind=99;REQUIRE(tlsq_validate(&bad,&cb)==TLSQ_INVALID);
    { const char *good[]={"127.0.0.1","::","::1","2001:db8::1","1:2:3:4:5:6:7:8","::ffff:192.0.2.1","1:2:3:4:5:6:192.0.2.1"};
      const char *wrong[]={"256.0.0.1","01.0.0.1","1.2.3","1:2:3","1:2:3:4:5:6:7:8::",":1","1:","1::2::3","::ffff:192.0.2.999","fe80::1%eth0","[::1]",""};
      bad=c;bad.identity_kind=TLSQ_IP;
      for (size_t i=0;i<sizeof good/sizeof good[0];++i) { bad.identity=text(good[i]);REQUIRE(tlsq_validate(&bad,&cb)==TLSQ_OK); }
      for (size_t i=0;i<sizeof wrong/sizeof wrong[0];++i) { bad.identity=text(wrong[i]);REQUIRE(tlsq_validate(&bad,&cb)==TLSQ_INVALID); }
    }
    REQUIRE(tlsq_test_release(p->provider,0)==TLSQ_INVALID);
    REQUIRE(tlsq_test_release(p->provider,1)==TLSQ_INVALID);
    REQUIRE(tlsq_test_secret(p->provider,99,0,bytes(s,32))==TLSQ_INVALID);
    REQUIRE(tlsq_test_secret(p->provider,1,99,bytes(s,32))==TLSQ_INVALID);
    REQUIRE(tlsq_test_secret(p->provider,0,0,bytes(s,32))==TLSQ_INVALID);
    REQUIRE(tlsq_test_secret(p->provider,1,0,bytes(NULL,32))==TLSQ_INVALID);
    REQUIRE(tlsq_test_secret(p->provider,1,0,bytes(s,31))==TLSQ_INVALID);
    REQUIRE(p->secret_calls==0 && p->release_calls==0);
    memset(&output,0x5a,sizeof output);prior=output;
    REQUIRE(tlsq_step(NULL,1,1,&output)==TLSQ_INVALID && !memcmp(&output,&prior,sizeof output));
    REQUIRE(tlsq_step(p->provider,1,1,NULL)==TLSQ_INVALID);
    REQUIRE(allocation_calls==allocs && free_calls==frees && live_allocations==live && live_bytes==used);
    return 1;
}
static int run(const char *scenario,const char *fixtures) {
    static struct peer peers[2];char ca[4096],cert[4096],key[4096];size_t tick;
    struct peer *c=&peers[0],*s=&peers[1];int negative=0;unsigned fault=0;tlsq_capabilities caps;
    const char *faults[]={"fail-send","fail-receive","fail-release","fail-secret","fail-params","fail-alert","overconsume","overlease","null-lease"};
    memset(peers,0,sizeof peers);
    REQUIRE(tlsq_query(TLSQ_ABI_VERSION,&caps)==TLSQ_OK && caps.runtime_available && caps.qualified_target);
    for (size_t i=0;i<sizeof faults/sizeof faults[0];++i) if (!strcmp(scenario,faults[i])) { fault=(unsigned)i+1;negative=1; }
    if (!strcmp(scenario,"wrong-host") || !strcmp(scenario,"wrong-ca") || !strcmp(scenario,"missing-client") || !strcmp(scenario,"alpn") || !strcmp(scenario,"params-overflow")) negative=1;
    for (unsigned i=0;i<2;++i) {
        struct peer *p=&peers[i];tlsq_config cfg;tlsq_callbacks cb;unsigned char owned_params[3],owned_alpn[sizeof protocol];int n;
        p->role=i;p->other=&peers[1-i];p->fragment=CAP;p->quantum=CAP;p->input_quantum=CAP;
        if (!strcmp(scenario,"fragmented") || !strcmp(scenario,"combined")) p->fragment=1;
        if (!strcmp(scenario,"backpressure") || !strcmp(scenario,"combined")) p->quantum=17;
        if (!strcmp(scenario,"budgeted")) p->input_quantum=17;
        p->reentrant=!strcmp(scenario,"reentrant");
        if (fault) { if ((fault==6 && !i) || (fault!=6 && i)) p->fail=fault; }
        n=snprintf(ca,sizeof ca,"%s/%s",fixtures,!i && !strcmp(scenario,"wrong-ca") ? "other-ca.pem":"ca.pem");REQUIRE(n>0 && (size_t)n<sizeof ca);
        n=snprintf(cert,sizeof cert,"%s/%s.pem",fixtures,i ? "server":"client");REQUIRE(n>0 && (size_t)n<sizeof cert);
        n=snprintf(key,sizeof key,"%s/%s.key",fixtures,i ? "server":"client");REQUIRE(n>0 && (size_t)n<sizeof key);
        cfg=config(p,ca,cert,key,scenario);cb=callbacks(p);
        if (!strcmp(scenario,"alpn") && i) cfg.alpn=text("different");
        if (!strcmp(scenario,"params-overflow") && i) { cfg.peer_parameter_limit=2;cfg.local_parameters=bytes(NULL,0); }
        if (!strcmp(scenario,"config-copy")) {
            memcpy(owned_params,cfg.local_parameters.data,3);memcpy(owned_alpn,cfg.alpn.data,sizeof protocol);
            cfg.local_parameters=bytes(owned_params,3);cfg.alpn=bytes(owned_alpn,sizeof protocol);
        }
        REQUIRE(tlsq_create(&cfg,&cb,&p->provider)==TLSQ_OK && p->provider);
        if (!strcmp(scenario,"validation") && !i) REQUIRE(validation(p,cfg,cb));
        memset(owned_params,0xcc,sizeof owned_params);memset(owned_alpn,0xcc,sizeof owned_alpn);
    }
    if (!strcmp(scenario,"zero-budget")) {
        REQUIRE(tlsq_step(c->provider,CAP,0,&c->result)==TLSQ_OK && c->result.output_accepted==0 && c->result.wait==TLSQ_EVENT_CAPACITY);
        REQUIRE(tlsq_step(s->provider,0,CAP,&s->result)==TLSQ_OK && s->result.input_delivered==0 && s->result.wait==TLSQ_LOCAL_WORK);
    }
    for (tick=0;tick<20000;++tick) {
        for (unsigned i=0;i<2;++i) {
            struct peer *p=&peers[i];
            if (p->result.tls_complete) continue;
            p->status=tlsq_step(p->provider,p->input_quantum,p->quantum,&p->result);
            if (p->result.wait==TLSQ_LOCAL_WORK) ++p->local_pauses;
            if (p->result.wait==TLSQ_EVENT_CAPACITY) ++p->output_pauses;
            REQUIRE(p->result.input_delivered<=p->input_quantum && p->result.output_accepted<=p->quantum);
            if (p->status!=TLSQ_OK) break;
        }
        if (c->status!=TLSQ_OK || s->status!=TLSQ_OK || (c->result.tls_complete && s->result.tls_complete)) break;
    }
    REQUIRE(tick<20000 && !c->invalid && !s->invalid);
    if (negative) {
        struct peer *p=(fault==6 || !strcmp(scenario,"wrong-host") || !strcmp(scenario,"wrong-ca")) ? c:s;
        tlsq_result output,before;memset(&output,0x5a,sizeof output);before=output;
        REQUIRE(p->status==TLSQ_TERMINAL && !p->result.tls_complete && p->result.peer_authentication==TLSQ_AUTH_NONE);
        REQUIRE(tlsq_step(p->provider,CAP,CAP,&output)==TLSQ_TERMINAL && !memcmp(&output,&before,sizeof output));
        if (fault) REQUIRE(p->injected && p->result.callback_failed);
        if (!strcmp(scenario,"wrong-host") || !strcmp(scenario,"fail-alert"))
            REQUIRE(p->result.verify_error==X509_V_ERR_HOSTNAME_MISMATCH && p->alerts);
        if (!strcmp(scenario,"wrong-ca"))
            REQUIRE(p->result.verify_error==X509_V_ERR_UNABLE_TO_GET_ISSUER_CERT_LOCALLY ||
                    p->result.verify_error==X509_V_ERR_UNABLE_TO_VERIFY_LEAF_SIGNATURE ||
                    p->result.verify_error==X509_V_ERR_SELF_SIGNED_CERT_IN_CHAIN);
        if (!strcmp(scenario,"missing-client")) REQUIRE(p->result.alert_code==116);
        if (!strcmp(scenario,"alpn")) REQUIRE(p->result.alert_code==120);
        if (fault==3) {
            size_t calls=p->release_calls;REQUIRE(p->lease_length && p->result.lease_bytes==p->lease_length);
            REQUIRE(tlsq_test_release(p->provider,p->lease_length+1)==TLSQ_INVALID && p->release_calls==calls);
        }
    } else {
        REQUIRE(c->result.tls_complete && s->result.tls_complete);
        REQUIRE(c->result.peer_authentication==TLSQ_AUTH_SERVER_IDENTITY);
        REQUIRE(s->result.peer_authentication==(!strcmp(scenario,"mutual") ? TLSQ_AUTH_CLIENT_CERTIFICATE:TLSQ_AUTH_SERVER_POLICY));
        REQUIRE(c->parameter_calls==1 && s->parameter_calls==1);
        for (unsigned level=1;level<=2;++level) for (unsigned direction=0;direction<2;++direction)
            REQUIRE(c->seen[level][direction] && s->seen[level][1-direction] && !CRYPTO_memcmp(c->secrets[level][direction],s->secrets[level][1-direction],32));
        for (unsigned i=0;i<2;++i) {
            struct peer *p=&peers[i];size_t calls=p->release_calls;
            REQUIRE(!p->lease_length && p->leases==p->releases);
            REQUIRE(tlsq_test_release(p->provider,p->last_release)==TLSQ_INVALID && p->release_calls==calls);
        }
        if (!strcmp(scenario,"budgeted")) REQUIRE(c->local_pauses && s->local_pauses);
        if (!strcmp(scenario,"backpressure") || !strcmp(scenario,"combined")) REQUIRE(c->output_pauses && s->output_pauses);
    }
    for (unsigned i=0;i<2;++i) {
        struct peer *p=&peers[i];tlsq_result out,before;
        p->teardown=1;REQUIRE(tlsq_close(p->provider)==TLSQ_OK);REQUIRE(tlsq_close(p->provider)==TLSQ_OK);
        memset(&out,0x5a,sizeof out);before=out;
        REQUIRE(tlsq_step(p->provider,CAP,CAP,&out)==TLSQ_CLOSED && !memcmp(&out,&before,sizeof out));
        REQUIRE(tlsq_test_release(p->provider,1)==TLSQ_CLOSED);
        REQUIRE(tlsq_destroy(&p->provider)==TLSQ_OK && !p->provider);REQUIRE(tlsq_destroy(&p->provider)==TLSQ_OK);
        REQUIRE(!p->invalid);
        if (p->fail==3) REQUIRE(p->release_failures==1 && p->teardown_releases==1 && !p->lease_length && p->leases==p->releases);
        OPENSSL_cleanse(p->secrets,sizeof p->secrets);
    }
    printf("{\"case\":\"%s\",\"passed\":true,\"steps\":%zu,\"client_leases\":%zu,\"server_leases\":%zu,\"server_teardown_releases\":%zu}\n",scenario,tick+1,c->leases,s->leases,s->teardown_releases);
    return 1;
}
int main(int argc,char **argv) {
    int passed;
    if (argc!=3) return 2;
    if (!CRYPTO_set_mem_functions(tracked_malloc,tracked_realloc,tracked_free)) return 2;
    passed=run(argv[1],argv[2]);
    OPENSSL_cleanup();
    if (live_allocations || live_bytes) {
        fprintf(stderr,"unreleased OpenSSL allocations: %zu (%zu bytes)\n",live_allocations,live_bytes);passed=0;
    }
    return passed ? 0:1;
}
