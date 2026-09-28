#include "backend/quic.h"
#define OFF(T,F) offsetof(T,F)
/* Independently compiled C layout observations, not a translated-C Zig oracle. */
uint64_t tlsq_abi_value(uint32_t type,uint32_t field) {
    static const size_t b[]={sizeof(tlsq_bytes),_Alignof(tlsq_bytes),OFF(tlsq_bytes,data),OFF(tlsq_bytes,length)};
    static const size_t cap[]={sizeof(tlsq_capabilities),_Alignof(tlsq_capabilities),OFF(tlsq_capabilities,abi_version),OFF(tlsq_capabilities,compiled_recordless),OFF(tlsq_capabilities,runtime_available),OFF(tlsq_capabilities,qualified_target)};
    static const size_t cfg[]={sizeof(tlsq_config),_Alignof(tlsq_config),OFF(tlsq_config,abi_version),OFF(tlsq_config,role),OFF(tlsq_config,identity_kind),OFF(tlsq_config,require_client_certificate),OFF(tlsq_config,wall_time_seconds),OFF(tlsq_config,trust_file),OFF(tlsq_config,certificate_file),OFF(tlsq_config,private_key_file),OFF(tlsq_config,identity),OFF(tlsq_config,alpn),OFF(tlsq_config,local_parameters),OFF(tlsq_config,peer_parameter_limit)};
    static const size_t cb[]={sizeof(tlsq_callbacks),_Alignof(tlsq_callbacks),OFF(tlsq_callbacks,abi_version),OFF(tlsq_callbacks,context),OFF(tlsq_callbacks,send),OFF(tlsq_callbacks,receive),OFF(tlsq_callbacks,release),OFF(tlsq_callbacks,secret),OFF(tlsq_callbacks,parameters),OFF(tlsq_callbacks,alert)};
    static const size_t result[]={sizeof(tlsq_result),_Alignof(tlsq_result),OFF(tlsq_result,wait),OFF(tlsq_result,tls_complete),OFF(tlsq_result,peer_authentication),OFF(tlsq_result,alert_code),OFF(tlsq_result,ssl_error),OFF(tlsq_result,callback_failed),OFF(tlsq_result,verify_error),OFF(tlsq_result,input_delivered),OFF(tlsq_result,output_accepted),OFF(tlsq_result,lease_bytes)};
    const size_t *values;size_t n;
    switch (type) {
        case 0:values=b;n=sizeof b/sizeof *b;break;
        case 1:values=cap;n=sizeof cap/sizeof *cap;break;
        case 2:values=cfg;n=sizeof cfg/sizeof *cfg;break;
        case 3:values=cb;n=sizeof cb/sizeof *cb;break;
        case 4:values=result;n=sizeof result/sizeof *result;break;
        default:return UINT64_MAX;
    }
    return field<n ? values[field]:UINT64_MAX;
}
int32_t tlsq_abi_invoke(const tlsq_callbacks *c) {
    static const unsigned char data[]={1,2,3};static const unsigned char secret[32]={7};
    tlsq_bytes bytes={data,3},lease={NULL,0},key={secret,32};size_t accepted=0;
    if (c->abi_version!=1 || c->send(c->context,0,bytes,&accepted)!=1 || accepted!=2) return 0;
    if (c->receive(c->context,1,3,&lease)!=1 || lease.length!=3 || !lease.data || lease.data[2]!=3) return 0;
    if (c->release(c->context,1,lease)!=1) return 0;
    if (c->secret(c->context,2,1,0x1301,key)!=1) return 0;
    if (c->parameters(c->context,bytes)!=1 || c->alert(c->context,42)!=1) return 0;
    return 1;
}
