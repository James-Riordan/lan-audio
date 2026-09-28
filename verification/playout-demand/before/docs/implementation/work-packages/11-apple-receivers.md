# WP11 — Native MacBook and iPhone receivers

Status: required product work; native Apple application not yet implemented.
The user now explicitly requires Windows system audio to either the MacBook or
iPhone. These are primary receiver journeys, not an optional mobile afterthought.
The original broader OS objective remains, with separate capability evidence.

## Shared behavior, native host integration

Both receiver applications must use the same v2 framing/format rules, selected-peer
authorization, ordered pending/queue custody, error meanings and session-generation
rules. The current Zig core, copied policy and channel gate provide shared pieces.
This is behavioral equivalence at the protocol/ownership boundary; it does not
mean macOS and iOS expose identical audio, permission or process APIs.

The proposed native Apple adapter uses a small Swift host around the shared media
engine through a documented C ABI. Create that ABI together with an actual caller
and conformance tests; it does not exist yet. Keep wire decoding and authorization
canonical in the shared engine rather than maintaining a second Swift protocol.
Keep platform notifications and UI off the audio callback and serialize their
effects through the generation-tagged lifecycle owner.

| Proposed component | Required contract before it becomes implemented |
| --- | --- |
| Shared receiver C ABI and Swift ownership wrapper | Explicit sizes/alignment/version, fixed stable buffers, copied/borrowed boundaries, accepted prefixes, no exceptions across ABI, no destruction with native/worker debt |
| Apple audio output adapter | Qualified AVAudioEngine/CoreAudio callback profile; verify actual rate/layout; explicit output conversion and gain; no callback allocation/blocking/networking |
| iOS audio-session owner | Activate the playback session only for the user's playing intent; handle interruption, route loss, media-services reset, screen lock and background transitions with generation isolation |
| Apple transport/identity adapter | Reviewed mutually authenticated TLS closure, copied verified peer leaf, current certificate time, approved role/ALPN and restrictive credential storage |
| Native pairing/status controls | Select the Windows PC, explicitly approve its identity, play/stop/retry, truthful waiting/playing/recovery state, accessible controls and actionable permission failures |
| Apple build/signing/package definitions | Real SDK/Xcode build, shared-engine linkage, minimum OS verification, signed installation and clean-device launch; no unsigned-binary claim of iPhone installability |

## Platform obligations

For local networking, provide the appropriate usage explanation and test denial,
approval and retry. Bonjour service declarations apply if discovery is actually
implemented; discovery never authorizes a peer. Apple's
[local-network privacy guidance](https://developer.apple.com/documentation/technotes/tn3179-understanding-local-network-privacy)
is the platform authority. Request permission from an understandable foreground
action rather than relying on a background first connection.

For iPhone playback while locked/backgrounded, Apple's
[playback category](https://developer.apple.com/documentation/avfaudio/avaudiosession/category-swift.struct/playback)
requires the corresponding audio background mode. This does not authorize an
unlimited idle reconnect service. Stop unnecessary background work when playback
ends, and never resume an obsolete generation after interruption. Test calls,
other audio, route changes, headphone removal and media-services resets. Follow
[Apple's route-change contract](https://developer.apple.com/documentation/avfaudio/responding-to-audio-route-changes)
when deciding whether output must pause before a route is reused.

The Mac receiver's required deployment floor remains macOS 12. The iPhone model
and installed iOS version are not known; iOS 16 is a provisional compile target,
not a newly imposed user minimum or a supported-version claim. Review availability
and the actual device before finalizing support. Build-host requirements and
deployment minimums differ; use Apple's current
[Xcode compatibility table](https://developer.apple.com/xcode/system-requirements)
when arranging the native build. A Mac running Monterey need not itself compile
the newest iPhone SDK in order to run the separately built Mac receiver.

## Acceptance

Install the signed receiver on each actual target and repeat the same approved
Windows stream test: correct selected identity, first sound, exact transport
sample reconstruction, bounded live latency, stop/restart and recovery. On iPhone,
also test locked playback, permission denial/retry, phone interruptions, route
loss and foreground/background transitions. Repeated controls create at most one
active generation; stale completions cannot restart sound or free a replacement.

One selected receiver is the initial scope. Simultaneous synchronized Mac+iPhone
playback requires a separate multi-sink clock/custody design and is not implied by
"either". Native hardware execution, SDK closure, signing and sustained timing
remain mandatory before calling either route production-ready.

Exit: both selected Apple receivers complete the signed-install, actual-device,
identity, lifecycle and sustained-audio checks above with recorded evidence.

The application build graph now keeps shared checks independent of unsupported
native-audio dependencies. Requesting `app` for iOS fails explicitly. An iOS
policy object can be compiled separately with `policy-object-check`; full linking
still needs Apple system libraries, and neither check installs a native receiver.
