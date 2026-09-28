# Exact SDK external QUIC TLS capability probe

Observed 2026-09-26 on the existing Windows OpenSSL 3.5.8 SDK with pinned Zig `0.17.0-dev.1859+dcceb318e`. [Raw result](r2-probe-result.json) records source/runner/lock hashes, verified SDK file count, staged DLL hashes, compile invocation and individual outcomes. The SDK's `OPENSSL_NO_QUIC` configuration does not prevent the external callback path exercised here.

| Case | Observed result | Meaning |
| --- | --- | --- |
| full output | WANT_READ; one 217-byte raw ClientHello | callbacks register, link, execute and emit initial handshake bytes |
| 17-byte output budget | WANT_WRITE after 17 bytes; refill produces complete 217-byte ClientHello and WANT_READ | partial send callback custody and resume execute successfully |
| send callback returns failure | SSL_ERROR_SSL with zero accepted bytes | callback failure is surfaced as terminal provider error |

All three cases passed; all report `handshake_complete=false` and `peer_authenticated=false`. No receive-release, secret, peer-parameter or alert callback was exercised. No server, socket, certificate verification result, completed handshake, key installation, cross-platform runtime, real memory bound or production QUIC behavior was proved. The trust store and expected identity are configured, but a configured check is not a completed check.

The probe compiles with warnings-as-errors, verifies all 166 SDK files before linking, and copies the locked DLLs beside the executable. It records staged file identities; it does not independently record loaded module paths. SDK/runtime provenance hardening remains a native qualification obligation.

## Reproduce

Within the TLS tree (probe source is shipped with tls-zig, not quic-zig):

```text
python tools/probe-quic-tls.py --work-dir <new-empty-scratch-directory>
```

For a source-only handoff, supply `--sdk-root <path-to-exact-locked-openssl-install>`. The override selects location only; every expected hash and exact file-set check still applies. The runner writes only scratch binaries/logs, never updates the SDK or lock, and returns JSON/nonzero on failure. Its native compile deadline is 120 seconds and each case deadline is 10 seconds. Preserve failed logs and use a new scratch directory for each attempt. This Windows-only probe cannot qualify another target.

## Consequence for the next work order

A backend rebuild is not currently justified merely to obtain the exercised callback capability. Continue with the separate recordless ABI/queue/owner and a real client/server handshake. Rebuild or upgrade only when additional required behavior demonstrates a concrete deficiency, with separate SDK lock review and records regressions. Keep the existing records API and pinned fixture stable.

Provider semantics are described by [OpenSSL's external QUIC TLS callback documentation](https://docs.openssl.org/3.5/man3/SSL_set_quic_tls_cbs/); this project's local execution result establishes the narrower build-specific finding above.
