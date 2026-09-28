# Repeat-safe desktop setup

`tools/setup_desktop.py` installs a built desktop app and one private pairing role.
Windows and Intel macOS use the same installer, configuration schema and native
`start`/`check` commands. **Windows execution is tested; native Mac execution is
still unverified.** This installer does not build the Mac application or make the
current candidate a production release.

## Use it

From the Windows source directory, after building the app, replace the example IP:

```powershell
python tools/setup_desktop.py --create-pair --pair "$env:USERPROFILE\LAN-Audio-Pair" --receiver-address 192.168.1.123
```

This creates or verifies the pair, installs its sender in your `LAN Audio` user
folder, and prints the receiver folder to transfer privately to the Mac. It does
not start audio. The OpenSSL executable comes from the reviewed sibling TLS SDK.

On the Intel Mac, after building the Mac app, run from its source directory:

```sh
python3 tools/setup_desktop.py --pair /absolute/path/to/receiver
```

The default installation is `~/LAN Audio` on both systems. `--application DIR`
selects a built executable/runtime folder instead of this source's `zig-out/bin`.
`--output DIR` selects a different private installation directory. Its parent must
already exist. The installation must be separate from its build and pair inputs.

The printed command starts the installed app. Inside that installation directory,
use `./lan-audio start` on Mac or `.\lan-audio.exe start` in Windows PowerShell.
Use `check` to validate the saved settings without starting audio. Start the Mac
receiver before the Windows sender. Python is not in the running audio path.

## Declarative setup

Save this as a setup JSON file, adjusting the paths and address for your machine:

```json
{
  "schema": 1,
  "create_pair": true,
  "pair": "./private-pair",
  "application": "./lan-audio/zig-out/bin",
  "output": "./installed-sender",
  "receiver_address": "192.168.1.123"
}
```

Then run `python tools/setup_desktop.py --config /path/to/setup.json` from the
source directory. Paths resolve against the setup file, not the working directory.
No environment-variable interpolation or executable configuration is supported.
On the Mac omit `create_pair` and `receiver_address`, set `pair` to the transferred
receiver folder, and set `application` to the native Mac build. Use `python3` there.
All three paths are required in a setup document. Unknown/duplicate JSON fields,
non-boolean `create_pair` and conflicting CLI overrides are rejected.

This setup document is separate from the installed `lan-audio.json`, which controls
audio devices, buffering and profiles. See [operation settings](configuration.md).

## Repeat and recover

Repeating the same setup command verifies the runtime, identity and saved profile.
It preserves existing operational edits byte for byte. `--check` verifies an
existing installation without creating one. If an explicit receiver address differs
from a saved address, setup stops; edit the saved configuration deliberately.

Changed binaries, missing files, altered identities, unrelated destination folders
and conflicting pair inputs are rejected without replacement. For a new app version,
install into a **new directory**, stop the old app, and start the new one. Retain the
old directory if you need to go back. There is no automatic updater or migration yet.

Normal pre-publication errors remove only their own uniquely named private staging
directory. A process kill or power loss can leave a hidden `.NAME.setup-*` or
`.NAME.pair-*` sibling. Such a directory is never treated as installed. A rerun uses
a new stage and preserves the existing published installation/pair. Do not run a
partial staged copy or merge its identities into another pair.

Fresh pair creation now stages and publishes a complete pair. An installation
failure after pair publication retains the complete pair; rerunning reuses it.
Legacy complete `pair.json` records remain verifiable by `create_pair.py`, but the
installer requires the new per-role `identity.json`. Older incomplete folders are
not repaired or replaced implicitly. Use a new explicit pairing path if necessary.

## Implementation and limits

The installer reads a bounded setup document, checks platform and path separation,
checks exact identity-file hashes and certificate fingerprint, and copies a fixed
runtime/identity file set into a private sibling stage. Windows uses a current-user
ACL; POSIX uses a private directory mode. Python's TLS parser verifies that the
private key matches the certificate and that the CA file parses. The actual staged
executable's `check` validates the home operation profile from a different working
directory. Only then does exclusive directory rename publish it. Windows rename
refuses an existing destination. macOS uses `renamex_np` with `RENAME_EXCL`, whose
[Apple contract](https://raw.githubusercontent.com/apple-oss-distributions/xnu/main/bsd/man/man2/rename.2)
rejects an existing target even if empty; the flag and deployment availability are
defined in [Apple's header](https://raw.githubusercontent.com/apple-oss-distributions/xnu/main/bsd/sys/stdio.h).
Unsupported filesystems fail instead of falling back to replacement. A concurrent winner is
verified through the same existing-installation path; it is not overwritten.

Runtime and identity hashes go into `installation.json`; editable operation settings
stay outside those hashes. All profiles must keep the installed role, credential
references and approved peer. Existing installs must match the supplied build/pair
inputs before verification succeeds. No setup operation rewrites an existing app.

This is local integrity checking, **not a signed publisher/authenticity check**.
Supply trusted local builds and privately transferred pairing files. Hostile users
with access to the source inputs or installed private keys are outside this boundary.
Certificate expiration/purpose/peer trust still require the actual TLS connection;
the settings checker does not establish connectivity, sound or acoustic latency.
Filesystem power-loss durability, clean-machine deployment, signing/notarization,
system credential-store integration and native Mac installation remain release gates.
No firewall, PATH, startup service, router or global audio setting is changed.

## Verification

`tests/integration/desktop_setup.py` uses temporary fresh identities and the real
Windows executable. It covers successful/repeated/concurrent installation, edits,
wrong keys, altered files, conflicting destinations, invalid configuration,
relative declarative paths, no-write check mode, and failed pair creation followed
by retry. It proves relocated `check` ignores an unrelated working-directory config.
An occupied loopback port proves `start` reaches the saved receiver operation before
audio acquisition. No captured audio or private test keys are retained.

Run after building the app:

```powershell
python tests/integration/desktop_setup.py
python tests/integration/pairing.py
python tests/integration/configuration.py
```

These Windows checks cannot establish Mac permissions, playback or Wi-Fi behavior.
