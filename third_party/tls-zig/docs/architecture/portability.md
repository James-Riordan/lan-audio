# Portability and resource contract

Current observed test host: Windows x86_64, pinned Zig 0.17.0-dev.1859+dcceb318e and the locked OpenSSL 3.5.8 SDK. This is evidence for that combination only.

| Component | Current status | Required before another target is supported |
| --- | --- | --- |
| QUIC pure Zig codecs/state | Native Windows tests pass | Compile and execute vectors/tests on each target; check endianness/alignment/usize assumptions. |
| TLS Engine/Driver semantics | Socket-independent API | Native provider ABI/link/runtime and time_t checks on each target. |
| TLS build | Windows .dll.a imports and DLL staging | Explicit platform selection, library suffix/search policy and clean consumer build. |
| TLS TCP demo | Winsock/IPv4 loopback | Separate platform adapter, IPv6 journey and cancellation/connect semantics. |
| SDK scripts | Absolute MSYS/Strawberry paths | Validated tool inputs and configuration fingerprint with rebuild invalidation. |
| Formal/docs tools | Python standard library | Python 3.10+ smoke run; no shell-specific runtime assumption. |

Do not assume a standardTargetOptions call makes downstream linkage portable. Unsupported targets should fail with a clear configuration diagnostic. Runtime feature detection must not silently downgrade authentication or cryptographic requirements.

## Resource envelope

Document capacity parameters in bytes, packets, events and connections. QUIC Assembler has O(B) byte/presence storage; sender/recovery has O(B+P) retained storage. ACK validation scans at most 32 ranges against retained P history entries; whole-packet CRYPTO overlap admission compares up to 64 chunks pairwise. These bounded algorithms still need measurements at the selected B/P limits. Large generics can exceed small thread stacks; allocate large connection objects deliberately.

TLS owns two 32 KiB BIO buffers and a 16 KiB pending plaintext block; Driver adds 32 KiB input and 16 KiB output arrays. This is not the total connection allocation. SSL_CTX/SSL, certificates and provider structures allocate beyond those arrays. Set host concurrency limits and measure peak resources before claiming a safe deployment envelope.

Benchmark with pinned CPU/OS/compiler/backend/config, record sample distributions, and separate successful throughput from rejection-path cost. Optimize only after a measured bottleneck while retaining invariant tests and independent oracles. Hardware-specific acceleration requires a portable functional path or an explicit unsupported capability.
