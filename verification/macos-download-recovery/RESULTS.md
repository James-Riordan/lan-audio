# macOS download recovery

Base: `9397013`. The user's Mac passed dependency custody, then Python TLS
failed against pkg.hexops.org with SSLV3_ALERT_ILLEGAL_PARAMETER. The exact Zig
archive at ziglang.org returned HTTP 404. Omitting git pull --ff-only was unrelated.

The launcher now tries two additional community mirrors (zig.tilok.dev and
zig.mirror.mschae23.de/zig). Pinned archive hashes, sizes and compiler version
are unchanged. Python TLS errors on macOS retry through /usr/bin/curl, with
certificate verification, HTTPS-only requests/redirects, no curlrc, bounded
redirects and time. Python streams a bounded body and checks the existing hash
before publishing. Partial failed files are removed and child processes reaped.
HTTP errors do not invoke the TLS fallback. HTTP error responses are closed.

## Verification

- 25 BootstrapTests pass under pinned Python 3.13.7 (3.408 seconds), including
  five added tests with multiple subcases: good/corrupt fallback bytes, partial
  Python TLS body, failed curl/mirror recovery, HTTP/platform routing and real
  subprocess success/nonzero exit/oversized output/cleanup. An earlier run also
  passed under local Python 3.14. These simulate Mac selection on Windows.
- Application reference generation, documentation and handoff checks pass:
  182 authored files mapped. Native application sources are unchanged.
- Both added mirrors return HTTP 200 and expected Content-Length for Windows
  and Intel Mac archives with TLS restricted to 1.2 in inspection requests.
  This is HEAD-response evidence, not successful full archive verification.
- Live Windows system curl fails the original mirror handshake. Live full
  downloads from alternate mirrors also encountered TLS record/decryption
  failures with Windows curl and Python. These attempts did not publish any
  archive. A curl-only fix was therefore insufficient to establish recovery.
- Windows `start.cmd --prepare` passed for the final source key
  `3a137dc7e6d0eef324783599`. Earlier preparation during edits also passed.
- 8 PairingTests passed under pinned Python 3.13.7 (7.134 seconds, no skips),
  including native receiver installation using the final Windows build.
  Combined bootstrap/pairing campaign: 33 tests passed; no physical audio.

Sources: https://ziglang.org/download/community-mirrors/ (mirror discovery),
https://curl.se/docs/manpage.html (curl option semantics). The existing archive
hashes bind bytes whose signatures were verified during earlier tool adoption;
no new compiler archive or trust pin is adopted here.

Native macOS system curl and full download/build still require the user's retry.
No certificate verification bypass, global TLS change or runtime identity change
was made. This is not Mac speaker or gaming-performance qualification.
