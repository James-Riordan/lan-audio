# Current handoff — revision 5

The [recordless provider experiment](quic-provider-pair.md) completed 17 scenarios at both O0 and O2 against the exact locked Windows SDK. It proves the scoped native callback path described in its receipts; it does not implement QUIC packet transport or the production recordless API.

The new [lease/scheduling contract](../contracts/provider-leases.md) resolves a concrete failure-cleanup hazard and distinguishes local work exhaustion from network input shortage. Four new acceptance cases bring the shared plan to 89 obligations across 37 still-planned packages. There are 127 source-bound contracts across both projects: QUIC 74, TLS 53. Only two diagnostic tools are new; all pre-existing source/build/fixture/tool/lock bytes remain unchanged from revision 4.

[Checks](r5-check-results.json), [exact changes](r5-change-audit.json) and the [prior status](baseline-r4.md) preserve the evidence chain. The peer plan, documentation coverage, model and lifecycle checks are rerun for this increment. Existing native protocol suites were not rerun because their implementation is unchanged; those historical results keep their original attribution.

This revision is applied only after all live baseline paths pass an intervening-edit preflight. No application pins, third-party SDK bytes or ecosystem producer trees are changed. Production completion still requires implementation, independent interoperability, resource qualification and the deployment decisions in the [decision register](../roadmap/decision-register.md).
