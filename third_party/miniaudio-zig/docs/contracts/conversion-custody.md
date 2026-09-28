# Conversion custody, terminal state and completion

Status: proposed contract for the application host adapter. No production adapter
or protocol extension is implemented here. Read [PCM units](pcm-and-conversion.md)
and the [file plan](../implementation/conversion-handoff.md) first. This model
assumes one mutable converter owner and an independently fenced output consumer.

## Values, buffers and clocks are separate

Use source frames for admitted input and output frames for converted playback.
Carry generation and domain in interfaces/types; do not let two bare `u64` values
be interchangeable. Channels describe samples per frame, not another clock.
Validate span products before pointers/slices, including `frames*channels*4` for
f32. Input and output storage are disjoint and bounded. A native process call
borrows both only until return; the adapter retains owned staging across calls.

At any observation point define nonnegative cumulative counts:

| Symbol | Domain / meaning |
| --- | --- |
| A | Real source frames admitted to this converter generation |
| U | Real source frames still owned and not yet submitted as consumed |
| C | Real source frames native calls reported consumed |
| Ds | Admitted source frames explicitly discarded before native consumption |
| Z | Synthetic zero input frames actually consumed under the terminal recipe |
| P | All output frames native calls reported produced, including startup/tail effects |
| H | Produced output frames held by the worker and not yet queued |
| Q | Produced output frames in the playback queue |
| B | Produced output frames copied into a callback's output region |
| Do | Produced output frames deliberately discarded before callback copy |
| S | Callback output frames filled with underrun/concealment silence outside conversion |

Two separate custody identities hold at committed successful transitions:

```text
A = U + C + Ds
P = H + Q + B + Do
callback_output_frames = B + S
```

`Z` is not part of A or C. Filter history inside the converter is an additional
live resource, not a count of unconsumed source buffers. C is a consumption
frontier, not evidence every source sample has finished influencing output. S
advances output time without source consumption. Do not assert `C=P`, `A=B`,
`C=rho*P` or add source and output counters to form a combined queue length.

This ledger describes prefixes and custody, not numerical sample identity.
Sequence order and at-most-once output publication additionally require a single
owner, immutable held-output prefix and no reset/reuse before consumers quiesce.
Actual queue indices remain the application's established SPSC abstraction.

## Proposed adapter seam

The names below are semantic operations, not declarations already exported:

- Initialize at its final address on the control/worker owner, with format,
  algorithm, allocation policy and supported rate profile. Publish ready only
  after complete acquisition. Keep a ledger for partial-initialization rollback.
- `process(input, output)` accepts bounded disjoint spans and returns actual
  consumed-source and produced-output counts plus typed outcome. Success requires
  each count within the corresponding offered capacity and finite accepted output.
  Advance input by consumed count; retain produced output until publication.
- `publish(k)` transfers only the first k held output frames to the existing queue.
  A short or zero queue write keeps the suffix in the same generation. Do not call
  native processing into that buffer until its old contents are no longer needed.
- `setRate` applies only at a documented owner boundary with no concurrent native
  operation. Preserve requested, represented and actual supported ratio facts.
  Held output keeps its old provenance; a new rate cannot relabel it retrospectively.
- `end(frontier)` closes admission at the validated contiguous source frontier.
  Process existing source before entering the declared terminal recipe.
- Abort prevents new admission/publication, preserves the fault/result and arranges
  queue/device/worker quiescence. Native mutable state is not reused after a process
  or rate failure whose failure atomicity has not been established.

Never publish output from a failed native call merely because its count parameters
changed. Native state and staging may already be modified: mark the generation
failed, discard unpublished bytes, retain last validated ledger and record the
attempted capacities as uncertain failure context. The conservation identities
above then describe the last committed state, not an invented native rollback.

Zero consumed and zero produced is a no-progress outcome, not END. An unchanged
work loop must yield to an input/capacity/cancellation event or reach its declared
failure/deadline policy. Available input does not guarantee progress for every
backend. Output-only and input-only progress are legal if native results report
them; both have explicit ledger transitions.

## Lifecycle and terminal protocol

| State | Allowed transition and condition |
| --- | --- |
| Empty | Init success -> Active; failed acquisition -> cleanup without publishing readiness. |
| Active | Successful process/rate/publish; validated END -> SourceClosed; fault/cancel -> Failed. |
| SourceClosed | Consume the owned real-source suffix, respecting output backpressure; when U=0 -> Tail. No new admission. |
| Tail | Execute only the qualified finite terminal recipe, counting Z separately; once its completion predicate holds -> OutputClosed. Fault, lack of progress or deadline -> Failed. |
| OutputClosed | Never generate more output; publish held suffix. Await queue drain and authoritative downstream fence, then -> Complete. |
| Complete | Freeze terminal evidence; reclaim after all converter/worker borrows have ended. Repeated completion reporting has no new side effect. |
| Failed | No successful completion acknowledgement. Cancel/stop owners and reclaim only after fences; further native calls are limited to required safe cleanup. |

State labels do not themselves provide synchronization. A callback count of zero
or a queue-empty load is not the device join. The worker must also release its
own borrows. Generation replacement creates a new initialized state only after
the old storage is reclaimable; never reset native history under a callback.

The upstream process API has no generic natural-EOF signal. A null input pointer
supplies synthetic zero values when counts request input; a null output pointer
can invoke seeking. Neither is an implicit flush. Keep both output and count
arguments explicit in the product adapter. A zero input *count* may still permit
cached output; discover that behavior for the selected algorithm rather than
assuming it completes the tail. Reset clears history/timer and cannot attest that
history was rendered.

The terminal recipe must identify algorithm/filter configuration, permitted input
padding, output cap, count/energy comparison window, maximum owner turns and wall
deadline, empty-stream behavior and residual/truncation criterion. An IIR filter
may have an asymptotic tail: exact zero forever is not a finite completion test.
If truncation is chosen, expose its quantified limit and account for discarded
produced output; do not invent a count for unmaterialized infinite output. Backend
latency queries are useful observations, not a proof that padding that many zeros
drains every possible signal or filter state.

## Worked prefix trace

This is a hand-worked custody example with scripted successful counts, not a
prediction of a particular native resampler. Real source total is six frames;
native output total happens to be seven frames including tail effects. Queue
capacity is two. Omitted counters retain their previous value.

| Event | U | C | Z | P | H | Q | B | S |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| Admit six | 6 | 0 | 0 | 0 | 0 | 0 | 0 | 0 |
| Process consumes 4, produces 3 | 2 | 4 | 0 | 3 | 3 | 0 | 0 | 0 |
| Publish only 2 | 2 | 4 | 0 | 3 | 1 | 2 | 0 | 0 |
| Callback copies 1 | 2 | 4 | 0 | 3 | 1 | 1 | 1 | 0 |
| Publish retained 1 | 2 | 4 | 0 | 3 | 0 | 2 | 1 | 0 |
| Close source; process consumes 2, produces 2 | 0 | 6 | 0 | 5 | 2 | 2 | 1 | 0 |
| Callback copies 2; publish held 2 | 0 | 6 | 0 | 5 | 0 | 2 | 3 | 0 |
| Terminal recipe consumes 1 synthetic zero, produces 2 | 0 | 6 | 1 | 7 | 2 | 2 | 3 | 0 |
| Callback copies 2; publish final 2 | 0 | 6 | 1 | 7 | 0 | 2 | 5 | 0 |
| Callback requests 3: copies 2 and fills 1 silence | 0 | 6 | 1 | 7 | 0 | 0 | 7 | 1 |

At the last row A=C=6 and P=B=7, whereas callback output is 8. Queue drain alone
still does not mean Complete: the recipe must be closed and downstream/worker
fences must be observed. Add a negative case that attempts completion before each
of those conditions. Short/zero publications must leave the same identities true.

## Acknowledgement and discontinuity obligations

Current application completion is specified for its non-resampled source-copy
frontier. Conversion destroys that one-to-one mapping. A future completion record
can state source admission/consumption frontier, output total and copied frontier,
terminal policy ID, explicit discards, generation and downstream fence result.
It still cannot promise acoustic presentation. Define how peers negotiate and
interpret this record before sending it under an existing success meaning.
The worked example's conservative lossless-success check additionally requires
Ds=Do=0. A terminal result with disclosed loss is a different outcome and must
not be encoded as that lossless success.

At underrun, separate output silence from converted output and apply the chosen
rebuffer/drop/mapping policy. Do not play all retained late data indefinitely or
silently count concealment as successful source delivery. Arbitrary midstream
source dropping while retaining filter history requires its own discontinuity
contract; the conservative experiment is to fail or replace the generation.

For graceful progress, state environmental premises: continued positive native
progress under the chosen finite recipe, eventual output capacity, callback
return and successful owner fences. Bounds/deadlines cause an explicit failure
if these premises do not hold. A finite scripted trace is not a liveness proof
for an arbitrary backend or stalled device.
