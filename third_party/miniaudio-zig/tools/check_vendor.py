"""Read-only vendor custody check. Hashes establish bytes, not upstream trust or API safety."""
import hashlib
import json
from pathlib import Path

root = Path(__file__).resolve().parents[1]
manifest = json.loads((root / "UPSTREAM.json").read_text(encoding="utf-8"))
for relative, expected in manifest["files"].items():
    path = (root / relative).resolve()
    if not path.is_relative_to(root):
        raise SystemExit(f"unsafe vendor path: {relative}")
    actual = hashlib.sha256(path.read_bytes()).hexdigest()
    if actual != expected:
        raise SystemExit(f"vendor mismatch: {relative}")
print(f"PASS: {len(manifest['files'])} unchanged upstream files at {manifest['commit']}")
