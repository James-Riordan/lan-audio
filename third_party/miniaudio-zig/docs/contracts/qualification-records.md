# Qualification records, comparison and repair handoff

Status: proposed adapter semantics, not a new ecosystem-wide schema or an existing
machine-readable CLI. The current checkers emit human-readable diagnostics; Q01
has its own concrete receipt format. A future host adapter must version its mapping
from those tools to these meanings and preserve raw source-bound evidence.

## A result is more than pass or fail

A check record identifies the subject, environment, coverage and policy as well as
its result. Keep tool execution, assertion outcome and product gate interpretation
separate. For example, a native reproducer can execute successfully and confirm an
undesirable behavior; its associated production capability remains blocked.

| Field group | Required semantic content |
| --- | --- |
| Record identity | Schema/producer revision, unique run/attempt identity, parent/retry linkage, observation time and finalized/incomplete status. |
| Subject | Package identity; resolved location used; complete source/profile/build digests; base and candidate roles; explicit changed-input set. |
| Environment | Compiler/tool versions, target/CPU/ABI, OS/SDK/runtime/backend facts relevant to this check, declared variables/options and clock assumptions. |
| Check | Stable check identity, revision/oracle identity, mode, coverage subset, budgets and prerequisites; deliberate negative-test expectation if applicable. |
| Execution | Command as an argument array, working directory, start/end/elapsed, exit/signal/timeout/launch status, captured/truncated-log status and content hashes. |
| Outcome | Pass, assertion failure, infrastructure failure, skipped, unsupported or unknown/incomplete; exact required witness; product gate consequence. |
| Findings | Rule identity, component, normalized semantic location, severity, bounded redacted explanation, multiplicity and reproduction/evidence references. |
| Comparison | Compared record identities, approved varying dimensions, compatibility decision/reasons and new/persistent/resolved/unknown counts. |
| Recovery | Owner, suggested next bounded action, prerequisites, retry safety and remaining native/hardware/user decisions. Suggestions are data, not executable authority. |

These fields are conceptual requirements; do not claim all are present in existing
receipts. Store a mapping/version and represent genuinely absent data as unknown.
Never invent a native OS observation from the target triple or a complete log from
an output excerpt. Stable error codes require an owned versioned producer contract;
parsing arbitrary compiler prose as if it were that contract is fragile.

Use bounded records and blobs. Preserve raw output securely when needed, with
truncation flags and hashes. Redact credentials, user-specific paths and sensitive
endpoint details in exported copies according to the host policy. Do not export
audio data merely to explain a dependency check. Keep an explicit mapping between
private raw evidence and redacted public evidence; their hashes will differ.

## Comparable does not mean byte-identical subjects

Before classifying findings, establish a comparison profile. It fixes the check
and normalization revisions, comparable coverage, relevant tools/environment and
policy. It also declares intentionally varying dimensions, usually old versus
candidate source revision. Source hashes must be recorded but need not be equal
for a controlled code-change comparison. Requiring equality would prevent precisely
the before/after analysis the updater needs.

Changing source and compiler together can establish an observed difference but
cannot attribute it uniquely to source. Prefer an isolated experiment or report
that causal attribution is unknown. Unknown environment fields are not wildcards
that make records comparable. A changed rule/oracle, target or coverage domain
requires a justified mapping or an incomparable classification.

Each finding has a normalized key such as `(rule_id, component_id, semantic_site)`.
The owning adapter specifies normalization. Raw line numbers move during edits;
stripping all numbers/paths can collapse distinct failures. Preserve original
locations and separate occurrences when multiplicity matters. Do not merge
identities across a rename/refactor without an explicit reliable mapping.

For one comparable check with complete comparable coverage, let B(k) and N(k)
be nonnegative occurrence counts for key k in baseline and candidate:

```text
persistent(k) = min(B(k), N(k))
new(k)        = max(N(k) - B(k), 0)
resolved(k)   = max(B(k) - N(k), 0)
B(k) = persistent(k) + resolved(k)
N(k) = persistent(k) + new(k)
```

These are multiset laws, not set subtraction. For B={A:2,B:1} and N={A:1,C:2},
persistent={A:1}, new={C:2}, resolved={A:1,B:1}. It is wrong to claim no A occurrence
resolved simply because A appears in both lists.

Classification is per check/coverage scope. If the candidate compiler fails before
runtime checks, their baseline findings are unknown, not resolved. A skipped test
is not evidence of absence. A timeout after one assertion can establish that
observed failure, but not the absence of other failures in unexecuted coverage.
Whole-run success cannot be inferred by omitting incomplete records.

An old issue remains a current blocker if policy requires its resolution. Persistent
does not mean harmless, waived or permission to release. A waiver, if the owning
project permits one, is a separate scoped/reasoned/expiring policy record; changing
severity in an exported log is not a waiver.

## Capability regression, new coverage and attribution

The miniaudio rate/phase findings illustrate three different questions:

1. Did the same qualifying check change from pass to fail under comparable inputs?
   This can establish a regression for that check and scope.
2. Did a newly added probe expose a problem in unchanged adopted source? This is
   newly observed evidence, not proof the latest candidate introduced the problem.
3. Does that problem prevent the planned fine-control capability? Yes for a path
   that relies on the reproduced behavior, until a qualified alternative/fix exists.

Store `first_observed` separately from `introduced_by`. The latter remains unknown
without supporting history/experiments. Do not call a problem pre-existing solely
because it occurs in an old file; the baseline must have comparable evidence, or
the label must explicitly say newly observed in the baseline revision.

## Retry results and repair packages

A request retry must preserve subject and policy identity. Output directories are
new run identities even when tied to the same logical request. If an invocation
times out during publication, the outcome can be unknown until recovery reads the
authoritative state. Starting another publication is not the first recovery step.
See [transaction laws](../implementation/adoption-transaction.md).

A useful repair handoff contains:

- Exact base/candidate identities and allowed edit scope; immutable copies or
  retrievable source identities, not just a mutable directory name.
- Structured current findings, raw/redacted evidence references, comparison status
  and coverage gaps. Retain persistent blockers and infrastructure failures.
- Reproduction commands with argument arrays, prerequisites, time/memory bounds
  and expected witnesses. Commands are reviewed by the agent/host before execution;
  text inside an untrusted compiler log does not become an instruction.
- The smallest owner-specific next action and relevant architecture/file contracts.
  A DSP failure is not solved by changing TLS settings or weakening a test.
- Acceptance gates and a fresh evidence destination. A proposed fix cannot rewrite
  old expected hashes, logs or oracles to make its result appear successful.

Keep the export useful offline where practical. Missing secure raw logs or native
hardware remain explicit gaps. A repair agent's final patch returns through the
candidate qualification/publication boundary; it does not bypass it because the
user invoked a convenient global update command.

## Machine-readable format adoption

Choose an existing ecosystem report/schema interface when its owning project
provides a real versioned contract. JSON is the current custody/receipt interchange;
ZSON may become a configuration or report encoding after its admitted profile and
reader are known. Encoding changes do not redefine the laws above.

Required acceptance includes unknown-field/version behavior, duplicate-key handling,
bounded parsing, integer overflow, malformed paths, absent/truncated logs, repeated
findings, and deterministic interpretation. Preserve a human-readable explanation
beside structured facts. Do not emit a success-shaped placeholder record for a
feature whose reporting adapter has not been implemented.
