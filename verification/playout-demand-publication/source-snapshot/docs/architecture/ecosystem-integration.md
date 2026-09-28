# LAN Audio within the JCR ecosystem

Status: accepted architectural requirements from James's 2026-09-26 ecosystem
vision; integrations described as future remain unimplemented. This chapter owns
the application's integration boundaries. It does not redefine the ecosystem's
languages, primitive libraries, document formats or host-management APIs.

## Product identity and dependency direction

LAN Audio is a prospective Zigadel ZApp under JCR. `lan-audio` remains its
descriptive working directory; no final brand or command alias has been chosen.
Its public purpose is authorized source-to-sink audio delivery. `miniaudio-zig`
is an independently usable upstream technology wrapper (a Zig Lib), not the app
or a new primitive ZLib. `tls-zig` and candidate `quic-zig` own their transport
capabilities. A source repository, package, application, deployment and ecosystem
membership are distinct identities; membership alone introduces no runtime edge.

The [canonical ownership record](../../../jcr-architecture/docs/ONTOLOGY-AND-OWNERSHIP.md)
provides the wider vocabulary. The local [dependency record](../DEPENDENCIES.md)
owns actually admitted packages. Application policy depends on library capabilities;
libraries must not import this application's latency choices, peer allowlist,
commands, account policy or UI. Keep concrete internal types until extraction has
real consumers, shared laws, a minimal interface and migration evidence.

| Boundary | Application responsibility | Owning ecosystem / adoption condition |
| --- | --- | --- |
| Audio | Frame identity, stream lifecycle, selected source/sink, fidelity and recovery policy | miniaudio wrapper supplies qualified native calls; no inferred precision or lifetime guarantee from an API name |
| Secure transport | Peer authorization, role, media protocol and application deadlines | TLS/QUIC own channel mechanics; admit actual qualified capabilities, not planned roadmap symbols |
| Configuration | Audio settings schema, units, bounds, provenance and side-effect-free validation | ZSON owns syntax/schema/evaluation; choose a real supported profile before importing it |
| System generation | Explicit build/deployment inputs and dependency closure | Sysl owns admitted generation/system meaning; generated outputs retain source/profile provenance |
| Host integration | Expose bounded typed operations and truthful capability/error results | MetaOS may resolve/install/launch/manage through a versioned adapter; core streaming also works without it |
| Selected context | Resolve a candidate project/profile before an operation | Contextz owns terminal context; freeze resolved inputs and authorization at operation creation |
| Network policy | Work within allowed endpoints/routes and report denial | Zap owns supported policy execution; do not silently change firewall/VPN/routes or disable validation |
| Content identity | No recording by default; explicit export/record consent and retention | Mediaz owns content/revision/provenance when recording becomes a feature; live stream IDs are not content IDs |
| Documents | Preserve explanation, examples, source links, mathematics and evidence | Docz owns `.dcz`; Quartz owns presentation/workspace envelopes; use the migration gate below |
| Observability | Bounded counters/events, snapshot consistency and redaction | Future ZObserve adapter consumes exported facts; missing collector cannot stall the audio callback |
| Deployment | Reproducible self-contained local product closure | Optional Hydra orchestration consumes a qualified package; an account, cluster or hosted control plane is not needed for the first local stream |

No adapter in this table exists merely because its owner is named. Any admission
records concrete package revision, exported API, licensing, trust/capability scope,
failure behavior, target execution and rollback. Optional GUI dependencies must
also be absent from a successful headless build; a runtime switch alone is not
proof of optional package closure.

## Decoupling with explicit identity and capability

Use typed semantic identities where required; retain actual locators at I/O
boundaries. A peer's address may change without changing its authorized identity.
A device's display name is not its native identifier. A filesystem path is not a
project identity, a hash is not authority, and a stream generation is not a peer.
No universal identity registry or new database is required for these distinctions.

For operation o, capture immutable resolved configuration C_o, authenticated peer
identity P_o, stream generation G_o and selected endpoint identity D_o. Native
capability observation K_t can expire. Opening must revalidate the selection;
changes after opening become explicit device/transport events, never silent
substitution of an unrelated source or sink. An in-progress operation uses C_o
even if terminal context or settings change. A new configuration applies only
through a documented transition with fresh validation and ownership rules.

Zig target support does not imply an available OS API, permission, driver, native
SDK or deliverable package. [Platform capabilities](platform-capabilities.md) owns
the current target gates. Adaptation selects an evidenced feasible capability;
it cannot make unavailable capture or playback exist. Fidelity reductions require
an explicit policy and visible status. Measured miniaudio converter limitations
must be resolved at the adoption boundary before claiming fine clock correction.

## Simple operations over one engine

The first surface is a foreground command using typed validated configuration.
Later CLI, terminal UI, tray/menu UI or optional web GUI must invoke the same
application operations and read the same snapshots. UI code owns presentation,
not an alternative network/audio engine. No SvelteKit/Bun/browser dependency is
admitted by this design; select a UI realization when its platform and packaging
requirements are known. Do not invent global aliases or `!` semantics here.

One action can orchestrate many internal steps, but start, permission, trust,
recovery and failure remain visible. Never equate connected with playing, silence
with recovered audio, stop-requested with quiescent, or a successful launch with a
successful stream. The state/error source of truth remains the runtime owner.

## Retry, update and diagnostic laws

Idempotence is operation-specific. Within a defined owner lifetime, repeated
`stop(G)` converges without double release. A future repeated `start(request_id,
configuration_revision)` returns the original operation only when payload and
authorization match; conflicting reuse fails. Durable replay behavior requires
explicit persistence semantics and is not implied by an in-memory request ID.
Generation exhaustion must fail or establish a newly qualified namespace, not wrap
onto a live/stale generation. Sequence positions reject duplicated media; they do
not authorize replay. Positive PendingBlock.advance is explicitly non-idempotent.

An updater may install/verify a candidate version while an old version runs if
their ownership is isolated. Switching executable/native-library sets requires
quiescence, consistent dependency closure and a known restart boundary. Never
replace a loaded DLL in place, mutate transport pins automatically, or use an
update retry to start capture again. Configuration migration and downgrade must
retain their own reversible/irreversible transition contracts. No update adapter
or transactional installer is implemented by this chapter.

For diagnostic baseline B and current observation N, classify findings by stable
rule/component/normalized-location identity under the same comparison profile.
Compare multisets when multiplicity matters. New, persistent and resolved findings
are meaningful only if sources, tools, policy and environment remain comparable;
otherwise report incomparable and retain both records. Never silently label all
changes new or all old findings harmless. Export minimal redacted configuration,
source/tool/profile IDs, causes, counters and reproduction steps. Exclude keys,
raw audio and sensitive endpoint details unless an explicit user-approved export
policy allows them. Audit obligations and optional performance telemetry differ.

## Quartz / Docz migration gate

James's intended authored format is `README.dcz` and `/docs/*.dcz`. Current authored
documentation and local checks use Markdown. Keep it usable while an owner-backed
conversion is prepared; renaming extensions does not implement Docz semantics.
Before switching canonical authority, qualify a pinned producer/reader profile,
source retention, mathematics/code rendering, links/anchors, automation and a
portable readable export. Choose `.dcz` authority and generated Markdown projection
deliberately; never maintain two independently editable authoritative copies.

The migration manifest must map document identity, old/new path and anchors,
source hashes, tool/profile revision and export role. Verify round-trip preservation
or record every intentional semantic change; test navigation and examples with
the actual Docz/Quartz owners. Migrate links/checkers atomically, preserve historical
receipts and retain rollback bytes. Do not rewrite immutable phase evidence into
the new format or invent a local `.dcz` grammar. This gate precedes conversion.

## Implementable obligations

The [configuration design](../design/configuration-resolution.md) supplies pure
functions, failure boundaries, file destinations and independent checks. Add
adapters only with a real caller and bounded vertical test. Existing C02 lifecycle
work still precedes usable C06 commands; ecosystem breadth does not reorder away
from reclamation, authorization or physical-device qualification.

For each new boundary, record: its owner and authority; inputs/outputs and units;
identities versus locators; mutation/borrow/commit points; resource bounds and
cleanup; meaningful retry behavior; an independent oracle and failure schedule;
target-specific evidence; and the next unmet gate. Architectural adjectives are
requirements to operationalize, not evidence that implementation meets them.
