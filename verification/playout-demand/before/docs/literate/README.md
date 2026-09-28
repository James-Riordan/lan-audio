# An executable engineering explanation

The documentation is part of the engineering of this program. Its purpose is to
let a reader reconstruct why the design is sound, identify the assumptions under
which it works, and determine exactly what evidence is still missing. A directory
inventory and a list of future tasks do not, by themselves, meet that purpose.

The methodological references are Knuth's [literate programming](https://cs.stanford.edu/~knuth/lp.html)
and Lamport's [Specifying Systems](https://lamport.azurewebsites.net/tla/book.html).
We adopt explanation in conceptual order, explicit state machines and reviewable
reasoning. This repository is not a WEB/CWEB program, and no claim of either
author's endorsement or a machine-checked implementation proof is made.

## Reading the program as an argument

1. [Following one stream](stream-argument.md) introduces the problem and walks
   through the actual implementation in ownership order, explaining why each
   boundary exists and how it fails.
2. [Kernel mathematics](../MATHEMATICS.md) supplies definitions, representation
   invariants and local inductive arguments.
3. [Runtime ownership argument](runtime-argument.md) specifies composition,
   cancellation, bounded drain, conservation and reclamation; it connects the
   executable TLA+ model to concrete implementation obligations.
4. [Quantitative design](quantitative-design.md) derives the capacity and clock
   controller conditions that experiments must validate.
5. [Proof ledger](proof-ledger.md) records the status and next missing obligation
   for each central claim. Read it before describing anything as proved.
6. [API contracts](../reference/api-contracts.md) and [every-file reference](../reference/README.md)
   provide lookup detail after the explanation. [Implementation chapters](../implementation/roadmap.md)
   locate the remaining code and acceptance checks.

For the next runtime composition, read [ordered frame custody](../design/receive-drain.md),
then the [implementation blueprint](../implementation/runtime-blueprint.md). The
former supplies the sequence invariant and conditional progress argument; the
latter names the concrete storage/owner boundaries the future code must establish.

## What a completed explanation must contain

For an algorithm, state the problem, mathematical domain and units; define the
representation relation; explain each consequential decision; give preconditions,
postconditions and failure atomicity; justify preservation/progress; bound space
and work; identify concurrency and aliasing assumptions; link independent tests
and counterexamples. Explain why a tempting alternative is invalid where that
helps prevent a specific mistake. Repeating a function's name is not explanation.

For an adapter, add trust and lifetime boundaries, native ABI obligations, partial
initialization/cleanup order, and target-specific evidence. For a build or support
file, explain its inputs, outputs, authority, reproducibility and failure policy.
For upstream code, record the adopted contract and trust boundary without silently
modifying vendored sources. Unavailable upstream source remains a review gap.

For a formal model, state the environment, variables, initial states, actions,
safety properties, fairness assumptions, liveness claims and abstraction losses.
Provide a refinement obligation for each implementation action. Model checking,
mathematical argument and executable testing are complementary evidence with
different scopes. A green finite model is not an unbounded theorem.

## Keeping prose and code consistent

Zig and TLA+ source remain canonical for executed behavior; prose explains them.
Do not keep a second full copy of an implementation in this book. Link to the
canonical file and name the exact symbol or action. When a symbol changes, review
its API contract, this argument, the proof ledger, formal models and independent
tests together. Generated declaration lists are navigation, not semantic review.

Definitions belong in the mathematical chapters, existing behavior in API/kernel
chapters, proposed behavior in explicitly marked design chapters, and observations
in immutable verification records. An assertion must not migrate from proposed to
implemented or proved merely because a later chapter repeats it.

The current text explains the authored foundation and selected dependency
interfaces. It is not yet a paragraph-by-paragraph commentary on every upstream
miniaudio/OpenSSL function. Nor is the still-unwritten runtime proved by writing
its design specification. The proof ledger makes that remaining work concrete.
