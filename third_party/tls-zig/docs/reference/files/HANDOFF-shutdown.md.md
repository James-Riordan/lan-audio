# `HANDOFF-shutdown.md`

Source: [HANDOFF-shutdown.md](../../../HANDOFF-shutdown.md)  
Source SHA-256: `ad78248b14893bfb5cc746facba0e9fa9798ac140928891d28d4df584a4389cb`  
Snapshot bytes: 2172. Review date: 2026-09-26.

## Responsibility

Historical provenance, checkpoint or handoff record.

## Contract, ownership and failure behavior

Preserve recorded paths, dates, source selection and result attribution. Older relocation targets and test counts are historical data, not current instructions or fresh test evidence.

## Next implementation work

Use docs/verification/current.md for this handoff. For a new run, write a new dated receipt tied to current hashes; do not rewrite an old success record to cover new source.

## Verification obligations

Run the owning build or maintenance entry point described in the [verification guide](../../verification/strategy.md). A passive fixture/record is verified by hash and by its named consumers; it is not an executable test.
