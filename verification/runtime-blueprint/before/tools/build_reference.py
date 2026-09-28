"""Render reviewed file contracts and a navigation inventory; never change pins.

Reads only the three declared sibling projects. Writes only four reference chapters,
the SDK/evidence guides and file-index.json. It does not infer implementation status
from a proposed path, alter source, download dependencies or certify upstream code.
"""
from pathlib import Path
import hashlib
import json
import re

ROOT = Path(__file__).resolve().parents[1]
PROJECTS = {name: ROOT.parent / name for name in ('lan-audio', 'miniaudio-zig', 'tls-zig')}
IGNORED = {'.git', '.zig-cache', '.zig-global-cache', 'zig-out', '__pycache__', 'states'}
OUT = ROOT / 'docs/reference'
GENERATED = {'docs/reference/file-index.json', 'docs/reference/lan-audio.md', 'docs/reference/miniaudio-zig.md', 'docs/reference/tls-zig.md', 'docs/reference/upstream-assets.md', 'docs/reference/evidence.md'}

def inventory():
    for name, root in PROJECTS.items():
        for path in sorted(root.rglob('*')):
            rel = path.relative_to(root)
            # Only the project's top-level verification tree is generated evidence.
            # docs/verification contains authored contracts and must be indexed.
            if not path.is_file() or rel.parts[0] == 'verification' or any(part in IGNORED for part in rel.parts):
                continue
            # Only the installed SDK is admitted. Future upstream build/source trees
            # require their own custody, rather than silently enlarging this index.
            if name == 'tls-zig' and rel.parts[0] == 'deps' and rel.parts[1] != 'openssl-install':
                continue
            yield name, rel.as_posix(), path

def surface(path):
    if path.suffix in {'.zig', '.c', '.h', '.py'}:
        text = path.read_text(encoding='utf-8', errors='replace')
        patterns = [r'^\s*(?:pub\s+)?(?:extern\s+)?fn\s+(\w+)', r'^\s*(?:pub\s+)?const\s+(\w+)\s*=', r'^\s*test\s+"([^"]+)"', r'^def\s+(\w+)', r'^(?:static\s+)?(?:[\w*]+\s+)+(\w+)\s*\(']
        names = []
        for pattern in patterns:
            for name in re.findall(pattern, text, re.M):
                if name not in names and name not in {'if','for','while','switch'}:
                    names.append(name)
        return names
    if path.suffix == '.md':
        return re.findall(r'^#{1,3}\s+(.+)$', path.read_text(encoding='utf-8'), re.M)
    if path.suffix == '.tla':
        return re.findall(r'^(\w+)(?:\([^\n]*?\))?\s*==', path.read_text(encoding='utf-8'), re.M)
    if path.suffix == '.json' and path.stat().st_size < 1000000:
        data = json.loads(path.read_text(encoding='utf-8-sig'))
        return list(data) if isinstance(data, dict) else ['ordered records']
    return []

def asset_role(rel):
    if '/include/' in rel:
        direct = Path(rel).name in {'ssl.h','err.h','x509v3.h'}
        return ('Directly included OpenSSL C boundary header' if direct else 'Installed OpenSSL API/configuration header; transitive or unused by this wrapper')
    if rel.endswith('.dll.a'): return 'Windows DLL import library selected by the native link graph'
    if rel.endswith('.a'): return 'Retained SDK static archive; not the current DLL-linked runtime path'
    if rel.endswith('.dll'): return 'Native runtime or optional provider/engine module; inspect actual load graph before deployment'
    if rel.endswith('.exe'): return 'SDK command-line diagnostic executable; not the application executable'
    if 'LICENSE' in rel: return 'Upstream legal text; preserve exactly and include applicable release notices'
    if '/pkgconfig/' in rel or '/cmake/' in rel: return 'SDK discovery metadata; do not let ambient discovery override reviewed paths'
    return 'Installed OpenSSL configuration/support asset; preserve custody and review if deployed'

def main():
    contracts = json.loads((ROOT / 'tools/reference_contracts.json').read_text(encoding='utf-8'))
    OUT.mkdir(parents=True, exist_ok=True)
    # Reserve generated paths so their own index is complete on the first render.
    for rel in GENERATED:
        path = ROOT / rel
        if not path.exists(): path.write_text('{}\n' if path.suffix == '.json' else '# Pending reference render\n', encoding='utf-8')
    entries = []
    chapters = {name: [f'# {name}: granular file contracts\n', 'Generated from reviewed `tools/reference_contracts.json`. Edit the contract data, then render; do not edit this chapter alone.\n'] for name in PROJECTS}
    assets = ['# Installed OpenSSL SDK: every-file custody and action guide\n', 'Each row is one installed file. These are upstream-owned assets, not locally rewritten implementations. Exact current hashes are observations; `transport-lock.json` and the TLS backend lock remain the reviewed trust inputs. The source archive/build tree is not present in this checkout.\n', '| File | Bytes / SHA-256 | Role and maintenance action |\n| --- | --- | --- |']
    for name, rel, path in inventory():
        key = name + '/' + rel
        if name == 'tls-zig' and rel.startswith('deps/openssl-install/'):
            role = asset_role(rel)
            digest = hashlib.sha256(path.read_bytes()).hexdigest()
            assets.append(f'| `{rel}` | {path.stat().st_size} / `{digest}` | {role}. Never hand-edit; rebuild from verified upstream source for a new target, review changed APIs/imports and repin only through explicit adoption. |')
            entries.append({'project':name,'path':rel,'kind':'upstream-sdk','reference':'docs/reference/upstream-assets.md','anchor':None})
            continue
        if key not in contracts:
            raise SystemExit(f'Missing reviewed contract: {key}')
        contract = contracts[key]
        anchor = 'file-' + re.sub(r'[^a-z0-9]+', '-', rel.lower()).strip('-')
        chapters[name].extend([f'\n<a id="{anchor}"></a>\n\n## `{rel}`\n', f"**Responsibility.** {contract['purpose']}\n", f"**Contract and ownership.** {contract['contract']}\n", f"**Failure/change obligations.** {contract['failure']}\n", f"**Verification.** {contract['verify']}\n", f"**Next actionable work.** {contract['next']}\n"])
        if rel not in GENERATED and rel != 'tools/reference_contracts.json' and not rel.startswith('vendor/'):
            symbols = surface(path)
            if symbols:
                chapters[name].append('**Declared surface / navigation:** ' + '; '.join('`'+x.replace('`','')+'`' for x in symbols) + '.\n')
        entries.append({'project':name,'path':rel,'kind':'authored-or-support','reference':f'docs/reference/{name}.md','anchor':anchor})
    actual = {e['project']+'/'+e['path'] for e in entries if e['kind'] != 'upstream-sdk'}
    if extra := set(contracts)-actual: raise SystemExit('Stale contracts: '+', '.join(sorted(extra)))
    for name, parts in chapters.items(): (OUT/(name+'.md')).write_text('\n'.join(parts),encoding='utf-8')
    (OUT/'upstream-assets.md').write_text('\n'.join(assets)+'\n',encoding='utf-8')
    (OUT/'file-index.json').write_text(json.dumps({'schema':1,'scope':'Current authored/support files and admitted installed SDK; generated evidence indexed separately; caches excluded.','entries':entries},indent=2)+'\n',encoding='utf-8')
    evidence = ['# Evidence, preserved versions and generated outputs\n', 'Evidence files are listed below; the final phase receipts named at the end are generated after this guide to avoid a self-hash cycle. Source before-images preserve old bytes; logs and receipts are observations at their recorded revision, not current-source proofs. Read the associated phase RESULTS/receipt and migration map before interpreting old paths.\n', '| Project-relative evidence path | Responsibility / handling |\n| --- | --- |']
    for name, project in PROJECTS.items():
        folder=project/'verification'
        if not folder.exists(): continue
        for path in sorted(folder.rglob('*')):
            if not path.is_file() or path in {ROOT/'verification/handoff/receipt.json', ROOT/'verification/literate-specification/receipt.json', ROOT/'verification/fidelity-core/receipt.json', ROOT/'verification/v2-independent/receipt.json'}: continue
            rel=path.relative_to(project).as_posix()
            if '/before/' in rel: role='Preserved pre-edit source; use migration/receipt hash and original path to compare; never compile it as current source.'
            elif path.suffix == '.log': role='Raw command output; interpret with command, return code and target. Preserve failures; never relabel the text.'
            elif path.name == 'RESULTS.md': role='Human interpretation of this phase, including measured limits; historical when later source changes.'
            elif 'model' in path.name: role='Bounded model execution and mutations; check spec/config/tool hashes and expected violations.'
            elif 'interop' in path.name: role='Independent peer observations; distinguish expected negative cases from harness defects.'
            else: role='Phase source/migration/command observations; verify named paths and hashes before drawing a freshness claim.'
            evidence.append(f'| `{name}/{rel}` | {role} |')
    evidence.append('\n`verification/handoff/receipt.json` seals the structure revision; `verification/literate-specification/receipt.json` seals the subsequent explanation/model revision; `verification/fidelity-core/receipt.json` seals the pure v2 implementation/documentation revision; `verification/v2-independent/receipt.json` seals independent v2 qualification and capture block assembly. `.zig-cache/`, `.zig-global-cache/`, `zig-out/`, `__pycache__/` and TLC `states/` are generated artifacts, not authored contracts. They must be reproducible or safely disposable; never move their contents into source or treat a cached executable as fresh evidence.\n')
    (OUT/'evidence.md').write_text('\n'.join(evidence),encoding='utf-8')
    print(f'Rendered {len(entries)} file entries: {len(actual)} authored/support, {len(entries)-len(actual)} installed SDK files')

if __name__ == '__main__': main()
