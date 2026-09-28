/* Windows-only demonstration transport. Network ownership stays outside tls. */
#define WIN32_LEAN_AND_MEAN
#include <winsock2.h>
#include <windows.h>
#include <stdint.h>
#include <stdlib.h>
#include <stdio.h>

intptr_t demo_accept(void) {
    WSADATA data;
    if (WSAStartup(MAKEWORD(2, 2), &data)) return -1;
    SOCKET listener = socket(AF_INET, SOCK_STREAM, IPPROTO_TCP);
    if (listener == INVALID_SOCKET) { WSACleanup(); return -1; }
    u_long nonblocking = 1;
    BOOL exclusive = TRUE;
    struct sockaddr_in address = {0};
    address.sin_family = AF_INET;
    address.sin_addr.s_addr = htonl(INADDR_LOOPBACK);
    int size = sizeof address;
    if (setsockopt(listener, SOL_SOCKET, SO_EXCLUSIVEADDRUSE, (const char *)&exclusive, sizeof exclusive) ||
        ioctlsocket(listener, FIONBIO, &nonblocking) ||
        bind(listener, (const struct sockaddr *)&address, sizeof address) ||
        listen(listener, 1) || getsockname(listener, (struct sockaddr *)&address, &size)) {
        closesocket(listener); WSACleanup(); return -1;
    }
    /* Tell the test harness the assigned port; it never reserves/reuses a port. */
    printf("PORT:%u\n", (unsigned)ntohs(address.sin_port));
    fflush(stdout);
    WSAPOLLFD pollfd = {listener, POLLRDNORM, 0};
    if (WSAPoll(&pollfd, 1, 5000) <= 0) {
        closesocket(listener); WSACleanup(); return -1;
    }
    SOCKET client = accept(listener, NULL, NULL);
    closesocket(listener);
    if (client == INVALID_SOCKET) { WSACleanup(); return -1; }
    if (ioctlsocket(client, FIONBIO, &nonblocking)) {
        closesocket(client); WSACleanup(); return -1;
    }
    return (intptr_t)client;
}

intptr_t demo_open(void) {
    const char *text = getenv("TLS_DEMO_PORT");
    char *end;
    if (!text || !*text) return -1;
    long port = strtol(text, &end, 10);
    if (*end || port < 1 || port > 65535) return -1;
    WSADATA data;
    if (WSAStartup(MAKEWORD(2, 2), &data)) return -1;
    SOCKET s = socket(AF_INET, SOCK_STREAM, IPPROTO_TCP);
    if (s == INVALID_SOCKET) { WSACleanup(); return -1; }
    struct sockaddr_in addr = {0};
    addr.sin_family = AF_INET;
    addr.sin_port = htons((u_short)port);
    addr.sin_addr.s_addr = htonl(INADDR_LOOPBACK);
    u_long nonblocking = 1;
    if (ioctlsocket(s, FIONBIO, &nonblocking)) {
        closesocket(s); WSACleanup(); return -1;
    }
    if (connect(s, (const struct sockaddr *)&addr, sizeof addr)) {
        int err = WSAGetLastError();
        WSAPOLLFD fd = {s, POLLWRNORM, 0};
        int socket_error = 0, error_size = sizeof socket_error;
        if ((err != WSAEWOULDBLOCK && err != WSAEINPROGRESS) ||
            WSAPoll(&fd, 1, 2000) <= 0 ||
            getsockopt(s, SOL_SOCKET, SO_ERROR, (char *)&socket_error, &error_size) || socket_error) {
            closesocket(s); WSACleanup(); return -1;
        }
    }
    return (intptr_t)s;
}
void demo_close(intptr_t s) { closesocket((SOCKET)s); WSACleanup(); }
int demo_send(intptr_t s, const unsigned char *p, int n) {
    int result = send((SOCKET)s, (const char *)p, n > 7 ? 7 : n, 0);
    return result == SOCKET_ERROR && WSAGetLastError() == WSAEWOULDBLOCK ? -2 : result;
}
int demo_recv(intptr_t s, unsigned char *p, int n) {
    int result = recv((SOCKET)s, (char *)p, n > 113 ? 113 : n, 0);
    return result == SOCKET_ERROR && WSAGetLastError() == WSAEWOULDBLOCK ? -2 : result;
}
int demo_poll(intptr_t s, int writing, uint32_t timeout) {
    WSAPOLLFD fd = {(SOCKET)s, writing ? POLLWRNORM : POLLRDNORM, 0};
    return WSAPoll(&fd, 1, (int)timeout);
}
void demo_sleep(uint32_t ms) { Sleep(ms); }
uint32_t demo_setting(const char *name, uint32_t fallback) {
    const char *text = getenv(name);
    char *end;
    if (!text || !*text) return fallback;
    unsigned long n = strtoul(text, &end, 10);
    return *end || n > 60000 ? fallback : (uint32_t)n;
}
uint64_t demo_now(void) { return GetTickCount64(); }
const char *demo_name(void) {
    const char *name = getenv("TLS_DEMO_NAME");
    return name ? name : "localhost";
}
const char *demo_client_ca(void) {
    const char *path = getenv("TLS_DEMO_CLIENT_CA");
    return path ? path : "tests/fixtures/ca.pem";
}
