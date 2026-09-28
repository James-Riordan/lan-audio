# One-command declarative launch increment

The user reports Sequoia 15.7.9 on the 2019 Intel MacBook Pro. This meets the
pinned compiler's macOS 14 minimum; it selects the direct source-build branch.
That selection is unit-tested. No access to the physical Mac occurred.

Implemented automatic checkout-relative lan-audio.launch.json selection, common
and per-target configuration, strict validation of every environment, fieldwise
audio overrides, preservation of saved profiles and native validation of the
complete effective session before discovery/audio. The same command is used for
first preparation and later sessions. Both shell help entry points now work with
only the launcher files present, without prerequisite setup/downloads or writes.

Enrollment additionally supports TLS1.2 restricted to ECDHE/ECDSA AES-GCM for
Python providers without TLS1.3, while capable peers negotiate TLS1.3. Exact leaf
pin checking still precedes bearer-token transmission. Native audio remains
TLS1.3 and its code/dependency pins were not changed. This is an explicit control-
plane compatibility policy, not a silent weakening of the native media channel.

Qualification:
- Standalone Windows build and repeat preparation: passed.
- Final isolated campaign: 28 tests, passed, no skips. Includes real native
  session acceptance/rejection, exact settings preservation, both enrollment TLS
  versions, original negative pin/token cases, configuration merge/rejection and
  Sequoia branch selection. Initial root campaign had one skipped native-install
  check before rebuilding; that initial output is retained.
- Windows and POSIX shell help from script-only temporary directories: passed,
  no filesystem changes. POSIX help used Git's shell on Windows, not macOS.
- 182 application reference/link/contract entries: passed.
- 188 TLS custody entries and staged DLL hashes: passed.

The just-qualified standalone build was adopted into the root cache only after
matching all source/build inputs participating in its source key. Root --prepare
then reused it and automatically selected the shipped configuration.

Still unexecuted: native Sequoia build/permissions, actual Apple Python-provider
interoperability, real Mac speakers, Wi-Fi latency/endurance, GitHub publication,
GUI/mobile and certificate renewal. OS consent and the first trusted invitation
transfer still require the user. No personal pair, firewall policy, global tool
installation or audio stream was created by this qualification.
