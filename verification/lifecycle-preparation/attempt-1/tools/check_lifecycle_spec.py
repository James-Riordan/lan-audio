"""Run the finite lifecycle specification and require named defect witnesses.

Print JSON to stdout; no source/evidence files are overwritten. Redirect to a new
phase report. Failed exploration or wrong/missing mutation witness exits nonzero.
"""
import hashlib
import importlib.util
import json
from pathlib import Path
import sys

ROOT=Path(__file__).resolve().parents[1]
SOURCE=ROOT/'spec/runtime/lifecycle_transactions.py'
spec=importlib.util.spec_from_file_location('lifecycle_transactions',SOURCE)
model=importlib.util.module_from_spec(spec)
sys.modules[spec.name]=model
spec.loader.exec_module(model)


def main():
    expected={'forget_pending':'OutstandingTracked',
              'lose_late_success':'SuccessfulAcquisitionTracked',
              'stale_completion':'TokenIsolation',
              'free_live_worker':'WorkerLifetime',
              'free_unjoined_device':'NativeJoinBeforeRelease'}
    normal=[model.explore(n) for n in (1,2)]
    mutants=[]
    for fault,witness in expected.items():
        result=model.explore(2,fault)
        result['expected_violation']=witness
        result['detected_expected']=not result['passed'] and result.get('violation')==witness
        mutants.append(result)
    passed=all(x['passed'] for x in normal) and all(x['detected_expected'] for x in mutants)
    report={'passed':passed,'python':sys.version,'model_sha256':hashlib.sha256(SOURCE.read_bytes()).hexdigest(),
            'runner_sha256':hashlib.sha256(Path(__file__).read_bytes()).hexdigest(),
            'normal':normal,'mutations':mutants,
            'limits':['Finite specification, not production lifecycle code.',
                      'Cleanup reachability is existential, not all-schedule liveness or an OS deadline.',
                      'Media, authorization, TLS buffers, weak memory and process crash are not modeled.']}
    print(json.dumps(report,indent=2))
    return 0 if passed else 1


if __name__=='__main__':
    raise SystemExit(main())
