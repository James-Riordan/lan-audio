# Copied device discovery and the first foreground command

`AudioDevice` and `Catalog` share one backend/profile validation function.
Catalog.discover opens an enumeration context, copies endpoint presentation
metadata into bounded application storage, and releases the context before
returning. It never initializes or starts an audio device. The actual native
library may allocate its own enumeration storage; the application's copied
catalog has a separate 64-entry bound and fails rather than silently truncating.

WASAPI loopback lists playback endpoints because those are the system outputs
being captured. It does not substitute microphone capture devices. Native names
must be nonempty, terminated valid UTF-8; malformed metadata or impossible
pointer/count pairs fail. The returned catalog owns all copied name bytes.
Duplicate names in the same direction are marked unselectable by name, consistent
with AudioDevice's existing exact-name ambiguity rejection.

This is a presentation snapshot, not a persistent endpoint identity. Names and
availability may change; opening performs a new enumeration and format check.
Opaque stable-ID selection and hotplug identity qualification remain C03 work.
The pinned non-null ma_context_uninit implementation releases backend/enum storage
and returns success; changing that upstream lifetime contract requires review.

`src/app/main.zig` is the first foreground executable. Build with `zig build app`
and run the installed `zig-out/bin/lan-audio.exe` on Windows:

```text
lan-audio help
lan-audio version
lan-audio devices
lan-audio devices --json
```

`zig build run -- devices` also passes arguments through the pinned build tool.
The command currently inspects devices only; its help explicitly says streaming
and pairing remain under development. Unknown commands/options fail before
enumeration. Unsupported native platforms return a clear unavailable result.
JSON escapes endpoint text and exposes schema 1 with name/default/ambiguity fields;
plain output replaces ASCII terminal controls in names. No configuration, network
listener, microphone recording or persistent background service is created.

Catalog tests poison native name storage on context release, check duplicate
flags and failure cleanup, then use a real silent-backend name after enumeration
to initialize a fresh stopped AudioDevice. Command smoke checks exercise normal
help/version, invalid arguments and repeated actual Windows enumeration. The
[phase results](../../verification/receiver-platforms/RESULTS.md) distinguish this
native discovery from capture/playback and packaged production qualification.
