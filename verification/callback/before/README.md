# LAN audio — authenticated media reference

This project prepares a cross-platform, peer-to-peer audio product whose initial
journey is **Windows system audio → LAN → Mac playback**. `lan-audio` is a working
repository name, not a finalized product brand. The eventual runnable product is
a **ZApp**. Its current pure kernel remains project-owned; it has not been promoted
to a primitive or composed ZLib.

Version 0.2 adds bounded PCM record framing and a composed receiver to the pure
session/playout kernel. An opt-in Windows probe receives synthetic PCM over real,
mutually authenticated TLS/TCP from an independent Python peer. It checks the audio
protocol, stream identity, sample contents and authenticated shutdown. Physical
capture/playback, pairing UX, callback transfer and a user-facing product remain
unimplemented. The miniaudio binding is separately linked and qualified.

## Read and verify

1. [Product contract and acceptance](docs/PRODUCT.md): user journey and evidence needed.
2. [Architecture and complete file map](docs/ARCHITECTURE.md): ownership and extension seams.
3. [Mathematical foundation](docs/MATHEMATICS.md): units, state, proofs and limits.
4. [Dependency closure and decisions](docs/DEPENDENCIES.md): actual dependencies versus candidates.
5. [Verification and next implementation gates](docs/VERIFICATION.md).
6. [Wire and transport contract](docs/TRANSPORT.md).
7. [Current executed results](verification/transport/RESULTS.md); the earlier
   [kernel preparation results](verification/RESULTS.md) remain historical evidence.

With Zig `0.17.0-dev.1859+dcceb318e` and sibling `../miniaudio-zig`:

```powershell
zig build test -j1 --summary all
zig build dependency-test -j1 --summary all
zig build test -j1 -Doptimize=ReleaseSafe --summary all
python tools/check_docs.py
```

For the explicit Windows x86_64 loopback integration, with sibling `../tls-zig`:

```powershell
python tools/check_transport.py
zig build transport-probe -Dtransport-tests=true -j1
python tools/test_transport.py
```

The custody gate verifies 188 adopted TLS/SDK/fixture files. The harness also checks
the two DLLs beside the probe against the pinned SDK. Its credentials are public
test fixtures and must never be used for real devices or a deployed service.

[Formal-model instructions](spec/README.md) use an explicit Java executable and TLC
jar; they do not install or modify a global toolchain. Unit tests perform no network
I/O; the opt-in transport harness opens ephemeral loopback sockets. Neither path
opens a physical audio device, records a microphone, starts a persistent service or
connects to another machine. Separate miniaudio tests initialize its null backend.

## Engineering intent

The supplied JCR directive is design context: precise contracts, coherent structure,
literate rationale, proportionate formal work and honest evidence. The current
request defines scope. Historical directions in other repositories are not orders
to modify their products. Ownership follows the observed JCR architecture records,
with source and executed evidence distinguished from proposals.

Neither an attractive tree nor a finite model check establishes universal perfection.
Each package has an explicit boundary, every authored file has a purpose, and every
remaining product claim has an acceptance gate. No license for new JCR-authored
files has been selected; upstream licensing is preserved separately.
