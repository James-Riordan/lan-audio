"""Read-only custody gate for the admitted TLS source, SDK and public fixtures.

Exact source/SDK hashes are reviewed adoption inputs. This program neither refreshes
them nor repairs files. Staged DLL checks bind the installed probe to that same SDK;
they are not an audit of every Windows system component or a signature check.
"""
import argparse
import hashlib
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]

def verify(staged=False):
    lock = json.loads((ROOT / 'transport-lock.json').read_text(encoding='utf-8'))
    dependency = (ROOT / lock['root']).resolve()
    for entry in lock['files']:
        path = (dependency / entry['path']).resolve()
        if not path.is_relative_to(dependency):
            raise RuntimeError(f"unsafe dependency path: {entry['path']}")
        actual = hashlib.sha256(path.read_bytes()).hexdigest()
        if actual != entry['sha256']:
            raise RuntimeError(f"dependency changed: {entry['path']}")
    if staged:
        hashes = {entry['path']: entry['sha256'] for entry in lock['files']}
        for name in lock['runtime_dlls']:
            expected = hashes['deps/openssl-install/bin/' + name]
            actual = hashlib.sha256((ROOT / 'zig-out/bin' / name).read_bytes()).hexdigest()
            if actual != expected:
                raise RuntimeError(f'staged runtime mismatch: {name}')
    return len(lock['files'])

if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('--staged', action='store_true')
    args = parser.parse_args()
    print(f'PASS: {verify(args.staged)} dependency files match reviewed custody; staged={args.staged}')
