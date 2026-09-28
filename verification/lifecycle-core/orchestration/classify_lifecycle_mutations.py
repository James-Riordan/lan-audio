"""Classify preserved executed-test output; never rerun/relabel compiler failures."""
import hashlib,json,re
from pathlib import Path
p=Path('C:/Projects/lan-audio/verification/lifecycle-core/mutations-2')
prior=json.loads((p/'results.json').read_text(encoding='utf-8'))
rows=[]
for row in prior['results']:
    log=p/(row['mutation']+'.log')
    assert hashlib.sha256(log.read_bytes()).hexdigest()==row['log_sha256']
    blocks=re.split(r'(?m)(?=^\d+/\d+ runtime_lifecycle\.test\.)',log.read_text(encoding='utf-8'))
    candidates=[b for b in blocks if row['expected_test'] in b.split('\n',1)[0]]
    assert len(candidates)==1
    block=candidates[0]
    failure=re.search(r'(?m)(?:^|\.\.\.)FAIL \((TestExpectedEqual|TestExpectedError|TestUnexpectedResult)\)',block)
    assert row['exit_code']!=0 and failure is not None,row['mutation']
    rows.append({**row,'detected':True,'witness':{'test_header':block.splitlines()[0],'test_failure':failure.group(1)}})
result={**prior,'results':rows,'passed':True,'classification_correction':'Earlier classifier required FAIL at line start; Zig also emits it immediately after test-name ellipsis. No executables or logs rerun/changed; compiled tests already rejected all six mutations.'}
with (p/'reviewed-results.json').open('x',encoding='utf-8') as f:json.dump(result,f,indent=2);f.write('\n')
print('Six isolated concrete mutations rejected by exact expected executed tests; raw outputs and earlier classifier results preserved.')
