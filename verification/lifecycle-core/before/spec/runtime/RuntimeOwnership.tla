------------------------ MODULE RuntimeOwnership ------------------------
EXTENDS Naturals, FiniteSets
CONSTANTS Capacity, Prefill, MaxFrames, MaxEpoch, DrainTicks, Fault
ASSUME /\ Capacity > 0 /\ Prefill \in 1..Capacity
       /\ MaxFrames > 0 /\ MaxEpoch > 0 /\ DrainTicks > 0
       /\ Fault \in {"none", "early_free", "stop_wait"}
Roles == {"capture", "network"}
Phases == {"idle", "connect", "prime", "run", "drain", "stop"}
AsNat(b) == IF b THEN 1 ELSE 0

\* Scalar counts abstract whole frames; payload identity/FIFO belongs to lower
\* models. capture ownership includes its native callback and assembly worker.
VARIABLES phase, epoch, authenticated, allocated, owners, device, active,
          captured, capq, flight, playq, held, rendered, discarded, remaining
vars == <<phase, epoch, authenticated, allocated, owners, device, active,
          captured, capq, flight, playq, held, rendered, discarded, remaining>>

Init == /\ phase = "idle" /\ epoch = 0 /\ authenticated = FALSE /\ allocated = FALSE
        /\ owners = {} /\ device = FALSE /\ active = FALSE /\ captured = 0
        /\ capq = 0 /\ flight = FALSE /\ playq = 0 /\ held = FALSE
        /\ rendered = 0 /\ discarded = 0 /\ remaining = 0

Begin == /\ phase = "idle" /\ epoch < MaxEpoch
         /\ phase' = "connect" /\ epoch' = epoch + 1 /\ allocated' = TRUE
         /\ captured' = 0 /\ rendered' = 0 /\ discarded' = 0 /\ remaining' = 0
         /\ UNCHANGED <<authenticated, owners, device, active, capq, flight, playq, held>>

Authorize == /\ phase = "connect" /\ phase' = "prime"
             /\ authenticated' = TRUE /\ owners' = Roles
             /\ UNCHANGED <<epoch, allocated, device, active, captured, capq,
                            flight, playq, held, rendered, discarded, remaining>>

Capture == /\ phase \in {"prime", "run"} /\ "capture" \in owners
           /\ captured < MaxFrames /\ capq < Capacity
           /\ capq' = capq + 1 /\ captured' = captured + 1
           /\ UNCHANGED <<phase, epoch, authenticated, allocated, owners,
                          device, active, flight, playq, held, rendered, discarded, remaining>>

Send == /\ phase \in {"prime", "run", "drain"} /\ "network" \in owners
        /\ capq > 0 /\ ~flight /\ capq' = capq - 1 /\ flight' = TRUE
        /\ UNCHANGED <<phase, epoch, authenticated, allocated, owners, device,
                       active, captured, playq, held, rendered, discarded, remaining>>

Deliver == /\ phase \in {"prime", "run", "drain"} /\ "network" \in owners
           /\ flight /\ playq < Capacity /\ flight' = FALSE /\ playq' = playq + 1
           /\ UNCHANGED <<phase, epoch, authenticated, allocated, owners, device,
                          active, captured, capq, held, rendered, discarded, remaining>>

Prime == /\ phase = "prime" /\ playq >= Prefill
         /\ phase' = "run" /\ device' = TRUE
         /\ UNCHANGED <<epoch, authenticated, allocated, owners, active, captured,
                        capq, flight, playq, held, rendered, discarded, remaining>>

\* A short stream may drain without ever reaching the normal prefill threshold.
Graceful == /\ phase \in {"prime", "run"}
            /\ phase' = "drain" /\ remaining' = DrainTicks /\ device' = TRUE
            /\ UNCHANGED <<epoch, authenticated, allocated, owners, active, captured,
                           capq, flight, playq, held, rendered, discarded>>

Enter == /\ phase \in {"run", "drain"} /\ device /\ ~active
         /\ active' = TRUE /\ held' = (playq > 0)
         /\ playq' = IF playq > 0 THEN playq - 1 ELSE playq
         /\ UNCHANGED <<phase, epoch, authenticated, allocated, owners, device,
                        captured, capq, flight, rendered, discarded, remaining>>

\* Already admitted callbacks can return after stop was requested.
Return == /\ active /\ active' = FALSE
          /\ rendered' = rendered + AsNat(held) /\ held' = FALSE
          /\ UNCHANGED <<phase, epoch, authenticated, allocated, owners, device,
                         captured, capq, flight, playq, discarded, remaining>>

Empty == capq = 0 /\ ~flight /\ playq = 0 /\ ~held
DrainComplete == /\ phase = "drain" /\ Empty /\ ~active
                 /\ phase' = "stop"
                 /\ UNCHANGED <<epoch, authenticated, allocated, owners, device, active,
                                captured, capq, flight, playq, held, rendered, discarded, remaining>>
Clock == /\ phase = "drain" /\ remaining > 0 /\ remaining' = remaining - 1
         /\ UNCHANGED <<phase, epoch, authenticated, allocated, owners, device, active,
                        captured, capq, flight, playq, held, rendered, discarded>>
Deadline == /\ phase = "drain" /\ remaining = 0 /\ phase' = "stop"
            /\ UNCHANGED <<epoch, authenticated, allocated, owners, device, active,
                           captured, capq, flight, playq, held, rendered, discarded, remaining>>
Abort == /\ phase \in {"connect", "prime", "run", "drain"} /\ phase' = "stop"
         /\ UNCHANGED <<epoch, authenticated, allocated, owners, device, active,
                        captured, capq, flight, playq, held, rendered, discarded, remaining>>
StopDevice == /\ phase = "stop" /\ device /\ device' = FALSE
              /\ UNCHANGED <<phase, epoch, authenticated, allocated, owners, active,
                             captured, capq, flight, playq, held, rendered, discarded, remaining>>

\* Cancellation must release ownership even if queued media cannot drain.
OwnerExit(role) == /\ phase = "stop" /\ role \in owners
                   /\ (Fault # "stop_wait" \/ Empty)
                   /\ owners' = owners \ {role}
                   /\ UNCHANGED <<phase, epoch, authenticated, allocated, device, active,
                                  captured, capq, flight, playq, held, rendered, discarded, remaining>>

Free == /\ phase = "stop"
        /\ ((~device /\ ~active /\ owners = {}) \/ Fault = "early_free")
        /\ phase' = "idle" /\ allocated' = FALSE /\ authenticated' = FALSE
        /\ discarded' = discarded + capq + AsNat(flight) + playq + AsNat(held)
        /\ capq' = 0 /\ flight' = FALSE /\ playq' = 0 /\ held' = FALSE
        /\ UNCHANGED <<epoch, owners, device, active, captured, rendered, remaining>>

Next == Begin \/ Authorize \/ Capture \/ Send \/ Deliver \/ Prime \/ Graceful
        \/ Enter \/ Return \/ DrainComplete \/ Clock \/ Deadline \/ Abort
        \/ StopDevice \/ (\E role \in Roles: OwnerExit(role)) \/ Free
Spec == Init /\ [][Next]_vars
        /\ WF_vars(Return) /\ WF_vars(StopDevice) /\ WF_vars(Free)
        /\ (\A role \in Roles: WF_vars(OwnerExit(role)))
        /\ WF_vars(Clock) /\ WF_vars(Deadline) /\ WF_vars(DrainComplete)

TypeOK == /\ phase \in Phases /\ epoch \in 0..MaxEpoch
          /\ authenticated \in BOOLEAN /\ allocated \in BOOLEAN
          /\ owners \subseteq Roles /\ device \in BOOLEAN /\ active \in BOOLEAN
          /\ captured \in 0..MaxFrames /\ capq \in 0..Capacity
          /\ flight \in BOOLEAN /\ playq \in 0..Capacity /\ held \in BOOLEAN
          /\ rendered \in 0..MaxFrames /\ discarded \in 0..MaxFrames
          /\ remaining \in 0..DrainTicks
Custody == captured = capq + AsNat(flight) + playq + AsNat(held) + rendered + discarded
IdleEmpty == phase = "idle" => Empty
HeldByCallback == held => active
LiveStorage == /\ (~allocated => (~device /\ ~active /\ owners = {}))
               /\ (phase = "idle" => ~allocated)
AuthorizedUse == phase \in {"prime", "run", "drain"} => (authenticated /\ allocated)
Progress == /\ [](phase = "stop" => <>(phase = "idle"))
            /\ [](phase = "drain" => <>(phase = "idle"))
=============================================================================
