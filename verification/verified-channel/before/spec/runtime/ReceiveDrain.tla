-------------------------- MODULE ReceiveDrain --------------------------
EXTENDS Naturals, Sequences
CONSTANTS Capacity, Prefill, MaxFrames, MaxBlock, Fault
ASSUME /\ Capacity > 0 /\ Prefill \in 1..Capacity
       /\ MaxFrames > 0 /\ MaxBlock \in 1..MaxFrames
       /\ Fault \in {"none", "overwrite_pending", "drop_suffix",
                     "early_ack", "short_stream_wait"}

\* A healthy, already authenticated v2 stream. Elements are source frame IDs,
\* not PCM values. Queues are copied custody; held models a callback that has
\* copied queue data but has not returned. Native joins remain host obligations.
VARIABLES received, pending, queued, held, consumed, ended, started,
          active, quiesced, acked
vars == <<received, pending, queued, held, consumed, ended, started,
          active, quiesced, acked>>
Prefix(s, n) == SubSeq(s, 1, n)
Suffix(s, n) == SubSeq(s, n + 1, Len(s))
Frames(n) == [i \in 1..n |-> i]

Init == /\ received = 0 /\ pending = <<>> /\ queued = <<>>
        /\ held = <<>> /\ consumed = <<>> /\ ended = FALSE
        /\ started = FALSE /\ active = FALSE /\ quiesced = FALSE /\ acked = FALSE

\* Decode/copy a whole record before parser storage is reused. There is exactly
\* one pending record. The gate frontier advances at this accepted-copy boundary.
Admit(n) == /\ ~ended /\ ~quiesced /\ ~acked
            /\ (pending = <<>> \/ Fault = "overwrite_pending")
            /\ n \in 1..MaxBlock /\ received + n <= MaxFrames
            /\ pending' = [i \in 1..n |-> received + i]
            /\ received' = received + n
            /\ UNCHANGED <<queued, held, consumed, ended, started, active, quiesced, acked>>

\* Partial queue writes transfer only their returned prefix. The remainder
\* prevents another Admit; zero progress is represented by stuttering.
Publish(n) == /\ ~quiesced /\ ~acked
              /\ n \in 1..Len(pending) /\ Len(queued) + n <= Capacity
              /\ queued' = queued \o Prefix(pending, n)
              /\ pending' = IF Fault = "drop_suffix" THEN <<>> ELSE Suffix(pending, n)
              /\ UNCHANGED <<received, held, consumed, ended, started, active, quiesced, acked>>

\* END may be known while decoded frames are pending. No later Admit is legal.
End == /\ ~ended /\ ~quiesced /\ ~acked /\ ended' = TRUE
       /\ UNCHANGED <<received, pending, queued, held, consumed, started, active, quiesced, acked>>

Prime == /\ ~started /\ ~quiesced /\ ~acked
         /\ (Len(queued) >= Prefill \/
             (Fault # "short_stream_wait" /\ ended /\ Len(queued) > 0))
         /\ started' = TRUE
         /\ UNCHANGED <<received, pending, queued, held, consumed, ended, active, quiesced, acked>>

Enter(n) == /\ started /\ ~active /\ ~quiesced /\ ~acked
            /\ n \in 1..Len(queued)
            /\ held' = Prefix(queued, n) /\ queued' = Suffix(queued, n)
            /\ active' = TRUE
            /\ UNCHANGED <<received, pending, consumed, ended, started, quiesced, acked>>
Return == /\ active /\ consumed' = consumed \o held
          /\ held' = <<>> /\ active' = FALSE
          /\ UNCHANGED <<received, pending, queued, ended, started, quiesced, acked>>

\* No real-time duration is asserted. This action requires a truthful host
\* fence closing future admission and joining callback and media worker owners.
Quiesce == /\ ended /\ pending = <<>> /\ queued = <<>> /\ ~active
           /\ ~quiesced /\ ~acked /\ quiesced' = TRUE
           /\ UNCHANGED <<received, pending, queued, held, consumed, ended, started, active, acked>>
Ack == /\ ended /\ pending = <<>> /\ queued = <<>> /\ ~acked
       /\ ((quiesced /\ ~active) \/ Fault = "early_ack")
       /\ acked' = TRUE
       /\ UNCHANGED <<received, pending, queued, held, consumed, ended, started, active, quiesced>>

PublishSome == \E n \in 1..MaxBlock: Publish(n)
EnterSome == \E n \in 1..Capacity: Enter(n)
Next == (\E n \in 1..MaxBlock: Admit(n)) \/ PublishSome \/ End \/ Prime
        \/ EnterSome \/ Return \/ Quiesce \/ Ack
Spec == Init /\ [][Next]_vars
        /\ WF_vars(PublishSome) /\ WF_vars(Prime) /\ WF_vars(EnterSome)
        /\ WF_vars(Return) /\ WF_vars(Quiesce) /\ WF_vars(Ack)

TypeOK == /\ received \in 0..MaxFrames
          /\ pending \in Seq(1..MaxFrames) /\ Len(pending) <= MaxBlock
          /\ queued \in Seq(1..MaxFrames) /\ Len(queued) <= Capacity
          /\ held \in Seq(1..MaxFrames) /\ Len(held) <= Capacity
          /\ consumed \in Seq(1..MaxFrames) /\ Len(consumed) <= MaxFrames
          /\ ended \in BOOLEAN /\ started \in BOOLEAN /\ active \in BOOLEAN
          /\ quiesced \in BOOLEAN /\ acked \in BOOLEAN
FrameOrder == consumed \o held \o queued \o pending = Frames(received)
CallbackCustody == active = (Len(held) > 0)
AckFence == acked => (ended /\ quiesced /\ ~active /\ pending = <<>>
                     /\ queued = <<>> /\ consumed = Frames(received))
Quiescent == quiesced => (~active /\ pending = <<>> /\ queued = <<>>)
EndProgress == ended ~> acked
=============================================================================
