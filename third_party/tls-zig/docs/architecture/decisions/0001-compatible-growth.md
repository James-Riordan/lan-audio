# ADR 0001: Compatible growth from the working foundations

Status: accepted for this documentation handoff, 2026-09-26.

Problem: the requested final hierarchy must guide implementation without breaking the small working libraries or pretending planned features exist. Existing imports, embedded vectors, package manifests and consumer builds depend on the current paths.

Decision: retain existing source paths, add a deeply indexed docs tree, and place proposed new responsibilities in dedicated src subdirectories when their milestone is implemented. Keep planned files as design cards rather than empty Zig/C stubs. Preserve the QUIC TLS contract fixture byte-for-byte until a real TLS-owned seam replaces it. Keep historical evidence unmodified and publish a dated current receipt.

Alternatives: moving every source file now creates compatibility work without new behavior; leaving an undifferentiated TODO list does not define ownership; generating empty modules can make imports/builds suggest unsupported capability. Neither is selected.

Consequences: some existing core files remain at src root. Future moves require the explicit migration protocol. The target tree is a versioned implementation baseline, not an immutable ideal. Acceptance is current builds/tests, complete baseline file coverage, actionable planned cards and mechanical documentation integrity checks.
