# tls-zig: implementation handoff

Start with docs/README.md and docs/verification/current.md. Existing source contracts are in docs/reference/catalog.md; future file cards and milestone dependencies are in docs/roadmap/README.md.

Preserve the documented public API and byte ownership. Keep implementation claims separate from proposed capabilities. QUIC's vendor/transport.zig is a pinned type-only fixture; TLS records are not a QUIC handshake provider. Do not repin dependencies to conceal a mismatch.

Use the exact compiler in build.zig.zon. Run relevant native tests in Debug and ReleaseSafe, public examples, and the external consumer when its boundary changes. Run python tools/check-models.py and python tools/check-docs.py --self-test; TLS additionally supports --with-sdk. Update source contract hashes only after reviewing the changed source. Current source paths are this project directory; SOURCE-ORIGIN.json describes historical relocation.

Documentation maintenance: edit the relevant file contract and current source inventory together, register added docs in artifact-register.json, and retain historical receipts. Do not generate empty source stubs from planned cards. No protocol algorithm changes are part of the 2026-09-26 documentation increment.
