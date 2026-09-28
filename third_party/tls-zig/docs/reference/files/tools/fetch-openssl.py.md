# `tools/fetch-openssl.py`

Source: [tools/fetch-openssl.py](../../../../tools/fetch-openssl.py)  
Source SHA-256: `45f60f7284910375d14959e4dee8d9c1a844907262369b33721f93788ec7a734`  
Snapshot bytes: 7098. Review date: 2026-09-26.

## Responsibility

Acquire the unchanged pinned OpenSSL release with verified staging.

## Contract, ownership and failure behavior

No I/O occurs on import. acquire uses the existing version, size, SHA-256 and HTTPS URL. download accepts only exact 206 range/status/length/encoding, retries each range at most four times and verifies the complete size/hash before replacing the archive. Unique partial files are removed on ordinary exception. archive_files rejects path aliases, escapes, links and special files; matches compares complete regular-file bytes. extract_verified extracts into a unique same-parent staging directory and verifies every expected file before publication. A lone Configure never establishes completion.

A stale destination is renamed to a unique retained sibling, never deleted. If publication raises, restore it. Two renames are not an atomic exchange: a process kill between them may leave no final tree, but never publishes partial extraction. A later invocation creates new staging; abandoned partial/staging/retained paths are not trusted. Existing correct trees are verified against the archive and reused. One acquisition owner per destination, trusted writable parent; no concurrent-writer guarantee or live download was qualified in T00. Python 3.12+.

T00-02 uses offline fake HTTP and synthetic archives, exact independent file maps and promotion/extraction fault injection. This script does not build/install an SDK or modify backend-lock.json.

## Verification

See [T00 implementation status](../../../verification/t00-implementation.md). Retain command outputs and keep source inventory and acceptance evidence current.

## Declaration contracts

### `sha256` — line 23

[Source declaration](../../../../tools/fetch-openssl.py#L23)

```python
def sha256(path):
```

Part of the file contract above; preserve explicit failure checks, ownership and read/write boundaries.

### `download` — line 28

[Source declaration](../../../../tools/fetch-openssl.py#L28)

```python
def download(dest, url, size, digest, *, opener=urllib.request.urlopen, pause=time.sleep, step=262_144):
```

Retry bounded byte ranges; publish archive only after exact size/hash.

### `archive_files` — line 68

[Source declaration](../../../../tools/fetch-openssl.py#L68)

```python
def archive_files(archive, top):
```

Build expected byte map; reject aliases, links, special files and escapes.

### `matches` — line 92

[Source declaration](../../../../tools/fetch-openssl.py#L92)

```python
def matches(tree, expected):
```

Compare exact regular-file bytes; reject linked directories and extra files.

### `extract_verified` — line 110

[Source declaration](../../../../tools/fetch-openssl.py#L110)

```python
def extract_verified(dest, top, *, extractor=None):
```

Verify every extracted file before rename; retain displaced trees.

Same-parent rename publishes a complete tree. Replacing a stale tree takes
two renames, not an atomic exchange. Exceptions restore the old tree. A kill
between renames leaves a backup and no incomplete final tree; next invocation
starts from fresh staging. Requires one acquisition owner per destination.

### `acquire` — line 145

[Source declaration](../../../../tools/fetch-openssl.py#L145)

```python
def acquire(deps, *, url=URL, size=SIZE, digest=SHA256, version=VERSION,
```

Fetch/extract under caller-owned directory; no partial promotion on error.

### `main` — line 156

[Source declaration](../../../../tools/fetch-openssl.py#L156)

```python
def main():
```

Part of the file contract above; preserve explicit failure checks, ownership and read/write boundaries.
