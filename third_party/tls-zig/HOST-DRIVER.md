# Nonblocking TLS host driver

`tls.Driver` (`tls.host.Driver`) in `src/driver.zig` owns one `Engine` and fixed
encrypted input/output custody buffers. The host continues to own its socket,
poller, clock, admission policy and cancellation wakeup mechanism. Do not call
Engine operations directly while the driver owns it. The driver is move-only;
serialize its calls and call `deinit` before releasing the socket/context/flag.

```zig
var canceled: std.atomic.Value(bool) = .init(false);
var driver = try tls.Driver.init(config, .{
    .context = &socket_context,
    .send = sendNonblocking,
    .recv = recvNonblocking,
}, &canceled);
defer driver.deinit();
try driver.beginHandshake(now_ms, absolute_deadline_ms);
```

Callbacks have signatures:

```zig
fn sendNonblocking(*anyopaque, []const u8) error{TransportFailure}!?usize;
fn recvNonblocking(*anyopaque, []u8) error{TransportFailure}!?usize;
```

`null` means would-block. A positive count identifies the sent/initialized prefix;
it must not exceed the slice length. Receive zero is raw transport EOF; send zero
is a transport contract error. Callbacks must be nonblocking and must not retain
slices or reenter the driver. Each `step(now_ms)` makes at most one callback or
one TLS/BIO call. The driver never calls a poller or starts threads.

| Operation | Begin call | Final result |
| --- | --- | --- |
| Handshake | `beginHandshake(now, deadline)` | `complete = 0` |
| Write | `beginWrite(bytes, now, deadline)` | `complete = bytes.len` |
| Read | `beginRead(buffer, now, deadline)` | `complete = count`, or `closed` |
| Local close | `beginShutdown(now, deadline)` | `closed`, or `plaintext_available` |
| Protocol output | `beginFlush(now, deadline)` | `complete = 0` |

Drive the active operation by repeatedly calling `step` with a fresh monotonic
timestamp. `again` means runnable work remains: schedule another step, yielding
fairly among connections. `wait_input` and `wait_output` mean poll the corresponding
socket readiness. Bound the poll timeout by `driver.deadline_ms - now` and the
host's cancellation wake cadence; even if the socket stays silent, call `step`
when a timeout or cancellation wake occurs. A readiness hint is not completion.

The driver preserves partially sent output and unconsumed input suffixes; it never
receives over a pending input suffix. Output is drained and sent before an operation
reports completion or asks for socket input. A completed write only means the local
transport accepted its bytes, not that the peer application received them.

Only one operation may be active. A second begin call returns `OperationInProgress`.
Writes copy one nonempty block of at most 16 KiB. Read buffers are borrowed until
the final result/error; use their contents only after successful `complete`.
Handshake must complete before read/write/flush/shutdown. `beginRead` cannot
interrupt a write; the optional peer probe below observes early responses while
preserving the accepted write.

## Early-response probe (0.1.4)

`probePeer(buffer, now, idle_deadline)` is allowed when idle or during a write.
It performs at most one TLS/BIO operation or receive callback and never sends,
discards, pauses or completes the accepted write. The buffer is borrowed only for
that call. A probe during a write always uses that write's original deadline;
its `idle_deadline` argument cannot extend it. Between blocks, pass the same
absolute upload deadline for every probe, flush and write.

| Probe result | Host action |
| --- | --- |
| `again` | Schedule another probe fairly, with fresh time. |
| `no_data` | No plaintext currently available; may continue upload or poll. This is nonterminal. |
| `data = count` | Consume the authenticated TLS bytes and continue bounded response parsing. |
| `write_pending` | Resume `step`; the underlying SSL_write must finish its immutable retry before any read. |
| `output_pending` | Resume the active write with `step`, or when idle use `beginFlush` and drive it to completion. |
| `closed` | Peer close_notify was authenticated; an active accepted write still needs completion or terminal failure. |

The supported upload pattern buffers/validates the request first, then queues
blocks of at most 16 KiB. Probe between blocks and while a completed SSL_write's
ciphertext is backpressured. After final HTTP headers, stop queueing new blocks,
finish the already accepted block and all pending ciphertext under the original
deadline, then read the bounded response and complete authenticated shutdown.
Never bypass pending ciphertext to send close_notify. If the peer refuses the
accepted block or withholds closure, fail closed under the relevant deadline.
`data` alone does not establish a complete or committable HTTP response. HTTP
framing, informational responses and downstream commit policy belong to the host.
This is not general concurrent read/write or an upload-abort API.

See `upload` in `examples/consumer/main.zig` for a runnable example. Its test-only
transport gate injects would-block after 17 ciphertext bytes over real TCP. A
fragmented early 413 is observed before that accepted block is released; the peer
then verifies exactly one intact block and no second block. The fixture does not
claim to reproduce native kernel send-buffer saturation.

On `plaintext_available`, shutdown has paused with final peer data intact. Begin
a read, consume the returned bytes, then begin shutdown again. The first shutdown
deadline remains in force across these operations; supplying later deadlines cannot
extend it. `closed` authenticates peer close_notify. Raw EOF without it remains a
TLS error, even after valid final data was delivered. Already-accepted write bytes
must finish before beginning shutdown.

Another thread may signal `canceled.store(true, .release)`. The driver observes
that flag with acquire loads on its serialized thread and destroys its Engine on
cancel/deadline/transport failure. Cancellation does not roll back transmitted
bytes or interrupt an in-flight OpenSSL call. Never call driver/Engine methods
from the canceling thread. `Canceled` and `OperationDeadline` are terminal. A
backward clock returns `InvalidState` without extending the deadline.

Normal operation TLS failures drain any generated alert under the same deadline
before returning their terminal error. A fatal probe error returns immediately and
terminates the driver, preserving diagnostics: it cannot bypass blocked ciphertext
to deliver an alert. Transport failure or cancellation can prevent alert
delivery. After a returned TLS failure, `driver.engine.diagnostics()` remains
available until deinit; timeout/cancel/transport abort releases the Engine.

The driver adds a 32 KiB encrypted receive buffer and a 16 KiB encrypted send buffer.
These supplement Engine's BIO/write buffers and do not bound OpenSSL's total memory
or per-call CPU use. No reconnect/replay, hostname discovery, OS trust loading,
revocation policy or application authorization is introduced.

`examples/consumer` shows this loop over real nonblocking Winsock with 25 ms poll
slices, independent absolute operation deadlines and a separate cancellation
thread. `zig build host-test -j1` runs deterministic short-I/O/deadline/cancellation
regressions. `python tools/tcp_interop.py` tests the separately built consumer
against Python's TLS server on an ephemeral loopback port.
`python tools/tcp_server_interop.py` exercises the consumer's single-connection
server mode, including required client certificates and incomplete closure.
`python tools/tcp_upload_interop.py` checks early response, blocked-write deadline,
cross-thread cancellation, raw EOF and withheld close_notify with an independent
Python TLS server.
