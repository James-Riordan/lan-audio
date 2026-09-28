# Encryption-level integrity regression

During Q00 standards integration, an external production-module probe queued a valid ClientHello followed by eight surplus Initial bytes. With a one-byte native input budget, the pre-fix Engine reached readiness. The retained failure is a genuine failed oracle, not an expected-success test. The same probe now exits zero with UnexpectedLevel.

The fix bounds each provider lease to one TLS Handshake header/message body, retaining framing state across fragments. After native advancement, queued old-level bytes beyond any still-held final message lease cause terminal UnexpectedLevel before public events/readiness. Message boundaries prevent a large lease from hiding a second old-level message. OpenSSL still owns TLS message validation and authentication.

The tenth native test injects surplus Initial bytes into both roles with budgets 1 and 16384. All ten tests pass in the initial Debug run; final Debug/ReleaseSafe qualification and source-bound completion refresh are recorded separately. The earlier nine-test checkpoint and completion receipts remain in history. Records source, public API names, package pins and SDK bytes are unchanged.

The probe also exposed a Windows build-run launch-path issue when its staged executable was launched with a working directory outside its external package. Installing and executing the absolute binary path against the fixture working directory successfully ran both pre/post-fix probes. That launcher issue is a separate consumer/platform follow-up, not a TLS authentication failure.

Reference: [RFC 9001 section 4.1.3](https://www.rfc-editor.org/rfc/rfc9001.html#section-4.1.3). The first failure and fixed output plus exact external consumer source are in [probe evidence](t02-level-gap-probe/surplus-initial-failure.json) and [fixed result](t02-level-gap-probe/surplus-initial-fixed.json). These supplemental runs use paths outside the repository; they are not relabeled as repository-local canonical commands.
