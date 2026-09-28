# `evidence/build-recovery.md`

Source: [evidence/build-recovery.md](../../../../evidence/build-recovery.md)  
Source SHA-256: `62da642c146947480514adee7190f6b64a0f1c08156d0dda452afe6ff69085e9`  
Snapshot bytes: 3242. Review date: 2026-09-26.

## Responsibility

Historical provenance, checkpoint or handoff record.

## Contract, ownership and failure behavior

Preserve recorded paths, dates, source selection and result attribution. Older relocation targets and test counts are historical data, not current instructions or fresh test evidence.

## Next implementation work

Use docs/verification/current.md for this handoff. For a new run, write a new dated receipt tied to current hashes; do not rewrite an old success record to cover new source.

## Verification obligations

Run the owning build or maintenance entry point described in the [verification guide](../../../verification/strategy.md). A passive fixture/record is verified by hash and by its named consumers; it is not an executable test.
