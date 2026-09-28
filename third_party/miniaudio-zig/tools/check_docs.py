"""Read-only exact handbook coverage, navigation, source-anchor and custody gate.

This deliberately supports the handbook's simple inline Markdown links and
explicit HTML anchor IDs, not the full Markdown grammar. It never infers semantic
correctness, repairs a catalogue, updates adoption hashes or accesses the network.
See docs/reference/files.md#docs-check for schema, scope and failure obligations.
"""
from __future__ import annotations

import argparse
import hashlib
import json
import os
from pathlib import Path, PurePosixPath
import re

GENERATED_DIRS = {'.git', '.zig-cache', '.zig-global-cache', 'zig-out', '__pycache__'}
VENDOR_FILES = {'vendor/miniaudio/miniaudio.h', 'vendor/miniaudio/LICENSE'}


def unique_object(pairs):
    """Reject duplicate JSON keys instead of silently keeping the last value."""
    result = {}
    for key, value in pairs:
        if key in result:
            raise ValueError(f'duplicate JSON key: {key}')
        result[key] = value
    return result


def read_json(path):
    return json.loads(path.read_text(encoding='utf-8-sig'), object_pairs_hook=unique_object)


def contained(root, relative):
    """Resolve a canonical repository-relative catalogue path, never an escape."""
    if not isinstance(relative, str) or not relative or '\\' in relative or ':' in relative:
        raise ValueError(f'invalid relative path: {relative!r}')
    posix = PurePosixPath(relative)
    if posix.is_absolute() or '..' in posix.parts or posix.as_posix() != relative:
        raise ValueError(f'invalid relative path: {relative!r}')
    result = (root / relative).resolve()
    if not result.is_relative_to(root):
        raise ValueError(f'path outside root: {relative}')
    return result


def inventory(root):
    """Prune reproducible caches and top-level observations, keeping unknown files."""
    files = set()
    errors = []
    for directory, dirs, names in os.walk(root, followlinks=False):
        base = Path(directory)
        dirs[:] = sorted(d for d in dirs if d not in GENERATED_DIRS
                         and not (base == root and d == 'verification'))
        for name in list(dirs):
            child = base / name
            if child.is_symlink() or not child.resolve().is_relative_to(root):
                errors.append(f'unsupported linked directory: {child.relative_to(root)}')
                dirs.remove(name)
        for name in names:
            path = base / name
            rel = path.relative_to(root).as_posix()
            if path.is_symlink() or not path.resolve().is_relative_to(root):
                errors.append(f'unsupported linked file: {rel}')
            else:
                files.add(rel)
    return files, errors


def explicit_ids(text):
    return re.findall(r'<a\s+id="([^"]+)"\s*>', text)


def check(root):
    """Return diagnostics; imports and calls never modify the inspected root."""
    root = Path(root).resolve()
    if not root.is_dir():
        return [f'missing root: {root}']
    actual, errors = inventory(root)
    try:
        catalog = read_json(root / 'docs/reference/catalog.json')
        if not isinstance(catalog, dict) or catalog.get('schema') != 1:
            raise ValueError('unsupported catalogue schema')
        entries = catalog['files']
        anchors = catalog['source_anchors']
        if not isinstance(entries, list) or not isinstance(anchors, dict):
            raise ValueError('files must be a list; source_anchors must be an object')
    except (OSError, ValueError, KeyError, TypeError) as exc:
        return errors + [f'catalogue error: {exc}']

    declared = set()
    text_cache = {}

    def text(path):
        if path not in text_cache:
            text_cache[path] = path.read_text(encoding='utf-8-sig')
        return text_cache[path]

    for entry in entries:
        try:
            if not isinstance(entry, dict) or set(entry) != {'path', 'reference', 'anchor'}:
                raise ValueError('entry requires exactly path, reference and anchor')
            rel = entry['path']
            contained(root, rel)
            if rel in declared:
                errors.append(f'duplicate indexed path: {rel}')
            declared.add(rel)
            reference = contained(root, entry['reference'])
            if reference.suffix != '.md':
                raise ValueError('reference must be Markdown')
            anchor = entry['anchor']
            if not isinstance(anchor, str) or not re.fullmatch(r'[a-z0-9-]+', anchor):
                raise ValueError('invalid reference anchor')
            if anchor not in explicit_ids(text(reference)):
                errors.append(f'missing reference anchor: {rel}: {anchor}')
        except (OSError, ValueError, KeyError, TypeError) as exc:
            errors.append(f'entry error: {exc}')
    errors.extend(f'unindexed file: {p}' for p in sorted(actual - declared))
    errors.extend(f'missing indexed file: {p}' for p in sorted(declared - actual))

    for rel, snippets in anchors.items():
        try:
            path = contained(root, rel)
            if rel not in declared:
                errors.append(f'unindexed source anchor file: {rel}')
            if not isinstance(snippets, list) or not snippets or any(
                    not isinstance(s, str) or not s.strip() for s in snippets):
                raise ValueError(f'nonempty source snippets required: {rel}')
            source = text(path)
            for snippet in snippets:
                if snippet not in source:
                    errors.append(f'missing source anchor: {rel}: {snippet}')
        except (OSError, ValueError, TypeError) as exc:
            errors.append(f'source anchor error: {exc}')

    for rel in sorted(actual):
        if not rel.endswith('.md'):
            continue
        try:
            path = root / rel
            prose = re.sub(r'```[\s\S]*?```', '', text(path))
            prose = re.sub(r'`[^`\n]*`', '', prose)
            ids = explicit_ids(prose)
            if len(ids) != len(set(ids)):
                errors.append(f'duplicate explicit anchor: {rel}')
            for destination in re.findall(r'\]\(([^)]+)\)', prose):
                destination = destination.strip('<>')
                if re.match(r'[A-Za-z][A-Za-z0-9+.-]*:', destination):
                    continue
                target, _, fragment = destination.partition('#')
                resolved = (path.parent / target).resolve() if target else path
                if not resolved.is_relative_to(root):
                    errors.append(f'local link outside root: {rel}: {destination}')
                elif not resolved.exists():
                    errors.append(f'broken local link: {rel}: {destination}')
                elif fragment and (resolved.suffix != '.md' or
                                   fragment not in explicit_ids(text(resolved))):
                    errors.append(f'broken local anchor: {rel}: {destination}')
        except (OSError, ValueError) as exc:
            errors.append(f'Markdown error: {rel}: {exc}')

    try:
        manifest = read_json(root / 'UPSTREAM.json')
        files = manifest['files']
        if not isinstance(files, dict) or set(files) != VENDOR_FILES:
            raise ValueError('vendor manifest must name the adopted header and license exactly')
        for rel, expected in files.items():
            if not isinstance(expected, str) or not re.fullmatch('[0-9a-f]{64}', expected):
                raise ValueError(f'invalid vendor digest: {rel}')
            actual_digest = hashlib.sha256(contained(root, rel).read_bytes()).hexdigest()
            if actual_digest != expected:
                errors.append(f'vendor mismatch: {rel}')
    except (OSError, ValueError, KeyError, TypeError) as exc:
        errors.append(f'vendor manifest error: {exc}')
    return errors


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--root', type=Path, default=Path(__file__).resolve().parents[1])
    args = parser.parse_args()
    errors = check(args.root)
    if errors:
        print('\n'.join(errors))
        return 1
    count = len(inventory(args.root.resolve())[0])
    print(f'PASS: {count} files mapped; local links, explicit anchors, source snippets and vendor custody checked')
    return 0


if __name__ == '__main__':
    raise SystemExit(main())
