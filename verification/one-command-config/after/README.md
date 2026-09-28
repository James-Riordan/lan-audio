# LAN Audio

Use your **2019 Intel MacBook Pro as speakers for your Windows 10 PC over Wi-Fi**.
No Bluetooth adapter or cloud account is needed. iPhone support is planned.

**Development candidate, not yet production-ready.** The Windows launcher builds
successfully. Native Mac builds, actual Mac sound, gaming latency and sustained
Wi-Fi performance still need testing.

## Clone once. Run the same command each time.

Clone this repository on both computers. No sibling repositories are needed.
Open a terminal inside the cloned `lan-audio` folder on each computer.

**1. Mac first — Terminal:**

```sh
sh start
```

On macOS 12/13, this needs a matching published desktop candidate; **none has
been published yet**. The source compiler requires macOS 14+. If Apple asks to
install developer tools, finish that installation and run the same command again.
On macOS 14+, the first run downloads tools and builds the receiver; wait until
it asks for pairing text.

**2. Windows — PowerShell:**

```powershell
.\start.cmd
```

The first run prepares its own tools and builds the sender. Copy the complete
`LAN1...` text it displays into the Mac's prompt and press **Return**. Pairing
saves automatically. Keep the text private. Allow the apps through the local
network firewall if your OS asks.

**3. Keep both terminal windows open. Play sound on Windows.**

Next time, run the same two commands: Mac first, Windows second. You do not need to
pair again. Press **Ctrl+C on Windows** to stop. Use `--prepare` after either
command to download/build without pairing or starting audio.

Both commands automatically read [lan-audio.launch.json](lan-audio.launch.json).
The supplied settings need no editing. Shared settings and per-computer overrides
use the same schema; repeats preserve pairing and saved audio profiles.
`--help` explains the commands without downloading anything.

Sequoia 15.x clears the compiler requirement, including the reported 15.7.9 Mac.
Native Mac builds and sound still need actual testing.

Need more detail? Read the [setup and troubleshooting guide](docs/first-run.md).

## What to expect

- Captures **all sound on the selected Windows output**, not individual apps/tabs.
- Uses mutually authenticated encryption and 48 kHz stereo float PCM; no lossy
  audio codec. OS/device conversion can still occur.
- Saves identities and settings outside the clone. Repeat runs reuse them.
- Rediscovers the paired Mac on ordinary IPv4 LANs. Guest Wi-Fi or network
  isolation can prevent communication.
- More buffering can cover some network stalls, at the cost of delay. It cannot
  make failing hardware invisible. Sustained clock correction is unfinished.
- The PC must have an available Windows audio output endpoint, even without
  attached speakers. This app does not install a virtual audio device.

The receiver targets Intel macOS 12+; building it from source needs macOS 14+.
The current launchers support Windows x86_64 and Intel Macs. A Mac build recipe
is not proof of Monterey or newer-macOS compatibility. iPhone, a graphical interface,
per-app capture, automatic certificate renewal and signed releases are not ready.

## Find what you need

| I want to… | Read this |
| --- | --- |
| Fix setup, no sound or choppiness | [Setup guide](docs/first-run.md) |
| Change devices or buffering | [Configuration](docs/runtime/configuration.md) |
| Understand downloads, pairing, saved files or declarative setup | [Launcher contract](docs/runtime/repository-launcher.md) |
| Install an already-built app from local pair files | [Advanced desktop setup](docs/runtime/desktop-setup.md) |
| See the latest verified runtime limits | [Runtime results](verification/playout-demand/RESULTS.md) |
| Work on the code | [Developer entry point](docs/implementation/START_HERE.md) |

No license has been selected for project-authored code. Dependencies retain their
own licenses; those do not license the entire application.
