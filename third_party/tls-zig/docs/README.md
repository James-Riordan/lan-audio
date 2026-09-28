# tls-zig engineering handoff

Read [current status and verified commands](verification/current.md) first. This handoff preserves the working source and defines a bounded implementation target; it does not certify production readiness.

1. [Architecture and ownership](architecture/principles.md)
2. [Directory policy and exact target tree](architecture/structure.md)
3. [Every existing file: catalog and contracts](reference/catalog.md)
4. [Milestones and every proposed implementation file](roadmap/README.md)
5. [QUIC–TLS contract and transaction ordering](contracts/quic-tls.md)
6. [Formal invariants and executable model limits](formal/invariants.md)
7. [Host usage and troubleshooting](guides/host-usage.md)
8. [Verification strategy](verification/strategy.md), [threat model](security/threat-model.md), [portability](architecture/portability.md)
9. [Primary references](reference/standards.md) and [compatible-growth decision](architecture/decisions/0001-compatible-growth.md)

## How to continue

Choose the first unfinished dependency-ready milestone. Read its file cards and existing API contracts. Implement one externally observable increment; add positive and negative tests, run the relevant commands, update capability/status and refresh reviewed file hashes. Do not count a design card, comment or type declaration as implementation. See the concrete [first work orders](roadmap/first-work-orders.md).

## Review evidence

[Component requirements and tests](verification/requirements.md), [exact changed paths](verification/change-audit.json), [execution receipt](verification/run-results.json).

## Revision 2 implementation detail

- [Exact work graph and completion procedure](roadmap/work-graph.md)
- [Selected recordless event and input-lease design](contracts/recordless-events.md)
- [Finite event custody model](formal/event-custody.md)
- [Locked SDK callback capability evidence](verification/quic-provider-probe.md)
- [Revision-2 changes](verification/r2-change-audit.json) and [check results](verification/r2-check-results.json)

## Revision 3: before implementation takeover

[Takeover guide](roadmap/takeover.md) · [Lifecycle and completion](roadmap/completion-protocol.md) · [Decisions](roadmap/decision-register.md) · [Connection transactions](contracts/connection-transactions.md) · [Resource budgets](contracts/resource-budgets.md).

## Ecosystem alignment — revision 4

[QUIC/TLS ecosystem boundary](ecosystem/overview.md) defines configuration, host adaptation, identity, maintenance, observability and future Docz migration. Eleven additional obligations refine existing packages; no new runtime dependency is adopted.

## Revision 5: provider experiment before implementation

Read the [authenticated callback experiment](verification/quic-provider-pair.md) before T02/T04/T06/Q00. It adds exact failure-cleanup and local-work scheduling obligations while all 37 production packages remain planned. The current shared plan contains 89 acceptance obligations.

## Implementation takeover — T00

[Current implementation status](verification/t00-implementation.md) records the first implemented backend-integrity milestone and fresh regressions. Historical preparation counts and diagnostics above retain their original scope.

## Recordless core implementation

[T01/T03 status and evidence](verification/t01-implementation.md): executable admission, semantic types, copied event custody, independent consumer and platform compile checks. Native recordless TLS remains a separate unfinished milestone.
