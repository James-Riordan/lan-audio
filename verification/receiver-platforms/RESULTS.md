# Selected-peer policy, copied device discovery and Apple receiver scope

The user made Windows system audio to either MacBook or iPhone the primary
journey, with repeatable controls and shared robust behavior. This phase adds
working shared authorization components and the first Windows inspection command.
It does not implement streaming commands or a native iPhone receiver.

The parent source receipt is native-failures SHA-256
`0dffee2e78dd45d29bf65bdb990ee1ad403d6308b73206f153fc2d32f587e029`.
Before editing, 128 application files were verified against that receipt.

## Implemented and checked

* A fixed copied allowlist binds verified leaf-certificate SHA-256, selected peer,
  complementary application role, exact v2 ALPN and local connection generation.
  Its tests use synthetic verification evidence; the real TLS export is still needed.
* A shared channel guard composes the actual v2 Negotiation gate. Repeated matching
  authorization preserves the stream/frontier, repeated revocation converges,
  stale events preserve replacement state, and current identity/policy failures
  revoke authorization. It does not perform native cleanup.
* Catalog copies reported device names/default flags before enumeration context
  release, enforces a 64-entry application bound, marks duplicate-name ambiguity,
  and rejects malformed native metadata. It never initializes an audio device.
* The foreground lan-audio command supports help, version and device inspection
  in plain text or schema-1 JSON. It explicitly reports streaming/pairing as under
  development. Actual Windows discovery reported four output devices repeatedly.
* Shared build checks no longer configure an unsupported desktop audio dependency
  on iOS. Native application requests fail explicitly instead of returning a
  successful placeholder. Object-only and fully linked checks remain separate.

## Restored-source results

| Check | Outcome |
| --- | --- |
| Windows Debug audio/policy tests and app build | 20/20 executed tests passed; executable built; 9.734 s |
| Windows ReleaseSafe audio/policy tests and app build | 20/20 executed tests passed; executable built; 72.275 s |
| Intel macOS 12 policy test artifact | Compiled, not executed; 8.151 s |
| x86_64 Linux/musl policy test artifact | Compiled, not executed; 2.264 s |
| ARM64 iOS 16 policy test object | Compiled without SDK linking or execution; 1.557 s |
| ARM64 iOS 16 full policy test link | Failed: Apple libSystem unavailable; 7.607 s; remains a blocked target gate |
| Native iOS app request | Explicit unavailable result, exit 1; no native iPhone app exists |
| Windows command smoke checks | Help/version/invalid arguments plus two actual device listings; expected exits 0/0/2/0/0 |
| Deliberate authorization defects | Four compiled variants rejected by named runtime tests |

The 20 tests comprise six external audio integration cases, seven host-root cases
and seven policy/channel cases. The latter include an independent 128-condition
authorization table, fingerprint formatting for all byte values, copied/bounded
rules, actual v2 record transitions in both roles, stale events and idempotence.
Timings are command wall times, not latency/performance benchmarks.

The qualified directory records exact commands, source hashes, return codes,
target logs and Debug/ReleaseSafe executable hashes. The mutations directory
retains broken variants and named runtime witnesses; the runner restores source
in finally. Negative build checks whose diagnostics match expectations are still
negative native/link outcomes, not successful iOS qualification.

## Failed attempts retained

Attempt 1 passed the seven new policy tests. Attempt 2 failed because the pinned
Zig build API uses addPassthruArgs rather than b.args. Attempt 3 then exposed a
nullable C-array slice conversion in copied discovery and the unconditional
unsupported miniaudio dependency during an iOS policy check. Their source hashes,
before-images and logs remain preserved. Attempt 4 repaired those boundaries,
passed 20 Windows tests and built the command; the iOS link then correctly reached
the separate missing-libSystem boundary. No failed attempt is relabeled as a pass.

Some inherited native compiler logs retain Perl locale diagnostics before a
successful final build summary. Keep those logs intact and interpret the actual
process exit and final summary. No production-clean-toolchain claim is made.

## Remaining product gates

The records TLS Engine still needs a reviewed copied verified-peer leaf export;
synthetic policy evidence must not enter production. Durable approvals/credentials,
real sender/receiver worker wiring, stream commands, stable device IDs, native
asynchronous fences, sustained clock/recovery behavior and native Apple app/SDK/
signing/installation remain open. No physical capture/playback ran in this phase.

macOS 12 remains the required receiver floor. iOS 16 is only a provisional object/
link probe, not an asserted phone requirement. The actual iPhone model/OS and both
Apple playback journeys still need qualification. The new WP11 records local
network permission, locked playback, interruptions, route changes, shared ownership
and signed installation obligations without creating an untested Swift skeleton.

Dependency pins and the stable core export remain unchanged. The final receipt
records observed TLS custody drift separately from adopted application work.
