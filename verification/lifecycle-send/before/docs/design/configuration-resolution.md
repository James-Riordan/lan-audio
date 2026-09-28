# Configuration resolution and operation snapshots

Status: proposed production design; no configuration parser, persistent settings
store or MetaOS adapter is implemented here. This is the executable-code contract
for C06/WP08, preserving the [ecosystem boundaries](../architecture/ecosystem-integration.md).
Existing compiler/package files remain authoritative for their current roles.

## Four separate authorities

| Input | Owns | Does not own |
| --- | --- | --- |
| `build.zig` | Build graph, modules, selected target/options and generated artifacts | Runtime peer trust, current terminal context or live device choice |
| `build.zig.zon` | Zig package identity, dependency references and package closure | ZSON grammar or arbitrary runtime settings |
| Future versioned ZSON profile | Authored audio settings using the ZSON owner's admitted schema/evaluation profile | Compiler dependency pins, credentials themselves or ambient authority to execute code/network reads |
| CLI / future UI request | Explicit overrides, operation intent and selected profile | Permission to weaken authentication, mutate a running snapshot or silently downgrade fidelity |

Compile-time configuration may specialize a bounded implementation; it must expose
the resulting capability limits for runtime validation. Runtime settings cannot
enable a backend excluded from the build. Schema versions, media protocol versions,
package versions and configuration revisions have different meanings.

## Pure normalization, policy and feasibility

Let each layer L_i be a finite partial map from typed field paths to values.
Absence, explicit reset-to-default and a value are distinct states. Reset is legal
only on fields whose schema defines it; null is not an implicit deletion rule.
Decode each layer under one explicit schema version, rejecting duplicate keys,
unknown fields and unsupported versions before combining it. Migrations are named
pure transformations with preserved source and declared information loss.

Proposed priority for ordinary user settings, lowest to highest:
shipped defaults, user settings, explicitly selected project/profile, explicit
invocation overrides. No directory walking, environment-variable expansion or
terminal-context lookup occurs inside the pure resolver. The host supplies an
explicit bounded context snapshot and records which profile it selected. A project
profile is configuration data, never implicit permission to start capture or pair.

For scalar field k, winner(k) is the highest-priority present legal assignment;
retain its layer/path/revision as provenance. Arrays replace as whole values;
there is no implicit concatenation of trusted peers or endpoints. Known record
fields resolve by path; arbitrary map merges require a schema-specific law. A
policy constraint is validated after resolution and cannot be overwritten by a
higher-priority setting. Trust material is a separately authorized store/reference,
not a low-priority value that an untrusted project can override.

Define Resolve(L, S) -> Candidate | Error, where S is a fixed schema/migration
profile. Define Validate(Candidate, Policy, K) -> Effective | Error, where K is a
capability snapshot. Required properties under identical inputs:

* Determinism: Resolve and Validate return equivalent typed results/errors and
  provenance. Input iteration order cannot affect resolution.
* Canonicalization: N(N(c)) = N(c) for a schema's normalization N; units and numeric
  ranges are validated before narrowing conversions. NaN/infinity are rejected.
* Failure purity: errors open no device/socket, change no trust, write no settings
  and publish no partial Effective configuration.
* Authority separation: effective values satisfy every mandatory policy constraint;
  override precedence cannot widen authorization.
* Snapshot isolation: an operation owns immutable Effective_o plus its revision;
  later context/settings revisions cannot mutate it.

These laws do not make merging commutative: swapping priorities can deliberately
change the result. Repeating an operation with the same settings is not necessarily
idempotent, because start/capture have effects outside the pure resolver.

## Bounds, identity and time

Set finite limits for file bytes, nesting, fields, strings, arrays, diagnostics,
evaluation steps and total included content before admitting a language profile.
Prefer a data-only profile for the initial product. If imports/evaluation are later
admitted, specify allowed roots, cycle handling, dependency revisions and resource
budgets with the ZSON owner; never add a private evaluator here. No unbounded file
read or resolution runs on a callback or audio worker.

Effective settings contain typed source/sink identifiers, authorized peer
reference, media format, bounded buffer/deadline policy and redacted diagnostic
metadata. Human labels and current addresses accompany identities but cannot
replace them. Secrets stay in their platform credential owner; diagnostics carry
opaque references, not credential bytes. A configuration digest detects equality
only for its declared canonical representation; it is neither authentication nor
a persistent uniqueness guarantee. Use a monotonic revision or explicit store
revision token for change control, with exhaustion handled before reuse.

Capability checks can race with hotplug or permission changes. Validate against
K_t, then revalidate at native acquisition. Failure follows the lifecycle's
partial-acquisition cleanup ledger. No read-validate-open sequence can guarantee
the device remains available afterward; runtime events handle subsequent loss.

## Publication and restart

PlanUpdate(old, candidate) classifies changes as presentation-only, restart-required,
or forbidden by current policy. Initially every audio/peer/device/buffer/control
change requires a new stream generation; no unqualified live retuning is promised.
Presentation changes may update UI state without changing Effective_o. Stop/join
old owners before reclaiming their storage or applying a new native configuration.

Persistent settings publish a fully validated next revision using a platform-
qualified atomic replacement protocol. Specify flush/durability and concurrent
writer behavior; an atomic rename alone is not a power-loss guarantee. A compare-
revision mismatch fails without lost updates. Preserve old bytes for failed
migrations and define unknown-future-version behavior. Retrying the same completed
write returns its revision only under an explicit operation-token contract;
otherwise re-read and resolve the conflict. Do not invent cross-process status/stop
or a service merely to persist settings.

## Planned files and dependency order

| File / owner | First caller and contract | Independent acceptance evidence |
| --- | --- | --- |
| `src/app/config.zig` | C06 command entry calls typed normalization/resolution/validation; no OS or language parser in its pure core | Table-driven expected resolved values/provenance, permutation of input order, invalid-unit/unknown-field/duplicate/version/policy cases; no side-effect calls on rejection |
| `src/app/settings.zig` | C06/WP08 host layer reads bounded sources and publishes revisions; invokes config validation | Faults at read/write/flush/replace, concurrent expected-revision mismatch, preserved old revision after failure; actual platform durability limits recorded |
| `src/app/commands.zig` | CLI now and future UI invoke shared typed operations using an immutable effective snapshot | Context changes during start cannot redirect peer/device; repeated stop and conflicting request-token reuse; rejected inputs cause no acquisition |
| `src/app/presentation.zig` | Derives understandable states/recovery actions from owner snapshots | The same snapshot produces coherent CLI/UI meaning; no playing state for mere authentication, no stopped state before quiescence |
| `tests/unit/app/config.zig` | Pure oracle for config.zig, independent of the production merge | Highest-precedence/reset/array replacement cases, deterministic errors, N(N(c)) = N(c), finite numeric/resource limits |
| `tests/integration/commands.zig` | Existing planned command acceptance fixture with controlled host operations | Acquisition event ledger, retry conflict, permission loss after validation, immutable stream configuration, failure cleanup |
| `tests/integration/settings.zig` | Controlled storage adapter plus target-specific publication tests | Crash/fault schedule, conflicting writers, unsupported-version preservation and redacted exports |

These are proposed destinations, not empty files to create now. Share existing
types only when they already express the same contract; do not add a universal
configuration framework to implement a small application. The first CLI can supply
typed arguments directly. Add a ZSON adapter under the settings boundary only when
its supported package/profile is selected, with parser-independent equivalence
tests against those typed arguments and the same Effective result.

Optional MetaOS/context integration follows this seam after local operation works.
The initial independent acceptance case is the same resolved operation run with
and without that adapter, producing equivalent audio policy and lifecycle events
under identical capabilities. Equivalence concerns declared semantics, not equal
wall-clock schedules, pointer values or host-specific diagnostics. Real Windows/Mac
execution and permissions remain separate qualification gates.
