#ifndef LAN_AUDIO_NET_NATIVE_H
#define LAN_AUDIO_NET_NATIVE_H
#include <stddef.h>
#include <stdint.h>

/* Private ABI. One serialized owner; only its separate cancellation flag is shared. */
typedef struct {
    uintptr_t handle;
    int open;
    int runtime;
    int family; /* 4 or 6, never a platform AF_* value. */
    int last_error;
    int close_error; /* Latched uncertain reclamation; never silently reusable. */
} la_net_socket;

enum { LA_NET_OK = 0, LA_NET_AGAIN = 1, LA_NET_ERROR = -1, LA_NET_BAD_ADDRESS = -2 };
int la_net_open(la_net_socket *s, int family);
int la_net_listen(la_net_socket *s, const char *address, uint16_t port, uint32_t scope, int backlog);
int la_net_connect(la_net_socket *s, const char *address, uint16_t port, uint32_t scope);
int la_net_finish_connect(la_net_socket *s);
int la_net_accept(la_net_socket *s, la_net_socket *child);
int la_net_poll(la_net_socket *s, int write_ready, int timeout_ms);
int la_net_send(la_net_socket *s, const uint8_t *data, size_t length, size_t *count);
int la_net_recv(la_net_socket *s, uint8_t *data, size_t length, size_t *count);
int la_net_shutdown_write(la_net_socket *s);
int la_net_port(la_net_socket *s, uint16_t *port);
int la_net_close(la_net_socket *s);
int la_net_now(uint64_t *milliseconds);
#endif
