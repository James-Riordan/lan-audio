# The audio dependency within the JCR ecosystem

Status: design requirements derived from James's 2026-09-26 ecosystem direction.
This package implements a thin native binding, not the integrations described
below. LAN Audio owns product behavior and its ecosystem architecture. This
chapter owns the dependency's side of that boundary. Proposed shared APIs and
formats require their owning project's actual contract before adoption.

## A small reusable component inside a broad system

`miniaudio-zig` exports an adopted C API through one Zig module. Its build has no
external Zig package dependency. That small surface is useful to MetaOS-managed
applications and to standalone consumers alike. Ecosystem membership does not
create a dependency on a project registry, terminal context, account, GUI, storage
model, configuration evaluator or orchestration service.

The user's one-command experience belongs to composition above this library. A
future update command may discover a candidate, qualify it and present a repair
report, but it must preserve this component's explicit source/profile/toolchain
identity. The real-time callback cannot discover configuration, await a registry,
evaluate a document, fetch a dependency or send telemetry.

| Responsibility | Owner / dependency-facing contract |
| --- | --- |
| Native audio API and algorithm | Adopted miniaudio source; this wrapper preserves reviewed bytes and reports qualification limits. |
| C/Zig build identity | This package's `build.zig`, profile and source manifest; one shared compile/translation profile. |
| Product audio policy | LAN Audio: endpoint selection, peers, gain, clocks, buffering, retry, recording and UI. |
| Project/workspace identity | MetaOS/projectz/workspacez owners; supply an explicit resolved package location/revision to a host operation. No terminal-context lookup inside the library. |
| Update orchestration | updatez/MetaOS owner; this package supplies source facts, checks and the [adoption transaction](../implementation/adoption-transaction.md). |
| Configuration language | ZSON owner; future host adapter produces validated typed settings or build inputs. This package invents no `.zson` grammar/evaluator. |
| Authored documentation | Intended Docz `.dcz` authority and Quartz presentation after the migration gate below. |
| Observation transport | Host/tooling owner consumes bounded [qualification records](../contracts/qualification-records.md); optional delivery cannot change pass/fail facts. |
| Deployment and native process lifetime | Application/installer/orchestrator owner. A source update does not modify the library already linked into a running executable. |

Keep technology wrappers independently reusable. Do not move LAN Audio's device
owner into this package simply because another ecosystem component may eventually
need audio. Extract an owner only after real consumers agree on lifetime, failures,
threading, types and verification, rather than just function names.

## Identity, location and authority

A package identity, source revision, build instance and installation are different
objects. A directory is a locator for bytes. An upstream commit identifies source
history, and a content hash identifies observed bytes; neither grants permission
to install or execute them. Display names cannot substitute for native device IDs.

An update attempt captures the resolved source root, expected base identity,
candidate identity, toolchain/profile, target set, qualification policy and request
identity before work starts. Later terminal-context changes cannot redirect its
reads, writes or target. Resolve again only by creating a new explicit attempt.
Do not bind long-lived operation meaning to the process's changing current directory.

Record logical relative file names separately from the resolved root used for I/O.
Verify containment and linked-path policy at use; lexical prefix matching is not
a safe containment test. Moving identical source to another allowed directory may
preserve source identity, but claims of build relocation invariance need tests
because build tools/debug metadata/caches may contain absolute paths.

## Configuration at the correct stage

| Stage | Current or future input | Rule |
| --- | --- | --- |
| Package resolution | `build.zig.zon` | Package identity/dependency closure; compiler floor is not a tested-version matrix or a runtime settings store. |
| Compile and translate | `build.zig`, `src/profile.h`, explicit target/options | Specialize one consistent ABI. Runtime settings cannot enable a compiled-out backend. Record actual compiler identity and profile, not merely desired values. |
| Admission tooling | Future typed updater policy, possibly decoded from ZSON | Exact candidate, allowed changes, checks and native target scope; no ambient executable configuration during verification. |
| Product acquisition | LAN Audio's validated immutable settings | Device/rate/format/trust/recovery decisions; acquire resources only after validation and retain original native result on failure. |
| Operation | Explicit owner state and capability events | Hotplug, permission loss and callback facts update runtime state through defined transitions, never by rereading terminal context. |

Comptime is appropriate for bounded specialization with a declared resulting
capability. It cannot establish that a runtime driver, permission, endpoint or SDK
exists. Dynamic adaptation chooses within observed capabilities and the product's
policy; it cannot silently substitute a null backend or reduced fidelity merely
to make an operation appear successful.

If a future schema is adopted, retain schema version, resolved values/provenance,
profile identity and resource bounds. A documentation example is not authority
to add a language dependency. Existing Markdown and JSON custody/receipt formats
continue to have their documented roles until an actual migration completes.

## Capability facts need a scope and a lifetime

Represent build availability, tested native behavior and live device availability
as separate facts. A useful host-facing capability record includes the feature,
source/build identity, target/profile, evidence identity, observation time or
generation, and result/reason. `available`, `unavailable`, `unqualified` and
`unknown` are different meanings. The existing binding does not yet export such
a product capability service; an application may assemble one from real facts.

For example, the raw resampler symbols exist, but [Q04 control constraints](../contracts/conversion-control.md)
block an inference that they implement fine drift correction safely. Windows build
success does not supply Intel Mac qualification. A prior device observation can
expire at hotplug or permission changes. Revalidate at acquisition and handle
later loss under the lifecycle contract; a timestamp is not a guarantee of freshness.

No callback-owned plain counter becomes a safe live UI observation merely because
an ecosystem dashboard wants it. The application must publish snapshots with its
own synchronization and final fences. Keep error facts and user-friendly explanation
separate so all frontends can derive the same truthful state.

## Quartz and Docz adoption for this handbook

The intended final authored paths are `README.dcz` and `docs/*.dcz` according to
the owning Docz/Quartz profile. Current authority is Markdown. A rename alone
does not translate mathematics, code, explicit anchors or local evidence links.
Prepare migration with the actual producer/reader and keep one authoritative
representation per document; a portable Markdown export can be a generated view.

Before switching authority, record each document's stable identity, old/new path,
old/new content digest, old/new anchor mapping, producer/reader/profile revision,
export role and intentional semantic changes. Test these specific package features:

- Fenced C/Zig/Python snippets and exact source anchors, including multiline snippets.
- Equations, inequality signs, tables of units, and literals such as `rho_req`.
- Links among the handbook, vendor source and source-bound verification observations.
- Broken-link/duplicate-anchor detection and exhaustive file-to-contract coverage.
- Readable output without an online account; retention of source and migration tools.

The existing checker supports a deliberately limited Markdown style. Its success
cannot verify `.dcz`. Migrate its responsibilities to a qualified reader/checker
and update the catalogue schema/navigation in one reviewed change. Preserve
historical verification bytes and their original format. A projection may link to
them; it must not rewrite history to create apparent new evidence.

## First implementation boundary

The concrete next work is a read-only qualification/export adapter with a real
caller, followed by isolated candidate preparation and failure tests. Publication
comes only after a host-side transaction protocol is implemented and qualified.
No production MetaOS, updatez, ZSON, Docz, Quartz or Hydra adapter is implemented
by this chapter. The [acceptance plan](../verification/ecosystem.md) specifies
what each future boundary must demonstrate.
