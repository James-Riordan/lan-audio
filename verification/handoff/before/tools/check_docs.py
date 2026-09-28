"""Read-only local-link and file-map gate for both audio repositories.

This checks navigation completeness only. It cannot establish that a description
or proof is correct. Vendor payloads retain upstream documentation and provenance.
"""
from pathlib import Path
import re

root = Path(__file__).resolve().parents[1]
projects = ((root, root / "docs/ARCHITECTURE.md"), (root.parent / "miniaudio-zig", root.parent / "miniaudio-zig/docs/FILES.md"))
ignored = {".git", ".zig-cache", "zig-out", "__pycache__", "verification", "states"}
errors = []
count = 0
for project, map_path in projects:
    mapping = map_path.read_text(encoding="utf-8")
    for path in project.rglob("*"):
        relative = path.relative_to(project)
        if not path.is_file() or any(part in ignored for part in relative.parts):
            continue
        count += 1
        if f"`{relative.as_posix()}`" not in mapping:
            errors.append(f"unmapped file: {path}")
        if path.suffix != ".md":
            continue
        prose = re.sub(r"```[\s\S]*?```", "", path.read_text(encoding="utf-8"))
        prose = re.sub(r"`[^`\n]*`", "", prose)
        for destination in re.findall(r"\]\(([^)]+)\)", prose):
            target = destination.strip("<>").split("#", 1)[0]
            if not target or re.match(r"[A-Za-z][A-Za-z0-9+.-]*:", target):
                continue
            if not (path.parent / target).exists():
                errors.append(f"broken local link: {path}: {target}")
if errors:
    raise SystemExit("\n".join(errors))
print(f"PASS: {count} authored/vendor files mapped; local Markdown targets exist (anchors not checked)")
