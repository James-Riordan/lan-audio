"""Fetch the pinned archive; promote only a completely verified source tree.

Checks remain active under Python -O. Incomplete trees are retained, not trusted.
Importing performs no I/O. No SDK build or lock update is performed. Python 3.12+.
"""
from pathlib import Path, PurePosixPath
import hashlib
import os
import re
import tarfile
import tempfile
import time
import urllib.request
import uuid

VERSION = '3.5.8'
SIZE = 53_213_818
SHA256 = 'a8f84a39918ec6415ce765d9b429d313ba97b8143169c172e734b9514464f5b2'
URL = f'https://github.com/openssl/openssl/releases/download/openssl-{VERSION}/openssl-{VERSION}.tar.gz'
ROOT = Path(__file__).resolve().parents[1]


def sha256(path):
    with path.open('rb') as stream:
        return hashlib.file_digest(stream, 'sha256').hexdigest()


def download(dest, url, size, digest, *, opener=urllib.request.urlopen, pause=time.sleep, step=262_144):
    """Retry bounded byte ranges; publish archive only after exact size/hash."""
    if dest.exists() and dest.stat().st_size == size and sha256(dest) == digest:
        return
    fd, name = tempfile.mkstemp(prefix=dest.name + '.', suffix='.partial', dir=dest.parent)
    partial = Path(name)
    try:
        with os.fdopen(fd, 'wb') as out:
            for offset in range(0, size, step):
                end = min(offset + step, size) - 1
                for attempt in range(4):
                    try:
                        request = urllib.request.Request(url, headers={
                            'Range': f'bytes={offset}-{end}', 'Accept-Encoding': 'identity',
                            'User-Agent': 'tls-zig-backend-acquisition'})
                        with opener(request, timeout=30) as response:
                            if response.status != 206:
                                raise ValueError('server did not honor byte range')
                            if response.headers.get('Content-Range') != f'bytes {offset}-{end}/{size}':
                                raise ValueError('unexpected Content-Range')
                            if response.headers.get('Content-Encoding', 'identity') != 'identity':
                                raise ValueError('unexpected Content-Encoding')
                            block = response.read(end - offset + 2)
                            if len(block) != end - offset + 1:
                                raise ValueError('short or oversized range body')
                        out.write(block)
                        break
                    except (OSError, ValueError):
                        if attempt == 3:
                            raise
                        pause(1)
            out.flush()
            os.fsync(out.fileno())
        if partial.stat().st_size != size or sha256(partial) != digest:
            raise ValueError('release size/hash mismatch')
        partial.replace(dest)
    finally:
        partial.unlink(missing_ok=True)


def archive_files(archive, top):
    """Build expected byte map; reject aliases, links, special files and escapes."""
    files, names = {}, set()
    for member in archive.getmembers():
        name = member.name.rstrip('/') if member.isdir() else member.name
        path = PurePosixPath(name)
        if (not name or path.as_posix() != name or path.is_absolute()
                or not path.parts or path.parts[0] != top
                or any(p in ('.', '..') or p.endswith((' ', '.'))
                       or any(ord(c) < 32 or c in '\\:<>"|?*' for c in p)
                       or re.fullmatch(r'(?i:CON|PRN|AUX|NUL|COM[0-9¹²³]|LPT[0-9¹²³])', p.split('.')[0])
                       for p in path.parts)):
            raise ValueError('unsafe archive member: ' + member.name)
        if name.casefold() in names or not (member.isdir() or member.isfile()):
            raise ValueError('duplicate, linked or special archive member: ' + name)
        names.add(name.casefold())
        if member.isfile():
            with archive.extractfile(member) as stream:
                files[path.relative_to(top).as_posix()] = (member.size, hashlib.file_digest(stream, 'sha256').hexdigest())
    if 'Configure' not in files:
        raise ValueError('archive lacks Configure')
    return files


def matches(tree, expected):
    """Compare exact regular-file bytes; reject linked directories and extra files."""
    if not tree.is_dir() or tree.is_symlink() or tree.is_junction():
        return False
    actual, pending = {}, [tree]
    while pending:
        for path in pending.pop().iterdir():
            if path.is_symlink() or path.is_junction():
                return False
            if path.is_dir():
                pending.append(path)
            elif path.is_file():
                actual[path.relative_to(tree).as_posix()] = (path.stat().st_size, sha256(path))
            else:
                return False
    return actual == expected


def extract_verified(dest, top, *, extractor=None):
    """Verify every extracted file before rename; retain displaced trees.

    Same-parent rename publishes a complete tree. Replacing a stale tree takes
    two renames, not an atomic exchange. Exceptions restore the old tree. A kill
    between renames leaves a backup and no incomplete final tree; next invocation
    starts from fresh staging. Requires one acquisition owner per destination.
    """
    tree = dest.parent / top
    with tarfile.open(dest, 'r:gz') as archive:
        expected = archive_files(archive, top)
        if matches(tree, expected):
            return tree
        with tempfile.TemporaryDirectory(prefix=top + '.stage-', dir=dest.parent) as temp:
            stage = Path(temp)
            if extractor is None:
                archive.extractall(stage, filter='data')
            else:
                extractor(archive, stage)
            candidate = stage / top
            if not matches(candidate, expected):
                raise ValueError('extracted source does not match the complete archive')
            backup = None
            if tree.exists() or tree.is_symlink():
                backup = dest.parent / (top + '.retained-' + uuid.uuid4().hex)
                tree.rename(backup)
            try:
                candidate.rename(tree)
            except BaseException:
                if backup is not None:
                    backup.rename(tree)
                raise
    return tree


def acquire(deps, *, url=URL, size=SIZE, digest=SHA256, version=VERSION,
            opener=urllib.request.urlopen, pause=time.sleep, extractor=None):
    """Fetch/extract under caller-owned directory; no partial promotion on error."""
    if not re.fullmatch(r'[0-9]+\.[0-9]+\.[0-9]+', version):
        raise ValueError('invalid release version')
    deps.mkdir(parents=True, exist_ok=True)
    dest = deps / f'openssl-{version}.tar.gz'
    download(dest, url, size, digest, opener=opener, pause=pause)
    return extract_verified(dest, f'openssl-{version}', extractor=extractor)


def main():
    tree = acquire(ROOT / 'deps')
    print('Verified complete source', tree, SHA256)


if __name__ == '__main__':
    main()
