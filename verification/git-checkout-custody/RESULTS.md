# Git checkout dependency custody repair

The user's Intel Mac clone of initial commit `e48aae6` stopped before building:
`reviewed dependency changed: tls-zig/tools/check-docs.py`.

Root cause: the `third_party/** -text` rule preceded extension rules, which
re-enabled Git normalization for Python and PowerShell files. The original
Windows working files matched all 1,030 reviewed hashes; 15 committed blobs did
not. For check-docs.py, the reviewed file had 195 CRLF endings, 9,896 bytes and
SHA256 `be34383f3ec878381ea6140f504b91af3213dcbb955aa35c0dffc63aa503a0be`.
The initial commit stored 9,701 bytes with LF endings and SHA256
`2a6e9a4877fb10d9fd8b6c3d52dbe16629d5c8a27e9b845495fdab6f819abc63`.

Repair: place `third_party/** -text !eol` after extension rules and stage the
original reviewed bytes again. Both adoption locks remain unchanged. All 1,030
staged dependency blobs match the lock; the 15-file staged dependency diff is
empty when ignoring line-ending whitespace. No upstream logic was modified.

## Checks

- Initial Git round-trip regression with old attributes: reproduced the
  check-docs.py hash mismatch (3 failing subtests, 96.764 seconds). This first
  test draft imposed autocrlf=true at invocation level; the repaired test
  explicitly selects each mode for clone execution as well as clone config.
- Final `python tests/integration/repository_launcher.py GitCustodyTests`:
  PASS (48.019 seconds), complete dependency closure added/committed to an isolated
  temporary Git repository and freshly cloned under false, true and input modes.
- `python tests/integration/repository_launcher.py BootstrapTests PairingTests`:
  PASS (28 tests, no skips, 10.227 seconds), including fresh loopback TLS pairing
  and prepared native installation reuse; no physical audio opened.
- `start.cmd --prepare`: PASS; verified existing Windows build reused.
- Application reference generation, documentation and handoff gates: PASS,
  182 authored files mapped.
- `python tools/check_transport.py`: PASS, 188 files unchanged.

Initial GitHub run 36369091696 failed at launcher steps on both Windows and Intel
Mac; the public job API confirms those steps but log downloads require
authentication (HTTP 403). No claim is made about their exact log messages.
The corrected revision has not been committed/pushed or executed on the Mac.
This is a clone-custody fix, not qualification of native Mac builds or playback.
