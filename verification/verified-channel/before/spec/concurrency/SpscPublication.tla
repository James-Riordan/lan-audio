-------------------------- MODULE SpscPublication --------------------------
EXTENDS Naturals, Integers
CONSTANTS Capacity, Count, Fault
VARIABLES w, r, pp, cp, memory, reserved, bad
vars == <<w, r, pp, cp, memory, reserved, bad>>
Init == /\ w = 0 /\ r = 0 /\ pp = "copy" /\ cp = "copy"
        /\ memory = [i \in 0..(Capacity-1) |-> -1]
        /\ reserved = 0 /\ bad = FALSE
CopyIn == /\ pp = "copy" /\ w < Count /\ w-r < Capacity
          /\ IF Fault = "early_publish"
                THEN /\ w' = w+1 /\ pp' = "latecopy" /\ UNCHANGED memory
                ELSE /\ memory' = [memory EXCEPT ![w % Capacity] = w]
                     /\ pp' = "publish" /\ UNCHANGED w
          /\ UNCHANGED <<r, cp, reserved, bad>>
Publish == /\ pp = "publish" /\ w' = w+1 /\ pp' = "copy"
           /\ UNCHANGED <<r, cp, memory, reserved, bad>>
LateCopyIn == /\ pp = "latecopy"
              /\ memory' = [memory EXCEPT ![(w-1) % Capacity] = w-1]
              /\ pp' = "copy" /\ UNCHANGED <<w, r, cp, reserved, bad>>
CopyOut == /\ cp = "copy" /\ r < w
           /\ IF Fault = "early_release"
                 THEN /\ r' = r+1 /\ reserved' = r /\ cp' = "latecopy" /\ UNCHANGED bad
                 ELSE /\ bad' = (bad \/ memory[r % Capacity] # r)
                      /\ cp' = "release" /\ UNCHANGED <<r, reserved>>
           /\ UNCHANGED <<w, pp, memory>>
Release == /\ cp = "release" /\ r' = r+1 /\ cp' = "copy"
           /\ UNCHANGED <<w, pp, memory, reserved, bad>>
LateCopyOut == /\ cp = "latecopy"
               /\ bad' = (bad \/ memory[reserved % Capacity] # reserved)
               /\ cp' = "copy" /\ UNCHANGED <<w, r, pp, memory, reserved>>
Produce == CopyIn \/ Publish \/ LateCopyIn
Consume == CopyOut \/ Release \/ LateCopyOut
Next == Produce \/ Consume
Spec == Init /\ [][Next]_vars /\ WF_vars(Produce) /\ WF_vars(Consume)
TypeOK == /\ w \in 0..Count /\ r \in 0..Count /\ r <= w /\ w-r <= Capacity
          /\ pp \in {"copy", "publish", "latecopy"}
          /\ cp \in {"copy", "release", "latecopy"}
          /\ memory \in [0..(Capacity-1) -> (-1)..(Count-1)]
          /\ reserved \in 0..Count /\ bad \in BOOLEAN
NoCorruption == ~bad
Completes == <>(w = Count /\ r = Count /\ pp = "copy" /\ cp = "copy")
=============================================================================
