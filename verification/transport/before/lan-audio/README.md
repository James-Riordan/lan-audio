# LAN audio — architecture and reference kernel

This project prepares a cross-platform, peer-to-peer audio product whose initial
journey is **Windows system audio → LAN → Mac playback**. `lan-audio` is a working
repository name, not a finalized product brand. The eventual runnable product is
a **ZApp**. Its current pure kernel remains project-owned; it has not been promoted
to a primitive or composed ZLib.

The repository currently contains an executable, allocation-free reference kernel
for session admission and bounded PCM playout, a real linked miniaudio dependency,
file-by-file contracts, mathematical arguments and a bounded TLA+ model. It does
**not** yet stream audio, implement pairing or provide a tray/CLI product. Those
missing behaviors are explicit acceptance obligations, not empty source stubs.

## Read and verify

1. [Product contract and acceptance](docs/PRODUCT.md): user journey and evidence needed.
2. [Architecture and complete file map](docs/ARCHITECTURE.md): ownership and extension seams.
3. [Mathematical foundation](docs/MATHEMATICS.md): units, state, proofs and limits.
4. [Dependency closure and decisions](docs/DEPENDENCIES.md): actual dependencies versus candidates.
5. [Verification and next implementation gates](docs/VERIFICATION.md).
6. [Executed results](verification/RESULTS.md): exact checks and unverified claims.

With Zig `0.17.0-dev.1859+dcceb318e` and sibling `../miniaudio-zig`:

```powershell
zig build test -j1 --summary all
zig build dependency-test -j1 --summary all
zig build test -j1 -Doptimize=ReleaseSafe --summary all
python tools/check_docs.py
```

[Formal-model instructions](spec/README.md) use an explicit Java executable and TLC
jar; they do not install or modify a global toolchain. No build/test command here
opens a physical audio device, records a microphone, starts a service or connects
to another machine. The separate miniaudio tests initialize only its null backend.

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
