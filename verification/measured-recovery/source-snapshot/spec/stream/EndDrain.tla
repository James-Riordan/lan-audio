---------------------------- MODULE EndDrain ----------------------------
EXTENDS Naturals, FiniteSets
CONSTANTS Capacity, MaxPosition, Fault
NoEnd == MaxPosition + 1
VARIABLES next, buffer, finish, done, postEndAdmission
vars == <<next, buffer, finish, done, postEndAdmission>>
Init == /\ next = 0 /\ buffer = {} /\ finish = NoEnd
        /\ done = FALSE /\ postEndAdmission = FALSE
Receive(q) == /\ ~done /\ (finish = NoEnd \/ Fault = "post_end")
              /\ q >= next /\ q < next + Capacity /\ q < MaxPosition
              /\ q \notin buffer
              /\ buffer' = buffer \cup {q}
              /\ postEndAdmission' = (postEndAdmission \/ finish # NoEnd)
              /\ UNCHANGED <<next, finish, done>>
End(n) == /\ finish = NoEnd /\ n >= next /\ n - next <= Capacity
          /\ (Fault = "end_before_buffer" \/ \A q \in buffer: q < n)
          /\ finish' = n
          /\ done' = (n = next \/ Fault = "early_done")
          /\ UNCHANGED <<next, buffer, postEndAdmission>>
Tick == /\ ~done /\ next < MaxPosition /\ (finish = NoEnd \/ next < finish)
        /\ buffer' = buffer \ {next} /\ next' = next + 1
        /\ done' = (finish # NoEnd /\ next + 1 = finish)
        /\ UNCHANGED <<finish, postEndAdmission>>
Next == (\E q \in 0..(MaxPosition-1): Receive(q))
        \/ (\E n \in 0..MaxPosition: End(n)) \/ Tick
Spec == Init /\ [][Next]_vars /\ WF_vars(Tick)
TypeOK == /\ next \in 0..MaxPosition /\ buffer \subseteq 0..(MaxPosition-1)
          /\ finish \in 0..NoEnd /\ done \in BOOLEAN /\ postEndAdmission \in BOOLEAN
Bounded == /\ Cardinality(buffer) <= Capacity
           /\ \A q \in buffer: /\ next <= q /\ q < next + Capacity
                                /\ (finish = NoEnd \/ q < finish)
Drained == done => (finish # NoEnd /\ next = finish /\ buffer = {})
NoPostEndAdmission == ~postEndAdmission
EndDrains == [](finish # NoEnd => <>done)
=============================================================================
