# WP09 — Reproducible distribution and rollback

Status: planned. Depends on WP01 and WP08. Acceptance: A6/A7.

| Planned file | Contract |
| --- | --- |
| `packaging/windows/package.ps1` | Assemble executable/private DLLs/licenses from verified build inputs; reject missing/wrong-target files; no global runtime installation. |
| `packaging/macos/package.sh` | Assemble Intel Mac binary/bundle and private libraries with explicit load paths/deployment target; no development-machine dependency leakage. |
| `packaging/manifest.json` | Release artifact identities, target, license notices and dependency hashes; no secrets or live sample data. |
| `tools/verify_package.py` | Read-only archive/path/dependency/custody validation; rejects traversal, missing licenses and unexpected runtime dependencies. |
| `tests/e2e/clean_install.md` | Repeatable clean-machine install/start/stop/update/uninstall and rollback procedure with evidence fields. |

Resolve authored-code license, final product identity, supported macOS floor and
signing/distribution path with the user before a public release. Never invent legal
permissions or claim a binary is signed/notarized without the actual artifacts.
Signing credentials remain outside source/evidence; package logs must not reveal them.

Replace sibling development dependencies with a reproducible release source closure
or immutable package artifacts. Build offline from that closure, validate exact
compiler/backend identities, and inspect runtime imports on clean Windows/Mac hosts.
Do not solve a load failure by changing a global library search path. Test package
locations containing spaces and non-ASCII characters and ordinary non-admin launch.

Persist settings/identities outside the application bundle with explicit ownership.
Updates preserve compatible settings and authorized peers; migration is validated
before committing and has a recovery path. Uninstall removes application resources
and explains whether user credentials/settings remain. Auto-start/firewall changes
are explicit and reversible, never hidden in a library import or test.

Exit: a clean host without the development tree runs the intended program with the
qualified runtime; update/rollback and uninstall behave as documented. Record all
remaining OS-provided dependencies and support boundaries. A successful local build
or copied executable is not a clean-install qualification.
