# Navigate the adopted header without forking it

Authority: local `vendor/miniaudio/miniaudio.h`, miniaudio 0.11.25, commit
`9634bedb5b5a2ca38c1ee7108a9358a4e233f14d`. `UPSTREAM.json` owns its exact digest.
The [commit-addressed source](https://github.com/mackron/miniaudio/blob/9634bedb5b5a2ca38c1ee7108a9358a4e233f14d/miniaudio.h)
is a provenance reference. Use local symbol search after checking custody; browser
rendering and generated translations can have different line numbering.

## Review scope

This pass read the wrapper's authored files, its build and tests, the low-level
device/manual contracts, the adopted conversion interfaces and the relevant
application audio adapter/queues. The large upstream header remains an external
implementation with inherited documentation. No line-by-line audit or proof of
all backend/DSP/codec internals is claimed. The table is navigation and review
routing, not a list of completed correctness reviews.

| Manual section / local starting line at this adoption | Use or review obligation |
| --- | --- |
| 1 Introduction / 13 | Object addresses, callbacks, device directions, enumeration; adopted boundary |
| 2 Building / 453 | Compile features and platform links; review profile upgrades |
| 3 Definitions / 720 | Frames, samples and terminology; align application units |
| 4 Data Sources / 771 | Generic upstream abstraction; do not assume application queue contracts |
| 5 Engine / 1023 | Disabled by selected profile; review before enabling |
| 6 Resource Management / 1525 | Disabled; no product asset-manager dependency is adopted |
| 7 Node Graph / 2027 | Disabled; routing/mixing product work requires a separate decision |
| 8 Decoding / 2498 | Disabled; do not advertise file-codec support from vendored source presence |
| 9 Encoding / 2660 | Disabled; network f32 encoding belongs to LAN Audio |
| 10 Data Conversion / 2716 | Available upstream interfaces; application adapter and numerical qualification still proposed |
| 11 Filtering / 3150 | Profile-available DSP surface; not qualified by adoption or layout tests |
| 12 Waveform and Noise Generation / 3339 | Profile-available generators; synthetic tests do not authorize audible extremes |
| 13 Audio Buffers / 3437 | Upstream ownership/borrow rules; not a replacement for the application's copy queue |
| 14 Ring Buffers / 3539 | Acquire/commit and SPSC restrictions; prove any future bridge |
| 15 Backends / 3608 | Backend-specific capabilities; native target qualification required |
| 16 Optimization Tips / 3702 | Suggestions need measured workload evidence |
| 17 Miscellaneous Notes / 3729 | Read for adopted platform/configuration constraints |

The declaration region follows the manual; native implementation is gated by
`MINIAUDIO_IMPLEMENTATION` or `MA_IMPLEMENTATION` near local line 11552.
Embedded file codecs exist later in the preserved header but are disabled by the
profile. Presence in an archive does not mean linked/used/qualified. Never split
the vendor header into local subfiles just to make the tree look modular.

## Symbol-level route to the contract

| Symbol family | Read next / concrete hazard |
| --- | --- |
| `ma_context_init`, `ma_context_uninit` | Context acquisition and device-before-context teardown |
| `ma_context_get_devices` | Returned lists are invalidated on next call/context teardown; snapshot before refresh |
| `ma_context_enumerate_devices`, `ma_context_get_device_info` | Enumeration callback must not recursively open/probe devices; source declarations override stale comment signatures |
| `ma_device_config_init`, `ma_device_init` | Defaults, stable destination and native result preservation |
| `ma_device_start` | Playback may request initial samples before returning |
| `ma_device_stop`, `ma_device_uninit` | Blocking non-callback control; resource lifetime versus audible tail |
| `ma_resampler_process_pcm_frames` | Distinct consumed/produced counts; null input means synthetic zeros, not natural EOF |
| `ma_resampler_set_rate_ratio` | Ratio is input/output; adopted generic helper quantizes via denominator 1000; successful return is not fine actuator precision |
| `ma_linear_resampler_adjust_timer_for_new_rate` | Adopted stock backend uses a 32-bit phase product; large reduced denominator transitions can wrap, even for repeated same rates |
| `ma_resampler_get_input_latency`, `ma_resampler_get_output_latency` | Different units; do not add them as the same clock |
| `ma_data_converter_config` | Inspect actual `allowDynamicSampleRate` field; prose/manual nesting can drift |
| `ma_pcm_rb_acquire_read`, `ma_pcm_rb_commit_read` | Borrowed span lifetime differs from FrameQueue copied-prefix semantics |

`reference/catalog.json` records exact declaration snippets for these anchors.
The documentation gate verifies that those snippets still exist, not that their
comments or implementations are correct. After an upgrade, read each changed
declaration and its implementation instead of merely changing the expected text.

The [conversion-control review](../contracts/conversion-control.md) adds silent
reproductions for these two rate/phase limitations. Native probe success means
the limitations were reproduced; it does not close Q04 or authorize a source
upgrade. The separate direct linear ratio helper has a different denominator and
must not be confused with the generic helper. All vendor bytes remain unchanged.

## Unreviewed source and platform work

Each advertised backend needs a targeted implementation review around start,
stop/uninit, thread creation/join, notifications, memory allocation, conversion and
OS capability failures. Record header symbols and version in the native evidence.
For Windows loopback and Intel Mac playback, the application supplies device
selection and behavior tests. Other backends remain available only to the extent
the upstream/build profile provides them; they are not product support promises.

The imported license is preserved alongside the header. No analysis in this book
relicenses either upstream or authored files. Release packaging must resolve the
authored license and include appropriate original notices.
