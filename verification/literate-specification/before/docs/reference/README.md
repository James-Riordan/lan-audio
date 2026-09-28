# File reference and review scope

The file index and project chapters cover every currently authored/support file
in `lan-audio`, `miniaudio-zig` and `tls-zig`, plus each installed OpenSSL SDK member
and the preserved miniaudio header/license. Entries name responsibility, callable
surface or document sections, ownership/failure obligations, validation and next
implementation work. `file-index.json` is a navigation index, never an adoption lock.

Read [application files](lan-audio.md), [miniaudio wrapper files](miniaudio-zig.md),
[TLS wrapper files](tls-zig.md), and [upstream SDK assets](upstream-assets.md).
Use the [call-by-call API contracts](api-contracts.md) when editing existing methods.
Generated evidence has a separate [evidence guide](evidence.md); caches and build
outputs are excluded from authored contracts and classified explicitly.

Upstream source remains upstream-owned. File-level inventory, hashes and the adapter
contract do not assert that every miniaudio/OpenSSL implementation line was audited
or proved correct. This local TLS checkout contains the installed SDK; upstream
OpenSSL source/build directories referenced in historical build scripts are absent.
No invented source audit substitutes for fetching, verifying and reviewing a future
upgrade. Never add comments to vendored bytes just to satisfy a documentation count.

Regenerate reference chapters after editing their source-specific contract data in
`tools/reference_contracts.json`, then review the diff. `tools/build_reference.py`
updates navigation, not dependency custody; `tools/check_handoff.py` verifies source
coverage and planned-path validity without mutation. Proposed files are documented
in work packages and must not be confused with current inventory entries.

Per-file extracted declarations/headings are navigation aids, not an AST proof or
guarantee every local variable is explained. Semantic contracts below them own the
important behavior. Source remains authoritative about current implementation;
the work packages explicitly describe intended changes.
