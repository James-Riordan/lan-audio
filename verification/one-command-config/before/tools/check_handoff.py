"""Read-only exact inventory/contract/reference coverage and source import check.

This is a documentation integrity gate, not a semantic proof or dependency repinner.
It imports the reference renderer's read-only inventory function; never calls main.
"""
import json
import re
import argparse
from build_reference import ROOT, PROJECTS, inventory

parser=argparse.ArgumentParser(description=__doc__)
parser.add_argument('--application-only',action='store_true',help='Check only application coverage; no sibling freshness claim.')
application_only=parser.parse_args().application_only
data=json.loads((ROOT/'docs/reference/file-index.json').read_text(encoding='utf-8'))
if application_only: data['entries']=[item for item in data['entries'] if item['project']=='lan-audio']
contracts=json.loads((ROOT/'tools/reference_contracts.json').read_text(encoding='utf-8'))
actual={(name,rel):path for name,rel,path in inventory() if not application_only or name=='lan-audio'}
declared={(item['project'],item['path']):item for item in data['entries']}
errors=[]
if len(declared)!=len(data['entries']): errors.append('duplicate indexed paths')
for key in actual.keys()-declared.keys(): errors.append(f'unindexed: {key}')
for key in declared.keys()-actual.keys(): errors.append(f'missing indexed file: {key}')
for key,item in declared.items():
    reference=ROOT/item['reference']
    if not reference.is_file(): errors.append(f'missing reference: {reference}');continue
    text=reference.read_text(encoding='utf-8')
    if item['anchor'] and f'id="{item["anchor"]}"' not in text: errors.append(f'missing file anchor: {key}')
    if item['kind']=='upstream-sdk':
        if '`'+item['path']+'`' not in text: errors.append(f'missing SDK row: {key}')
    else:
        contract=contracts.get('/'.join(key),{})
        for field in ('purpose','contract','failure','verify','next'):
            if len(contract.get(field,'').strip())<20: errors.append(f'incomplete {field}: {key}')
for name,rel,path in inventory():
    if name!='lan-audio' or path.suffix!='.zig': continue
    for target in re.findall(r'@import\("([^"]+\.zig)"\)',path.read_text(encoding='utf-8')):
        if not (path.parent/target).is_file(): errors.append(f'broken source import: {rel}: {target}')
for path in (ROOT/'docs/implementation/work-packages').glob('*.md'):
    text=path.read_text(encoding='utf-8')
    if not ('Status:' in text and ('Exit:' in text or 'Complete when' in text)):
        errors.append(f'work package lacks status/exit: {path.name}')
if errors: raise SystemExit('\n'.join(errors))
print(f'PASS: {len(actual)} {"application " if application_only else ""}files have contract/index coverage; local Zig imports and work-package exits resolve')
