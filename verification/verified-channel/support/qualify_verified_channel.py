from pathlib import Path
import hashlib
import json
import subprocess
import sys
import time

ROOT = Path('C:/Projects/lan-audio')
BASE = ROOT/'verification/verified-channel'
RUNS = []

def run(label, command, folder, timeout=240):
    started = time.monotonic()
    process = subprocess.run(command, cwd=ROOT, capture_output=True, timeout=timeout)
    (folder/(label+'.log')).write_bytes(process.stdout+process.stderr)
    item = dict(label=label, command=command, exit_code=process.returncode, seconds=round(time.monotonic()-started,3))
    RUNS.append(item)
    (folder/'runs.json').write_text(json.dumps(RUNS,indent=2))
    print(json.dumps(item),flush=True)
    return process

def mutations():
    folder = BASE/'mutations'
    folder.mkdir()
    path = ROOT/'src/host/verified_channel.zig'
    original = path.read_bytes()
    text = original.decode()
    variants = [
      ('bypass-peer', 'const leaf = try self.driver.engine.verifiedPeerLeafSha256();',
       'const leaf = self.channel.expected_peer;', 'wrong-peer'),
      ('retain-permission', 'self.channel.revoke(self.channel.generation) catch unreachable;', '', 'valid'),
      ('stale-closes-current', 'if (generation != self.channel.generation) return error.StaleGeneration;',
       'if (generation != self.channel.generation) { self.deinit(); return error.StaleGeneration; }', 'valid'),
    ]
    results=[]
    try:
        for name,old,new,only in variants:
            case=folder/name
            case.mkdir()
            if old not in text: raise RuntimeError('missing mutation target')
            variant=text.replace(old,new)
            path.write_text(variant)
            (case/'verified_channel.zig').write_text(variant)
            build=run(name+'-build',['zig','build','verified-transport-probe','-Dtransport-tests=true','--summary','all'],folder)
            if build.returncode: raise RuntimeError('mutant failed to compile')
            probe=run(name+'-peer',[sys.executable,'tests/integration/verified_channel_peer.py','--only',only,'--output',str(case/'peers.json')],folder)
            rows=json.loads((case/'peers.json').read_text())['results']
            caught=probe.returncode != 0 and any(not row['matched'] and 'HARNESS ' not in row['output'] for row in rows)
            results.append(dict(name=name,caught=caught,source_sha256=hashlib.sha256(path.read_bytes()).hexdigest(),failed_cases=[{k:r[k] for k in ('tls_role','audio_role','mode','exit_code')} for r in rows if not r['matched']]))
            (folder/'results.json').write_text(json.dumps(results,indent=2))
            if not caught: raise RuntimeError('mutation survived')
    finally:
        path.write_bytes(original)
        if path.read_bytes()!=original: raise RuntimeError('restore failure')
    print('Restored exact host source after 3 caught compiled mutations',flush=True)

def qualify():
    folder=BASE/'qualified'
    folder.mkdir()
    commands=[
        ('debug-build',['zig','build','verified-transport-probe','v2-transport-probes','transport-probe','policy-test','network-test','-Dtransport-tests=true','--summary','all']),
        ('debug-peer',[sys.executable,'tests/integration/verified_channel_peer.py','--output',str(folder/'debug-peers.json')]),
        ('legacy-v2',[sys.executable,'tests/integration/protocol_v2_peer.py','--output',str(folder/'legacy-v2.json')]),
        ('legacy-v1',[sys.executable,'tools/test_transport.py','--output',str(folder/'legacy-v1.json')]),
        ('safe-build',['zig','build','verified-transport-probe','policy-test','network-test','-Dtransport-tests=true','-Doptimize=ReleaseSafe','--summary','all']),
        ('safe-peer',[sys.executable,'tests/integration/verified_channel_peer.py','--output',str(folder/'safe-peers.json')]),
        ('custody',[sys.executable,'tools/check_transport.py','--staged']),
    ]
    for label,command in commands:
        result=run(label,command,folder,timeout=300)
        if result.returncode:
            print((result.stdout+result.stderr).decode(errors='replace')[-5000:],flush=True)
            raise SystemExit(1)

def buffered_regression():
    folder=BASE/'buffered-record-regression'
    folder.mkdir()
    path=ROOT/'src/host/verified_channel.zig'
    final=path.read_bytes()
    before=(BASE/'buffered-record-review/src/host/verified_channel.zig').read_bytes()
    try:
        path.write_bytes(before)
        result=run('before-build',['zig','build','verified-transport-probe','-Dtransport-tests=true','--summary','all'],folder)
        if result.returncode: raise RuntimeError('historical source did not compile')
        for mode in ('buffered-deadline','after-end'):
            result=run(mode,[sys.executable,'tests/integration/verified_channel_peer.py','--only',mode,'--output',str(folder/(mode+'.json'))],folder)
            rows=json.loads((folder/(mode+'.json')).read_text())['results']
            if result.returncode==0 or not any(not r['matched'] and 'HARNESS ' not in r['output'] for r in rows):
                raise RuntimeError('historical defect not detected')
    finally:
        path.write_bytes(final)
    print('Both buffered-record regressions fail on the preserved earlier source; final source restored.',flush=True)

def final_host():
    folder=BASE/'final-host'
    folder.mkdir()
    for optimize in ('Debug','ReleaseSafe'):
        commands=[
            ('build-'+optimize,['zig','build','verified-transport-probe','-Dtransport-tests=true','-Doptimize='+optimize,'--summary','all']),
            ('peer-'+optimize,[sys.executable,'tests/integration/verified_channel_peer.py','--output',str(folder/(optimize+'.json'))]),
        ]
        for label,command in commands:
            result=run(label,command,folder,timeout=300)
            if result.returncode:
                print((result.stdout+result.stderr).decode(errors='replace')[-5000:],flush=True)
                raise SystemExit(1)

if __name__=='__main__':
    if sys.argv[1]=='mutations': mutations()
    elif sys.argv[1]=='qualify': qualify()
    elif sys.argv[1]=='buffered': buffered_regression()
    elif sys.argv[1]=='final': final_host()
