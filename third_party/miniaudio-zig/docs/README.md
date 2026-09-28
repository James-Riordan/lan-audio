# Read the binding as an engineering argument

This package owns the Zig/C boundary to one adopted miniaudio revision. The
application owns devices, queues, endpoints, gain policy, timing and recovery.
The small source tree stays shallow; documentation is divided by the questions
an implementer needs to answer. More folders are justified by distinct ownership,
not by depth itself.

1. [Contract](CONTRACT.md): the existing public boundary and lifetime rules.
2. [Build and ABI](architecture/build-and-abi.md): follow one consumer import to
   the native implementation; distinguish enabled APIs from qualified behavior.
3. [Device lifecycle](contracts/device-lifecycle.md): acquisition, start-time
   callbacks, enumeration snapshots, teardown and failure atomicity.
4. [PCM and conversion](contracts/pcm-and-conversion.md): dimensions, conversion
   accounting, amplitude and the future drift-correction seam.
5. [Every-file handbook](reference/files.md): purpose, mechanics, failure modes,
   evidence and next action for each existing file.
6. [Upstream navigation](reference/upstream.md): precise local source anchors;
   review scope is explicit and vendor bytes remain untouched.
7. [Implementation gates](implementation/qualification.md): ordered missing
   work, proposed paths, independent tests and measurable exit conditions.
8. [Verification protocol](verification/README.md): repeatable evidence capture
   and the distinction between documentation, ABI, null and physical tests.
9. [Executable ABI qualification](verification/abi.md): C-produced layout facts,
   callback sentinel, independent consumer and strict mutation-evidence matrix.
10. [Conversion handoff](implementation/conversion-handoff.md): canonical future
    application files, prerequisite decisions and a bounded implementation order.
11. [Conversion custody](contracts/conversion-custody.md) and
    [rate-control constraints](contracts/conversion-control.md): separate clocks,
    terminal state and reproduced limitations in the adopted native implementation.
12. [Conversion verification](verification/conversion.md): independent numerical
    and failure oracles, candidate records and exact limits of current evidence.
13. [Ecosystem boundary](architecture/ecosystem-boundary.md): JCR/MetaOS ownership,
    explicit configuration stages, capability scope and Docz/Quartz migration.
14. [Adoption transaction](implementation/adoption-transaction.md) and
    [qualification records](contracts/qualification-records.md): repeatable updates,
    conflict/recovery laws, comparable diagnostics and bounded repair handoffs.
15. [Ecosystem acceptance](verification/ecosystem.md): future adapter roles,
    independent failure schedules and actual implementation gates.
16. [Source-package verification](verification/source-package.md): exact compiler
    selection, cache-noise exclusion, actual package archive and relocated consumer.
17. [Release readiness](implementation/release-readiness.md): separate source,
    ABI, native/DSP, target, runtime, license and recovery gates for Q05.

`reference/catalog.json` is the maintained exact file-to-chapter mapping.
`python tools/check_docs.py` checks it without repairing it. This is navigation
and custody evidence, not a semantic proof. The handbook is also indexed by the
consumer's existing three-project reference when that index is regenerated.

Existing adoption results remain at [VERIFICATION.md](VERIFICATION.md). New runs
belong in new `verification/` directories with source hashes and explicit scope.
The package is not yet a qualification of every exported upstream function.
