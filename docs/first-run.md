# Set up Windows-to-Mac audio

This candidate targets Windows 10 x86_64 and your 2019 Intel MacBook Pro on macOS
12 (Monterey) or newer. **Native Mac execution and actual speaker playback have
not yet been verified.** There is no iPhone receiver yet.

## Before starting

Connect both computers to the same home network and keep the Mac awake, lid open.
Use your usual Mac speaker volume. Windows must expose an audio output device;
LAN Audio does not create a virtual one. Clone this repository on each computer.
No separate miniaudio-zig or tls-zig checkout, SSH setup or key-file copying is needed.

**Monterey/macOS 13: a matching published desktop candidate is required. None is
published yet.** The pinned compiler itself requires macOS 14; building a receiver
with a macOS 12 deployment target does not make that compiler run on Monterey.
The launcher can download an exact-commit candidate after the maintainer publishes
one using the included GitHub workflow. It fails clearly if no matching candidate exists.

<a id="build"></a>
## 1. Run the Mac first

Open Terminal. Type `cd ` (including the space), drag the cloned `lan-audio`
folder from Finder into Terminal, then press Return. Run:

```sh
sh start
```

If Apple opens its Command Line Tools installer, complete it and rerun `sh start`.
The tools must provide Python 3.9 or newer. On macOS 14+, the first source build downloads the
pinned Zig compiler and OpenSSL source, builds/tests OpenSSL and builds the app.
This takes longer than later launches. Leave Terminal open until the pairing prompt.
You do not need Homebrew or administrator access to install LAN Audio itself.

<a id="pair"></a>
## 2. Run Windows and pair once

Open the cloned `lan-audio` folder in File Explorer. Click the address bar, type
`powershell`, and press Enter. In the PowerShell window, run:

```powershell
.\start.cmd
```

This installs private build tools inside the clone and builds the Windows sender.
It does not change your global PATH or persistent PowerShell execution policy.
When Windows displays a line beginning `LAN1.`, select and copy that entire line.
Paste it into the Mac Terminal pairing prompt and press Return. Do not paste the
pairing text into a public chat or issue. It authorizes transfer of this receiver's
private identity. The PC waits up to ten minutes; rerun it if that timer expires.

If Windows Firewall prompts for Python, allow it on your **private/home network**.
If macOS asks to allow incoming connections for Python or lan-audio, allow them.
The temporary pairing listener is TCP 46322 on Windows; receiver discovery is
UDP 46323 on the Mac; encrypted audio uses TCP 46321 on the Mac. The launcher does
not disable firewalls or change router settings. Networks that isolate clients
(such as guest Wi-Fi) will not work for direct audio.

## 3. Play sound

After successful pairing, both commands start their native audio role. Keep both
windows open. Play music or your game on Windows. A connected/playback diagnostic
is useful evidence, but hearing correct sound is the actual first listening check.
No command in this guide has yet been qualified on your physical Mac.

Press **Ctrl+C once on Windows** to stop and drain. A second press aborts. Restart
the Mac command before the next Windows session. Recoverable interruptions retry;
an intentional clean stop ends the session.

## Every later session

In the same source folders, run **`sh start` on the Mac first**, then
**`.\start.cmd` on Windows**. Saved identities are reused. Normally the sender
finds the paired Mac even if its IPv4 address changed. Repeat setup does not rotate
keys. Certificates last 825 days; automatic renewal remains unfinished.

To prepare a computer without opening audio, use `sh start --prepare` or
`.\start.cmd --prepare`. Successful preparation proves a local build, not sound.

## One configuration for both computers

Both commands automatically read `lan-audio.launch.json` beside the launchers.
Leave it as supplied to use automatic setup. You can keep the same document on
Windows and Mac: the launcher selects `windows-x86_64` or `macos-x86_64` itself.
Use `--config FILE` only when you want a different document. `--help` works even
before tools are installed and does not start setup.

For example, this keeps defaults on Windows and asks for 60 ms of initial reserve
on the Mac (more reserve adds delay):

```json
{
  "schema": 1,
  "environments": {
    "windows-x86_64": {},
    "macos-x86_64": {"audio": {"buffer_ms": 60}}
  }
}
```

You may set `audio.device`, `audio.buffer_ms`, `audio.max_buffer_ms` and
`audio.reconnect`. The complete profile is checked by the native app before audio
starts. These overrides affect the current session; they do not rewrite your
saved settings or pair. Remove an override to use the saved value again.

## Saved settings

The editable audio profile is `settings.json` in:

- Windows: `%LOCALAPPDATA%\LAN Audio` (paste this into File Explorer's address bar).
- Mac: `~/Library/Application Support/LAN Audio` (Finder → Go → Go to Folder).

Change settings while both launchers are stopped. Settings survive application
rebuilds. The launcher keeps native binaries in the `releases` subdirectory and
passes them a generated session profile. Avoid editing generated `session.json`.
See [configuration fields](runtime/configuration.md) for device/buffer settings and
[launcher configuration](runtime/repository-launcher.md#discovery-and-settings)
for a declarative state directory or fixed receiver IP. Keep private state out of Git.

<a id="troubleshooting"></a>
## Troubleshooting

| Symptom | Next step |
| --- | --- |
| Command/file not found | Open the terminal in the cloned folder containing `start` and `start.cmd`. |
| Apple developer tools missing | Finish the Apple installation, then rerun `sh start`. |
| Download failed | Check internet access and retry. Never change the expected hash to bypass a mismatch. |
| Already running/preparing | Close the other LAN Audio run using the same checkout/state directory, then retry. A crash releases the lock automatically. |
| Pairing timed out | Leave the Mac at its pairing prompt and rerun Windows; use its new invitation. |
| Pairing stopped after transfer | Rerun the Mac, then Windows; durable paired state can recover through discovery. |
| Paired Mac not found | Start the Mac first, allow incoming LAN traffic, and check both devices are on the same non-guest network. A fixed IP can be set in launcher JSON. |
| Authentication fails | Check both system clocks. Do not edit fingerprints or disable authentication. |
| Connected, no sound | Check Mac volume/default output and the game's Windows output/volume. Windows needs an available output endpoint. |
| Wrong sound | Current capture includes all audio on the selected Windows output. Per-app/tab selection is not implemented. |
| Choppy sound | Stop both ends. In the Mac's settings.json, try changing `defaults.buffer_ms` from 40 to 60, then restart Mac and Windows. This adds delay. Persistent network/device faults still need fixing. |
| Too much delay | Extra buffering adds latency. End-to-end gaming latency and sustained clock correction remain unqualified. |

For a test report, note macOS version, device choices, final diagnostics, audible
gaps and delay. Do not include keys, `link.json`, discovery secrets or invitations.
[Windows runtime evidence](../verification/playout-demand/RESULTS.md) does not
establish Mac speaker performance. [Manual installation](runtime/desktop-setup.md)
remains available for engineers working with explicit build/pair files.
