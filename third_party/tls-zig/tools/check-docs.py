"""Read-only documentation/source integrity gate. Python 3.10+, standard library only.

Exit 0: inventory, contracts, local documentation links and artifact register agree.
Exit 1: drift or missing coverage. --self-test checks rejection using temporary copies.
Run from anywhere: python tools/check-docs.py [--self-test] [--with-sdk].
SDK verification is opt-in so source-only packages can be inspected without SDK binaries.
"""
from pathlib import Path, PurePosixPath
import argparse
import hashlib
import json
import re
import os
import shutil
import tempfile
from urllib.parse import unquote

SKIP = {'.git', '.zig-cache', '.zig-global-cache', 'zig-out', '__pycache__', 'verification'}


def digest(p):
    return hashlib.sha256(p.read_bytes()).hexdigest()


def safe(root, value):
    """Validate a canonical relative spelling and resolved containment before reading."""
    if not isinstance(value, str) or not value or ':' in value or '\\' in value:
        raise ValueError('unsafe inventory path')
    rel = PurePosixPath(value)
    if rel.is_absolute() or '..' in rel.parts or rel.as_posix() != value or value == '.':
        raise ValueError('unsafe inventory path: ' + value)
    p = root / value
    if not p.resolve().is_relative_to(root.resolve()):
        raise ValueError('unsafe resolved inventory path: ' + value)
    return p


def universe(root):
    """Prune caches, dependencies and documentation before traversing source files."""
    result = set()
    for directory, children, files in os.walk(root, followlinks=False):
        children[:] = [d for d in children if d not in SKIP | {'deps', 'docs'}]
        for name in files:
            p = Path(directory) / name
            if p.suffix != '.log': result.add(p.relative_to(root).as_posix())
    return result


def check(root, with_sdk=False):
    """Return diagnostic errors, including malformed documents; never rewrite evidence."""
    try:
        return check_contents(root, with_sdk)
    except (OSError, ValueError, KeyError, TypeError, AttributeError) as exc:
        return ['malformed or unreadable documentation: ' + str(exc)]


def check_contents(root, with_sdk=False):
    errors = []
    manifest = json.loads((root / 'docs/verification/source-inventory.json').read_text(encoding='utf-8'))
    indexed = set()
    for row in manifest['files']:
        rel = row['path']
        if rel in indexed:
            errors.append(f'duplicate inventory: {rel}')
        indexed.add(rel)
        p = safe(root, rel)
        if not p.is_file():
            errors.append(f'missing source: {rel}')
            continue
        if digest(p) != row['sha256']:
            errors.append(f'stale source contract: {rel}')
        card = safe(root, row['contract'])
        if not card.is_file():
            errors.append(f'missing contract: {rel}')
        elif f"Source SHA-256: `{row['sha256']}`" not in card.read_text(encoding='utf-8'):
            errors.append(f'contract hash disagrees: {rel}')
        if card.is_file():
            body = card.read_text(encoding='utf-8')
            source_lines = p.read_text(encoding='utf-8', errors='replace').splitlines()
            pattern = r'### `([^`]+)` — line (\d+)\s+\[Source declaration\]\([^)]+\)\s+```[^\n]*\n([^\n]+)'
            for name, line, signature in re.findall(pattern, body):
                index = int(line) - 1
                if index < 0 or index >= len(source_lines) or source_lines[index].strip() != signature.strip():
                    errors.append(f'stale declaration location: {rel}:{line} ({name})')

    actual = universe(root)
    expected = {p for p in indexed if not p.startswith('docs/')}
    for p in sorted(actual - expected):
        errors.append(f'unindexed source: {p}')
    for p in sorted(expected - actual):
        errors.append(f'inventory outside source universe: {p}')
    register = json.loads((root / 'docs/verification/artifact-register.json').read_text(encoding='utf-8'))
    registered = {row['path'] for row in register['artifacts']}
    if len(registered) != len(register['artifacts']):
        errors.append('duplicate documentation artifact registration')
    for rel in registered:
        if not safe(root, rel).is_file():
            errors.append(f'missing artifact: {rel}')
    actual_docs = {p.relative_to(root).as_posix() for p in (root / 'docs').rglob('*') if p.is_file()}
    for p in sorted(actual_docs - registered):
        errors.append(f'unregistered document: {p}')
    for p in (root / 'docs').rglob('*.md'):
        # Only engineering docs: baseline historical docs have external evidence references.
        if p.relative_to(root).as_posix() in manifest.get('historical_documents', []):
            continue
        content = re.sub(r'```.*?```', '', p.read_text(encoding='utf-8'), flags=re.S)
        for target in re.findall(r'\[[^\]\n]*\]\(([^)\n]+)\)', content):
            target = target.strip('<>')
            if re.match(r'^[a-zA-Z][a-zA-Z0-9+.-]*:', target) or target.startswith('#'):
                continue
            path = unquote(target.split('#')[0])
            if path and not (p.parent / path).resolve().exists():
                errors.append(f'broken link: {p.relative_to(root)} -> {target}')
    if with_sdk:
        dep = root / 'docs/verification/dependency-inventory.json'
        records = json.loads(dep.read_text(encoding='utf-8'))['files']
        locked = {r['path'] for r in records}
        present = {p.relative_to(root).as_posix() for p in (root/'deps/openssl-install').rglob('*') if p.is_file()}
        if locked != present:
            errors.append('SDK file set differs from dependency inventory')
        for r in records:
            p = safe(root, r['path'])
            if not p.is_file() or digest(p) != r['sha256']:
                errors.append(f'SDK mismatch: {r["path"]}')
        if records:
            backend = json.loads((root/'backend-lock.json').read_text(encoding='utf-8-sig'))
            locked_hashes = {backend['sdk_root']+'/'+r['path']:r['sha256'] for r in backend['sdk_files']}
            if locked_hashes != {r['path']:r['sha256'] for r in records}:
                errors.append('dependency inventory does not match backend-lock.json')
    return errors


def self_test(root):
    with tempfile.TemporaryDirectory(prefix='zig-docs-check-') as tmp:
        copy = Path(tmp) / root.name
        # docs/verification is source evidence, unlike root verification run scratch.
        shutil.copytree(root, copy, ignore=shutil.ignore_patterns(*(SKIP - {'verification'}), 'deps'))
        if check(copy):
            raise RuntimeError('self-test baseline failed')
        target = copy / 'src/root.zig'
        before = target.read_bytes()
        target.write_bytes(before + b'\n// injected documentation drift\n')
        if not any('stale source contract' in e for e in check(copy)):
            raise RuntimeError('source drift was not detected')
        target.write_bytes(before)
        extra = copy / 'src/undocumented-example.zig'
        extra.write_text('// temporary negative fixture\n')
        if not any('unindexed source' in e for e in check(copy)):
            raise RuntimeError('missing coverage was not detected')
        extra.unlink()
        manifest = json.loads((copy/'docs/verification/source-inventory.json').read_text())
        card = copy / manifest['files'][0]['contract']
        content = card.read_text(encoding='utf-8')
        card.write_text(content+'\n[missing](missing-negative-fixture.md)\n', encoding='utf-8')
        if not any('broken link' in e for e in check(copy)):
            raise RuntimeError('broken link was not detected')
        card.write_text(content, encoding='utf-8')
        # Verify locations even if source hashes and card hashes agree.
        card.write_text(content+'\n### `injected` — line 999999\n\n[Source declaration](x#L999999)\n\n```text\nnot a real declaration\n```\n', encoding='utf-8')
        if not any('stale declaration location' in e for e in check(copy)):
            raise RuntimeError('stale declaration location was not detected')
        card.write_text(content, encoding='utf-8')
        inventory = copy/'docs/verification/source-inventory.json'
        original_inventory = inventory.read_text(encoding='utf-8')
        bad = json.loads(original_inventory)
        bad['files'][0]['path'] = '../escape'
        inventory.write_text(json.dumps(bad), encoding='utf-8')
        if not any('unsafe' in e for e in check(copy)):
            raise RuntimeError('unsafe path was not detected')
        inventory.write_text('{malformed', encoding='utf-8')
        if not any('malformed' in e for e in check(copy)):
            raise RuntimeError('malformed JSON was not detected')
        inventory.write_text(original_inventory, encoding='utf-8')
        card.unlink()
        if not any('missing contract' in e for e in check(copy)):
            raise RuntimeError('missing contract was not detected')
    return ['source hash drift', 'unindexed file', 'broken local link', 'missing contract', 'stale declaration location', 'unsafe inventory path', 'malformed JSON']


def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument('--self-test', action='store_true')
    ap.add_argument('--with-sdk', action='store_true')
    args = ap.parse_args()
    root = Path(__file__).resolve().parents[1]
    errors = check(root, args.with_sdk)
    result = {'project': root.name, 'passed': not errors, 'errors': errors}
    if args.self_test and not errors:
        result['negative_controls_detected'] = self_test(root)
    print(json.dumps(result, indent=2))
    raise SystemExit(bool(errors))


if __name__ == '__main__':
    main()
