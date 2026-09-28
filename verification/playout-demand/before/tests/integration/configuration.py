"""Independent CLI config acceptance. No credentials, capture or speaker output.

Uses nonexistent credential references to prove validate never opens them. A
loopback occupied port proves run reaches the configured receiver operation and
fails before native audio acquisition. Temporary profiles are never persisted.
"""
import copy
import json
import os
from pathlib import Path
import socket
import subprocess
import tempfile

ROOT = Path(__file__).resolve().parents[2]
EXE = ROOT / 'zig-out/bin' / ('lan-audio.exe' if os.name == 'nt' else 'lan-audio')


def exercise():
    observations = []
    with tempfile.TemporaryDirectory(prefix='lan audio config ') as directory:
        root = Path(directory)
        config = root / 'profiles.json'
        base = dict(schema=1, defaults=dict(role='receive', ca='missing ca.pem', cert='missing cert.pem',
                    key='missing key.pem', peer_fingerprint='ab'*32, reconnect=False),
                    profiles=[dict(name='home', settings=dict(address='127.0.0.1', buffer_ms=40)),
                              dict(name='other', settings=dict(address='::1', buffer_ms=80))])

        def invoke(document, profile='home', expected=None, command='validate'):
            config.write_text(document if isinstance(document, str) else json.dumps(document), encoding='utf-8')
            result = subprocess.run([str(EXE), command, '--config', str(config), '--profile', profile],
                                    cwd=ROOT, capture_output=True, text=True, timeout=15)
            if expected:
                assert result.returncode != 0 and expected in result.stderr, (result.stdout, result.stderr, expected)
                if command == 'validate':
                    assert 'Starting' not in result.stdout and 'Listening' not in result.stderr
            else:
                assert result.returncode == 0, result.stderr
                parsed = json.loads(result.stdout)
                assert parsed['valid'] and not any(parsed[k] for k in ('credentials_checked', 'device_checked', 'network_checked'))
                assert 'ab'*32 not in result.stdout and 'missing' not in result.stdout
            observations.append(dict(command=command, profile=profile, expected=expected, exit_code=result.returncode))
            return result

        first = invoke(base).stdout
        assert first == invoke(base).stdout
        assert json.loads(invoke(base, 'other').stdout)['buffer_ms'] == 80
        invoke(base, 'absent', 'ProfileNotFound')
        for field, value, error in [
            ('buffer_ms', 4, 'InvalidOptions'), ('max_buffer_ms', 241, 'InvalidOptions'),
            ('port', 0, 'InvalidOptions'), ('address', 'localhost', 'InvalidAddress'),
            ('key', 'embedded\0key', 'InvalidConfigString'), ('buffer_ms', '40', 'InvalidConfigType'),
            ('buffer_ms', 40.0, 'InvalidConfigType'), ('seconds', -1, 'Overflow'),
            ('reconnect', 'false', 'UnexpectedToken'), ('unknown', 1, 'UnknownField'),
            ('device', None, 'ConfigNullUnsupported'), ('peer_fingerprint', 'bad', 'InvalidFingerprint'),
        ]:
            changed = copy.deepcopy(base)
            changed['profiles'][0]['settings'][field] = value
            invoke(changed, expected=error)
        for capture in ('process_tree', 'browser_tab'):
            changed = copy.deepcopy(base)
            changed['profiles'][0]['settings'].update(role='send', peer_name='receiver', capture=capture)
            invoke(changed, expected='UnsupportedCaptureSelection')
        changed = copy.deepcopy(base)
        changed['schema'] = 99
        invoke(changed, expected='UnsupportedConfigSchema')
        changed = copy.deepcopy(base)
        changed['profiles'].append(changed['profiles'][0])
        invoke(changed, expected='DuplicateProfile')
        invoke('{"schema":1,"schema":1,"profiles":[]}', expected='DuplicateField')
        invoke('['*9+'0'+']'*9, expected='ConfigTooDeep')
        invoke(' '*65537, expected='StreamTooLong')
        with socket.socket() as occupied:
            if hasattr(socket, 'SO_EXCLUSIVEADDRUSE'):
                occupied.setsockopt(socket.SOL_SOCKET, socket.SO_EXCLUSIVEADDRUSE, 1)
            occupied.bind(('127.0.0.1', 0))
            occupied.listen(1)
            changed = copy.deepcopy(base)
            changed['profiles'][0]['settings']['port'] = occupied.getsockname()[1]
            result = invoke(changed, expected='SystemFailure', command='run')
            assert 'Starting the receiver' in result.stdout
        assert sorted(p.name for p in root.iterdir()) == ['profiles.json']
    return dict(cases=observations, repeat_deterministic=True, temporary_config_only=True)


if __name__ == '__main__':
    print(json.dumps(exercise(), indent=2))
