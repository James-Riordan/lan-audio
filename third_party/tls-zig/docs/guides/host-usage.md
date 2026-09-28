# Host integration and troubleshooting

Start with [current status](../verification/current.md), then use the existing README for runnable examples. These libraries expose protocol primitives; a general networking product still needs a host loop and operational policy.

## TLS records sequence

Construct one move-only Engine or Driver per connection with explicit trust, peer identity, ALPN and two clocks. Keep the transport context and cancellation flag alive. Drive a single operation at a time, preserving read-buffer lifetime. For Driver, call step with fresh monotonic milliseconds; yield fairly on again, poll the requested readiness on wait_input/wait_output and bound the poll by the operation deadline and cancellation wakeup. Handle each final result exactly once.

For direct Engine use, drain pending records even after need_input, retain every unconsumed input suffix and distinguish feed of an empty slice from transportEof. Queue at most one nonempty <=16 KiB plaintext block, then finish immutable flush retries. Do not read during a pending SSL_write. Engine cancellation is owner-thread work; another thread only signals the Driver's atomic flag.

Shutdown may report plaintext_available. Read the final data and resume shutdown using the original deadline. Only authenticated closed establishes peer close_notify. Application response completeness still belongs to the application. Early-response probing never authorizes discarding accepted ciphertext or retrying the request.

## QUIC offline sequence

Use the exported codec examples as executable guides to packet protection, reassembly, CID rules and recovery. Supply independent number spaces, immutable datagram input and separate decrypt scratch. Preflight whole-packet semantics before accept/pump. Apply send budgets after final padding and before submission. Actual TLS secrets, endpoint routing, streams and 1-RTT protection remain roadmap work.

| Symptom | Likely contract issue | Action |
| --- | --- | --- |
| TLS waits for input with output queued | Host did not drain protocol records | Drain/send pending bytes, preserve suffix, then poll. |
| TLS write cannot progress | Immutable write or ciphertext still pending | Continue same operation and original deadline; inspect wait result. |
| Shutdown stalls with final data | Host ignored plaintext_available | Read under retained close deadline, then resume shutdown. |
| QUIC ResourceLimit after many packets | Lifetime history exhausted | Close/fail explicitly; do not reset counters or reuse slots ad hoc. |
| QUIC ACK rejected | Unsent/skipped number, malformed range or wrong space | Verify authenticated ACK routing and sent-history registration. |
| Key derived but peer unauthenticated | Codec success mistaken for TLS completion | Enforce identity/ALPN/parameter completion gate. |
| Runtime version differs | Wrong SDK/DLL loaded | Check pinned/staged library hashes and loaded module paths. |
| Works on Windows but fails elsewhere | Build/consumer assumes Windows | Consult support matrix; implement and qualify a target adapter. |

No credentials, record plaintext, traffic secrets or raw certificate private keys belong in ordinary diagnostics. Log stable error categories, bounded sanitized peer diagnostics and source/build identifiers. Test fixtures are intentionally public and local-only.
