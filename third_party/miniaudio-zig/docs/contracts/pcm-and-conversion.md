# Frames, conversion and preservation claims

## Dimensions and representation

Let N be frames, C channels, S bytes per sample, F frames/second. Require C,F > 0
and checked products before forming any slice or allocation:

`sample_count = N*C`, `byte_count = N*C*S`, `duration = N/F` seconds.

Interleaved sample `(n,c)` occupies `n*C+c`. Callback PCM uses the native format;
wire byte order belongs to LAN Audio's codec. For its current f32 stereo host,
S=4, C=2, so a 240-frame callback contains 480 samples and 1,920 bytes. At
48,000 frames/s the nominal duration is 5 ms, but this is neither a promised
callback period nor a measured end-to-end latency.

The low-level binding does not reject NaNs or excessive amplitude by itself.
LAN Audio's finite-f32 wire domain is wider than nominal output amplitude.
Bitwise transport preservation means equality at the codec boundary; it does not
imply equality after channel mixing, clipping, gain, resampling or hardware output.
Choose and document an output gain/headroom policy before using real devices.
Protocol extreme-value fixtures belong in silent tests, not speaker playback.

## Partial conversion is normal

The `ma_resampler_process_pcm_frames` input/output counts are in/out parameters.
Let I and O be supplied capacities and i,o returned actual counts. The consumer
must establish `0 <= i <= I` and `0 <= o <= O`, advance each cursor independently,
retain the unconsumed input suffix and publish only the produced output prefix.
Never advance input by output count or assume one input frame yields one output
frame when rates differ. Do not overlap buffers without an explicit API guarantee.

No progress (`i=o=0`) is not EOF. The worker must wait for suitable input/output
capacity, detect an invalid configuration, or reach its bounded failure policy;
it must not spin indefinitely. A returned native error terminates that conversion
generation unless unchanged-state behavior has been separately established.
Do not assume the whole converter is transactional on failure.

Rate ratio r is input-rate/output-rate for the upstream ratio setter. Its inverse
is needed if a controller uses output-per-input units. Name the quantity at each
boundary and test its sign: a growing receive queue must eventually consume more
source frames per output duration under the selected controller convention.
Rate-setting capability depends on the selected implementation/configuration;
verify native result codes rather than assuming every backend supports changes.
Success alone does not establish rate precision: the adopted generic ratio helper
quantizes near unity in roughly 1000 ppm steps. Large explicit integer rates can
also overflow the stock backend's phase remapping. The
[control contract](conversion-control.md) records reproduced examples and the
qualification needed before using either route for drift correction.
For the adopted `ma_data_converter_config`, set its actual top-level
`allowDynamicSampleRate` field before init when rate changes are required;
its default is false. The manual's older nested spelling must not become an
invented Zig field. Inspect the translated declaration and test equal-rate init
followed by a rate change, where disabled dynamic support can otherwise be missed.

The required-input and expected-output query APIs help size processing requests;
they are not ownership transfers or a proof that a particular call will consume
exactly that many frames. Keep the processing result authoritative. Initialize
converters and their heaps on a non-callback owner, keep allocator state alive,
and pair teardown with the same allocation policy. Preallocation is an available
upstream mechanism, not evidence that every processing backend has constant time.

## Conservation and tail accounting

For the no-resampling copy path, admitted source frames split into pending,
queued, callback-copied and explicitly discarded frames. Without saturation or
abort, their counts conserve source frames. After resampling, source and output
frames are different units; they cannot be added in that equation.

A future converter ledger needs at least: consumed source frames, produced media
output frames, intentionally padded input, output silence, discarded source,
discarded output, algorithmic delay and terminal tail policy. Report delay in its
declared clock domain. A raw queue-empty observation cannot prove the converter
has emitted its tail. Upstream reset clears conversion history and is not a
graceful flush; any zero-input/drain policy needs algorithm-specific tests.

For a steady ratio, `produced_output approximately consumed_input/r` is only a
long-run rate relation. Finite blocks, latency and filters invalidate exact
per-call equality. Test impulse location/tail, DC, channel identity and chunking
independence with a separate oracle and stated numerical tolerances. Do not use
f32 bit equality as a resampling quality metric.

## Deliberate adoption boundaries

`ma_data_converter` composes sample-format, channel and rate conversion. Selecting
it could make a device path convenient but introduces implicit mixing/resampling
that must appear in diagnostics and fidelity claims. Record both requested
application format and observed native format where the backend exposes them.

Upstream ring buffers use acquire/commit borrowing and have their own SPSC
contract. LAN Audio currently uses its own FrameQueue copy semantics and proof.
Do not interchange these abstractions or share producer/consumer ownership just
because both are called queues. Adopting another buffer requires translating its
borrow lifetimes and redoing the release/publication argument.

These conversion APIs are available in the chosen profile, but application clock
control is not implemented by this document. [Q04](../implementation/qualification.md#q04)
specifies the gate before introducing a resampler into the production path.
The detailed [custody/terminal model](conversion-custody.md),
[future-file handoff](../implementation/conversion-handoff.md) and
[independent verification plan](../verification/conversion.md) refine that gate.
