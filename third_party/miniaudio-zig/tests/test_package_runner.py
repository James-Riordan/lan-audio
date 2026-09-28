"""Independent package-evidence/closure defects; never compile or touch live source."""
from pathlib import Path
import hashlib
import io
import sys
import tarfile
import tempfile
import unittest

sys.path.insert(0,str(Path(__file__).resolve().parents[1]/'tools'))
import test_package as p

IDENTITY='miniaudio_zig-0.1.0-example'
LINE='file: '+'a'*64+': README.md\n'


class PackageEvidence(unittest.TestCase):
    def test_actual_compiler_record_shape(self):
        self.assertEqual(p.parse_fetch(LINE+IDENTITY+'\n'),({'README.md'},IDENTITY))

    def test_missing_duplicate_or_unsafe_fetch_records_fail(self):
        for text in [IDENTITY,LINE,LINE+LINE+IDENTITY,LINE+IDENTITY+'\n'+IDENTITY,
                     'file: bad: README.md\n'+IDENTITY,
                     LINE.replace('README.md','../escape')+IDENTITY]:
            with self.assertRaises(ValueError):p.parse_fetch(text)

    def test_selection_rejects_missing_and_leaked_cache(self):
        for observed in [set(),{'README.md','tests/__pycache__/probe.pyc'}]:
            with self.assertRaises(ValueError):p.require_selection(observed,{'README.md'})
        p.require_selection({'README.md'},{'README.md':'hash'})

    def test_consumer_requires_fresh_test_and_zero_exit(self):
        witness='1/1 tests passed\nrun test 1 pass (1 total)'
        self.assertTrue(p.consumer_pass(0,witness))
        self.assertTrue(p.consumer_pass(0,witness+'\nWriteFile cached'))
        for code,text in [(1,witness),(0,'success'),(0,'1/1 tests passed\nrun test cached')]:
            self.assertFalse(p.consumer_pass(code,text))

    def test_deterministic_archive_roundtrip(self):
        with tempfile.TemporaryDirectory() as tmp:
            root=Path(tmp);(root/'a.txt').write_bytes(b'exact\n')
            expected={'a.txt':p.digest(root/'a.txt')}
            p.write_archive(root,expected,root/'one.tar')
            p.write_archive(root,expected,root/'two.tar')
            self.assertEqual(p.digest(root/'one.tar'),p.digest(root/'two.tar'))
            p.extract_own_archive(root/'one.tar',expected,root/'copy')
            self.assertEqual((root/'copy/a.txt').read_bytes(),b'exact\n')

    def test_wrong_archive_bytes_fail(self):
        with tempfile.TemporaryDirectory() as tmp:
            root=Path(tmp);(root/'a.txt').write_bytes(b'wrong')
            p.write_archive(root,{'a.txt'},root/'one.tar')
            with self.assertRaisesRegex(ValueError,'bytes'):
                p.extract_own_archive(root/'one.tar',{'a.txt':'0'*64},root/'copy')

    def test_nonregular_duplicate_and_extra_members_fail(self):
        for mode in ('link','duplicate','extra'):
            with self.subTest(mode=mode),tempfile.TemporaryDirectory() as tmp:
                root=Path(tmp);archive=root/'bad.tar'
                with tarfile.open(archive,'w') as t:
                    info=tarfile.TarInfo('miniaudio-zig/a.txt')
                    if mode=='link':info.type=tarfile.SYMTYPE;info.linkname='../escape'
                    t.addfile(info)
                    if mode=='duplicate':t.addfile(info)
                    if mode=='extra':t.addfile(tarfile.TarInfo('miniaudio-zig/extra'))
                with self.assertRaises(ValueError):
                    p.extract_own_archive(archive,{'a.txt':hashlib.sha256(b'').hexdigest()},root/'copy')


if __name__ == '__main__':unittest.main()
