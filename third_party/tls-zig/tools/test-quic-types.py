"""Compile recordless type-misuse controls; errors must be semantic type mismatches.

No network or native TLS SDK is needed. Python checks remain active under -O.
"""
from pathlib import Path
import argparse
import json
import os
import subprocess


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--zig', default='zig')
    args = parser.parse_args()
    root = Path(__file__).resolve().parents[1]
    env = os.environ.copy()
    env['ZIG_GLOBAL_CACHE_DIR'] = str(root / '.zig-global-cache')
    version = subprocess.check_output([args.zig, 'version'], text=True, env=env).strip()
    if version != '0.17.0-dev.1859+dcceb318e':
        raise RuntimeError('wrong Zig compiler: ' + version)
    cases = [('valid', None), ('direction-as-level', 'EncryptionLevel'),
             ('wall-as-monotonic', 'MonotonicNs'), ('raw-byte-count', 'ByteCount'),
             ('generation-as-sequence', 'Sequence')]
    results = []
    for name, expected in cases:
        command = [args.zig, 'build-obj', '-fno-emit-bin', '--dep', 'tls_quic',
                   '-Mroot=' + str(root / 'tests/quic/negative' / (name + '.zig')),
                   '-Mtls_quic=' + str(root / 'src/quic.zig')]
        run = subprocess.run(command, cwd=root, env=env, capture_output=True, text=True, timeout=120)
        passed = run.returncode == 0 if expected is None else (
            run.returncode != 0 and 'expected type' in run.stderr and expected in run.stderr and 'found' in run.stderr)
        results.append(dict(case=name, passed=passed, compiler_exit=run.returncode,
                            command=command, stdout=run.stdout, stderr=run.stderr))
    passed = all(r['passed'] for r in results)
    print(json.dumps(dict(passed=passed, compiler=version, cases=results), indent=2))
    return 0 if passed else 1


if __name__ == '__main__':
    raise SystemExit(main())
