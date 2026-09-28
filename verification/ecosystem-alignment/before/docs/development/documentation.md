# Documentation is maintained engineering data

This standard applies to authored source, tests, build scripts, models and tools.
It does not authorize changing upstream vendored bytes to add local prose. Source
contract additions belong next to the wrapper/adoption boundary when upstream
ownership is involved.

## Three complementary reading levels

1. `/docs/literate/` explains the program in conceptual order, its reasoning,
   mathematical definitions and outstanding proof obligations.
2. Domain chapters such as `/docs/protocol/` own canonical formats, transitions and
   cross-module contracts. Architecture and implementation chapters connect them
   to ownership, planned files and acceptance evidence.
3. Each source file begins with purpose, scope, ownership, side effects and a link
   to its detailed argument. Public APIs document units, lifetime, aliasing,
   failures and state changes. Local comments explain nonobvious decisions.

The [generated per-file reference](../reference/README.md) is the lookup layer.
Its contract data and declaration extraction do not replace these explanations.
One canonical chapter owns each wire field or invariant; other locations link to
it rather than keeping drifting copies.

## Definition of a documented source change

State the problem and first consumer. Specify the domain and invalid inputs.
Explain who owns every buffer and mutable field, when ownership transfers and
when storage may be reclaimed. Define the success postcondition and exactly what
failure can change. Account for overflow, truncation, aliases, partial operations,
stale generations, cancellation and platform assumptions where they apply.

Give a space/work bound and its units; distinguish asymptotic bounds from measured
execution time. Describe the representation invariant and preservation argument.
For progress, name the rank, environmental assumptions and fairness needed. Provide
an independent expectation or counterexample, then link actual source-scoped
evidence. Mark proposed behavior explicitly; do not promote a TODO to a result.

Tests themselves explain which contract they challenge, why their expected result
is independent, the tested domain/boundary, and what they do not establish. Avoid
tests that simply reproduce the implementation under another name. Golden bytes,
different data representations, reference decoders, adversarial transitions and
faulty variants can each provide useful independent evidence.

## Change checklist and authority

Update the source comment, canonical domain chapter, affected literal/reference
contract, proof ledger and work-package status in the same change. Update public
exports and tests together. Run the reference renderer and read-only documentation
checks after registering every new authored file. Preserve historical receipts;
they describe old source revisions and must not be relabeled as current proof.

The user request owns scope; product requirements own acceptance; domain contracts
own intended behavior; source describes actual behavior; verification records
describe observations. If these disagree, resolve the discrepancy explicitly and
test the repair. A passing link checker establishes navigation, not truth.
