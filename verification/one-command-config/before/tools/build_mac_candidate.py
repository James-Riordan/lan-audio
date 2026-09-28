"""Build an Intel Monterey candidate ON a Mac from an explicit pinned archive.

App-owned static SDK integration; no sibling sources or Windows pins are changed.
Requires Apple command-line tools, Python 3.9+, Perl/make and the pinned Zig. This
recipe is not evidence of a successful Mac build until its commands actually pass.
"""
import argparse
import hashlib
import json
import os
from pathlib import Path
import platform
import subprocess
import sys
import time

ROOT = Path(__file__).resolve().parents[1]
ZIG_VERSION = '0.17.0-dev.1859+dcceb318e'
OPENSSL_SHA256 = 'a8f84a39918ec6415ce765d9b429d313ba97b8143169c172e734b9514464f5b2'


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--openssl-archive', type=Path, required=True)
    parser.add_argument('--output', type=Path, required=True)
    parser.add_argument('--zig', type=Path, required=True)
    args = parser.parse_args()
    if sys.platform != 'darwin' or platform.machine() != 'x86_64':
        parser.error('run this candidate build on an Intel Mac; cross-builds are not qualified here')
    archive, output, zig = args.openssl_archive.resolve(), args.output.resolve(), args.zig.resolve()
    if hashlib.sha256(archive.read_bytes()).hexdigest() != OPENSSL_SHA256:
        parser.error('OpenSSL archive differs from the reviewed 3.5.8 source digest')
    if subprocess.check_output([str(zig), 'version'], text=True).strip() != ZIG_VERSION:
        parser.error('Zig version does not match the pinned compiler')
    if output.exists():
        parser.error('use a new output directory; prior build evidence is preserved')
    output.mkdir(parents=False)
    env = dict(os.environ, MACOSX_DEPLOYMENT_TARGET='12.0', LC_ALL='C')
    commands = []
    def run(command, cwd=ROOT):
        command = list(map(str, command))
        started = time.time()
        result = subprocess.run(command, cwd=cwd, env=env, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True)
        log = f'{len(commands):02d}.log'
        (output / log).write_text(result.stdout, encoding='utf-8')
        commands.append(dict(command=command, cwd=str(cwd), exit_code=result.returncode, seconds=round(time.time()-started, 3), log=log))
        (output / 'commands.json').write_text(json.dumps(commands, indent=2)+'\n', encoding='utf-8')
        print(f'{result.returncode}: {" ".join(command)}', flush=True)
        result.check_returncode()
        return result.stdout
    env['SDKROOT'] = run(['xcrun', '--sdk', 'macosx', '--show-sdk-path']).strip()
    env['CC'] = run(['xcrun', '--find', 'clang']).strip()
    run([sys.executable, 'tools/check_transport.py'])
    inputs = {}
    for project in (ROOT, ROOT / 'third_party/tls-zig', ROOT / 'third_party/miniaudio-zig'):
        files = [project / 'build.zig', project / 'build.zig.zon']
        files += [p for p in (project / 'src').rglob('*') if p.is_file()]
        if (project / 'vendor').exists():
            files += [p for p in (project / 'vendor').rglob('*') if p.is_file()]
        for path in sorted(files):
            inputs[project.name + '/' + path.relative_to(project).as_posix()] = hashlib.sha256(path.read_bytes()).hexdigest()
    (output / 'source-inputs.json').write_text(json.dumps(inputs, indent=2)+'\n')
    run([env['CC'], '--version'])
    source, sdk = output / 'source', output / 'openssl-static'
    source.mkdir()
    run(['tar', '-xzf', archive, '-C', source, '--strip-components=1'])
    run(['perl', source / 'Configure', 'darwin64-x86_64-cc', 'no-shared', 'no-module', 'no-quic', 'no-docs',
         '--libdir=lib', f'--prefix={sdk}', f'--openssldir={sdk / "ssl"}', '-mmacosx-version-min=12.0'], cwd=source)
    run(['make', f'-j{min(os.cpu_count() or 2, 8)}'], cwd=source)
    run(['make', 'test'], cwd=source)
    run(['make', 'install_sw'], cwd=source)
    version = run([sdk / 'bin/openssl', 'version', '-a'])
    sdk_files = {p.relative_to(sdk).as_posix(): hashlib.sha256(p.read_bytes()).hexdigest() for p in sorted(sdk.rglob('*')) if p.is_file()}
    (output / 'sdk.json').write_text(json.dumps(dict(source_sha256=OPENSSL_SHA256, minimum_macos='12.0', openssl_version=version, files=sdk_files), indent=2)+'\n')
    run([zig, 'build', 'app', '-j1', '-Dstreaming=true', '-Dtarget=x86_64-macos.12.0', f'-Dmac-openssl-root={sdk}', '-Doptimize=ReleaseSafe'])
    binary = ROOT / 'zig-out/bin/lan-audio'
    linked = run(['otool', '-L', binary])
    if 'libssl' in linked or 'libcrypto' in linked:
        raise RuntimeError('candidate unexpectedly requires external OpenSSL dylibs')
    run(['otool', '-l', binary])
    run([binary, 'help'])
    (output / 'candidate.json').write_text(json.dumps(dict(binary=str(binary), sha256=hashlib.sha256(binary.read_bytes()).hexdigest(),
        zig=ZIG_VERSION, target='x86_64-macos.12.0', status='build-and-help-passed; speaker/Wi-Fi qualification still required'), indent=2)+'\n')


if __name__ == '__main__':
    main()
