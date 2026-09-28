# Lifecycle preparation and takeover audit

This phase supplies a concrete C02 contract and executable finite specification.
It does not implement the production lifecycle or claim R03-R08/native completion.
No runtime, build graph, wire protocol, vendor code or dependency pin changed.

## What the future implementation now has

[Lifecycle transactions](../../docs/design/lifecycle-transactions.md) defines
resource and in-flight-operation identity, parent borrows, partial failure,
bounded effect/result capacity, cancellation/late-success semantics, method/event
contracts, native and worker fences, outcome dimensions, deadline behavior and
specific fake/native acceptance schedules. It explicitly distinguishes application
stop from native admission closure and callback return from resource reclamation.

[Takeover readiness](../../docs/implementation/takeover-readiness.md) separates
settled choices from facts still required for identity, physical fidelity, clock
correction, network recovery, Mac qualification, UI, Docz migration and release.
It retains C02-C09 order and names which missing facts block coding versus release.
The next production files are still lifecycle.zig and its fake-owner fixture.

## A discovered design failure, not just a green model

The unmutated first draft allowed this schedule: acquire storage and device; issue
worker creation; cancel; complete native fence; release device; receive successful
worker creation. Its worker then referred to a released dependency. The one- and
two-generation domains both rejected the draft with WorkerLifetime. The original
model/runner, command, raw JSON and stderr are preserved under attempt-1.

The correction retains parent resources while dependent acquisition is outstanding
and checks this debt explicitly as AcquisitionBorrow. A dedicated mutation now
removes that guard and must produce its intended counterexample. This is a defect
found and fixed in the preparation specification, not an observed bug in a shipped
or implemented runtime controller.

## Current finite evidence

The normal domains contain 64 states/363 edges (one generation) and 127 states/730
edges (two generations). All 46/92 stopping states respectively have a path to
release within their own generation. This is existential reachability, not a fair
temporal liveness proof. The environment may stall forever; no hard OS deadline
is established by an available cleanup path.

Six injected defects must fail their named predicates: forgotten pending result,
lost late success, stale completion mutation, live-worker release, pending-parent
release and unjoined-device release. Five input/budget controls reject zero or
boolean generation counts, zero state capacity, an unknown fault and exhausted
state capacity. The runner qualifies only the exact mutation witness, never an
arbitrary exception. Normal and optimized Python runs are recorded separately in
model-normal.json and model-optimized.json, with their commands in checks.json.

The model abstracts three aggregate resources, one pending acquisition, one worker,
one active callback and at most two generations. Wrong-token categories are abstract
classes, not a tested concrete comparator. Authorization, media samples/frontiers,
TLS custody, weak memory, crash persistence and actual native operations are outside
this model. Existing TLA+ models remain unchanged and are not rerun in this phase.

## Parallel documentation integrated

The miniaudio owner's ten-entry ecosystem delta and 43-file snapshot add library
capability/configuration, qualification comparison, adoption and Docz migration
contracts. The TLS owner's r4 documentation adds eight indexed files and updates
its existing work obligations. Their before/after/source evidence was checked;
the application imports canonical navigation and preserves earlier receipts.
This does not introduce either ecosystem integration into the audio runtime.

Documentation/index/link and dependency custody checks are recorded in checks.json.
The final receipt binds all current file hashes, before-images, failed and repaired
model evidence and unchanged production inputs. A file count establishes navigation
coverage, not paragraph-level semantic perfection or product completion.

The Mac is still unavailable and Monterey unconfirmed. Native lifecycle, real
credential/network integration, two-host first sound, sustained drift/recovery and
delivery qualification remain the explicit implementation gates.
