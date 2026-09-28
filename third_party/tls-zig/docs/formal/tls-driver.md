# TLS Driver transition model

This is a readable map of src/driver.zig. It is not a generated state machine or a proof of OpenSSL internals. All transitions occur on one serialized owner thread; only the cancellation flag is concurrent.

| Phase | One external action | State/result after action |
| --- | --- | --- |
| drive | One handshake/read/flush/shutdown TLS operation | Store desired progress or final result; move to drain. A fatal TLS error is retained while alerts are drained. |
| drain | Drain one BIO output prefix, unless output is already retained | Nonempty output goes to send. Empty output returns retained result/error, retries drive when needed, or moves to feed/receive. |
| send | One transport send of the retained suffix | Would-block returns wait_output; a valid positive prefix advances output_start; invalid counts terminate. |
| feed | Feed one retained ciphertext suffix | Advance input_start by accepted prefix, including zero on input_full, then drive TLS. |
| receive | One transport receive | Would-block returns wait_input; zero signals raw EOF; nonzero prefix becomes retained input then feed. |

Every step first checks the active operation, cancellation, clock and deadline. A callback may not block or reenter. Returning again is an invitation for immediate work subject to host fairness, not permission to monopolize a scheduler indefinitely. A fixed number of external calls per step does not bound the CPU of one provider call.

Let I=[input_start,input_end) and O=[output_start,output_end). Both remain within fixed array bounds. A transport send consumes a prefix of O only after positive success. BIO feed consumes only its reported prefix of I. Until each suffix is empty it cannot be overwritten. The host read destination remains exclusively borrowed until the operation returns complete/error; only complete(count) authorizes use of that prefix.

Probe state is separate: read -> optional drain -> receive/feed -> read. During an active write, probe returns write_pending until SSL_write has completed; ciphertext may still be blocked. It cannot send/discard that ciphertext, end the write or replace its deadline. Idle probe output requires beginFlush or a normal operation to send it in order. A fatal peer record prevents resuming upload.

Shutdown stores its first accepted deadline. When plaintext_available interrupts shutdown, a read uses min(old close deadline, requested read deadline), then shutdown resumes. An authenticated TLS prefix is not a complete HTTP response; the application owns framing and commit. Raw EOF is passed to the engine, and authenticated close is determined by TLS state, not TCP FIN.

## Next refinement work

Extend the executable model from closure only to the complete queue/phase tuple with bounded I/O prefixes, would-block, cancellation and fixed deadlines. For each model action, identify the precise source branch and add an implementation trace test. Check that invalid callback counts cannot expose uninitialized bytes and that all fatal-alert flushing remains bounded by the original operation deadline.
