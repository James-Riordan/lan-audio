# `HANDOFF-tcp-consumer.md`

Source: [HANDOFF-tcp-consumer.md](../../../HANDOFF-tcp-consumer.md)  
Source SHA-256: `553c72bb57fe9ad49580aad89d30c3e607dda63e96720f9a04fba0d04e9a9f71`  
Snapshot bytes: 1833. Review date: 2026-09-26.

## Responsibility

Historical provenance, checkpoint or handoff record.

## Contract, ownership and failure behavior

Preserve recorded paths, dates, source selection and result attribution. Older relocation targets and test counts are historical data, not current instructions or fresh test evidence.

## Next implementation work

Use docs/verification/current.md for this handoff. For a new run, write a new dated receipt tied to current hashes; do not rewrite an old success record to cover new source.

## Verification obligations

Run the owning build or maintenance entry point described in the [verification guide](../../verification/strategy.md). A passive fixture/record is verified by hash and by its named consumers; it is not an executable test.
