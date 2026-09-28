"""Read-only exact SDK verifier; never regenerate locks or execute SDK binaries.

Usage: python tools/verify-backend.py [--root PROJECT] [--lock LOCK]
Checks remain active under Python -O. Build-tool paths are historical provenance,
not a requirement to retain the original builder's directory layout. Python 3.12+.
"""
from pathlib import Path, PurePosixPath
import argparse
import hashlib
import json
import re
import stat


def relative(value):
    """Require portable canonical paths without Windows aliases or device names."""
    if not isinstance(value, str) or not value:
        raise ValueError('expected nonempty relative path')
    path = PurePosixPath(value)
    if path.is_absolute() or path.as_posix() != value or value == '.':
        raise ValueError('noncanonical relative path: ' + value)
    for part in path.parts:
        if (part in ('.', '..') or part.endswith((' ', '.'))
                or any(ord(c) < 32 or c in '\\:<>"|?*' for c in part)
                or re.fullmatch(r'(?i:CON|PRN|AUX|NUL|COM[0-9¹²³]|LPT[0-9¹²³])', part.split('.')[0])):
            raise ValueError('unsafe relative path: ' + value)
    return path


def no_link(path):
    """Reject symlinks and Windows reparse points before traversal or reads."""
    info = path.lstat()
    if stat.S_ISLNK(info.st_mode) or getattr(info, 'st_file_attributes', 0) & 0x400:
        raise ValueError('linked/reparse SDK path: ' + str(path))
    return info


def file_set(sdk):
    """Enumerate regular files; unreadable paths and special files fail closed."""
    if not stat.S_ISDIR(no_link(sdk).st_mode):
        raise ValueError('SDK root must be a directory')
    result, aliases, pending = set(), set(), [sdk]
    while pending:
        for path in pending.pop().iterdir():
            rel = path.relative_to(sdk).as_posix()
            relative(rel)
            if rel.casefold() in aliases:
                raise ValueError('case-aliased SDK path: ' + rel)
            aliases.add(rel.casefold())
            info = no_link(path)
            if stat.S_ISDIR(info.st_mode):
                pending.append(path)
            elif stat.S_ISREG(info.st_mode):
                result.add(rel)
            else:
                raise ValueError('nonregular SDK file: ' + rel)
    return result


def sha256(path):
    """Stream the complete file without loading or modifying it."""
    with path.open('rb') as stream:
        return hashlib.file_digest(stream, 'sha256').hexdigest()


def unique_object(pairs):
    """Reject duplicate JSON keys instead of accepting the last value."""
    result = {}
    for key, value in pairs:
        if key in result:
            raise ValueError('duplicate JSON key: ' + key)
        result[key] = value
    return result


def verify(root, lock_path):
    """Validate manifest, exact file set and digests; return scoped evidence."""
    root = root.resolve(strict=True)
    lock = json.loads(lock_path.read_text(encoding='utf-8-sig'), object_pairs_hook=unique_object)
    if not isinstance(lock, dict):
        raise ValueError('lock must be an object')
    sdk_rel = relative(lock.get('sdk_root'))
    sdk = root
    for part in sdk_rel.parts:
        sdk = sdk / part
        no_link(sdk)
    rows = lock.get('sdk_files')
    if not isinstance(rows, list) or not rows:
        raise ValueError('sdk_files must be a nonempty list')
    expected, aliases = {}, set()
    for row in rows:
        if not isinstance(row, dict):
            raise ValueError('SDK file entry must be an object')
        rel = relative(row.get('path')).as_posix()
        digest = row.get('sha256')
        if not isinstance(digest, str) or not re.fullmatch('[0-9a-f]{64}', digest):
            raise ValueError('invalid SHA-256: ' + rel)
        if rel.casefold() in aliases:
            raise ValueError('duplicate/case-aliased lock path: ' + rel)
        aliases.add(rel.casefold())
        expected[rel] = digest
    actual = file_set(sdk)
    missing, extra = sorted(expected.keys() - actual), sorted(actual - expected.keys())
    if missing or extra:
        raise ValueError(f'SDK file set mismatch: missing={missing}, extra={extra}')
    changed = [rel for rel, digest in expected.items() if sha256(sdk / rel) != digest]
    if changed:
        raise ValueError('SDK hash mismatch: ' + ', '.join(changed))
    return dict(passed=True, sdk_root=sdk_rel.as_posix(), files=len(actual),
                lock_sha256=sha256(lock_path), scope='SDK file set and bytes; not loaded-runtime identity')


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--root', type=Path, default=Path(__file__).resolve().parents[1])
    parser.add_argument('--lock', type=Path)
    args = parser.parse_args()
    try:
        result = verify(args.root, args.lock or args.root / 'backend-lock.json')
    except (OSError, ValueError, TypeError) as exc:
        result = dict(passed=False, error=str(exc))
    print(json.dumps(result, indent=2))
    return 0 if result['passed'] else 1


if __name__ == '__main__':
    raise SystemExit(main())
