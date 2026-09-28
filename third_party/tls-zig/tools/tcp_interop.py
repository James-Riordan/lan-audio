"""Run the separately built Zig consumer against a real loopback Python TLS server."""

if not __debug__:
    raise SystemExit("This interoperability harness requires assertions; remove -O/PYTHONOPTIMIZE")

import os
from pathlib import Path
import socket
import ssl
import subprocess
import threading
import time

ROOT = Path(__file__).resolve().parents[1]
EXE = ROOT / "examples/consumer/zig-out/bin/tls-tcp-consumer.exe"
REPLY = b"HTTP/1.1 200 OK\r\nContent-Length: 5\r\n\r\nhello"

def case(mode):
    context = ssl.SSLContext(ssl.PROTOCOL_TLS_SERVER)
    context.minimum_version = context.maximum_version = ssl.TLSVersion.TLSv1_3
    context.set_alpn_protocols(["http/1.1"])
    context.load_cert_chain(ROOT / "tests/fixtures/server.pem", ROOT / "tests/fixtures/server.key")
    failures = []
    stop_server = threading.Event()
    with socket.socket() as listener:
        listener.bind(("127.0.0.1", 0))
        listener.listen(1)
        listener.settimeout(8)
        def serve():
            try:
                raw, _ = listener.accept()
                with raw:
                    raw.settimeout(5)
                    try:
                        conn = context.wrap_socket(raw, server_side=True)
                    except ssl.SSLError:
                        if mode == "wrong_name":
                            return
                        raise
                    with conn:
                        assert mode != "wrong_name", "Untrusted hostname was accepted"
                        assert conn.selected_alpn_protocol() == "http/1.1"
                        request = b""
                        while b"\r\n\r\n" not in request:
                            chunk = conn.recv(7)
                            assert chunk, "Unexpected client closure before request"
                            request += chunk
                            assert len(request) <= 256
                        assert request == b"GET / HTTP/1.1\r\nHost: localhost\r\n\r\n"
                        if mode.startswith("stall_"):
                            assert stop_server.wait(5), "Client did not enforce cancellation/deadline"
                            return
                        for i in range(0, len(REPLY), 3):
                            conn.sendall(REPLY[i:i+3])
                        if mode == "clean":
                            with conn.unwrap():
                                pass
                        else:
                            # Send a TCP FIN without TLS close_notify. Drain the raw
                            # client bytes so closing with unread data cannot send RST.
                            conn.shutdown(socket.SHUT_WR)
                            while conn.recv(4096):
                                pass
            except BaseException as exc:
                failures.append(exc)
        worker = threading.Thread(target=serve)
        worker.start()
        env = dict(os.environ, TLS_DEMO_PORT=str(listener.getsockname()[1]),
                   TLS_DEMO_SERVER="0",
                   TLS_DEMO_NAME="wrong.example" if mode == "wrong_name" else "localhost",
                   TLS_DEMO_TIMEOUT_MS="250" if mode == "stall_deadline" else "3000",
                   TLS_DEMO_CANCEL_MS="100" if mode == "stall_cancel" else "0")
        started = time.monotonic()
        try:
            result = subprocess.run([str(EXE)], cwd=ROOT, env=env, capture_output=True, text=True, timeout=15)
        finally:
            stop_server.set()
            worker.join(timeout=8)
        assert not worker.is_alive(), "Server did not terminate"
        assert not failures, failures
        output = result.stdout + result.stderr
        if mode == "clean":
            assert result.returncode == 0 and "authenticated close_notify" in output, output
        else:
            expected = {"wrong_name": "PeerAuthentication", "raw_eof": "TlsFailure",
                        "stall_deadline": "OperationDeadline", "stall_cancel": "Canceled"}[mode]
            assert result.returncode != 0 and expected in output and "PASS" not in output, output
            if mode.startswith("stall_"):
                assert time.monotonic() - started < 2, "Stall handling exceeded bounded poll/deadline"
        print("PASS TCP consumer:", mode)

print("Independent TCP server:", ssl.OPENSSL_VERSION)
for mode in ("clean", "raw_eof", "wrong_name", "stall_deadline", "stall_cancel"):
    case(mode)
print("5 external-consumer TCP cases passed")
