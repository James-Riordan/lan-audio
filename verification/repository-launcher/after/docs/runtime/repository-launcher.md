# Clone, prepare, pair and start

The repository owns this path. No sibling checkout, SSH login, Homebrew, global
Python installation on Windows, or manually copied private-key folder is needed.
The receiver targets Windows x86_64 and Intel macOS 12+, but the pinned Mac
compiler executable has a macOS 14 minimum (verified from its Mach-O load command).
Other hardware/platform targets fail
explicitly. Native Mac execution remains unverified until its checks run there.

From a clone, use `start.cmd` on Windows and `sh start` on the Mac. The Mac should
run first: its first source build includes OpenSSL tests and may take considerable
time. It then asks for the Windows invitation. Windows prints the invitation and
waits up to ten minutes. After pairing, keep both launchers open. On subsequent
sessions, run the Mac command first, then Windows. Ctrl+C ends the foreground run.
`--prepare` downloads/builds without provisioning, listening or opening audio.

## Build custody and repeat behavior

`third_party/lock.json` binds all 1,030 copied dependency files to the preserved
reviewed source package. Existing TLS digests are unchanged. The launcher verifies
them before using a cached build. Copies retain library ownership; other chats
editing live sibling libraries cannot change this build implicitly.

`tools/bootstrap_assets.json` pins Zig, the Windows embedded Python archive and
the Mac OpenSSL source archive. Zig signatures and trusted archive names were
verified against the [ZSF key](https://ziglang.org/download/) during adoption;
the launcher enforces those exact SHA256 digests on downloaded archives. Mirrors
may disappear: it tries the pinned locations and fails explicitly if unavailable,
without upgrading tools or accepting a different hash. Repository trust is still
required. Neither local hashes nor source compilation establish publisher signing.

Tools, build outputs and failed Mac build logs live in ignored `.lan-audio/`.
Archive extraction rejects traversal, duplicate paths, links and device entries.
Zig uses one build job. The Mac recipe uses Apple Command Line Tools, builds and
tests static OpenSSL, and targets macOS 12. It never installs a system SDK or
modifies PATH. The OS owns installation/permission prompts. Apple tools with
Python 3.9+ are required. The Mac launcher requests their installer when absent.

An OS file lock serializes preparation per checkout and the audio session per
state directory. A crash releases locks. Completed builds have immutable runtime
hashes and source-derived directories. A later build gets a separate installation;
the saved pair and user settings stay in the stable private state directory.
Failed builds retain logs; reruns retry incomplete build work. Full power-loss
durability across every filesystem and OS is not claimed.

## Pairing trust and failure boundary

The Windows host generates fresh identities with the reviewed OpenSSL executable.
The issuer signing key is discarded. Enrollment listens temporarily on TCP 46322.
The `LAN1` invitation includes numeric candidate addresses, the server leaf SHA256
and a random 256-bit bearer token. Copy it directly between your trusted devices;
do not post it in issues or public chats. It is deliberately not a weak short PIN.

The Mac connects with TLS 1.3 and checks the exact leaf fingerprint **before**
sending the token. The server requires that token before transferring any private
material. Only the receiver's five fixed-name files cross the connection; their
bytes are base64 encoded to preserve Windows/Mac line endings. Frames are bounded
to 64 KiB and eight JSON nesting levels. The receiver checks file hashes, role, profile binding and key/cert
matching, installs privately, and records its link before acknowledging. The PC
records the accepted address before its final response. The temporary listener
closes after success or timeout. There is no persistent enrollment service.

A failed final response can leave one side already paired. Rerun the Mac first,
then Windows: the same saved discovery secret lets the PC recognize that receiver.
An existing different identity is never overwritten. Failed private receiver
stages may remain for diagnosis; they are not adopted. Certificate expiration is
825 days; automatic renewal and a user-facing re-pair command are still missing.

The PC currently creates and retains both identities in its private state folder;
this is a trusted-PC enrollment model, not hardware-backed, endpoint-local key
generation. Public dependency test credentials never participate. Same-user local
processes can access this state; isolation from other code running as you is not
claimed.

## Discovery and settings

The receiver answers UDP 46323 challenges only when their HMAC-SHA256 matches
the pair's random 256-bit discovery secret. Responses bind a fresh nonce and are
checked before selecting the receiver address. The sender tries the previous IP
and IPv4 broadcast, so normal DHCP address changes do not require profile edits.
The native audio connection still independently uses mutual TLS and leaf pins.
Discovery does not replace authentication. IPv6, multiple receivers, VLAN routing,
and networks that suppress broadcast are not automatic in this increment.

Stable private state defaults to `%LOCALAPPDATA%\LAN Audio` on Windows and
`~/Library/Application Support/LAN Audio` on macOS. `settings.json` there contains
editable operation profiles. It survives builds and repeat launches. The launcher
writes only the discovered address into an installation-local `session.json` and
starts the native `run --config ... --profile home` engine. Python carries no audio.
On the receiver it keeps only the small discovery listener alongside that process.

For a custom state directory or networks requiring an explicit Mac IPv4 address:

```json
{
  "schema": 1,
  "state_directory": "./private-lan-audio-state",
  "receiver_address": "192.168.1.50"
}
```

Save this configuration **outside the repository**. Paths resolve relative to it.
Run `start.cmd --config C:\path\launcher.json` or
`sh start --config /path/launcher.json`. Omit `receiver_address` to use discovery;
the explicit address is used only by the sender. The state directory contains
private keys and must not be committed. There are no provider accounts to configure.

## Qualification

`tests/integration/repository_launcher.py` exercises archive and download rejection,
OS locking, atomic writes, bounded frames, strict invitations, real loopback TLS
enrollment, wrong pins/tokens, exact receiver bytes and authenticated rediscovery.
`tests/integration/desktop_setup.py` separately checks real installation/repeat/race
behavior. Neither opens physical audio devices. The GitHub workflow builds both
desktop targets and runs enrollment tests on each; defining it is not a passing CI run.

Still required before production: native Monterey and newer Mac execution, speaker
and gaming latency measurements, long Wi-Fi sessions, drift correction, certificate
renewal, permissions/clean-host testing and signed distribution. iPhone, SvelteKit
and per-app capture remain separate unfinished work.

## Monterey distribution and GitHub publication

`tools/desktop_release.py` packages prepared native files, both upstream licenses
and a source/target/revision manifest. The desktop workflow builds/tests Windows
and Intel Mac candidates, then stores build artifacts. It does not publish on a
push or pull request. To publish, the maintainer runs **Desktop clone and build**
manually with **publish** enabled. After both target jobs pass, a dedicated job
creates an unsigned **prerelease** tagged `desktop-<full commit SHA>`.

On macOS 12/13, the launcher reads the clone's GitHub origin and exact HEAD. It
requests that specific public release from GitHub, requires the exact target/commit
asset name and GitHub-provided SHA256 digest, and checks the binary file set,
source key, hashes and licenses before executing `help` and publishing its cache.
It never falls back to an unrelated latest build. Private GitHub repositories,
source archives without Git metadata, and unpublished/modified revisions are not
supported by this automatic old-macOS path. A missing candidate is a clear error,
not a successful setup. No candidate has yet been published or run on Monterey.

This removes the need to run the modern compiler on Monterey once a candidate
exists. It does not qualify that binary on Monterey, sign/notarize it, or establish
actual speaker performance. API digests authenticate the download through the
trusted repository/GitHub HTTPS channel, not through an independent signing key.
