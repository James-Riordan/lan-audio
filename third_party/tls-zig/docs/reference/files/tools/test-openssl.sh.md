# `tools/test-openssl.sh`

Source: [tools/test-openssl.sh](../../../../tools/test-openssl.sh)  
Source SHA-256: `ee8b7db47b7498e5765eb915a09f7ce47013aec1fcb3c551e2eb14d4a095064c`  
Snapshot bytes: 1742. Review date: 2026-09-26.

## Responsibility

Selected upstream certificate and TLS recipe runner with native Perl recovery.

## Contract, ownership and failure behavior

Runs six selected TLS configurations and test_verify; adjusts generated wrapper/config paths for Windows. This is not the full upstream suite.

## Next implementation work

Retain explicit test selection and skip counts in receipts. Make generated-file adjustments checkable and fail on unexpected content. Portable qualification must use the platform-native harness without assuming this recovery recipe.

## Verification obligations

Run the owning build or maintenance entry point described in the [verification guide](../../../verification/strategy.md). A passive fixture/record is verified by hash and by its named consumers; it is not an executable test.
