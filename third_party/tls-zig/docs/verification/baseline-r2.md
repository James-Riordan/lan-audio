# Current handoff — revision 2, 2026-09-26

This is the reviewed revision-2 source/documentation snapshot, applied to `C:/Projects/tls-zig` after the separate application snapshot hold was released. All baseline paths were checked for intervening edits before application. Existing application dependency pins were not changed; consumers must review the exact revision-2 change manifest before adoption.

50 existing first-party/fixture/metadata/tool files have source-bound contracts. 15 planned files have expanded design cards. The shared plan contains 37 exact work packages and 74 observable acceptance obligations. TLS retains 166 individual upstream SDK provenance records; SDK binaries are omitted from source-only delivery.

## New evidence and limits

The [native SDK probe](quic-provider-probe.md) passed full, partial-output and fatal-send callback cases. It proves initial external QUIC TLS callback capability in the locked Windows build, not an authenticated handshake. The [new finite custody model](../formal/event-custody.md) checks bounded event ownership and detects three injected defects. The [exact work graph](../roadmap/work-graph.md) replaces coarse file prerequisites.

See [revision-2 checks](r2-check-results.json) and [exact revision-2 changes](r2-change-audit.json). New documentation/source coverage and graph gates are tested normally and with Python -O. The original three models remain required.

## Preserved implementation evidence

Existing Zig/C protocol source, builds, fixtures, root documentation and dependency pins are byte-identical to the pre-r2 snapshot. No transport/TLS algorithm or public API changes were made in revision 2. New C code is confined to a test-only probe.

The [prior native qualification](baseline-v1.md) and [original command receipts](run-results.json) remain historical evidence for the unchanged implementation. Native protocol suites were not rerun just to relabel old results as new. QUIC still lacks real TLS integration, 1-RTT transport, streams and an endpoint; TLS still exposes its records Engine/Driver, not the planned recordless owner.

## Reproduce maintenance checks

```text
python tools/check-docs.py --self-test
python -O tools/check-docs.py --self-test
python tools/check-plan.py --self-test --peer <other-project>
python -O tools/check-plan.py --self-test --peer <other-project>
python tools/check-event-model.py
python -O tools/check-event-model.py
python tools/check-models.py
```

The graph checker requires both source-only trees for peer validation. TLS documentation SDK mode additionally requires the locked SDK at deps/openssl-install. The probe supports an external exact SDK location without repinning.
