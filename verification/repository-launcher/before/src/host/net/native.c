#ifndef _WIN32
#define _POSIX_C_SOURCE 200809L
#endif
#include "native.h"
#include <limits.h>
#include <string.h>
#ifdef _WIN32
#define WIN32_LEAN_AND_MEAN
#include <winsock2.h>
#include <ws2tcpip.h>
#include <windows.h>
typedef SOCKET native_socket;
typedef int native_length;
#define INVALID_NATIVE INVALID_SOCKET
#define close_native closesocket
#define socket_error() WSAGetLastError()
#define INVALID_ARGUMENT WSAEINVAL
#else
#include <errno.h>
#include <fcntl.h>
#include <poll.h>
#include <time.h>
#include <unistd.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <netinet/tcp.h>
#include <arpa/inet.h>
typedef int native_socket;
typedef socklen_t native_length;
#define INVALID_NATIVE (-1)
#define close_native close
#define socket_error() errno
#define INVALID_ARGUMENT EINVAL
#endif

static native_socket handle(const la_net_socket *s) { return (native_socket)s->handle; }
static int failure(la_net_socket *s, int error) { s->last_error = error; return LA_NET_ERROR; }
static int bad_address(la_net_socket *s) { s->last_error = INVALID_ARGUMENT; return LA_NET_BAD_ADDRESS; }
static int retryable(int error) {
#ifdef _WIN32
    return error == WSAEWOULDBLOCK || error == WSAEINTR;
#else
    return error == EAGAIN || error == EWOULDBLOCK || error == EINTR;
#endif
}
static int pending_connect(int error) {
#ifdef _WIN32
    return error == WSAEWOULDBLOCK || error == WSAEINPROGRESS || error == WSAEALREADY;
#else
    return error == EINPROGRESS || error == EALREADY || error == EINTR;
#endif
}
static int runtime_start(la_net_socket *s) {
#ifdef _WIN32
    WSADATA data;
    int result = WSAStartup(MAKEWORD(2, 2), &data);
    if (result != 0) return failure(s, result);
    s->runtime = 1;
#else
    (void)s;
#endif
    return LA_NET_OK;
}
static void runtime_stop(la_net_socket *s) {
#ifdef _WIN32
    if (s->runtime) { if (WSACleanup() != 0) s->close_error = socket_error(); s->runtime = 0; }
#else
    (void)s;
#endif
}
static int configure(la_net_socket *s) {
    native_socket fd = handle(s);
    int one = 1;
#ifdef _WIN32
    u_long nonblocking = 1;
    if (ioctlsocket(fd, FIONBIO, &nonblocking) != 0) return failure(s, socket_error());
    if (!SetHandleInformation((HANDLE)fd, HANDLE_FLAG_INHERIT, 0)) return failure(s, (int)GetLastError());
#else
    int flags = fcntl(fd, F_GETFL, 0);
    if (flags < 0 || fcntl(fd, F_SETFL, flags | O_NONBLOCK) < 0) return failure(s, socket_error());
    flags = fcntl(fd, F_GETFD, 0);
    if (flags < 0 || fcntl(fd, F_SETFD, flags | FD_CLOEXEC) < 0) return failure(s, socket_error());
#ifdef SO_NOSIGPIPE
    if (setsockopt(fd, SOL_SOCKET, SO_NOSIGPIPE, &one, sizeof(one)) != 0) return failure(s, socket_error());
#endif
#endif
    if (setsockopt(fd, IPPROTO_TCP, TCP_NODELAY, (const char *)&one, sizeof(one)) != 0) return failure(s, socket_error());
    return LA_NET_OK;
}
int la_net_open(la_net_socket *s, int family) {
    native_socket fd;
    int one = 1;
    if (s->open || s->runtime || (family != 4 && family != 6)) return failure(s, INVALID_ARGUMENT);
    if (runtime_start(s) != LA_NET_OK) return LA_NET_ERROR;
    fd = socket(family == 4 ? AF_INET : AF_INET6, SOCK_STREAM, IPPROTO_TCP);
    if (fd == INVALID_NATIVE) { int error = socket_error(); runtime_stop(s); return failure(s, error); }
    s->handle = (uintptr_t)fd; s->open = 1; s->family = family;
    if (family == 6 && setsockopt(fd, IPPROTO_IPV6, IPV6_V6ONLY, (const char *)&one, sizeof(one)) != 0) {
        int error = socket_error(); la_net_close(s); return failure(s, error);
    }
    if (configure(s) != LA_NET_OK) { int error = s->last_error; la_net_close(s); return failure(s, error); }
    return LA_NET_OK;
}
static int address_of(la_net_socket *s, const char *text, uint16_t port, uint32_t scope, struct sockaddr_storage *out, native_length *length) {
    memset(out, 0, sizeof(*out));
    if (s->family == 4) {
        struct sockaddr_in *a = (struct sockaddr_in *)out;
        if (scope != 0) return bad_address(s);
        a->sin_family = AF_INET; a->sin_port = htons(port);
        if (inet_pton(AF_INET, text, &a->sin_addr) != 1) return bad_address(s);
        *length = sizeof(*a);
    } else {
        struct sockaddr_in6 *a = (struct sockaddr_in6 *)out;
        a->sin6_family = AF_INET6; a->sin6_port = htons(port); a->sin6_scope_id = scope;
        if (inet_pton(AF_INET6, text, &a->sin6_addr) != 1) return bad_address(s);
        *length = sizeof(*a);
    }
    return LA_NET_OK;
}
int la_net_listen(la_net_socket *s, const char *address, uint16_t port, uint32_t scope, int backlog) {
    struct sockaddr_storage addr; native_length length;
#ifdef _WIN32
    int one = 1;
    if (setsockopt(handle(s), SOL_SOCKET, SO_EXCLUSIVEADDRUSE, (const char *)&one, sizeof(one)) != 0) return failure(s, socket_error());
#endif
    if (address_of(s, address, port, scope, &addr, &length) != LA_NET_OK) return LA_NET_BAD_ADDRESS;
    if (bind(handle(s), (struct sockaddr *)&addr, length) != 0 || listen(handle(s), backlog) != 0) return failure(s, socket_error());
    return LA_NET_OK;
}
int la_net_connect(la_net_socket *s, const char *address, uint16_t port, uint32_t scope) {
    struct sockaddr_storage addr; native_length length;
    if (address_of(s, address, port, scope, &addr, &length) != LA_NET_OK) return LA_NET_BAD_ADDRESS;
    if (connect(handle(s), (struct sockaddr *)&addr, length) == 0) return LA_NET_OK;
    { int error = socket_error(); return pending_connect(error) ? LA_NET_AGAIN : failure(s, error); }
}
int la_net_finish_connect(la_net_socket *s) {
    int error = 0; native_length length = sizeof(error);
    if (getsockopt(handle(s), SOL_SOCKET, SO_ERROR, (char *)&error, &length) != 0) return failure(s, socket_error());
    return error == 0 ? LA_NET_OK : failure(s, error);
}
int la_net_accept(la_net_socket *s, la_net_socket *child) {
    native_socket fd = accept(handle(s), NULL, NULL);
    if (fd == INVALID_NATIVE) { int error = socket_error(); return retryable(error) ? LA_NET_AGAIN : failure(s, error); }
    child->handle = (uintptr_t)fd; child->open = 1; child->family = s->family;
    if (runtime_start(child) != LA_NET_OK) {
        int error = child->last_error; la_net_close(child); return failure(child, error);
    }
    if (configure(child) != LA_NET_OK) { int error = child->last_error; la_net_close(child); return failure(child, error); }
    return LA_NET_OK;
}
int la_net_poll(la_net_socket *s, int write_ready, int timeout_ms) {
    int result;
#ifdef _WIN32
    fd_set wanted, errors;
    struct timeval timeout;
    FD_ZERO(&wanted); FD_ZERO(&errors); FD_SET(handle(s), &wanted); FD_SET(handle(s), &errors);
    timeout.tv_sec = timeout_ms / 1000; timeout.tv_usec = (timeout_ms % 1000) * 1000;
    result = select(0, write_ready ? NULL : &wanted, write_ready ? &wanted : NULL, &errors, &timeout);
#else
    struct pollfd p;
    p.fd = handle(s); p.events = write_ready ? POLLOUT : POLLIN; p.revents = 0;
    result = poll(&p, 1, timeout_ms);
#endif
    if (result > 0) return LA_NET_OK; /* Includes hangup/error: the next syscall resolves it. */
    if (result == 0) return LA_NET_AGAIN;
    { int error = socket_error(); return retryable(error) ? LA_NET_AGAIN : failure(s, error); }
}
int la_net_send(la_net_socket *s, const uint8_t *data, size_t length, size_t *count) {
    int amount = (int)(length > INT_MAX ? INT_MAX : length);
    int flags = 0;
#ifdef MSG_NOSIGNAL
    flags = MSG_NOSIGNAL;
#endif
    int result = (int)send(handle(s), (const char *)data, amount, flags);
    if (result > 0) { *count = (size_t)result; return LA_NET_OK; }
    if (result == 0) return failure(s, INVALID_ARGUMENT);
    { int error = socket_error(); return retryable(error) ? LA_NET_AGAIN : failure(s, error); }
}
int la_net_recv(la_net_socket *s, uint8_t *data, size_t length, size_t *count) {
    int amount = (int)(length > INT_MAX ? INT_MAX : length);
    int result = (int)recv(handle(s), (char *)data, amount, 0);
    if (result >= 0) { *count = (size_t)result; return LA_NET_OK; }
    { int error = socket_error(); return retryable(error) ? LA_NET_AGAIN : failure(s, error); }
}
int la_net_shutdown_write(la_net_socket *s) {
#ifdef _WIN32
    int how = SD_SEND;
#else
    int how = SHUT_WR;
#endif
    return shutdown(handle(s), how) == 0 ? LA_NET_OK : failure(s, socket_error());
}
int la_net_port(la_net_socket *s, uint16_t *port) {
    struct sockaddr_storage addr; native_length length = sizeof(addr);
    if (getsockname(handle(s), (struct sockaddr *)&addr, &length) != 0) return failure(s, socket_error());
    *port = ntohs(s->family == 4 ? ((struct sockaddr_in *)&addr)->sin_port : ((struct sockaddr_in6 *)&addr)->sin6_port);
    return LA_NET_OK;
}
int la_net_close(la_net_socket *s) {
    int result = 0, error = 0;
    if (s->open) {
        native_socket fd = handle(s);
        /* Retire once. In particular, never retry POSIX close after EINTR: its
           descriptor may already have been reused by another thread. */
        s->open = 0; s->handle = 0;
        result = close_native(fd);
        if (result != 0) { error = socket_error(); s->close_error = error; }
    }
    runtime_stop(s);
    return s->close_error == 0 ? LA_NET_OK : failure(s, s->close_error);
}
int la_net_now(uint64_t *milliseconds) {
#ifdef _WIN32
    LARGE_INTEGER ticks, frequency;
    if (!QueryPerformanceCounter(&ticks) || !QueryPerformanceFrequency(&frequency) ||
        ticks.QuadPart < 0 || frequency.QuadPart <= 0) return LA_NET_ERROR;
    return la_net_clock_milliseconds((uint64_t)ticks.QuadPart, (uint64_t)frequency.QuadPart, milliseconds);
#else
    struct timespec now;
    if (clock_gettime(CLOCK_MONOTONIC, &now) != 0) return LA_NET_ERROR;
    *milliseconds = (uint64_t)now.tv_sec * 1000 + (uint64_t)now.tv_nsec / 1000000;
#endif
    return LA_NET_OK;
}

/* Split before multiplying: long uptimes must not overflow ticks*1000.
   The frequency bound makes remainder*1000 safe. Outputs commit only on success. */
int la_net_clock_milliseconds(uint64_t ticks, uint64_t frequency, uint64_t *milliseconds) {
    if (!milliseconds || frequency == 0 || frequency > UINT64_MAX / 1000) return LA_NET_ERROR;
    uint64_t whole = ticks / frequency;
    uint64_t part = ((ticks % frequency) * 1000) / frequency;
    if (whole > (UINT64_MAX - part) / 1000) return LA_NET_ERROR;
    *milliseconds = whole * 1000 + part;
    return LA_NET_OK;
}
