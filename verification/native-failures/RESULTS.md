# Native failure and TCP ownership qualification

This phase advances C03 controlled audio failures and C04 native sockets. It does
not supply a deployed sender/receiver or close a production acceptance gate.
`receipt.json` seals the final source/evidence observations after qualification.
The parent is native-events receipt SHA-256
`ff591f754921463fe81dbe365d99802ba1108c4bd4aaf0a3c85635493c1ee03b`;
before.json records the 122 application files verified before editing.

## Implemented behavior

The actual AudioDevice owner is instantiated with a compile-time native function
set. Its new test uses real null devices and controlled failures before context,
enumeration/device acquisition, format admission, and before/after start/stop.
It independently checks ownership counts, device-before-context cleanup, failed
state, withheld fences/snapshots and reconstruction. The production native calls
remain the default, with no runtime injection facility or dependency edits.

The new application-owned network_host module implements explicit numeric
IPv4/IPv6 TCP endpoints, serialized nonblocking ownership, independent accepted
sockets, checked connect completion, short-prefix/would-block/EOF semantics,
half-close, bounded absolute waits, cancellation and uncertain-close retirement.
Winsock and POSIX differences live in its private C boundary, replacing the
proposed separate Windows/Mac Zig wrappers under decision D24.

## Evidence interpretation

Initial audio attempt-1 executed 11 tests in Debug. Initial network-attempt-1
failed because this pinned Zig version removed @cImport; the original log and
source are preserved. The repair uses the build system's translate-C module.
Network-attempt-2 then executed five tests. The stalled-peer case and cleanup/
clock refinements were added afterward; those early runs are not their evidence.

The final/ directory records six network tests in both Debug and ReleaseSafe,
11 fresh audio tests in ReleaseSafe, and a Debug audio rerun with six integration
tests executed and five unchanged host-root tests cached. This cache behavior
was identified explicitly; build.zig now marks the host-root qualification run
as side-effecting so an explicit request always executes it. The qualified/
directory supersedes that build revision and records fresh audio/network runs
and the selected cross-target compilations, with sources and timings.

Six real loopback network cases cover both IP families, exact byte order across
different I/O boundaries, reverse traffic after read EOF, listener release,
refused connection, invalid endpoints, original deadline preservation, atomic
cancellation, 32 teardown cycles and bounded backpressure followed by recovery.
The tests do not make a process-wide handle-count or Wi-Fi performance claim.

The mutations/ directory preserves deliberately broken source variants, raw
test output and classification. Detection requires a named executed test and a
runtime failure, not simply a compiler exit. The mutation runner restores exact
working bytes in finally; qualification runs after restoration. See the receipt
for the final successful test/build outcomes. All four broken variants were
rejected by their named executed tests. The initial classifier incorrectly
required the literal phrase "test failure", absent from this compiler output;
review_mutations.py checks the actual named failure, count, successful compile
and specific runtime witness without overwriting the original classification.

Some compiler logs contain inherited Perl locale warnings headed as a failed
substep, followed by the compiler's successful final summary. Preserve those
messages verbatim; classify each run using its recorded process exit and final
test/build summary, without presenting warnings as clean diagnostics.

## Final restored-source results

| Check | Recorded outcome |
| --- | --- |
| Windows Debug audio + network | 17/17 executed tests passed, 80.764 s |
| Windows ReleaseSafe audio + network | 17/17 executed tests passed, 31.519 s |
| x86_64 Linux/musl network compile | Passed, 11.836 s; artifact compile cached, no execution |
| Intel macOS 12 network compile | Passed, 6.718 s; artifact compile cached, no execution |
| Intel macOS 26 network compile | Passed, 40.108 s; no execution |
| Deliberate start/stop state and connection/EOF defects | Four named runtime rejections; raw evidence retained |

Timings are total command elapsed times on this host, not performance benchmarks.
Native tests comprise six external audio integration cases, five host-root cases
and six real network cases. Foreign network builds include the C boundary and
Zig owner; they do not include the product's native audio/TLS deployment closure.

## Remaining production gates

The native TCP source compiles for x86_64 Linux/musl and Intel macOS 12 in the
recorded final/ runs. Cross-compilation does not execute either target. The
qualified/ runs also check the explicit macOS 26 target. No Linux, Mac or mobile
runtime, physical device, SDK audio closure, packaging or clean installation was
qualified in this phase. Monterey is still the required minimum for the user's
Intel Mac; no future-OS guarantee is inferred.

Audio injection covers application-boundary return/metadata failures, not every
internal allocator/driver failure. Asynchronous native fences, endpoint discovery/
stable identity, independent socket peers, native socket failure injection,
secure real identity/allowlist storage, worker joins, sustained timing/drift and
the Windows-to-Mac hardware journey remain open. Native library source, stable
core exports and dependency pins are retained. The current TLS custody result
and any unadopted dependency changes are recorded rather than silently repinned.

The implementation arguments are in docs/runtime/native-failures.md and
docs/runtime/network-owner.md. Source files and raw evidence are canonical;
historical records remain historical when later changes supersede this receipt.
