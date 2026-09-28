"""Explore small independent safety models; does not execute Zig/C or prove refinement."""
from collections import deque
import json


def explore(initial, successors, invariant):
    queue = deque([(initial, [])])
    seen = {initial}
    edges = 0
    while queue:
        state, trace = queue.popleft()
        if not invariant(state):
            return {'states': len(seen), 'edges': edges, 'counterexample': trace}
        for label, nxt in successors(state):
            edges += 1
            if nxt not in seen:
                seen.add(nxt)
                queue.append((nxt, trace + [label]))
    return {'states': len(seen), 'edges': edges, 'counterexample': None}


def ack_model(broken=False):
    # generated, committed, prepared ticket, greatest actually covered generation
    def transitions(s):
        g, committed, ticket, covered = s
        if g < 3:
            yield 'admit ack-eliciting packet', (g+1, committed, ticket, covered)
        if g > committed and ticket == 0:
            yield f'prepare ticket {g}', (g, committed, g, covered)
        if committed < ticket <= g:
            yield f'send ticket {ticket}', (g, g if broken else ticket, 0, max(covered, ticket))
        if ticket:
            yield 'blocked send leaves ticket pending', s
    return explore((0, 0, 0, 0), transitions,
                   lambda s: 0 <= s[1] <= s[0] and s[1] == s[3])


def custody_model(broken=False):
    # packet states: 0 unsent, 1 in flight, 2 lost, 3 acknowledged.
    # Two bytes carried by original packet and one retransmission.
    def transitions(s):
        p0, p1, pending, acked = s
        if p0 == 0:
            yield 'send original span {0,1}', (1, p1, 0, acked)
        if p0 != 0 and p1 == 0 and pending:
            yield 'send retransmission span {0,1}', (p0, 1, 0, acked)
        for i, p in enumerate((p0, p1)):
            if p in (1, 2):
                ps = [p0, p1]
                ps[i] = 3
                yield f'ACK packet {i}', (*ps, 0, 3)
            if p == 1:
                ps = [p0, p1]
                ps[i] = 2
                requeued = 3 if broken else (3 & ~acked)
                yield f'lose packet {i}', (*ps, pending | requeued, acked)
    return explore((0, 0, 3, 0), transitions, lambda s: s[2] & s[3] == 0)


def shutdown_model(broken=False):
    # remaining authenticated application bytes, notify, eof, closed, failed.
    def transitions(s):
        remaining, notify, eof, closed, failed = s
        if closed or failed:
            return
        if remaining:
            yield 'consume one final plaintext byte', (remaining-1, notify, eof, False, False)
        if not notify and not eof:
            yield 'receive authenticated close_notify', (remaining, True, eof, False, False)
        if not eof:
            yield 'receive raw transport EOF', (remaining, notify, True, False, False)
        if remaining == 0 and (notify or eof):
            clean = notify or (broken and eof)
            yield 'finish shutdown', (remaining, notify, eof, clean, not clean)
    return explore((2, False, False, False, False), transitions,
                   lambda s: not s[3] or (s[0] == 0 and s[1]))


def main():
    report = {'scope': 'finite abstract safety models; no Zig/C refinement or liveness proof', 'models': {}}
    for name, run in [('ack_ticket', ack_model), ('late_ack_custody', custody_model), ('authenticated_shutdown', shutdown_model)]:
        good, bad = run(), run(True)
        if good['counterexample'] is not None:
            raise RuntimeError(f'{name}: valid model violated its invariant: {good}')
        if bad['counterexample'] is None:
            raise RuntimeError(f'{name}: injected defect was not detected')
        report['models'][name] = {'correct_model': good, 'injected_fault': bad}
    print(json.dumps(report, indent=2))


if __name__ == '__main__':
    main()
