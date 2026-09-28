"""Exercise the separately built Zig TLS server with Python's real TCP client."""

if not __debug__:
    raise SystemExit("This interoperability harness requires assertions; remove -O/PYTHONOPTIMIZE")

import os
from pathlib import Path
import queue
import socket
import ssl
import subprocess
import threading

ROOT = Path(__file__).resolve().parents[1]
EXE = ROOT / "examples/consumer/zig-out/bin/tls-tcp-consumer.exe"
REQUEST = b"GET / HTTP/1.1\r\nHost: localhost\r\n\r\n"
REPLY = b"HTTP/1.1 200 OK\r\nContent-Length: 5\r\n\r\nhello"


def case(mode):
    env = dict(os.environ, TLS_DEMO_SERVER="1", TLS_DEMO_CLIENT_CA=
               "tests/fixtures/other-ca.pem" if mode == "untrusted_client" else "tests/fixtures/ca.pem")
    process = subprocess.Popen([str(EXE)], cwd=ROOT, env=env, stdout=subprocess.PIPE,
                               stderr=subprocess.PIPE, text=True)
    ready = queue.Queue()
    reader = threading.Thread(target=lambda: ready.put(process.stdout.readline()))
    reader.start()
    try:
        line = ready.get(timeout=6)
        reader.join(timeout=1)
        assert line.startswith("PORT:"), line
        port = int(line.split(":", 1)[1])
        context = ssl.SSLContext(ssl.PROTOCOL_TLS_CLIENT)
        context.minimum_version = context.maximum_version = ssl.TLSVersion.TLSv1_3
        context.set_alpn_protocols(["http/1.1"])
        context.load_verify_locations(ROOT / "tests/fixtures/ca.pem")
        if mode != "missing_client":
            context.load_cert_chain(ROOT / "tests/fixtures/client.pem", ROOT / "tests/fixtures/client.key")
        rejected = False
        with socket.create_connection(("127.0.0.1", port), timeout=4) as raw:
            try:
                with context.wrap_socket(raw, server_hostname="localhost") as conn:
                    conn.settimeout(4)
                    if mode in ("missing_client", "untrusted_client"):
                        # TLS1.3 may finish the client side before the server has
                        # checked its certificate. Read the server alert first.
                        conn.recv(1)
                        raise AssertionError("Server did not send authentication alert")
                    for i in range(0, len(REQUEST), 5):
                        conn.sendall(REQUEST[i:i+5])
                    received = b""
                    while len(received) < len(REPLY):
                        chunk = conn.recv(2)
                        assert chunk, "Server closed before complete response"
                        received += chunk
                    assert received == REPLY
                    assert mode not in ("missing_client", "untrusted_client"), "Client authentication bypass"
                    if mode == "clean":
                        with conn.unwrap():
                            pass
                    else:
                        conn.shutdown(socket.SHUT_WR)
                        while conn.recv(4096):
                            pass
            except ssl.SSLError:
                if mode not in ("missing_client", "untrusted_client"):
                    raise
                rejected = True
        output, errors = process.communicate(timeout=5)
        if mode == "clean":
            assert process.returncode == 0 and "PASS external Zig server" in errors, errors
        else:
            expected = "TlsFailure" if mode == "raw_eof" else "PeerAuthentication"
            assert process.returncode != 0 and expected in errors and "PASS" not in errors, errors
            if mode != "raw_eof":
                assert rejected, "Python did not observe the authentication alert"
        print("PASS TCP server:", mode)
    finally:
        if process.poll() is None:
            process.kill()
        process.communicate(timeout=5)
        reader.join(timeout=1)
        assert not reader.is_alive(), "Port reader did not stop"


print("Independent TCP client:", ssl.OPENSSL_VERSION)
for mode in ("clean", "missing_client", "untrusted_client", "raw_eof"):
    case(mode)
print("4 external-consumer server TCP cases passed")
