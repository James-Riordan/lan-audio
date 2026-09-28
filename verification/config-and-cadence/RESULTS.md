# Declarative profiles and receiver diagnostics qualification

This phase adds bounded JSON schema 1 profiles, pure defaults/profile resolution,
configuration-relative credential references, run/validate commands sharing the
direct CLI engine, and editable templates from fresh pairing. App/tab selection
requests fail before capture because those adapters are not implemented.

| Build | Components | Config CLI | Live workers | Recovery peer | Two-ended proxy |
| --- | --- | --- | --- | --- | --- |
| Debug | 117/117 | 24/24 | 12/12 | 8/10 | Pass |
| ReleaseSafe | 117/117 | 24/24 | 12/12 | 9/10 | Pass |

Failed final checks: recovery-Debug, recovery-ReleaseSafe.
The recovery suite retains its original completion/attempt criteria. Failure is
not relabeled success when host scheduling exceeds its reserve. The new callback
counters retain maximum demand and first-starvation requested/available/rendered
frames after fencing. Independent peer counters distinguish send-start gaps from
send-call duration. Neither is an acoustic or actual packet-arrival timestamp.

An early diagnostic observed a 136.306 ms peer send gap against 60 ms reserve.
Other cases fail with smaller peer gaps; callback/worker scheduling and receive
cadence remain unresolved, so peer pacing alone is not a complete explanation.
The preflight and resumed suites remain separate evidence; no failed file was
overwritten. The host crashed during the first build. That process result was
unavailable after restart, so it is not counted as a successful qualification.

The explicit physical Windows run used the generated profile with paths containing
spaces, relative credential references, and an unrelated working directory. It
delivered 480,000 frames with zero capture drops and authenticated
ACK/closure, joined media worker and fenced/released native owners. Samples were
silent. Full measured harness interval: 14.09 seconds; process CPU:
0.15625 seconds (1.11% of one core).
This is a 10-second requested capture, not an acoustic or Mac receiver test.
The final ReleaseSafe executable hash exactly matches this physical observation.

Fresh pairing passes an independent mutual-TLS exchange. Repeated pairing retains
the identity and edited configuration; changed certificate bytes are rejected.
Pure Intel macOS 12 configuration/core/lifecycle/policy compilation passes. All
188 TLS dependency pins and staged DLLs match. Those checks do not compile or run
the native Mac application. Source/build/test/tool hashes are unchanged throughout
the final campaign. The prior phase's receipt and 469 evidence files remain intact.

This is not production-ready. Remaining gates include receiver timing failures,
independent-clock correction, native Intel Mac build and speaker execution,
Monterey/current compatible macOS testing, real Wi-Fi latency/soak measurements,
credential lifecycle, stable endpoint identity, selected-app/tab adapters, phone
playback and the SvelteKit interface. Recovery can cause audible interruptions;
finite buffering cannot conceal arbitrary network or scheduler outages.
