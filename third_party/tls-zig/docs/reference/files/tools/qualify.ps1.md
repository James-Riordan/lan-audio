# `tools/qualify.ps1`

Source: [tools/qualify.ps1](../../../../tools/qualify.ps1)  
Source SHA-256: `7918b074ef0e4012bfb7d969b46dfc1a6d60e06bf5fbf86ad0047bf3d89c6cc0`  
Snapshot bytes: 2703. Review date: 2026-09-26.

## Responsibility

Qualification entry point with independent exact SDK verification.

## Contract, ownership and failure behavior

The existing compiler-version and SDK availability checks remain. The entry point now invokes tools/verify-backend.py and refuses nonzero exit without suggesting automatic repinning; missing, extra, changed or unsafe SDK paths are rejected before tests. It then runs the existing test/host-test/interop/example steps, checks formatting and restores environment variables in finally. The verifier's disk check does not establish actual loaded runtime identity (T07).

## Verification

See [T00 implementation status](../../../verification/t00-implementation.md). Retain command outputs and keep source inventory and acceptance evidence current.

Before verification, the qualification profile binds the lock backend, SDK root, compiler version and target to the same fixed paths used by native builds. This prevents verification of a different directory from authorizing the actual build. Offline entry-point tests observe failure before any build for each mismatched field and for an extra SDK file.
