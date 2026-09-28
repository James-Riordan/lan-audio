# Implementation entry point

The user wants a highly robust, fidelity-first Windows-to-Mac LAN audio product.
Documentation is part of the product's engineering: read `docs/literate/README.md`
and maintain explanations, assumptions, invariants, proof obligations and evidence
alongside the code. File inventories and work packages do not substitute for this.
Start at `docs/implementation/START_HERE.md`, then select the first unmet work
package whose dependencies are satisfied. The files describe proposed work as
proposed; do not claim an interface exists because it appears in the handbook.

Keep `src/root.zig` as the stable core import. Native audio is the separate
`audio_host` module. Preserve sibling library ownership and reviewed dependency
pins. Do not promote application concepts into new packages without real consumers.

Make a complete, bounded path work before adding the next layer. Test behavior,
ownership and failure recovery. Update affected contracts and acceptance evidence
alongside implementation. Do not modify historical results to imply fresh success.
Do not silently rehash changed dependencies to make custody checks pass.

Callbacks must not allocate, block, log, perform network I/O or control devices.
Device/queue storage stays fixed until all owners are quiescent. Public test
credentials, frozen fixture clocks and loopback socket adapters never become
production identity or networking defaults.

Use the pinned Zig version. Consult actual target/toolchain documentation when
implementing platform details. Run only checks relevant to the change; physical
capture is an explicit separate check. Read-only handbook checks are
`python tools/check_docs.py` and `python tools/check_handoff.py`.

No document can guarantee universal perfection. Completion means the named
acceptance criteria pass with recorded sources, tools, targets and limits.
