# Planned `build/backend.zig`

Status: **not implemented**. Milestone T2. Exact completion prerequisites are below. This is a design card, not a source stub or an exported capability.

## Responsibility and boundary

Platform-specific backend discovery, linkage and runtime staging.

## Invariants, data ownership and errors

Fail explicitly on unsupported target/backend combinations; pin dependency/toolchain provenance and avoid system DLL substitution.

Define input/output ownership, capacity units and failure atomicity in the first implementation. Refuse unsupported capability before accepting application work. Make terminal cleanup idempotent without treating protocol sends or application requests as generally retryable.

## Construction sequence

1. Read the existing relevant file contracts and [integration contract](../../../contracts/quic-tls.md). Resolve public types and caller/provider responsibilities.
2. Author independent positive and negative oracles for the acceptance cases below. Add a minimal compiling implementation behind explicit capability selection.
3. Connect the owning build and external consumer. Keep this design card, update its lifecycle status, and add a separate source-bound contract when the file exists.
4. Run both supported native build modes and the relevant model/interop/fuzz profile; record actual outcome and remaining limits.

## Acceptance cases

Windows native; Linux/macOS native qualification; external SDK path with spaces; wrong architecture and missing library.

Completion requires all cases to have observable assertions, a bounded failure path and source-bound evidence. A successful happy-path demo alone does not close this card.

## Exact work package T07

Authority: [implementation plan](../../implementation-plan.json). Milestone labels group work; the following edges govern completion order. Tests can be authored earlier.

- `T00` — `tls-zig/tools/verify-backend.py` must satisfy its acceptance evidence.

### Observable acceptance obligations

**T07-01**

- Stimulus: Build Windows and proposed POSIX targets with missing SDK, wrong architecture and path containing spaces.
- Expected: Qualified native target builds; unsupported or mismatched target fails with actionable reason.
- Independent check: Native link/run smoke per target; cross-compilation alone is insufficient.

**T07-02**

- Stimulus: Place an incompatible same-name library on search path while specifying locked SDK.
- Expected: Resolver/staging chooses verified artifact or fails; recorded runtime provenance matches intended SDK.
- Independent check: Capture loaded module identity and compare file digests; test outside development directory.

These obligations refine the earlier acceptance list; they do not replace it. Capture command, exit status, source/backend identity, actual observed assertions and unresolved cases. No test above is represented as already implemented.

## Lifecycle and evidence

Follow the [completion protocol](../../completion-protocol.md). Preserve this design card and its acceptance obligations. Add current source documentation separately; completion requires matching source/log/obligation hashes and completed prerequisite evidence.

## Ecosystem boundary acceptance

**T07-03**

- Stimulus: Build lean and optional-adapter profiles; change a runtime-only setting and enable a disabled-dependency tripwire.
- Expected: Lean graph does not configure/import the optional backend; runtime-only changes do not silently alter compiled feature identity.
- Independent check: Independent graph tripwire, clean consumer and artifact/build-plan hashes with recorded producer version.

This is an additional proposed obligation, not executed integration evidence. See [ecosystem boundary](../../../ecosystem/overview.md).
