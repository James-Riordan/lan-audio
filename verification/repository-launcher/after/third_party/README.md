# Reviewed dependencies

These are immutable copies of the dependency source package preserved with
application receipt `3846d5ec05d5ea1bef312153fc6e3a691f99b3e94828ceee46106ed9a4bbfaf5`.
`lock.json` records every copied file. `transport-lock.json` retains the exact
previously adopted TLS digests; only its location changed. The 1,030 files include
the reviewed Windows OpenSSL SDK, upstream licenses and **public test credentials**.
Those credentials are never used for pairing or real audio.

Library development remains owned by miniaudio-zig and tls-zig. Make changes in
those projects, review an explicit new snapshot, then update these copies and
their custody records together. Do not edit copies to conceal upstream drift.
The launcher verifies the complete snapshot before building. A clone needs no
sibling checkout. Neither this manifest nor a hash alone authenticates a publisher;
trust the source repository before running its code.
