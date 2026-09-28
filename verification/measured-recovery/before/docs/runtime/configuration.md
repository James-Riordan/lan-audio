# Declarative operation profiles

The desktop application accepts a bounded, data-only JSON schema 1 document:

```text
lan-audio validate --config /path/to/lan-audio.json --profile home
lan-audio run --config /path/to/lan-audio.json --profile home
```

`validate` reads the named configuration file and checks syntax, profile selection,
values and compiled platform support. It does not read credentials, open a socket,
enumerate devices or start audio. Its redacted JSON explicitly reports those checks
as false. Success establishes a valid operation request, not connectivity or sound.
`run` sends the same immutable effective settings through the existing foreground
supervisor. Changes to a file take effect only on a new invocation. Ctrl+C retains
the direct command's stop/drain behavior.

## First use

New pairings from `tools/create_pair.py` contain an editable `lan-audio.json` in each
role's folder. In the sender file, replace `RECEIVER_IP` with the Mac's numeric LAN
address. This placeholder deliberately fails validation until configured. Keep the
receiver file and its credentials together on the Mac. Start the receiver first,
then the sender, using the commands above. The receiver's `0.0.0.0` means listen on
local IPv4 interfaces; every connection still requires the approved peer identity.
Existing pairings are never rewritten. Existing direct-argument launchers still work.

Example receiver document (replace the fingerprint with your paired sender's hash):

```json
{
  "schema": 1,
  "defaults": {
    "role": "receive",
    "ca": "ca.pem",
    "cert": "identity.pem",
    "key": "identity.key",
    "peer_fingerprint": "0000000000000000000000000000000000000000000000000000000000000000",
    "buffer_ms": 40,
    "max_buffer_ms": 120,
    "reconnect": true
  },
  "profiles": [
    { "name": "home", "settings": { "address": "0.0.0.0" } },
    { "name": "ipv6", "settings": { "address": "::", "buffer_ms": 60 } }
  ]
}
```

Sender settings use `role: "send"`, the receiver's address/fingerprint,
`peer_name: "lan-audio-receiver"` for the generated certificate, and optionally
`capture: "system_output"`. Its local ca/cert/key references point to the sender
folder. Never copy the sender's private key to the receiver.

## Resolution and bounds

The resolver applies built-in defaults, then document defaults, then the explicitly
named profile's settings. Fields omitted from a profile inherit. False and zero
are assignments; zero is accepted only where the field allows it. There is no null
reset, environment-variable expansion, import, execution, ambient profile search,
or invocation override in `run`. Unknown and duplicate fields, duplicate profile
names and unsupported schema versions are errors. All layers are decoded before
selection; semantic cross-field validation applies to the selected effective profile.

| Field | Effective requirement / default |
| --- | --- |
| `role` | Required: `send` or `receive` |
| `address` | Required numeric IPv4 or IPv6 address, without a port |
| `ca`, `cert`, `key` | Required file references; relative to the resolved configuration file's directory |
| `peer_fingerprint` | Required, 64 hexadecimal SHA-256 characters |
| `peer_name` | Required for send; forbidden for receive |
| `device` | Optional exact current endpoint name; omission uses the system default |
| `port` | 46321; range 1–65535 |
| `buffer_ms` | 40; range 5 through `max_buffer_ms` |
| `max_buffer_ms` | 120; maximum 240 |
| `seconds` | 0 (unlimited); sender only, up to 86400, per attempt |
| `reconnect` | true |
| `capture` | Sender only: `system_output`; other selections fail explicitly |

Document limit: 65,536 bytes, nesting depth 8, decoded values at most 4,096 bytes,
and 1–32 profiles. Names are 1–64 ASCII letters/digits/underscore/hyphen. Numeric
fields require JSON integers, not quoted or fractional values. Strings reject
empty values, control characters and invalid UTF-8. Runtime/native endpoint limits
remain additional acquisition checks.

The parser owns its allocations; resolved strings borrow them. The command retains
the parsed document and arena for the complete supervisor lifetime, including
retries. No config parsing or path resolution happens on callbacks or media workers.
Relative credential references are resolved once. Credentials themselves are still
opened during each authenticated connection; this is not a credential-store snapshot.
Named devices are revalidated at native acquisition and remain nonpersistent selectors.

Pair manifests continue hashing identity files and launchers. Editable operation
profiles are explicitly outside those hashes. Repeating pair creation verifies
immutable custody and preserves profile edits; it does not certify an edited profile
or rotate a key. Validate the profile separately. Older pair manifests remain usable
and are not upgraded in place.

## Capture selection and platform limits

The implemented capture path is Windows system-output loopback. Selecting
`process_tree` or `browser_tab` returns `UnsupportedCaptureSelection` before any
capture; it never silently captures all audio instead. Microsoft documents process
loopback as requiring build 20348 or later in its
[application loopback sample](https://learn.microsoft.com/en-us/samples/microsoft/windows-classic-samples/applicationloopbackaudio-sample/).
This host's Windows 10 build 19045 does not satisfy that requirement. Capturing an
arbitrary browser tab additionally needs a qualified browser/source adapter; a
window title is not an audio source identity. Those adapters are not implemented.

macOS playback remains targeted at Intel macOS 12+, with native compilation and
two-host listening still unqualified. Phone playback, drift correction and a
SvelteKit interface are open work. A future interface should edit/validate these
operation settings and call the same engine; no UI framework is required by the
headless build. JSON schema 1 is an initial transport for application settings, not
a private ZSON evaluator. The broader [configuration design](../design/configuration-resolution.md)
still owns proposed provenance, reset, storage and ecosystem adapters.

## Evidence and failure interpretation

`src/app/config.zig` tests merge determinism, rejection rules and resource bounds.
`tests/integration/configuration.py` independently invokes the installed executable
with multiple profiles, malformed documents, missing credential references and an
occupied loopback listener. The last case proves `run` reaches the chosen receiver
operation without opening native audio. `tests/integration/pairing.py` checks fresh
profile peer hashes and preserves edited config on repeated pairing.

Callback reports now include maximum output request size and the requested,
available and rendered frames at the first guarded starvation. These are plain
callback-owned counters inspected only after fencing. They perform no clock query,
allocation or logging, and do not establish packet arrival or acoustic timing.
The independent recovery peer separately measures maximum send-start gap and send
call duration. Qualification failures remain failures when host scheduling exceeds
the buffer budget; larger buffers also cost latency.
