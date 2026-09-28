# `tools/interop.py`

Source: [tools/interop.py](../../../../tools/interop.py)  
Source SHA-256: `49ceb9cb3baadf03b262ec67eafdba3551174a1610117aab076a0342b6d97e8c`  
Snapshot bytes: 10676. Review date: 2026-09-26.

## Responsibility

Runner for 17 in-memory backend/Python TLS interoperability cases.

## Contract, ownership and failure behavior

Honor bounded timeouts, preserve peer error output and clean up owned resources. Runtime/backend versions and case outcomes must be recorded. Existing interop assertions require normal Python mode; the new check tools use unconditional failures.

## Next implementation work

Run this runner after the producer and required separate consumer are built. Missing prerequisites must fail clearly, never be counted as a pass. Extend negative cases with independent peer expectations; do not weaken assertions to accommodate a regression.

## Verification obligations

Run the owning build or maintenance entry point described in the [verification guide](../../../verification/strategy.md). A passive fixture/record is verified by hash and by its named consumers; it is not an executable test.

## Declaration-by-declaration work map

Each entry points to the exact current source. Adjacent source documentation is retained below. Direct error names and assigned self fields are mechanically extracted navigation cues; they exclude transitive errors, pointer writes and full branch reasoning. Use the module contract above for obligations.

### `__init__` — line 37

[Source declaration](../../../../tools/interop.py#L37)

```python
def __init__(self, server, name=b"localhost", ca=b"tests/fixtures/ca.pem", mtls=False):
```

Review `__init__` as part of this file’s responsibility: Runner for 17 in-memory backend/Python TLS interoperability cases. Preserve the stated ownership/failure contract when extending this entry point.

Directly assigned owner fields in the syntactic region: `h`.

### `close` — line 42

[Source declaration](../../../../tools/interop.py#L42)

```python
def close(self):
```

Review `close` as part of this file’s responsibility: Runner for 17 in-memory backend/Python TLS interoperability cases. Preserve the stated ownership/failure contract when extending this entry point.

Directly assigned owner fields in the syntactic region: `h`.

### `drain` — line 45

[Source declaration](../../../../tools/interop.py#L45)

```python
def drain(self):
```

Review `drain` as part of this file’s responsibility: Runner for 17 in-memory backend/Python TLS interoperability cases. Preserve the stated ownership/failure contract when extending this entry point.

### `feed` — line 49

[Source declaration](../../../../tools/interop.py#L49)

```python
def feed(self, data):
```

Review `feed` as part of this file’s responsibility: Runner for 17 in-memory backend/Python TLS interoperability cases. Preserve the stated ownership/failure contract when extending this entry point.

### `read` — line 53

[Source declaration](../../../../tools/interop.py#L53)

```python
def read(self):
```

Review `read` as part of this file’s responsibility: Runner for 17 in-memory backend/Python TLS interoperability cases. Preserve the stated ownership/failure contract when extending this entry point.

### `python_peer` — line 58

[Source declaration](../../../../tools/interop.py#L58)

```python
def python_peer(server, alpn=("http/1.1",), version=ssl.TLSVersion.TLSv1_3, client_cert=False, name="localhost"):
```

Review `python_peer` as part of this file’s responsibility: Runner for 17 in-memory backend/Python TLS interoperability cases. Preserve the stated ownership/failure contract when extending this entry point.

### `exchange` — line 72

[Source declaration](../../../../tools/interop.py#L72)

```python
def exchange(engine, incoming, outgoing):
```

Review `exchange` as part of this file’s responsibility: Runner for 17 in-memory backend/Python TLS interoperability cases. Preserve the stated ownership/failure contract when extending this entry point.

### `connect` — line 81

[Source declaration](../../../../tools/interop.py#L81)

```python
def connect(engine, peer, incoming, outgoing):
```

Review `connect` as part of this file’s responsibility: Runner for 17 in-memory backend/Python TLS interoperability cases. Preserve the stated ownership/failure contract when extending this entry point.

### `case` — line 100

[Source declaration](../../../../tools/interop.py#L100)

```python
def case(label, *, backend_server, expected=True, **kw):
```

Review `case` as part of this file’s responsibility: Runner for 17 in-memory backend/Python TLS interoperability cases. Preserve the stated ownership/failure contract when extending this entry point.

### `final_data_during_shutdown` — line 183

[Source declaration](../../../../tools/interop.py#L183)

```python
def final_data_during_shutdown(backend_server, clean):
```

Review `final_data_during_shutdown` as part of this file’s responsibility: Runner for 17 in-memory backend/Python TLS interoperability cases. Preserve the stated ownership/failure contract when extending this entry point.

## T00 implementation update

Entry refuses -O/PYTHONOPTIMIZE before imports with runtime or network side effects; existing assertion-based test oracles remain required.

## Verified peer leaf export increment

Real C ABI/Python SSLObject interoperability additionally checks digest denial before handshakes, verified server/client fingerprints against Python PEM-to-DER SHA-256, no-client-verification denial, and unchanged output after closing. Independent Python peer TLS and qualified backend DLLs remain distinct. The harness still rejects Python -O before effects. Existing cases and assertions remain active.

See the [identity guide](../../../guides/peer-identity.md) for the application boundary and current evidence.
