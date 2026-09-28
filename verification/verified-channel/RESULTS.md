# Verified native connection — qualification

This increment connects the actual application TCP owner, reviewed TLS Driver and
live verified peer leaf identity to copied policy and v2 records. It adds no device
streaming command, native Apple app, credential store or physical audio run.

## Current source results

- Final host: 43 independent Python-peer scenarios pass in both Debug and ReleaseSafe.
  Eight positive combinations cover both TLS roles, both audio roles and IPv4/IPv6,
  exact words for 1285 frames, mutual certificate identity and clean TLS close.
  Negative cases cover approval/role/identity, protocol, deadline, EOF, cancellation,
  policy revision, truncation, trailing records and buffered expiry.
- Each positive path checks 32 repeated authorizations, seven stale operations and
  repeated cleanup. Receiver completion here is a synchronous verifier, not a device.
- Three compiled authorization/lifetime mutants were caught. Two further regressions
  fail on the preserved earlier implementation: buffered expiry and ACK after known
  trailing data. Final source has both guards; fresh 43-case results supersede the
  prior 42-case host qualification for these changes.
- Existing v1 (16 cases) and v2 (22 cases) media regressions pass with the reviewed
  TLS adoption. Policy/network component tests pass in both modes (13 tests).
  These unchanged execution closures were not rerun after the two isolated host guards.
- All 188 reviewed TLS custody entries and staged DLLs pass. Five entries changed
  by explicit reviewed adoption, with the copied owner receipt and rationale retained;
  183 entries stayed fixed. All 47 previously observed miniaudio files are unchanged.
- iOS native transport probe intentionally rejects as unsupported. Earlier iOS
  shared-policy object compilation remains separate, with no native Apple qualification.

## Historical attempts and limits

The initial build succeeded. The first independent campaign rejected all intended
bad connections but incorrectly classified three error names (server ALPN and two
sequence errors). The raw 38-case result and classifier review remain in attempt-2.
The corrected/expanded 42-case campaign passed, then passed in both modes with the
legacy suites. Subsequent code inspection identified the two buffered-record guards;
before-code tests reproduce them and the final 43-case campaign passes freshly.

The inherited Perl locale warning appears in raw build output even where the final
build summary and process report success. It has not been rewritten or claimed fixed.
The native evidence is Windows 10 x86_64. Public fixture keys and frozen certificate
time remain only in test programs. No Mac/iPhone execution, sustained Wi-Fi audio,
acoustic fidelity/latency, secure pairing/storage, packaging/signing or release claim
follows. Live capture/playback workers and their lifecycle/callback mapping are next.

`receipt.json` binds current application bytes, exact source snapshot, adoption,
commands, raw evidence, and executable hashes. It is a review record, not a proof of
universal correctness. The previous 135-file snapshot and all 206 prior evidence
files were verified and preserved.
