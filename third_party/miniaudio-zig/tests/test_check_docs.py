"""Independent negative fixtures for the read-only handbook integrity gate.

The fixture uses tiny synthetic vendor bytes and its own manifest; it never
modifies the repository adoption or exercises native audio. Each mutation checks
a documented obligation, not the implementation's internal loop structure.
"""
import hashlib
import importlib.util
import json
from pathlib import Path
import tempfile
import unittest

spec = importlib.util.spec_from_file_location(
    'miniaudio_docs_check', Path(__file__).resolve().parents[1] / 'tools/check_docs.py')
gate = importlib.util.module_from_spec(spec)
spec.loader.exec_module(gate)


class DocumentationGate(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        self.put('docs/reference/files.md', '<a id="owned"></a>\n# Fixture\n')
        self.put('README.md', '[Files](docs/reference/files.md#owned)\n')
        self.put('src/root.zig', 'pub const c = 1;\n')
        self.put('vendor/miniaudio/miniaudio.h', 'fixture declaration\n')
        self.put('vendor/miniaudio/LICENSE', 'fixture notice\n')
        self.put('UPSTREAM.json', json.dumps({'files': {
            p: hashlib.sha256((self.root / p).read_bytes()).hexdigest()
            for p in sorted(gate.VENDOR_FILES)}}))
        paths = sorted(p.relative_to(self.root).as_posix()
                       for p in self.root.rglob('*') if p.is_file())
        paths.append('docs/reference/catalog.json')
        self.catalog = {
            'schema': 1,
            'files': [{'path': p, 'reference': 'docs/reference/files.md', 'anchor': 'owned'}
                      for p in paths],
            'source_anchors': {'src/root.zig': ['pub const c = 1;']},
        }
        self.save()

    def put(self, rel, value):
        path = self.root / rel
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(value, encoding='utf-8')

    def save(self):
        self.put('docs/reference/catalog.json', json.dumps(self.catalog))

    def expect_error(self, fragment):
        before = {p.relative_to(self.root).as_posix(): p.read_bytes()
                  for p in self.root.rglob('*') if p.is_file()}
        errors = gate.check(self.root)
        self.assertTrue(any(fragment in e for e in errors), errors)
        after = {p.relative_to(self.root).as_posix(): p.read_bytes()
                 for p in self.root.rglob('*') if p.is_file()}
        self.assertEqual(before, after, 'validation must never repair files')

    def test_complete_fixture(self):
        self.assertEqual([], gate.check(self.root))

    def test_new_file_requires_contract(self):
        self.put('src/unreviewed.zig', '// new source')
        self.expect_error('unindexed file: src/unreviewed.zig')

    def test_removed_file_rejects_stale_row(self):
        (self.root / 'src/root.zig').unlink()
        self.expect_error('missing indexed file: src/root.zig')

    def test_duplicate_row(self):
        self.catalog['files'].append(self.catalog['files'][0].copy())
        self.save()
        self.expect_error('duplicate indexed path')

    def test_missing_reference_anchor(self):
        self.catalog['files'][0]['anchor'] = 'not-present'
        self.save()
        self.expect_error('missing reference anchor')

    def test_broken_local_file(self):
        self.put('README.md', '[Missing](no-file.md)')
        self.expect_error('broken local link')

    def test_broken_local_fragment(self):
        self.put('README.md', '[Missing](docs/reference/files.md#no-anchor)')
        self.expect_error('broken local anchor')

    def test_changed_source_symbol(self):
        self.put('src/root.zig', 'pub const different = 1;')
        self.expect_error('missing source anchor')

    def test_escaped_catalogue_reference(self):
        self.catalog['files'][0]['reference'] = '../outside.md'
        self.save()
        self.expect_error('invalid relative path')

    def test_escaped_local_link(self):
        self.put('README.md', '[Outside](../outside.md)')
        self.expect_error('local link outside root')

    def test_vendor_mutation(self):
        self.put('vendor/miniaudio/miniaudio.h', 'changed source')
        self.expect_error('vendor mismatch')

    def test_incomplete_vendor_manifest(self):
        self.put('UPSTREAM.json', '{"files":{}}')
        self.expect_error('must name the adopted header and license exactly')

    def test_duplicate_json_key(self):
        self.put('docs/reference/catalog.json', '{"schema":1,"schema":1}')
        self.expect_error('duplicate JSON key')

    def test_generated_files_are_outside_coverage(self):
        for path in ['.zig-cache/artifact', 'zig-out/library.a',
                     'tests/__pycache__/cache.pyc', 'verification/phase/receipt.json']:
            self.put(path, 'generated')
        self.assertEqual([], gate.check(self.root))

    def test_docs_verification_is_authored(self):
        self.put('docs/verification/new.md', '# Still needs a contract')
        self.expect_error('unindexed file: docs/verification/new.md')

    def test_unsafe_source_anchor_path(self):
        self.catalog['source_anchors'] = {'../external.c': ['probe']}
        self.save()
        self.expect_error('invalid relative path')

    def test_duplicate_html_anchor(self):
        self.put('docs/reference/files.md', '<a id="owned"></a>\n<a id="owned"></a>')
        self.expect_error('duplicate explicit anchor')


if __name__ == '__main__':
    unittest.main()
