"""Record the exact locally built SDK and read-only tool executables after building."""
from pathlib import Path
import hashlib
import json
import subprocess
import os
import tempfile

def sha256(path):
    digest = hashlib.sha256()
    with path.open("rb") as stream:
        while chunk := stream.read(1024 * 1024):
            digest.update(chunk)
    return digest.hexdigest()

def validate_version(version):
    """Reject a different backend even when Python assertions are disabled."""
    if version.splitlines()[0:1] != ["OpenSSL 3.5.8 25 Aug 2026 (Library: OpenSSL 3.5.8 25 Aug 2026)"]:
        raise ValueError("unexpected OpenSSL runtime version: " + version)


def main():
    """Explicit lock generation after an authorized build; import is read-only."""
    root = Path(__file__).resolve().parents[1]
    sdk = root / "deps/openssl-install"
    version = subprocess.check_output([str(sdk / "bin/openssl.exe"), "version", "-a"], text=True)
    validate_version(version)
    tools = [
        Path("C:/Applications/Development/zig/zig-x86_64-windows-0.17.0-dev.1859+dcceb318e/zig.exe"),
        Path("C:/Applications/Development/Strawberry/c/bin/gcc.exe"),
        Path("C:/Applications/Development/Strawberry/c/bin/ar.exe"),
        Path("C:/Applications/Development/Strawberry/c/bin/gmake.exe"),
        Path("C:/Applications/Development/msys64/usr/bin/bash.exe"),
        Path("C:/Applications/Development/msys64/usr/bin/perl.exe"),
        Path("C:/Applications/Development/Strawberry/perl/bin/perl.exe"),
        Path("C:/Applications/Development/msys64/usr/bin/msys-2.0.dll"),
    ]
    historical_make = root / "deps/msys-make/usr/bin/make.exe"
    if historical_make.exists():
        tools.append(historical_make)
    lock = {
        "backend": "OpenSSL 3.5.8 25 Aug 2026",
        "target": "x86_64-windows-gnu",
        "zig": "0.17.0-dev.1859+dcceb318e",
        "compiler": "GCC 13.2.0 / MinGW-W64 x86_64-ucrt-posix-seh",
        "source": json.loads((root / "evidence/source-provenance.json").read_text(encoding="utf-8-sig")),
        "openssl_version_a": version,
        "sdk_root": "deps/openssl-install",
        "sdk_files": [{"path": p.relative_to(sdk).as_posix(), "sha256": sha256(p)}
                      for p in sorted(sdk.rglob("*")) if p.is_file()],
        "build_tools": [{"path": str(p), "sha256": sha256(p)} for p in tools],
    }
    destination = root / "backend-lock.json"
    fd, name = tempfile.mkstemp(prefix='backend-lock.', suffix='.tmp', dir=root)
    try:
        with os.fdopen(fd, 'w', encoding='utf-8', newline='\n') as stream:
            stream.write(json.dumps(lock, indent=2) + "\n")
            stream.flush()
            os.fsync(stream.fileno())
        Path(name).replace(destination)
    finally:
        Path(name).unlink(missing_ok=True)
    print(f"Pinned {len(lock['sdk_files'])} SDK files and {len(tools)} build tools")


if __name__ == "__main__":
    main()
