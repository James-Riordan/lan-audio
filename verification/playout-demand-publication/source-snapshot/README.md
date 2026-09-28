# LAN audio — custom desktop streaming candidate

**Engineering explanation:** [Read the program and its arguments](docs/literate/README.md).
**Documentation map:** [Choose a reading path](docs/README.md).
**Implementation entry:** [START HERE](docs/implementation/START_HERE.md).
The [roadmap](docs/implementation/roadmap.md), [per-file contracts](docs/reference/README.md)
and [acceptance matrix](docs/verification/acceptance-matrix.md) form the completion
specification. Proposed product files and commands are labeled explicitly.
The [completion sequence](docs/implementation/completion-sequence.md) gives the
next implementable slices; the [runtime blueprint](docs/implementation/runtime-blueprint.md)
defines their ownership and failure contracts.

This project prepares a cross-platform, peer-to-peer audio product whose initial
journeys are **Windows system audio → LAN → MacBook or iPhone playback**. `lan-audio` is a working
repository name, not a finalized product brand. The eventual runnable product is
a **ZApp**. Its current pure kernel remains project-owned; it has not been promoted
to a primitive or composed ZLib.

The pure core now also includes a [finite-f32 v2 codec](docs/protocol/v2.md) and
[negotiation gate](docs/protocol/negotiation.md). Their tests do not establish a
deployed v2 streaming product. [Independent protocol qualification](docs/verification/v2-independent.md)
now covers both application roles over fixture mTLS; real credentials/device
integration remain open. The [block assembler](docs/media/assembly.md) handles
variable frame chunks, final partial blocks and terminal source loss in the pure core.
The private [pending receive block](docs/media/pending-block.md) now preserves
unqueued suffixes through short writes and parser reuse; its TLS caller remains a
synthetic verification fixture. The live runtime now uses the same pending buffer
and lifecycle owners; native Apple and sustained timing qualification remain open.

Version 0.3 adds bounded concurrent frame queues and an optional miniaudio host
adapter. The Windows TLS probe now delivers authenticated synthetic PCM through
real callbacks on the silent backend. Explicit native profiles include Windows
system-output capture/playback and Mac playback; Mac device execution remains
unqualified. Actual foreground send/receive workers and fresh-pair provisioning now exist.
See the [desktop candidate workflow](docs/first-run.md) and
[live owner argument](docs/runtime/live-workers.md). Windows physical capture to an
independent TLS discard peer works; native Mac builds/speakers, clock control,
pairing UX and the complete Windows-to-Mac journey remain unqualified. The
[latest recovery qualification](verification/network-recovery/RESULTS.md) retains
receiver starvation failures as open release gates. See the [callback contract](docs/CALLBACKS.md)
and [historical callback evidence](verification/callback/RESULTS.md).

## Read and verify

1. [Product contract and acceptance](docs/PRODUCT.md): user journey and evidence needed.
2. [Architecture and complete file map](docs/ARCHITECTURE.md): ownership and extension seams.
3. [Mathematical foundation](docs/MATHEMATICS.md): units, state, proofs and limits.
4. [Dependency closure and decisions](docs/DEPENDENCIES.md): actual dependencies versus candidates.
5. [Verification and next implementation gates](docs/VERIFICATION.md).
6. [Wire and transport contract](docs/TRANSPORT.md).
7. [Current runtime design/model results](verification/runtime-blueprint/RESULTS.md),
   [independent v2 results](verification/v2-independent/RESULTS.md), and
   [historical relocation results](verification/handoff/RESULTS.md); the earlier
   [kernel preparation results](verification/RESULTS.md) remain historical evidence.

With Zig `0.17.0-dev.1859+dcceb318e` and sibling `../miniaudio-zig`:

```powershell
zig build test -j1 --summary all
zig build dependency-test -j1 --summary all
zig build test -j1 -Doptimize=ReleaseSafe --summary all
python tools/check_docs.py
zig build audio-test -j1 --summary all
zig build network-test -j1 --summary all
```

For the explicit Windows x86_64 loopback integration, with sibling `../tls-zig`:

```powershell
python tools/check_transport.py
zig build transport-probe -Dtransport-tests=true -j1
python tools/test_transport.py --output verification/local-interop/interop.json
```

The custody gate verifies 188 adopted TLS/SDK/fixture files. The harness also checks
the two DLLs beside the probe against the pinned SDK. Its credentials are public
test fixtures and must never be used for real devices or a deployed service.

Choose a new report path for every rerun; existing evidence is never overwritten.
After documentation changes, run `python tools/build_reference.py`, then
`python tools/check_docs.py` and `python tools/check_handoff.py`. Dependency pins
are verified separately and are never refreshed by the reference renderer.

[Formal-model instructions](spec/README.md) use an explicit Java executable and TLC
jar; they do not install or modify a global toolchain. Unit tests perform no network
I/O; network-test and the opt-in transport harness open ephemeral loopback sockets. Neither path
opens a physical audio device, records a microphone, starts a persistent service or
connects to another machine. `audio-test` exercises actual asynchronous null callbacks.

`zig build capture-test -j1 --summary all` is a separate, explicit Windows hardware
check: it opens a silent playback stream and captures system output briefly through
WASAPI, checks encoding and discards all samples. It does not save or transmit a
recording. This command is never a dependency of the default or null-backend tests.

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

The latest [native-failures increment](verification/native-failures/RESULTS.md)
adds controlled device-failure cleanup and a [serialized native TCP owner](docs/runtime/network-owner.md).
These components still need real identity, worker, Mac and two-host qualification.

## Foreground inspection command

`zig build app` installs the development `lan-audio` command. Run `zig build run -- devices`
to list system-output devices without starting audio, or use `devices --json`,
`help` and `version`. The streaming CLI and private-pair helper are described in
[first-run instructions](docs/first-run.md).
[Copied discovery](docs/runtime/device-discovery.md), [peer authorization](docs/runtime/peer-authorization.md)
and the [Apple receiver package](docs/implementation/work-packages/11-apple-receivers.md)
define the current implementation and remaining Mac/iPhone work.

The [verified channel](docs/runtime/verified-channel.md) now composes native TCP,
reviewed TLS identity export and v2 authorization/records, tested against an
independent peer. Actual foreground workers now consume that component.
[Automatic recovery](docs/runtime/network-recovery.md) restarts interrupted
sessions with bounded reserve growth. Native MacBook qualification, clock-drift
correction and an iPhone application remain open.

Declarative startup is available with `lan-audio run --config FILE --profile NAME`.
See [configuration profiles](docs/runtime/configuration.md) for validation, generated pairing templates
and the current capture/platform limits.
