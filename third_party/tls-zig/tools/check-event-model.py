"""Exhaustive finite safety model of the PROPOSED acknowledged TLS event boundary.

No TLS implementation is exercised. BFS explores capacity 1 and 2, three emitted
events and all relevant fresh/stale/head/tail/foreign acknowledgement tokens.
Only copied/derived head events may be acknowledged; cancel destroys this owner.
Three injected defects must yield shortest counterexamples. Python 3.10+, no deps.
"""
from collections import deque
from dataclasses import dataclass,replace
import json


@dataclass(frozen=True)
class State:
    """Ghost ledgers retain history; implementation need only retain pending custody."""
    emitted:int=0
    queue:tuple=()
    borrowed:int=-1
    copied:frozenset=frozenset()
    retired:frozenset=frozenset()
    canceled:bool=False


def successors(s,capacity,fault):
    """Enumerate success and stutter attempts under a serialized owner (issuer 7)."""
    if not s.canceled:
        if s.emitted<3:
            if len(s.queue)<capacity:
                yield 'emit '+str(s.emitted),replace(s,emitted=s.emitted+1,queue=s.queue+(s.emitted,))
            elif fault=='overwrite':
                yield 'overwrite full queue',replace(s,emitted=s.emitted+1,queue=s.queue[1:]+(s.emitted,))
        if s.queue:
            yield 'nextEvent',replace(s,borrowed=s.queue[0])
        if s.borrowed>=0:
            yield 'copy/derive '+str(s.borrowed),replace(s,copied=s.copied|{s.borrowed})
        # Cover all finite tokens, including not-yet-issued, wrong-owner and non-head.
        for issuer in (7,8):
            for token in range(4):
                allowed=(s.queue and issuer==7 and token==s.queue[0] and s.borrowed==token and token in s.copied)
                if fault=='stale-ack': allowed=(s.queue and s.borrowed>=0 and s.queue[0] in s.copied)
                if fault=='early-ack': allowed=(s.queue and issuer==7 and token==s.queue[0] and s.borrowed==token)
                if allowed:
                    nxt=replace(s,queue=s.queue[1:],borrowed=-1,retired=s.retired|{s.queue[0]})
                else: nxt=s
                yield f'ack issuer={issuer} sequence={token}',nxt
        yield 'cancel',replace(s,queue=(),borrowed=-1,canceled=True)
    else:
        yield 'cancel again',s
        yield 'attempt emit/ack after cancel',s


def invariant(s):
    """Conservation, unique retirement and capacity-independent terminal safety."""
    issued=set(range(s.emitted)); pending=set(s.queue)
    if len(pending)!=len(s.queue) or pending & s.retired: return 'duplicate custody'
    if not s.retired<=s.copied: return 'retired before independent copy/derivation'
    if not s.canceled and pending|s.retired!=issued: return 'lost emitted event'
    if s.borrowed>=0 and (not s.queue or s.borrowed!=s.queue[0]): return 'borrow invalidated by queue mutation'
    if s.canceled and (s.queue or s.borrowed!=-1): return 'terminal owner retains borrowed custody'
    return None


def transition_invariant(before,action,after):
    """Acknowledgement authentication is checked independently of transition logic."""
    if action.startswith('ack ') and before!=after:
        expected=f'ack issuer=7 sequence={before.borrowed}'
        if action!=expected: return 'stale/foreign acknowledgement mutated state'
    return None


def explore(capacity,fault=None):
    """BFS returns finite state/edge counts or a shortest failing trace."""
    initial=State(); todo=deque([initial]); paths={initial:[]}; edges=0
    while todo:
        current=todo.popleft()
        for action,nxt in successors(current,capacity,fault):
            edges+=1
            problem=invariant(nxt) or transition_invariant(current,action,nxt)
            if len(nxt.queue)>capacity: problem='capacity exceeded'
            trace=paths[current]+[action]
            if problem: return dict(passed=False,capacity=capacity,states=len(paths),edges=edges,violation=problem,trace=trace)
            if nxt not in paths: paths[nxt]=trace; todo.append(nxt)
    return dict(passed=True,capacity=capacity,states=len(paths),edges=edges)


def main():
    normal=[explore(c) for c in (1,2)]
    controls={name:explore(2,name) for name in ('overwrite','stale-ack','early-ack')}
    passed=all(r['passed'] for r in normal) and all(not r['passed'] for r in controls.values())
    print(json.dumps(dict(passed=passed,scope='finite proposed custody model; no implementation refinement or liveness proof',normal=normal,injected_faults=controls),indent=2))
    raise SystemExit(0 if passed else 1)


if __name__=='__main__': main()
