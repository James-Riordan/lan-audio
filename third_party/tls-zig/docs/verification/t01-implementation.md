# T01/T03 recordless core implementation — 2026-09-26

## Implemented behavior

`tls-zig/src/quic/contract.zig` validates explicit host-selected configuration before allocation/input: required capabilities, QUIC v1/TLS 1.3/AES-128-GCM, trust/identity policy, opaque ALPN, capacities and clock arithmetic. Whole-field overrides require caller authority; unknown and duplicate fields fail. Typed levels, directions, byte counts, wall/monotonic time, owner generations and event sequences prevent accidental mixing. Plan verification detects drift in borrowed options and binds a canonical schema/versioned fingerprint. This is not authorization or loaded-provider attestation.

`tls-zig/src/quic/events.zig` owns stable copied event payloads in bounded storage. Data backpressure preserves a precise accepted prefix and reserves control slots. A consumer must successfully perform its action before the exact borrowed head can be acknowledged. Stale, foreign, out-of-order, early and duplicate actions are rejected. Callback reentry is rejected. Cancel and deinit clear secrets; volatile zeroing is observed at the allocator handoff. Generation and sequence counters stop before reuse.

The new `tls_quic` build module has no native provider dependency. Existing records APIs/exports and dependency pins remain unchanged. The separate example uses a clearly labeled synthetic provider fixture plus the real queue; it does not perform a TLS handshake.

## Verification scope

The `quic-test` step runs 15 distinct tests, including 32768 five-action custody traces, construction failure at every allocation ordinal, actual pre-free payload clearing, callback reentry, counter exhaustion, canonical hash oracle, policy rejection and borrowed-plan drift. Both Debug and ReleaseSafe are required. Four negative type programs must fail for their intended semantic mismatch and one positive program must compile. The compiler tool is tested normally and under Python -O.

The independent source-only consumer is also copied outside the repository into paths containing spaces, with only the package allowlist and no SDK directory. Native build/run and compile-only target outcomes are retained separately. Cross compilation cannot establish OS runtime, ABI/native provider behavior or production support. The fixture allocator is synchronous and serialized; no race-safety claim is made for Queue.

Existing record TLS tests, independent peer interop, example and external TCP consumers are rechecked for the changed owning build. T00 acceptance is rerun against the unchanged SDK and tooling before updating its current completion receipt; the old receipt stays in completions/history.

## Iteration findings retained

Initial compile fixes followed the pinned Zig compiler: array repetition uses @splat, new package examples require a generated fingerprint, and local names cannot shadow declarations. A new allocator test initially failed because Allocator.free writes undefined before rawFree in Debug. Payload release now directly calls rawFree after volatile zeroing; the allocator observes zeroes, and double deinit frees neither allocation twice. These fixes are covered by the final tests, not counted as passing initial runs.

## Remaining production gates

T05 native C ABI and T04 callback adapter are next; T02 Engine and T06 authenticated provider conformance follow. The existing 17 native callback scenarios remain diagnostic evidence. Preserve release-failure custody through SSL destruction, distinguish local byte-budget exhaustion from network input shortage, and gate readiness on identity/ALPN, accepted parameters and installed keys. Then Q00/Q01 integrate QUIC packet/CRYPTO custody.

T07/T09/T13 require actual native platform/runtime/ABI qualification; pure-module target builds do not complete them. Resource envelope, independent QUIC interoperability, endpoint/stream/transport integration, fuzzing, deployment trust policy and distribution authorization remain in the unchanged 37-package/89-obligation plan. There is no claim of universal production readiness.

## Sealed qualification results

T00, T01 and T03 are complete within their package scope: 3 of 37 work packages, with all 89 acceptance obligations preserved. The remaining 34 packages are planned. This does not establish a production QUIC stack.

| Evidence | Outcome and scope |
| --- | --- |
| Pure core, native Windows x86_64 | 15 distinct tests in Debug and ReleaseSafe. Debug build ran 13 external tests and reused a cached internal result; a direct Debug command reran both internal tests. |
| Separate pure-module consumer | Build and execution pass in Debug and ReleaseSafe. Synthetic provider fixture only. |
| Type misuse controls | Positive program compiles; four negative programs fail for their intended semantic type mismatch, normal Python and -O. |
| Relocated consumer | Native build and execution pass from paths with spaces, using the package source allowlist with no SDK directory. Supplemental source snapshot; not a release archive. |
| Pure-consumer cross compilation | x86-windows-gnu, aarch64-windows-gnu, x86_64-linux-musl, aarch64-linux-musl, x86_64-macos, aarch64-macos and x86_64-freebsd all compile in ReleaseSafe. No native execution on these targets. |
| Existing record TLS and host driver | 11 + 19 native tests pass in Debug and ReleaseSafe. |
| Existing consumers and interop | Public example, separate existing consumer, 17 independent peer cases and 14 TCP cases pass. |
| Backend integrity | 16 offline groups pass normally and on isolated -O retry; exact 166-file SDK verification passes in both modes. Initial -O invocation timed out at 240 seconds and remains recorded as failed. No assertion failure was observed before timeout; its cause is not established. |
| Models | TLS safety, event custody and lifecycle models pass normally and under -O. Final documentation and shared-plan gates are recorded separately. |

Canonical receipts live in the TLS peer under `docs/verification/completions/T00.json`, `T01.json` and `T03.json`. The prior T00 receipt is retained under `completions/history/`. Run manifests retain exact commands, log hashes and the original timeout. Native and compile-only results are deliberately scoped separately.

## Consumer review of the build change

The build adds `dep.module("tls_quic")` and `zig build quic-test`. Existing `tls`/`runtime` module names, record APIs, C backend sources, SDK archives and package pins are unchanged. A consumer's exact build-file pin will correctly detect this change; adoption requires reviewing the current receipt and its TLS regression evidence. No downstream dependency lock was updated, and no runtime QUIC adoption is implied.

Previous TLS build.zig SHA-256: `62d431a423ff9017333a57fb1611d943b639ed6839a9f1364dbcbb0513d49d20`.
Current TLS build.zig SHA-256: `b61f99699d71fbc481c52fa81fd2a39a8e59520f8cb330717807713b5c4ee638`.

T05 is the next dependency-ready recordless step, then T04/T02/T06. Its C/Zig ABI validation requires actual linked symbols and native LLP64/LP64 observations or explicit target unavailability; a header-only stub or cross-build cannot satisfy those obligations. T07, Q09, Q12 and Q14 are independently ready. Other-OS native execution and provider qualification remain unavailable in this Windows-only evidence set.
