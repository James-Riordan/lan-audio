# Runtime design, frame-custody model and implementation continuation

Observed on Windows, 2026-09-26. This phase adds implementation-ready design and
mathematical specifications. It changes no application runtime source, build graph,
native audio code, protocol, dependency source or SDK asset. It does not make the
product runnable. The [final receipt](receipt.json) names exact files/tools/evidence.

## Concrete preparation delivered

- [Runtime blueprint](../../docs/implementation/runtime-blueprint.md): actual
  component mismatches; owner/storage map; sender copied-write commit; receiver
  pending-prefix custody; empty/short-stream startup; callback/native fence;
  cancellation, rollback and bounded scheduling requirements.
- [Completion sequence](../../docs/implementation/completion-sequence.md): C01-C09,
  exact next-slice file contracts and exit conditions, Windows/pure versus Mac
  availability, and foreground command scope without invented IPC.
- [Receive/drain mathematics](../../docs/design/receive-drain.md): sequence identity,
  frontier mapping, transition preservation, conditional liveness rank and a
  concrete refinement-obligation table.
- [Runtime test obligations](../../docs/verification/runtime-obligations.md): R01-R15,
  independent source ledger, explicit failure schedules, resource/borrow accounting
  and versioned trace fields. These future runtime tests remain unimplemented.
- Two new TLA+/configuration files and the existing model runner's new selection.
  Six new authored files extend the reference to 329 entries: 163 authored/support
  contracts and 166 installed SDK assets. Planned runtime files remain plans.

The design now explicitly avoids interpreting v2 frame offsets as v1 block numbers,
accepting unsupported native rates because the wire parser permits them, reading
plain callback statistics concurrently, or acknowledging merely because a queue
is empty. It also identifies the missing verified-peer identity API required by
product authorization and the missing live native-input fault publication.

## Executed model checks

| Model/configuration | Observed result | Evidence |
| --- | --- | --- |
| ReceiveDrain: capacity 2, prefill 2, frames 3, max block 2 | Normal safety/temporal pass; 73 distinct states; all four expected defect detections | [standard report](model-receive-drain-attempt1.json) |
| ReceiveDrain: capacity 1, prefill 1, frames 4, max block 3 | Normal safety/temporal pass; 98 distinct states | [additional bounds](model-additional-bounds.json), [exact config](block-larger-than-queue.cfg) |
| ReceiveDrain: capacity 3, prefill 3, frames 5, max block 3 | Normal safety/temporal pass; 220 distinct states | [additional bounds](model-additional-bounds.json), [exact config](larger-tail-domain.cfg) |
| Existing RuntimeOwnership | Normal safety/temporal pass; 3,925 distinct states; early_free and stop_wait detected as expected | [regression report](model-runtime-ownership.json), [command](runtime-ownership-command.json) |

The four ReceiveDrain mutations are overwrite_pending and drop_suffix (FrameOrder
violations), early_ack (AckFence violation), and short_stream_wait (temporal
violation). Nonzero TLC exits are successful *defect detections* only when they
name the expected property. None is a normal-model success. The additional domains
run the normal specification only; they are not extra mutation campaigns.

Java and the reviewed TLC jar are identified in [tool observations](formal-tools.json).
The standard runner records model/config/runner/jar hashes and raw TLC output;
the additional-domain report retains each exact command/config/source identity.
All new model attempts passed their stated expectations. The other three existing
models were not rerun; their prior results remain historical.

## Documentation and custody checks

The final [documentation/custody report](document-checks.json) records reference
rendering, local Markdown targets, exact inventory/contract coverage, local Zig
imports, work-package status/exit markers, TLS staged-runtime pins and preserved
miniaudio upstream bytes. These checks verify navigation/custody, not the quality
of every sentence or correctness of every proposed design decision.

Before-images preserve all 98 previously indexed application files. The final
receipt verifies every prior phase evidence file and all unchanged runtime/build,
dependency and existing formal-model sources against the previous receipt. No
source/dependency pin is refreshed to make validation pass. Runtime suites and
hardware probes were not rerun for this documentation/model-only change.

## Remaining limits and next implementation

ReceiveDrain represents one already authorized healthy non-resampled stream.
It tracks frame identities, not sample words, cryptography, device buffers or weak
memory. Its fair eventuality is not a physical completion deadline. Native callback
joins and actual downstream copy counts remain implementation obligations. Its
relationship to RuntimeOwnership is explained but not mechanically composed or
proved as a Zig/C refinement. Speaker completion is outside the ACK claim.

The next coherent implementation is C01/C02: a private pending receive block helper
with an independent prefix oracle, then fake-owner lifecycle/cleanup tests. Native
Mac qualification remains blocked by host availability; the reported Monterey OS
is still unconfirmed. First real two-host audio, sustained drift/resilience, real
pairing, UX and production packaging remain open. No universal hardware immunity,
unbounded theorem or production-readiness claim follows from this phase.
