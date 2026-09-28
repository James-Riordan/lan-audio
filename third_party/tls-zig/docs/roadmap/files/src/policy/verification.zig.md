# Planned `src/policy/verification.zig`

Status: **not implemented**. Milestone T3. Exact completion prerequisites are below. This is a design card, not a source stub or an exported capability.

## Responsibility and boundary

Explicit identity, trust and revocation policy profile.

## Invariants, data ownership and errors

Fail closed when required checks unavailable. Separate certificate authentication from application authorization.

Define input/output ownership, capacity units and failure atomicity in the first implementation. Refuse unsupported capability before accepting application work. Make terminal cleanup idempotent without treating protocol sends or application requests as generally retryable.

## Construction sequence

1. Read the existing relevant file contracts and [integration contract](../../../../contracts/quic-tls.md). Resolve public types and caller/provider responsibilities.
2. Author independent positive and negative oracles for the acceptance cases below. Add a minimal compiling implementation behind explicit capability selection.
3. Connect the owning build and external consumer. Keep this design card, update its lifecycle status, and add a separate source-bound contract when the file exists.
4. Run both supported native build modes and the relevant model/interop/fuzz profile; record actual outcome and remaining limits.

## Acceptance cases

Revoked/unknown status, timeout, stale revocation cache, hostname/IP cases and trust rotation.

Completion requires all cases to have observable assertions, a bounded failure path and source-bound evidence. A successful happy-path demo alone does not close this card.

## Exact work package T11

Authority: [implementation plan](../../../implementation-plan.json). Milestone labels group work; the following edges govern completion order. Tests can be authored earlier.

- `T10` — `tls-zig/src/policy/credentials.zig` must satisfy its acceptance evidence.

### Observable acceptance obligations

**T11-01**

- Stimulus: Require revocation status; supply revoked, unknown, expired-cache and unavailable service outcomes.
- Expected: Profile denies readiness unless its explicit policy accepts available evidence; no silent downgrade.
- Independent check: Fixed certificate/status fixtures and injected clock; inspect stable decision reason.

**T11-02**

- Stimulus: Validate DNS and IP identities across trust rotation and certificate time boundaries.
- Expected: Decision matches configured identity type and trust version; no application authorization claim is inferred.
- Independent check: Separate expected identities and fixed wall-clock instants; no network-dependent oracle.

These obligations refine the earlier acceptance list; they do not replace it. Capture command, exit status, source/backend identity, actual observed assertions and unresolved cases. No test above is represented as already implemented.

## Lifecycle and evidence

Follow the [completion protocol](../../../completion-protocol.md). Preserve this design card and its acceptance obligations. Add current source documentation separately; completion requires matching source/log/obligation hashes and completed prerequisite evidence.

## Ecosystem boundary acceptance

**T11-03**

- Stimulus: Resolve a logical service to a new address while retaining explicit expected identity; supply misleading context metadata.
- Expected: Routing/context does not authenticate the peer or bypass trust, hostname/IP, ALPN or application authorization policy.
- Independent check: Independent expected peer identity and negative certificate/policy fixtures, with metadata changes isolated.

This is an additional proposed obligation, not executed integration evidence. See [ecosystem boundary](../../../../ecosystem/overview.md).
