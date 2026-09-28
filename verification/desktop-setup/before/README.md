# LAN Audio

Use another device as your PC's speakers over your local network. The first target
is **Windows 10 → a 2019 Intel MacBook Pro**, with iPhone playback planned.
No Bluetooth adapter is needed.

**Development candidate — not yet a production release.** Windows capture and
authenticated streaming have been tested. The Mac still needs a native build and
a real two-computer listening test.

## What works today?

| Capability | Current status |
| --- | --- |
| Capture Windows system sound | Implemented; physical capture tested |
| Stream audio privately to a paired receiver | Implemented; authenticated transport and recovery tested |
| Play through Intel Mac speakers | Receiver code and macOS 12+ build recipe exist; native build and playback unverified |
| Choose a sound device; save settings in JSON | Implemented |
| Choose individual games, apps or browser tabs | Not implemented; capture currently includes all sound on the selected Windows output |
| iPhone, graphical interface, other native platforms | Not ready |

Audio uses 48 kHz stereo floating-point samples. There is no lossy audio codec in
the stream, but Windows/device conversion may occur. Gaming latency and sustained
Wi-Fi playback have not yet been measured. More buffering can cover some network
delays at the cost of more audio delay; it cannot make a failing network invisible.

## First-time setup

**Start with the [Windows-to-Mac setup guide](docs/first-run.md).** It walks through:

1. Getting a Windows executable and building the Intel Mac receiver.
2. Creating one private pair and putting the correct files on each computer.
3. Saving the Mac's network address in the sender's configuration.
4. Starting the receiver, then the sender, and checking for sound.

There is no finished installer or prebuilt Mac receiver in this source tree.
The guide lists the required tools before asking you to build anything.

## Start audio after setup

Open Terminal **in the Mac's `receiver` folder**:

```sh
./lan-audio run --config ./lan-audio.json --profile home
```

Then open PowerShell **in the PC's `sender` folder**:

```powershell
.\lan-audio.exe run --config .\lan-audio.json --profile home
```

Keep both windows open. Start your game or music on Windows. Press **Ctrl+C once
on Windows** to stop both ends cleanly. Start the receiver again before the next
session. These commands require the files and pairing from the setup guide.

## Find what you need

| I want to… | Read this |
| --- | --- |
| Fix no sound, connection errors or choppiness | [Troubleshooting](docs/first-run.md#troubleshooting) |
| Change devices, buffering or saved profiles | [Configuration reference](docs/runtime/configuration.md) |
| See what has actually been tested | [Latest runtime results and limits](verification/playout-demand/RESULTS.md) |
| Understand or change the code | [Developer entry point](docs/implementation/START_HERE.md) |
| Find design details, tests or file contracts | [Documentation map](docs/README.md) |

## Build and contribute

Keep `lan-audio`, `miniaudio-zig` and `tls-zig` beside each other. Use Zig
`0.17.0-dev.1859+dcceb318e` and the reviewed dependency files. Follow the
[build instructions](docs/first-run.md#build) and [development workflow](docs/development/workflow.md).
Run commands from the `lan-audio` directory unless a guide says otherwise.

No license has been selected for new project-authored code. Upstream dependencies
retain their own licenses; those do not grant a license to the whole application.
