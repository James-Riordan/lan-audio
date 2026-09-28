# `backend-lock.json`

Source: [backend-lock.json](../../../backend-lock.json)  
Source SHA-256: `d4d905865bddf009683d703345873bf4fba06ba742a26d5bf2079dee1df7c2ef`  
Snapshot bytes: 27737. Review date: 2026-09-26.

## Responsibility

Exact historical SDK/build-tool provenance lock.

## Contract, ownership and failure behavior

Verify every listed SDK hash and exact file set. A version string alone is insufficient; the lock does not prove a source rebuild is byte-reproducible.

## Next implementation work

Use check-docs.py --with-sdk for read-only current-byte verification. Regenerate only after a deliberately qualified backend build, preserving the prior lock as evidence.

## Verification obligations

Run the owning build or maintenance entry point described in the [verification guide](../../verification/strategy.md). A passive fixture/record is verified by hash and by its named consumers; it is not an executable test.
