# Native failure ownership and reconstruction

The AudioDevice control implementation is now instantiated privately as
`Device(Native)`. The public `AudioDevice` name, stable userdata requirement,
callback behavior and host-module boundary remain unchanged. Native is a
compile-time function set; there is no runtime injection switch in the product.
The host-root test instantiates the same implementation with controlled wrappers
around real miniaudio null-backend objects.

## What the test establishes

| Failure location | Required result |
| --- | --- |
| Before context initialization | No context/device ownership and no native release. |
| Enumeration or before device initialization | Release the acquired context exactly once; never uninitialize an uncreated device. |
| Callback/native format admission after device initialization | Release the actual device before its context; remain empty and reject start. |
| Before or after native start | Retain both resources in failed state. Even if the native device secretly started, an error cannot authorize a fence or reset. |
| Before or after native stop | Retain both resources in failed state. A stop error cannot be treated as proof that callbacks have ended. |
| Final deinit after each start/stop failure | Real device uninit precedes context uninit. Repeated deinit does not release twice; reconstruction can initialize, start, fence and destroy another device. |

The wrapper maintains independent context/device counts and an ordered release
trace. The format cases temporarily change stopped-device admission metadata
and restore it before native cleanup. The after-start case invokes real native
start before returning a synthetic failure; the before-stop case leaves the real
device running. These distinguish a reported control failure from a known native
state and exercise destruction with outstanding callback potential.

After real uninit, the test observes an unchanged callback count across a short
wait. That observation supports the run; the reclamation argument still depends
on the reviewed native uninit/join contract. A finite quiet interval alone would
not prove future callbacks impossible. No test releases live device storage to
manufacture a use-after-free witness.

## Limits and next obligations

These are controlled API-return and metadata faults at the application boundary.
They do not inject allocator/driver failures inside miniaudio initialization, and
they do not establish arbitrary OS partial-failure cleanup. Native library source
and reviewed pins are unchanged. See the [source-scoped results](../../verification/native-failures/RESULTS.md)
for actual build modes, raw outcomes and hashes.

The existing [native fence contract](native-fence.md) remains limited to reviewed
synchronous backends. CoreAudio asynchronous fences, endpoint discovery/stable
identity, actual hotplug/sleep/wake, driver failures, Mac SDK/runtime closure and
full worker fault propagation still require implementation or qualification.
The test seam permits future boundary cases without changing the production
control path or introducing test policy into callback execution.
