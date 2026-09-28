"""Exercise real private provisioning, relocated CLI and setup failure boundaries.

Fresh temporary keys are removed; no physical devices are opened. An occupied
loopback port proves `start` reaches the receiver without waiting for a peer/audio.
Mac host execution is deliberately not simulated into a platform support claim.
"""
import concurrent.futures
import hashlib
import json
import os
from pathlib import Path
import shutil
import socket
import subprocess
import sys
import tempfile
import unittest
from unittest.mock import patch

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT/'tools'))
import create_pair
import setup_desktop


def hashes(folder):
    return {str(p.relative_to(folder)): hashlib.sha256(p.read_bytes()).hexdigest()
            for p in folder.rglob('*') if p.is_file()}


class DesktopSetup(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        if os.name != 'nt':
            raise unittest.SkipTest('this campaign requires the Windows candidate and pinned Windows OpenSSL')
        cls.temporary = tempfile.TemporaryDirectory(prefix='LAN audio setup é ')
        cls.base = Path(cls.temporary.name)
        cls.openssl = ROOT/'third_party/tls-zig/deps/openssl-install/bin/openssl.exe'
        cls.original_pair = cls.base/'original pair'
        create_pair.create(cls.original_pair, cls.openssl, '127.0.0.1')

    @classmethod
    def tearDownClass(cls):
        cls.temporary.cleanup()

    def setUp(self):
        self.case = self.base/self._testMethodName
        self.case.mkdir()
        self.pair = self.case/'pair'
        shutil.copytree(self.original_pair, self.pair)
        self.application = ROOT/'zig-out/bin'
        self.output = self.case/'installed app é'

    def install(self, role='sender', **kwargs):
        return setup_desktop.install(self.pair/role, self.application, self.output, **kwargs)

    def test_repeat_preserves_all_files_and_edited_profiles(self):
        self.assertEqual(self.install()['status'], 'installed')
        path = self.output/'lan-audio.json'
        document = json.loads(path.read_text())
        document['defaults']['buffer_ms'] = 60
        document['profiles'][0]['settings']['address'] = '192.0.2.20'
        path.write_text(json.dumps(document))
        before = hashes(self.output)
        self.assertEqual(self.install()['status'], 'verified-existing')
        self.assertEqual(hashes(self.output), before)
        with self.assertRaisesRegex(ValueError, 'saved address differs'):
            self.install(receiver_address='192.0.2.21')
        self.assertEqual(hashes(self.output), before)

    def test_start_and_check_find_executable_relative_config(self):
        self.install(role='receiver')
        (self.case/'lan-audio.json').write_text('not the selected config')
        exe = self.output/'lan-audio.exe'
        result = subprocess.run([str(exe), 'check'], cwd=self.case, capture_output=True, timeout=10)
        self.assertEqual(result.returncode, 0, result.stderr)
        report = json.loads(result.stdout)
        self.assertTrue(report['valid'])
        self.assertFalse(report['credentials_checked'])
        self.assertFalse(report['network_checked'])
        self.assertFalse(report['device_checked'])
        with socket.socket() as occupied:
            occupied.setsockopt(socket.SOL_SOCKET, socket.SO_EXCLUSIVEADDRUSE, 1)
            occupied.bind(('127.0.0.1', 0))
            occupied.listen(1)
            path = self.output/'lan-audio.json'
            config = json.loads(path.read_text())
            config['profiles'][0]['settings'].update(address='127.0.0.1', port=occupied.getsockname()[1], reconnect=False)
            path.write_text(json.dumps(config))
            result = subprocess.run([str(exe), 'start'], cwd=self.case, capture_output=True, timeout=10)
            self.assertNotEqual(result.returncode, 0)
            self.assertIn(b'Starting the receiver', result.stdout)
            self.assertIn(b'SystemFailure', result.stderr)
        result = subprocess.run([str(exe), 'check', '--profile', 'missing'], capture_output=True, timeout=10)
        self.assertIn(b'ProfileNotFound', result.stderr)
        self.assertIn(b'default profile', result.stderr)

    def test_check_only_does_not_create_installation(self):
        before = hashes(self.case)
        with self.assertRaisesRegex(ValueError, 'does not exist'):
            self.install(check_only=True)
        self.assertEqual(before, hashes(self.case))
        self.assertFalse(self.output.exists())

    def test_invalid_config_never_publishes_or_leaves_stage(self):
        p = self.pair/'sender/lan-audio.json'
        config = json.loads(p.read_text())
        config['defaults']['buffer_ms'] = 241
        p.write_text(json.dumps(config))
        with self.assertRaisesRegex(ValueError, 'application settings check failed'):
            self.install()
        self.assertFalse(self.output.exists())
        self.assertEqual(sorted(x.name for x in self.case.iterdir()), ['pair'])

    def test_unknown_destination_is_never_overwritten(self):
        self.output.mkdir()
        (self.output/'personal.txt').write_text('leave me alone')
        before = hashes(self.output)
        with self.assertRaises(ValueError):
            self.install()
        self.assertEqual(before, hashes(self.output))

    def test_changed_identity_rejected_before_installation(self):
        (self.pair/'sender/identity.pem').write_text('damaged')
        with self.assertRaisesRegex(ValueError, 'identity files differ'):
            self.install()
        self.assertFalse(self.output.exists())

    def test_wrong_key_rejected_even_with_rehashed_metadata(self):
        folder = self.pair/'sender'
        shutil.copyfile(self.pair/'receiver/identity.key', folder/'identity.key')
        path = folder/'identity.json'
        metadata = json.loads(path.read_text())
        metadata['files']['identity.key'] = create_pair.digest(folder/'identity.key')
        path.write_text(json.dumps(metadata))
        with self.assertRaises(OSError):
            self.install()
        self.assertFalse(self.output.exists())
        self.assertEqual(sorted(x.name for x in self.case.iterdir()), ['pair'])

    def test_installed_tamper_never_repaired_silently(self):
        self.install()
        (self.output/'identity.pem').write_text('changed')
        before = hashes(self.output)
        with self.assertRaisesRegex(ValueError, 'was changed'):
            self.install()
        self.assertEqual(before, hashes(self.output))

    def test_changed_build_requires_separate_destination(self):
        self.install()
        alternate = self.case/'new build'
        alternate.mkdir()
        for name in setup_desktop.TARGET_FILES['windows-x86_64']:
            shutil.copyfile(self.application/name, alternate/name)
        with (alternate/'lan-audio.exe').open('ab') as stream:
            stream.write(b'changed')
        before = hashes(self.output)
        with self.assertRaisesRegex(ValueError, 'differs from these build'):
            setup_desktop.install(self.pair/'sender', alternate, self.output)
        self.assertEqual(before, hashes(self.output))

    def test_pair_authority_cannot_be_changed_by_profile(self):
        path = self.pair/'sender/lan-audio.json'
        config = json.loads(path.read_text())
        config['profiles'][0]['settings']['peer_fingerprint'] = 'ab'*32
        path.write_text(json.dumps(config))
        with self.assertRaisesRegex(ValueError, 'does not match'):
            self.install()
        self.assertFalse(self.output.exists())

    def test_declarative_paths_relative_to_config_and_overrides_rejected(self):
        path = self.case/'setup.json'
        path.write_text(json.dumps(dict(schema=1, pair='pair/sender', application=str(self.application),
                                       output='installed app é', receiver_address='127.0.0.1')), encoding='utf-8')
        command = [sys.executable, str(ROOT/'tools/setup_desktop.py'), '--config', str(path)]
        result = subprocess.run(command, cwd=self.base, capture_output=True, timeout=20)
        self.assertEqual(result.returncode, 0, result.stderr)
        before = hashes(self.output)
        result = subprocess.run(command+['--check'], cwd=self.base, capture_output=True, timeout=20)
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(before, hashes(self.output))
        result = subprocess.run(command+['--receiver-address', '127.0.0.2'], capture_output=True, timeout=20)
        self.assertNotEqual(result.returncode, 0)
        self.assertIn(b'cannot be combined', result.stderr)
        self.assertEqual(before, hashes(self.output))

    def test_pair_creation_failure_can_retry_same_destination(self):
        output = self.case/'fresh'
        real_private = create_pair.private_directory
        def fail(stage):
            real_private(stage)
            (stage/'partial').write_text('incomplete')
            raise OSError('controlled interruption before keys')
        with patch.object(create_pair, 'private_directory', fail):
            with self.assertRaisesRegex(OSError, 'controlled interruption'):
                create_pair.create(output, self.openssl)
        self.assertFalse(output.exists())
        self.assertFalse(list(self.case.glob('.fresh.pair-*')))
        create_pair.create(output, self.openssl, '127.0.0.1')
        before = hashes(output)
        create_pair.create(output, self.openssl, '127.0.0.1')
        self.assertEqual(before, hashes(output))
        with self.assertRaisesRegex(ValueError, 'existing address differs'):
            create_pair.create(output, self.openssl, '127.0.0.2')
        self.assertEqual(before, hashes(output))

    def test_empty_manifest_is_not_a_valid_existing_pair(self):
        path = self.pair/'pair.json'
        path.write_text(json.dumps(dict(schema=1, files={}, fingerprints={})))
        with self.assertRaisesRegex(ValueError, 'incomplete pairing manifest'):
            create_pair.create(self.pair, self.openssl)

    def test_concurrent_installers_converge_to_one_complete_install(self):
        with concurrent.futures.ThreadPoolExecutor(max_workers=2) as executor:
            results = list(executor.map(lambda _: self.install(), range(2)))
        self.assertEqual(sorted(r['status'] for r in results), ['installed', 'verified-existing'])
        self.assertFalse(list(self.case.glob('.*.setup-*')))
        self.assertEqual(self.install()['status'], 'verified-existing')

    def test_duplicate_setup_json_rejected(self):
        path = self.case/'setup.json'
        path.write_text('{"schema":1,"schema":1}')
        with self.assertRaisesRegex(ValueError, 'duplicate JSON'):
            setup_desktop.read_json(path)

    def test_source_output_overlap_rejected(self):
        with self.assertRaisesRegex(ValueError, 'separate from pair'):
            setup_desktop.install(self.pair/'sender', self.application, self.pair/'sender/install')

    def test_one_command_bootstrap_reuses_pair_and_installation(self):
        pair = self.case/'new pair'
        command = [sys.executable, str(ROOT/'tools/setup_desktop.py'), '--create-pair', '--pair', str(pair),
                   '--output', str(self.output), '--receiver-address', '127.0.0.1']
        result = subprocess.run(command+['--check'], capture_output=True, timeout=20)
        self.assertNotEqual(result.returncode, 0)
        self.assertFalse(pair.exists())
        self.assertFalse(self.output.exists())
        result = subprocess.run(command, capture_output=True, timeout=20)
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn(b'transfer_to_mac', result.stdout)
        before = hashes(self.case)
        for extra in ([], ['--check']):
            result = subprocess.run(command+extra, capture_output=True, timeout=20)
            self.assertEqual(result.returncode, 0, result.stderr)
            self.assertEqual(before, hashes(self.case))

    def test_destination_appearing_during_setup_is_preserved(self):
        publish = setup_desktop.publish_directory
        def interpose(stage, output):
            output.mkdir()
            publish(stage, output)
        with patch.object(setup_desktop, 'publish_directory', interpose):
            with self.assertRaises(ValueError):
                self.install()
        self.assertTrue(self.output.is_dir())
        self.assertEqual(list(self.output.iterdir()), [])
        self.assertFalse(list(self.case.glob('.*.setup-*')))

    def test_concurrent_pair_creators_reuse_the_published_identity(self):
        output = self.case/'concurrent pair'
        with concurrent.futures.ThreadPoolExecutor(max_workers=2) as executor:
            results = list(executor.map(lambda _: create_pair.create(output, self.openssl, '127.0.0.1'), range(2)))
        self.assertEqual(results[0], results[1])
        self.assertEqual(create_pair.verify_pair(output), results[0])
        self.assertFalse(list(self.case.glob('.*.pair-*')))


if __name__ == '__main__':
    unittest.main(verbosity=2)
