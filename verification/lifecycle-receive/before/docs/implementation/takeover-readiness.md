# Takeover readiness: what is settled and what still needs evidence

Implementation has begun in the existing local Codex-backed chat. The
[C02a lifecycle core](../runtime/lifecycle-core.md) is real Zig code with fake-owner
callers, recorded in [its results](../../verification/lifecycle-core/RESULTS.md).
This audit separates that completed subset from remaining C02 and native work. It is not
a declaration of product completion. The goal is a sequence that can be followed
without reconstructing decisions from chat, with uncertainty located at explicit
gates rather than hidden behind a general quality aspiration.

## The next implementable unit

C01 pending receive custody is implemented. C02's
[transaction contract](../design/lifecycle-transactions.md) now supplies state and
operation identity, bounded effect/result delivery, late-success ownership,
native/worker fencing, cleanup dependencies, outcome dimensions, method contracts,
failure schedules and a finite falsifiable model. Acquisition/abort/reclaim and
its fake-owner tests are implemented; compose graceful media outcomes next, before
adding real native orchestration.

Continue `src/runtime/lifecycle.zig` and
`tests/integration/runtime_lifecycle.zig`, now wired as a private module/test step in
the existing build. Keep native operations outside the transition code. The fake
executor must instantiate the same controller production adapters will use.
Do not declare C02 complete from the Python model or a mock containing a second
copy of the intended state machine. R03-R08 include frame/tail cases that additionally
need the existing PendingBlock/queue and stream contract in the composed harness.

## Decisions that must not be guessed

| Subject | Settled preparation / authority | Missing evidence and when it blocks |
| --- | --- | --- |
| Package identity | App-private media/runtime helpers; upstream wrappers retain independent ownership; final app name is open | Branding blocks publication/installation identity, not C02 implementation |
| Lifetime | Pending acquisitions retain parents; cancellation cannot erase debt; no reset until all owners/fences/results are reconciled | C02 fake event schedules first; C03 actual native fence and partial-init behavior before host composition |
| Fidelity | v2 finite binary32 word preservation ends before any DSP/device transform; v1 byte meaning remains unchanged | Output headroom/clipping and DSP quality policy before physical playback; synthetic extrema never go to speakers |
| Transport | Serialized Driver, bounded copied write custody, fixed deadlines, no second Driver owner | Generic verified-peer identity export, real host socket/readiness/cancel behavior and product credentials before C04/C05 real sessions |
| Configuration | Typed pure resolver, mandatory policy, provenance, immutable per-operation snapshot | Actual parser/profile bounds and atomic store behavior before ZSON/persistence; typed CLI can precede them |
| Graceful completion | END/ACK, local drain, native quiescence, remote confirmation and acoustic output are different claims | Role-specific worker/fence integration in C05; resampler tail policy before WP05; physical tail observation before a user-facing completed claim |
| Rate correction | Independent source/output units; measured generic ratio/phase-update limitations are adoption blockers | Qualified actuator path and signal/control oracle before tuning or enabling correction; no automatic large-denominator workaround |
| Network recovery | Fidelity first within a declared finite latency/storage/throughput envelope; degraded output counted | Actual adapter traces and user latency tradeoff before selecting recovery thresholds; simulations can start now with explicitly experimental bounds |
| Native targets | Windows/null evidence and Intel Mac build intent have separate status; Monterey unconfirmed | Actual Mac/SDK/device/permissions required for C07; never infer native execution from cross compilation |
| User experience | One foreground engine and coherent snapshots; GUI/context integration optional | Authenticated control-channel design before cross-process status/stop; actual UI/accessibility tests before normal-user delivery |
| Documentation | Current Markdown authority; planned owner-backed Docz migration with source/anchor/evidence preservation | Producer/profile and semantic migration qualification before changing canonical format |
| Distribution | Explicit source/tool/runtime closure; source receipts are observations, not vendor correctness certificates | License, signing, clean-machine install, private SDK loading, upgrade/rollback and actual platform acceptance before release |

These are deferred evidence gates, not a request for the user to answer every item
now. Use the existing explicit provisional settings for local experiments. Ask
only when the next step actually depends on a missing personal preference, device
fact or release decision. Preserve that answer in the decision register.

## Implementation order and branch conditions

1. Verify current source/custody and read the latest phase receipt. Shared chats
   edit the same trees; a previous snapshot does not cover later files automatically.
2. Extend the implemented C02a ledger/fake-owner schedules into full C02 graceful
   media drain and outcome dimensions. Preserve the pending-parent regression and
   independently test PendingBlock/queue/END/ACK composition; no success from queue-empty alone.
3. Implement C03 with real endpoint selection, sticky callback fault publication and
   qualified snapshot/fence behavior. Never read callback-owned plain diagnostics
   concurrently to make a test pass.
4. Implement C04's real network/identity seam; then C05 composes one synthetic
   authenticated round trip with the same owners and failure transitions.
5. Add C06 foreground commands over those owners. Configuration errors cause no
   device/network acquisition; stop remains usable under queue/transport pressure.
6. Execute native Intel Mac qualification when available. C07 first sound is a
   two-host observation. C08 timing/recovery and C09 delivery retain their own gates.

If a step exposes a lower-layer limitation, preserve the reproduction and propose
an owner-reviewed change; do not patch vendor bytes or refresh pins to remove the
failure. A new QUIC capability or Docz producer sample can inform a future gate
without replacing the current tested path by default.

## Before declaring any slice complete

Name the promised behavior, concrete files/callers, units and mutation boundaries.
Record independent expectations and the exact injected failure being rejected.
Check cleanup debt, stale generations, absolute deadlines and information retained
after an error. Explain mathematical premises and implementation refinement gaps.
Run relevant tests with the actual target/toolchain and retain raw failed attempts.
Update affected source/API explanations, proof/decision ledgers and file registry.

Run `zig build lifecycle-test` in Debug and ReleaseSafe for actual controller tests.
The earlier `python tools/check_lifecycle_spec.py` and optimized-Python run execute
the unchanged finite specification. The new source-scoped receipt distinguishes
controller execution, deliberately broken implementations, compile-only foreign
targets, prior model evidence and silent native regression. Maintain the existing
documentation/custody checks and rerun affected suites when their inputs change.

No amount of documentation can supply unavailable hardware observations or prove
an unwritten implementation. The actionable readiness standard is that each next
change has an owner, a concrete interface, explicit assumptions, failure behavior,
an independent acceptance method and a named unresolved boundary.
