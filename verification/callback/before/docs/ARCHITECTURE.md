# Architecture, directory structure and file contracts

## Ownership and dependency direction

`ZApp/product → host adapters → project kernel + technology libraries → OS`.

The kernel owns pure state/admission and fixed-window playout. miniaudio owns audio
device/DSP mechanics through `miniaudio-zig`. A qualified transport owns encryption,
peer-channel authentication, packet framing, congestion and delivery primitives;
the product owns pairing policy and media negotiation. Mediaz owns persistent media
catalog facts, not real-time packet delivery. Zap owns network policy; it is not
required for a direct peer connection. MetaOS integration is optional host lifecycle
integration, not a prerequisite for a standalone product.

No math concept automatically creates a new package. A ring buffer is a data
structure, not a seventh primitive ZLib. Extraction requires actual independent
consumers, a stable law/interface, ownership and a versioned migration contract.

## Present tree

```text
lan-audio/
  README.md
  build.zig
  build.zig.zon
  transport-lock.json
  src/         root.zig, session.zig, window.zig, wire.zig, receiver.zig
  tests/       core.zig, dependency.zig, wire.zig, tls_probe.zig
  docs/        PRODUCT.md, ARCHITECTURE.md, MATHEMATICS.md,
               DEPENDENCIES.md, VERIFICATION.md, TRANSPORT.md
  spec/        SessionWindow.tla/.cfg, EndDrain.tla/.cfg, README.md
  tools/       check_models.py, check_docs.py, check_transport.py, test_transport.py
  verification/ original preparation evidence; transport/ current qualification
```

Every current directory has executable or explanatory content. No empty
`platform/`, `codec/`, `security/`, `runtime/` or test-type forest pretends that those
systems exist. Add a directory only when several cohesive files justify it.

## Concurrency and future implementation seams

The present kernels are **single-owner, serialized** data structures. Their methods
are not atomic and cannot be called concurrently. Tests never imply otherwise.
For a real host, a media worker owns packet validation and the reorder window;
bounded SPSC queues transfer PCM to/from device callbacks. The callback only copies
available frames or fills silence. A control owner closes admission and joins
workers/devices before reclaiming any reachable object. Callback admission state
in the reference model is an abstraction; do not put a contended mutex in the
real-time callback to imitate the serialized model.

The later SPSC implementation needs an independent acquire/release proof, overflow
policy, fixed-address storage, cache-sharing review and concurrent stress tests.
Window reset and session restart must occur atomically from the host's perspective
after quiescence. A block authenticated under a former stream identifier cannot be
relabeled with the current local epoch.

Potential additions have specific obligations, not committed empty files:

| Future responsibility | Preconditions before adding source |
|---|---|
| Host audio adapter | Explicit capture/playback capability, ownership and permission/error mapping; miniaudio lifecycle tests |
| Physical PCM adapter | Wire codec exists; connect negotiated miniaudio PCM to bounded callback queues with conversion and deadline evidence |
| Product transport host | TLS/TCP probe exists; add deployed identity/pairing policy, real endpoints, pacing/backpressure and Mac backend qualification |
| Callback transfer queue | Memory-order proof and bounded copy/overflow behavior, no hidden allocation or lock |
| Clock/drift controller | Observable time domains, identifiability assumptions, stable controller, simulation and physical-device evidence |
| CLI/tray/service | Product commands and explicit permissions; render core state faithfully; lifecycle and packaging acceptance |

## Complete file-by-file map

| File | Owns / rationale | Contract and verification |
|---|---|---|
| `README.md` | Entry, status, reading order | Commands and claims agree with actual artifacts |
| `build.zig` | Pure module/tests and real dependency consumer | No device/network side effects; compile-only step separated from execution |
| `build.zig.zon` | Package identity and sibling dependency | Local development layout; release archive must vendor/package or replace sibling path with an immutable hash-pinned artifact |
| `src/root.zig` | Minimal public project-kernel surface | No hidden I/O; exports `Session`, `Window`, `wire` and `Receiver` |
| `src/session.zig` | Epoch/authentication/stop state | Rejected transitions preserve state; serialized host attestation, not a cryptographic verifier or synchronization primitive |
| `src/window.zig` | Bounded copied PCM storage and monotonic positions | Finite complete blocks, no allocation; O(samples/block) insert/tick; missing data becomes fully initialized silence; no integer wrap |
| `src/wire.zig` | Experimental record framing and PCM conversion | Max 996 bytes; poisoned parser on invalid input; explicit borrow lifetime; validation before output mutation |
| `src/receiver.zig` | Serialized authenticated-channel/stream/window composition | Host attests channel policy; one stream; bounded END drain; no post-END admission; no physical callback ownership claimed |
| `tests/core.zig` | State gates and independent output expectations | Authentication, stale completion, callback drain, holes, duplicate/late/far input, ring reuse, nonfinite PCM, exhaustion and 32,768 non-ring-oracle traces |
| `tests/dependency.zig` | Independent wrapper consumption | Calls native PCM function through the actual imported module; no hardware |
| `tests/wire.zig` | Independent framing and PCM expectations | Golden bytes, all record split points, all s16 values, invalid profile/length/identity and END drain |
| `tests/tls_probe.zig` | Windows synthetic receiver integration | Public mTLS fixtures, own ALPN, absolute transfer deadline, real loopback sockets; no device I/O |
| `docs/PRODUCT.md` | User journey, profiles, failures, acceptance | Distinguishes intended and implemented behavior; no invented timing result |
| `docs/ARCHITECTURE.md` | Ownership, current tree, file map, future seams | No competing semantic owners or empty source promises |
| `docs/MATHEMATICS.md` | Mathematical model and refinement obligations | Precise dimensions, assumptions, induction and counterexamples; proof scope stated |
| `docs/DEPENDENCIES.md` | Dependency closure and decisions | Actual wiring versus observed candidates; source paths and provenance |
| `docs/VERIFICATION.md` | Reproduction and acceptance interpretation | Describes meaningful checks and missing integration evidence |
| `docs/TRANSPORT.md` | Authoritative experimental wire/channel contract | Fields, state, limits, trust, ACK semantics, dependencies and failure behavior |
| `transport-lock.json` | Explicit TLS adoption identity | 188 exact source/SDK/fixture hashes and runtime import observations; changes require reviewed adoption |
| `spec/SessionWindow.tla` | Abstract composed transition relation | Safety invariants and fair-stop liveness; executable fault switches for falsification |
| `spec/SessionWindow.cfg` | Finite TLC scope | Capacity two, three positions, two epochs; no unbounded verification claim |
| `spec/EndDrain.tla` | END admission and completion abstraction | Bounded terminal frontier, no post-END admission, fair draining; three falsifying mutations |
| `spec/EndDrain.cfg` | END model bound | Capacity two, three positions; weak fairness of tick |
| `spec/README.md` | Model use and limits | Java/TLC explicit, source-to-model correspondence linked |
| `tools/check_models.py` | Bounded model runner and mutant expectations | Temporary state, 120-second subprocess bound; nonzero on missing counterexamples; no fetch or source repair |
| `tools/check_docs.py` | Local link and authored-file-map consistency | Read-only; coverage is a navigation check, not semantic approval |
| `tools/check_transport.py` | Read-only dependency and staged-DLL custody | Missing/changed/escaped paths fail; never refreshes hashes or fetches files |
| `tools/test_transport.py` | Independent Python mTLS sender and negative cases | Ephemeral loopback, synthetic PCM, public fixtures, bounded processes/sockets; checks expected failures and clean closure |
| `verification/RESULTS.md` | Human interpretation of executed evidence | Exact environment, results and limitations |
| `verification/models.json` | Generated TLC output and tool/model hashes | Evidence at one source revision; do not hand-edit into success |
| `verification/source-snapshot.json` | Generated source/dependency/tool hashes | Freshness observation, not a signed release or correctness proof |
| `verification/transport/RESULTS.md` | Current transport qualification interpretation | Distinguishes executed synthetic transfer from physical and cross-platform claims |
| `verification/transport/receipt.json` | Current exact source/evidence observations | Commands, hashes, tool versions and before-images; prior preparation snapshot remains historical |
| `.gitignore` | Generated-output boundaries | Does not hide source or model receipts |

Remaining files under `verification/` are generated command logs, with command,
exit status and source observation recorded by the results document. `.zig-cache/`
and `zig-out/` are generated and not source contracts. Upstream miniaudio has its
own complete adoption file map; the 4 MB vendor header is preserved, not rewritten.

## Build metadata and structured data

`build.zig` executes the Zig build graph. `build.zig.zon` describes Zig package
metadata and dependency paths. **ZON and ZSON are distinct contracts.** The observed
`C:/Projects/zson` owns ZSON language/schema/evaluation. This kernel has no runtime
configuration parser, so it neither imports ZSON nor creates invented `.zson`
configuration syntax. Adopt a real ZSON profile only when product configuration
exists, with current-source inspection and schema/error/lifetime tests.
