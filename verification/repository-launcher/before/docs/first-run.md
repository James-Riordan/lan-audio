# Set up Windows-to-Mac audio

This guide is for a Windows 10 x86_64 PC sending sound to a 2019 Intel MacBook Pro
on the same local network. **The Mac build and real speaker playback still need
testing.** These are candidate setup instructions, not a verified production setup.
There is no iPhone receiver yet.

## Before you start

- Keep both computers awake and connected to the same local network.
- Windows needs an available audio output endpoint, even if no speakers are
  attached. LAN Audio captures the sound sent to that endpoint; it does not create
  a virtual sound device.
- You need a Windows streaming build and an Intel Mac streaming build. If you
  already have both, skip to [pair the computers](#pair). Otherwise, build below.
- Pairing on Windows needs Python 3.9+ and the reviewed OpenSSL executable.

<a id="build"></a>
## 1. Build the application

Keep this directory layout on each computer:

```text
projects/
  lan-audio/
  miniaudio-zig/
  tls-zig/
```

Use the complete reviewed source set, including the TLS SDK files checked by
`tools/check_transport.py`. An arbitrary replacement library or empty sibling
directory will not work. Commands below run from `lan-audio`.

### Windows: PowerShell

Install Python 3.9+ and make the exact Zig compiler
`0.17.0-dev.1859+dcceb318e` available as `zig`. Then:

```powershell
zig version
python tools/check_transport.py
zig build app -j1 -Doptimize=ReleaseSafe
.\zig-out\bin\lan-audio.exe help
```

**Check:** the dependency check and build succeed, and help lists `run` and
`validate`. The executable and its two OpenSSL DLLs are in `zig-out/bin`. Keep
those three files together. If a command fails, fix that failure before continuing.
The dependency check does not download or repair missing SDK files.

### Intel Mac: Terminal

You need Apple command-line tools, Python 3.9+, Perl, make, the **Intel Mac version**
of the same Zig compiler, and the OpenSSL **3.5.8 source archive**. The recipe targets
macOS 12 (Monterey) and later; this target setting is not evidence of runtime support.
The required archive SHA-256 is:

```text
a8f84a39918ec6415ce765d9b429d313ba97b8143169c172e734b9514464f5b2
```

Replace the three paths below with your actual paths. Choose a **new** build-output
directory whose parent already exists:

```sh
python3 tools/build_mac_candidate.py \
  --openssl-archive /absolute/path/openssl-3.5.8.tar.gz \
  --output /absolute/path/new-mac-build \
  --zig /absolute/path/zig
```

The recipe verifies inputs, builds and tests a private static OpenSSL SDK, then
builds LAN Audio and checks linkage and help. It does not install software globally.
It can take a while; command logs are saved in your chosen output directory.

**Check:** all commands finish successfully and `candidate.json` appears in that
output directory. The application is at **`lan-audio/zig-out/bin/lan-audio`**, not
inside the chosen log directory. On failure, keep the logs and use a new output
directory for a later attempt. Do not treat a failed build as ready for pairing.

<a id="pair"></a>
## 2. Install the Windows sender in one command

Find the Mac's numeric IPv4 address in its network settings or your router's device
list. Replace `192.168.1.123` below with that address. From the Windows source
folder, run in PowerShell:

```powershell
python tools/setup_desktop.py --create-pair --pair "$env:USERPROFILE\LAN-Audio-Pair" --receiver-address 192.168.1.123
```

**Check:** setup prints `installed` (or `verified-existing` on a repeat), the
installation directory, the receiver folder to transfer, and your start command.
The default installation is `LAN Audio` inside your Windows user folder.
Setup creates a private pair, fills in the address, copies the required executable
and DLLs, and validates the installed configuration. No manual JSON edit is needed.

Repeating the command verifies the existing installation and keeps your identities
and settings. It never silently replaces them. If setup stops, read the error before
continuing. A finished pair remains reusable if a later installation step fails.
Use a new path for an old incomplete pairing folder; existing folders are preserved.

## 3. Transfer the receiver and install it on the Mac

Privately copy **only `LAN-Audio-Pair/receiver`** to your Mac. Keep the complete
folder, including `identity.json`, its certificates, private key and configuration.
Do not transfer the sender key or use public keys/certificates from the test fixtures.

After the Mac build succeeds, run this in Terminal from the Mac's `lan-audio` source
folder. Replace the path with the actual transferred receiver folder:

```sh
python3 tools/setup_desktop.py --pair /absolute/path/to/receiver
```

**Check:** setup prints `installed` and a start command. It installs into
`LAN Audio` in your Mac home folder, combining your Mac executable with the receiver
identity and settings. No DLL copying or JSON editing is needed on the Mac.
Native execution of this step still needs to be tested on your machine.

For custom paths or repeatable setup JSON, see [desktop setup](runtime/desktop-setup.md).
The defaults are deliberately the same on both OSs. The application currently uses
separate builds for each OS; it does not run the Windows executable on the Mac.

## 4. Start audio

On the Mac, open Terminal and run:

```sh
"$HOME/LAN Audio/lan-audio" start
```

Then on Windows, open PowerShell and run:

```powershell
& "$env:USERPROFILE\LAN Audio\lan-audio.exe" start
```

Leave both windows open. Start sound in a game or music app on Windows. The Mac
reports playback starting once it has enough audio buffered. That message confirms
startup; hearing the correct sound is the next check.

Replace `start` with `check` to validate saved settings without starting audio.
The native checker does **not** test credentials, networking or sound; setup also
checks local identity-file integrity and certificate/key matching.

The receiver uses TCP port **46321** by default. Its firewall must allow the
application's incoming LAN connection; LAN Audio does not change firewall settings.
Do not forward this port from the internet.

## Stop and use it again

Press **Ctrl+C once in the Windows sender** to drain and stop both ends. A second
press aborts. Ctrl+C on the receiver aborts locally. Start the receiver again before
starting the sender next time. Unexpected interruptions retry automatically when
recoverable; an intentional clean stop ends the session.

Your settings stay in the installed `LAN Audio/lan-audio.json`. Changes take effect
after restarting the command. If the Mac's address changes, edit the sender's
`home` profile address in that file. Use `check`, then restart. Pair certificates
expire after 825 days; renewal requires a new explicitly distributed pair.

Older generated `Send.ps1` and `Receive.command` launchers use direct arguments and
**do not read JSON profiles**. Use `start` for the installed settings in this guide.

<a id="troubleshooting"></a>
## Troubleshooting

| What you see or hear | What to check first |
| --- | --- |
| Command or file not found | Open the terminal in the correct source or installed `LAN Audio` folder for that step. Quote paths containing spaces. |
| Missing DLL on Windows | Keep both built OpenSSL DLLs beside `lan-audio.exe`. |
| Validation fails | Replace `RECEIVER_IP`, use profile `home`, and check JSON punctuation. Addresses must be numeric, not computer names. |
| Connection never starts | Start the receiver first; check the Mac's current address, TCP port 46321, firewall and whether the Wi-Fi network isolates devices. |
| Authentication fails | Check both computers' clocks and use the sender and receiver from the same pair. Do not edit fingerprints to bypass the failure. |
| Connected, but no sound | Check Mac volume/output and the Windows app's volume/output. Run `devices` as shown below. Windows must have an output endpoint available. |
| Wrong sound is captured | Capture includes all sound on the selected Windows output. Individual app/tab selection is not available. |
| Choppy sound | Try `"buffer_ms": 60` in the receiver file's existing `defaults`, then restart both ends. More buffering adds delay; repeated network stalls or device faults still need fixing. |
| Sound arrives too late | Raising the buffer will add more delay. Check the network and selected devices first; end-to-end gaming latency and clock-drift correction remain open work. |

To list output devices without starting an audio stream:

```powershell
# Windows installed LAN Audio folder
.\lan-audio.exe devices
```

```sh
# Mac installed LAN Audio folder
./lan-audio devices
```

By default each role uses its system's default output. To choose another, add
`"device": "EXACT_NAME_FROM_THE_LIST"` to that role's profile `settings` object,
with the required JSON comma. See the [configuration reference](runtime/configuration.md)
for all fields, profiles and buffer limits. The receiver starts at 40 ms reserve
and may increase it after starvation, up to 120 ms by default. This is not a total
latency measurement; [recovery behavior](runtime/network-recovery.md) explains the limits.

For a first Mac test, save the final terminal diagnostics and note the macOS
version, selected devices, audible gaps and delay. Keep private keys out of reports.
The [runtime results](../verification/playout-demand/RESULTS.md) describe the existing
Windows and simulated-peer checks; they do not establish Mac speaker performance.
