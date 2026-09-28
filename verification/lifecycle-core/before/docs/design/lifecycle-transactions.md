# Lifecycle transactions: partial startup through final reclamation

Status: proposed C02 production contract with an executable finite specification.
`src/runtime/lifecycle.zig` is not implemented. The actual current AudioDevice,
callback bridge and TLS Driver have narrower interfaces; do not infer new methods
from names used in this design. Read this with the
[runtime blueprint](../implementation/runtime-blueprint.md) and
[R03-R08 obligations](../verification/runtime-obligations.md).

## The ownership problem

Stop is an intent, not evidence that native work stopped. A successful allocation
can arrive after cancellation. A callback can release queue slots before returning.
A queued completion can belong to an older operation. Startup and teardown therefore
need a resource/operation ledger, not a reverse list of destructors or one running
boolean. A parent remains borrowed by a pending acquisition even before the child
resource exists. No deadline authorizes reclaiming a live native borrow.

The first draft of the executable specification violated precisely this rule:
create storage, create device, issue worker creation, cancel, join callbacks, free
device, then receive successful worker creation. The environment still owed that
result. The corrected model forbids parent release while that acquisition is
outstanding. [Preserved evidence](../../verification/lifecycle-preparation/RESULTS.md)
includes the original failure and a permanent mutation of the missing guard.

## State, identity and authority

One control owner serializes transitions. Its immutable generation G and operation
serial N form a local token `(G,N,executor,kind,resource)`. Generation and serial
increment with checked arithmetic and never wrap into an issued namespace. Start
requires the previous generation to have no resources, issued effects, completion
slots, borrowers or unresolved native work. A new stream ID and authorization
belong to the new generation; reusing settings does not reuse stream identity.

Resource records carry acquisition identity, dependency set, state and borrow
owners. States are absent, acquiring, owned, quiescing and released. A pending
acquisition reserves its result slot and parent borrows before host dispatch.
Successful completion adds cleanup debt even when the desired state is stopped.
Failure adds no child resource only if the adapter guarantees internal rollback;
otherwise the result must return the partial resource plus its cleanup contract.
Do not assume a failed native initializer universally leaves nothing to release.

| Phase | Admissions and transitions | Exit evidence |
| --- | --- | --- |
| idle / released | May accept validated fresh start; no inherited handles or borrows | Empty resource/operation ledger |
| acquiring | Issue dependency-ready effects; authorization/media prerequisites remain separate | All required successes, or cancellation/failure |
| ready / active | Commands may begin qualified source/sink activity for this generation | Stop, authenticated END, native fault or deadline |
| draining | Close source/publication admission in the role-specific order; retain required transport ownership | Exact local drain attestation and protocol completion, or abort escalation |
| aborting | No new media/start acquisitions; signal/wake owners; receive outstanding results and reclaim safely | All required native/worker fences and cleanup |
| stopped | Publish final outcome after complete ledger reclamation | A separately requested new start may allocate a generation |
| stopping-unresponsive | Deadline expired with unresolved native/worker debt; retain storage and show cause | Late truthful fences may permit cleanup; no forced free or claimed stopped state |

The user-facing state maps from this control snapshot. Acknowledging a stop request
immediately is compatible with displaying stopping until cleanup finishes. A
generation with unresolved native debt cannot restart in the same storage.

## Commands and completion transactions

Proposed `lifecycle.zig` accepts typed events and produces bounded effect descriptors
and snapshots; it performs no I/O. Resolve exact Zig signatures with the pinned
compiler when implementing. The required conceptual steps are:

1. Validate event generation, token, expected kind and prior operation state.
2. Compute candidate ledger/state and any effect, checking bounds without effects.
3. Commit the ledger and reserve delivery/result capacity before publishing an effect.
4. A designated executor takes the descriptor exactly once and invokes the host.
5. Return a typed result carrying the exact token; settle that issued debt once.

Each executor has at most one active blocking/serialized host operation and one
reserved completion slot in the initial implementation. A pending effect cannot
be overwritten. Normal commands may report Busy; stop intent and sticky fault
bits have separate bounded publication and cannot be dropped because a queue is
full. Callbacks publish only qualified atomics/counters; they never run this
controller, a destructor, device control or a blocking completion submission.

Repeatedly observing an effect is not permission to execute it twice. Distinguish
never dispatched, issued, and settled. A host dispatch rejected before execution
can settle with a known-not-started error; uncertain execution retains debt until
the host returns or the process-level failure policy takes over. In-process request
tokens do not provide crash-persistent exactly-once I/O. No callback reentry into
the control transition is allowed, even if a fake adapter completes synchronously.

A stale/duplicate/mismatched completion cannot mutate the current ledger, advance
state, release a handle, or start a device. Preserve a bounded diagnostic. It also
cannot be used to forget a genuine unresolved old resource: old executor results
must be reconciled before its generation can be released. If an adapter delivers
an unknown owned handle, that is an adapter protocol fault requiring a defined
quarantine/cleanup owner; never attach it to the new stream or blindly destroy it.

### Proposed C02 call surface

| Method / event | Mutation and caller obligation | Rejection semantics |
| --- | --- | --- |
| `init` | Construct an empty controller without allocating/opening anything; caller supplies bounded storage and generation namespace policy | Unsupported bounds fail before construction |
| `begin(validated_config)` | Reserve a new generation and immutable configuration; prepare the first dependency-ready effect | Busy while any old debt exists; checked generation exhaustion; no native side effects |
| `requestStop(mode, reason)` | Serialized monotonic intent update, preserving existing issued debt; abort dominates graceful | Repetition succeeds without resetting deadlines or creating duplicate effects; use a bounded enum/cause record |
| `takeEffect(executor)` | Transfer one ready descriptor to its designated executor, marking it issued before return; reserve its result slot/parent borrows | None when no ready work; never reissue an already taken descriptor |
| `complete(token, result)` | Match all token fields and issued state; settle once, attach successful resource or preserve typed failure/partial ownership; prepare cleanup when stopping | Stale, duplicate, wrong-kind and impossible result leave the controller ledger unchanged and publish a bounded diagnostic |
| `observeMediaFence(generation, frontier, outcome)` | Accept only the designated worker's terminal custody attestation; this does not create a native/worker join | Reject stale or inconsistent frontier/outcome before ACK authorization |
| `deadline(generation, deadline_id)` | Escalate the corresponding outstanding phase without altering its original deadline or erasing resources | Old/settled deadline notification is a no-op observation; it cannot cancel a new phase |
| `snapshot` | Copy a coherent bounded controller view for presentation/diagnostics; no direct callback-counter reads | Does not mutate, acknowledge, join or infer delivery |

`result` is a tagged union of known-not-started failure, successful acquisition,
explicit partial-acquisition debt, qualified fence/exit, and cleanup result. The
executor/kind determines legal variants. Contradictory success/failure payloads,
foreign acquisition IDs and an impossible cleanup claim are adapter protocol
errors, not ordinary cancellation. Platform handles remain executor-owned stable
objects addressed by acquisition IDs; do not copy opaque native structs into the
pure controller. C02 resolves concrete Zig unions and field widths together with
the fake executor caller; the semantics above are the required compatibility point.

## Cleanup dependencies and fences

For resource r, let Acq(r) mean successfully acquired, Released(r) mean destroyed,
and Borrow(r) include live callbacks, workers and issued dependent acquisitions.
The central release precondition is:

`Acq(r) AND NOT Released(r) AND Borrow(r)=empty AND RequiredFences(r)=complete`.

Every success is in exactly one of owned or released; failure cannot invent a
success, and cancel cannot erase one. Release is once per acquisition identity,
not once per pointer address. Address reuse after a complete generation does not
make an old token valid. Zero media and empty queues do not imply empty Borrow.

Storage is the parent of native device/bridge and worker access. Native context
is the parent of its device. A worker starting against a device/bridge borrows its
declared parents until startup resolves and its ownership is transferred or rolled
back. Worker exit, thread join, callback return, native stop and native uninit are
distinct observations. Register each actual native guarantee before mapping one
to the required fence. The finite model's non-destructive callback fence must not
be implemented as an early destructive uninit while a worker still needs native
objects. Current AudioDevice.deinit combines operations; C03 must provide a safe
ordering or a narrower adapter boundary, with target-specific evidence.

Native callback admission may remain open after application cancellation and even
while a fence call is pending. The model separates request, native admission seal,
last callback return and fence completion. The seal is an environmental abstraction,
not a new public API; the concrete adapter may observe only the final join. A
sampled callback-count zero or queue-empty flag never substitutes for that join.

On abort, a worker stops waiting for a disabled consumer to empty its queue. It
records retained/discarded/uncertain custody, releases borrows and exits. Queues and
objects are reset only after all owners are gone. No thread terminates itself by
joining itself; transport ownership may remain after media fences to send ACK.

## Graceful completion and outcome ordering

Graceful request can escalate to abort; abort never de-escalates to graceful. A
repeated request does not reset deadlines, issue duplicate host calls or count
discard twice. Reasons retain the first initiating cause plus bounded secondary
cleanup failures. If concurrent causes are incomparable, retain both instead of
pretending their timestamps establish causal order.

Maintain separate outcome dimensions: local custody, remote attestation, secure
transport close and resource cleanup. Local samples drained plus failed ACK write
is not a confirmed remote success. Clean TLS close without matching END/ACK is
not media completion. Native output copying is not acoustic completion. Any local
source gap, unclassified underrun, forced discard or uncertain media transfer must
remain visible even when cleanup eventually succeeds. Backend tail/resampler
accounting belongs to the explicit WP05 contract.

Deadlines are absolute within a named monotonic clock domain. Saturating or
overflowing an exact accounting counter invalidates that claim; it cannot be
quietly clamped and subtracted. Expiry changes intent/outcome, then requests
cancellation. It cannot prove a blocked OS call returned. A hard termination SLA
requires a separately designed process-isolation boundary, not unsafe thread kill.

## Executable abstraction and mathematical limits

[lifecycle_transactions.py](../../spec/runtime/lifecycle_transactions.py) enumerates
three aggregate resources (storage, device, worker), one outstanding acquisition,
one active callback, one worker, and one/two generations. Manager-held resources
are checked against an environment ledger. Pending tokens are checked against
environment obligations. Six mutations exercise forgotten pending work, discarded
late success, stale completion, live-worker release, pending-parent release and
unjoined-device release. Wrong-token classes are abstract equivalence classes;
the model does not implement a concrete token parser/comparator.

Safety is checked on every enumerated transition. Reverse graph traversal also
requires every stopping state to have some same-generation path to released.
This is existential reachability, not universal temporal progress. It deliberately
permits a native call to stall forever. Conditional eventual cleanup additionally
requires eventual acquisition settlement, native admission closure, return/join,
worker cooperation and fair scheduling of enabled cleanup actions. Earlier TLA+
RuntimeOwnership checks a different aggregate fairness abstraction; neither model
mechanically refines the future Zig implementation or composes the whole protocol.

After new acquisitions are forbidden and outstanding acquisition results settle,
assume native admission closes. There are finitely many admitted callbacks and
workers. Under the stated return/join premises, their debt decreases, then the
finite resource dependency DAG admits successive releases. This explains conditional
termination; it is not a measured time bound. Before native admission closes, new
callbacks can increase debt, so a simple monotonically decreasing count is invalid.

The runner fails on a missing or wrong mutation witness, model exception or state
budget exhaustion. It does not treat arbitrary nonzero exits as successful defect
detection. No native handles, samples, cryptography, weak memory, crash recovery,
permission flows or arbitrary numbers of workers are modeled.

## Implementation/refinement acceptance

| Future file | Concrete obligation | Independent evidence |
| --- | --- | --- |
| `src/runtime/lifecycle.zig` | Typed states/tokens, partial-acquisition ledger, bounded effect/result slots, monotonic stop escalation, immutable generation config | Replay hand-authored event schedules against a separate acquisition/borrow/release oracle; reject stale/duplicate token fields individually |
| `tests/integration/runtime_lifecycle.zig` | Use the same controller with controlled host executors, virtual time and explicit paused callback/worker borrows | R03-R08 plus every counterexample below; compare event identities and parent lifetime, not controller counters alone |
| `src/host/audio_device.zig` | Map actual init failure, stop, join, uninit and final snapshot behavior to declared obligations | Native/null failure injection and callback pause/return ordering; Windows and Mac qualified separately |
| Future network/worker owners | Retain Driver buffers/socket ownership until their typed cancellation/exit results settle | Blocked read/write, uncertain dispatch, delayed completion and stop while queues full; no duplicate frees or completion ACK |

Mandatory schedules: cancel before dispatch; cancel during each acquisition;
success after cancel; failure after cancel; callback enter after stop request;
queue empty while callback paused; worker start pending during device teardown;
duplicate stop/result; wrong generation/serial/kind/resource; native stop failure
followed by qualified uninit; a never-returning native call; completion deadline
followed by a late valid fence; and a complete stop/start with old queued results.
Each negative test names the expected error and verifies no forbidden effect.

The C02 exit is implemented controller plus fake-owner tests with independent
ledgers and recorded traces. Passing this Python specification is preparation for
that exit, not its completion. Native C03 and two-host R15 remain separate gates.
