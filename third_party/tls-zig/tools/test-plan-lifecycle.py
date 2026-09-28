"""Exercise plan lifecycle/evidence validation using disposable, explicitly synthetic files.

Run python tools/test-plan-lifecycle.py (also supports Python -O). No native build
or real completion is claimed. Positive fixtures prove the gate can accept a
consistent receipt; mutations prove that specific inconsistent receipts fail.
"""
from pathlib import Path
import copy
import hashlib
import importlib.util
import json
import tempfile


def digest(path):
    """Hash exact fixture bytes with no line-ending normalization."""
    return hashlib.sha256(path.read_bytes()).hexdigest()


def write(root,relative,body):
    """Create only a declared file below the disposable root."""
    p=root/relative;p.parent.mkdir(parents=True,exist_ok=True)
    p.write_text(body,encoding='utf-8');return p


def fixture(base,checker):
    """Build a two-project, cross-dependency completion using synthetic tool files."""
    roots={name:base/name for name in ('tls-zig','quic-zig')}
    nodes=[]
    for name,key,dep in [('tls-zig','T00',[]),('quic-zig','Q00',['T00'])]:
        row=dict(id=key,project=name,path='tools/synthetic.py',card='docs/roadmap/files/tools/synthetic.py.md',milestone=key[0]+'0',status='complete',evidence='docs/verification/completions/'+key+'.json',depends_on=dep,purpose='Synthetic lifecycle fixture; not implemented protocol.',tests=[dict(id=key+'-01',stimulus='synthetic input',expected='synthetic expected result',oracle='fixture-only oracle')])
        root=roots[name]
        source=write(root,row['path'],'# Synthetic fixture, not an implementation.\n')
        contract='docs/reference/files/tools/synthetic.py.md'
        write(root,contract,'Source SHA-256: `'+digest(source)+'`\n')
        inv=dict(project=name,files=[dict(path=row['path'],sha256=digest(source),contract=contract)])
        write(root,'docs/verification/source-inventory.json',json.dumps(inv))
        body='Status: **complete**\nExact work package '+key+'\n'+'\n'.join('`'+d+'`' for d in dep)+'\n'+'\n'.join(row['tests'][0].values())
        write(root,row['card'],body)
        for path in ('src/root.zig','build.zig','build.zig.zon'):
            write(root,path,'// synthetic build input\n')
        if name=='tls-zig':write(root,'backend-lock.json','{"synthetic":true}\n')
        write(root,'docs/verification/logs/synthetic.out','Synthetic stdout; no command was executed.\n')
        write(root,'docs/verification/logs/synthetic.err','')
        inputs=[row['path'],row['card'],contract,'src/root.zig','build.zig','build.zig.zon']+(['backend-lock.json'] if name=='tls-zig' else [])
        receipt=dict(schema=1,node=key,status='passed',obligation_sha256=checker.fingerprint(row),design_sha256=digest(root/row['card']),created_utc='2026-09-26T00:00:00+00:00',reviewer='synthetic fixture',scope_review='Only tests the validator; never native or production evidence.',remaining_gaps=[],environment=dict(zig='synthetic',target='synthetic',os='synthetic',backend='synthetic'),inputs=[dict(project=name,path=p,sha256=digest(root/p)) for p in inputs],runs=[dict(id='run-1',command=['synthetic-command-not-executed'],cwd='.',mode='host-tool',exit_code=0,outcome='passed',stdout=dict(path='docs/verification/logs/synthetic.out',sha256=digest(root/'docs/verification/logs/synthetic.out')),stderr=dict(path='docs/verification/logs/synthetic.err',sha256=digest(root/'docs/verification/logs/synthetic.err')))],acceptance=[dict(id=key+'-01',outcome='passed',observed='Synthetic observation; not a protocol test result.',run_ids=['run-1'])],dependencies=[])
        for d in dep:
            parent=next(n for n in nodes if n['id']==d)
            receipt['dependencies'].append(dict(node=d,project=parent['project'],path=parent['evidence'],sha256=digest(roots[parent['project']]/parent['evidence'])))
        write(root,row['evidence'],json.dumps(receipt))
        nodes.append(row)
    return roots,dict(schema=2,nodes=nodes)


def verify(checker,roots,plan):
    """Run shape/order checks and both projects' local and prerequisite checks."""
    checker.validate(plan)
    for name,root in roots.items():checker.local_check(root,plan,name,roots)


def main():
    root=Path(__file__).resolve().parents[1]
    spec=importlib.util.spec_from_file_location('plan_checker',root/'tools/check-plan.py')
    checker=importlib.util.module_from_spec(spec);spec.loader.exec_module(checker)
    controls=[
        ('failed run',lambda r:r['runs'][0].update(exit_code=1)),
        ('boolean exit code',lambda r:r['runs'][0].update(exit_code=False)),
        ('skipped run',lambda r:r['runs'][0].update(outcome='skipped')),
        ('missing acceptance',lambda r:r.update(acceptance=[])),
        ('skipped acceptance',lambda r:r['acceptance'][0].update(outcome='skipped')),
        ('unknown run',lambda r:r['acceptance'][0].update(run_ids=['missing'])),
        ('stale design',lambda r:r.update(design_sha256='0'*64)),
        ('stale obligation',lambda r:r.update(obligation_sha256='0'*64)),
        ('missing source scope',lambda r:r.update(inputs=r['inputs'][1:])),
        ('source hash mismatch',lambda r:r['inputs'][0].update(sha256='0'*64)),
        ('duplicate input',lambda r:r['inputs'].append(copy.deepcopy(r['inputs'][0]))),
        ('unsafe log path',lambda r:r['runs'][0]['stdout'].update(path='../escape.txt')),
        ('log hash mismatch',lambda r:r['runs'][0]['stdout'].update(sha256='0'*64)),
        ('unresolved gap',lambda r:r.update(remaining_gaps=['still incomplete'])),
        ('missing environment',lambda r:r.pop('environment')),
        ('unknown input project',lambda r:r['inputs'][0].update(project='unknown')),
        ('missing dependency receipt',lambda r:r.update(dependencies=[])),
        ('stale dependency receipt',lambda r:r['dependencies'][0].update(sha256='0'*64)),
    ]
    detected=[];positives=[]
    with tempfile.TemporaryDirectory(prefix='plan-lifecycle-') as tmp:
        roots,plan=fixture(Path(tmp),checker);verify(checker,roots,plan)
        positives.append('consistent cross-project completion')
        if 'false completion' not in checker.self_test(plan):
            raise RuntimeError('self-test missed invalid completion from complete baseline')
        positives.append('negative controls from already-complete baseline')
        child=plan['nodes'][1];path=roots['quic-zig']/child['evidence'];original=path.read_bytes()
        for name,mutate in controls:
            receipt=json.loads(original);mutate(receipt);path.write_text(json.dumps(receipt),encoding='utf-8')
            try:verify(checker,roots,plan)
            except (ValueError,OSError,KeyError,TypeError):detected.append(name)
            else:raise RuntimeError('bad completion accepted: '+name)
            finally:path.write_bytes(original)
        # Byte-level change after evidence creation must invalidate the receipt.
        source=roots['quic-zig']/child['path'];oldsource=source.read_bytes();source.write_bytes(oldsource+b'# drift\n')
        try:verify(checker,roots,plan)
        except ValueError:detected.append('source changed after completion')
        else:raise RuntimeError('source drift escaped')
        source.write_bytes(oldsource)
        # Reopen both dependent nodes; preserve source and remove completion claims.
        for node in plan['nodes']:
            node.update(status='implemented',evidence=None)
            card=roots[node['project']]/node['card'];card.write_text(card.read_text().replace('**complete**','**implemented**'),encoding='utf-8')
        verify(checker,roots,plan);positives.append('reopened implemented work')
        for node in plan['nodes']:
            node['status']='in_progress'
            card=roots[node['project']]/node['card'];card.write_text(card.read_text().replace('**implemented**','**in progress**'),encoding='utf-8')
        verify(checker,roots,plan);positives.append('in-progress documented source')
        for node in plan['nodes']:
            node['status']='planned'
            card=roots[node['project']]/node['card'];card.write_text(card.read_text().replace('**in progress**','**not implemented**'),encoding='utf-8')
        try:verify(checker,roots,plan)
        except ValueError:detected.append('planned state conceals existing source')
        else:raise RuntimeError('unmigrated source escaped')
        for node in plan['nodes']:
            (roots[node['project']]/node['path']).unlink()
        verify(checker,roots,plan);positives.append('planned without source')
    print(json.dumps(dict(passed=True,scope='synthetic lifecycle evidence fixtures; no real work completed',positive_controls=positives,negative_controls_detected=detected),indent=2))


if __name__=='__main__':main()
