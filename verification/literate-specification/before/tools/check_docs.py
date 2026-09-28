"""Read-only local-link and reference-index gate for the three admitted projects.

This checks navigation completeness only. It cannot establish that a description
or proof is correct. Vendor payloads retain upstream documentation and provenance.
"""
from pathlib import Path
import json
import re
from build_reference import inventory

root = Path(__file__).resolve().parents[1]
index = json.loads((root / 'docs/reference/file-index.json').read_text(encoding='utf-8'))
indexed = {(item['project'], item['path']) for item in index['entries']}
errors = []
count = 0
for project, relative, path in inventory():
    count += 1
    if (project, relative) not in indexed:
        errors.append(f"unmapped file: {path}")
    if path.suffix != '.md': continue
    prose = re.sub(r"```[\s\S]*?```", "", path.read_text(encoding='utf-8'))
    prose = re.sub(r"`[^`\n]*`", "", prose)
    for destination in re.findall(r"\]\(([^)]+)\)", prose):
        target = destination.strip('<>').split('#', 1)[0]
        if not target or re.match(r'[A-Za-z][A-Za-z0-9+.-]*:', target): continue
        if not (path.parent / target).exists():
            errors.append(f"broken local link: {path}: {target}")
if errors:
    raise SystemExit("\n".join(errors))
print(f"PASS: {count} authored/vendor files mapped; local Markdown targets exist (anchors not checked)")
