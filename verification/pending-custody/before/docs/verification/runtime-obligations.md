# Runtime verification obligations and independent oracles

Status: executable model checks exist; the runtime tests specified here are
planned. No row is a passing product test merely because its scenario is written.
This chapter refines [qualification scenarios](scenarios.md) for the
[runtime blueprint](../implementation/runtime-blueprint.md).

## Harness boundary

Use fake native owners, a virtual monotonic clock and a scripted byte transport
to test the same lifecycle and worker state machines used by real endpoints.
Inject failures at resource boundaries through explicit test adapters; do not add
production environment variables that bypass authorization or callback fences.
Test scheduling must be reproducible by an event trace, not sleeps chosen to make
a race rare. Native integration then tests that the adapters satisfy these contracts.

The oracle owns a separate list of `(generation, source_frame, sample_words)`.
Expected order and accounting come from this source list, not from the production
gate's next_frame, queue indices or assembler output. Each simulated callback
records the exact media prefix it copied and a separate silence suffix. The test
compares lists and explicit event order after quiescence. A production counter
agreeing with another production counter is insufficient independence.

## Required cases before first-sound qualification

| ID / planned test home | Stimulus | Independent result and forbidden success |
| --- | --- | --- |
| R01 `tests/unit/runtime/pending_block.zig` | Source blocks 1,17,240,1024,3; destination accepts varied prefixes including zero | Concatenated copied frame/sample identities equal source; cursors advance only by accepted frames; never discard a suffix. |
| R02 same | Hold a pending suffix; present another complete AUDIO and coalesced unread plaintext | Parser storage not reused until borrowed payload copied; bounded retained bytes; next AUDIO not admitted over a live pending block. |
| R03 `tests/integration/runtime_lifecycle.zig` | Stop before first frame; END at zero | No unnecessary device start; empty completion follows actual fences; no fabricated AUDIO. |
| R04 same | END after 1 frame with Prefill=2; final partial block; END while pending is nonempty | Tail plays without waiting for full prefill; pending publishes fully; terminal frontier equals source count. |
| R05 same | Callback releases queue slots, then pause it before return | Queue-empty may be observed; ACK/free/reset must remain forbidden until the callback join/final snapshot. |
| R06 same | Full queue, blocked transport, then abort or deadline | Cancellation wakes owner; cleanup never requires the now-disabled consumer to empty the queue; residual custody counted without success ACK. |
| R07 same | Inject failure before/after each successful acquisition and native start/stop | Each successfully acquired resource released exactly once after borrowers release it; failed acquisitions create no cleanup debt. |
| R08 same | Graceful stop repeated; abort races stop; start-stop-start; delayed old-generation status | Control operations converge without duplicate cleanup; stale result cannot start/stop/publish into the new generation. |
| R09 `tests/integration/capture_sender.zig` | Overflow immediately before/after queue read; null input; nonfinite accepted samples | Sticky fault observed before any post-loss concatenation; stream aborts; no successful END disguises source loss. |
| R10 same | beginWrite rejects before copy; fails after accepted copy; sends repeated short prefixes | Gate/assembler commit only after accepted copied custody, once; later failure terminates connection with explicit uncertainty. |
| R11 `tests/integration/playback_receiver.zig` | Invalid profile, wrong stream, gap, duplicate, post-END AUDIO; malformed final record | Typed rejection before affected media publication, no ACK success, bounded cleanup. Reuse independent Python byte construction. |
| R12 same | Midstream underrun, startup silence, known final zero suffix; device disappears | Categories distinguish source media and device silence; unclassified underrun cannot pass uninterrupted-playback acceptance. |
| R13 `tests/integration/network_host.zig` | Read/write waits, trickle bytes, cancellation, raw EOF, clean close; both IP families | Fixed total deadlines survive progress; no second Driver owner; each native handle closes once; IP results recorded separately. |
| R14 `tests/integration/peer_policy.zig` | Cryptographically trusted but unlisted peer, wrong role, changed key, expired certificate, corrupt store | Deny before capture/audible admission; no public fixture/frozen time/plaintext fallback in product path. |
| R15 `tests/e2e/two_host.py` | Actual Windows system capture and selected Intel Mac output, bounded run and restart | Record real devices/formats/credentials policy/binaries and independent output observation. Null/Python fixtures cannot satisfy this row. |

The three new test destinations beyond the original work packages
(`tests/unit/runtime/pending_block.zig`, `tests/integration/capture_sender.zig`,
`tests/integration/playback_receiver.zig`) are proposed homes. Create each only with
a real tested responsibility; merge with runtime_lifecycle when it improves clarity.
They are not empty directories waiting to be populated.

## Resource ledger and failure matrix

For each resource type record states absent, acquired, borrowed, quiescing,
released. Test every acquisition prefix: configuration storage, native context,
device, process socket reference, socket, TLS Engine, worker. The adapter may
combine native context/device acquisition, but the failure injection must still
distinguish their obligations. Record acquisition IDs and release counts in the
fake owner; use independently tracked borrow tokens to reject early destruction.

Do not equate every failure with immediate release. An in-flight callback retains
a borrow during stopping. If the fake native fence never returns, the expected
result is an outstanding resource/failed-stop observation, not a test that demands
unsafe reclamation. Fair-return tests establish eventual cleanup under that premise;
separate stalled-native tests establish truthful reporting and absence of use-after-free.

For real adapters, measure native cancellation/join duration and inspect handle,
thread and device ownership after each run. A bounded logical model cannot certify
an OS deadline. Include repeated cycles and fail-after-allocation cases; a single
successful start/stop does not exercise partial initialization.

## Trace schema for future runtime runs

Use versioned structured records with explicit units and observation owner:

| Field group | Required meaning |
| --- | --- |
| Run identity | schema version, run ID, source/compiler/SDK/binary hashes, target/OS/driver, fixture or physical mode |
| Event identity | owner ID, monotonically increasing owner-local event sequence, connection generation, stream ID; no secret material |
| Time | local monotonic timestamp and domain ID; simulation time separately labeled; certificate wall time only as verification metadata |
| Media | source first_frame/count, admitted/published/callback-consumed frontier, pending frame count; byte counts explicitly typed |
| Ownership | acquisition/borrow/release ID, operation start/completion, stop reason, native/worker fence observation |
| Outcome | expected versus observed category, stdout/stderr/return code, deadlines, final resource ledger, measurement limitations |

Events from different owners form a partial order through release/acquire and
request/response links. Sorting unsynchronized timestamps does not create a valid
causal total order. Reconstruct the explicit links or preserve ambiguity.
Routine product telemetry stays bounded and excludes sample payloads; synthetic
test word sequences belong to fixtures. Physical raw audio is not retained by
default. Status snapshots must be published race-free rather than assembled by
reading callback-owned plain counters concurrently.

Counters must define saturation/exhaustion behavior. A saturated counter loses
exact accounting; mark the run indeterminate for conservation claims rather than
subtracting saturated values. Production frame frontiers use checked nonwrapping
arithmetic; SPSC modular slot indices are a different domain.

## Gates and evidence freshness

Run pure/model/fake-owner checks on the inspected source revision, then only the
native checks supported by the actual host. Record missing Mac evidence as
unexecuted. Pin the actual OS/build when the Mac becomes available; Monterey is
currently a user-reported possibility. Review fixture identity and actual private
TLS loading independently of application framing.

The [ReceiveDrain argument](../design/receive-drain.md) has an executable finite
oracle and falsifying mutations. It does not mark R01-R15 implemented. Each future
test must record its exact command, seed/trace, code and tool hashes, expected
negative error and final cleanup state. Preserve failed evidence before repair;
publish a new receipt instead of editing an old success claim.
