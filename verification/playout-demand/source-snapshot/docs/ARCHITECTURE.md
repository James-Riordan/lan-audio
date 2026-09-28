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
  AGENTS.md    short implementation entry
  src/         root.zig; session/, media/, protocol/, audio/, host/
  tests/       unit/, integration/, hardware/; dependency.zig
  docs/        PRODUCT.md, ARCHITECTURE.md, MATHEMATICS.md,
               DEPENDENCIES.md, VERIFICATION.md, TRANSPORT.md, CALLBACKS.md
               implementation/, design/, reference/, verification/
  spec/        session/, stream/, concurrency/; README.md
  tools/       custody, models, peer tests, reference renderer and handoff checks
  verification/ preserved phases; handoff/ relocation and documentation evidence
```

Every current directory has executable or explanatory content. No empty
`platform/`, `codec/`, `security/`, `runtime/` or test-type forest pretends that those
systems exist. Add a directory only when several cohesive files justify it.

## Concurrency and future implementation seams

The session, receiver and window kernels are **single-owner, serialized** structures.
Their methods are not atomic and cannot be called concurrently. The new frame queues
are specifically SPSC; their ownership and atomics do not extend to other kernels.
For a real host, a media worker owns packet validation and the reorder window;
bounded SPSC queues transfer PCM to/from device callbacks. The callback only copies
available frames or fills silence. A control owner closes admission and joins
workers/devices before reclaiming any reachable object. Callback admission state
in the reference model is an abstraction; do not put a contended mutex in the
real-time callback to imitate the serialized model.

The SPSC implementation has an acquire/release argument, explicit overflow policy,
fixed-address contract, separated cursors, concurrent tests and a bounded publication
model. Its optional device adapter is separate from the platform-independent core.
Window reset and session restart must occur atomically from the host's perspective
after quiescence. A block authenticated under a former stream identifier cannot be
relabeled with the current local epoch.

Potential additions have specific obligations, not committed empty files:

| Future responsibility | Preconditions before adding source |
|---|---|
| Host audio adapter extensions | Explicit profiles exist; add endpoint selection, richer permission/device-loss mapping and Mac qualification |
| Physical PCM integration | Queues and callback adapter exist; connect the production capture/network path with loss policy and deadline evidence |
| Product transport host | TLS/TCP probe exists; add deployed identity/pairing policy, real endpoints, pacing/backpressure and Mac backend qualification |
| Callback scheduling | SPSC transfer exists; add production pacing, prefill, cancellation and worker join integration |
| Clock/drift controller | Observable time domains, identifiability assumptions, stable controller, simulation and physical-device evidence |
| CLI/tray/service | Product commands and explicit permissions; render core state faithfully; lifecycle and packaging acceptance |

## Primary file map

The exhaustive [granular reference](reference/README.md) covers all three admitted
projects and every installed SDK file. The [deep layout](implementation/layout.md)
defines current directories and future responsibilities. The table below remains
a concise implementation overview; the reference index owns complete file coverage.

| File | Owns / rationale | Contract and verification |
|---|---|---|
| `README.md` | Entry, status, reading order | Commands and claims agree with actual artifacts |
| `build.zig` | Core, host modules and explicit qualification graph | Default core tests, null callbacks, hardware capture and network tests are separate steps; compilation is not execution |
| `build.zig.zon` | Package identity and sibling dependency | Local development layout; release archive must vendor/package or replace sibling path with an immutable hash-pinned artifact |
| `src/root.zig` | Public project-owned state and transfer mechanisms | No hidden I/O; exports existing v1 kernels/queues plus `Format`, `wire_v2` and `Negotiation` |
| `src/session/session.zig` | Epoch/authentication/stop state | Rejected transitions preserve state; serialized host attestation, not a cryptographic verifier or synchronization primitive |
| `src/media/playout_window.zig` | Bounded copied PCM storage and monotonic positions | Finite complete blocks, no allocation; O(samples/block) insert/tick; missing data becomes fully initialized silence; no integer wrap |
| `src/protocol/v1.zig` | Experimental record framing and PCM conversion | Max 996 bytes; poisoned parser on invalid input; explicit borrow lifetime; validation before output mutation |
| `src/media/format.zig` | Checked v2 application dimensions | Stereo finite f32 profile and bounded frame/sample/byte products; host capabilities remain external |
| `src/media/block_assembler.zig` | Copied source-prefix assembly | Bounded pending frames, finite sample bits, commit-only position advance, final partial block and terminal discontinuity |
| `src/protocol/v2.zig` | Finite-f32 record codec | Max 8240 bytes; exact bit representation, nonwrapping frame ranges, disjoint caller buffers and poisoned incremental parser |
| `src/protocol/negotiation.zig` | Serialized v2 record-order gate | Authorization/format echo, role/direction, contiguous source frames and host-attested drain before ACK; no I/O |
| `src/session/receiver.zig` | Serialized authenticated-channel/stream/window composition | Host attests channel policy; one stream; bounded END drain; no post-END admission; no physical callback ownership claimed |
| `src/audio/frame_queue.zig` | Fixed-capacity SPSC interleaved-frame transfer | Acquire/release publication; modular u32 cursors; sole owners; no reset while live |
| `src/audio/callback_bridge.zig` | Callback copy/silence/drop policy and diagnostics | Separate capture/playback queues; sticky overrun; counters read only after callback teardown |
| `src/host/audio_device.zig` | Optional native host module and explicit backend profiles | Stable userdata; serialized control; native error retention; deinit before reclamation |
| `tests/unit/core.zig` | State gates and independent output expectations | Authentication, stale completion, callback drain, holes, duplicate/late/far input, ring reuse, nonfinite PCM, exhaustion and 32,768 non-ring-oracle traces |
| `tests/dependency.zig` | Independent wrapper consumption | Calls native PCM function through the actual imported module; no hardware |
| `tests/unit/wire.zig` | Independent framing and PCM expectations | Golden bytes, all record split points, all s16 values, invalid profile/length/identity and END drain |
| `tests/integration/tls_receiver.zig` | Windows synthetic receiver integration | Public mTLS fixtures, own ALPN, absolute transfer deadline, real loopback sockets and explicit null playback callbacks |
| `tests/unit/callback.zig` | Queue and bridge expectations | Stereo alignment, tails, full/empty, u32 wrap, silence/overflow and 250,000-frame two-thread stress |
| `tests/integration/audio_device.zig` | Null-backend callback lifecycle | Eight real callback teardown/recreation cycles; no physical device |
| `tests/hardware/windows_capture.zig` | Opt-in physical Windows loopback qualification | Silent playback keeps engine active; bounded capture, finite PCM encoding, no recorded/transmitted sample files |
| `docs/PRODUCT.md` | User journey, profiles, failures, acceptance | Distinguishes intended and implemented behavior; no invented timing result |
| `docs/ARCHITECTURE.md` | Ownership, current tree, file map, future seams | No competing semantic owners or empty source promises |
| `docs/MATHEMATICS.md` | Mathematical model and refinement obligations | Precise dimensions, assumptions, induction and counterexamples; proof scope stated |
| `docs/DEPENDENCIES.md` | Dependency closure and decisions | Actual wiring versus observed candidates; source paths and provenance |
| `docs/VERIFICATION.md` | Reproduction and acceptance interpretation | Describes meaningful checks and missing integration evidence |
| `docs/TRANSPORT.md` | Authoritative experimental wire/channel contract | Fields, state, limits, trust, ACK semantics, dependencies and failure behavior |
| `docs/CALLBACKS.md` | Authoritative queue/callback/host ownership contract | Frame units, overload policy, native lifecycle, nonblocking scope and reproduction |
| `transport-lock.json` | Explicit TLS adoption identity | 188 exact source/SDK/fixture hashes and runtime import observations; changes require reviewed adoption |
| `spec/session/SessionWindow.tla` | Abstract composed transition relation | Safety invariants and fair-stop liveness; executable fault switches for falsification |
| `spec/session/SessionWindow.cfg` | Finite TLC scope | Capacity two, three positions, two epochs; no unbounded verification claim |
| `spec/stream/EndDrain.tla` | END admission and completion abstraction | Bounded terminal frontier, no post-END admission, fair draining; three falsifying mutations |
| `spec/stream/EndDrain.cfg` | END model bound | Capacity two, three positions; weak fairness of tick |
| `spec/concurrency/SpscPublication.tla` | Copy/publication/release abstraction | Payload identity and fair completion; early publication/release mutations |
| `spec/concurrency/SpscPublication.cfg` | SPSC model bound | Two slots, four frames; sequentially consistent abstraction |
| `spec/README.md` | Model use and limits | Java/TLC explicit, source-to-model correspondence linked |
| `tools/check_models.py` | Bounded model runner and mutant expectations | Temporary state, 120-second subprocess bound; nonzero on missing counterexamples; no fetch or source repair |
| `tools/check_docs.py` | Local link and authored-file-map consistency | Read-only; coverage is a navigation check, not semantic approval |
| `tools/check_transport.py` | Read-only dependency and staged-DLL custody | Missing/changed/escaped paths fail; never refreshes hashes or fetches files |
| `tools/test_transport.py` | Independent Python mTLS sender and negative cases | Ephemeral loopback, synthetic PCM, public fixtures, bounded processes/sockets; checks expected failures and clean closure |
| `verification/RESULTS.md` | Human interpretation of executed evidence | Exact environment, results and limitations |
| `verification/models.json` | Generated TLC output and tool/model hashes | Evidence at one source revision; do not hand-edit into success |
| `verification/source-snapshot.json` | Generated source/dependency/tool hashes | Freshness observation, not a signed release or correctness proof |
| `verification/transport/RESULTS.md` | Preserved version 0.2 transport qualification | Historical array-based integration, not current-source freshness |
| `verification/transport/receipt.json` | Preserved version 0.2 source/evidence observations | Commands, hashes, tool versions and before-images |
| `verification/callback/RESULTS.md` | Current callback qualification interpretation | Separates null, physical Windows, model and compile-only evidence |
| `verification/callback/receipt.json` | Current source and evidence observations | Retains first failures and before-images; does not silently refresh dependencies |
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
