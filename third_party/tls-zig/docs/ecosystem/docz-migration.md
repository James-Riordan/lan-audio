# Future README.dcz and Quartz documentation migration

Status: selected direction, staged migration plan. Markdown remains the current reviewable project authority until this migration is qualified. No mass rename, deletion, installed Docz/Quartz change or automatic library import was performed. A standalone native conversion preview is supplied with this handoff, separate from canonical project documentation.

## Producer boundary observed

Docz documents a Markdown import CLI that produces .dcz plus a source-hashed conversion report. It supports a declared Markdown subset; unsupported content can be preserved inertly with diagnostics. Preserved original bytes are valuable recovery evidence but are not equivalent to fully editable, semantically rendered native constructs. Importing does not automatically adopt a document into Quartz or establish stable cross-document identity.

Quartz separates retained document/library identity from paths and presentation. A future project-document adapter should preserve project, document, revision and source anchors with explicit authority. It must not invent a second project/context registry or infer logical identity solely from the new file extension.

## Migration inventory and mapping

For each current document, record source path/hash, language/profile, stable document identity if one actually exists, title, outgoing links, file/declaration anchors, tables, mathematical notation, literal code, preserved blocks and assets. Produce an explicit old-path/anchor to new-document/anchor mapping. Anchors must distinguish a source declaration identifier from a physical line number in a particular source revision.

Keep source-contract SHA-256 and code snippets bound to actual Zig/C/tool bytes. Preserve test IDs, prerequisite IDs, receipt references and status labels as semantic data. JSON evidence/plan formats remain machine-owned interfaces unless a separately versioned migration replaces them; renaming them to .dcz would not preserve their parser contracts.

## Required gate sequence

1. Pin the adopted converter/renderer and record their exact source or executable identity and limits. Use new output paths; keep original documents and prior delivery archives.
2. Convert a representative corpus: every declaration-code form, escaped text, links, tables, Unicode, math, large file and unsupported construct used by this handoff. Retain complete conversion reports and original bytes.
3. Parse/check and render the converted artifacts. Classify every diagnostic/preserved block. Compare semantic content and literal code, not just a successful exit or nonempty output.
4. Test reverse export/recovery for supported material; record differences explicitly. Exact original bytes are recoverable only where the producer contract actually guarantees them. Preserve original source when an inverse is lossy.
5. Update documentation/source gates to understand .dcz syntax, declarations, IDs and links. Test missing/stale source hashes, broken links, renamed anchors and malformed native documents with negative fixtures.
6. Qualify Quartz open/edit/save/reopen, revision conflicts, context attribution, navigation and asset custody. Do not count CLI conversion as GUI acceptance.
7. Update build package allowlists, entry points and external consumers. Select one editable authority per migrated document; compatibility Markdown, if retained, is derived and visibly attributed. Avoid two independently editable truth sources.
8. Publish the reviewed document set and anchor/redirect manifest together under an interruption-recovery policy. Failed migration leaves the old authoritative set usable; stale generated files do not count as a successful update.

## Preview scope

The standalone sample illustrates how QUIC/TLS ecosystem text can move through the locally available Docz CLI. Its receipt records converter bytes, source/output/report hashes and actual command results. It does not migrate these projects, prove every source contract converts, test Quartz UI behavior or bind the live converter to a complete producer build receipt.

Full documentation migration is a maintenance workstream outside the 37 protocol implementation files. It should not block baseline protocol implementation; the existing Markdown/JSON handoff remains executable and reviewable while the native-document gate is developed.
