# Custom desktop streaming candidate

The Windows command is runnable. Mac build and speaker/Wi-Fi execution remain
unqualified; this is not a production release. iPhone support is still pending.
The current transport is authenticated TCP/TLS with 48 kHz stereo f32 audio, 5 ms
blocks and a default 40 ms receiver prefill. Actual end-to-end delay is unmeasured.

## Windows build

Keep `lan-audio`, `miniaudio-zig` and `tls-zig` as sibling directories. With the
pinned Zig `0.17.0-dev.1859+dcceb318e`:

```powershell
python tools/check_transport.py
zig build app -Doptimize=ReleaseSafe
.\zig-out\bin\lan-audio.exe devices
```

Keep both installed OpenSSL DLLs beside the executable. Help and device inspection
do not start a stream. `zig build run -- help` stages the same required libraries.

## Intel Mac build gate

On the 2019 Intel Mac, use Apple command-line tools, Python 3.9+, Perl/make and the
same pinned Zig. Obtain the OpenSSL 3.5.8 source archive identified by the reviewed
TLS backend lock. The recipe requires this exact SHA-256:

`a8f84a39918ec6415ce765d9b429d313ba97b8143169c172e734b9514464f5b2`

```sh
python3 tools/build_mac_candidate.py \
  --openssl-archive /absolute/path/openssl-3.5.8.tar.gz \
  --output /absolute/path/new-mac-build \
  --zig /absolute/path/zig
```

This is a native build recipe, not a prebuilt Mac binary. It verifies the source,
builds/tests a static SDK, targets `x86_64-macos.12.0`, builds LAN Audio and records
linkage/help results. It does not install software globally or change trust stores.
Keep failed logs; use a new output directory on another attempt. Native compilation
and the resulting executable's behavior on the Mac remain untested here.

## Create one private pair

On Windows, choose an existing parent directory outside the source tree:

```powershell
python tools/create_pair.py --output C:\Users\James\LAN-Audio-Pair
```

The tool prints public fingerprints, not private keys. Keep the sender folder on
Windows; transfer only the receiver folder privately to the Mac. Copy the Windows
executable and both DLLs into sender. After a successful Mac build, copy its
`zig-out/bin/lan-audio` into receiver. Do not use the repository's public test keys.
The issuer signing key is discarded; certificates have a finite lifetime, so
renewal requires a new explicitly distributed pair. Keychain storage is pending.

On the Mac, run `sh Receive.command` from its receiver folder. It listens on port
46321 on IPv4 interfaces and accepts only the approved sender certificate. On
Windows, provide the Mac's numeric Wi-Fi address to the generated launcher:

```powershell
powershell -NoProfile -File C:\Users\James\LAN-Audio-Pair\sender\Send.ps1 -ReceiverAddress 192.168.1.123
```

Replace that example address with the Mac's actual address. Windows captures its
default system-output device; `--device EXACT_NAME` selects a name from `devices`.
A silent playback stream on that endpoint keeps loopback capture active during
idle periods; it does not change volume.
The receiver prints when playback starts. First Ctrl+C on the sender drains and
stops both ends. A second press aborts. Receiver Ctrl+C aborts locally. Run the
receiver again after an intentional clean stop. Interrupted sessions now reconnect
automatically with fresh authentication and stream IDs. A playback starvation
raises the reserve for the next attempt by at least 20 ms, with measured delivery
gaps able to select a larger step, up to 120 ms by default.
`--buffer-ms` sets the starting reserve; `--max-buffer-ms` sets its ceiling (up to
240 ms); `--reconnect off` disables recovery. The application queue separately
allows 10 ms of packet-burst headroom above that reserve ceiling, plus at most one
admitted record before backlog rejection. These flags are available on the
executable directly. `--seconds` limits each sender attempt.

Each attempt prints JSON with frame counts, native faults, starvation, unplayed
frames and cleanup. Ctrl+C cancels retry waiting. Fatal errors exit nonzero. See
[recovery behavior and limits](runtime/network-recovery.md).

No firewall rule or network category is changed automatically. A receiver firewall
must allow the chosen LAN port. Do not forward it from the internet. For the first
two-host qualification, retain final diagnostics and note audible gaps, Mac OS
version and selected devices. Buffer increases can tolerate some arrival variation
but add delay; they do not replace the planned drift/jitter controller.

Declarative startup is available with `lan-audio run --config FILE --profile NAME`.
See [configuration profiles](runtime/configuration.md) for validation, generated pairing templates
and the current capture/platform limits.
