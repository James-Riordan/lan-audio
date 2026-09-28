# Source adoption as a recoverable transaction

Status: proposed Q02/Q05 host-tooling contract. The current package has read-only
integrity checks and an ABI matrix runner; it has no transactional updater,
publication journal or automatic repair implementation. The orchestration belongs
to the updater/application owner. These requirements make a future one-command
experience precise without creating a second updater in this library.

## Inputs frozen at preparation

Represent an attempt by `(request, expected_base, candidate, policy, environment)`.
Each term has a versioned encoding or typed value; a human title is not identity.
Candidate closure includes adopted header/license, any deliberate local patch,
manifest, profile, wrapper/build changes and package metadata affected by adoption.
Environment includes the exact compiler, targets, SDK/runtime facts and test profile.
Policy names the required checks and authority for this type of change.

The existing `UPSTREAM.json` is the adopted source record, not a mutable cache and
not sufficient provenance for a patched header. A local fix requires deliberate
representation of upstream base plus patch and resulting bytes, with review and
corresponding verifier/schema behavior. Merely inserting a new hash erases the
distinction and is not an adoption procedure.

Snapshot all authored/vendor inputs and relevant test/oracle/policy revisions.
An unrelated concurrent edit matters if it changes those inputs. Physical device
results additionally name the actual endpoint/OS/driver/settings. A green check
from another candidate or target cannot be transferred by changing a report label.

## State machine and persistent facts

| State | Entry fact / permitted next action | Failure or restart behavior |
| --- | --- | --- |
| Observed | Freeze expected base and explicit request; adopted source is untouched. | Missing/mismatched custody -> report and stop candidate promotion; do not rehash the manifest. |
| Prepared | Candidate bytes and provenance are complete in an isolated location. | Partial retrieval/extraction remains quarantined evidence; retry with verified identity, never as adopted input. |
| Qualified | Required candidate checks completed successfully with matching inputs; open target gaps explicitly excluded by policy. | Failed/incomplete/incomparable checks retain logs and block the affected qualification. |
| Ready | Review/authorization required by the host policy is satisfied; old/new change set and recovery bytes are sealed. | A changed expected base invalidates readiness; rebase/review a new attempt. |
| Publishing | Acquire exclusive mutation ownership, exclude relevant builds/readers, recheck expected base, publish through the host's qualified protocol. | Interrupted/ambiguous result enters Recovery; never report success from a missing journal record. |
| Adopted | Durable publication identity and whole-closure verification are recorded under that protocol. | Repeating the same request returns the sealed outcome if identity/content still match; it does not overwrite current work. |
| Recovery | Determine old/new/partial/unknown state from journal and actual bytes under exclusive ownership. | Resume/restore only the protocol-authorized state; unknown writes or provenance conflict require inspection. Preserve all evidence. |

An old source closure is rollback material, not permission to overwrite later
edits. Restore only if the expected current identity matches the state being
undone and policy authorizes that transition. Otherwise record a conflict.
An automatic repair agent receives a new isolated attempt, not unrestricted
ownership of the adopted source merely because a check failed.

The current filesystem tree has no atomic multi-file publication guarantee.
Writing source, profile and manifest in sequence can expose a mixed closure.
A Git commit, directory rename or lock file alone does not establish consistent
readers, power-loss durability or Windows handle behavior. A future host must
qualify its actual protocol: immutable revision staging plus an atomic revision
selection mechanism, or exclusive quiescence with journaled replacement/recovery.
All participating builders/readers must honor the selection/lock convention.
Arbitrary external readers cannot be covered by a convention they do not use.

Until that protocol exists, adoption remains a controlled reviewed change with
builds/consumers stopped as needed; it is not a claimed crash-safe transaction.
This chapter specifies the desired implementation and its proof obligations.

## Laws a future implementation must preserve

1. **Isolation before publish.** Preparation and qualification mutate only the
   candidate and new evidence locations. `adopted_after = adopted_before` through
   all failed pre-publication attempts.
2. **Compare expected revision.** Publish succeeds only if current adoption is
   still the captured expected base. The compare and switch occur within the same
   mutation-ownership protocol; a separate early hash check is insufficient.
3. **Closure consistency.** An admitted build observes one complete reviewed
   source/profile/manifest set. No candidate header plus old profile or old hash.
4. **Retry identity.** Same request plus equivalent payload/policy/authority refers
   to the same attempt; conflicting reuse fails. Fresh authorization is checked
   as the host requires. A token is not an authority grant or content signature.
5. **Monotone evidence.** A failed or partial check is never overwritten as if it
   passed. Re-execution produces a new run linked to the prior attempt. Historical
   source-bound results remain immutable.
6. **Truthful completion.** Success is emitted only after the qualified commit and
   verification boundary. An interrupted caller can receive unknown outcome and
   later query/reconcile; an acknowledgement timeout is not proof publication failed.
7. **No replayed audio effects.** Dependency retry never starts capture, replays
   media, reconnects a peer or resets a running converter. Deployment/restart has
   its own application lifecycle operation and authorization.

Algebraically, for a sealed success at revision C, reapplying an identical request
returns that receipt; it is observationally idempotent with respect to adopted
bytes. If the project has since moved to D, report `superseded` with C's historical
receipt and D's current identity, or another explicitly specified conflict result.
Never silently restore C. A lost in-memory request map after restart cannot support
durable exactly-once claims; persistent deduplication/recovery must be designed.

## Required check selection and invalidation

| Candidate change | Evidence invalidated or required |
| --- | --- |
| Header/profile/compiler/ABI-relevant build change | Relevant C/Zig ABI matrix, public consumer, source anchors and adopted API behavior; physical/native target qualification as required by actual behavior changes. |
| Resampler control fix | Preserve original R01 reproductions; correct-phase and effective-rate regressions plus DSP/custody/controller tests for the chosen path. Q01 success alone is insufficient. |
| Backend/runtime/SDK change | Actual platform acquisition/callback/teardown/capability tests and supported-target record. |
| Documentation-only change | Exact inventory/navigation/source anchors and semantic review of changed contracts; do not rerun hardware tests as if new runtime evidence were required without a reason. |
| Oracle/test/tool-policy change | Reassess comparability and baseline status; prior diagnostic absence may reflect absent coverage. Keep old and new policies explicit. |
| License/notice/package closure change | Review distribution closure/notices and clean consumer/package build; choose authored-code licensing through the responsible owner. |

No network response, parser error, compiler failure, missing host or timeout is a
successful negative-test witness. Each deliberate defect test names the required
failure and excludes infrastructure errors. The existing Q01 runner already applies
this distinction; reuse its actual interfaces before inventing another native runner.

## File-level preparation and integration plan

| Current file or future owner | Concrete work / boundary |
| --- | --- |
| `UPSTREAM.json` | Preserve current source identity. A future patched-source adoption first designs/reviews its provenance representation; do not silently repurpose `local_modifications`. |
| `src/profile.h`, `src/native.c`, `build.zig` | Keep C/translation macros and exactly one implementation consistent; any changed native profile is a whole candidate input. |
| `build.zig.zon` | Retain package identity and explicit source closure; a toolchain floor is not a floating update policy. |
| `tools/check_vendor.py` | Existing human-readable, read-only custody check. Use exit status and actual output as such; no structured-report or stable error-code API currently exists. |
| `tools/check_docs.py` | Existing read-only inventory/link/source/custody gate. Add future document formats only through their supported reader/schema, not extension-based bypass. |
| `tools/test_abi.py` | Existing native matrix and receipts. Preserve exact witness requirements and unique output directories; host orchestration consumes its declared schema/version or an explicit adapter. |
| Future updater adapter, owned by updatez/MetaOS | Resolve immutable project/candidate context, stage changes, select checks, normalize reports and implement the host publication/recovery protocol. Agree its actual repository/path with that owner; do not create an unowned local service. |
| Future adapter tests, alongside that adapter | Independent fault schedule, expected-base conflict, repeated/superseded request, source closure consistency, redacted reports and real platform durability tests. |
| New `verification/<adoption-attempt>/` | Keep the request, before/candidate identities, check records, failed runs, decisions and commit/recovery facts. Retention policy is explicit; a retry cannot erase evidence. |

The earliest useful host adapter is read-only: inspect the dependency, invoke
already available checks and report missing evidence. Isolated candidate comparison
comes next. Publication/recovery is a later capability with real OS/filesystem
tests. This order preserves a useful simple user command at each completed stage.
