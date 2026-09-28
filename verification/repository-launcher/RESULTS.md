# Repository-owned desktop launch qualification

## Result

A standalone Windows copy builds from the supplied pinned dependency closure and
archives, without sibling repositories or prebuilt app/compiler trees. Its path
included spaces and é. Initial downloads were also exercised by the real root
start.cmd launcher. A fresh standalone Zig global/local cache completed ReleaseSafe
compilation. Repeated preparation reused the checked output. The isolated output
was then adopted into the root cache after byte-for-byte matching all native
source/build/dependency key inputs.

- 21 isolated bootstrap/enrollment/native-install/release-boundary tests: PASS,
  with the private embedded Python runtime and real temporary TLS credentials.
- 19 existing desktop setup tests: PASS. No physical audio opened.
- Windows candidate packaging with a deliberately synthetic test revision: PASS.
  This test package is not a publication and must not be shipped as a real revision.
- Application reference/link/contract coverage: 180 files, PASS.
- Reviewed TLS custody including staged runtime DLLs: 188 files, PASS.
- Complete copied dependency closure: 1,030 files verified against the preserved
  source-package manifest. Existing TLS hashes were not changed.
- GitHub workflow: authored and manually reviewed, not executed. Local YAML parser
  was unavailable; workflow-parse.json records that limit rather than a false pass.

The new listener tests bind loopback and disable discovery broadcasts. They reject
wrong certificate pins, wrong and malformed tokens, deep/oversized messages, unsafe
archive paths, corrupt downloads, stale/mismatched release data and license changes.
They verify exact identity bytes, saved-pair preservation, native receiver install,
OS lock exclusion/release, discovery-secret checks and lost-final-response custody.
The preexisting desktop suite separately exercises repeat and concurrent publication.

## Preserved failures and repairs

The first PowerShell bootstrap encountered missing Get-FileHash in this host's
Windows PowerShell module environment. The launcher now uses .NET hashing/extraction.
The first pairing campaign exposed newline conversion in text file transfer; base64
now preserves exact source bytes. A fresh standalone build rejected the old Zig
--global-cache-dir build flag; the wrapper now uses ZIG_GLOBAL_CACHE_DIR plus its
supported local-cache option. A deep-JSON test exposed an assumption about Python's
recursion behavior; the protocol now explicitly bounds decoded nesting to eight.
Earlier logs remain alongside passing reruns.

## Mac blocker discovered, not hidden

Both archived Zig downloads were verified using the ZSF signing key, signature and
trusted filename. The Intel Mac archive contains no links or unsafe member paths.
Mach-O inspection found that its compiler executable requires macOS 14.0, despite
the application's intended macOS 12 deployment target. The launcher therefore
routes macOS 12/13 to an exact-source/revision public GitHub native candidate instead
of attempting that compiler. The release path and explicit publication workflow
are implemented. No GitHub release or native Mac binary has been produced here.
Source builds on Intel macOS 14+ and candidate execution on Monterey remain
unqualified. The machine's current OS, Apple SDK and actual speaker hardware have
not been accessed.

## Production limits

No live Windows-to-Mac listening, gaming latency, sustained Wi-Fi, clock correction,
certificate renewal, signing/notarization, phone receiver, per-app capture or GUI
qualification occurred. This is a substantial onboarding increment, not a production
release. OS installation/firewall prompts and a first trusted invitation transfer
remain user interactions. Private saved state is outside the clone; no personal
pair, OS service, firewall rule, SSH login or GitHub publication was created.
