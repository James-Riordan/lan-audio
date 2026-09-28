# Executable session and playout model

`SessionWindow.tla` composes the serialized lifecycle with a bounded media window.
`SessionWindow.cfg` checks two generations, three positions per generation and
capacity two. Payloads are abstracted to `(generation, position)` records. Input
reordering, loss (absence), repetition, stale generations, callback admission,
callback completion, stop and restart are nondeterministic actions.

The model checks type preservation, authenticated streaming, quiescence before
idle/reuse, current-generation bounded buffering and at-most-once media positions.
Stop completion is checked **under weak fairness of callback return and stop
completion**. A permanently hung callback violates that environment assumption;
the model does not claim the operating system will repair it.

Run from the project root with a separately obtained official TLC 1.7.4 jar and
Java 17 (both explicit command arguments; neither is installed by this project):

```powershell
python tools/check_models.py --java PATH_TO_JAVA --jar PATH_TO_TLA2TOOLS
```

The runner executes the normal model plus four deliberately defective variants.
They must fail the expected invariants: unauthenticated start, stale-generation
admission, early teardown and duplicate playout. Counterexamples test whether the
properties detect those defects; they do not prove that every defect is covered.
Temporary configurations/states are isolated and removed by the runner. Output is
a JSON result; archive it with tool/source hashes and commands for reproducibility.

The refinement map and manual induction argument are in
[`../docs/MATHEMATICS.md`](../docs/MATHEMATICS.md). There is no machine-checked
refinement proof from Zig or upstream C, no verified weak-memory implementation,
and no model of TLS, clock drift, packet parsing or real device scheduling.

Primary method reference: Leslie Lamport,
[Specifying Systems](https://lamport.azurewebsites.net/tla/book.html), especially
safety, liveness, fairness and refinement. The model is original project work.

`EndDrain.tla` / `EndDrain.cfg` cover the implemented receiver's exclusive terminal
frontier. Invoke the same runner with `--model EndDrain`. Capacity is two and the
position domain has three elements. Safety requires bounded buffering below END,
no post-END admission, and an empty buffer/exact frontier when done. Weak fairness
of tick yields eventual drain after END. Three mutants must violate those properties.
The current model explores 29 distinct states; raw output is retained with transport
qualification. The initially ambiguous Boolean assignment in the mutation observer
was parenthesized after the mutation run exposed an incompletely specified successor;
the corrected model and all three detection checks pass. This repair concerns the
specification, not a runtime bug or a hidden successful earlier check.
