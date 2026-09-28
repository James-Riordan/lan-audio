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
const char *tz_version(void);
#endif
