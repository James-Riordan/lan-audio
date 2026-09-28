------------------------- MODULE SessionWindow -------------------------
EXTENDS Naturals, Sequences, FiniteSets
CONSTANTS Capacity, MaxSequence, MaxEpoch, Fault
ASSUME /\ Capacity > 0 /\ MaxSequence > 0 /\ MaxEpoch > 0
       /\ Fault \in {"none", "skip_auth", "stale_epoch", "early_free", "replay_tick"}
VARIABLES phase, epoch, authenticated, active, next, buffer, history
vars == <<phase, epoch, authenticated, active, next, buffer, history>>
Packet(e, n) == [generation |-> e, position |-> n]
Packets == [generation : 0..MaxEpoch, position : 0..(MaxSequence-1)]

Init == /\ phase = "idle" /\ epoch = 0 /\ authenticated = FALSE
        /\ active = FALSE /\ next = 0 /\ buffer = {} /\ history = <<>>

Begin == /\ phase = "idle" /\ epoch < MaxEpoch
         /\ phase' = "negotiating" /\ epoch' = epoch + 1
         /\ next' = 0 /\ buffer' = {}
         /\ UNCHANGED <<authenticated, active, history>>
Authenticate == /\ phase = "negotiating" /\ ~authenticated
                /\ authenticated' = TRUE
                /\ UNCHANGED <<phase, epoch, active, next, buffer, history>>
Start == /\ phase = "negotiating"
         /\ (authenticated \/ Fault = "skip_auth")
         /\ phase' = "streaming"
         /\ UNCHANGED <<epoch, authenticated, active, next, buffer, history>>
Receive(e, n) ==
    /\ phase = "streaming" /\ authenticated
    /\ (e = epoch \/ Fault = "stale_epoch")
    /\ next <= n /\ n < next + Capacity /\ n < MaxSequence
    /\ Packet(e, n) \notin buffer
    /\ buffer' = buffer \cup {Packet(e, n)}
    /\ UNCHANGED <<phase, epoch, authenticated, active, next, history>>
EnterCallback == /\ phase = "streaming" /\ authenticated /\ ~active
                 /\ active' = TRUE
                 /\ UNCHANGED <<phase, epoch, authenticated, next, buffer, history>>
Tick == /\ active /\ next < MaxSequence
        /\ LET current == Packet(epoch, next)
               hasMedia == current \in buffer
               replay == Fault = "replay_tick" /\ hasMedia
           IN /\ history' = IF hasMedia THEN Append(history, current) ELSE history
              /\ next' = IF replay THEN next ELSE next + 1
              /\ buffer' = IF replay THEN buffer ELSE buffer \ {current}
        /\ UNCHANGED <<phase, epoch, authenticated, active>>
LeaveCallback == /\ active /\ active' = FALSE
                 /\ UNCHANGED <<phase, epoch, authenticated, next, buffer, history>>
RequestStop == /\ phase \in {"negotiating", "streaming"}
               /\ phase' = "stopping"
               /\ UNCHANGED <<epoch, authenticated, active, next, buffer, history>>
FinishStop == /\ phase = "stopping" /\ (~active \/ Fault = "early_free")
              /\ phase' = "idle" /\ authenticated' = FALSE /\ buffer' = {}
              /\ UNCHANGED <<epoch, active, next, history>>
Next == Begin \/ Authenticate \/ Start
        \/ (\E e \in 0..MaxEpoch, n \in 0..(MaxSequence-1): Receive(e,n))
        \/ EnterCallback \/ Tick \/ LeaveCallback \/ RequestStop \/ FinishStop

\* Fair callback return and fair stop completion are environment assumptions.
Spec == Init /\ [][Next]_vars /\ WF_vars(LeaveCallback) /\ WF_vars(FinishStop)
TypeOK == /\ phase \in {"idle", "negotiating", "streaming", "stopping"}
          /\ epoch \in 0..MaxEpoch /\ authenticated \in BOOLEAN /\ active \in BOOLEAN
          /\ next \in 0..MaxSequence /\ buffer \subseteq Packets /\ history \in Seq(Packets)
AuthenticatedStreaming == phase = "streaming" => authenticated
QuiescentIdle == phase = "idle" => (~active /\ ~authenticated)
WindowBounds == /\ Cardinality(buffer) <= Capacity
                /\ \A p \in buffer: /\ p.generation = epoch
                                     /\ next <= p.position /\ p.position < next + Capacity
UniquePlayout == Len(history) = Cardinality({history[i] : i \in DOMAIN history})
StopCompletes == [](phase = "stopping" => <>(phase = "idle"))
=============================================================================
