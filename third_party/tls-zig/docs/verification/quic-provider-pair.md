# Authenticated recordless provider experiment — revision 5

## Question and result

Can the exact locked Windows OpenSSL SDK complete a certificate-authenticated TLS 1.3 exchange through the external QUIC callbacks, with real inbound leases, directional secrets and post-handshake processing? Yes, within the experiment below. Seventeen cases passed at C optimization O0 and O2: 34 observed case executions. This is a diagnostic executable under tools/, separate from the planned production adapter. No library API, packet algorithm, dependency or consumer pin changed.

[O0 receipt](provider-pair/O0.json) and [O2 receipt](provider-pair/O2.json) bind source, runner, fixture, executable, compiler, SDK lock and staged DLL hashes to command/exit/log evidence. Raw logs are under the corresponding O0/ and O2/ directories. The runner verified all 166 SDK files before compilation. Loaded-module paths were not independently queried; this does not close D12. These C modes are not Zig Debug/ReleaseSafe qualification of the future library.

## Stimulus and independent checks

Two TLS objects from the same provider exchange raw handshake bytes through fixed, append-only, per-level arrays. There are no sockets, QUIC packets, record BIOs, packet protection, CRYPTO offsets, retransmission, adversarial scheduling or independent peer implementation. A level change is driven by its own directional secret callback. Local transport parameters are distinct fixed byte strings and are compared at the opposite callback; semantic QUIC parameter validation remains untested.

Trust uses the existing explicit test CA, strict X.509 verification, the localhost SAN and a fixed fixture time of 2026-09-26 12:00 UTC. The server fixture chain must authenticate; mutual mode additionally requires a verified client certificate. The single ALPN is checked on both sides. Secrets for both Handshake and Application are compared client-write/server-read and client-read/server-write, without printing bytes. Traffic secrets alone never satisfy the success predicate. Secret arrays are cleansed after teardown; this is not a physical-memory erasure proof or full allocation audit. Certificates and private keys in the bundle are public test fixtures.

| Cases | Stimulus and checked outcome |
| --- | --- |
| full | both peers finish; identity, ALPN, opposite-direction secrets, parameters and all input retirement checks pass |
| fragmented | each receive lease exposes at most one byte; authenticated result and matching releases still pass |
| backpressure | each drive offers at most 17 outbound bytes; both roles observe WANT_WRITE and later finish |
| combined | one-byte receive fragments plus 17-byte output budget; no accepted-byte loss |
| mutual / missing-client | require and validate client certificate; absence fails server with certificate-required alert |
| wrong-host / wrong-ca / alpn | reject mismatched SAN, unrelated trust anchor and ALPN refusal at the expected role; verify specific policy/error results |
| fail-send / fail-receive / fail-release / fail-secret / fail-params / fail-alert | inject failure into each callback kind; require fatal provider result, actual injection and no harness invariant violation |
| tickets | issue one test-only session ticket; process Application-level bytes through zero-length read and observe one client session callback; no resumption attempt |
| budgeted | expose at most 17 inbound bytes per drive in one-byte leases; withholding returns empty availability and later drives resume to authenticated completion |

Client and server completion are reported separately. In missing-client mode the client can locally finish before the server rejects missing authentication. The harness stops on the local fatal result; it does not forward alerts or prove remote close delivery. Authentication labels in this report describe the test policy, not mutual identity in every mode.

## Findings that change implementation instructions

**Failed release is not successful retirement.** The first release-failure experiment retired its lease before returning failure. During SSL destruction another release arrived for that lease, correctly triggering the harness invariant. The final experiment retains the outstanding lease on failure, accepts the matching cleanup release, and verifies one failed attempt, two release invocations, one teardown release and one byte-range retirement. This is an observed property of the locked provider, not a portable promise that cleanup always has this exact callback count. A duplicate after successful retirement must still fail.

**Provider call count is not a work bound.** The O0 fragmented client required more than 2,000 callbacks inside one provider call. The receipts distinguish total callback count from control callbacks (secrets, parameters and alerts). These observed maxima are not capacity constants. The budgeted fixture instead pauses input after 17 bytes and resumes successfully; this does not bound certificate verification time, provider allocation or total CPU inside that call. Future wrappers need separate byte/event/work units, fair scheduling and terminal reserve handling.

**Fatal paths retain input until cleanup.** Wrong-host, wrong-CA, missing-client and failed-alert cases include teardown releases. Keep provider context, queues and all callback targets alive through SSL_free. Prohibiting new public entry must not disable callbacks needed for destruction.

**Post-handshake processing is separate from readiness.** The ticket case demonstrates the provider path only. The initial product profile still promises no resumption or 0-RTT. T06 must additionally test forbidden and malformed post-handshake messages, cancellation and bounded event capacity.

The provider API requires input storage to remain valid until release; its release length matches the offer. Write output follows the latest write level, and read input follows the latest read level. Callback failure is fatal. Post-handshake CRYPTO is processed through a read call. [Official OpenSSL callback reference](https://docs.openssl.org/3.5/man3/SSL_set_quic_tls_cbs/)

## Limits and remaining closure evidence

The successful experiment does not implement or close T01–T06 or Q00–Q01. Missing evidence includes the actual Zig/C boundary, model-to-code refinement, event acknowledgement/backpressure, full event/control queues, all failure positions in both roles, cancellation at every retained state, malformed peer input, independent interoperability, ABI/native-platform matrix, runtime-loaded artifact identity and resource enforcement. Fixed 64 KiB append-only arrays are test storage; they are not the production queue design or proof of a provider heap bound.

D04 and D05 stay experimental with narrower unknowns. Complete the four new plan obligations for failed release, input fairness, post-handshake custody and adapter wakeup semantics against the actual implementation. Do not mark packages complete by linking this standalone probe as if it exercised their missing source files.

## Reproduce

From tls-zig, supply the exact SDK and a fresh empty scratch directory for each run:

```text
python tools/probe-quic-pair.py --optimize O0 --work-dir <new-O0-scratch> --sdk-root <exact-locked-SDK>
python tools/probe-quic-pair.py --optimize O2 --work-dir <new-O2-scratch> --sdk-root <exact-locked-SDK>
```

Without --sdk-root, the runner uses deps/openssl-install. It never rewrites the lock or SDK. Unsupported platforms and changed SDK bytes fail explicitly. Each successful run produces 17 cases; nonzero command exits, malformed output and timeouts fail the runner. C assertions do not carry the checks, so optimization does not remove them. Python -O likewise retains runner checks.

## Exploratory failures retained

[First exploratory receipt](provider-pair/exploratory-1.json) records rejection of the wrong CA but a too-narrow test oracle: the provider built a chain including an untrusted self-signed root, producing verification error 19 and unknown-CA alert. The final oracle accepts only the three relevant untrusted-chain errors and requires the unknown-CA alert. [Second receipt](provider-pair/exploratory-2.json) records the pre-commit release bug above. Their failing-case logs are retained. These preliminary source versions are identified by recorded hashes but are not included as reproducible source snapshots; only the final source is delivered. Neither exploratory run is counted as qualification success.
