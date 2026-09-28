# Literate explanation and composed specification revision

This revision makes the engineering explanation an explicit maintained part of
the project. It adds a conceptual stream narrative, a runtime ownership argument,
quantitative queue/controller derivations and a twelve-claim proof ledger. Root
navigation now leads to `docs/literate/README.md`; the implementation guide remains
available for exact file destinations. A file inventory is not described as a
substitute for explaining the program.

## Executed checks

| Model | Normal distinct states | Required defective variants |
| --- | ---: | --- |
| RuntimeOwnership | 3,925 | early_free violates LiveStorage; stop_wait violates temporal Progress |
| SessionWindow | 1,171 | Four expected invariant counterexamples |
| EndDrain | 29 | Three expected invariant counterexamples |
| SpscPublication | 29 | Two expected NoCorruption counterexamples |

All four normal models and all eleven expected counterexamples pass their runner
criteria. `*-final.json` and `model-commands.json` contain actual outputs, source,
configuration, runner and jar identities and command results. RuntimeOwnership
uses two-frame queues, prefill two, three captured frames, two generations and two
logical drain ticks. It checks custody/idle emptiness/callback ownership/live
storage/authorized use and conditional stop/drain progress. Its refinement to a
future production runtime remains open.

The first runtime-model execution was rejected by TLC because negated unbound
Boolean variables in Init did not enumerate their initial values. It was repaired
to use explicit FALSE assignments. The failed source, outputs and command are
preserved as `runtime-attempt1.tla`, `runtime-model-attempt1.json` and
`runtime-command-attempt1.json`. They are a specification development failure,
not a passing counterexample or evidence of a runtime defect. A subsequent normal
run preceded the final explicit IdleEmpty invariant and final runner hash changes;
use the `*-final.json` files for current results.

The ideal PI derivation was additionally checked at 1,305 points by independently
evaluating polynomial roots, including stable and unstable points; numerical
unit-circle boundary points were excluded. All classifications agree. This
corroborates algebra for the stated linear model; it does not qualify any real
controller, gains, resampler or device. Details are in `controller-root-check.json`.

Exact reference coverage and local documentation/import checks are recorded in
the final receipt. The inventory has 298 entries, including seven new authored
files: five explanation chapters and the composed model/configuration. There are
132 authored/support entries and 166 installed SDK assets. Their existence or
length is not treated as a correctness metric.

## Revision boundaries

Sixty-six pre-edit application files were preserved in `before/` with hashes in
`before.json`. Historical verification records, production Zig sources, dependency
sources, SDK bytes and adoption locks were not edited. The model runner gained
the composed profile, expected temporal-failure classification and additional
configuration/runner identity recording. No physical audio, network streaming or
native product qualification was rerun for this documentation/model revision.

Open work is explicit: complete production runtime and its refinement; partial
initialization and multi-buffer models; weak-memory/target obligations; measured
NIC fault envelope; delayed/saturated clock-controller analysis; native Mac and
real two-host qualification. No universal perfection, author endorsement, vendor
source audit or whole-system computer-checked proof is claimed.
