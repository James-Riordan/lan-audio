# Source-package closure and relocation

This gate qualifies the dependency's selected source files and a public consumer
on the current host. It is one part of Q05, not application distribution, native
Mac support, licensing clearance or reproducible binary output.

## Defects found in the previous package declaration

The original root `.paths` selected whole `tests`, `tools` and `docs` directories.
The pinned compiler's actual `zig fetch --debug-hash` selected 71 files from a
43-file authored/vendor baseline: it omitted `.gitignore` and included 29 generated
files under nested consumer `.zig-cache` and Python `__pycache__` directories.
The compiler-cache files included executables, object files and a native library.
A clean source tar of that baseline selected only 42 authored files. Thus package
identity could depend on local test history, and its handbook catalogue named a
file absent from the selected package.

These were source-selection observations, not a published release incident. The
earlier Q01 checks ran from the working tree and did not claim clean packaging.
Ignoring caches in the documentation inventory or `.gitignore` did not prevent
their inclusion through directory-wide `.paths` entries in this compiler.

The corrected `build.zig.zon` lists exact authored/vendor files, including the
catalogued `.gitignore`. No directory recursively admits future files. New source,
test, tool or documentation files require both an intentional package-list entry
and their handbook contract. The verifier detects mismatch; it never edits either
list to make them agree. Root package identity, compiler floor, dependency set and
vendor adoption remain unchanged.

## Executable qualification

From the package root, with the exact qualification compiler installed:

```text
python tools/test_package.py --output verification/source-package-new
```

Choose a new output directory. `--zig` selects an executable and `--timeout`
sets each subprocess bound. In-project output must be beneath `verification/`;
an external workspace directory is also allowed. The tool writes evidence,
source copies, two deterministic source tars and private compiler/build caches.
It never cleans an old run, edits the source list, changes pins or opens a device.

The runner executes the following dependency chain:

1. Validate the exact documentation/source inventory, hash all authored/vendor
   files, require the exact compiler version recorded by this qualification and
   check package-manifest formatting before expensive compilation.
2. Ask the compiler for the live directory's selected paths and opaque package
   identity. Require exactly the inventoried authored/vendor set.
3. Copy those files to a location containing spaces and a non-ASCII character.
   Add controlled compiler-cache, Python-bytecode, unreviewed-document and evidence
   sentinels. Require the same compiler-selected paths and package identity.
4. Create two source tars from the explicit closure using sorted paths, fixed
   permissions and zero timestamps/owner metadata. Their SHA-256 values must match.
   Feed one tar to the compiler and require the same selection/package identity.
5. Read the pinned compiler's generated package-cache archive, validate its exact
   regular-file members and source hashes, and extract to another spaced/non-ASCII
   directory. Reject extra, duplicate, linked or changed members.
6. Run documentation and vendor checks from that relocated package. Build and run
   the existing independent public consumer in Debug/native and ReleaseSafe/null
   profiles, each using a distinct fresh local cache. Require an actual executed
   one-test witness; cached compilation is allowed, cached test results are not.
7. Recheck live authored inventory/hashes and relocated authored hashes. Mark the
   receipt complete only when every required step succeeded.

The compiler debug-file record syntax and generated cache archive layout are
version-specific observations of the pinned compiler, not a stable cross-version
Zig API. A compiler change must deliberately requalify this adapter. The debug
record's hexadecimal value is not treated as the ordinary content SHA-256; the
runner calculates its own file digests. Package hash and tar SHA-256 have distinct
encodings/meanings, and neither is a trust or signature claim.

## Failures and evidence interpretation

`receipt.json` records source identities, commands, return codes, durations, log
digests, package identity, tar digests, injected noise and final status. Failure
leaves the receipt incomplete with a reason and retained logs. Timeout/launch
failure cannot become a successful negative test. Timeout terminates the direct
process only; inspect descendants before any cleanup. Compiler warnings, including
temporary-directory cleanup warnings, remain in the recorded logs.

The runner validates a self-created known source archive and the corresponding
compiler result. It is not a general hostile-archive ingestion service: no claim
of arbitrary compressed-size/expansion-ratio limits follows. Required exact member
names, regular-file types and content hashes still reject contamination at this
boundary. Source input reads/builds are not atomic with unrelated concurrent edits;
end-of-run consistency rejects observed drift. Coordinate writers for a stable run.

Seven independent Python tests in `tests/test_package_runner.py` exercise malformed,
duplicate and unsafe compiler records; missing/leaked paths; fresh versus cached
test witnesses; deterministic archive round trip; changed contents; and linked,
duplicate or unexpected archive entries. They use temporary synthetic fixtures,
not the real source tree or the native compiler.

## Scope of a pass

A successful run establishes this exact source closure, cache-noise exclusion,
location independence of its package identity under the tested paths, identical
source-tar bytes under this tar recipe, and two fresh public-consumer executions
on the observed host/compiler. It adds real archive-derived consumer evidence to
the earlier working-tree consumer, without repeating the entire Q01 matrix.

It does not prove binary byte-for-byte reproducibility, hermetic compiler/bootstrap
execution, a clean OS installation, dynamic runtime-library loading in LAN Audio,
code-signing/notarization, all optimization/profile combinations, Linux/Mac execution,
physical audio or admissible public redistribution. Keep the compiler/OS runtime
and authored-code license gates in the [release plan](../implementation/release-readiness.md).

Top-level `verification/` history is intentionally outside the source package.
Historical links/commands that refer to a delivered evidence bundle require that
bundle; they are not additional runtime dependencies or newly executed results.
The archive contains current source tests and documentation, not old native binaries.
