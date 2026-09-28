# Serialized native TCP ownership

`src/host/net/socket.zig` is the application-owned `network_host` module. Its
private `native.c`/`native.h` boundary implements Winsock and POSIX calls. The
first caller is `tests/integration/network_host.zig`. This layer supplies real
TCP operations; it does not authenticate a peer or constitute an audio worker.
The TLS owner's loopback fixture remains test-only and is not imported here.

## Why one owner

An operating-system descriptor is a reusable number. Closing it from a second
thread can redirect an outstanding operation to a later resource. Consequently
one serialized owner opens, connects, reads, writes and closes each `Socket`.
Only the cancellation atomic may be written concurrently. A socket may move
before it is borrowed, but its address stays stable while a transport callback
holds it. Field visibility does not authorize copying a live owner or changing
its state. Every borrower must finish before close or storage reclamation.

`empty -> open -> connecting -> connected` describes a pending connection;
immediate native success skips `connecting`. Listening uses `open -> listening`.
Accepted children start in caller-owned empty storage, become connected and own
their own Winsock reference. Releasing the listener therefore cannot tear down
accepted children. System I/O failure moves a connection to `failed`; close is
still required. A successful close returns to `empty`. Uncertain close becomes
`retired`, which rejects another close or initialization rather than retrying a
possibly reused descriptor. This is an explicit cleanup failure, not a leak-free
guarantee under arbitrary native failures.

## Calls and failure boundaries

| Operation | Contract and ownership |
| --- | --- |
| `init(family)` | Empty owner only. Create nonblocking TCP, disable inheritance, enable TCP_NODELAY, and make IPv6 sockets IPv6-only. Failed setup releases acquired native resources; uncertain release retires storage. |
| `listen(endpoint, backlog)` | Numeric address, explicit port (zero requests an ephemeral port), backlog 1..128. Windows uses exclusive address ownership. Invalid numeric input leaves the open owner reusable; bind/listen failure retains it for close. |
| `connect(endpoint)` | Numeric destination and nonzero port. True means connected; false means pending. One attempt per initialized socket. An invalid endpoint is rejected without consuming the open state. |
| `finishConnect()` | Pending only. Poll without waiting, then inspect SO_ERROR. Writable/error readiness alone cannot authorize a connection. |
| `accept(child)` | Listener and distinct empty child. False is would-block. Success acquires independent child ownership. Native child setup failure releases or retires the child; it never overwrites an existing owner. |
| `send(bytes)` | Nonempty borrowed input. A positive result accepts exactly that prefix; null accepts nothing. Caller retains the suffix. One native call, capped at INT_MAX bytes. |
| `receive(bytes)` | Nonempty borrowed output. Positive result initializes only that prefix; null is would-block; zero is read EOF. EOF is sticky and leaves the write direction available. |
| `shutdownWrite()` | Connected only; idempotent after success. Prior accepted data remains subject to TCP delivery; success is not peer receipt. |
| `wait(interest, deadline, canceled)` | Absolute monotonic milliseconds in the `nowMilliseconds()` domain. Cancellation and expiry leave the descriptor owned and usable. Each native wait is at most 10 ms; scheduler latency is additional. |
| `close()` | Borrowers finished. Retire the native handle once and release its runtime reference. Successful repeated close is harmless. Report uncertain close and do not blindly retry. |

Endpoint text is borrowed only during the call, must contain no interior NUL and
must be at most 45 bytes. IPv6 scope is a separate numeric field; IPv4 rejects a
nonzero scope. DNS, interface-name resolution, discovery and dual-stack fallback
are not implemented. Callers must explicitly choose the address, family and
scope. No loopback-only policy, fixture key, environment override or default
wildcard listener is hidden in this module.

## Deadline and progress argument

Let D be the original deadline and t the current monotonic time. An iteration
first checks cancellation and monotonicity. If t >= D, it returns Deadline;
otherwise it waits at most min(D-t, 10) milliseconds. It checks cancellation,
monotonicity and expiry again after the native call before accepting readiness.
The next iteration retains the last observed clock value. Repeated would-block
or interrupted calls never replace D with a later deadline. Under advancing
monotonic time and eventual scheduling, the loop terminates by readiness,
cancellation, native failure or expiry. There is no hard real-time scheduling
guarantee. Callers must check arithmetic when constructing D and service the same
deadline/cancellation between successful transfers, not only when I/O blocks.

The transport adapters have the reviewed TLS callback signatures and map socket
errors to TransportFailure. That signature match is not TLS integration evidence.
The real worker must retain the socket, Driver and borrowed buffers, serialize
operations, validate counts, and release them in order on every terminal path.

## Platform decisions and authority

Windows uses `select` for pending-connect completion, including its error set,
followed by SO_ERROR as described by Microsoft's
[connect documentation](https://learn.microsoft.com/en-us/windows/win32/api/winsock2/nf-winsock2-connect).
POSIX uses poll, treating hangup/error as readiness for the next resolving syscall.
Darwin suppresses SIGPIPE with SO_NOSIGPIPE; Linux uses MSG_NOSIGNAL. Apple's
[socket guidance](https://developer.apple.com/library/archive/documentation/NetworkingInternet/Conceptual/NetworkingTopics/Articles/UsingSocketsandSocketStreams.html)
and the Linux [poll contract](https://www.man7.org/linux/man-pages/man2/poll.2.html)
are the platform references. POSIX interrupted close is conservatively retired
without retry because descriptor reuse makes a generic retry unsafe; this may
retain an uncertain resource on platforms whose close semantics differ.

Inheritance flags are set after creation/accept. This does not prove atomic
exclusion against concurrent process creation; the current consumer does not
spawn child processes while sockets are being created. Qualify atomic creation
or coordinate process launch before introducing that use. This C boundary uses
platform SDK contracts and must be compiled and run on every supported target.
Portable source is not universal OS certification.

## Evidence and remaining gates

The source-scoped [native-failures phase](../../verification/native-failures/RESULTS.md)
records Windows Debug/ReleaseSafe checks and actual cross-build outcomes. Real
loopback tests compare exact ordered bytes through differing send/read boundaries,
read EOF followed by reverse traffic, listener release, refused connection,
invalid endpoints, absolute deadlines, concurrent cancellation, 32 ownership
cycles and bounded stalled-peer backpressure. The last fixture fails if 64 MiB
is accepted without observing would-block; it cannot silently call an unexercised
condition a pass. These tests do not measure all operating-system handle leaks,
Wi-Fi latency, hostile remote hosts or cleanup after every injected native fault.

Native Mac/Linux execution, independent socket-peer interoperability, network
failure injection, IPv6 link-local scope, TLS/identity composition and worker
joins remain gates. Mobile background networking, lifecycle and packaging have
not been qualified. The first product path remains Windows 10 to Intel macOS 12+
with separately provisioned real identities; no release gate is closed here.
