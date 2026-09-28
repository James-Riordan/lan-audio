# `tools/test-backend.py`

Source: [tools/test-backend.py](../../../../tools/test-backend.py)  
Source SHA-256: `e055e8c522a0fd777bc3b4d2831e057c406ed8e0bd880f934d9bfc19208eb8fb`  
Snapshot bytes: 14684. Review date: 2026-09-26.

## Responsibility

Offline adversarial SDK, acquisition, pin-version and interop-guard acceptance tests.

## Contract, ownership and failure behavior

Disposable standard-library fixtures; no network or installed SDK modification. Unittest checks remain active under -O. The verifier is invoked as a subprocess with fixed known digests and exact byte snapshots, independently of its file enumerator. Fake range responses cover exact boundaries, wrong status/range/encoding, short/long bodies and retry exhaustion. A synthetic tarball supplies independently known extracted bytes; interrupted/silently incomplete extraction, retained stale trees and failed promotion are tested. Interop guards are invoked without runtime arguments to prove early refusal. Windows reparse rejection uses an actual symlink if permitted, otherwise injected lstat flags; this fallback is not native junction qualification. T00-01/T00-02 remain separate from native provider qualification.

## Verification

See [T00 implementation status](../../../verification/t00-implementation.md). Retain command outputs and keep source inventory and acceptance evidence current.

## Declaration contracts

### `load` — line 24

[Source declaration](../../../../tools/test-backend.py#L24)

```python
def load(name):
```

Independent fixture assertion or setup; owned temporary resources end at test cleanup. No network or live SDK effects.

### `snapshot` — line 36

[Source declaration](../../../../tools/test-backend.py#L36)

```python
def snapshot(root):
```

Independent fixture assertion or setup; owned temporary resources end at test cleanup. No network or live SDK effects.

### `BackendTests` — line 40

[Source declaration](../../../../tools/test-backend.py#L40)

```python
class BackendTests(unittest.TestCase):
```

Independent fixture assertion or setup; owned temporary resources end at test cleanup. No network or live SDK effects.

### `setUp` — line 41

[Source declaration](../../../../tools/test-backend.py#L41)

```python
    def setUp(self):
```

Independent fixture assertion or setup; owned temporary resources end at test cleanup. No network or live SDK effects.

### `save_lock` — line 56

[Source declaration](../../../../tools/test-backend.py#L56)

```python
    def save_lock(self, lock):
```

Independent fixture assertion or setup; owned temporary resources end at test cleanup. No network or live SDK effects.

### `check_cli` — line 59

[Source declaration](../../../../tools/test-backend.py#L59)

```python
    def check_cli(self, passed):
```

Independent fixture assertion or setup; owned temporary resources end at test cleanup. No network or live SDK effects.

### `test_exact_set_changed_missing_extra` — line 68

[Source declaration](../../../../tools/test-backend.py#L68)

```python
    def test_exact_set_changed_missing_extra(self):
```

Independent fixture assertion or setup; owned temporary resources end at test cleanup. No network or live SDK effects.

### `test_unsafe_and_ambiguous_manifest_paths` — line 78

[Source declaration](../../../../tools/test-backend.py#L78)

```python
    def test_unsafe_and_ambiguous_manifest_paths(self):
```

Independent fixture assertion or setup; owned temporary resources end at test cleanup. No network or live SDK effects.

### `test_duplicate_and_malformed_manifest` — line 92

[Source declaration](../../../../tools/test-backend.py#L92)

```python
    def test_duplicate_and_malformed_manifest(self):
```

Independent fixture assertion or setup; owned temporary resources end at test cleanup. No network or live SDK effects.

### `test_link_rejected` — line 108

[Source declaration](../../../../tools/test-backend.py#L108)

```python
    def test_link_rejected(self):
```

Independent fixture assertion or setup; owned temporary resources end at test cleanup. No network or live SDK effects.

### `test_pin_version_check_unconditional` — line 120

[Source declaration](../../../../tools/test-backend.py#L120)

```python
    def test_pin_version_check_unconditional(self):
```

Independent fixture assertion or setup; owned temporary resources end at test cleanup. No network or live SDK effects.

### `test_interop_refuses_disabled_assertions_before_side_effects` — line 126

[Source declaration](../../../../tools/test-backend.py#L126)

```python
    def test_interop_refuses_disabled_assertions_before_side_effects(self):
```

Independent fixture assertion or setup; owned temporary resources end at test cleanup. No network or live SDK effects.

### `qualification_fixture` — line 133

[Source declaration](../../../../tools/test-backend.py#L133)

```python
    def qualification_fixture(self):
```

Invoke the real PowerShell entry with fake compiler and disposable SDK.

### `test_qualification_binds_verified_root_and_profile` — line 153

[Source declaration](../../../../tools/test-backend.py#L153)

```python
    def test_qualification_binds_verified_root_and_profile(self):
```

Independent fixture assertion or setup; owned temporary resources end at test cleanup. No network or live SDK effects.

### `test_qualification_rejects_extra_sdk_before_build` — line 165

[Source declaration](../../../../tools/test-backend.py#L165)

```python
    def test_qualification_rejects_extra_sdk_before_build(self):
```

Independent fixture assertion or setup; owned temporary resources end at test cleanup. No network or live SDK effects.

### `AcquisitionTests` — line 177

[Source declaration](../../../../tools/test-backend.py#L177)

```python
class AcquisitionTests(unittest.TestCase):
```

Independent fixture assertion or setup; owned temporary resources end at test cleanup. No network or live SDK effects.

### `setUp` — line 178

[Source declaration](../../../../tools/test-backend.py#L178)

```python
    def setUp(self):
```

Independent fixture assertion or setup; owned temporary resources end at test cleanup. No network or live SDK effects.

### `archive` — line 187

[Source declaration](../../../../tools/test-backend.py#L187)

```python
    def archive(self, files):
```

Independent fixture assertion or setup; owned temporary resources end at test cleanup. No network or live SDK effects.

### `opener` — line 196

[Source declaration](../../../../tools/test-backend.py#L196)

```python
    def opener(self, mode='valid'):
```

Independent fixture assertion or setup; owned temporary resources end at test cleanup. No network or live SDK effects.

### `respond` — line 197

[Source declaration](../../../../tools/test-backend.py#L197)

```python
        def respond(request, timeout):
```

Independent fixture assertion or setup; owned temporary resources end at test cleanup. No network or live SDK effects.

### `acquire` — line 210

[Source declaration](../../../../tools/test-backend.py#L210)

```python
    def acquire(self, **kwargs):
```

Independent fixture assertion or setup; owned temporary resources end at test cleanup. No network or live SDK effects.

### `test_complete_and_repeat_without_network` — line 216

[Source declaration](../../../../tools/test-backend.py#L216)

```python
    def test_complete_and_repeat_without_network(self):
```

Independent fixture assertion or setup; owned temporary resources end at test cleanup. No network or live SDK effects.

### `test_ranges_errors_and_wrong_digest_never_promote` — line 223

[Source declaration](../../../../tools/test-backend.py#L223)

```python
    def test_ranges_errors_and_wrong_digest_never_promote(self):
```

Independent fixture assertion or setup; owned temporary resources end at test cleanup. No network or live SDK effects.

### `test_multiple_ranges_exact_boundaries` — line 237

[Source declaration](../../../../tools/test-backend.py#L237)

```python
    def test_multiple_ranges_exact_boundaries(self):
```

Independent fixture assertion or setup; owned temporary resources end at test cleanup. No network or live SDK effects.

### `test_interrupted_extraction_and_configure_only_recovery` — line 244

[Source declaration](../../../../tools/test-backend.py#L244)

```python
    def test_interrupted_extraction_and_configure_only_recovery(self):
```

Independent fixture assertion or setup; owned temporary resources end at test cleanup. No network or live SDK effects.

### `interrupt` — line 249

[Source declaration](../../../../tools/test-backend.py#L249)

```python
        def interrupt(archive, stage):
```

Independent fixture assertion or setup; owned temporary resources end at test cleanup. No network or live SDK effects.

### `test_extractor_silent_omission_rejected` — line 264

[Source declaration](../../../../tools/test-backend.py#L264)

```python
    def test_extractor_silent_omission_rejected(self):
```

Independent fixture assertion or setup; owned temporary resources end at test cleanup. No network or live SDK effects.

### `incomplete` — line 265

[Source declaration](../../../../tools/test-backend.py#L265)

```python
        def incomplete(archive, stage):
```

Independent fixture assertion or setup; owned temporary resources end at test cleanup. No network or live SDK effects.

### `test_modified_complete_tree_preserved_and_replaced` — line 274

[Source declaration](../../../../tools/test-backend.py#L274)

```python
    def test_modified_complete_tree_preserved_and_replaced(self):
```

Independent fixture assertion or setup; owned temporary resources end at test cleanup. No network or live SDK effects.

### `test_promotion_failure_restores_old_tree` — line 283

[Source declaration](../../../../tools/test-backend.py#L283)

```python
    def test_promotion_failure_restores_old_tree(self):
```

Independent fixture assertion or setup; owned temporary resources end at test cleanup. No network or live SDK effects.

### `fail_candidate` — line 288

[Source declaration](../../../../tools/test-backend.py#L288)

```python
        def fail_candidate(path, target):
```

Independent fixture assertion or setup; owned temporary resources end at test cleanup. No network or live SDK effects.

### `test_archive_traversal_and_links_rejected` — line 298

[Source declaration](../../../../tools/test-backend.py#L298)

```python
    def test_archive_traversal_and_links_rejected(self):
```

Independent fixture assertion or setup; owned temporary resources end at test cleanup. No network or live SDK effects.

The real PowerShell qualification entry is also tested using a disposable SDK and a compiler fixture. Wrong backend/root/compiler/target metadata and extra SDK files fail before the compiler can create a build marker. Requires pwsh; this native Windows run contains no skipped cases.
