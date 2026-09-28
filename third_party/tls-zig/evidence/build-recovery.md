# Private OpenSSL build recovery

The source is the unmodified official OpenSSL 3.5.8 release archive. Configuration
uses MSYS Perl, the existing Strawberry MinGW GCC 13.2.0 compiler, `mingw64 shared
no-quic no-docs`, and a prefix entirely inside this candidate's `deps` directory.
All builds use one worker. No global tools or configuration were changed.

The first attempt was interrupted during compilation. It was resumed after checking
for surviving workers and removing the interrupted object. The initial MSYS GNU make
driver later became unusually slow. Only task-owned make/compiler processes were
stopped; the final potentially interrupted objects were removed and rebuilt.
The build resumed with native GNU make 4.4.1 and an explicit MSYS shell, using the
same source, configuration, compiler and completed object files. The reproduction
script uses that native driver from the start.

Failed-attempt logs are retained separately from the native driver's final log.
The initial reduced install target also needed generated `apps/CA.pl` and
`apps/tsget.pl` helpers; those explicit generation targets were added to the build
script before resuming installation. No C recompilation or source change was needed.
The interrupted MSYS attempt reported a `child_copy` error and a missing
`apps/openssl.exe`; these are not successful build or test results.

Upstream compilation emitted warnings in `crypto/threads_win.c` (pointer signedness
for `_InterlockedExchange64`) and `crypto/x509/x509_def.c` (discarded const qualifier).
No upstream patch or warning suppression was introduced. The adapter C shim is
compiled separately with `-Wall -Wextra -Werror` during qualification.

The first upstream run under MSYS Perl passed all six TLS configurations but failed
certificate-store cases 202, 204 and 205: the harness used MSYS absolute file URIs
and attempted a colon-containing filename against native Windows OpenSSL. The
test script uses native Strawberry Perl for the final run, selecting the upstream
recipe's own Windows path rules and Windows skip for colon-containing filenames.
It normalizes the generated `configdata.pm` utility import paths to Windows form
(valid under both Perls), preserving its timestamp, and regenerates `util/wrap.pl`
with native Perl. These are generated test-harness files, not OpenSSL source or
compiled-library changes. The source's bundled Text::Template fallback is used;
no Perl modules are installed globally.

The first adapter link selected static `libssl.a` / `libcrypto.a`, so revision 2 now
links the `.dll.a` import archives explicitly. The runtime-version test then caught
Windows loading an existing OpenSSL 3.4.1 DLL from `C:/Windows/System32`, ahead of
the process PATH. Build steps now stage each executable/test DLL alongside copies
of the pinned SDK DLLs. The successful interoperability run checks both loaded
module paths and SHA-256 equality with the SDK. The system DLLs were not modified.

This is a reproducible source/configuration/toolchain procedure. It is not a claim
that a clean rebuild produces byte-identical binaries, because paths and build
timestamps are embedded. `backend-lock.json` records the delivered SDK's exact bytes
after successful build and installation.
