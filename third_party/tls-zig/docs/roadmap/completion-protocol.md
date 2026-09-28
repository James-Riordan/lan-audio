# Work lifecycle and completion evidence, schema 2

The shared plan now supports real progress without removing prerequisites or inventing a separate bookkeeping system. The current shared plan records implementation progress; historical preparation receipts preserve the earlier all-planned state. `tools/check-plan.py` validates metadata/source/evidence consistency; `tools/test-plan-lifecycle.py` exercises synthetic positive and negative fixtures. Neither tool executes the recorded build commands or attests that a reviewer told the truth.

## States

| State | Source rule | Evidence rule |
| --- | --- | --- |
| planned | future source path absent | evidence null; design status says not implemented |
| in_progress | source may be absent; any existing source has current inventory/hash/contract | evidence null; card says in progress |
| implemented | source exists with matching source-bound contract | evidence null; acceptance/qualification still incomplete |
| complete | source and current contract exist; all prerequisite nodes complete | canonical completion receipt passes scope/hash/acceptance/dependency checks |

Keep the design card at its stable path and update its status line; keep prior decisions and acceptance text. Add a separate current source contract in docs/reference/files when code exists. This preserves design intent and supports source-specific documentation. Both plan copies must remain byte-identical. A full shared plan containing any completed node requires `--peer`; both projects' completion evidence is then checked.

The current graph is not an append-only audit log. A legitimate reopening changes the node to implemented/in_progress and sets evidence null, retaining old receipt files as history. Reopen dependent complete nodes transitively if a prerequisite is no longer complete. Stale hashes fail checks; they are not silently refreshed. Capture the reason in the file card/decision history. There is no automatic transition, approval, pin update or source generation.

## Receipt location and required fields

Use `docs/verification/completions/<package-id>.json`. Register the receipt and logs as documentation artifacts. Schema 1 receipt fields:

| Field | Meaning / enforced check |
| --- | --- |
| schema, node, status | integer schema 1, exact package ID, passed status |
| obligation_sha256 | SHA-256 of canonical JSON node fields excluding status/evidence; produced by checker.fingerprint |
| design_sha256 | exact current design-card bytes, including status and original acceptance list |
| created_utc | parseable timezone-bearing ISO timestamp; attribution, not proof of execution |
| reviewer, scope_review | nonempty attribution and explanation of exercised input closure / adequacy |
| remaining_gaps | empty for completion; unresolved required work means implemented/in_progress |
| environment | recorded zig, target, os and backend descriptions |
| inputs | unique project/path/SHA-256 references to exact source, build, configuration and contract inputs |
| runs | unique IDs; argument arrays, relative cwd, mode, zero integer exit, passed outcome, hash-bound retained stdout/stderr |
| acceptance | every current test ID exactly once, passed outcome, observed assertions and links to retained run IDs |
| dependencies | every prerequisite exactly once, bound to that completed node's receipt path/project/hash |

Mandatory local inputs include the package source, design card, current source contract, src/root.zig, build.zig and build.zig.zon; TLS also includes backend-lock.json. Add every actual source, fixture, tool, policy and backend input used by the run, including peer-project inputs. Input paths must remain contained and hashes must match. Added unrelated files do not automatically stale a receipt; changed referenced inputs do.

The checker does not infer the complete transitive compile/import/runtime closure. The scope review must explain it, using build dependency manifests or an independently enumerated closure where practical. A shallow input list that meets the mechanical minimum is insufficient review evidence. Any source change relevant to a claimed test requires rerunning/reviewing that claim even if someone omitted the file from inputs.

Each run must be referenced by an acceptance observation; every acceptance obligation needs at least one run. Failed, skipped or missing outcomes cannot close a package. The full design-card acceptance list, relevant native Debug/ReleaseSafe tests, consumer, interop, resource and target gates still apply. Mode labels and zero exits are recorded data, not verification that the required native matrix actually ran. Lifecycle fixtures use explicitly synthetic logs to test validation without claiming native execution.

## Exact authoring procedure

1. Update both node states and design-card status; add/register current source contracts and build exports. Run documentation checks.
2. Execute relevant commands with pinned inputs. Retain actual stdout/stderr and failures; do not edit logs to turn a failure into success.
3. Author observed assertions for every acceptance ID and review earlier design cases. Record the input closure and environment; classify any remaining gap honestly.
4. Set status complete only when all prerequisites are complete. Write the canonical receipt with the current obligation/design hashes and prerequisite receipt hashes. The receipt never includes its own hash; dependents bind it after it exists.
5. Run both documentation gates, `check-plan.py --self-test --peer <other-root>`, and lifecycle tests. Review the actual observations and release gate separately. A green consistency check cannot confer production readiness.

`python tools/test-plan-lifecycle.py` and its Python -O equivalent provide a reproducible schema example in disposable files: a completed cross-project dependency, reopening, in-progress documentation and planned state. They also reject failed/skipped outcomes, unsafe/stale logs, source/design/obligation drift, missing cases, unknown run IDs, incomplete scope, dependency drift and concealed implementation. No synthetic receipt is installed in the actual completion directory.
