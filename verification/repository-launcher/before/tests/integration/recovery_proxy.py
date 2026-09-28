"""Run both real supervisors through a bounded ciphertext-only TCP stall proxy.

The proxy knows no keys or PCM. It delays one direction on the first connection,
then requires both owners to recover and finish a fresh authenticated session.
"""
import argparse
import hashlib
import json
import os
from pathlib import Path
import queue
import re
import select
import socket
import subprocess
import threading
import time
from verified_channel_peer import ROOT, TLS, fingerprint


def exercise():
    executable = ROOT/'zig-out/bin/audio-recovery-probe.exe'
    env = dict(os.environ, OPENSSL_CONF=str(TLS/'deps/openssl-install/ssl/openssl.cnf'), OPENSSL_MODULES=str(TLS/'deps/openssl-install/lib/ossl-modules'))
    receiver = subprocess.Popen([str(executable),'receiver','0',fingerprint('client.pem'),'proxy-listener'],cwd=TLS,env=env,stdout=subprocess.PIPE,stderr=subprocess.PIPE,text=True)
    lines=queue.Queue()
    reader=threading.Thread(target=lambda:lines.put(receiver.stderr.readline()),daemon=True)
    reader.start()
    sender=None
    stop=threading.Event()
    observations=[]
    thread=None
    try:
        ready=lines.get(timeout=5); reader.join(1)
        port=int(re.search(r'Listening on 127.0.0.1:(\d+);',ready).group(1))
        with socket.socket() as listener:
            listener.bind(('127.0.0.1',0)); listener.listen(4); listener.settimeout(.1)
            def proxy():
                number=0
                try:
                    while not stop.is_set():
                        try: client,_=listener.accept()
                        except socket.timeout: continue
                        number+=1
                        peer=dict(connection=number,peak_queued_bytes=0,delayed=False,received_bytes=0,forwarded_bytes=0,media_direction_bytes=0,stall_start_seconds=None)
                        observations.append(peer)
                        with client, socket.create_connection(('127.0.0.1',port),timeout=4) as backend:
                            endpoints=[client,backend]; buffers=[bytearray(),bytearray()]
                            for endpoint in endpoints:
                                endpoint.setblocking(False); endpoint.setsockopt(socket.IPPROTO_TCP,socket.TCP_NODELAY,1)
                            started=time.monotonic()
                            stall_until=None
                            while not stop.is_set():
                                elapsed=time.monotonic()-started
                                if elapsed>8: raise TimeoutError('connection exceeded proxy watchdog')
                                # Ciphertext volume, not connection age, ensures
                                # device setup/handshake cannot consume the stall.
                                if number==1 and stall_until is None and peer['media_direction_bytes']>=64000:
                                    peer['stall_start_seconds']=elapsed
                                    stall_until=elapsed+.15
                                delayed=stall_until is not None and elapsed<stall_until
                                peer['delayed'] |= delayed
                                reads=[endpoints[i] for i in range(2) if len(buffers[1-i])<131072]
                                writes=[endpoints[i] for i in range(2) if buffers[i] and not(i==1 and delayed)]
                                readable,writable,_=select.select(reads,writes,[],.002)
                                ended=False
                                for endpoint in readable:
                                    i=endpoints.index(endpoint)
                                    try: data=endpoint.recv(min(16384,131072-len(buffers[1-i])))
                                    except (ConnectionError,OSError): ended=True; break
                                    if not data: ended=True; break
                                    buffers[1-i].extend(data); peer['received_bytes']+=len(data)
                                if ended: break
                                for endpoint in writable:
                                    i=endpoints.index(endpoint)
                                    try: sent=endpoint.send(buffers[i])
                                    except BlockingIOError: continue
                                    except OSError: ended=True; break
                                    del buffers[i][:sent]; peer['forwarded_bytes']+=sent
                                    if i==1: peer['media_direction_bytes']+=sent
                                peer['peak_queued_bytes']=max(peer['peak_queued_bytes'],sum(map(len,buffers)))
                                if ended: break
                except Exception as error:
                    observations.append(dict(error=f'{type(error).__name__}: {error}'))
            thread=threading.Thread(target=proxy,daemon=True); thread.start()
            sender=subprocess.Popen([str(executable),'sender',str(listener.getsockname()[1]),fingerprint('server.pem'),'proxy'],cwd=TLS,env=env,stdout=subprocess.PIPE,stderr=subprocess.PIPE,text=True)
            so,se=sender.communicate(timeout=15)
            ro,receiver_errors=receiver.communicate(timeout=10)
            stop.set(); thread.join(2)
        send_events=[json.loads(line) for line in so.splitlines() if line.startswith('{')]
        receive_events=[json.loads(line) for line in ro.splitlines() if line.startswith('{')]
        good=(sender.returncode==receiver.returncode==0 and len(send_events)>=2 and len(receive_events)>=2
              and observations[0]['delayed'] and not any('error' in p for p in observations) and not thread.is_alive()
              and send_events[-1]['failure'] is None and receive_events[-1]['failure'] is None
              and send_events[-1]['frames']==receive_events[-1]['frames']
              and receive_events[0]['failure']=='PlaybackStarved'
              and receive_events[0]['prefill_frames']==1920
              and receive_events[-1]['prefill_frames']>=2880)
        for event in send_events+receive_events:
            state=event['lifecycle']
            good &= state['held']==[False]*3 and state['pending'] is None and state['phase']=='stopped'
        return dict(matched=bool(good),sender=send_events,receiver=receive_events,proxy=observations,sender_stderr=se,receiver_stderr=ready+receiver_errors)
    finally:
        stop.set()
        for child in [sender,receiver]:
            if child and child.poll() is None:
                child.kill(); child.communicate(timeout=3)
        if thread: thread.join(2)


if __name__=='__main__':
    parser=argparse.ArgumentParser(); parser.add_argument('--output',type=Path,required=True); args=parser.parse_args()
    output=(ROOT/args.output).resolve()
    if output.exists() or not output.is_relative_to(ROOT/'verification'): parser.error('choose new verification output')
    result=exercise()
    result['binary_sha256']=hashlib.sha256((ROOT/'zig-out/bin/audio-recovery-probe.exe').read_bytes()).hexdigest()
    output.write_text(json.dumps(result,indent=2)+'\n')
    print(json.dumps(result,indent=2))
    if not result['matched']: raise SystemExit(1)
