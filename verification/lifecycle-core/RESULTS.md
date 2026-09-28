# Lifecycle implementation and in-place Codex transition

This phase begins implementation in the existing Codex-backed conversation.
There is one application owner; the other audio conversation retains dependency
ownership. No duplicate application chat, UI switch, model switch or background
automation is claimed. The user need not copy a handoff prompt.

## Implemented increment

C02a adds the actual private `src/runtime/lifecycle.zig` controller, an independent
fake-owner caller, a mathematical/adapter explanation in
`docs/runtime/lifecycle-core.md`, private build steps and updated continuation/file
contracts. It handles three-resource acquisition, cancellation, late/partial
success, exact operation identity, worker/native fence debt, explicit cleanup
retry, namespace exhaustion and delayed completion after timeout. It does not
implement the complete graceful media runtime or a runnable sender/receiver.

`before.json` and `before/` preserve all 113 application files from the preceding
lifecycle-preparation receipt. Earlier evidence stays historical and unchanged.

## Executed evidence

- 11 real-controller fake-owner tests passed in Debug and ReleaseSafe.
- Fresh local-cache regression passed 55 tests: 42 existing pure tests, 11 lifecycle
  tests, one dependency consumer and one silent native-device integration test.
  The build emitted Perl locale warnings with intermediate failure-looking text;
  final result was exit 0, 14/14 steps and 55/55 passed. Raw warnings are preserved.
- The same controller/test caller compiled for x86_64 macOS and aarch64 Linux.
  Neither foreign target was executed. No Mac SDK/device behavior is established.
- Six deliberately corrupted controller copies were rejected by the intended
  executed fake-owner tests: duplicate dispatch, lost late success, incomplete token
  comparison, release of a live worker, release of an unfenced device, and terminal
  state while acquisition remains pending. Production source was not mutated.
- Documentation/reference/custody checks and their exact commands are recorded
  in the final receipt. The unchanged earlier Python/TLA models remain prior
  evidence; this phase's new runtime result is actual Zig controller execution.

Acquisition schedules cover cancellation before all four acquired prefixes and
during all three acquisition operations with three possible outcomes; additional
cases cover automatic failure cleanup, five cleanup failure/retry positions,
paused callback return, repeat/old-generation input and counter limits.
The tests maintain independent acquired/released/borrow facts, rather than merely
asserting the controller's own counters agree with each other.

## Failed attempts and their meaning

The first test source used the old Zig array-repeat syntax. The pinned development
compiler rejected it before tests ran; `attempt-1/` preserves that source. Explicit
array elements fixed the syntax, and the formatter normalized current builtins.
This was a compatibility defect in new test code, not a passing runtime observation.

The first mutation runner rejected a real duplicate-dispatch failure because it
expected the test name and FAIL on the same line, then stopped because formatting
had renamed `@intFromEnum` to `@backingInt`. The second campaign executed all six
mutations, but its classifier missed two FAIL markers printed on the test-name
line. A separate review of the unchanged raw output corrected classification;
`mutations-2/reviewed-results.json` binds each exact named failed test and log hash.
Earlier output/results and runner source remain preserved. Compiler failure alone
is never counted as a successful fault-detection test.

## Reviewed dependency adoption

The miniaudio owner corrected recursive package `.paths` inclusion with an explicit
47-file allowlist. This application adopted twelve file-contract updates after
verifying all 47 live and sealed source files, source archive, owner receipts and
command logs. Eight files changed and four were added; runtime Zig/C, native build,
vendor bytes, ABI profile and reviewed application TLS pins remain unchanged.
The owner's packaging/30-tool-test observations remain historical dependency
evidence; the fresh application consumer/device regression is separately recorded.

The first reference render correctly rejected an unregistered TLS r5 addition.
The completed transport-owner revision was then reviewed and integrated: 51 added
file contracts cover isolated provider diagnostics, raw observations and lease
documentation. The before/after audit matches the prior baseline; existing runtime,
SDK and lock bytes are unchanged. Its 17-case O0/O2 diagnostics remain owner
observations, not a fresh LAN Audio transport test or adoption of QUIC. The final
reference covers 563 files (397 authored/support and 166 installed SDK assets).

## Limits and next work

C02a is a bounded resource-lifetime implementation. It assumes truthful executor
results and stable handle slots. Timeout retains debt; it cannot force a native
call to return. Fake schedules and isolated mutations are not a machine-checked
refinement proof, real-time bound or whole-upstream semantic audit.

Full C02 remains open: compose graceful PendingBlock/queue custody, media tails,
END/ACK and independent terminal outcome dimensions with this controller. R07/R08
ownership/abort subsets and part of R05 have evidence, not all R03-R08. Then qualify
C03's real native fence/join mapping, C04 networking/identity and C05 workers.
Native Intel Mac/two-host execution, sustained drift/network recovery and final
distribution remain later gates. The Mac is unavailable; Monterey is unconfirmed.
