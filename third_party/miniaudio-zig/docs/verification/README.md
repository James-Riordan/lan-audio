# Reproduce evidence without overstating it

Run from the package root with the compiler identified in `build.zig.zon` and
record its actual `zig version` output. These commands are currently available:

```text
python tools/check_vendor.py
python tools/check_docs.py
python -m unittest discover -s tests -p test_check_docs.py -v
python -m unittest discover -s tests -p test_abi_runner.py -v
zig build test -j1 --summary all
zig build test -j1 -Dnull-backend=true --summary all
zig build test -j1 -Doptimize=ReleaseSafe --summary all
```

The Python tests challenge the new documentation gate in temporary directories.
They do not open devices, modify adoption pins or use the network. Native tests
select the null backend explicitly; default compilation still includes native
backend code. Execute only checks relevant to a change. A prose-only update does
not require repeatedly rebuilding every target.

## What each result establishes

| Evidence | Positive meaning | Does not establish |
| --- | --- | --- |
| Vendor check | Adopted header/license bytes match manifest | Trusted release signature, upstream correctness, vulnerability absence |
| Documentation gate | Exact inventoried files have real chapter anchors; source symbols and local links resolve; vendor custody agrees | Truth of prose, completeness of upstream review, behavior of planned files |
| Gate mutation tests | Specific malformed/missing documentation cases fail without repairing files | A complete Markdown parser or arbitrary hostile-filesystem security |
| Existing three native tests | Version constants, frame units, defaults, explicit null context/device init/uninit | Full ABI layout agreement, active callbacks, physical playback |
| Downstream application tests | The named consumer exercises its own boundary at its recorded revision | Qualification of every exported upstream API |
| Q01 ABI probes and mutations | Native C and Zig layout/callback agreement and deliberate mismatch rejection for tested types/profile | Arbitrary callers' memory safety, other target qualification |
| Independent package consumer | Public module wiring and native symbol/configuration-return behavior | Application deployment or physical audio |
| Conversion-control characterization | Adopted generic-rate quantization and phase-overflow examples reproduce in silent C-only builds | A corrected converter, fine clock control, numerical quality or physical playback |
| Future physical run | Named device/OS/profile works within recorded conditions | Other hardware, indefinite uptime, acoustic fidelity outside measurement |

## A receipt is an observation

Write new logs/results under a unique `verification/<phase>/`; keep work copies
outside the authored source inventory. Record UTC timestamp, command/working
directory, exit code, elapsed time, stdout/stderr, OS/architecture/compiler,
source hashes and relevant profile. Include failures and unsupported/unexecuted
checks. Hash the evidence with a receipt outside its own hash input set.

Source hashes bind an observation to bytes. They are not new adoption authority.
Never change `UPSTREAM.json` or the application's TLS lock just to make a gate
green. An unrelated sibling change may invalidate the application's reference or
transport check; record the mismatch and let its owner reconcile the adoption.

Documentation changes preserve [the historical adoption report](../VERIFICATION.md).
Do not rewrite it to imply tests reran or hardware became available. The current
phase report will name exactly which checks actually executed.

For the implemented Q01 matrix use [ABI verification](abi.md). The runner writes
to a new evidence directory, checks exact runtime witnesses for deliberate faults,
and refuses to count compilation failure or a cached result as qualification.

For Q04 preparation use [conversion verification](conversion.md). Its exploratory
probe records known limitations as such. A successful defect reproduction must
never be reclassified as successful adaptive-resampler qualification.

The [ecosystem acceptance plan](ecosystem.md) defines future read-only inspection,
report comparison, candidate isolation, publication/recovery and Docz migration
gates. Its finite specification exercises establish only their named abstract
examples, not OS crash durability or implemented ecosystem adapters.

For Q05's source-closure subgate use [source-package verification](source-package.md).
It tests actual compiler selection and archive-derived consumer execution, while
keeping clean-machine product loading, physical audio and licensing gates open.
