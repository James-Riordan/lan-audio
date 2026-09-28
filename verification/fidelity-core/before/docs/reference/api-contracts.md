# Existing API contracts: call-by-call maintenance guide

This chapter describes current implementations after relocation. It supplements
the per-file reference with inputs, state effects, custody and failure obligations.
It does not declare the proposed v2/runtime interfaces implemented. Caller mutation
of public struct internals can violate invariants; field visibility is not permission
to bypass these contracts. Source and named tests decide current behavior.

## Session — `src/session/session.zig`

| Call | Preconditions / effect | Rejection / maintainer obligation |
| --- | --- | --- |
| `begin()` | Idle; increment epoch, enter negotiating, return new epoch. | InvalidState/EpochExhausted; no wrap or implicit restart. Keep failure state unchanged. |
| `authenticate(epoch)` | Matching epoch and negotiating; set authenticated. | StaleEpoch/InvalidState. This is host attestation, not certificate verification. |
| `start()` | Negotiating and authenticated; enter streaming. | InvalidState/Unauthenticated. No callback/device is started here. |
| `admit(epoch)` | Matching epoch, streaming and authenticated; no mutation. | StaleEpoch/InvalidState/Unauthenticated. Check before window admission. |
| `enterCallback(epoch)` | Admission passes and token absent; set one token. | CallbackActive and admission errors; not a real-thread synchronization primitive. |
| `leaveCallback(epoch)` | Matching epoch and token present; clear token. | StaleEpoch/NoCallback; permit release after requestStop. |
| `requestStop()` | Negotiating or streaming; enter stopping. | InvalidState; closes new admission but does not stop a worker. |
| `finishStop()` | Stopping, token absent and host has actually quiesced owners; clear auth, enter idle. | InvalidState/CallbackActive; native joining remains caller duty. |

Review `tests/unit/core.zig` authentication/drain cases and the session model when
changing any transition. Add before/after snapshots for newly rejected transitions.

## Window — `src/media/playout_window.zig`

`Window(K,M)` statically requires K,M > 0 and owns K complete copied blocks.

| Call | Inputs/output and state | Rejection / custody |
| --- | --- | --- |
| `init(epoch)` | Return empty presence map with next=0 and given epoch. | Old generation can be discarded only after caller quiescence. Undefined payload slots cannot be read until present. |
| `insert(epoch,sequence,samples)` | Exactly M finite f32 samples; matching epoch; copy into sequence modulo K and mark present. | StaleEpoch, InvalidBlock, SequenceExhausted, Late, TooFar, Duplicate. A temporary permits input overlap with owned payload storage; rejection does not publish. |
| `tick(output)` | Output exactly M nonaliasing samples; copy present block or fully zero; clear slot and increment next; return media/silence. | InvalidBlock/SequenceExhausted leave state/output unchanged. No allocation or external timing; one owner supplies tick schedule. |

Modulo reuse must still agree with the independent non-ring oracle. Do not conflate
received positions, rendered positions and queue-consumed frames in new metrics.

## V1 framing and conversion — `src/protocol/v1.zig`

| Call/type | Contract | Important failure edge |
| --- | --- | --- |
| `validate(Message)` | Validate nonzero stream, exact kind body size, valid sequence, and exact START profile/reserved bytes. | A constructed Message is not trusted just because it has a Zig type. |
| `parse(bytes)` | Exactly one complete record; return body slice borrowed from input. | Invalid header/length/profile/sequence/ID; no copied lifetime extension. |
| `Parser.feed(input)` | Input nonaliasing parser storage; consume at most one record, return consumed prefix and optional borrowed Message. | On any parser error set failed; next call returns Poisoned. Empty input must not spin. Process unconsumed suffix at caller. |
| `Parser.finish()` | Accept empty or completed state without changing it. | Poisoned or Truncated for a pending partial record; TLS close alone cannot validate application framing. |
| `encodeStart(out,id)` | Write 48 total bytes: 36-byte header plus exact 12-byte PCM16 profile. | Bad ID/short output before writing; returned slice borrows out. |
| `encodeAudio(out,id,seq,input)` | Exactly 480 finite f32 samples; quantize/clamp to s16LE into a 996-byte record. | InvalidSamples/InvalidStream/InvalidSequence/ShortOutput before writes. Input and output may not overlap. This conversion is intentionally not f32-bit-exact. |
| `encodeEnd(out,id,next)` | Write empty-body header with exclusive final position. | ID/output bound checks; receiver validates whether frontier is admissible. |
| `encodeAck(out,id,next)` | Write empty-body acknowledgement header. | Encoder does not prove playback/drain; caller controls truthful ACK timing. |
| `decodeAudio(message,out)` | Valid AUDIO and exactly 480 output samples; decode s16 via bounded temporary then copy. | Wrong kind/length/profile rejected. Temporary permits overlap between input record and output. |

`header`, `bodySize`, `kindOf`, `validId` and `writeHeader` are private shared
validation/layout helpers. Changes must preserve public validation-before-write,
maximum 996-byte parser storage and the independent golden layout tests. Reject
unknown kinds/versions; do not scan for magic after a poisoned record.

## Receiver — `src/session/receiver.zig`

| Call | Effect | Ownership/error boundary |
| --- | --- | --- |
| `authorizeChannel()` | Set one host-authorized-channel flag before a stream. | Repeated call or existing stream rejects InvalidState. Host must finish cryptographic and product policy checks first. |
| `accept(message)` | Validate record; require channel; START binds epoch/ID, AUDIO decodes/copies, END sets admissible frontier and may complete. | UnexpectedMessage, WrongStream, Ended, InvalidEnd plus lower-level errors. One stream/connection; post-END admission is closed even during drain. |
| `tick(out)` | Require admitted streaming session, tick window, then check completion. | Ended or lower-level errors. Host schedules ticks; callbacks do not concurrently call this. |
| `completeIfDrained()` | Private: if next=end, request/finish abstract stop and set ended. | No native join occurs. Application must drain/join actual output ownership separately before user-visible completion. |

## SPSC, callback bridge and native owner

| Surface | Current contract / test obligation |
| --- | --- |
| `FrameQueue.write(samples)` | Producer-only; complete frames; copy fitting prefix and release-publish; return frame count. Full is zero, not a retry loop. Partial writes leave the suffix caller-owned. |
| `FrameQueue.read(out)` | Consumer-only; copy available prefix then release slots; return frame count. Unfilled output suffix remains unchanged. |
| `FrameQueue.producerPending()` | Producer-only conservative occupancy from own published and acquired remote released cursor. Third-party snapshots are not supported. |
| `CallbackBridge.captureInput(input)` | Callback producer; update saturating captured/drop totals and sticky atomic overrun. Worker must not stitch across dropped intervals. |
| `CallbackBridge.renderOutput(out)` | Callback consumer; copy available frames and zero entire remainder; count media versus silence separately. |
| `AudioDevice.init(profile)` | Empty, stable storage and joined prior owners; choose explicit backend/type, reset bridge, initialize context/device with self userdata; native errors retained. |
| `AudioDevice.start()` | Ready; native start; running on success or failed on native error. Native callbacks may begin during the call. |
| `AudioDevice.stop()` | Running; native stop; ready on success or failed on native error. Off callback only; pause retains queued contents. |
| `AudioDevice.deinit()` | Idempotent for empty; otherwise uninitialize device then context and mark empty. Authoritative callback reclamation boundary; workers still need their own joins. |
| Native data callback | Borrow native buffers for invocation only; arbitrary frame count, stereo f32; copy/zero, update owned diagnostics and atomic callback count. No I/O, allocation, logs, control calls or blocking. |

Check full/empty, ring/u32 rollover, stereo alignment, callback tails, overrun,
concurrent FIFO and repeated native reconstruction. `capture_overrun` is the only
live cross-owner bridge status besides explicit atomic callback count; ordinary
totals may be read after deinit, not sampled concurrently by a UI.

FrameQueue caller buffers must not overlap its internal storage: both span copies
use memcpy, not an overlapping move. Whole-frame length and sole ownership are
caller preconditions. Window.insert's deliberate overlap allowance does not apply
to FrameQueue. See the [ownership explanation](../literate/stream-argument.md).

## TLS Engine — `../tls-zig/src/root.zig`

| Call | Custody / progress | Failure behavior |
| --- | --- | --- |
| `init(Config)` | Returns one move-only owner; validates roles, identity strings, certificate/key pair, ALPN 1..255, wall time and checked handshake deadline; C backend copies/consumes init strings. | InvalidConfig or BackendInitialization; no network/DNS/console prompt. |
| `tick(now_ms)` | Advance monotonic host observation and enforce pre-authentication deadline. | Backward clock InvalidState; deadline cancels and remains terminal. |
| `handshake()` | Progress complete/need_input/need_output; complete sets authenticated. | Authentication/ALPN/TLS failures become terminal and clear auth. |
| `feedRecords(bytes)` | Copy accepted ciphertext prefix, at most 16 KiB per call. | Empty is not EOF; input_full can mean no consumption; preserve caller suffix. |
| `drainRecords(out)` | Copy available ciphertext prefix; allowed after TLS failure to send a generated alert. | Keep owner alive for diagnostics/alert drain until cleanup; invalid destroyed handle fails. |
| `readPlaintext(out)` | Copy authenticated plaintext prefix; caller owns supplied storage. | Requires ready/no pending write; raw transport EOF is not automatically clean TLS close. |
| `queuePlaintext(bytes)` | Copy one nonempty <=16 KiB block into owned write storage. | Success is local custody, not remote delivery. Second pending write/misuse rejects. |
| `flushPlaintext()` | Resume SSL write with the same owned buffer through WANT_READ/WANT_WRITE. | Do not replace/reorder accepted bytes; bounded buffer does not bound OpenSSL total CPU/memory. |
| `shutdown()` | Initiate/resume close; plaintext_available requires reading pending peer data before retry. | Only closed authenticates close_notify; preserve remaining deadline and queued records. |
| `transportEof()` | Signal raw transport EOF to BIO. | Handshake/read still determine truncation; no fabricated clean close. |
| `diagnostics()` | Optional snapshot of verification code, reason and received alert while handle exists. | Diagnostic codes are not an authorization API; preserve useful native cause locally. |
| `cancel()/deinit()` | Free owner once, clear authentication, set terminal cancellation where absent. | Serialized caller only; a different thread must signal Driver's cancellation flag. |
| `backendVersion()` | Borrow backend version string. | Verify actual runtime identity, not just header version or expected DLL filename. |

Private `ptr`, `live` and `status` centralize string optionality, terminal-handle
checks and C-status mapping. Keep them consistent with backend.h/backend.zig/C
implementation and independent ctypes consumers on each target ABI.

## TLS Driver — `../tls-zig/src/driver.zig`

| Call | Contract / caller action |
| --- | --- |
| `init(config,transport,canceled)` | Own Engine; transport context and optional atomic flag outlive Driver; one worker serializes everything else. |
| `beginHandshake(now,deadline)` | Idle, not shutting down; start absolute-deadline handshake. |
| `beginWrite(bytes,now,deadline)` | Idle/authenticated/not closing; copies into Engine and owns transfer until final result. Caller may release input after successful begin. |
| `beginRead(buffer,now,deadline)` | Idle/authenticated/nonempty; exclusively borrow buffer until complete or error. Use bytes only after successful complete count. |
| `beginShutdown(now,deadline)` | Idle/authenticated; retain the first shutdown deadline across later plaintext reads and repeated close attempts. |
| `beginFlush(now,deadline)` | Idle/authenticated/not closing; send existing protocol output without new application bytes. |
| `step(now)` | At most one transport callback or TLS/BIO operation per step. again yields scheduling opportunity; wait_input/output require bounded interruptible polling; complete carries count; closed/ plaintext_available have distinct meanings. |
| `probePeer(buffer,now,idle_deadline)` | Nonblocking early-data probe, idle or after SSL_write completed during active ciphertext send; borrow buffer only this call. Preserve original write/deadline/ciphertext custody; return output_pending/write_pending when caller must resume normal driving. |
| `cancel()/deinit()` | Serialized terminal cleanup. Other threads set flag and wake the owner; they do not touch Engine or close its transport concurrently. |

Internal drive→drain→send/feed/receive phases retain unsent and unconsumed suffixes.
Validate transport counts; send zero is invalid and receive zero is EOF. Deadline
and cancellation checks precede ongoing work even if the peer makes slow progress.
An expired or backward clock never authorizes extending a deadline silently. A
bounded Driver step does not imply bounded OpenSSL call duration.

## Native C boundary and miniaudio adoption

The TLS `tz_*` declarations are a fixed ABI mirror: status 0 complete, 1/2 need
input/output, 3 authenticated close, 4 input full, 5 pending plaintext during close;
negative values represent failure/misuse categories mapped by Engine. Preserve
old `tz_new` HTTP-default compatibility while new callers use copied configurable
ALPN. Call `SSL_get_error` immediately after the relevant SSL result. Match target
C integer widths and pointer lifetime across header, Zig externs and ctypes tests.

The miniaudio wrapper exports upstream `c` rather than inventing an alternate
owning API. For application use, inspect the pinned definitions of context/device
config/init/start/stop/uninit, PCM format/frame helpers and any future resampler.
Initialize configuration through upstream helpers, match compile-feature macros,
keep stable device/userdata addresses and uninitialize only successfully created
objects. Platform capability is checked at native initialization; presence of an
enum does not prove a backend/device works on the host.
