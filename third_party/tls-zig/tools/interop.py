"""Wire interoperability using Python SSLObject (OpenSSL 3.0.18 on qualification host).

Exercises the real C backend compiled by Zig, using no listening ports or subprocesses.
The Zig public API is tested separately by zig build test.
"""

if not __debug__:
    raise SystemExit("This interoperability harness requires assertions; remove -O/PYTHONOPTIMIZE")

import ctypes as C
import hashlib
import os
from pathlib import Path
import ssl
import sys

if os.name == "nt":
    # Explicit dependency location; no installation or persistent PATH changes.
    backend_bin = Path(os.environ.get("TLS_OPENSSL_BIN", str(Path(__file__).resolve().parents[1] / "deps/openssl-install/bin"))).resolve()
    dll_dir = os.add_dll_directory(str(backend_bin))
lib = C.CDLL(str(Path(sys.argv[1]).resolve()))
P = C.c_void_p
S = C.c_size_t
lib.tz_new.argtypes = [C.c_int, C.c_char_p, C.c_char_p, C.c_char_p, C.c_char_p, C.c_int, C.c_int, C.c_int64]
lib.tz_new.restype = P
lib.tz_free.argtypes = [P]
for name in ("handshake", "flush", "shutdown", "eof"):
    getattr(lib, "tz_" + name).argtypes = [P]
for name in ("feed", "drain", "read"):
    getattr(lib, "tz_" + name).argtypes = [P, P, S, C.POINTER(S)]
lib.tz_write.argtypes = [P, P, S]
lib.tz_verified_peer_leaf_sha256.argtypes = [P, P, S]
lib.tz_version.restype = C.c_char_p
FIX = Path("tests/fixtures")

class Engine:
    def __init__(self, server, name=b"localhost", ca=b"tests/fixtures/ca.pem", mtls=False):
        self.h = lib.tz_new(server, ca, b"tests/fixtures/server.pem" if server else None,
                            b"tests/fixtures/server.key" if server else None,
                            None if server else name, 0, mtls, 1_789_300_000)
        assert self.h, "backend initialization failed"
    def close(self):
        lib.tz_free(self.h)
        self.h = None
    def drain(self):
        buf, n = C.create_string_buffer(16384), S()
        assert lib.tz_drain(self.h, buf, len(buf), C.byref(n)) >= 0
        return buf.raw[:n.value]
    def feed(self, data):
        n = S()
        assert lib.tz_feed(self.h, data, len(data), C.byref(n)) >= 0
        assert n.value == len(data)
    def read(self):
        buf, n = C.create_string_buffer(16384), S()
        status = lib.tz_read(self.h, buf, len(buf), C.byref(n))
        return status, buf.raw[:n.value]

def python_peer(server, alpn=("http/1.1",), version=ssl.TLSVersion.TLSv1_3, client_cert=False, name="localhost"):
    ctx = ssl.SSLContext(ssl.PROTOCOL_TLS_SERVER if server else ssl.PROTOCOL_TLS_CLIENT)
    ctx.minimum_version = ctx.maximum_version = version
    ctx.set_alpn_protocols(list(alpn))
    if server:
        ctx.load_cert_chain(FIX / "server.pem", FIX / "server.key")
    else:
        ctx.load_verify_locations(FIX / "ca.pem")
        if client_cert:
            ctx.load_cert_chain(FIX / "client.pem", FIX / "client.key")
    incoming, outgoing = ssl.MemoryBIO(), ssl.MemoryBIO()
    peer = ctx.wrap_bio(incoming, outgoing, server_side=server, server_hostname=None if server else name)
    return peer, incoming, outgoing

def exchange(engine, incoming, outgoing):
    # Deliberately split records across host transport fragments.
    data = engine.drain()
    for i in range(0, len(data), 137):
        incoming.write(data[i:i+137])
    data = outgoing.read()
    for i in range(0, len(data), 113):
        engine.feed(data[i:i+113])

def connect(engine, peer, incoming, outgoing):
    py_ready = False
    for _ in range(100):
        rc = lib.tz_handshake(engine.h)
        if rc < 0:
            return False
        exchange(engine, incoming, outgoing)
        try:
            peer.do_handshake()
            py_ready = True
        except (ssl.SSLWantReadError, ssl.SSLWantWriteError):
            pass
        except ssl.SSLError:
            return False
        exchange(engine, incoming, outgoing)
        if rc == 0 and py_ready:
            return True
    raise AssertionError("bounded handshake stalled")

def case(label, *, backend_server, expected=True, **kw):
    mtls = kw.pop("mtls", False)
    engine = Engine(backend_server, name=kw.pop("backend_name", b"localhost"),
                    ca=kw.pop("backend_ca", b"tests/fixtures/ca.pem"), mtls=mtls)
    try:
        digest = C.create_string_buffer(b"\xa5" * 32, 32)
        assert lib.tz_verified_peer_leaf_sha256(engine.h, digest, 32) == -4
        assert digest.raw == b"\xa5" * 32
        peer, incoming, outgoing = python_peer(not backend_server, **kw)
        ok = connect(engine, peer, incoming, outgoing)
        assert ok == expected, label
        if ok:
            if not backend_server or mtls:
                pem = (FIX / ("client.pem" if backend_server else "server.pem")).read_text()
                leaf = pem.split("-----END CERTIFICATE-----", 1)[0] + "-----END CERTIFICATE-----\n"
                expected_digest = hashlib.sha256(ssl.PEM_cert_to_DER_cert(leaf)).digest()
                assert lib.tz_verified_peer_leaf_sha256(engine.h, digest, 32) == 0
                assert digest.raw == expected_digest
            else:
                assert lib.tz_verified_peer_leaf_sha256(engine.h, digest, 32) == -4
                assert digest.raw == b"\xa5" * 32
            assert peer.version() == "TLSv1.3"
            assert peer.selected_alpn_protocol() == "http/1.1"
            payload = b"POST /echo HTTP/1.1\r\nContent-Length: 5\r\n\r\nhello"
            assert peer.write(payload) == len(payload)
            exchange(engine, incoming, outgoing)
            rc, data = engine.read()
            assert rc == 0 and data == payload
            reply = b"HTTP/1.1 200 OK\r\nContent-Length: 5\r\n\r\nhello"
            assert lib.tz_write(engine.h, reply, len(reply)) == 0
            assert lib.tz_flush(engine.h) == 0
            exchange(engine, incoming, outgoing)
            assert peer.read() == reply
            assert not peer.session_reused
            assert lib.tz_shutdown(engine.h) in (1, 2)
            exchange(engine, incoming, outgoing)
            assert peer.read() == b""
            try:
                peer.unwrap()
            except ssl.SSLWantReadError:
                pass
            exchange(engine, incoming, outgoing)
            assert lib.tz_shutdown(engine.h) == 3
            digest.raw = b"\xa5" * 32
            assert lib.tz_verified_peer_leaf_sha256(engine.h, digest, 32) == -4
            assert digest.raw == b"\xa5" * 32
        print("PASS", label)
    finally:
        engine.close()

print("Backend:", lib.tz_version().decode())
assert lib.tz_version() == b"OpenSSL 3.5.8 25 Aug 2026", "Unqualified backend loaded"
if os.name == "nt":
    kernel = C.WinDLL("kernel32", use_last_error=True)
    kernel.GetModuleHandleW.argtypes = [C.c_wchar_p]
    kernel.GetModuleHandleW.restype = P
    kernel.GetModuleFileNameW.argtypes = [P, C.c_wchar_p, C.c_uint]
    for dll in ("libssl-3-x64.dll", "libcrypto-3-x64.dll"):
        handle = kernel.GetModuleHandleW(dll)
        assert handle, f"Missing qualified module: {dll}"
        path_buffer = C.create_unicode_buffer(32768)
        assert kernel.GetModuleFileNameW(handle, path_buffer, len(path_buffer))
        loaded = Path(path_buffer.value).resolve()
        expected = Path(sys.argv[1]).resolve().parent / dll
        assert loaded == expected, f"Wrong dependency loaded: {loaded}"
        assert hashlib.sha256(loaded.read_bytes()).digest() == hashlib.sha256((backend_bin / dll).read_bytes()).digest(), f"Wrong staged DLL bytes: {loaded}"
        print("Verified loaded DLL:", loaded)
print("Independent peer:", ssl.OPENSSL_VERSION)
case("backend server / authenticated Python client roundtrip", backend_server=True)
case("backend client / Python server roundtrip", backend_server=False)
case("backend rejects wrong server hostname", backend_server=False, backend_name=b"wrong.example", expected=False)
case("backend rejects untrusted server", backend_server=False, backend_ca=b"tests/fixtures/other-ca.pem", expected=False)
case("Python client rejects wrong server hostname", backend_server=True, name="wrong.example", expected=False)
case("server rejects incompatible ALPN", backend_server=True, alpn=("h2",), expected=False)
case("server rejects missing ALPN", backend_server=True, alpn=(), expected=False)
case("client rejects missing ALPN", backend_server=False, alpn=(), expected=False)
case("server rejects TLS 1.2", backend_server=True, version=ssl.TLSVersion.TLSv1_2, expected=False)
case("client rejects TLS 1.2", backend_server=False, version=ssl.TLSVersion.TLSv1_2, expected=False)
case("mTLS accepts trusted Python client", backend_server=True, mtls=True, client_cert=True)
case("mTLS rejects absent client certificate", backend_server=True, mtls=True, expected=False)
case("mTLS rejects untrusted client chain", backend_server=True, mtls=True, client_cert=True,
     backend_ca=b"tests/fixtures/other-ca.pem", expected=False)

def final_data_during_shutdown(backend_server, clean):
    engine = Engine(backend_server)
    try:
        peer, incoming, outgoing = python_peer(not backend_server)
        assert connect(engine, peer, incoming, outgoing)
        assert lib.tz_shutdown(engine.h) == 1
        # Peer data crosses our outgoing close_notify before the peer receives it.
        for record in (b"final ", b"response"):
            assert peer.write(record) == len(record)
        if clean:
            try:
                peer.unwrap()
            except ssl.SSLWantReadError:
                pass
        exchange(engine, incoming, outgoing)
        if not clean:
            assert lib.tz_eof(engine.h) == 0
        received = b""
        for _ in range(10):
            assert lib.tz_shutdown(engine.h) == 5
            assert lib.tz_shutdown(engine.h) == 5  # Peeking does not consume data.
            status, data = engine.read()
            assert status == 0 and data
            received += data
            if received == b"final response":
                break
        assert received == b"final response"
        assert lib.tz_shutdown(engine.h) == (3 if clean else -1)
        if clean:
            peer.unwrap()
        print("PASS final peer data during shutdown / backend", "server" if backend_server else "client",
              "/", "close_notify" if clean else "raw EOF rejected")
    finally:
        engine.close()

for backend_server in (False, True):
    for clean in (False, True):
        final_data_during_shutdown(backend_server, clean)
print("17 independent-peer cases passed")
