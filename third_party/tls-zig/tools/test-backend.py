"""Offline T00 acceptance: independent fixtures; unittest checks survive -O.

Run python [-O] tools/test-backend.py. No network, installed SDK edits or pinning.
"""
from pathlib import Path
import copy
import hashlib
import importlib.util
import io
import json
import os
import shutil
import subprocess
import sys
import tarfile
import tempfile
import unittest
from unittest import mock

TOOLS = Path(__file__).resolve().parent
sys.dont_write_bytecode = True


def load(name):
    spec = importlib.util.spec_from_file_location(name.replace('-', '_'), TOOLS / (name + '.py'))
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


verify = load('verify-backend')
fetch = load('fetch-openssl')
pin = load('pin-backend')


def snapshot(root):
    return {p.relative_to(root).as_posix(): p.read_bytes() for p in root.rglob('*') if p.is_file() and not p.is_symlink()}


class BackendTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory(prefix='tls-t00-')
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        self.sdk = self.root / 'deps/sdk'
        self.sdk.mkdir(parents=True)
        (self.sdk / 'header.h').write_bytes(b'abc')
        (self.sdk / 'runtime.dll').write_bytes(b'')
        # Fixed published SHA-256 values, independent of verifier implementation.
        self.lock = {'sdk_root': 'deps/sdk', 'sdk_files': [
            {'path': 'header.h', 'sha256': 'ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad'},
            {'path': 'runtime.dll', 'sha256': 'e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855'}]}
        self.manifest = self.root / 'backend-lock.json'
        self.save_lock(self.lock)

    def save_lock(self, lock):
        self.manifest.write_text(json.dumps(lock), encoding='utf-8')

    def check_cli(self, passed):
        before = snapshot(self.root)
        result = subprocess.run([sys.executable, *(['-O'] if not __debug__ else []),
                                 str(TOOLS / 'verify-backend.py'), '--root', str(self.root)],
                                capture_output=True, text=True, timeout=30)
        self.assertEqual(result.returncode, 0 if passed else 1, result.stdout + result.stderr)
        self.assertEqual(json.loads(result.stdout)['passed'], passed)
        self.assertEqual(before, snapshot(self.root), 'verification mutated input')

    def test_exact_set_changed_missing_extra(self):
        self.check_cli(True)
        (self.sdk / 'header.h').write_bytes(b'abd')
        self.check_cli(False)
        (self.sdk / 'header.h').unlink()
        self.check_cli(False)
        (self.sdk / 'header.h').write_bytes(b'abc')
        (self.sdk / 'extra.dll').write_bytes(b'')
        self.check_cli(False)

    def test_unsafe_and_ambiguous_manifest_paths(self):
        for path in ('../escape', 'C:/escape', 'C:escape', '/escape', 'a\\b', './a',
                     'a//b', 'a/../b', 'a/', 'name.', 'name ', 'NUL.txt', 'a:stream'):
            with self.subTest(path=path):
                lock = copy.deepcopy(self.lock)
                lock['sdk_files'][0]['path'] = path
                self.save_lock(lock)
                self.check_cli(False)
        for path in ('../sdk', 'C:/sdk'):
            lock = copy.deepcopy(self.lock)
            lock['sdk_root'] = path
            self.save_lock(lock)
            self.check_cli(False)

    def test_duplicate_and_malformed_manifest(self):
        for row in (self.lock['sdk_files'][0], {'path': 'HEADER.H', 'sha256': '0'*64}):
            lock = copy.deepcopy(self.lock)
            lock['sdk_files'].append(row)
            self.save_lock(lock)
            self.check_cli(False)
        for body in ('{bad', '{"sdk_root":"deps/sdk","sdk_root":"deps/sdk"}',
                     '[]', '{"sdk_root":"deps/sdk","sdk_files":[]}',
                     '{"sdk_root":"deps/sdk","sdk_files":[null]}'):
            self.manifest.write_text(body)
            self.check_cli(False)
        lock = copy.deepcopy(self.lock)
        lock['sdk_files'][0]['sha256'] = 'not-a-digest'
        self.save_lock(lock)
        self.check_cli(False)

    def test_link_rejected(self):
        link = self.sdk / 'linked'
        try:
            link.symlink_to(self.sdk / 'header.h')
        except OSError:
            # Windows without symlink privilege: exercise the exact lstat flag.
            with mock.patch.object(Path, 'lstat', return_value=type('Info', (), {'st_mode': 0o100644, 'st_file_attributes': 0x400})()):
                with self.assertRaisesRegex(ValueError, 'reparse'):
                    verify.no_link(link)
        else:
            self.check_cli(False)

    def test_pin_version_check_unconditional(self):
        pin.validate_version('OpenSSL 3.5.8 25 Aug 2026 (Library: OpenSSL 3.5.8 25 Aug 2026)\nbuilt on: fixture')
        for value in ('', 'OpenSSL 3.0.0', 'OpenSSL 3.5.8 25 Aug 2026 (Library: OpenSSL 3.0.0)'):
            with self.assertRaises(ValueError):
                pin.validate_version(value)

    def test_interop_refuses_disabled_assertions_before_side_effects(self):
        for name in ('interop.py', 'tcp_interop.py', 'tcp_server_interop.py', 'tcp_upload_interop.py'):
            result = subprocess.run([sys.executable, '-O', str(TOOLS / name)], cwd=self.root,
                                    capture_output=True, text=True, timeout=30)
            self.assertNotEqual(result.returncode, 0)
            self.assertIn('requires assertions', result.stderr)

    def qualification_fixture(self):
        """Invoke the real PowerShell entry with fake compiler and disposable SDK."""
        shell = shutil.which('pwsh')
        if shell is None:
            self.skipTest('PowerShell qualification entry requires pwsh')
        tools = self.root / 'tools'
        tools.mkdir()
        shutil.copy2(TOOLS / 'qualify.ps1', tools / 'qualify.ps1')
        shutil.copy2(TOOLS / 'verify-backend.py', tools / 'verify-backend.py')
        sdk = self.root / 'deps/openssl-install'
        (sdk / 'bin').mkdir(parents=True)
        (sdk / 'bin/libssl-3-x64.dll').write_bytes(b'abc')
        compiler = self.root / 'fake-zig.ps1'
        compiler.write_text("if ($args[0] -eq 'version') { '0.17.0-dev.1859+dcceb318e'; exit 0 }; Set-Content -LiteralPath (Join-Path $PSScriptRoot 'build-started') -Value 'unexpected'; exit 1", encoding='utf-8')
        lock = dict(backend='OpenSSL 3.5.8 25 Aug 2026', sdk_root='deps/openssl-install',
                    zig='0.17.0-dev.1859+dcceb318e', target='x86_64-windows-gnu',
                    sdk_files=[dict(path='bin/libssl-3-x64.dll', sha256=self.lock['sdk_files'][0]['sha256'])])
        command = [shell, '-NoProfile', '-File', str(tools / 'qualify.ps1'), '-Zig', str(compiler)]
        return lock, command

    def test_qualification_binds_verified_root_and_profile(self):
        lock, command = self.qualification_fixture()
        for key in ('sdk_root', 'backend', 'target', 'zig'):
            candidate = dict(lock)
            candidate[key] = 'incorrect'
            self.save_lock(candidate)
            before = snapshot(self.root)
            result = subprocess.run(command, capture_output=True, text=True, timeout=30)
            self.assertNotEqual(result.returncode, 0)
            self.assertIn('does not match this qualification profile', result.stderr)
            self.assertEqual(snapshot(self.root), before)

    def test_qualification_rejects_extra_sdk_before_build(self):
        lock, command = self.qualification_fixture()
        self.save_lock(lock)
        (self.root / 'deps/openssl-install/extra.dll').write_bytes(b'unlocked')
        before = snapshot(self.root)
        result = subprocess.run(command, capture_output=True, text=True, timeout=30)
        self.assertNotEqual(result.returncode, 0)
        self.assertIn('SDK file set mismatch', result.stdout)
        self.assertIn('Private SDK verification failed', result.stderr)
        self.assertEqual(snapshot(self.root), before)


class AcquisitionTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory(prefix='tls-acquire-')
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        self.top = 'openssl-3.5.8'
        self.files = {'Configure': b'configuration fixture\n', 'include/api.h': b'API\x00\xff', 'src/impl.c': b'implementation\n'}
        self.blob = self.archive(self.files)
        self.calls = 0

    def archive(self, files):
        output = io.BytesIO()
        with tarfile.open(fileobj=output, mode='w:gz') as archive:
            for name, body in files.items():
                info = tarfile.TarInfo(self.top + '/' + name)
                info.size = len(body)
                archive.addfile(info, io.BytesIO(body))
        return output.getvalue()

    def opener(self, mode='valid'):
        def respond(request, timeout):
            self.calls += 1
            start, end = map(int, request.get_header('Range')[6:].split('-'))
            body = self.blob[start:end+1]
            response = io.BytesIO(body[:-1] if mode == 'short' else body + b'x' if mode == 'long' else body)
            response.status = 200 if mode == 'ignored' else 206
            response.headers = {'Content-Range': f'bytes {start}-{end}/{len(self.blob)}'}
            if mode == 'range': response.headers['Content-Range'] = 'bytes 0-1/2'
            if mode == 'encoding': response.headers['Content-Encoding'] = 'gzip'
            if mode == 'interrupt': raise OSError('injected interruption')
            return response
        return respond

    def acquire(self, **kwargs):
        args = dict(url='https://fixture.invalid/archive', size=len(self.blob),
                    digest=hashlib.sha256(self.blob).hexdigest(), opener=self.opener(), pause=lambda _: None)
        args.update(kwargs)
        return fetch.acquire(self.root, **args)

    def test_complete_and_repeat_without_network(self):
        tree = self.acquire()
        self.assertEqual(snapshot(tree), self.files)
        before = snapshot(self.root)
        self.acquire(opener=lambda *a, **kw: self.fail('verified archive must not redownload'))
        self.assertEqual(before, snapshot(self.root))

    def test_ranges_errors_and_wrong_digest_never_promote(self):
        for mode in ('ignored', 'range', 'short', 'long', 'encoding', 'interrupt'):
            with self.subTest(mode=mode):
                before = snapshot(self.root)
                self.calls = 0
                with self.assertRaises((OSError, ValueError)):
                    self.acquire(opener=self.opener(mode))
                self.assertEqual(self.calls, 4, 'retry budget')
                self.assertEqual(before, snapshot(self.root))
                self.assertFalse((self.root / self.top).exists())
        with self.assertRaisesRegex(ValueError, 'hash'):
            self.acquire(digest='0' * 64)
        self.assertEqual(snapshot(self.root), {})

    def test_multiple_ranges_exact_boundaries(self):
        dest = self.root / 'archive'
        fetch.download(dest, 'https://fixture.invalid/a', len(self.blob), hashlib.sha256(self.blob).hexdigest(),
                       opener=self.opener(), pause=lambda _: None, step=7)
        self.assertEqual(dest.read_bytes(), self.blob)
        self.assertEqual(self.calls, (len(self.blob) + 6) // 7)

    def test_interrupted_extraction_and_configure_only_recovery(self):
        tree = self.root / self.top
        tree.mkdir()
        (tree / 'Configure').write_bytes(b'old partial extraction')
        before = snapshot(tree)
        def interrupt(archive, stage):
            folder = stage / self.top
            folder.mkdir()
            (folder / 'Configure').write_bytes(self.files['Configure'])
            raise OSError('injected extraction interruption')
        with self.assertRaisesRegex(OSError, 'interruption'):
            self.acquire(extractor=interrupt)
        self.assertEqual(snapshot(tree), before)
        self.assertEqual(list(self.root.glob('*.stage-*')), [])
        self.acquire()
        self.assertEqual(snapshot(tree), self.files)
        backups = list(self.root.glob('*.retained-*'))
        self.assertEqual(len(backups), 1)
        self.assertEqual(snapshot(backups[0]), before)

    def test_extractor_silent_omission_rejected(self):
        def incomplete(archive, stage):
            (stage / self.top).mkdir()
            (stage / self.top / 'Configure').write_bytes(self.files['Configure'])
        with self.assertRaisesRegex(ValueError, 'complete archive'):
            self.acquire(extractor=incomplete)
        self.assertFalse((self.root / self.top).exists())
        self.acquire()
        self.assertEqual(snapshot(self.root / self.top), self.files)

    def test_modified_complete_tree_preserved_and_replaced(self):
        tree = self.acquire()
        (tree / 'include/api.h').write_bytes(b'user modification')
        (tree / 'extra').write_bytes(b'keep this')
        before = snapshot(tree)
        self.acquire()
        self.assertEqual(snapshot(tree), self.files)
        self.assertEqual(snapshot(next(self.root.glob('*.retained-*'))), before)

    def test_promotion_failure_restores_old_tree(self):
        tree = self.root / self.top
        tree.mkdir()
        (tree / 'Configure').write_bytes(b'old')
        original = Path.rename
        def fail_candidate(path, target):
            if '.stage-' in str(path): raise OSError('injected rename failure')
            return original(path, target)
        with mock.patch.object(Path, 'rename', fail_candidate):
            with self.assertRaisesRegex(OSError, 'rename failure'):
                self.acquire()
        self.assertEqual(snapshot(tree), {'Configure': b'old'})
        self.acquire()
        self.assertEqual(snapshot(tree), self.files)

    def test_archive_traversal_and_links_rejected(self):
        for name in ('../escape', 'C:/escape', 'a\\b', 'NUL', 'a:stream'):
            self.blob = self.archive({'Configure': b'ok', name: b'bad'})
            with self.assertRaises(ValueError): self.acquire()
            self.assertFalse((self.root / self.top).exists())
        output = io.BytesIO()
        with tarfile.open(fileobj=output, mode='w:gz') as archive:
            member = tarfile.TarInfo(self.top + '/link')
            member.type = tarfile.SYMTYPE
            member.linkname = '../outside'
            archive.addfile(member)
        self.blob = output.getvalue()
        with self.assertRaises(ValueError): self.acquire()
        self.assertFalse((self.root / self.top).exists())


if __name__ == '__main__':
    unittest.main(verbosity=2)
