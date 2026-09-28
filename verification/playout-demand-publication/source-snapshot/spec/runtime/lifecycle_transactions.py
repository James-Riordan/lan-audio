"""Finite specification of partial acquisition, cancellation and reclamation.

Not the production lifecycle implementation. Host completion and native joining
are abstract events. Ledger/actual and pending/outstanding pairs separate manager
knowledge from an independently retained environment obligation. No devices/I/O.
See docs/design/lifecycle-transactions.md for refinement obligations and limits.
"""
from collections import deque
from dataclasses import dataclass, replace

STORAGE, DEVICE, WORKER = 1, 2, 4
RESOURCES = (STORAGE, DEVICE, WORKER)


@dataclass(frozen=True)
class State:
    """Manager state plus ghost environment facts; all fields are immutable.

    Native closed/joined start true vacuously while no device exists. Issuing a
    device success makes both false; only host events can establish them again.
    """
    phase: str = 'idle'
    generation: int = 0
    serial: int = 0
    pending: tuple | None = None  # Manager token (generation, serial, resource).
    outstanding: tuple | None = None  # Environment's still-owed acquisition result.
    held: int = 0  # Manager's acquired/not-released resource bit set.
    actual: int = 0  # Ghost native ownership, independent of manager forgetting.
    worker_alive: bool = False
    callback: bool = False
    fence_requested: bool = False
    native_closed: bool = True
    joined: bool = True


def actions(s, max_generations, fault='none'):
    """Yield event, successor, and whether this was a rejected token event."""
    if s.phase in ('idle', 'released') and s.generation < max_generations:
        yield 'begin', State(phase='starting', generation=s.generation+1), False
    if s.phase == 'starting' and s.pending is None:
        resource = next((r for r in RESOURCES if not s.held & r), None)
        if resource is None:
            yield 'ready', replace(s, phase='running'), False
        else:
            token = (s.generation, s.serial+1, resource)
            yield f'issue acquire {resource}', replace(s, serial=s.serial+1,
                  pending=token, outstanding=token), False
    if s.phase in ('starting', 'running', 'stopping'):
        new = replace(s, phase='stopping')
        if fault == 'forget_pending':
            new = replace(new, pending=None)
        yield 'cancel', new, False
    if s.outstanding:
        token = s.outstanding
        resource = token[2]
        yield f'complete failure {token}', replace(s, pending=None, outstanding=None,
              phase='stopping'), False
        held = s.held | resource
        if fault == 'lose_late_success' and s.phase == 'stopping':
            held = s.held
        new = replace(s, pending=None, outstanding=None, held=held,
                      actual=s.actual | resource,
                      worker_alive=s.worker_alive or resource == WORKER)
        if resource == DEVICE:
            new = replace(new, joined=False, native_closed=False)
        yield f'complete success {token}', new, False
    # Old-generation, wrong-serial and wrong-resource completions are separate
    # from real outstanding completions. Their only correct transition is stutter.
    if s.generation:
        for label in ('old generation', 'wrong serial', 'wrong resource'):
            new = s
            if fault == 'stale_completion' and s.pending:
                new = replace(s, pending=None)
            yield 'reject '+label, new, True
    # A native callback can enter even during cancellation/fence request until
    # the native environment seals admission. Application stop is not that seal.
    if s.actual & DEVICE and not s.native_closed and not s.callback:
        yield 'callback enter', replace(s, callback=True), False
    if s.callback:
        yield 'callback return', replace(s, callback=False), False
    if s.phase == 'stopping':
        if s.actual & DEVICE and not s.fence_requested:
            yield 'request native fence', replace(s, fence_requested=True), False
        if s.fence_requested and not s.native_closed:
            yield 'native seals admission', replace(s, native_closed=True), False
        if s.fence_requested and s.native_closed and not s.callback and not s.joined:
            yield 'native fence returns', replace(s, joined=True), False
        if s.worker_alive:
            yield 'worker exits', replace(s, worker_alive=False), False
        if s.held & WORKER and (not s.worker_alive or fault == 'free_live_worker'):
            yield 'release worker', replace(s, held=s.held & ~WORKER,
                  actual=s.actual & ~WORKER), False
        if s.held & DEVICE and not s.held & WORKER and not s.worker_alive and (s.pending is None or fault == 'free_acquisition_parent'):
            if s.joined or fault == 'free_unjoined_device':
                yield 'release device', replace(s, held=s.held & ~DEVICE,
                      actual=s.actual & ~DEVICE), False
        if s.held == STORAGE and s.pending is None:
            yield 'release storage', replace(s, held=0, actual=s.actual & ~STORAGE), False
        if not s.held and s.pending is None:
            yield 'finish', replace(s, phase='released'), False


def violation(before, event, after, rejected):
    """Independent safety predicates; do not reuse successor guard conditions."""
    if rejected and before != after:
        return 'TokenIsolation'
    if after.pending != after.outstanding:
        return 'OutstandingTracked'
    if after.held != after.actual:
        return 'SuccessfulAcquisitionTracked'
    if after.outstanding:
        required={STORAGE:0, DEVICE:STORAGE, WORKER:STORAGE | DEVICE}[after.outstanding[2]]
        if after.actual & required != required:
            return 'AcquisitionBorrow'
    if after.worker_alive and after.actual & (STORAGE | DEVICE | WORKER) != 7:
        return 'WorkerLifetime'
    if after.callback and not after.actual & DEVICE:
        return 'CallbackLifetime'
    if before.actual & DEVICE and not after.actual & DEVICE and not before.joined:
        return 'NativeJoinBeforeRelease'
    if after.actual & (DEVICE | WORKER) and not after.actual & STORAGE:
        return 'StorageDependency'
    if after.phase in ('idle', 'released') and (after.actual or after.outstanding or after.callback or after.worker_alive):
        return 'TerminalHasDebt'
    if before.phase == 'stopping' and event.startswith('issue acquire'):
        return 'NoAcquisitionAfterCancel'
    return None


def trace_to(parents, state):
    trace=[]
    while parents[state] is not None:
        state, event = parents[state]
        trace.append(event)
    return list(reversed(trace))


def explore(max_generations=2, fault='none', max_states=100000):
    """BFS safety plus existential cleanup reachability, not temporal liveness.

    Reverse edges are restricted to a generation: reaching a later restart cannot
    masquerade as cleanup. A stalled-native schedule can stutter forever; a path
    to cleanup only establishes that the abstract protocol has an escape path.
    """
    if type(max_generations) is not int or max_generations < 1 or type(max_states) is not int or max_states < 1:
        raise ValueError('positive integer generation/state bounds required')
    if fault not in {'none','forget_pending','lose_late_success','stale_completion',
                     'free_live_worker','free_acquisition_parent','free_unjoined_device'}:
        raise ValueError('unknown injected defect; no qualification')
    first=State();todo=deque([first]);parents={first:None};reverse={};edges=0
    while todo:
        current=todo.popleft()
        for event, nxt, rejected in actions(current,max_generations,fault):
            edges+=1
            problem=violation(current,event,nxt,rejected)
            if problem:
                return {'passed':False,'fault':fault,'max_generations':max_generations,
                        'states':len(parents),'edges':edges,'violation':problem,
                        'trace':trace_to(parents,current)+[event]}
            if current.generation == nxt.generation:
                reverse.setdefault(nxt,set()).add(current)
            if nxt not in parents:
                if len(parents)>=max_states:
                    raise RuntimeError('state budget exhausted; no qualification')
                parents[nxt]=(current,event);todo.append(nxt)
    terminals={s for s in parents if s.phase=='released'}
    reachable=set(terminals);todo=deque(terminals)
    while todo:
        for previous in reverse.get(todo.popleft(),()):
            if previous not in reachable:
                reachable.add(previous);todo.append(previous)
    blocked=[s for s in parents if s.phase=='stopping' and s not in reachable]
    return {'passed':not blocked,'fault':fault,'max_generations':max_generations,
            'states':len(parents),'edges':edges,'terminal_states':len(terminals),
            'stopping_states':sum(s.phase=='stopping' for s in parents),
            'stopping_states_without_cleanup_path':len(blocked),
            'scope':'finite safety and existential same-generation cleanup; no fairness, native execution or implementation refinement proof'}
