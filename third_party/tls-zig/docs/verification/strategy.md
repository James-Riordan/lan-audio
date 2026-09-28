# Verification and completion criteria

The dated current receipt records what actually ran. Historical README/checkpoint counts remain historical. Source hashes bind file contracts to reviewed bytes; passing a hash check demonstrates no drift, not correctness.

## Required layers

| Layer | Evidence | Detects | Cannot establish |
| --- | --- | --- | --- |
| Documentation integrity | check-docs.py with negative self-test | Missing contracts, changed files, broken local links, stale hashes | Semantic completeness or true prose |
| Bounded state models | check-models.py and counterexamples | Small-state custody/scheduler/closure invariant failures | Unbounded proof or implementation refinement |
| Native unit tests | Pinned Zig Debug and ReleaseSafe logs | Tested packet/Engine/Driver behavior | Untested platform or peer behavior |
| Independent wire vectors | RFC/.NET expected bytes | Shared encoder/decoder mistakes | Complete connection interoperability |
| TLS independent peer | Python SSL memory-BIO and TCP cases | Actual backend/consumer wire behavior | Provider-wide certification |
| Future QUIC peer matrix | Independently built peers, both roles | Connection/stream interoperability | All networks or all extensions |
| Fuzz/resource/performance | Corpus, seed, environment, distributions | Robustness and capacity envelope | Universal safety or performance |

## Change-specific gates

Every parser change tests all truncation boundaries, invalid value ranges, overflow, exact consumed prefix and failure-state preservation. Every state change tests duplicate events, valid/invalid phase, failure before/after commit, cancellation, timer ties and capacity boundaries. Every cryptographic change requires independent expected bytes and tamper rejection. Every provider upgrade verifies provenance, actual loaded runtime and all supported consumer journeys. Every packaging change builds a separate consumer from the packaged source closure.

## Evidence schema

Record date/UTC time, project/source manifest digest, command and working directory, tool versions, target, optimization mode, exit status, stdout/stderr log, test case count where reported, environment overrides, skips and remaining gaps. Separate upstream-reported tests from locally rerun evidence. A failed or interrupted run remains failed/interrupted even if a later retry succeeds. Keep sensitive values out of logs.

## Definition of done for a roadmap item

Its stable design card and separate current source contract agree with the checked lifecycle; no placeholder implementation advertises the feature; invariants have positive and negative tests; declared capabilities match the implementation; public examples and consumer build pass; docs/source inventory and package paths agree; remaining limitations are explicit. Release qualification additionally needs a chosen deployment threat model, supported platform matrix, resource envelope and independent security review appropriate to that deployment.

Python interoperability harnesses currently use assertions as test oracles. Run them without -O or PYTHONOPTIMIZE. T00 added an explicit startup refusal when assertions are disabled. Download/lock integrity now uses unconditional checks; tools/test-backend.py exercises them normally and under -O.


Revision 3 uses [source-bound lifecycle receipts](../roadmap/completion-protocol.md). Their structural checks supplement the native and reviewer obligations above; they do not replace them.
