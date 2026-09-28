# tls-zig: granular file contracts

Generated from reviewed `tools/reference_contracts.json`. Edit the contract data, then render; do not edit this chapter alone.


<a id="file-backend-lock-json"></a>

## `backend-lock.json`

**Responsibility.** Exact Windows SDK artifacts and build provenance/tool identities.

**Contract and ownership.** The 166 SDK files are adopted inputs; target/tool/source metadata describes the recorded build, not a guarantee of current upstream support or signatures.

**Failure/change obligations.** Preserve exact error/custody/lifetime semantics and old users. Unexpected failures remain failures; a passing local test is not cross-platform or whole-library security certification.

**Verification.** Generic Engine/Driver tests, independent SSL/TCP consumers, exact backend/runtime checks and relevant source hashes; rerun only affected gates.

**Next actionable work.** WP01 records Mac SDK separately and retains the Windows lock; review all changed imports/provenance.

**Declared surface / navigation:** `backend`; `target`; `zig`; `compiler`; `source`; `openssl_version_a`; `sdk_root`; `sdk_files`; `build_tools`.


<a id="file-build-zig"></a>

## `build.zig`

**Responsibility.** Build Zig/C TLS wrapper against the explicit private Windows OpenSSL SDK and stage matching DLLs.

**Contract and ownership.** Target and optimization flow to every dependent artifact. Compile steps are distinct from execution; do not open devices or network as an implicit build action.

**Failure/change obligations.** Wrong targets, missing SDK/runtime and ABI/link mismatches must fail. A successful cached compile does not prove execution or correct runtime search paths.

**Verification.** Run owning native tests and independent downstream consumer after graph changes; inspect staged imports and target identity.

**Next actionable work.** WP01 extends native platform build qualification; preserve existing public module names and callback/test separation.

**Declared surface / navigation:** `staged`; `build`; `std`; `files`; `target`; `optimize`; `openssl`; `mod`; `test_mod`; `test_exe`; `tests`; `host_test_mod`; `host_test_exe`; `host_tests`; `exe`; `run`; `interop_mod`; `interop_lib`; `interop`.


<a id="file-build-zig-zon"></a>

## `build.zig.zon`

**Responsibility.** Own package identity, version/compiler floor, dependency declarations and distribution allowlist.

**Contract and ownership.** ZON is Zig package metadata, distinct from ZSON. Fingerprint is identity, not artifact integrity. Sibling paths are development dependencies and require a release closure.

**Failure/change obligations.** Do not silently rename identities or raise compiler floor; changes need compatibility and clean-checkout evidence. Excluded source/docs must not break packages.

**Verification.** Parse/build with pinned compiler; test package allowlist and downstream import from a clean layout.

**Next actionable work.** WP09 replaces development-only assumptions with reproducible source/package custody and includes all required handoff documents.


<a id="file-checkpoint-md"></a>

## `CHECKPOINT.md`

**Responsibility.** Historical engineering context: TLS current checkpoint — September 14, 2026.

**Contract and ownership.** Dated workflow/evidence observations; never independent authorization to execute commands or change unrelated repositories.

**Failure/change obligations.** Do not duplicate conflicting protocol/API meaning or imply unexecuted platform support. Preserve useful history and label superseded claims rather than erasing evidence.

**Verification.** Validate local navigation and file index, compare referenced source behavior and evidence dates/hashes; prose quality requires review beyond automated checks.

**Next actionable work.** Read the declared sections below; update this guide whenever its owned contract changes and link to granular implementation/verification obligations.

**Declared surface / navigation:** `TLS current checkpoint — September 14, 2026`; `Completed usable increment`; `Snapshot adopted by Zap`; `2026-09-15 bounded continuation: peer probe 0.1.4`; `2026-09-15 subsequent Zap adoption confirmed`.


<a id="file-evidence-build-recovery-md"></a>

## `evidence/build-recovery.md`

**Responsibility.** Historical engineering context: Private OpenSSL build recovery.

**Contract and ownership.** Dated workflow/evidence observations; never independent authorization to execute commands or change unrelated repositories.

**Failure/change obligations.** Do not duplicate conflicting protocol/API meaning or imply unexecuted platform support. Preserve useful history and label superseded claims rather than erasing evidence.

**Verification.** Validate local navigation and file index, compare referenced source behavior and evidence dates/hashes; prose quality requires review beyond automated checks.

**Next actionable work.** Read the declared sections below; update this guide whenever its owned contract changes and link to granular implementation/verification obligations.

**Declared surface / navigation:** `Private OpenSSL build recovery`.


<a id="file-evidence-source-provenance-json"></a>

## `evidence/source-provenance.json`

**Responsibility.** Historical upstream archive/configuration and build-recovery provenance.

**Contract and ownership.** Records URLs/hashes/config and explicitly absent signature verification. Historical support/date fields require fresh review before release claims.

**Failure/change obligations.** Preserve exact error/custody/lifetime semantics and old users. Unexpected failures remain failures; a passing local test is not cross-platform or whole-library security certification.

**Verification.** Generic Engine/Driver tests, independent SSL/TCP consumers, exact backend/runtime checks and relevant source hashes; rerun only affected gates.

**Next actionable work.** WP01/WP09 retain it, add new target/release provenance and verify source availability before rebuilding.

**Declared surface / navigation:** `release`; `make_url`; `signature_verification`; `checked_at`; `source_url`; `configure`; `support_until`; `make_checksum_source`; `make_sha256`; `release_date`; `source_sha256`; `final_make`; `build_note`; `source_checksum_url`; `official_downloads_url`; `release_policy_url`.


<a id="file-examples-consumer-build-zig"></a>

## `examples/consumer/build.zig`

**Responsibility.** Separately built downstream TLS package consumer.

**Contract and ownership.** Imports exported tls module and owns Windows Winsock C shim/linking; stages matching private runtime.

**Failure/change obligations.** Preserve exact error/custody/lifetime semantics and old users. Unexpected failures remain failures; a passing local test is not cross-platform or whole-library security certification.

**Verification.** Generic Engine/Driver tests, independent SSL/TCP consumers, exact backend/runtime checks and relevant source hashes; rerun only affected gates.

**Next actionable work.** WP01 adds target-aware external consumers as needed to catch missing transitive link propagation.

**Declared surface / navigation:** `build`; `std`; `target`; `optimize`; `dep`; `mod`; `exe`.


<a id="file-examples-consumer-build-zig-zon"></a>

## `examples/consumer/build.zig.zon`

**Responsibility.** Consumer package identity and relative library dependency.

**Contract and ownership.** Separate package boundary tests exported metadata/imports rather than direct source inclusion.

**Failure/change obligations.** Preserve exact error/custody/lifetime semantics and old users. Unexpected failures remain failures; a passing local test is not cross-platform or whole-library security certification.

**Verification.** Generic Engine/Driver tests, independent SSL/TCP consumers, exact backend/runtime checks and relevant source hashes; rerun only affected gates.

**Next actionable work.** Retain clean consumer qualification when changing root build metadata.


<a id="file-examples-consumer-main-zig"></a>

## `examples/consumer/main.zig`

**Responsibility.** Real TCP client/server and early-response demonstration host.

**Contract and ownership.** Own socket/Driver/cancellation thread and bounded response storage; public fixtures, frozen clock and demo flags are test policy. Maintain early-response ciphertext custody and shared shutdown deadline.

**Failure/change obligations.** Preserve exact error/custody/lifetime semantics and old users. Unexpected failures remain failures; a passing local test is not cross-platform or whole-library security certification.

**Verification.** Generic Engine/Driver tests, independent SSL/TCP consumers, exact backend/runtime checks and relevant source hashes; rerun only affected gates.

**Next actionable work.** Use as behavioral reference for WP03, not a source of production HTTP, address or credential defaults.

**Declared surface / navigation:** `demo_open`; `demo_accept`; `demo_close`; `demo_send`; `demo_recv`; `demo_poll`; `demo_now`; `demo_name`; `demo_client_ca`; `demo_sleep`; `demo_setting`; `send`; `recv`; `run`; `cancelLater`; `main`; `upload`; `serve`; `std`; `tls`; `Network`; `len`; `n`; `result`; `now`; `started`; `cancel_ms`; `close_deadline`; `deadline`; `progress`; `request_deadline`; `reply`; `response_deadline`; `end`.


<a id="file-examples-consumer-socket-c"></a>

## `examples/consumer/socket.c`

**Responsibility.** Windows demonstration socket adapter shared by the current audio probe.

**Contract and ownership.** Loopback-only connect/listen, nonblocking poll, forced 7-byte sends and 113-byte receives; returns explicit would-block and owns WSA/socket cleanup.

**Failure/change obligations.** Preserve exact error/custody/lifetime semantics and old users. Unexpected failures remain failures; a passing local test is not cross-platform or whole-library security certification.

**Verification.** Generic Engine/Driver tests, independent SSL/TCP consumers, exact backend/runtime checks and relevant source hashes; rerun only affected gates.

**Next actionable work.** WP03 creates real platform adapters. Modifying this pinned shared fixture requires explicit transport-lock adoption and all consumers retested.

**Declared surface / navigation:** `demo_accept`; `demo_open`; `demo_close`; `demo_send`; `demo_recv`; `demo_poll`; `demo_sleep`; `demo_setting`; `demo_now`.


<a id="file-examples-roundtrip-zig"></a>

## `examples/roundtrip.zig`

**Responsibility.** Minimal serialized TLS example under public test credentials.

**Contract and ownership.** Shows Engine pumping and authenticated data/close; never supplies production pairing, sockets or trust-store policy.

**Failure/change obligations.** Preserve exact error/custody/lifetime semantics and old users. Unexpected failures remain failures; a passing local test is not cross-platform or whole-library security certification.

**Verification.** Generic Engine/Driver tests, independent SSL/TCP consumers, exact backend/runtime checks and relevant source hashes; rerun only affected gates.

**Next actionable work.** Retain as generic library consumer; do not turn it into the audio product entry point.

**Declared surface / navigation:** `pump`; `main`; `std`; `tls`; `n`; `request`; `response`.


<a id="file-handoff-shutdown-md"></a>

## `HANDOFF-shutdown.md`

**Responsibility.** Historical engineering context: Shutdown correction — September 13, 2026.

**Contract and ownership.** Dated workflow/evidence observations; never independent authorization to execute commands or change unrelated repositories.

**Failure/change obligations.** Do not duplicate conflicting protocol/API meaning or imply unexecuted platform support. Preserve useful history and label superseded claims rather than erasing evidence.

**Verification.** Validate local navigation and file index, compare referenced source behavior and evidence dates/hashes; prose quality requires review beyond automated checks.

**Next actionable work.** Read the declared sections below; update this guide whenever its owned contract changes and link to granular implementation/verification obligations.

**Declared surface / navigation:** `Shutdown correction — September 13, 2026`.


<a id="file-handoff-tcp-consumer-md"></a>

## `HANDOFF-tcp-consumer.md`

**Responsibility.** Historical engineering context: Separate consumer over TCP — September 14, 2026.

**Contract and ownership.** Dated workflow/evidence observations; never independent authorization to execute commands or change unrelated repositories.

**Failure/change obligations.** Do not duplicate conflicting protocol/API meaning or imply unexecuted platform support. Preserve useful history and label superseded claims rather than erasing evidence.

**Verification.** Validate local navigation and file index, compare referenced source behavior and evidence dates/hashes; prose quality requires review beyond automated checks.

**Next actionable work.** Read the declared sections below; update this guide whenever its owned contract changes and link to granular implementation/verification obligations.

**Declared surface / navigation:** `Separate consumer over TCP — September 14, 2026`.


<a id="file-host-driver-md"></a>

## `HOST-DRIVER.md`

**Responsibility.** Authoritative scoped guide: Nonblocking TLS host driver.

**Contract and ownership.** Keep terminology, existing versus proposed behavior, source paths and acceptance claims synchronized with the owning implementation/work package.

**Failure/change obligations.** Do not duplicate conflicting protocol/API meaning or imply unexecuted platform support. Preserve useful history and label superseded claims rather than erasing evidence.

**Verification.** Validate local navigation and file index, compare referenced source behavior and evidence dates/hashes; prose quality requires review beyond automated checks.

**Next actionable work.** Read the declared sections below; update this guide whenever its owned contract changes and link to granular implementation/verification obligations.

**Declared surface / navigation:** `Nonblocking TLS host driver`; `Early-response probe (0.1.4)`.


<a id="file-readme-md"></a>

## `README.md`

**Responsibility.** Authoritative scoped guide: tls-zig revision 2 — private OpenSSL 3.5.8 backend.

**Contract and ownership.** Keep terminology, existing versus proposed behavior, source paths and acceptance claims synchronized with the owning implementation/work package.

**Failure/change obligations.** Do not duplicate conflicting protocol/API meaning or imply unexecuted platform support. Preserve useful history and label superseded claims rather than erasing evidence.

**Verification.** Validate local navigation and file index, compare referenced source behavior and evidence dates/hashes; prose quality requires review beyond automated checks.

**Next actionable work.** Read the declared sections below; update this guide whenever its owned contract changes and link to granular implementation/verification obligations.

**Declared surface / navigation:** `tls-zig revision 2 — private OpenSSL 3.5.8 backend`; `Run`; `Separate TCP consumer`; `Verified current source results`; `Host contract`; `Supported profile and limits`; `Design evidence and primary references`.


<a id="file-source-origin-json"></a>

## `SOURCE-ORIGIN.json`

**Responsibility.** Historical relocation provenance for an earlier TLS checkout.

**Contract and ownership.** Its source/target paths and status are dated observations; current user-selected source is C:/Projects/tls-zig.

**Failure/change obligations.** Preserve exact error/custody/lifetime semantics and old users. Unexpected failures remain failures; a passing local test is not cross-platform or whole-library security certification.

**Verification.** Generic Engine/Driver tests, independent SSL/TCP consumers, exact backend/runtime checks and relevant source hashes; rerun only affected gates.

**Next actionable work.** Preserve history; do not move repositories or assume old paths are active instructions.

**Declared surface / navigation:** `schema`; `id`; `source`; `target`; `status`; `source_retained`; `observed_utc`; `selection`; `verification_evidence`; `selection_status`.


<a id="file-src-backend-c"></a>

## `src/backend.c`

**Responsibility.** C implementation of TLS 1.3 using OpenSSL, memory BIOs and owned write/ALPN storage.

**Contract and ownership.** SSL_get_error immediately follows the SSL call. Initialize/free resources once; reject encrypted key prompting, certificate/ALPN mismatch and raw EOF. BIO/write buffers are bounded but OpenSSL total allocations are not. Shutdown preserves peer final plaintext.

**Failure/change obligations.** Preserve exact error/custody/lifetime semantics and old users. Unexpected failures remain failures; a passing local test is not cross-platform or whole-library security certification.

**Verification.** Generic Engine/Driver tests, independent SSL/TCP consumers, exact backend/runtime checks and relevant source hashes; rerun only affected gates.

**Next actionable work.** WP01 changes build/platform integration only unless a demonstrated API issue requires a separately tested backend change. Keep generic HTTP compatibility.

**Declared surface / navigation:** `no_password`; `select_alpn`; `info`; `result`; `tz_free`; `tz_handshake`; `tz_feed`; `tz_drain`; `tz_read`; `tz_write`; `tz_flush`; `tz_shutdown`; `tz_eof`; `tz_verify_error`; `tz_reason`; `tz_alert`.


<a id="file-src-backend-h"></a>

## `src/backend.h`

**Responsibility.** Small stable C ABI including old HTTP-default constructor and configurable ALPN constructor.

**Contract and ownership.** Status integers, pointer optionality, sizes and ownership must agree exactly with backend.zig and the C implementation.

**Failure/change obligations.** Preserve exact error/custody/lifetime semantics and old users. Unexpected failures remain failures; a passing local test is not cross-platform or whole-library security certification.

**Verification.** Generic Engine/Driver tests, independent SSL/TCP consumers, exact backend/runtime checks and relevant source hashes; rerun only affected gates.

**Next actionable work.** For ABI changes update C/Zig/ctypes consumers together and add independent compatibility tests; preserve old constructor behavior.

**Declared surface / navigation:** `tz_free`; `tz_handshake`; `tz_feed`; `tz_drain`; `tz_read`; `tz_write`; `tz_flush`; `tz_shutdown`; `tz_eof`; `tz_verify_error`; `tz_reason`; `tz_alert`.


<a id="file-src-backend-zig"></a>

## `src/backend.zig`

**Responsibility.** Manually maintained Zig extern mirror of backend.h.

**Contract and ownership.** Opaque Engine pointers have one owner; c_int/c_long/c_ulong/usize types follow target C ABI. Do not assume Windows C long width on Mac.

**Failure/change obligations.** Preserve exact error/custody/lifetime semantics and old users. Unexpected failures remain failures; a passing local test is not cross-platform or whole-library security certification.

**Verification.** Generic Engine/Driver tests, independent SSL/TCP consumers, exact backend/runtime checks and relevant source hashes; rerun only affected gates.

**Next actionable work.** WP01 explicitly validates Darwin ABI widths/signatures and links an external C/Zig consumer.

**Declared surface / navigation:** `tz_new`; `tz_new_with_alpn`; `tz_free`; `tz_handshake`; `tz_feed`; `tz_drain`; `tz_read`; `tz_write`; `tz_flush`; `tz_shutdown`; `tz_eof`; `tz_verify_error`; `tz_reason`; `tz_alert`; `tz_version`; `tz_engine`.


<a id="file-src-driver-zig"></a>

## `src/driver.zig`

**Responsibility.** One-owner nonblocking TLS/transport scheduler with bounded byte custody.

**Contract and ownership.** Transport send null means would-block and zero fails; receive zero means EOF. beginRead borrows output until final result; beginWrite copies into Engine. step performs bounded driver work, preserves suffixes and absolute deadlines. probePeer preserves pending ciphertext; only cancellation flag is shared.

**Failure/change obligations.** Preserve exact error/custody/lifetime semantics and old users. Unexpected failures remain failures; a passing local test is not cross-platform or whole-library security certification.

**Verification.** Generic Engine/Driver tests, independent SSL/TCP consumers, exact backend/runtime checks and relevant source hashes; rerun only affected gates.

**Next actionable work.** WP03 supplies real cross-platform socket hosts; WP04 must use fresh times, cancellation wake and ownership joins instead of concurrent Engine access.

**Declared surface / navigation:** `init`; `deinit`; `cancel`; `abort`; `check`; `idle`; `begin`; `beginHandshake`; `beginWrite`; `beginRead`; `beginShutdown`; `beginFlush`; `probePeer`; `step`; `std`; `tls`; `Transport`; `Error`; `Result`; `ProbeResult`; `Driver`; `Operation`; `r`; `n`; `op`; `progress`; `bytes`.


<a id="file-src-root-zig"></a>

## `src/root.zig`

**Responsibility.** Public Engine API, validation, error/progress translation and ownership.

**Contract and ownership.** Config strings/ALPN are copied/consumed during init; Engine is move-only and serialized. tick enforces monotonic handshake time, queuePlaintext owns a nonempty <=16 KiB block, feed/drain preserve exact prefixes, shutdown distinguishes unread final plaintext from authenticated closure. cancel/deinit are idempotent.

**Failure/change obligations.** Preserve exact error/custody/lifetime semantics and old users. Unexpected failures remain failures; a passing local test is not cross-platform or whole-library security certification.

**Verification.** Generic Engine/Driver tests, independent SSL/TCP consumers, exact backend/runtime checks and relevant source hashes; rerun only affected gates.

**Next actionable work.** WP01 preserves API semantics across native platforms. Peer policy belongs to the product; do not weaken name/CA/ALPN validation or deadlines.

**Declared surface / navigation:** `init`; `ptr`; `live`; `status`; `tick`; `handshake`; `feedRecords`; `drainRecords`; `readPlaintext`; `queuePlaintext`; `flushPlaintext`; `shutdown`; `transportEof`; `diagnostics`; `cancel`; `deinit`; `backendVersion`; `std`; `c`; `host`; `Driver`; `Error`; `Progress`; `Transfer`; `Role`; `Identity`; `Config`; `Diagnostics`; `Engine`; `deadline`; `value`; `h`; `p`; `alert`.


<a id="file-tests-driver-zig"></a>

## `tests/driver.zig`

**Responsibility.** Eleven host-driver tests including prefix custody, probing, deadlines and cancellation.

**Contract and ownership.** Fake transports inject would-block, short I/O, invalid counts and raw EOF; snapshots ensure unsent data/deadline stay unchanged.

**Failure/change obligations.** Preserve exact error/custody/lifetime semantics and old users. Unexpected failures remain failures; a passing local test is not cross-platform or whole-library security certification.

**Verification.** Generic Engine/Driver tests, independent SSL/TCP consumers, exact backend/runtime checks and relevant source hashes; rerun only affected gates.

**Next actionable work.** Add real host cancellation/reconnect cases in product tests while preserving these independent generic contracts.

**Declared surface / navigation:** `transport`; `send`; `recv`; `init`; `deinit`; `handshake`; `finish`; `probe`; `std`; `tls`; `expect`; `equal`; `expectError`; `Result`; `Pipe`; `Socket`; `pipe`; `n`; `Pair`; `result`; `start`; `end`; `ciphertext`; `early`; `r`; `first`; `second`; `calls`; `sends`; `recvs`; `peer probe observes early response without changing blocked ciphertext or deadline`; `peer probe during blocked write honors cancel deadline and raw EOF`; `idle probe output flush preserves order before next application write`; `host driver preserves partial writes and received suffixes across reads`; `host shutdown preserves deadline across final plaintext reads and rejects raw EOF`; `host operation deadline expires despite slow transport progress`; `atomic cancellation stops blocked reads and writes without touching transport`; `host cannot extend a shutdown deadline by switching to read`; `host rejects invalid transport counts and backward clocks`; `host authentication failure flushes fragmented alert and retains diagnostics`; `host raw EOF during handshake is terminal even when alert delivery blocks`.


<a id="file-tests-fixtures-ca-pem"></a>

## `tests/fixtures/ca.pem`

**Responsibility.** Public test certificate for trusted fixture authority.

**Contract and ownership.** Fixture bytes belong only to bounded local tests; identity, validity and key/certificate relationships are deliberate negative/positive inputs.

**Failure/change obligations.** Never deploy, copy into a product trust store or silently regenerate. Do not print private-key contents in diagnostics even though these fixtures are public.

**Verification.** tools/make_fixtures.py documents generation; TLS and independent peers check the corresponding auth/expiry/purpose case; downstream transport lock covers adopted bytes.

**Next actionable work.** WP03 provisions separate real credentials and rejects fixture defaults; deliberate fixture regeneration needs reviewed hashes and regression evidence.


<a id="file-tests-fixtures-client-key"></a>

## `tests/fixtures/client.key`

**Responsibility.** Public test private-key material for client authentication identity.

**Contract and ownership.** Fixture bytes belong only to bounded local tests; identity, validity and key/certificate relationships are deliberate negative/positive inputs.

**Failure/change obligations.** Never deploy, copy into a product trust store or silently regenerate. Do not print private-key contents in diagnostics even though these fixtures are public.

**Verification.** tools/make_fixtures.py documents generation; TLS and independent peers check the corresponding auth/expiry/purpose case; downstream transport lock covers adopted bytes.

**Next actionable work.** WP03 provisions separate real credentials and rejects fixture defaults; deliberate fixture regeneration needs reviewed hashes and regression evidence.


<a id="file-tests-fixtures-client-pem"></a>

## `tests/fixtures/client.pem`

**Responsibility.** Public test certificate for client authentication identity.

**Contract and ownership.** Fixture bytes belong only to bounded local tests; identity, validity and key/certificate relationships are deliberate negative/positive inputs.

**Failure/change obligations.** Never deploy, copy into a product trust store or silently regenerate. Do not print private-key contents in diagnostics even though these fixtures are public.

**Verification.** tools/make_fixtures.py documents generation; TLS and independent peers check the corresponding auth/expiry/purpose case; downstream transport lock covers adopted bytes.

**Next actionable work.** WP03 provisions separate real credentials and rejects fixture defaults; deliberate fixture regeneration needs reviewed hashes and regression evidence.


<a id="file-tests-fixtures-expired-key"></a>

## `tests/fixtures/expired.key`

**Responsibility.** Public test private-key material for deliberately expired server identity.

**Contract and ownership.** Fixture bytes belong only to bounded local tests; identity, validity and key/certificate relationships are deliberate negative/positive inputs.

**Failure/change obligations.** Never deploy, copy into a product trust store or silently regenerate. Do not print private-key contents in diagnostics even though these fixtures are public.

**Verification.** tools/make_fixtures.py documents generation; TLS and independent peers check the corresponding auth/expiry/purpose case; downstream transport lock covers adopted bytes.

**Next actionable work.** WP03 provisions separate real credentials and rejects fixture defaults; deliberate fixture regeneration needs reviewed hashes and regression evidence.


<a id="file-tests-fixtures-expired-pem"></a>

## `tests/fixtures/expired.pem`

**Responsibility.** Public test certificate for deliberately expired server identity.

**Contract and ownership.** Fixture bytes belong only to bounded local tests; identity, validity and key/certificate relationships are deliberate negative/positive inputs.

**Failure/change obligations.** Never deploy, copy into a product trust store or silently regenerate. Do not print private-key contents in diagnostics even though these fixtures are public.

**Verification.** tools/make_fixtures.py documents generation; TLS and independent peers check the corresponding auth/expiry/purpose case; downstream transport lock covers adopted bytes.

**Next actionable work.** WP03 provisions separate real credentials and rejects fixture defaults; deliberate fixture regeneration needs reviewed hashes and regression evidence.


<a id="file-tests-fixtures-other-ca-pem"></a>

## `tests/fixtures/other-ca.pem`

**Responsibility.** Public test certificate for unrelated authority used for rejection.

**Contract and ownership.** Fixture bytes belong only to bounded local tests; identity, validity and key/certificate relationships are deliberate negative/positive inputs.

**Failure/change obligations.** Never deploy, copy into a product trust store or silently regenerate. Do not print private-key contents in diagnostics even though these fixtures are public.

**Verification.** tools/make_fixtures.py documents generation; TLS and independent peers check the corresponding auth/expiry/purpose case; downstream transport lock covers adopted bytes.

**Next actionable work.** WP03 provisions separate real credentials and rejects fixture defaults; deliberate fixture regeneration needs reviewed hashes and regression evidence.


<a id="file-tests-fixtures-server-key"></a>

## `tests/fixtures/server.key`

**Responsibility.** Public test private-key material for localhost/IP server identity.

**Contract and ownership.** Fixture bytes belong only to bounded local tests; identity, validity and key/certificate relationships are deliberate negative/positive inputs.

**Failure/change obligations.** Never deploy, copy into a product trust store or silently regenerate. Do not print private-key contents in diagnostics even though these fixtures are public.

**Verification.** tools/make_fixtures.py documents generation; TLS and independent peers check the corresponding auth/expiry/purpose case; downstream transport lock covers adopted bytes.

**Next actionable work.** WP03 provisions separate real credentials and rejects fixture defaults; deliberate fixture regeneration needs reviewed hashes and regression evidence.


<a id="file-tests-fixtures-server-pem"></a>

## `tests/fixtures/server.pem`

**Responsibility.** Public test certificate for localhost/IP server identity.

**Contract and ownership.** Fixture bytes belong only to bounded local tests; identity, validity and key/certificate relationships are deliberate negative/positive inputs.

**Failure/change obligations.** Never deploy, copy into a product trust store or silently regenerate. Do not print private-key contents in diagnostics even though these fixtures are public.

**Verification.** tools/make_fixtures.py documents generation; TLS and independent peers check the corresponding auth/expiry/purpose case; downstream transport lock covers adopted bytes.

**Next actionable work.** WP03 provisions separate real credentials and rejects fixture defaults; deliberate fixture regeneration needs reviewed hashes and regression evidence.


<a id="file-tests-fixtures-wrong-purpose-key"></a>

## `tests/fixtures/wrong-purpose.key`

**Responsibility.** Public test private-key material for client-only purpose presented as a server.

**Contract and ownership.** Fixture bytes belong only to bounded local tests; identity, validity and key/certificate relationships are deliberate negative/positive inputs.

**Failure/change obligations.** Never deploy, copy into a product trust store or silently regenerate. Do not print private-key contents in diagnostics even though these fixtures are public.

**Verification.** tools/make_fixtures.py documents generation; TLS and independent peers check the corresponding auth/expiry/purpose case; downstream transport lock covers adopted bytes.

**Next actionable work.** WP03 provisions separate real credentials and rejects fixture defaults; deliberate fixture regeneration needs reviewed hashes and regression evidence.


<a id="file-tests-fixtures-wrong-purpose-pem"></a>

## `tests/fixtures/wrong-purpose.pem`

**Responsibility.** Public test certificate for client-only purpose presented as a server.

**Contract and ownership.** Fixture bytes belong only to bounded local tests; identity, validity and key/certificate relationships are deliberate negative/positive inputs.

**Failure/change obligations.** Never deploy, copy into a product trust store or silently regenerate. Do not print private-key contents in diagnostics even though these fixtures are public.

**Verification.** tools/make_fixtures.py documents generation; TLS and independent peers check the corresponding auth/expiry/purpose case; downstream transport lock covers adopted bytes.

**Next actionable work.** WP03 provisions separate real credentials and rejects fixture defaults; deliberate fixture regeneration needs reviewed hashes and regression evidence.


<a id="file-tests-transport-zig"></a>

## `tests/transport.zig`

**Responsibility.** Nineteen Engine tests for config, identity, ALPN, bytes, bounds and authenticated closure.

**Contract and ownership.** Test fixtures and frozen verification time are deterministic test inputs; preserve tamper/no-plaintext, suffix and blocked-close cases.

**Failure/change obligations.** Preserve exact error/custody/lifetime semantics and old users. Unexpected failures remain failures; a passing local test is not cross-platform or whole-library security certification.

**Verification.** Generic Engine/Driver tests, independent SSL/TCP consumers, exact backend/runtime checks and relevant source hashes; rerun only affected gates.

**Next actionable work.** Keep existing 19 cases during target port; add Mac-specific ABI/runtime regressions rather than weakening assertions.

**Declared surface / navigation:** `clientConfig`; `serverConfig`; `transfer`; `handshake`; `connected`; `std`; `tls`; `expect`; `equal`; `expectError`; `now`; `n`; `request`; `r`; `response`; `local`; `peer`; `available`; `end`; `expected`; `read`; `custom ALPN is owned by each connection and bounds are checked`; `ALPN mismatch rejects handshake before application data`; `opaque ALPN accepts the maximum legal identifier`; `qualified runtime backend is OpenSSL 3.5.8`; `TLS13 HTTP1 roundtrip with single-byte handshake fragments`; `wrong DNS name fails before application access`; `explicit trust excludes an unrelated CA`; `expired certificate and future validity use supplied wall time`; `client-only EKU cannot authenticate a server`; `IP SAN succeeds and wrong IP fails`; `mTLS requires a trusted client certificate`; `AEAD record tampering is terminal and releases no plaintext`; `clean close_notify differs from raw EOF and truncated record`; `shutdown preserves final records in both roles and still rejects truncation`; `shutdown retries a blocked close alert before reading final peer data`; `bounded output retains write data across WANT_WRITE`; `input bounds, empty input, and explicit EOF`; `absolute deadline, backward clock, and idempotent cancel`; `invalid configuration and mismatched credentials fail at creation`.


<a id="file-tools-build-openssl-sh"></a>

## `tools/build-openssl.sh`

**Responsibility.** Reproduces the historical Windows SDK build with explicit local toolchain paths.

**Contract and ownership.** Uses isolated build/install paths, shared TLS without QUIC, one-job native make and exact compiler/shell configuration.

**Failure/change obligations.** Preserve exact error/custody/lifetime semantics and old users. Unexpected failures remain failures; a passing local test is not cross-platform or whole-library security certification.

**Verification.** Generic Engine/Driver tests, independent SSL/TCP consumers, exact backend/runtime checks and relevant source hashes; rerun only affected gates.

**Next actionable work.** WP01 needs a distinct Mac build path; do not reuse mingw flags or overwrite a functioning SDK during qualification.


<a id="file-tools-fetch-openssl-py"></a>

## `tools/fetch-openssl.py`

**Responsibility.** Downloads the exact adopted upstream archive using HTTPS ranges and final hash.

**Contract and ownership.** Validates response range/length, bounded retries and final SHA-256 before extracting with data-only tar filtering; writes under deps.

**Failure/change obligations.** Preserve exact error/custody/lifetime semantics and old users. Unexpected failures remain failures; a passing local test is not cross-platform or whole-library security certification.

**Verification.** Generic Engine/Driver tests, independent SSL/TCP consumers, exact backend/runtime checks and relevant source hashes; rerun only affected gates.

**Next actionable work.** Only use for explicit rebuild/adoption. Existing checkout has SDK only; no source audit can be inferred from absent source trees.


<a id="file-tools-interop-py"></a>

## `tools/interop.py`

**Responsibility.** Independent Python SSL peer against the C ABI with runtime path checks.

**Contract and ownership.** Loads specified backend and verifies DLL identity; exchanges fragmented records, validates TLS/auth/ALPN/closure and pending final data.

**Failure/change obligations.** Preserve exact error/custody/lifetime semantics and old users. Unexpected failures remain failures; a passing local test is not cross-platform or whole-library security certification.

**Verification.** Generic Engine/Driver tests, independent SSL/TCP consumers, exact backend/runtime checks and relevant source hashes; rerun only affected gates.

**Next actionable work.** Run during TLS port/change; preserve old-C-ABI and independent-provider checks.

**Declared surface / navigation:** `python_peer`; `exchange`; `connect`; `case`; `final_data_during_shutdown`; `in`.


<a id="file-tools-make-fixtures-py"></a>

## `tools/make_fixtures.py`

**Responsibility.** Regenerates public certificate/key fixtures for isolated tests.

**Contract and ownership.** Writes test credentials with deliberate identity/purpose/validity differences; these private keys are public examples, never deployable identities.

**Failure/change obligations.** Preserve exact error/custody/lifetime semantics and old users. Unexpected failures remain failures; a passing local test is not cross-platform or whole-library security certification.

**Verification.** Generic Engine/Driver tests, independent SSL/TCP consumers, exact backend/runtime checks and relevant source hashes; rerun only affected gates.

**Next actionable work.** Do not run as routine verification: replacement changes pinned fixture bytes. Review intended dates/identities and requalify all users on deliberate regeneration.

**Declared surface / navigation:** `issue`.


<a id="file-tools-pin-backend-py"></a>

## `tools/pin-backend.py`

**Responsibility.** Explicit adoption writer for SDK and historical build-tool hashes.

**Contract and ownership.** Runs private openssl version and records SDK/tool identities into backend-lock.json; unlike verifiers it intentionally mutates custody.

**Failure/change obligations.** Preserve exact error/custody/lifetime semantics and old users. Unexpected failures remain failures; a passing local test is not cross-platform or whole-library security certification.

**Verification.** Generic Engine/Driver tests, independent SSL/TCP consumers, exact backend/runtime checks and relevant source hashes; rerun only affected gates.

**Next actionable work.** Never run to repair a mismatch. Review rebuilt artifacts/provenance first, then adopt and update downstream pins explicitly.

**Declared surface / navigation:** `sha256`.


<a id="file-tools-qualify-ps1"></a>

## `tools/qualify.ps1`

**Responsibility.** Windows qualification orchestration with scoped runtime paths/cache and retained logs.

**Contract and ownership.** Saves/restores process environment in finally; verifies compiler/SDK hashes before test/host-test/interop/example and formatting.

**Failure/change obligations.** Preserve exact error/custody/lifetime semantics and old users. Unexpected failures remain failures; a passing local test is not cross-platform or whole-library security certification.

**Verification.** Generic Engine/Driver tests, independent SSL/TCP consumers, exact backend/runtime checks and relevant source hashes; rerun only affected gates.

**Next actionable work.** Its message suggesting pin-backend is not permission to rehash changed bytes. Add target-aware qualification rather than weakening custody checks.


<a id="file-tools-tcp-interop-py"></a>

## `tools/tcp_interop.py`

**Responsibility.** Independent Python TCP server testing downstream client.

**Contract and ownership.** Own ephemeral listener/thread/process; bounded deadlines and exact response/clean-close/error expectations.

**Failure/change obligations.** Preserve exact error/custody/lifetime semantics and old users. Unexpected failures remain failures; a passing local test is not cross-platform or whole-library security certification.

**Verification.** Generic Engine/Driver tests, independent SSL/TCP consumers, exact backend/runtime checks and relevant source hashes; rerun only affected gates.

**Next actionable work.** Extend target executable/path selection for Mac without loosening error or cleanup oracles.

**Declared surface / navigation:** `case`; `in`.


<a id="file-tools-tcp-server-interop-py"></a>

## `tools/tcp_server_interop.py`

**Responsibility.** Independent Python TCP client testing downstream server roles.

**Contract and ownership.** Consume actual assigned port; require client certificate rejection, exact fragmented response and authenticated closure; join reader and process.

**Failure/change obligations.** Preserve exact error/custody/lifetime semantics and old users. Unexpected failures remain failures; a passing local test is not cross-platform or whole-library security certification.

**Verification.** Generic Engine/Driver tests, independent SSL/TCP consumers, exact backend/runtime checks and relevant source hashes; rerun only affected gates.

**Next actionable work.** Retain missing/untrusted-client and raw-EOF cases through backend or runtime changes.

**Declared surface / navigation:** `case`; `in`.


<a id="file-tools-tcp-upload-interop-py"></a>

## `tools/tcp_upload_interop.py`

**Responsibility.** Early final response while ciphertext transmission is deliberately blocked.

**Contract and ownership.** Require observed early headers, retained accepted first body block, no second block, bounded cancel/deadline and clean/unclean close distinctions.

**Failure/change obligations.** Preserve exact error/custody/lifetime semantics and old users. Unexpected failures remain failures; a passing local test is not cross-platform or whole-library security certification.

**Verification.** Generic Engine/Driver tests, independent SSL/TCP consumers, exact backend/runtime checks and relevant source hashes; rerun only affected gates.

**Next actionable work.** Keep as regression for any scheduling or probePeer change; application-level response policy remains caller-owned.

**Declared surface / navigation:** `case`; `in`.


<a id="file-tools-test-openssl-sh"></a>

## `tools/test-openssl.sh`

**Responsibility.** Runs selected upstream TLS/certificate recipes with known Windows Perl/make adaptations.

**Contract and ownership.** Mutates generated build metadata/wrapper paths, not adopted upstream source; preserves metadata timestamps; does not claim full upstream test coverage.

**Failure/change obligations.** Preserve exact error/custody/lifetime semantics and old users. Unexpected failures remain failures; a passing local test is not cross-platform or whole-library security certification.

**Verification.** Generic Engine/Driver tests, independent SSL/TCP consumers, exact backend/runtime checks and relevant source hashes; rerun only affected gates.

**Next actionable work.** Record exact source/build/tool prerequisites before running; unavailable historical paths require a deliberate reproduction plan.
