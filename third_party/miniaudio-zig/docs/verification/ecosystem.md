# Ecosystem boundary acceptance and future file contracts

Status: preparation only. No production updater, configuration-language adapter,
transaction journal or Docz migration is implemented. The
[architecture](../architecture/ecosystem-boundary.md),
[adoption transaction](../implementation/adoption-transaction.md) and
[qualification records](../contracts/qualification-records.md) define this slice.
The application retains its lifecycle/network/device implementation sequence.

## First vertical boundary: read-only inspection

Begin in the owning updater/tooling project with an adapter that accepts an
explicit resolved dependency location/revision, invokes current tools, and returns
truthful observations. Its test must snapshot the inspected tree before/after;
no check may modify adopted bytes or repair a mismatched manifest. Invoke tools
with structured arguments, bounded outputs and explicit working directories.

Existing interfaces to reuse are `tools/check_vendor.py`, `tools/check_docs.py`
and `tools/test_abi.py`. The first two are read-only; the third writes a new evidence
directory and build caches. Do not classify all three as side-effect-free. A null
backend native test is a different scope from physical device execution.

Required inspection cases: valid adoption, missing source, hash mismatch, escaped
or linked path under the chosen policy, invalid metadata, unavailable compiler,
wrong exact qualification compiler, inaccessible output, timeout, truncated log,
unsupported native host and fresh/cached negative-test witness. None may silently
become a pass or trigger a source download in the integrity checker.

## File responsibilities for the future host adapter

Names below are roles, not fabricated repository paths. Agree concrete paths with
the MetaOS/updatez owner; this dependency must not create a parallel updater. Keep
each role small and combine files if the owning project's conventions justify it.

| Role | Inputs / output | Ownership, failure and independent evidence |
| --- | --- | --- |
| Dependency inspector | Resolved root + expected package identity -> bounded source/build/capability facts | Read-only; reject ambiguous identity and unsupported metadata; golden facts from a hand-built small fixture. |
| Check invoker | Immutable check plan + subject + tool profile -> raw execution record | Own child processes/evidence, explicit timeout/cancellation and descendant cleanup policy; scripted executables exercise launch/crash/truncation paths. |
| Report adapter | Versioned raw producer record -> typed qualification record | Pure mapping; preserve unknowns and native failures; independent valid/malformed/negative-witness fixtures. |
| Baseline comparator | Two typed records + comparison profile -> multiset classifications or incomparable | Pure; coverage and environment checks precede absence claims; exact hand-worked examples and mismatched-profile tests. |
| Candidate preparer | Expected base + source request -> isolated verified candidate | Does not mutate adopted tree; provenance/closure bounded; interrupted retrieval and conflicting input fixtures. |
| Publisher/recovery owner | Ready candidate + expected base + host authority -> durable outcome or unknown/conflict | Exclusive mutation and reader protocol; platform-specific fault injection at every boundary; never implement a sequence of unchecked copies and call it atomic. |
| Document migrator | Qualified Docz/Quartz producer/reader + catalogue -> candidate source/projection mapping | Preserve canonical authority, mathematical/code semantics, anchors/evidence links; round-trip or explicit semantic-loss review with real tools. |

A first implementation can provide only inspection/reporting and explicitly return
unsupported for publication/migration. That is a useful complete capability; it
must not advertise the unfinished roles as implemented commands.

## Transaction fault schedule

The fake model separates candidate identity, expected base and current adoption.
For every transition, inject failure before/after its side effect and before/after
the caller receives acknowledgement. Test source/profile/manifest as a closure.

| Scenario | Required result |
| --- | --- |
| Retrieval interruption / wrong candidate digest | Adopted bytes unchanged; partial candidate cannot qualify. |
| Qualification assertion failure / missing hardware | Retained failed/unavailable records; affected promotion gate stays open. |
| Tool or policy changes mid-attempt | Frozen plan used or explicit attempt invalidation; no silent replacement of expected output. |
| Another writer adopts or edits after observation | Expected-base conflict; preserve other writer's work. Recheck under publication ownership. |
| Same request + same payload | Return/resume the same logical attempt under its durable-state rules; no duplicate mutation. |
| Same request + conflicting payload | Typed conflict; no replacement of the old request mapping. |
| Same completed request after later adoption | Historical/superseded result; never roll current source backward. |
| Lost commit acknowledgement | Reconcile authoritative journal/current closure; do not infer failure and republish blindly. |
| Crash during multi-file replacement | Host protocol either excludes readers and recovers, or readers use immutable selected revisions. No mixed closure is admitted to builds. |
| Rollback after unrelated edits | Conflict requiring re-evaluation; old backup cannot overwrite new authored work. |
| Running application during source candidate preparation | Its linked/runtime closure stays owned; no capture/start/reset side effects. Deployment switch follows the application lifecycle. |

The abstract model can show that a compare-and-switch rule rejects a second
writer. It cannot prove the real OS atomically implements that rule. Test actual
publication, flush/durability, process restart, locks/handles, disk-full and relevant
filesystem behavior on supported hosts before claiming crash-safe operation.

## Report comparison acceptance

Use a hand-built baseline with duplicate findings and a candidate with partial
overlap. Assert multiset conservation for every key. Add source-only change under
an approved comparison profile: hashes differ, but classification can be valid.
Then change the compiler, rule normalization or coverage without an approved
mapping and require incomparable. Preserve both records and reasons.

Test that a candidate compile failure cannot resolve baseline runtime failures;
skipped/unsupported/incomplete tests cannot supply absence evidence. A newly added
check finding a baseline issue is newly observed, with introduction date unknown.
Persistent severity still follows current policy. Test deliberately changed
location lines without conflating independent occurrences or losing the original
diagnostic location.

Known-defect tests require their exact runtime witness. For the adopted converter,
the successful reproducer demonstrates the problem; it does not authorize fine
clock correction. A future fixed candidate should fail the old defect expectation
and pass a reviewed correct-behavior regression, with both meanings explicit.

## Configuration and capability acceptance

Validate typed input before side effects. Changing terminal context while a check
runs must not change its subject, candidate destination, target or policy. The same
resolved typed request with and without a future ZSON/MetaOS adapter should produce
equivalent semantics under the same capabilities; no requirement for identical
timestamps, addresses or debug paths follows.

Exercise compiled-out backend, native API absent, permission denial, missing device,
hotplug after validation and stale evidence. Unknown/unqualified is not available;
a null fallback cannot masquerade as physical audio. No language parser, registry
lookup or telemetry wait is allowed in a callback. Future process-level tests
observe these boundaries in the real product; source prose alone cannot prove them.

## Docz/Quartz migration acceptance

Use the actual owner-supplied grammar, producer and reader. Fixtures must contain
the two frame-domain identities, rate/phase inequalities, C/Zig/Python snippets,
tables, Unicode labels, explicit anchors, relative source links and immutable
evidence references from this handbook. Compare their semantic content and verify
navigation in both the canonical reader and a portable export.

Test collisions, duplicate/removed anchors, renamed documents, unsupported schema,
missing export tool and interrupted migration. Preserve old canonical bytes until
the whole migration is accepted; never leave two independently editable authorities.
Historical reports keep their hashes and original formats. A new projection is
identified as a projection, not a fresh run of the historical checks.

## Present evidence and completion gates

The staged preparation bundle includes a small Python specification exercise for
multiset comparison, controlled source variation, missing coverage, expected-base
conflict, repeated/conflicting/superseded requests and frozen context. It uses
ordinary immutable values and fake in-memory state. It does not implement filesystem
durability, native scheduling, authorization, a schema parser or an ecosystem API.

Deliver a new source-bound receipt for each actual implementation gate: inspection,
record mapping/comparison, isolated candidate work, publication/recovery and document
migration. A gate closes only for its named environments and scope. The user's
broader ecosystem vision supplies requirements; it does not supply missing SDKs,
external APIs, signing identities or physical device evidence.
