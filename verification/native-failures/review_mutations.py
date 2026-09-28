"""Preserve initial classification; verify the actual pinned-toolchain witnesses."""
from pathlib import Path
import hashlib
import json
import re

out=Path(__file__).with_name('mutations')
rows=json.loads((out/'results.json').read_text(encoding='utf-8'))
markers={
    'start-error-ready':'expected .failed, found .ready',
    'stop-error-ready':'expected .failed, found .ready',
    'writable-means-connected':'expected error.SystemFailure, found true',
    'eof-closes-both-directions':'return error.InvalidState;',
}
for row in rows:
    log=(out/(row['name']+'.log')).read_bytes()
    assert hashlib.sha256(log).hexdigest()==row['log_sha256']
    text=log.decode('utf-8')
    assert row['exit_code']!=0
    assert re.search(r"error: '[^'\n]*"+re.escape(row['witness'])+r"' failed:",text)
    assert re.search(r'run test \d+ pass, [1-9]\d* fail',text)
    assert 'compile test debug native success' in text
    assert markers[row['name']] in text
    row.update(detected=True, reviewed_runtime_marker=markers[row['name']],
               review='Initial classifier required literal test failure; this compiler reports a named test failed and a run-test failure count. Original records preserved.')
(out/'reviewed-results.json').write_text(json.dumps(rows,indent=2)+'\n',encoding='utf-8')
print('Four compiled mutations rejected by their named runtime witnesses; original classification retained.')
