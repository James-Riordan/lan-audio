# Implementing from the exact work graph

The [machine-readable plan](implementation-plan.json) contains 37 work packages and 89 observable acceptance obligations. Both projects contain an identical snapshot. Work-package IDs such as T03 identify one file, while T1 identifies a whole capability milestone. Edges are prerequisites for completing a package, not import dependencies or a ban on writing tests early.

Run `python tools/check-plan.py --self-test --peer <other-project-directory>` from either source tree. The gate checks unique IDs/paths, canonical safe paths, nonempty acceptance inputs/results/oracles, known dependencies, acyclicity, planned source absence, exact local card coverage/content, and matching peer snapshots. Its nine in-memory negative controls must fail validation. It returns a deterministic topological order; it does not decide that an implementation is complete.

## Current dependency-ready work

Q09 STREAM frame syntax, Q12 host datagram contract and Q14 deterministic network simulator have no new-file prerequisite. They can be developed against current source contracts without exposing an endpoint. T00 exact backend verification is implemented with unconditional acquisition checks. T01 and T07 become dependency-ready when its completion receipt passes. The new native callback probe is preliminary T1 evidence, not completion of T00 or T1.

T01 contract precedes T03 event storage and T05 C ABI; those precede T04 callback adapter, T02 public owner and T06 conformance. Q00 then consumes this qualified boundary; Q01 closes the real handshake journey. Packet protection/recovery and streams converge into Q06 connection state before receive/send coordination and endpoint work. T13 provider/platform qualification also gates Q19 final QUIC interop.

## Closing one work package

Use the [schema-2 lifecycle and evidence protocol](completion-protocol.md). Design cards remain at stable paths while source-bound contracts describe implemented bytes. Prerequisite edges remain intact through completion; receipts bind each dependency's evidence. The checker accepts planned, in_progress, implemented and complete states with corresponding source/evidence rules. T00 now has implementation and source-bound evidence; consult the current plan for lifecycle state.

Read the [takeover guide](takeover.md), [decision register](decision-register.md), [connection transactions](../contracts/connection-transactions.md) and [resource budget contract](../contracts/resource-budgets.md) before implementing their owning packages.

## Release gate beyond a topological order

All package acceptance cases, milestone exit gates, current API regressions, SDK provenance, supported native target evidence, interop, resource envelope, fuzz results and deployment-specific review must agree. These are mandatory evidence categories; the graph does not encode every existing file edit, reviewer decision or platform job as a fake new source file. A green plan checker proves document consistency only.
