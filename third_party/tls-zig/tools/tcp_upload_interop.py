"""Early response over real TCP; consumer injects would-block after 17 body ciphertext bytes."""

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
REPLY = b"HTTP/1.1 413 Content Too Large\r\nContent-Length: 5\r\n\r\nhello"


def case(mode):
    context = ssl.SSLContext(ssl.PROTOCOL_TLS_SERVER)
    context.minimum_version = context.maximum_version = ssl.TLSVersion.TLSv1_3
    context.set_alpn_protocols(["http/1.1"])
    context.load_cert_chain(ROOT / "tests/fixtures/server.pem", ROOT / "tests/fixtures/server.key")
    failures = []
    stop = threading.Event()
    with socket.socket() as listener:
        listener.bind(("127.0.0.1", 0))
        listener.listen(1)
        listener.settimeout(8)

        def serve():
            try:
                raw, _ = listener.accept()
                with raw:
                    raw.settimeout(5)
                    with context.wrap_socket(raw, server_side=True) as conn:
                        request = b""
                        while not request.endswith(b"\r\n\r\n"):
                            chunk = conn.recv(1)
                            assert chunk
                            request += chunk
                            assert len(request) <= 256
                        assert request == b"POST / HTTP/1.1\r\nHost: localhost\r\nContent-Length: 32768\r\n\r\n"
                        for i in range(0, len(REPLY), 3):
                            conn.sendall(REPLY[i:i + 3])
                        if mode in ("blocked_deadline", "blocked_cancel"):
                            assert stop.wait(5)
                            return
                        body = b""
                        while len(body) < 16384:
                            chunk = conn.recv(16384 - len(body))
                            assert chunk, "Accepted block was truncated"
                            body += chunk
                        assert body == b"k" * 16384
                        # The advertised second block must never arrive.
                        assert conn.recv(1) == b"", "Unexpected second body block"
                        if mode == "clean":
                            with conn.unwrap():
                                pass
                        elif mode == "no_close":
                            assert stop.wait(5)
                        else:
                            conn.shutdown(socket.SHUT_WR)
                            while conn.recv(4096):
                                pass
            except BaseException as exc:
                failures.append(exc)

        worker = threading.Thread(target=serve)
        worker.start()
        env = dict(os.environ, TLS_DEMO_PORT=str(listener.getsockname()[1]),
                   TLS_DEMO_SERVER="0", TLS_DEMO_NAME="localhost", TLS_DEMO_UPLOAD_PROBE="1",
                   TLS_DEMO_UPLOAD_MS="400" if mode == "blocked_deadline" else "3000",
                   TLS_DEMO_CANCEL_MS="200" if mode == "blocked_cancel" else "0",
                   TLS_DEMO_HOLD_OUTPUT="1" if mode.startswith("blocked_") else "0",
                   TLS_DEMO_TIMEOUT_MS="300" if mode == "no_close" else "3000")
        started = time.monotonic()
        try:
            result = subprocess.run([str(EXE)], cwd=ROOT, env=env, capture_output=True, text=True, timeout=12)
        finally:
            stop.set()
            worker.join(8)
        assert not worker.is_alive(), "Server did not terminate"
        assert not failures, failures
        output = result.stdout + result.stderr
        assert "OBSERVED early final headers" in output, output
        if mode == "clean":
            assert result.returncode == 0 and "PASS early response" in output, output
        else:
            expected = {"blocked_deadline": "OperationDeadline", "blocked_cancel": "Canceled",
                        "no_close": "OperationDeadline", "raw_eof": "TlsFailure"}[mode]
            assert result.returncode != 0 and expected in output and "PASS" not in output, output
            assert time.monotonic() - started < 2, "Failure exceeded bounded deadline/cancel cadence"
        print("PASS early-response TCP:", mode)


print("Independent TCP server:", ssl.OPENSSL_VERSION)
print("Transport fixture: real TCP with deterministic send would-block after 17 ciphertext bytes")
for mode in ("clean", "blocked_deadline", "blocked_cancel", "raw_eof", "no_close"):
    case(mode)
print("5 early-response TCP cases passed")
