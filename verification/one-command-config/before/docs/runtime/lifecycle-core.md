# Lifecycle core: acquisition, abort and receiver completion

C02a implements [the controller](../../src/runtime/lifecycle.zig) and its
[independent fake owners](../../tests/integration/runtime_lifecycle.zig).
This is the resource-lifetime subset of the
[larger C02 transaction contract](../design/lifecycle-transactions.md).
It is application-private and uses no allocator, OS API, Python or native handle.
The real caller today is the fake-owner integration test. C02b now adds
[graceful receiver composition](receive-drain.md) to this same controller. Native
owners and sender graceful composition remain open; `ready` does not mean playing audio.
The sections below explain the original resource subset; the linked chapter owns
the additional draining/reclaiming phases, receiver facts and transport effects.

## Exact boundary and representation

One control owner serializes all calls. Stable executor slots contain the actual
storage, device and worker resources, in that dependency order. A worker borrows
both device and storage; a device borrows storage. The initial profile has one
global outstanding operation, more restrictive than the proposed per-executor
capacity. This bounds memory and removes concurrent cleanup/acquisition dispatch.
The restriction may cost startup speed; no performance claim is made.

`Controller` holds a generation, operation serial, three ownership bits, one
optional issued token, two fence facts, first stop cause, cleanup-blocked flag and
deadline flag. Each call has constant work and storage independent of stream
duration. Fields are representation, not a public mutation interface. Do not copy,
reset, relocate associated executor storage, or construct a replacement controller
while the old instance has debt. Counters are unsigned 64-bit and never wrap.

An effect token is `(generation, serial, executor, kind, resource)`. Every component
participates in comparison. Serial resets only when a strictly larger generation
begins. For distinct dispatches, either generations differ or the within-generation
serial strictly increases; therefore token identities are distinct. No claim of
crash-persistent identity or distributed exactly-once execution follows.

| Executor | Permitted operations | Required adapter evidence |
| --- | --- | --- |
| allocator | acquire/release storage | Fully initialized stable storage or fully rolled-back failure; destruction only on release authority |
| native | acquire/fence/release device | Fence seals callback admission and waits for all entered callbacks; it preserves device storage until release |
| joiner | acquire/join/release worker | Join operation signals cancellation, wakes blocked work and joins from outside that worker; release destroys only joined worker ownership |

The native fence is a semantic contract, **not** an assertion that today's
`AudioDevice.deinit` already supplies a separate non-destructive operation.
C03 must qualify the actual mapping. Cancellation does not close native callback
admission by itself. A callback may enter until the adapter seals that admission.
The joiner cannot execute on the worker it joins. Workers must stop without needing
the control owner to issue a second concurrent operation; otherwise this profile
can stall safely but cannot establish progress.

## Calls, mutation and failure

| Call | Actual behavior | Failure / retained facts |
| --- | --- | --- |
| `begin()` | Idle/stopped only; reserves new generation and acquiring phase; no effects yet | Busy or generation exhaustion leaves every field unchanged. It does not resolve config, authenticate or start media. |
| `takeEffect(executor)` | Computes the next dependency-ready operation and reserves its result slot before returning its token | Wrong executor, blocked cleanup or outstanding work returns null. Serial exhaustion is atomic and retains all debt; caller must surface the unrecoverable namespace limit. |
| `complete(token,result)` | Matches all fields and legal result tag before settlement; attaches any acquired debt, then normalizes phase | Invalid token/result changes nothing. The caller receives the typed error and owns diagnostics/quarantine. |
| `requestStop(generation)` | Monotonic abort request; first cause preserved; stops immediately only when no debt exists | Stale generation is atomic. Repeated stop cannot reissue an effect, clear a deadline or bypass a blocked cleanup. |
| `deadline(generation)` | Marks the one generation-scoped absolute deadline expired and requests abort | Stale/terminal notifications have no effect. Timeout never cancels outstanding work or authorizes destruction. |
| `retryCleanup(generation)` | Unblocks a definitive failed cleanup so a new serial may be dispatched | Stale generation or no definitive blocked result fails atomically. Uncertain pending work cannot be retried. |
| `snapshot()` | Copies coherent serialized facts | Does not read native callback counters, join, acknowledge media or alter state. |

The caller owns clock measurement and the absolute deadline. This subset has one
deadline domain per generation; the proposed multi-phase `deadline_id` API remains
future work. Duplicate notifications do not extend it. After late truthful cleanup,
phase can become stopped while the deadline flag remains true, preserving history.

Taking an effect transfers dispatch authority once. The descriptor is not a request
that can be blindly retried after an executor queue failure. A known non-started
acquisition returns `failed_rolled_back`; a known non-started cleanup can return
`failure_no_change`. If execution is uncertain, retain the operation and its result
reservation until the executor resolves it. There is no extra heap completion queue
inside this module; an adapter must preserve delivery to the reserved slot.

Acquisition results are `acquired`, `failed_rolled_back`, or `partial_owned`.
The last creates the same resource cleanup obligation and initiates abort. It is
valid only if that partial resource supports this profile's ordinary fence/release
protocol. An arbitrary half-initialized C object is not thereby safe to uninitialize;
the adapter must normalize it or retain its own explicitly tracked recovery debt.
Failures that already created a resource must never masquerade as rollback.

Cleanup accepts its exact success (`joined`, `fenced`, or `released`) or
`failure_no_change`. The latter attests no ownership/fence fact changed, clears the
settled operation and blocks automatic retries. Explicit retry issues a new token;
a delayed success for the previous token remains invalid. If the native operation
partly progressed or is still running, that result is inappropriate: retain pending
debt and resolve it in the adapter. Unknown handles remain adapter-owned and need a
quarantine policy; rejecting an event does not confer permission to free its handle.

## Ownership argument and progress limit

Let H be the controller's held resource set, A the independent executor-owned set,
and P the optional issued operation. At reconciled event boundaries H=A, assuming
truthful adapter results. Between native success and completion, the result slot
and P account for the new executor resource. The invariant is consequently not
that native allocations appear instantaneously in H: it is that every allocation
is either in H or reserved by the one unsettled acquisition/result.

1. Initially H and P are empty. `begin` is allowed only after complete reclamation.
2. Acquisition dispatch requires its parent prefix in H. While P exists, no other
   effect can dispatch, so all parents remain held. Stop/deadline do not clear P.
3. Successful or partial completion attaches the resource even after cancellation.
   Rolled-back failure adds no resource only under the adapter's rollback premise.
4. Once stopping, no new acquisition dispatches. Cleanup order is worker join,
   worker release, device fence, device release, storage release, omitting absent
   resources. Join/fence results are required before their corresponding release.
5. Each release first reserves its exact operation and clears its bit only upon
   matching successful completion. No second dispatch occurs while that result is
   owed. Duplicate/foreign/contradictory events preserve the entire snapshot.
6. Stopped requires H empty and P absent. A new generation therefore cannot
   inherit an unsettled old acquisition or live registered owner.

Under these premises, resource release cannot race a registered child acquisition,
worker borrow or entered callback. This is an induction argument over the concrete
transition cases, not a machine-checked refinement proof or a guarantee against
a lying/broken native adapter.

After an outstanding acquisition settles during abort, a progress measure is
`R = [storage held] + [device held]*(1 + [device not fenced]) +
[worker held]*(1 + [worker not joined])`, so 0 <= R <= 5.
Each successful cleanup completion reduces R by one. Dispatch, repeated stop,
timeout and rejected input do not reduce it. Definitive cleanup failure requires
explicit retry; an executor that never returns prevents progress. Eventual cleanup
therefore requires eventual truthful successful results and fair control execution.
There is no wall-clock termination bound and no forced destruction on timeout.

## Model relationship and tests

The Python specification abstracts this same three-resource dependency prefix.
Its pending acquisition maps to the issued acquire token; actual resource bits map
to the fake host's ownership, while held bits map to the controller. The controller
restricts schedules by joining/releasing the worker before fencing the device.
Its join completion folds worker-exit/native management observations into a truthful
adapter attestation. Cleanup dispatch/results, explicit retry, partial ownership and
full token fields are concrete details beyond that model's acquisition-only token.
The finite model is complementary evidence, not execution of the Zig controller.

The fake harness instantiates the actual controller and maintains separate native
ownership, acquisition/release counts, worker lifetime and callback admission/return.
It validates every effect before the controller receives success. It exercises:

- cancellation before each acquisition and during each acquisition, with late
  success, rolled-back failure and partial cleanup debt;
- the preserved pending-worker-parent counterexample, repeated stop and a
  never-returning operation observed for a bounded schedule;
- callback entry after stop, admission sealing and a paused callback return;
- all token-field mismatches, duplicate/old-generation events and illegal result tags;
- failure and explicit retry at all five cleanup stages; namespace exhaustion;
- restart only after matching acquisition/release counts and empty ownership.

Run `zig build lifecycle-test` and `zig build lifecycle-test -Doptimize=ReleaseSafe`.
The lifecycle run step always executes when requested. `zig build test` includes it.
`lifecycle-check -Dtarget=x86_64-macos` and the equivalent Linux target only compile;
they provide no native operating-system evidence. See the
[phase results](../../verification/lifecycle-core/RESULTS.md) for exact observations.

## Next implementation boundary

C02a is complete only for this documented resource profile. R07/R08 acquisition,
abort, identity and retry subsets have fake-owner coverage; the paused-callback test
covers only the lifetime part of R05. C02b now tests receiver PendingBlock/queue custody, tails,
END/fence/ACK/close ordering and distinct outcomes with this controller. See its
[contract and exact fake-owner limits](receive-drain.md). Full C02 remains open
for sender graceful custody, native start/fault/snapshot refinement and real
blocked-owner cancellation. Socket/TLS/config resources need explicit owners or justified
aggregate adapter contracts before adding them to this profile. C03 then qualifies
the real native fence/join mapping; C04-C09 retain their existing gates.

## Sender and native extension

[C02c](send-drain.md) adds sender AUDIO/END/ACK effects and separate remote
attestation to this controller. [The native subset](native-fence.md) now implements
a non-destructive fence for the inspected synchronous path, with silent-backend
execution. Async backends, native failure recovery and production workers remain
unqualified. Original C02a observations above retain their historical scope.
