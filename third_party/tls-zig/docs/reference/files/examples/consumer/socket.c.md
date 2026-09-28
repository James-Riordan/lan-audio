# `examples/consumer/socket.c`

Source: [examples/consumer/socket.c](../../../../../examples/consumer/socket.c)  
Source SHA-256: `478368d14b74bde70c923fdba05287c1ad0ce404cfe8fa6028ea6acc9ae4975c`  
Snapshot bytes: 4830. Review date: 2026-09-26.

## Responsibility

Windows-only nonblocking loopback transport demonstration.

## Contract, ownership and failure behavior

Owns Winsock initialization/socket cleanup. send is deliberately capped at 7 bytes, receive at 113. -2 indicates would-block; EOF and errors remain distinct. Opening/accepting performs bounded polling outside the library.

## Next implementation work

Keep as a demo. T2 adds separate POSIX consumer support and cancellation-aware connect/accept policy. A production connector must define address resolution, IPv6, connect deadline and total resource limits.

## Verification obligations

Run the owning build or maintenance entry point described in the [verification guide](../../../../verification/strategy.md). A passive fixture/record is verified by hash and by its named consumers; it is not an executable test.

## Declaration-by-declaration work map

Each entry points to the exact current source. Adjacent source documentation is retained below. Direct error names and assigned self fields are mechanically extracted navigation cues; they exclude transitive errors, pointer writes and full branch reasoning. Use the module contract above for obligations.

### `demo_accept` — line 20

[Source declaration](../../../../../examples/consumer/socket.c#L20)

```c
intptr_t demo_accept(void) {
```

Review `demo_accept` as part of this file’s responsibility: Windows-only nonblocking loopback transport demonstration. Preserve the stated ownership/failure contract when extending this entry point.

### `demo_open` — line 53

[Source declaration](../../../../../examples/consumer/socket.c#L53)

```c
intptr_t demo_open(void) {
```

Review `demo_open` as part of this file’s responsibility: Windows-only nonblocking loopback transport demonstration. Preserve the stated ownership/failure contract when extending this entry point.

### `demo_close` — line 83

[Source declaration](../../../../../examples/consumer/socket.c#L83)

```c
void demo_close(intptr_t s) { closesocket((SOCKET)s); WSACleanup(); }
```

Review `demo_close` as part of this file’s responsibility: Windows-only nonblocking loopback transport demonstration. Preserve the stated ownership/failure contract when extending this entry point.

### `demo_send` — line 84

[Source declaration](../../../../../examples/consumer/socket.c#L84)

```c
int demo_send(intptr_t s, const unsigned char *p, int n) {
```

Review `demo_send` as part of this file’s responsibility: Windows-only nonblocking loopback transport demonstration. Preserve the stated ownership/failure contract when extending this entry point.

### `demo_recv` — line 88

[Source declaration](../../../../../examples/consumer/socket.c#L88)

```c
int demo_recv(intptr_t s, unsigned char *p, int n) {
```

Review `demo_recv` as part of this file’s responsibility: Windows-only nonblocking loopback transport demonstration. Preserve the stated ownership/failure contract when extending this entry point.

### `demo_poll` — line 92

[Source declaration](../../../../../examples/consumer/socket.c#L92)

```c
int demo_poll(intptr_t s, int writing, uint32_t timeout) {
```

Review `demo_poll` as part of this file’s responsibility: Windows-only nonblocking loopback transport demonstration. Preserve the stated ownership/failure contract when extending this entry point.

### `demo_sleep` — line 96

[Source declaration](../../../../../examples/consumer/socket.c#L96)

```c
void demo_sleep(uint32_t ms) { Sleep(ms); }
```

Review `demo_sleep` as part of this file’s responsibility: Windows-only nonblocking loopback transport demonstration. Preserve the stated ownership/failure contract when extending this entry point.

### `demo_setting` — line 97

[Source declaration](../../../../../examples/consumer/socket.c#L97)

```c
uint32_t demo_setting(const char *name, uint32_t fallback) {
```

Review `demo_setting` as part of this file’s responsibility: Windows-only nonblocking loopback transport demonstration. Preserve the stated ownership/failure contract when extending this entry point.

### `demo_now` — line 104

[Source declaration](../../../../../examples/consumer/socket.c#L104)

```c
uint64_t demo_now(void) { return GetTickCount64(); }
```

Review `demo_now` as part of this file’s responsibility: Windows-only nonblocking loopback transport demonstration. Preserve the stated ownership/failure contract when extending this entry point.

### `demo_name` — line 105

[Source declaration](../../../../../examples/consumer/socket.c#L105)

```c
const char *demo_name(void) {
```

Review `demo_name` as part of this file’s responsibility: Windows-only nonblocking loopback transport demonstration. Preserve the stated ownership/failure contract when extending this entry point.

### `demo_client_ca` — line 109

[Source declaration](../../../../../examples/consumer/socket.c#L109)

```c
const char *demo_client_ca(void) {
```

Review `demo_client_ca` as part of this file’s responsibility: Windows-only nonblocking loopback transport demonstration. Preserve the stated ownership/failure contract when extending this entry point.
