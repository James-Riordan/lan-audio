"""Validate planned-file coverage, completion dependencies and test obligations.

Run from anywhere: python tools/check-plan.py [--peer ../tls-zig] [--self-test].
Both projects carry one identical shared plan snapshot; --peer verifies equality
and both sets of local cards. No source file is created or task marked complete.
All paths are relative POSIX spellings. Exit 1 on malformed input or unmet checks.
"""
from pathlib import Path, PurePosixPath
import argparse
import copy
import datetime
import hashlib
import json
import re


def relative(value):
    """Reject ambiguous, escaping and platform-dependent plan paths."""
    if not isinstance(value,str) or not value or '\\' in value or ':' in value:
        raise ValueError('invalid relative path')
    p=PurePosixPath(value)
    if p.is_absolute() or '..' in p.parts or p.as_posix()!=value or value=='.':
        raise ValueError('noncanonical relative path: '+value)
    return value


def validate(plan):
    """Validate schema before constructing a deterministic Kahn topological order."""
    if not isinstance(plan,dict) or plan.get('schema')!=2 or not isinstance(plan.get('nodes'),list) or not plan['nodes']:
        raise ValueError('expected nonempty schema-2 plan')
    nodes={}; paths=set(); tests=set()
    for row in plan['nodes']:
        if not isinstance(row,dict): raise ValueError('work package must be object')
        key=row.get('id')
        if not isinstance(key,str) or not re.fullmatch(r'[TQ][0-9]{2}',key) or key in nodes:
            raise ValueError('invalid or duplicate work package id')
        project=row.get('project')
        if project not in ('quic-zig','tls-zig') or key[0]!=('Q' if project=='quic-zig' else 'T'):
            raise ValueError('invalid project identity')
        path=relative(row.get('path')); card=relative(row.get('card'))
        if card!='docs/roadmap/files/'+path+'.md' or path.startswith('docs/'):
            raise ValueError('card/source path mismatch')
        identity=(project,path.casefold())
        if identity in paths: raise ValueError('duplicate source path')
        paths.add(identity)
        if row.get('status') not in ('planned','in_progress','implemented','complete'): raise ValueError('invalid lifecycle status')
        if row['status']=='complete':
            if relative(row.get('evidence')) != 'docs/verification/completions/'+key+'.json': raise ValueError('invalid completion receipt path')
        elif row.get('evidence') is not None: raise ValueError('uncompleted node must not claim completion evidence')
        deps=row.get('depends_on')
        if not isinstance(deps,list) or any(not isinstance(d,str) for d in deps) or len(deps)!=len(set(deps)):
            raise ValueError('invalid dependency list')
        for field in ('purpose','milestone'):
            if not isinstance(row.get(field),str) or not row[field].strip(): raise ValueError('missing '+field)
        obligations=row.get('tests')
        if not isinstance(obligations,list) or not obligations: raise ValueError('missing acceptance obligations')
        for t in obligations:
            if not isinstance(t,dict): raise ValueError('acceptance must be object')
            tid=t.get('id')
            if not isinstance(tid,str) or not re.fullmatch(re.escape(key)+r'-[0-9]{2}',tid) or tid in tests:
                raise ValueError('invalid or duplicate acceptance id')
            tests.add(tid)
            for field in ('stimulus','expected','oracle'):
                if not isinstance(t.get(field),str) or not t[field].strip(): raise ValueError('missing acceptance '+field)
        nodes[key]=row
    for key,row in nodes.items():
        if any(dep not in nodes for dep in row['depends_on']): raise ValueError('unknown dependency: '+key)
        if row['status']=='complete' and any(nodes[d]['status']!='complete' for d in row['depends_on']): raise ValueError('completion has unfinished prerequisite: '+key)
    remaining=set(nodes); order=[]
    while remaining:
        ready=sorted(k for k in remaining if not (set(nodes[k]['depends_on']) & remaining))
        if not ready: raise ValueError('dependency cycle: '+', '.join(sorted(remaining)))
        order.extend(ready); remaining.difference_update(ready)
    return order



def fingerprint(row):
    """Bind evidence to the stable work obligation, excluding progress metadata."""
    fields = {k: v for k, v in row.items() if k not in ('status', 'evidence')}
    return hashlib.sha256(json.dumps(fields, sort_keys=True, separators=(',', ':')).encode()).hexdigest()


def checked_file(root, reference):
    """Check exact file identity under one root; reject unsafe/malformed references."""
    if not isinstance(reference, dict): raise ValueError('file reference must be object')
    path = relative(reference.get('path')); digest = reference.get('sha256')
    if not isinstance(digest, str) or not re.fullmatch(r'[0-9a-f]{64}', digest):
        raise ValueError('invalid SHA-256 reference')
    p = root/path
    if not p.resolve().is_relative_to(root.resolve()): raise ValueError('file reference escapes project')
    if not p.is_file() or hashlib.sha256(p.read_bytes()).hexdigest() != digest:
        raise ValueError('evidence file mismatch: '+path)
    return p


def evidence_check(root, row, nodes, roots, inventory):
    """Validate a completion receipt's scope, assertions, logs and prerequisite identities.

    This checks recorded evidence consistency, not whether commands were truly run
    or whether the author's input closure/observed assertions are semantically adequate.
    """
    p = root/row['evidence']
    if not p.resolve().is_relative_to(root.resolve()): raise ValueError('receipt escapes project')
    receipt = json.loads(p.read_text(encoding='utf-8'))
    if not isinstance(receipt,dict) or receipt.get('schema') != 1 or receipt.get('node') != row['id'] or receipt.get('status') != 'passed':
        raise ValueError('invalid completion receipt')
    if receipt.get('obligation_sha256') != fingerprint(row): raise ValueError('stale work obligation')
    if receipt.get('design_sha256') != hashlib.sha256((root/row['card']).read_bytes()).hexdigest():
        raise ValueError('stale design card')
    for field in ('created_utc','reviewer','scope_review'):
        if not isinstance(receipt.get(field),str) or not receipt[field].strip(): raise ValueError('missing receipt '+field)
    # ISO parsing catches unparseable attribution dates; a timestamp is not attestation.
    when = datetime.datetime.fromisoformat(receipt['created_utc'].replace('Z','+00:00'))
    if when.utcoffset() is None: raise ValueError('completion date needs timezone')
    if receipt.get('remaining_gaps') != []: raise ValueError('completion has unresolved gaps')
    environment = receipt.get('environment')
    if not isinstance(environment,dict): raise ValueError('missing environment')
    for field in ('zig','target','os','backend'):
        if not isinstance(environment.get(field),str) or not environment[field].strip(): raise ValueError('missing environment '+field)
    inputs = receipt.get('inputs')
    if not isinstance(inputs,list) or not inputs: raise ValueError('missing evidence inputs')
    identities=set()
    for item in inputs:
        if not isinstance(item,dict) or item.get('project') not in roots: raise ValueError('input project unavailable')
        checked_file(roots[item['project']],item)
        identity=(item['project'],item['path'].casefold())
        if identity in identities: raise ValueError('duplicate evidence input')
        identities.add(identity)
    source_row = inventory.get(row['path'])
    if source_row is None: raise ValueError('implemented source has no source contract')
    required = {row['path'],row['card'],source_row['contract'],'src/root.zig','build.zig','build.zig.zon'}
    if row['project']=='tls-zig': required.add('backend-lock.json')
    if any((row['project'],rel.casefold()) not in identities for rel in required):
        raise ValueError('evidence omits required source/build/contract input')
    runs = receipt.get('runs')
    if not isinstance(runs,list) or not runs: raise ValueError('missing execution records')
    by_run={}
    for run in runs:
        if not isinstance(run,dict): raise ValueError('run must be object')
        key=run.get('id')
        if not isinstance(key,str) or not key.strip() or key in by_run: raise ValueError('invalid run id')
        if type(run.get('exit_code')) is not int or run['exit_code'] != 0 or run.get('outcome') != 'passed':
            raise ValueError('completion contains nonpassing run')
        command=run.get('command')
        if not isinstance(command,list) or not command or any(not isinstance(a,str) or not a for a in command):
            raise ValueError('invalid recorded command')
        cwd=run.get('cwd')
        if cwd != '.': relative(cwd)
        if not (root/cwd).resolve().is_relative_to(root.resolve()) or not (root/cwd).is_dir(): raise ValueError('invalid recorded cwd')
        if run.get('mode') not in ('Debug','ReleaseSafe','host-tool','other-qualified'): raise ValueError('missing run mode')
        for stream in ('stdout','stderr'):
            ref=run.get(stream)
            if not isinstance(ref,dict) or not isinstance(ref.get('path'),str) or not ref['path'].startswith('docs/verification/'):
                raise ValueError('logs must be retained verification artifacts')
            checked_file(root,ref)
        by_run[key]=run
    acceptance=receipt.get('acceptance')
    if not isinstance(acceptance,list): raise ValueError('missing acceptance results')
    expected={t['id'] for t in row['tests']}; seen=set(); used=set()
    for result in acceptance:
        if not isinstance(result,dict) or result.get('id') not in expected or result['id'] in seen: raise ValueError('unexpected/duplicate acceptance result')
        seen.add(result['id'])
        if result.get('outcome') != 'passed' or not isinstance(result.get('observed'),str) or not result['observed'].strip():
            raise ValueError('unproven acceptance obligation')
        links=result.get('run_ids')
        if not isinstance(links,list) or not links or any(not isinstance(k,str) or k not in by_run for k in links) or len(links)!=len(set(links)):
            raise ValueError('acceptance references missing or duplicate runs')
        used.update(links)
    if seen!=expected: raise ValueError('incomplete acceptance coverage')
    if used!=set(by_run): raise ValueError('execution record not linked to an obligation')
    dependencies=receipt.get('dependencies')
    if not isinstance(dependencies,list): raise ValueError('missing prerequisite evidence')
    found=set()
    for reference in dependencies:
        if not isinstance(reference,dict): raise ValueError('dependency evidence must be object')
        key=reference.get('node')
        if key not in row['depends_on'] or key in found: raise ValueError('unknown/duplicate prerequisite evidence')
        found.add(key); parent=nodes[key]
        if parent['status']!='complete' or reference.get('project') != parent['project'] or reference.get('path') != parent['evidence']:
            raise ValueError('prerequisite is not completed evidence')
        if parent['project'] not in roots: raise ValueError('peer required for prerequisite evidence')
        checked_file(roots[parent['project']],reference)
    if found!=set(row['depends_on']): raise ValueError('incomplete prerequisite evidence')

def local_check(root,plan,project,roots=None):
    """Check cards for every state; bind implemented source and completed evidence."""
    roots = roots or {project:root}
    expected=set(); nodes={n['id']:n for n in plan['nodes']}
    manifest=json.loads((root/'docs/verification/source-inventory.json').read_text(encoding='utf-8'))
    inventory={r['path']:r for r in manifest['files']}
    for row in plan['nodes']:
        if row['project']!=project: continue
        card=root/row['card']; expected.add(row['card'])
        if not card.resolve().is_relative_to(root.resolve()): raise ValueError('card escapes project')
        if not card.is_file(): raise ValueError('missing planned card: '+row['card'])
        source=root/row['path']; state=row['status']
        if state=='planned' and source.exists(): raise ValueError('planned source already exists; update lifecycle: '+row['path'])
        if state in ('implemented','complete') and not source.is_file(): raise ValueError('implemented source missing')
        if source.exists():
            record=inventory.get(row['path'])
            if record is None: raise ValueError('implemented source has no source contract')
            checked_file(root,record)
            contract=root/relative(record.get('contract'))
            if not contract.resolve().is_relative_to(root.resolve()) or not contract.is_file(): raise ValueError('missing source contract')
            if 'Source SHA-256: `'+record['sha256']+'`' not in contract.read_text(encoding='utf-8'): raise ValueError('source contract hash disagrees')
        body=card.read_text(encoding='utf-8')
        label='not implemented' if state=='planned' else state.replace('_',' ')
        if 'Status: **'+label+'**' not in body or 'Exact work package '+row['id'] not in body:
            raise ValueError('missing lifecycle status/id in card: '+row['id'])
        for dep in row['depends_on']:
            if '`'+dep+'`' not in body: raise ValueError('card omits prerequisite: '+dep)
        for test in row['tests']:
            for value in test.values():
                if value not in body: raise ValueError('card acceptance drift: '+test['id'])
        if state=='complete': evidence_check(root,row,nodes,roots,inventory)
    actual={p.relative_to(root).as_posix() for p in (root/'docs/roadmap/files').rglob('*.md')}
    if actual!=expected: raise ValueError('planned card set differs: '+str(sorted(actual^expected)))


def self_test(plan):
    """Reject nine independently introduced graph/schema defects in memory."""
    controls=[
        ('cycle',lambda p:p['nodes'][0]['depends_on'].append(p['nodes'][0]['id'])),
        ('unknown dependency',lambda p:p['nodes'][0]['depends_on'].append('T99')),
        ('duplicate id',lambda p:p['nodes'].append(copy.deepcopy(p['nodes'][0]))),
        ('unsafe path',lambda p:p['nodes'][0].update(path='../escape.zig')),
        ('noncanonical path',lambda p:p['nodes'][0].update(path='src//a.zig')),
        ('missing oracle',lambda p:p['nodes'][0]['tests'][0].pop('oracle')),
        ('duplicate acceptance',lambda p:p['nodes'][0]['tests'].append(copy.deepcopy(p['nodes'][0]['tests'][0]))),
        ('false completion',lambda p:p['nodes'][0].update(status='complete',evidence=None)),
        ('invalid shape',lambda p:p.update(nodes=[None])),
    ]
    detected=[]
    for name,mutate in controls:
        candidate=copy.deepcopy(plan); mutate(candidate)
        try: validate(candidate)
        except ValueError: detected.append(name)
        else: raise RuntimeError('negative control escaped: '+name)
    return detected


def main():
    ap=argparse.ArgumentParser(description=__doc__)
    ap.add_argument('--peer',type=Path)
    ap.add_argument('--self-test',action='store_true')
    args=ap.parse_args(); root=Path(__file__).resolve().parents[1]
    try:
        project=json.loads((root/'docs/verification/source-inventory.json').read_text(encoding='utf-8'))['project']
        raw=(root/'docs/roadmap/implementation-plan.json').read_bytes(); plan=json.loads(raw)
        order=validate(plan)
        if project not in ('quic-zig','tls-zig'): raise ValueError('invalid local project')
        roots={project:root}; peer_checked=False
        if args.peer:
            peer=args.peer.resolve()
            peer_name=json.loads((peer/'docs/verification/source-inventory.json').read_text(encoding='utf-8'))['project']
            if {project,peer_name}!={'quic-zig','tls-zig'}: raise ValueError('peer must be the other project')
            if raw!=(peer/'docs/roadmap/implementation-plan.json').read_bytes(): raise ValueError('peer plan snapshot differs')
            roots[peer_name]=peer; peer_checked=True
        if any(n['status']=='complete' for n in plan['nodes']) and not peer_checked: raise ValueError('complete shared plan requires --peer verification')
        for name,location in roots.items(): local_check(location,plan,name,roots)
        nodes={n['id']:n for n in plan['nodes']}
        report=dict(passed=True,project=project,work_packages=len(order),acceptance_obligations=sum(len(n['tests']) for n in plan['nodes']),completion_order=order,peer_checked=peer_checked)
        report['states']={state:sum(n['status']==state for n in plan['nodes']) for state in ('planned','in_progress','implemented','complete')}
        report['ready_to_implement']=[k for k in order if nodes[k]['status']!='complete' and all(nodes[d]['status']=='complete' for d in nodes[k]['depends_on'])]
        if args.self_test: report['negative_controls_detected']=self_test(plan)
    except (OSError,ValueError,KeyError,TypeError,RuntimeError) as exc:
        report=dict(passed=False,error=str(exc))
    print(json.dumps(report,indent=2)); raise SystemExit(0 if report['passed'] else 1)


if __name__=='__main__': main()
