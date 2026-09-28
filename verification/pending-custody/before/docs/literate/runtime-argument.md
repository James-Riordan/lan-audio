# Runtime ownership: composition, cancellation and reclamation

Status: executable **design specification**. The production runtime it specifies
is not implemented. The source of this argument is
[`RuntimeOwnership.tla`](../../spec/runtime/RuntimeOwnership.tla), configured by
[`RuntimeOwnership.cfg`](../../spec/runtime/RuntimeOwnership.cfg). This model adds
a composition boundary; it does not replace the three narrower existing models.

## Domain, state and deliberate abstractions

The model has phases idle, connect, prime, run, drain and stop; a nonwrapping epoch;
an allocation flag; host-attested authentication; a set of owners; a playback-device
admission flag; and one active playback callback. The capture owner abstracts both
the source callback and its assembler. `OwnerExit("capture")` is legal only when
both have actually quiesced in the implementation. This is an obligation, not an
assumption that returning from an assembler thread joins a native callback.

Let C be captured frames, A frames in the capture queue, N the indicator of one
in-flight frame, P frames in the playback queue, H the indicator of a frame held
by a callback, R frames callback-consumed and D explicitly discarded frames.
The two queues each have capacity K. N and H are Boolean-sized custody stages.
Actual TLS buffers can hold many frames/bytes; they require a wider refinement,
not the false assertion that the real network contains at most one frame.

The model counts frames, not their values or sequence IDs. It therefore checks
conservation and ownership, not FIFO, integrity, replay rejection, f32 fidelity,
cryptography, packet losses or acoustic output. SessionWindow, SpscPublication,
protocol checks and future source-identity refinement carry those obligations.
Native calls are abstract actions; the model cannot prove they return or that a
single abstract action has bounded physical duration.

## Actions and their implementation meaning

| Action | Meaning / condition that concrete code must establish |
| --- | --- |
| `Begin` | Allocate fresh stable storage only from quiescent idle; advance generation; reset per-generation accounting. |
| `Authorize` | Host finishes transport identity/format policy and starts owned capture/network work. Authentication itself is outside the model. |
| `Capture` | Publish a complete captured frame while admission is open and queue space exists. A full queue does not silently accept a frame. |
| `Send`, `Deliver` | Transfer exclusive custody between queue, in-flight and output stages. May stall forever; no network fairness is assumed. |
| `Prime` | Start playback only after contiguous prefill. Capture/transport already run in prime, avoiding circular startup waits. |
| `Graceful` | Close capture admission; begin finite drain budget; permit short-stream playback below the usual prefill. |
| `Enter`, `Return` | Admit playback callback, borrow a frame or silence, then relinquish the callback token. Already admitted callbacks may return after stop. |
| `Clock`, `Deadline` | Decrease a finite drain budget and request stop on expiry. Budget cannot be extended by trickle progress. |
| `DrainComplete` | Request stop when every custody stage and active callback is empty. Does not itself free memory. |
| `Abort` | Request stop during connect, prime, run or drain, including device/transport failure or cancellation. |
| `StopDevice` | Close future playback admission. Active callback return and native uninitialization/join must still be established. |
| `OwnerExit(role)` | Owner acknowledges cancellation after dropping all references; may do so with queued data remaining. |
| `Free` | Reclaim only after all owners/callbacks quiesce; classify residual custody as discarded; enter idle. |

The phase stop disables Capture/Send/Deliver/Enter. This is the key reason abort
cannot wait for those operations to drain queues. Owner exit must not depend on
progress from work that stop has just forbidden.

## Safety theorem R1 — custody conservation

Claim: every reachable state of the unmutated model satisfies

`C = A + N + P + H + R + D`.

Proof obligation: `Init => Custody` and
`Custody /\ TypeOK /\ Next => Custody'`, with the required reachable-state
invariants where noted. The induction cases are explicit:

1. Init sets every term to zero. Begin resets C/R/D; quiescent idle has no live
   custody because Free cleared A/N/P/H and no idle action can repopulate them.
2. Capture increases C and A by one; the equality is preserved.
3. Send subtracts one from A and changes N from zero to one. Deliver transfers
   that one from N to P. Neither action creates or destroys a frame.
4. Enter transfers one from P to H, or transfers nothing for silence. Return
   transfers H to R and clears H. Silence is not falsely counted as captured media.
5. Free transfers all A/N/P/H to D before clearing those stages. Under its normal
   guard H is already zero; retaining it in the expression exposes the full ledger.
6. Every other action preserves all terms.

The explicit strengthening `phase = idle => A=N=P=H=0` is named IdleEmpty and
checked with the other invariants; the isolated equation alone would not justify
Begin. A future machine-checked inductive proof must use this strengthening.
The present argument is manual; TLC checks the configured reachable state graph.

## Safety theorem R2 — no reclamation with live references

Claim: `~allocated => (~device /\ ~active /\ owners = {})`.
Init satisfies it. Begin makes storage allocated. The only action that clears
allocation is Free, whose guard requires precisely the absent-reference condition.
Actions that can establish references are disabled in idle. No stopped owner can
publish into a new generation because Begin is enabled only after Free. This last
statement is about modeled owners; unregistered native references would violate
the refinement assumptions and remain a real implementation bug.

The `early_free` mutation bypasses the guard. TLC must find a state violating
LiveStorage; an expected counterexample demonstrates that the check can detect
this particular broken ownership discipline. It is not a test of every possible
reclamation bug.

## Liveness theorem R3 — stop eventually reaches idle

Once stop is entered, no new owner or callback is admitted. Assume weak fairness
of callback return, device stopping, each owner exit and Free. A pending callback
then returns; an open device closes admission; every remaining owner exits; Free
becomes continuously enabled and eventually runs. The informal ranking measure
is `|owners| + indicator(device) + indicator(active)`, followed by the final Free
step. Fairness is required to turn possible decrements into eventual decrements.

The `stop_wait` mutation makes owner exit depend on empty queues. A stop with
queued media can then stutter forever: transport/render admission is closed, so
the queue cannot empty, yet its nonemptiness prevents the owner from exiting.
Weak fairness does not rescue a disabled action. The runner expects a temporal
counterexample, not a safety violation or a process timeout.

## Liveness theorem R4 — graceful drain has an escape

Assume weak fairness of Clock and Deadline. While drain continues, remaining is
a nonnegative integer that decreases at each Clock step. It cannot decrease
forever; at zero, Deadline eventually requests stop. Earlier natural completion
or Abort also requests stop. R3 then gives eventual idle without assuming delivery
or packet recovery. This is bounded *logical ticks* followed by fair cleanup, not
a wall-clock completion deadline. A wall-clock bound additionally requires bounds
on scheduling and native join/cancellation latency, which are not supplied here.

`CHECK_DEADLOCK FALSE` allows intended terminal idling after the finite epoch bound.
It does not disable the temporal Progress property. The stop_wait defect is found
by that property even when the offending behavior is infinite stuttering.

## Refinement obligations before claiming runtime verification

| Abstract element | Current or planned owner | Required demonstration |
| --- | --- | --- |
| phase/epoch/allocation | Planned `src/runtime/lifecycle.zig`; current Session only covers a subset | Give a mapping for partial init, every error path, abort and restart; prevent ABA reuse across outstanding owners. |
| capture owner and A | AudioDevice/CallbackBridge/FrameQueue plus implemented BlockAssembler; native composition planned | Account for callbacks already in flight, partial blocks, drops and separate source/worker joins. |
| network owner and N | Planned capture_sender/playback_receiver with tls-zig Driver | Preserve every partial plaintext/ciphertext suffix; interruption wakes the actual owner; expand count abstraction to all buffers. |
| P/H/R | Existing playback queue/native callback plus planned renderer | Callback-consumed is the chosen frontier; device-buffer/acoustic latency requires another observation. |
| remaining | Planned absolute monotonic deadline | Checked clock arithmetic; polling/waits interruptible; no retry restarts deadline. |
| Free | Planned cleanup ledger and AudioDevice.deinit | Every acquired resource released once; all foreign/userdata references invalidated before storage reuse. |

Concrete transitions must correspond to an allowed abstract action or a stuttering
step. They must preserve assumptions while split across real threads; simply
matching action/function names is not a refinement proof. Progress refinement
also needs to justify that internal stuttering cannot indefinitely postpone the
abstract action. Partial initialization and multiple in-flight records are open
extensions, not checked behavior smuggled into the present abstraction.

The separate [ReceiveDrain argument](../design/receive-drain.md) now checks
variable-frame identity and partial playback publication through callback return,
including final short streams. It refines the *design vocabulary* but has not been
mechanically composed with this model or the production queue/worker code.

Run instructions and source-scoped results are in [the model guide](../../spec/README.md)
and [this revision's evidence](../../verification/literate-specification/RESULTS.md).
