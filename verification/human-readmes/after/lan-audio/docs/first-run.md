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
## 2. Pair the computers once

In PowerShell, from the Windows `lan-audio` source directory:

```powershell
python tools/create_pair.py --output "$env:USERPROFILE\LAN-Audio-Pair"
```

This creates `LAN-Audio-Pair` in your Windows user folder. It contains `sender`,
`receiver` and `pair.json`. The helper uses the reviewed OpenSSL executable from
the sibling TLS SDK by default. If using a supplied binary bundle instead, follow
that bundle's instructions for the helper location and `--openssl` path.

- **On Windows:** keep `sender` and put `lan-audio.exe` and both OpenSSL DLLs from
  `zig-out/bin` inside it.
- **On the Mac:** privately transfer only the `receiver` folder. Put the newly
  built Mac `lan-audio` executable inside it. Keep its configuration and identity
  files together.

Each role has its own private `identity.key`. Never use the public test keys from
the source tree. Keep `pair.json` on Windows. Repeating the pairing command checks
the existing pair and preserves edited settings; it does not replace identities.
If creation failed partway through, keep the incomplete folder and choose a new
name for another attempt. Certificates expire after 825 days; create and distribute
a new pair before then.

## 3. Save the Mac's address

Find the Mac's current IPv4 address in its network settings or your router's
connected-device list. It looks like `192.168.1.123`; use your actual address.

On Windows, open `sender/lan-audio.json` in a text editor. Replace just
`RECEIVER_IP` with that address and save the file. For example:

```json
"address": "192.168.1.123"
```

This is one field inside the existing JSON, not a replacement for the whole file.
Keep the generated credentials, fingerprint and `peer_name` unchanged. Keep the
receiver's address as `0.0.0.0`: that means listen on the Mac's local IPv4 interfaces.
If the Mac's address changes later, update the sender file again.

## 4. Validate, then start audio

On the Mac, open Terminal in the **`receiver` folder**:

```sh
chmod 700 ./lan-audio
chmod 600 ./identity.key
./lan-audio validate --config ./lan-audio.json --profile home
./lan-audio run --config ./lan-audio.json --profile home
```

On Windows, open PowerShell in the **`sender` folder**:

```powershell
.\lan-audio.exe validate --config .\lan-audio.json --profile home
.\lan-audio.exe run --config .\lan-audio.json --profile home
```

Run `run` only if validation succeeds. Validation checks settings and compiled
platform support; it does **not** test credentials, networking or sound.
Leave both windows open. Start sound in a game or music app on Windows. The Mac
reports playback starting once it has enough audio buffered. That message confirms
startup, but hearing the correct sound is the next check.

The receiver uses TCP port **46321** by default. Its firewall must allow the
application's incoming LAN connection; LAN Audio does not change firewall settings.
Do not forward this port from the internet.

## Stop and use it again

Press **Ctrl+C once in the Windows sender** to drain and stop both ends. A second
press aborts. Ctrl+C on the receiver aborts locally. Start the receiver again before
starting the sender next time. Unexpected interruptions retry automatically when
recoverable; an intentional clean stop ends the session.

Your configuration stays saved. On later runs, use just the two `run` commands.
Changes to a JSON file take effect after restarting the command. The generated
`Send.ps1` and `Receive.command` are alternative direct-argument launchers; **they
do not read your JSON profiles**. Use `run --config` for the settings in this guide.

<a id="troubleshooting"></a>
## Troubleshooting

| What you see or hear | What to check first |
| --- | --- |
| Command or file not found | Open the terminal in the correct source, `sender` or `receiver` folder for that step. Quote paths containing spaces. |
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
# Windows sender folder
.\lan-audio.exe devices
```

```sh
# Mac receiver folder
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
