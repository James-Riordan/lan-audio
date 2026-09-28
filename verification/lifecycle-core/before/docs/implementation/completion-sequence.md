# Completion sequence for the next implementation session

This is the continuation entry after the component and design qualification
phases. The repository is a documented foundation, not a deployable audio app.
Use measurable gates below rather than a percentage or a universal perfection
label. [Product requirements](../PRODUCT.md) remain the authority for A1-A10.

## First establish the exact starting state

Read AGENTS.md, START_HERE, the proof ledger, the latest phase RESULTS and receipt.
Check dependency custody, source hashes and local documentation coverage. Separate
new working changes from the recorded revision; never refresh locks to hide drift.
Inspect the active toolchain rather than assuming the pinned Zig development
version still matches an installed default. Preserve changes and record a fresh
phase before further edits. Do not initialize, rename or move sibling projects as
a prerequisite for ordinary implementation work.

The [runtime blueprint](runtime-blueprint.md) and
[test obligations](../verification/runtime-obligations.md) identify source-level
gaps. Planned paths are specifications, not working APIs. The
[directory architecture](layout.md) owns their placement. Create files together
with their caller, documentation, independent tests and failure behavior.

## Small complete changes, in dependency order

| Step / first files | Deliverable and stopping condition | Can proceed without the Mac? |
| --- | --- | --- |
| C01 Receive pending-custody helper: implemented `src/runtime/pending_block.zig`, R01-R02 component tests | Copied v2 admission, prefix cursor, Busy before overwrite, terminal local abort accounting; actual decoder/gate/queue composition in pure tests and the TLS fixture. Native owner integration remains C05. | Implemented local component; see [contract/evidence](../media/pending-block.md). |
| C02 Lifecycle owner: `src/runtime/lifecycle.zig`, runtime_lifecycle tests | Resource acquisition/borrow/cleanup ledger, typed terminal outcomes, generation-tagged commands, graceful versus abort states. R03-R08 pass with controlled callback return and native failure. | Yes; native claims remain open. |
| C03 Audio adapter obligations: `src/host/audio_device.zig`, callback bridge and tests | Explicit selected endpoint and validated format; live sticky input/output fault publication; safe final snapshots/fences; no callback blocking or allocation. Qualify Windows/null behavior first. | Yes for those targets; Mac semantics need its host. |
| C04 Real socket and identity seam: WP03 files plus generic TLS peer export | Serialized native handle/readiness/cancel ownership; real verified-peer identity bound to product allowlist/role. R13-R14 pass; public fixtures never become product credentials. | Windows and fake policy work can proceed. Native Mac portion waits. |
| C05 Sender/receiver workers: capture_sender, playback_receiver and R09-R12 | Actual components compose with bounded copied custody, absolute deadlines, short-stream drain and no self-join. Synthetic real-TLS/fake-device round trip passes in both application directions. | Yes as local qualification; no two-host claim. |
| C06 Thin product command: `src/app/{main,config}.zig`, build graph | Validated devices/send/receive/help workflow invokes the same tested owners. Missing settings fail clearly before device start. Foreground stop works; no service or hidden IPC required. | Windows runnable path can proceed. |
| C07 Native Intel Mac and two-host run: WP01/WP04 | Build private SDK/runtime closure on an available host, qualify selected endpoint and actual OS, execute R15. Only this can reach M1 first sound. | No. Mac unavailable; Monterey unconfirmed. |
| C08 Sustained timing and recovery: WP05-WP07 | Clock estimator/resampler/controller with independent plant/oracle; quantitative limits, source retention, fault accounting and measured real adapter traces. Reach M2 only with sustained actual-device evidence. | Simulation/Windows measurements can proceed; final gate needs both. |
| C09 UX/distribution/release: WP08-WP10 | Real pairing/storage/recovery UX, clean-machine runtime loading, support matrix, licenses/signing/update/rollback, all A1-A10 obligations evidenced. | Prepare and qualify each available target; M3 needs full release evidence. |

The C01 component is implemented; C02 is the next slice while the Mac is unavailable. The pending
helper is justified by one concrete receiver caller and R01-R02; keep it private
to runtime until another consumer establishes a reusable library contract.
Do not add a new package merely because a helper or mathematical concept has a name.
C03-C04 may be developed independently once their prerequisite interfaces are
stable. The table describes dependencies, not authorization for unrelated changes.

WP01's native Mac gate blocks the complete WP03/WP04 milestones, not useful
Windows or pure preparation inside those packages. Track partial target status
explicitly instead of declaring a whole work package complete from one platform.

## Per-file implementation contract for the next slice

C02 is refined by [lifecycle transactions](../design/lifecycle-transactions.md):
typed operations, bounded effect/result delivery, pending-parent borrows, late
success after cancel, native fences, outcome dimensions and six falsifying model
mutations. Its specification results do not close the implementation/fake-owner gate.

| Proposed file | Inputs and owned state | Required outputs, errors and evidence |
| --- | --- | --- |
| `src/runtime/pending_block.zig` (implemented) | Validated format, borrowed v2 AUDIO decoded into fixed owned storage, first frame/count, prefix cursor | Actual init/admit/peek/advance/abort contract is in [pending block](../media/pending-block.md); tests and TLS fixture are current callers. No reset with live borrows or new public core/package API. |
| `src/runtime/lifecycle.zig` | Validated configuration, generation, staged resource outcomes, stop/cancel requests, owner fence acknowledgements | Deterministic commands to adapters plus typed state/outcome; no destructor on live borrowers; repeated stop converges; stale generation rejected; explicit acquisition-failure coverage. Keep native operations outside the pure transition logic where practical. |
| `src/runtime/capture_sender.zig` | Authorized channel, native capture queue, retained scratch suffix, BlockAssembler, encoder, serialized Driver | Exactly one gate/assembler commit per accepted write; truthful END after quiescence/drain; source loss abort; no unbounded per-iteration work. |
| `src/runtime/playback_receiver.zig` | Authorized channel, parser/read suffix, pending helper, playback queue, device-fence messages | Contiguous frame order, bounded publication, normal/short-stream priming, exact END/fence/ACK order; distinguish transport uncertainty from known media discard. |
| `tests/unit/runtime/pending_block.zig` | Independent finite frame identities and integer f32 words; varying block/queue capacities and zero/short acceptances | Exact concatenation equality, unchanged state on rejected admission, cursor limits and no hidden remainder loss. Include maximum block and final tail, not only nominal 240 frames. |
| `tests/integration/runtime_lifecycle.zig` | Fake resources and explicit schedule/borrow tokens; virtual time | Resource-event partial order and final ledger; pause callbacks between release and return; cancel each state; reject early free/ACK and late old-generation completion. |

Contracts not labeled implemented are proposed semantic behavior. Resolve exact Zig signatures with
the pinned compiler. For each fallible call state the mutation boundary; errors
must not secretly consume input or publish a prefix unless the result reports it.
Avoid a second independent decoder or protocol schema inside the runtime helper.

## Scope of the first usable command

The first command is foreground and explicit: choose the intended peer/device,
connect, start, observe state, stop. `status` and `stop` in a different process
require authenticated/local IPC or a service protocol that does not exist today;
do not present those planned verbs as working remote controls. Begin with bounded
in-process status and foreground termination. UI later drives the same lifecycle.

Use a configured supported rate, finite buffer/drain limits and provisioned real
credentials for the first alpha. Keep proposed settings labeled experimental until
qualified. Do not default-enable discovery, startup service, auto-reconnect, a
format downgrade, or an alternative transport as incidental scaffolding.

## A completed implementation change

The concrete code has a real caller, its explanation matches actual semantics,
all relevant independent tests pass, negative paths preserve ownership, and new
evidence names sources/tools/targets/limits. The generated per-file reference and
acceptance/proof ledgers agree. Remaining gates identify a specific missing fact,
adapter, test or host; they do not say only "make robust" or "optimize later".

Production readiness additionally requires actual A1-A10 evidence and a stated
support/fault envelope. A richly documented design is valuable preparation; it
cannot substitute for execution on the user's Windows adapter and Intel Mac.
