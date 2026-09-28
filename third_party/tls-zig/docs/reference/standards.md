# Primary standards and provider references

Reviewed online on 2026-09-26. Recheck status/errata and provider support when implementing or releasing. This register points to source material; it is not a conformance certificate.

| Reference | Use in this project | Qualification gap |
| --- | --- | --- |
| [RFC 9000](https://www.rfc-editor.org/info/rfc9000/) | QUIC transport wire/lifecycle/stream rules | Current library covers only part of the transport; Q2–Q5 complete the chosen profile. |
| [RFC 9001](https://www.rfc-editor.org/info/rfc9001/) | TLS integration and QUIC packet protection | T1/Q1 establish actual recordless integration; Q2 adds Application keys. |
| [RFC 9002](https://www.rfc-editor.org/info/rfc9002/) | Recovery and congestion-control review | Current driver is Initial-only; review skipped-number threshold and multi-space behavior. |
| [RFC 9846](https://www.rfc-editor.org/info/rfc9846/) | Current TLS 1.3 specification; obsoletes RFC 8446 | Existing adapter tests are not complete provider conformance qualification. |
| [OpenSSL 3.5 external QUIC TLS API](https://docs.openssl.org/3.5/man3/SSL_set_quic_tls_cbs/) | Candidate provider seam | Exact SDK symbol/configuration probe plus real handshake required. |

For each new feature, add requirement IDs tied to specific standard sections, local policy decisions, source files and executable tests. Keep local caps (32 ACK ranges, 64 parameters/chunks, lifetime buffers) labeled as implementation policies. Do not present those caps as protocol requirements. Record deviations and interoperability consequences explicitly.

## Revision-2 callback capability evidence

The locked no-quic Windows SDK executes the initial external QUIC TLS callback probe successfully. This removes a speculative rebuild prerequisite for that exercised capability only. Nonempty receive-release, secret direction, peer parameters and an authenticated handshake still require native qualification; preserve the exact backend lock until a concrete requirement justifies an upgrade. See docs/verification/quic-provider-probe.md.
