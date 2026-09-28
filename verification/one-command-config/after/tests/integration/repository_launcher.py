"""Bootstrap/enrollment failure boundaries; real local TLS, no physical audio.

Fresh test identities are private temporary material and are removed after use.
Network tests bind loopback only. This is not native Mac qualification.
"""
from concurrent.futures import ThreadPoolExecutor
import base64
import hashlib
import io
import json
import os
from pathlib import Path
import queue
import secrets
import socket
import ssl
import struct
import sys
import tarfile
import tempfile
import threading
import unittest
from unittest.mock import patch
import zipfile

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT/'tools'))
import bootstrap as boot
import local_pairing as pairing
import desktop_release as release
import launcher_config as config
from create_pair import create


class BootstrapTests(unittest.TestCase):
    def setUp(self):
        self.temporary = tempfile.TemporaryDirectory(prefix='LAN bootstrap é ')
        self.base = Path(self.temporary.name)

    def tearDown(self):
        self.temporary.cleanup()

    def test_reviewed_complete_dependency_closure(self):
        boot.verify_dependencies()

    def test_shipped_config_resolves_for_both_hosts_without_private_paths(self):
        for target in ('windows-x86_64','macos-x86_64'):
            self.assertEqual(config.resolve(ROOT/'lan-audio.launch.json',target),dict(audio={}))

    def test_environment_overrides_merge_without_changing_document(self):
        path=self.base/'launcher.json'
        value=dict(schema=1,audio=dict(buffer_ms=40,max_buffer_ms=120),environments={
            'windows-x86_64':dict(state_directory='./pc'),
            'macos-x86_64':dict(state_directory='./mac',audio=dict(buffer_ms=60))})
        boot.atomic_json(path,value);before=path.read_bytes()
        pc=config.resolve(path,'windows-x86_64');mac=config.resolve(path,'macos-x86_64')
        self.assertEqual(pc['state_directory'],self.base/'pc');self.assertEqual(mac['state_directory'],self.base/'mac')
        self.assertEqual(pc['audio'],dict(buffer_ms=40,max_buffer_ms=120));self.assertEqual(mac['audio'],dict(buffer_ms=60,max_buffer_ms=120))
        self.assertEqual(path.read_bytes(),before)

    def test_bad_configuration_in_inactive_environment_is_rejected(self):
        path=self.base/'launcher.json'
        for layer in [dict(audio=dict(buffer_ms=True)),dict(audio=dict(peer_fingerprint='x')),dict(receiver_address='0.0.0.0'),dict(state_directory=None)]:
            boot.atomic_json(path,dict(schema=1,environments={'macos-x86_64':layer}))
            with self.assertRaises(ValueError):config.resolve(path,'windows-x86_64')

    def test_config_duplicate_unknown_and_merged_buffer_errors(self):
        path=self.base/'launcher.json'
        for raw in ['{"schema":1,"schema":1}', '{"schema":true}', '{"schema":1,"environments":{"macos-x86-64":{}}}', '{"schema":1,"audio":{"buffer_ms":100,"max_buffer_ms":120},"environments":{"macos-x86_64":{"audio":{"max_buffer_ms":80}}}}']:
            path.write_text(raw)
            with self.assertRaises(ValueError):config.resolve(path,'macos-x86_64')

    def test_session_overrides_preserve_saved_settings_and_other_profiles(self):
        saved=dict(schema=1,defaults=dict(buffer_ms=40),profiles=[dict(name='home',settings=dict(role='receive')),dict(name='other',settings=dict(buffer_ms=80))])
        before=json.dumps(saved,sort_keys=True)
        session=pairing.session_settings(saved,dict(buffer_ms=60,device='Speakers'))
        self.assertEqual(session['profiles'][0]['settings']['buffer_ms'],60)
        self.assertEqual(session['profiles'][1],saved['profiles'][1]);self.assertEqual(json.dumps(saved,sort_keys=True),before)
        with self.assertRaises(ValueError):pairing.session_settings(saved,dict(key='different.key'))

    def test_sequoia_selects_source_preparation_not_old_os_release(self):
        with patch.object(boot.platform,'mac_ver',return_value=('15.7.9',(),'')),patch.object(boot,'verify_dependencies'),patch.object(boot,'compiler',side_effect=RuntimeError('selected source build')) as compiler,patch.object(release,'fetch',side_effect=AssertionError('Sequoia should not require a published candidate')):
            with self.assertRaisesRegex(RuntimeError,'selected source build'):boot.prepare(self.base,'macos-x86_64')
            compiler.assert_called_once()

    def test_release_repository_url_is_not_an_arbitrary_download_host(self):
        for remote in ['https://github.com/james/lan-audio.git','git@github.com:james/lan-audio.git']:
            self.assertEqual(release.repository_name(remote),'james/lan-audio')
        for remote in ['https://github.com.evil.test/james/repo','https://evil.test/a/b','https://github.com/../repo','file:///repo']:
            with self.assertRaises(ValueError):release.repository_name(remote)

    def test_release_requires_exact_revision_source_and_license_bytes(self):
        target='macos-x86_64';revision='a'*40;folder=self.base/'release';folder.mkdir()
        (folder/'lan-audio').write_bytes(b'fake test binary, never executed')
        for name,path in release.LICENSES.items():(folder/name).write_bytes(path.read_bytes())
        metadata=dict(schema=1,target=target,revision=revision,source_key=boot.source_key(target),files={'lan-audio':boot.digest(folder/'lan-audio')})
        boot.atomic_json(folder/'release.json',metadata)
        release.inspect_payload(folder,target,revision)
        with self.assertRaises(ValueError):release.inspect_payload(folder,target,'b'*40)
        (folder/'LICENSE-OpenSSL.txt').write_bytes(b'changed')
        with self.assertRaisesRegex(ValueError,'license'):release.inspect_payload(folder,target,revision)

    def test_monterey_uses_release_path_before_attempting_modern_compiler(self):
        with patch.object(boot.platform,'mac_ver',return_value=('12.7.6',(),'')),patch.object(boot,'verify_dependencies'),patch.object(boot,'compiler',side_effect=AssertionError('must not execute compiler')),patch.object(release,'fetch',return_value=self.base/'candidate') as fetch:
            self.assertEqual(boot.prepare(self.base,'macos-x86_64'),self.base/'candidate')
            self.assertEqual(fetch.call_args.args[1],'macos-x86_64')

    def test_real_os_lock_released_after_failure(self):
        path = self.base/'lock'
        with self.assertRaisesRegex(RuntimeError, 'injected'):
            with boot.exclusive(path):
                with self.assertRaisesRegex(ValueError, 'already'):
                    with boot.exclusive(path):
                        self.fail('overlapping launcher acquired lock')
                raise RuntimeError('injected')
        with boot.exclusive(path):
            pass

    def test_atomic_json_preserves_old_file_on_publish_failure(self):
        path = self.base/'settings.json'; boot.atomic_json(path, {'old': True})
        with patch.object(boot.os, 'replace', side_effect=OSError('injected')):
            with self.assertRaises(OSError):
                boot.atomic_json(path, {'new': True})
        self.assertEqual(json.loads(path.read_text()), {'old':True})
        self.assertEqual(list(self.base.iterdir()), [path])

    def test_cached_archive_corruption_never_downloads_or_executes(self):
        asset = dict(sha256='0'*64,archive='zip',size=3,urls=['https://example.invalid/file'])
        (self.base/('0'*64+'.zip')).write_bytes(b'bad')
        with patch.object(boot.urllib.request, 'urlopen') as fetch:
            with self.assertRaisesRegex(ValueError, 'cached archive changed'):
                boot.download(asset,self.base)
            fetch.assert_not_called()

    def test_download_hash_and_size_failures_leave_no_published_archive(self):
        class Response(io.BytesIO):
            def geturl(self):return 'https://example.invalid/file'
        for maximum in (2,100):
            with self.subTest(maximum=maximum):
                asset=dict(sha256='0'*64,archive='zip',size=maximum,urls=['https://example.invalid/file'])
                with patch.object(boot.urllib.request,'urlopen',return_value=Response(b'bad')):
                    with self.assertRaises(ValueError):boot.download(asset,self.base)
                self.assertEqual(list(self.base.iterdir()), [])

    def test_zip_traversal_and_case_collision_rejected(self):
        for names in (['../escaped'],['/absolute'],['C:/absolute'],['ok','OK']):
            with self.subTest(names=names):
                archive=self.base/'test.zip'; destination=self.base/secrets.token_hex(5);destination.mkdir()
                with zipfile.ZipFile(archive,'w') as out:
                    for name in names:out.writestr(name,b'x')
                with self.assertRaises(ValueError):boot.extract(archive,destination,'zip')
        self.assertFalse((self.base/'escaped').exists())

    def test_tar_link_rejected_without_following_target(self):
        archive=self.base/'test.tar'; destination=self.base/'out';destination.mkdir()
        with tarfile.open(archive,'w') as out:
            member=tarfile.TarInfo('alias');member.type=tarfile.SYMTYPE;member.linkname='../escape';out.addfile(member)
        with self.assertRaisesRegex(ValueError,'link/device'):boot.extract(archive,destination,'tar')
        self.assertEqual(list(destination.iterdir()),[])

    def test_frame_size_checked_before_payload_read(self):
        class Stream:
            def recv(self,size):
                self.assert_size=size
                return struct.pack('!I',65537)
        stream=Stream()
        with self.assertRaisesRegex(ValueError,'64 KiB'):pairing.receive(stream)
        self.assertEqual(stream.assert_size,4)

    def test_deep_pairing_json_is_a_controlled_rejection(self):
        value=b'['*2000+b']'*2000
        data=io.BytesIO(struct.pack('!I',len(value))+value)
        class Stream:
            recv=data.read
        with self.assertRaisesRegex(ValueError,'invalid pairing JSON'):pairing.receive(Stream())

    def test_invitation_rejects_bad_addresses_ports_and_tokens(self):
        good=dict(addresses=['127.0.0.1'],port=46322,fingerprint='a'*64,token='b'*64)
        self.assertEqual(pairing.parse_invitation(pairing.invitation(**good))['hosts'],['127.0.0.1'])
        for field,value in [('addresses',['name.example']),('addresses',[]),('port',True),('port',0),('token','x'*64),('fingerprint','a')]:
            with self.subTest(field=field):
                with self.assertRaises(ValueError):pairing.parse_invitation(pairing.invitation(**dict(good,**{field:value})))

    def test_unauthenticated_discovery_cannot_select_receiver(self):
        secret=secrets.token_hex(32);stop=threading.Event();ready=threading.Event();errors=[]
        with socket.socket(socket.AF_INET,socket.SOCK_DGRAM) as probe:
            probe.bind(('127.0.0.1',0));port=probe.getsockname()[1]
        thread=threading.Thread(target=pairing.discovery_listener,args=(secret,stop,ready,errors,port,'127.0.0.1'));thread.start()
        try:
            self.assertTrue(ready.wait(2));self.assertEqual(errors,[])
            with self.assertRaises(ValueError):pairing.discover('0'*64,'127.0.0.1',seconds=0.5,port=port,broadcast=False)
            self.assertEqual(pairing.discover(secret,'127.0.0.1',seconds=1,port=port,broadcast=False),'127.0.0.1')
        finally:stop.set();thread.join(2)
        self.assertFalse(thread.is_alive())


@unittest.skipUnless(os.name=='nt' or sys.platform=='darwin','requires a desktop SDK')
class PairingTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.temporary=tempfile.TemporaryDirectory(prefix='LAN pairing é ');cls.base=Path(cls.temporary.name)
        openssl=ROOT/'third_party/tls-zig/deps/openssl-install/bin/openssl.exe'
        if sys.platform=='darwin':
            openssl=Path(boot.read_json(ROOT/'.lan-audio/mac-sdk.json')['path'])/'bin/openssl'
        cls.pair=cls.base/'pair';create(cls.pair,openssl,'127.0.0.1')

    @classmethod
    def tearDownClass(cls):cls.temporary.cleanup()

    def test_real_tls_pairing_publishes_only_receiver_and_preserves_repeat(self):
        secret=secrets.token_hex(32);codes=queue.Queue();committed=[];received=self.base/'receiver'
        def accept(payload):pairing.save_receiver(received,payload)
        with ThreadPoolExecutor(max_workers=1) as pool:
            future=pool.submit(pairing.offer,self.pair,secret,codes.put,committed.append,['127.0.0.1'],0,8,'127.0.0.1')
            code=codes.get(timeout=3)
            self.assertEqual(pairing.join(code,accept),'127.0.0.1')
            self.assertEqual(future.result(timeout=3),'127.0.0.1')
        self.assertEqual(committed,['127.0.0.1'])
        self.assertEqual({p.name for p in received.iterdir()},pairing.FILES)
        before={p.name:p.read_bytes() for p in received.iterdir()}
        pairing.save_receiver(received,dict(files={k:base64.b64encode(v).decode() for k,v in before.items()},secret=secret))
        self.assertEqual(before,{p.name:p.read_bytes() for p in received.iterdir()})
        altered={k:base64.b64encode(v).decode() for k,v in before.items()};altered['identity.key']=base64.b64encode(b'bad').decode()
        with self.assertRaisesRegex(ValueError,'different saved pair'):pairing.save_receiver(received,dict(files=altered,secret=secret))

    def test_enrollment_with_tls12_provider_and_modern_negotiation(self):
        original=pairing.enrollment_context
        for tls12_only in (True,False):
            with self.subTest(tls12_only=tls12_only):
                observed=[];codes=queue.Queue();committed=[];accepted=[]
                def context(server=False):
                    result=original(server)
                    if not server:
                        if tls12_only:result.maximum_version=ssl.TLSVersion.TLSv1_2
                        wrap=result.wrap_socket
                        def record(*args,**kwargs):
                            stream=wrap(*args,**kwargs);observed.append((stream.version(),stream.cipher()[0]));return stream
                        result.wrap_socket=record
                    return result
                with patch.object(pairing,'enrollment_context',side_effect=context),ThreadPoolExecutor(max_workers=1) as pool:
                    future=pool.submit(pairing.offer,self.pair,secrets.token_hex(32),codes.put,committed.append,['127.0.0.1'],0,8,'127.0.0.1')
                    pairing.join(codes.get(timeout=3),accepted.append);future.result(timeout=3)
                expected='TLSv1.2' if tls12_only or not ssl.HAS_TLSv1_3 else 'TLSv1.3'
                self.assertEqual(observed[0][0],expected)
                if expected=='TLSv1.2':self.assertIn(observed[0][1],['ECDHE-ECDSA-AES256-GCM-SHA384','ECDHE-ECDSA-AES128-GCM-SHA256'])
                self.assertEqual(len(accepted),1);self.assertEqual(committed,['127.0.0.1'])

    def test_wrong_certificate_never_releases_token_or_accepts_payload(self):
        codes=queue.Queue();committed=[];accepted=[]
        with ThreadPoolExecutor(max_workers=1) as pool:
            future=pool.submit(pairing.offer,self.pair,secrets.token_hex(32),codes.put,committed.append,['127.0.0.1'],0,2,'127.0.0.1')
            value=pairing.parse_invitation(codes.get(timeout=2))
            wrong=pairing.invitation(value['hosts'],value['port'],'0'*64,value['token'])
            with self.assertRaisesRegex(ValueError,'certificate differs'):pairing.join(wrong,accepted.append)
            with self.assertRaisesRegex(ValueError,'timed out'):future.result(timeout=4)
        self.assertEqual(accepted,[]);self.assertEqual(committed,[])

    def test_wrong_token_gets_no_private_payload_and_good_retry_succeeds(self):
        codes=queue.Queue();committed=[];accepted=[]
        with ThreadPoolExecutor(max_workers=1) as pool:
            future=pool.submit(pairing.offer,self.pair,secrets.token_hex(32),codes.put,committed.append,['127.0.0.1'],0,8,'127.0.0.1')
            code=codes.get(timeout=3);value=pairing.parse_invitation(code)
            wrong=pairing.invitation(value['hosts'],value['port'],value['pin'],'0'*64)
            with self.assertRaises(ValueError):pairing.join(wrong,accepted.append)
            self.assertEqual(accepted,[]);self.assertEqual(committed,[])
            pairing.join(code,accepted.append);future.result(timeout=3)
        self.assertEqual(len(accepted),1);self.assertEqual(committed,['127.0.0.1'])

    def test_malformed_unicode_token_does_not_kill_listener(self):
        codes=queue.Queue();committed=[];accepted=[]
        with ThreadPoolExecutor(max_workers=1) as pool:
            future=pool.submit(pairing.offer,self.pair,secrets.token_hex(32),codes.put,committed.append,['127.0.0.1'],0,8,'127.0.0.1')
            code=codes.get(timeout=3);value=pairing.parse_invitation(code)
            context=ssl.SSLContext(ssl.PROTOCOL_TLS_CLIENT);context.check_hostname=False;context.verify_mode=ssl.CERT_NONE
            with socket.create_connection(('127.0.0.1',value['port']),timeout=2) as raw:
                with context.wrap_socket(raw,server_hostname='lan-audio-receiver') as stream:
                    pairing.send(stream,dict(token='é'*64))
                    self.assertEqual(stream.recv(1),b'')
            pairing.join(code,accepted.append);future.result(timeout=3)
        self.assertEqual(len(accepted),1);self.assertEqual(committed,['127.0.0.1'])

    def test_receiver_publication_survives_lost_final_response(self):
        codes=queue.Queue();committed=[];received=self.base/'lost-final';secret=secrets.token_hex(32)
        original_send=pairing.send
        def lose_final(stream,value):
            if value==dict(complete=True):raise ConnectionResetError('injected lost final response')
            return original_send(stream,value)
        with patch.object(pairing,'send',side_effect=lose_final),ThreadPoolExecutor(max_workers=1) as pool:
            future=pool.submit(pairing.offer,self.pair,secret,codes.put,committed.append,['127.0.0.1'],0,2,'127.0.0.1')
            code=codes.get(timeout=3)
            with self.assertRaises(ValueError):pairing.join(code,lambda payload:pairing.save_receiver(received,payload))
            with self.assertRaises(ValueError):future.result(timeout=4)
        self.assertTrue((received/'identity.key').is_file());self.assertEqual(committed,['127.0.0.1'])

    def test_remote_filename_injection_never_writes(self):
        destination=self.base/'malicious'
        with self.assertRaises(ValueError):pairing.save_receiver(destination,dict(files={'../escape':'x'},secret='0'*64))
        self.assertFalse(destination.exists());self.assertFalse((self.base/'escape').exists())

    def test_prepared_native_receiver_installs_and_reuses(self):
        target=boot.host_target()
        application=ROOT/'.lan-audio/builds'/boot.source_key(target)/'bin'
        if not application.is_dir():
            self.skipTest('run the checkout launcher --prepare before this native-install check')
        destination=self.base/'native installation'
        self.assertEqual(boot.install(self.pair/'receiver',application,destination)['status'],'installed')
        before={p.name:p.read_bytes() for p in destination.iterdir() if p.is_file()}
        self.assertEqual(boot.install(self.pair/'receiver',application,destination)['status'],'verified-existing')
        self.assertEqual(before,{p.name:p.read_bytes() for p in destination.iterdir() if p.is_file()})
        settings=boot.read_json(destination/'lan-audio.json')
        session=destination/'session.json'
        boot.atomic_json(session,pairing.session_settings(settings,dict(buffer_ms=60)))
        pairing.validate_session(destination/boot.TARGET_FILES[target][0],session)
        boot.atomic_json(session,pairing.session_settings(settings,dict(buffer_ms=200,max_buffer_ms=120)))
        with self.assertRaisesRegex(ValueError,'audio settings rejected'):
            pairing.validate_session(destination/boot.TARGET_FILES[target][0],session)
        self.assertEqual(before['lan-audio.json'],(destination/'lan-audio.json').read_bytes())


if __name__=='__main__':unittest.main(verbosity=2)
