"""Package native outputs and fetch an exact-commit public GitHub candidate.

Repository trust and GitHub HTTPS/API integrity are required. These are unsigned
candidates, not notarized releases or independent publisher authentication.
"""
import argparse
import hashlib
import json
from pathlib import Path
import re
import subprocess
import sys
import tempfile
import urllib.request
import zipfile

sys.path.insert(0, str(Path(__file__).resolve().parent))
from bootstrap import ROOT, digest, download, extract, source_key, atomic_json
from setup_desktop import TARGET_FILES, host_target, read_json

LICENSES = {
    'LICENSE-miniaudio.txt': ROOT/'third_party/miniaudio-zig/vendor/miniaudio/LICENSE',
    'LICENSE-OpenSSL.txt': ROOT/'third_party/tls-zig/deps/openssl-install/LICENSE.txt',
}


def repository_name(remote):
    match = re.fullmatch(r'(?:https://github\.com/|git@github\.com:)([A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+?)(?:\.git)?/?',remote)
    if not match or any(p in ('.','..') for p in match[1].split('/')):
        raise ValueError('automatic candidate download requires a public github.com origin')
    return match[1]


def revision_id(value):
    if not re.fullmatch('[0-9a-f]{40}',value):
        raise ValueError('expected the full Git commit SHA')
    return value


def package(output, revision):
    target = host_target(); revision_id(revision)
    prefix = ROOT/'.lan-audio/builds'/source_key(target)
    ready = read_json(prefix/'ready.json')
    if set(ready['files']) != set(TARGET_FILES[target]) or any(digest(prefix/'bin'/p)!=h for p,h in ready['files'].items()):
        raise ValueError('prepare this exact source before packaging')
    output.mkdir(parents=True,exist_ok=True)
    destination = output/f'lan-audio-{target}-{revision}.zip'
    with zipfile.ZipFile(destination,'x',compression=zipfile.ZIP_DEFLATED) as archive:
        for name in TARGET_FILES[target]:archive.write(prefix/'bin'/name,name)
        for name,path in LICENSES.items():archive.write(path,name)
        archive.writestr('release.json',json.dumps(dict(schema=1,target=target,revision=revision,source_key=source_key(target),files=ready['files'])))
    return destination


def inspect_payload(folder, target, revision):
    value = read_json(folder/'release.json')
    if set(value) != {'schema','target','revision','source_key','files'} or value['schema'] != 1 or value['target'] != target or value['revision'] != revision or value['source_key'] != source_key(target):
        raise ValueError('release does not match this exact source and target')
    if not isinstance(value['files'],dict) or set(value['files']) != set(TARGET_FILES[target]):
        raise ValueError('invalid release runtime file set')
    if {p.name for p in folder.iterdir()} != set(TARGET_FILES[target])|set(LICENSES)|{'release.json'}:
        raise ValueError('unexpected release contents')
    for name,expected in value['files'].items():
        if digest(folder/name) != expected:raise ValueError('release runtime digest mismatch')
    for name,path in LICENSES.items():
        if digest(folder/name)!=digest(path):raise ValueError('release dependency license differs')
    return value


def fetch(cache, target, prefix):
    try:
        remote = subprocess.check_output(['git','remote','get-url','origin'],cwd=ROOT,text=True,stderr=subprocess.DEVNULL,timeout=10).strip()
        revision = revision_id(subprocess.check_output(['git','rev-parse','HEAD'],cwd=ROOT,text=True,timeout=10).strip())
        repository = repository_name(remote)
        tag = 'desktop-'+revision
        request = urllib.request.Request(f'https://api.github.com/repos/{repository}/releases/tags/{tag}',headers={'Accept':'application/vnd.github+json','User-Agent':'lan-audio-launcher','X-GitHub-Api-Version':'2022-11-28'})
        with urllib.request.urlopen(request,timeout=30) as response:
            data=response.read(1024*1024+1)
        if len(data)>1024*1024:raise ValueError('release metadata exceeds 1 MiB')
        release=json.loads(data)
        name=f'lan-audio-{target}-{revision}.zip'
        asset=next((a for a in release.get('assets',[]) if a.get('name')==name),None)
        if not asset or not re.fullmatch(r'sha256:[0-9a-f]{64}',asset.get('digest','')):
            raise ValueError('release has no matching asset with a GitHub SHA256 digest')
        expected_url=f'https://github.com/{repository}/releases/download/{tag}/{name}'
        if asset.get('browser_download_url')!=expected_url or type(asset.get('size')) is not int or not 0<asset['size']<=128*1024*1024:
            raise ValueError('release URL or size differs from this repository candidate')
        archive=download(dict(urls=[expected_url],sha256=asset['digest'][7:],size=asset['size'],archive='zip'),cache)
        prefix.parent.mkdir(parents=True,exist_ok=True)
        with tempfile.TemporaryDirectory(prefix='release-',dir=cache) as text:
            stage=Path(text)/'payload';stage.mkdir();extract(archive,stage,'zip')
            value=inspect_payload(stage,target,revision)
            for name in TARGET_FILES[target]:
                if target.startswith('macos'):(stage/name).chmod(0o755)
            # Execute the hash-checked binary before admitting it as a usable build.
            subprocess.run([str(stage/TARGET_FILES[target][0]),'help'],check=True,stdout=subprocess.DEVNULL,timeout=20)
            from create_pair import publish_directory
            prefix.mkdir(exist_ok=True)
            if (prefix/'bin').exists():
                inspect_payload(prefix/'bin',target,revision)
            else:
                publish_directory(stage,prefix/'bin')
            atomic_json(prefix/'ready.json',dict(files=value['files']))
        return prefix/'bin'
    except (OSError,ValueError,KeyError,TypeError,subprocess.SubprocessError) as error:
        raise ValueError('This pinned compiler needs macOS 14+. On macOS 12/13 the launcher needs an exact-commit public GitHub desktop candidate. The maintainer must run Desktop clone and build with publish enabled for this revision. No matching usable candidate is available: '+str(error)) from None


if __name__=='__main__':
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--output',type=Path,required=True)
    parser.add_argument('--revision',required=True)
    args=parser.parse_args()
    print(package(args.output,args.revision))
