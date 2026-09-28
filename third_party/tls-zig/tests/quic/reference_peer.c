/* Test-only independent adapter: preserved direct-OpenSSL diagnostic code.
 * It deliberately bypasses src/backend/quic.c and the Zig Engine. Same locked
 * OpenSSL provider; this is not an independent QUIC implementation.
 */
#define main tlsq_reference_diagnostic_main
#include "../../tools/probe-quic-pair.c"
#undef main
#include <openssl/hmac.h>

struct reference_peer { struct peer native, output; EVP_MD_CTX *ledger[3][2];size_t bytes[3][2]; };
void reference_destroy(struct reference_peer **owner);
static unsigned reference_level(uint32_t level) { return level==0 ? 0:level==1 ? 2:3; }
int32_t reference_create(uint32_t role,const char *fixtures,int32_t tickets,struct reference_peer **out) {
    struct reference_peer *p;
    if (!out || *out || role>1 || !fixtures) return 0;
    p=OPENSSL_zalloc(sizeof *p);if (!p) return 0;
    p->native.id=(int)role;p->native.other=&p->output;p->native.alert_code=-1;
    p->native.fragment=7;p->native.quantum=23;p->native.input_quantum=29;
    for (unsigned level=0;level<3;++level) for (unsigned direction=0;direction<2;++direction) {
        p->ledger[level][direction]=EVP_MD_CTX_new();
        if (!p->ledger[level][direction] || !EVP_DigestInit_ex(p->ledger[level][direction],EVP_sha256(),NULL)) {
            reference_destroy(&p);return 0;
        }
    }
    if (!setup(&p->native,fixtures,tickets ? "tickets":"full")) {
        reference_destroy(&p);return 0;
    }
    *out=p;return 1;
}
void reference_destroy(struct reference_peer **owner) {
    struct reference_peer *p;
    if (!owner || !*owner) return;
    p=*owner;p->native.tearing_down=1;
    SSL_free(p->native.ssl);SSL_CTX_free(p->native.ctx);
    for (unsigned level=0;level<3;++level) for (unsigned direction=0;direction<2;++direction)
        EVP_MD_CTX_free(p->ledger[level][direction]);
    OPENSSL_clear_free(p,sizeof *p);*owner=NULL;
}
int32_t reference_advance(struct reference_peer *p) {
    if (!p || p->native.failure) return 0;
    step(&p->native,p->native.done);
    return !p->native.failure && !p->native.invariant;
}
int32_t reference_offer(struct reference_peer *p,uint32_t level,const unsigned char *data,size_t length,size_t *accepted) {
    struct queue *q;size_t n;
    if (!p || !accepted || level>2 || (length && !data)) return 0;
    q=&p->native.input[reference_level(level)];n=length<CAP-q->used ? length:CAP-q->used;
    if (n && !EVP_DigestUpdate(p->ledger[level][0],data,n)) return 0;
    p->bytes[level][0]+=n;
    if (n) memcpy(q->data+q->used,data,n);q->used+=n;*accepted=n;return 1;
}
int32_t reference_peek(struct reference_peer *p,uint32_t level,const unsigned char **data,size_t *length) {
    struct queue *q;
    if (!p || !data || !length || level>2) return 0;
    q=&p->output.input[reference_level(level)];*data=q->data+q->retired;*length=q->used-q->retired;return 1;
}
int32_t reference_retire(struct reference_peer *p,uint32_t level,size_t length) {
    struct queue *q;
    if (!p || level>2) return 0;
    q=&p->output.input[reference_level(level)];if (length>q->used-q->retired) return 0;
    if (length && !EVP_DigestUpdate(p->ledger[level][1],q->data+q->retired,length)) return 0;
    p->bytes[level][1]+=length;
    OPENSSL_cleanse(q->data+q->retired,length);q->retired+=length;return 1;
}
int32_t reference_ledger(struct reference_peer *p,uint32_t level,uint32_t direction,unsigned char *digest,size_t *bytes) {
    EVP_MD_CTX *copy;unsigned int length=0;int ok;
    if (!p || level>2 || direction>1 || !digest || !bytes) return 0;
    copy=EVP_MD_CTX_new();if (!copy) return 0;
    ok=EVP_MD_CTX_copy_ex(copy,p->ledger[level][direction]) && EVP_DigestFinal_ex(copy,digest,&length) && length==32;
    EVP_MD_CTX_free(copy);if (ok) *bytes=p->bytes[level][direction];return ok;
}
int32_t reference_ready(struct reference_peer *p) {
    const unsigned char *selected;unsigned int length;
    if (!p || !p->native.done || p->native.failure || p->native.invariant || p->native.params!=1) return 0;
    if (!p->native.id && (SSL_get_verify_result(p->native.ssl)!=X509_V_OK || !SSL_get0_peer_certificate(p->native.ssl))) return 0;
    SSL_get0_alpn_selected(p->native.ssl,&selected,&length);
    if (length!=10 || memcmp(selected,protocol+1,10)) return 0;
    for (unsigned level=2;level<=3;++level) for (unsigned direction=0;direction<2;++direction)
        if (!p->native.seen[level][direction]) return 0;
    return 1;
}
int32_t reference_secret(struct reference_peer *p,uint32_t level,uint32_t direction,unsigned char *out) {
    unsigned native_level;
    if (!p || !out || level<1 || level>2 || direction>1) return 0;
    native_level=reference_level(level);if (!p->native.seen[native_level][direction]) return 0;
    memcpy(out,p->native.secrets[native_level][direction],32);return 1;
}
static int reference_expand(const unsigned char *secret,const char *label,unsigned char *out,size_t length) {
    unsigned char info[64],digest[32];unsigned int digest_length=0;size_t n=strlen(label),pos=0;
    if (n>40 || length>32) return 0;
    info[pos++]=0;info[pos++]=(unsigned char)length;info[pos++]=(unsigned char)(6+n);
    memcpy(info+pos,"tls13 ",6);pos+=6;memcpy(info+pos,label,n);pos+=n;
    info[pos++]=0;info[pos++]=1; /* empty context; first HKDF-Expand block */
    if (!HMAC(EVP_sha256(),secret,32,info,pos,digest,&digest_length) || digest_length!=32) return 0;
    memcpy(out,digest,length);OPENSSL_cleanse(digest,sizeof digest);return 1;
}
/* Encrypt a genuine short-header QUIC packet (PING + padding, PN 1), including
 * AEAD and header protection, using this independently driven peer's write key.
 */
int32_t reference_packet(struct reference_peer *p,unsigned char *out,size_t capacity,size_t *written) {
    EVP_CIPHER_CTX *ctx=NULL;unsigned char key[16],iv[12],hp[16],mask[16],plain[32]={1};
    unsigned char packet[61]={0x43,1,2,3,4,5,6,7,8,0,0,0,1};int n=0,last=0,ok=0;
    if (!p || !out || !written || capacity<sizeof packet || !p->native.seen[3][1]) return 0;
    if (!reference_expand(p->native.secrets[3][1],"quic key",key,sizeof key) ||
        !reference_expand(p->native.secrets[3][1],"quic iv",iv,sizeof iv) ||
        !reference_expand(p->native.secrets[3][1],"quic hp",hp,sizeof hp)) goto done;
    iv[11]^=1;ctx=EVP_CIPHER_CTX_new();if (!ctx) goto done;
    if (!EVP_EncryptInit_ex(ctx,EVP_aes_128_gcm(),NULL,key,iv) ||
        !EVP_EncryptUpdate(ctx,NULL,&n,packet,13) ||
        !EVP_EncryptUpdate(ctx,packet+13,&n,plain,sizeof plain) || n!=32 ||
        !EVP_EncryptFinal_ex(ctx,packet+45,&last) || last!=0 ||
        !EVP_CIPHER_CTX_ctrl(ctx,EVP_CTRL_GCM_GET_TAG,16,packet+45)) goto done;
    EVP_CIPHER_CTX_free(ctx);ctx=EVP_CIPHER_CTX_new();if (!ctx) goto done;
    if (!EVP_EncryptInit_ex(ctx,EVP_aes_128_ecb(),NULL,hp,NULL) || !EVP_CIPHER_CTX_set_padding(ctx,0) ||
        !EVP_EncryptUpdate(ctx,mask,&n,packet+13,16) || n!=16) goto done;
    packet[0]^=mask[0]&0x1f;
    for (unsigned i=0;i<4;++i) packet[9+i]^=mask[1+i];
    memcpy(out,packet,sizeof packet);*written=sizeof packet;ok=1;
done:
    EVP_CIPHER_CTX_free(ctx);OPENSSL_cleanse(key,sizeof key);OPENSSL_cleanse(iv,sizeof iv);
    OPENSSL_cleanse(hp,sizeof hp);OPENSSL_cleanse(mask,sizeof mask);return ok;
}
