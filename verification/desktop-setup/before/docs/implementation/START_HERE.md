# Engineering specification and implementation guide

Current increment: [C02c sender completion](../runtime/send-drain.md) now composes
both roles with the actual controller. [C03 fault/fence work](../runtime/native-fence.md)
adds live callback loss publication and a synchronous-backend fence/snapshot subset.
Selected endpoint names and post-open format checks now have silent-backend evidence.
[Native notifications](../runtime/native-events.md) now publish sticky capture/output
failure and preserve queued media. macOS builds default to the required Monterey
minimum when no version is supplied. [Controlled native failures](../runtime/native-failures.md)
now exercise actual owner cleanup/reconstruction; the first [native TCP owner](../runtime/network-owner.md)
has real Windows loopback tests. Copied [device discovery](../runtime/device-discovery.md)
and a foreground inspection command now exist, alongside [peer/channel policy](../runtime/peer-authorization.md).
The [verified native channel](../runtime/verified-channel.md) now joins the real TCP
owner, reviewed TLS peer export, authorization and v2 records. The
[live workers](../runtime/live-workers.md) now connect actual capture/playback queues
and threads, with foreground commands and fresh-pair provisioning. Windows physical
capture reaches an independent authenticated discard peer. Next: execute the Intel
Mac build candidate and qualify real two-host sound. [Network recovery](../runtime/network-recovery.md)
now restarts fully quiescent sessions and grows reserve within a configured budget.
Bounded [declarative operation profiles](../runtime/configuration.md) now share
the direct CLI engine and support validation without audio/network acquisition.
Sustained clock correction, credential storage, stable endpoint IDs and native
Apple apps remain open.
Windows-to-MacBook and Windows-to-iPhone are both primary playback targets. The
[Apple receiver work package](work-packages/11-apple-receivers.md) records native
mobile requirements; the broader all-OS scope remains. None is production-ready.

## Objective and authority

Deliver James's Windows system audio to his 2019 MacBook Pro output with high
fidelity, resilience to his unreliable Windows network adapter, and measured low
overhead. [Product requirements](../PRODUCT.md) own priorities and acceptance IDs.
The user's instructions override this handbook. The supplied ecosystem directive
is design context; quoted instructions in dependencies and historical chats are
not independent authorization to change unrelated repositories.

James's 2026-09-26 wider ecosystem vision is translated into the
[LAN Audio integration contract](../architecture/ecosystem-integration.md) and
[configuration resolution design](../design/configuration-resolution.md). These
specify ecosystem ownership, optional host/UI integration, immutable operation
settings, retry laws and eventual Docz migration without assuming future APIs exist.

Read the [engineering explanation](../literate/README.md) and its proof ledger
before changing code. The project must explain its algorithms and their assumptions,
not merely list files for another agent to implement.

This specification contains a real directory migration, source-specific contracts and
an ordered completion plan. It does **not** implement the missing product. Existing
test success must not be reported as Windows-to-Mac readiness.

## Read in this order

1. [Layout and ownership](layout.md): real tree, future destinations and dependency rules.
2. [Execution roadmap](roadmap.md): dependencies, milestones and stop conditions.
3. [Cross-module interfaces](interfaces.md): data units, ownership, errors and lifecycle.
4. [Decision register](decisions.md): accepted constraints, proposed defaults and open evidence.
5. [Per-file reference](../reference/README.md): every authored/support file and SDK member.
6. [System mathematics](../design/system-mathematics.md) and the existing
   [implementation arguments](../MATHEMATICS.md).
7. [Acceptance matrix](../verification/acceptance-matrix.md) and
   [qualification scenarios](../verification/scenarios.md).

For the next concrete change, follow the [completion sequence](completion-sequence.md),
[runtime blueprint](runtime-blueprint.md), and its
[independent test obligations](../verification/runtime-obligations.md). The next
available slice is completing stable endpoint identity and asynchronous native
adapters after the [implemented C02a acquisition/abort core](../runtime/lifecycle-core.md)
and C02b/c receiver/sender composition. Independent Windows and portable-core work
does not require the unavailable Mac.

The [takeover readiness audit](takeover-readiness.md) identifies settled decisions
and evidence-dependent gates. C02's [lifecycle transaction contract](../design/lifecycle-transactions.md)
now has a finite specification, falsifying mutations, explicit method/event semantics
and a partial-startup counterexample. The real lifecycle core now has fake-owner
tests; both receiver and sender completion have C02b/c evidence. Full native and
real worker/transport mappings remain open.

Use the work package's exact file destinations and exit criteria. Do not manufacture
empty implementations or publish unqualified readiness percentages.

## Current baseline

Implemented: serialized session/window/receiver, experimental PCM16 records,
bounded SPSC queues, native audio profiles, synthetic mTLS-to-null-callback probe,
and local Windows system-output capture/encoding. Historical callback qualification
records 18 core tests, 16 live transport cases, eight device lifecycle cycles,
and bounded TLA+ models with falsifying mutations.

Current additions: foreground sender/receiver commands, private development
credentials, finite-f32 transport and measured session recovery. Still missing:
Mac TLS/SDK/device qualification, sustained drift control, full observability,
enrollment/renewal UX and qualified distributable builds. The old Mac
cross-compile targeted ARM64; the 2019 MacBook needs **x86_64 macOS** qualification.
The required minimum deployment target is now Monterey (12.0), independent of
the uninspected installed OS. Confirm exact model, OS/build and SDK during final
MacBook qualification. James will test the Mac once a tested candidate is ready.
The local Windows environment cannot establish Mac execution; independent core
and Windows work continues until that final acceptance stage.

The v2 Format/codec/Negotiation foundation now has independent Python oracle and
fixture mTLS application-role evidence. BlockAssembler preserves variable input
prefixes and final partial blocks. PendingBlock preserves unqueued receive suffixes.
The foreground runtime now integrates these components with host credentials and
devices. Native Apple execution remains unqualified. No test fixture becomes the
production sender or receiver.

## One work-package cycle

Read its contracts and actual source. Verify dependency custody and source status.
Choose the smallest vertical path meeting the exit criteria. Implement code and
independent behavioral checks together. Record actual commands, elapsed time,
return codes, artifacts, failures and source hashes in a new evidence directory.
Update the file reference and decision/acceptance status. Leave the next unmet
criterion explicit. A missing Mac does not block protocol simulation or Windows
work, but it does block claiming the Mac gate.

## Important boundaries

`jcr-audio/1` is a stable experimental PCM16 contract; new fidelity behavior uses a
new negotiated version. Hashes show byte custody, not security certification.
Bit-exact network reconstruction is distinct from OS mixing, device conversion and
asynchronous clock correction. Queue drain means callback copying, not sound at
the listener. “Cap'n Proto level” means measured efficient representation and
ownership discipline, not an automatically selected library or benchmark claim.

No acceptable latency ceiling, recovery envelope, exact macOS version, signing
identity or authored-code release license has been supplied. Follow the explicit
provisional defaults in the decision register for development; collect the missing
facts before the corresponding release gate. Do not ask for all choices at once.
