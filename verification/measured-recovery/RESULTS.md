# Measured recovery qualification

Windows interval timing now uses QueryPerformanceCounter with checked conversion.
The worker records receive/publication gaps without clock calls in audio callbacks.
Starvation selects at least 20 ms more reserve, or a larger measured gap plus
timestamp and callback margin, rounded to 5 ms and capped by configuration.
This observation is censored at failure and cannot predict a complete outage.

Queue overload allows two extra normal records (10 ms) above the reserve ceiling,
so a reserve at its limit does not immediately reject an ordinary arrival burst.
The pre-publication check can admit one additional record beyond that threshold.
The callback FIFO remains fixed. This is not an end-to-end latency guarantee.
Retry waiting now has a pure checked deadline with cancellation priority at expiry.
The cancellation fixture initializes its timer before starting the backoff interval.

| Build | Components | Config CLI | Live workers | Verified channel | Recovery peer | Two-ended proxy |
| --- | --- | --- | --- | --- | --- | --- |
| Debug | 121/121 | 24/24 | 12/12 | 43/43 | 9/10 | Pass |
| ReleaseSafe | 121/121 | 24/24 | 12/12 | 43/43 | 9/10 | Pass |

Failed final checks: recovery-Debug, recovery-ReleaseSafe.

- Debug recovery: role=receiver, mode=jitter, listener=False.
  Observed peer maximum AUDIO send gap: 122.852 ms; attempt reserves: [60.0] ms. These are diagnostics, not a waiver of the test.
- ReleaseSafe recovery: role=receiver, mode=jitter, listener=False.
  Observed peer maximum AUDIO send gap: 45.694 ms; attempt reserves: [60.0] ms. These are diagnostics, not a waiver of the test.

The original recovery completion/attempt criteria remain enforced. Diagnostic
failures are preserved: a preflight caught integer overflow before multiplication
in the new reserve calculation; the corrected test passes extreme inputs. A later
combined build caught duplicate module ownership; the runtime now owns the shared
policy import. Earlier development suites are distinct from the final campaign.
The peer now measures END send delay as well as AUDIO send gaps/call durations.
Local publication gaps do not identify packet arrival, acoustic latency or a NIC
fault. Null-backend scheduling and other host work can affect these tests.

Fresh explicit Windows capture through a generated declarative profile:
passed=True, frames=480000, elapsed=13.337 s,
process CPU=0.140625 s, non-silent bytes=0.
Samples are discarded; no audio recording is retained. This is a requested
10-second Windows capture to an independent authenticated peer, not Mac speakers.
The recorded final ReleaseSafe binary hash matches that physical observation.

Pure Intel macOS 12 core/configuration/lifecycle/authorization/recovery/timing
compilation is checked; native Mac audio and SDK linkage are not exercised here.
All 188 dependency entries and staged TLS DLLs are checked without changing pins.
Build/source/test/tool hashes stayed unchanged during the final campaign. The
prior receipt and its 361 evidence files remain intact.

This is not production-ready. Outstanding gates include sustained independent
clock correction, native Intel Mac build and speaker execution, Monterey/current
compatible macOS tests, real Wi-Fi latency and soak measurements, credential
lifecycle, stable endpoint identity, selected-app/tab adapters, phone playback
and the SvelteKit interface. Any failed checks above also remain unresolved.
Recovery causes an audible interruption; finite reserve cannot mask arbitrary
network, hardware or scheduler outages.
