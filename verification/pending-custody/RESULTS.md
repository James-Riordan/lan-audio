# Pending receive custody: implementation and qualification

This phase implements C01, the private PendingBlock helper, and uses it in the
authenticated v2 receiver fixture. It completes a bounded receive-buffer slice;
native continuous Windows-to-Mac playback remains unfinished. The next application
slice is C02, fake-owner lifecycle transitions and failure/quiescence tests.

## Behavior and mathematical contract

An AUDIO record is decoded into owned fixed storage before parser reuse. If the
playback queue accepts only a prefix, the remaining suffix survives until copied.
The candidate protocol gate commits only after admission succeeds. Rejected
admission changes neither storage nor metadata. The representation invariant is
`0 <= offset <= frames <= max_frames <= 1024`; the retained frame interval is
`[first_frame + offset, first_frame + frames)`, with a checked nonwrapping endpoint.
Every advance transfers exactly its reported prefix. Abort accounts for the local
remainder once; already queued media belongs to a separate ledger.

See [the implemented contract](../../docs/media/pending-block.md) for assumptions,
API/error precedence, borrow lifetime, failure-atomicity argument, complexity,
and the limits of this manual refinement argument. Positive advance is deliberately
not idempotent: replaying a successful count may consume a different prefix.
Existing finite ReceiveDrain/RuntimeOwnership models are unchanged and were not
rerun; their historical evidence is not a new proof of this Zig implementation.

## Observed checks

| Check | Result and scope |
| --- | --- |
| Pure Debug suite | 42/42 executed successfully; original completed tool output is preserved in debug-execution-observation.json. The later command-1.log is a cached rerun. |
| Pure ReleaseSafe suite | 42/42 executed successfully; command-2.log. |
| Seven new unit tests | Independent integer sample oracle; queue capacities 1, 8, 32, 4096; record sizes 1, 17, 240, 1024, 3; short/zero writes, failure atomicity, Busy, bounds, abort, parser reuse and gate non-commit. |
| Intel macOS and ARM64 Linux | Pure test artifact compilation passes; no target execution, native audio/TLS qualification or Monterey compatibility claim. |
| Independent authenticated v2 peer | 22/22 scenarios pass in interop-final.json; every peer thread terminated. |
| Nonempty v2 receive | 1,285 exact frames verified through an eight-frame queue; 1,680 short writes include 1,260 zero writes. Synchronous three-frame reads, not physical playback. |
| Existing v1 regression | 16/16 scenarios pass in v1-regression.json, including the explicit silent audio backend. |
| Application audio-library consumer | 1/1 executes successfully with a new build-cache path after the dependency's ABI build changes; dependency-consumer.json records unchanged input hashes and the raw log. No physical I/O. |
| Formatting | Zig format check passes. |

The v2 peer checks TLS authentication/ALPN, exact sample words, queue observations
and expected negative-case errors. ACK in this fixture attests completion of the
synchronous verifier; it does not attest native callback drain or acoustic output.
Synthetic extrema remain test data and are never sent to physical speakers here.

## Failed attempts and explicit dependency adoption

An initial test used unsupported direct array-literal indexing. The syntax failure
and attempted source are preserved; a named array repaired the test. This failure
was not a discovered media algorithm defect.

The first TLS run was rejected before networking because the sibling TLS chat had
updated a pinned README. command-6.log preserves that rejection. Review found nine
changes: README navigation, leading source comments, and two documentation package
paths. tls-documentation-adoption.json records complete diffs and old/new hashes;
dependency-before and dependency-adopted preserve exact bytes. The original source
bodies are unchanged after line-ending normalization, and the other 179 pins,
including SDK and public fixtures, retain their old hashes. The transport lock
adopts only those reviewed nine changes. All four subsequent transport commands
pass; the guard remains enabled. No generic dependency-pin refresh was performed.

## Documentation ownership and continuation

The application handbook now describes the implemented helper at source, API,
module, runtime, work-package, proof-ledger and acceptance-test levels. Its registry
links dependency-owned miniaudio/TLS documentation instead of duplicating their
authority. The separate dependency chats retain their own source-scoped evidence.
The miniaudio Q01 increment independently compares C/Zig layout and a synthetic
callback boundary in four Windows Debug/ReleaseSafe native/null configurations:
eight library tests and one separate public consumer pass in each configuration,
and all eight deliberate size/profile mismatch runs are rejected for their intended
runtime witnesses. Its first incomplete classifier attempt remains preserved. The
application imports 18 changed/new file contracts; miniaudio-abi-integration.json
binds the owner's exact source snapshot and raw evidence. Production audio source,
profile, package metadata and adopted vendor bytes remain unchanged.
The application receipt records the exact shared-tree snapshot; later dependency
work requires another integrity check and does not inherit this phase's results.

Continue at [START_HERE](../../docs/implementation/START_HERE.md) and
[the ordered completion sequence](../../docs/implementation/completion-sequence.md).
The final receipt records source hashes, preserved history, documentation checks
and complementary dependency evidence. The inventory establishes file coverage,
not the semantic completeness of every paragraph or a universal correctness proof.

The Mac remains unavailable; its macOS version is unconfirmed. Native sender and
receiver orchestration, clock-drift handling, bounded network recovery, production
identity, user experience, packaging and real two-device qualification remain open.
No finite buffer can hide an unbounded network outage while retaining bounded
latency and every sample. Recovery behavior must be explicit and measured.
