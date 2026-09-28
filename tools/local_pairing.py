"""Explicit one-time enrollment over pinned TLS; authenticated LAN rediscovery.

No SSH, cloud, certificate-store changes or plaintext key transfer. Enrollment
requires copying a high-entropy invitation from the trusted PC to the Mac.
"""
import base64
import hashlib
import hmac
import ipaddress
import json
import os
from pathlib import Path
import secrets
import socket
import ssl
import struct
import subprocess
import threading
import time
import uuid

from create_pair import create, private_directory, publish_directory
from setup_desktop import identity, check_credentials, check_binding, read_json, install, TARGET_FILES

ROOT = Path(__file__).resolve().parents[1]
FILES = {'ca.pem', 'identity.pem', 'identity.key', 'identity.json', 'lan-audio.json'}
PAIR_PORT = 46322
DISCOVERY_PORT = 46323
LIMIT = 65536


def enrollment_context(server=False):
    """Pinned enrollment accepts TLS1.2 ECDHE/ECDSA GCM or negotiated TLS1.3.

Python's TLS provider is OS-dependent. The separately built native audio engine
still requires TLS1.3; this control-plane policy does not change its transport.
"""
    context = ssl.SSLContext(ssl.PROTOCOL_TLS_SERVER if server else ssl.PROTOCOL_TLS_CLIENT)
    if not server:
        # Trust is the invitation's leaf digest, checked before the bearer token.
        context.check_hostname = False
        context.verify_mode = ssl.CERT_NONE
    context.minimum_version = ssl.TLSVersion.TLSv1_2
    context.set_ciphers('ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-ECDSA-AES128-GCM-SHA256')
    return context


def receive_exact(stream, size):
    result = bytearray()
    while len(result) < size:
        data = stream.recv(size-len(result))
        if not data:
            raise ValueError('pairing connection ended before completion')
        result.extend(data)
    return bytes(result)


def receive(stream):
    size, = struct.unpack('!I', receive_exact(stream, 4))
    if size > LIMIT:
        raise ValueError('pairing message exceeds 64 KiB')
    try:
        value = json.loads(receive_exact(stream, size))
        pending = [(value, 0)]
        while pending:
            item, depth = pending.pop()
            if depth > 8:
                raise ValueError('pairing nesting limit')
            if isinstance(item, dict):
                pending.extend((child, depth+1) for child in item.values())
            elif isinstance(item, list):
                pending.extend((child, depth+1) for child in item)
        return value
    except (ValueError, RecursionError):
        raise ValueError('invalid pairing JSON') from None


def send(stream, value):
    data = json.dumps(value).encode()
    if len(data) > LIMIT:
        raise ValueError('pairing message exceeds 64 KiB')
    stream.sendall(struct.pack('!I', len(data))+data)


def local_addresses():
    addresses = set()
    if os.name == 'nt':
        command = ['powershell.exe', '-NoProfile', '-Command', "Get-NetIPAddress -AddressFamily IPv4 | Where-Object { $_.AddressState -eq 'Preferred' } | Select-Object -ExpandProperty IPAddress"]
        text = subprocess.check_output(command, text=True, timeout=20)
        candidates = text.split()
    else:
        import re
        text = subprocess.check_output(['/sbin/ifconfig'], text=True, timeout=10)
        candidates = re.findall(r'\binet (\d+\.\d+\.\d+\.\d+)', text)
    for text in candidates:
        ip = ipaddress.ip_address(text)
        if ip.version == 4 and not ip.is_loopback and not ip.is_unspecified:
            addresses.add(str(ip))
    if not addresses:
        raise ValueError('no active IPv4 network address found; connect both devices to the same LAN')
    return sorted(addresses)[:8]


def invitation(addresses, port, fingerprint, token):
    data = json.dumps(dict(v=1, hosts=addresses, port=port, pin=fingerprint, token=token), separators=(',', ':')).encode()
    return 'LAN1.'+base64.urlsafe_b64encode(data).decode().rstrip('=')


def parse_invitation(text):
    if not text.startswith('LAN1.') or len(text) > 2048:
        raise ValueError('paste the complete LAN1 pairing text from your PC')
    try:
        value = json.loads(base64.b64decode(text[5:]+'='*((-len(text[5:]))%4), altchars=b'-_', validate=True))
        if set(value) != {'v','hosts','port','pin','token'} or type(value['v']) is not int or value['v'] != 1:
            raise ValueError()
        if not isinstance(value['hosts'], list) or not 1 <= len(value['hosts']) <= 8:
            raise ValueError()
        for ip in value['hosts']:
            if str(ipaddress.IPv4Address(ip)) != ip:
                raise ValueError()
        if type(value['port']) is not int or not 1 <= value['port'] <= 65535:
            raise ValueError()
        for field in ('pin','token'):
            if not isinstance(value[field], str) or len(value[field]) != 64 or len(bytes.fromhex(value[field])) != 32:
                raise ValueError()
        return value
    except (ValueError, KeyError, TypeError):
        raise ValueError('invalid LAN1 pairing text') from None


def save_receiver(folder, payload):
    """Validate fixed-name identity before exclusive publication; never unpack a remote archive."""
    if not isinstance(payload, dict) or set(payload) != {'files', 'secret'} or not isinstance(payload['files'], dict) or set(payload['files']) != FILES:
        raise ValueError('invalid pairing payload')
    if not isinstance(payload['secret'], str) or len(payload['secret']) != 64 or len(bytes.fromhex(payload['secret'])) != 32:
        raise ValueError('invalid discovery secret')
    contents = {}
    for name, value in payload['files'].items():
        if not isinstance(value, str) or len(value) > 32768:
            raise ValueError('invalid pairing file')
        contents[name] = base64.b64decode(value, validate=True)
    if folder.exists():
        if any((folder/name).read_bytes() != data for name,data in contents.items()):
            raise ValueError('this Mac already has a different saved pair; existing identity retained')
        return
    stage = folder.parent/('.receiver-'+uuid.uuid4().hex)
    private_directory(stage)
    # Failed stages remain private for diagnosis, never adopted as a completed pair.
    for name, data in contents.items():
        (stage/name).write_bytes(data)
    selected, _ = identity(stage)
    if selected['role'] != 'receiver':
        raise ValueError('expected receiver identity')
    check_binding(read_json(stage/'lan-audio.json'), selected)
    check_credentials(stage)
    publish_directory(stage, folder)


def join(text, accept):
    value = parse_invitation(text)
    context = enrollment_context()
    errors = []
    for address in value['hosts']:
        try:
            with socket.create_connection((address,value['port']), timeout=5) as raw:
                with context.wrap_socket(raw, server_hostname='lan-audio-receiver') as stream:
                    stream.settimeout(20)
                    actual = hashlib.sha256(stream.getpeercert(binary_form=True)).hexdigest()
                    if not hmac.compare_digest(actual, value['pin']):
                        raise ValueError('pairing certificate differs from the PC invitation')
                    send(stream, dict(token=value['token']))
                    payload = receive(stream)
                    accept(payload)  # Durable local publication before acknowledging.
                    send(stream, dict(accepted=True))
                    if receive(stream) != dict(complete=True):
                        raise ValueError('PC did not confirm pairing')
                    return address
        except OSError as error:
            errors.append(str(error))
    raise ValueError('Could not reach the PC pairing listener. Check same LAN and allow Python on the Windows private-network firewall. '+ '; '.join(errors))


def offer(pair, secret, ready, commit, addresses=None, port=PAIR_PORT, seconds=600, bind_address='0.0.0.0'):
    receiver = pair/'receiver'
    selected, _ = identity(receiver)
    payload = dict(files={name:base64.b64encode((receiver/name).read_bytes()).decode('ascii') for name in FILES}, secret=secret)
    context = enrollment_context(server=True)
    context.load_cert_chain(str(receiver/'identity.pem'), str(receiver/'identity.key'))
    token = secrets.token_hex(32)
    with socket.socket() as listener:
        # No SO_REUSEADDR on Windows: another listener must not share enrollment.
        listener.bind((bind_address,port)); listener.listen(4); listener.settimeout(1)
        ready(invitation(addresses or local_addresses(), listener.getsockname()[1], selected['fingerprint'], token))
        deadline = time.monotonic()+seconds
        while time.monotonic() < deadline:
            try:
                raw, peer = listener.accept()
            except socket.timeout:
                continue
            try:
                with raw:
                    raw.settimeout(min(5, max(0.1, deadline-time.monotonic())))
                    with context.wrap_socket(raw, server_side=True) as stream:
                        request = receive(stream)
                        if not isinstance(request, dict) or set(request) != {'token'} or not isinstance(request['token'], str) or len(request['token']) != 64 or not request['token'].isascii() or not hmac.compare_digest(request['token'], token):
                            continue
                        stream.settimeout(min(30, max(0.1, deadline-time.monotonic())))
                        send(stream, payload)
                        if receive(stream) != dict(accepted=True):
                            continue
                        commit(peer[0])
                        send(stream, dict(complete=True))
                        return peer[0]
            except (OSError, ValueError):
                continue
    raise ValueError('pairing timed out after ten minutes; run the same command on both devices to retry')


def proof(secret, message):
    return hmac.digest(bytes.fromhex(secret), message, 'sha256')


def discovery_listener(secret, stop, ready, errors, port=DISCOVERY_PORT, bind_address='0.0.0.0'):
    try:
        with socket.socket(socket.AF_INET, socket.SOCK_DGRAM) as sock:
            sock.bind((bind_address,port)); sock.settimeout(0.5); ready.set()
            while not stop.is_set():
                try:
                    data, peer = sock.recvfrom(256)
                except socket.timeout:
                    continue
                if len(data) == 52 and data[:4] == b'LAQ1' and hmac.compare_digest(data[20:], proof(secret,data[:20])):
                    response = b'LAR1'+data[4:20]
                    sock.sendto(response+proof(secret,response), peer)
    except OSError as error:
        errors.append(error); ready.set()


def discover(secret, previous=None, seconds=5, port=DISCOVERY_PORT, broadcast=True):
    nonce = secrets.token_bytes(16)
    request = b'LAQ1'+nonce
    with socket.socket(socket.AF_INET, socket.SOCK_DGRAM) as sock:
        sock.setsockopt(socket.SOL_SOCKET, socket.SO_BROADCAST, 1)
        sock.settimeout(0.4)
        deadline = time.monotonic()+seconds
        while time.monotonic() < deadline:
            for host in ([previous] if previous else [])+(['255.255.255.255'] if broadcast else []):
                try:
                    sock.sendto(request+proof(secret,request), (host,port))
                except OSError:
                    pass
            try:
                data, peer = sock.recvfrom(256)
            except socket.timeout:
                continue
            if len(data) == 52 and data[:20] == b'LAR1'+nonce and hmac.compare_digest(data[20:], proof(secret,data[:20])):
                return peer[0]
    raise ValueError('paired Mac not found. Start sh start on the Mac first, allow incoming connections, and use the same LAN. For blocked broadcast, set receiver_address in launcher JSON.')


def session_settings(saved_settings, audio):
    """Copy a saved profile before applying a launcher-owned home-session override."""
    import copy
    from launcher_config import validate_layer
    validate_layer(dict(audio=audio))
    configuration = copy.deepcopy(saved_settings)
    home = next(p for p in configuration['profiles'] if p['name'] == 'home')
    home['settings'].update(audio)
    return configuration


def validate_session(binary, session):
    result = subprocess.run([str(binary), 'validate', '--config', str(session), '--profile', 'home'], capture_output=True, timeout=20)
    if result.returncode:
        raise ValueError('audio settings rejected: '+result.stderr.decode('utf-8', errors='replace').strip())
    if json.loads(result.stdout).get('valid') is not True:
        raise ValueError('native application did not validate these audio settings')


def connect_and_run(state, application, target, receiver_address=None, audio=None):
    from bootstrap import atomic_json, digest
    sender = target == 'windows-x86_64'
    saved = state/'link.json'
    pair = state/'pair'
    role_folder = pair/'sender' if sender else state/'receiver'
    release_key = hashlib.sha256(''.join(digest(application/name) for name in TARGET_FILES[target]).encode()).hexdigest()[:24]
    releases = state/'releases'; releases.mkdir(exist_ok=True)
    installed = releases/release_key
    if not saved.exists():
        if sender:
            create(pair, ROOT/'third_party/tls-zig/deps/openssl-install/bin/openssl.exe', '127.0.0.1')
            secret_file = state/'discovery.json'
            if not secret_file.exists():
                atomic_json(secret_file, dict(secret=secrets.token_hex(32)))
            secret = read_json(secret_file)['secret']
            def ready(text):
                print('\nOn the Mac run: sh start\nPaste this entire pairing text when asked (keep it private):\n\n'+text+'\n\nWaiting for the Mac (up to 10 minutes)...', flush=True)
            # Recover enrollment whose last ACK was lost: the receiver may
            # already have durably saved this pair and started discovery.
            address = None
            try:
                address = discover(secret, seconds=1)
            except ValueError:
                pass
            if address:
                atomic_json(saved, dict(secret=secret, address=address))
            else:
                offer(pair, secret, ready, lambda address: atomic_json(saved, dict(secret=secret, address=address)))
        else:
            print('Run start.cmd on Windows. Copy its complete LAN1 pairing text.')
            text = input('Paste pairing text here, then press Return: ').strip()
            def accept(payload):
                save_receiver(role_folder, payload)
                install(role_folder, application, installed)
                # Commit before ACK; after a lost final response, rerunning the
                # Mac starts this receiver and the PC can rediscover its secret.
                atomic_json(saved, dict(secret=payload['secret']))
            address = join(text, accept)
            value = read_json(saved); value['address'] = address
            atomic_json(saved, value)
    link = read_json(saved)
    if not isinstance(link.get('secret'), str) or len(link['secret']) != 64 or len(bytes.fromhex(link['secret'])) != 32:
        raise ValueError('saved discovery secret is invalid; pair files were preserved')
    install(role_folder, application, installed)
    settings = state/'settings.json'
    if not settings.exists():
        atomic_json(settings, read_json(installed/'lan-audio.json'))
    configuration = read_json(settings)
    selected, _ = identity(role_folder)
    check_binding(configuration, selected)
    configuration = session_settings(configuration, audio or {})
    binary = installed/TARGET_FILES[target][0]
    session = installed/'session.json'
    atomic_json(session, configuration)
    # Validate the complete effective native profile before discovery/audio.
    validate_session(binary, session)
    stop, ready = threading.Event(), threading.Event()
    errors = []; thread = None
    if sender:
        address = str(ipaddress.IPv4Address(receiver_address)) if receiver_address else discover(link['secret'], link.get('address'), seconds=15)
        for profile in configuration['profiles']:
            if profile['name'] == 'home':
                profile['settings']['address'] = address
        if address != link.get('address'):
            atomic_json(saved, dict(link, address=address))
        print('Sending Windows system audio to '+address+'. Ctrl+C stops audio.', flush=True)
    else:
        thread = threading.Thread(target=discovery_listener, args=(link['secret'],stop,ready,errors), daemon=True)
        thread.start(); ready.wait(5)
        if errors or not ready.is_set():
            raise ValueError('could not open receiver discovery port: '+str(errors))
        print('Mac receiver ready. Start start.cmd on Windows. Ctrl+C stops audio.', flush=True)
    # Resolve only the address into a transient profile. Keep user settings intact.
    atomic_json(session, configuration)
    child = None
    try:
        child = subprocess.Popen([str(binary), 'run', '--config', str(session), '--profile', 'home'])
        result = child.wait()
        if result:
            raise ValueError(f'audio process exited with code {result}; see its diagnostic above')
    finally:
        stop.set()
        if thread:
            thread.join(timeout=2)
        if child and child.poll() is None:
            # Ctrl+C goes to the native process too; allow its normal drain first.
            try:
                child.wait(timeout=5)
            except subprocess.TimeoutExpired:
                child.terminate(); child.wait(timeout=5)
