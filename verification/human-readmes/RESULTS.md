# Human-first README revision

The LAN Audio README now leads with the Windows-to-Mac task, actual availability,
one setup guide and the two daily JSON-profile commands. The setup guide names
prerequisites, shells, directories, placeholders, file placement, expected results,
stop/restart behavior and common failures. It explicitly distinguishes JSON profiles
from generated direct-argument launchers. The docs index now reflects implemented
streaming. The documentation standard makes these human-facing requirements durable.
The miniaudio README now supplies an integration sequence and complete-consumer link.

Application documentation/contract gates pass for 164 files. All 188 TLS custody
entries and staged DLLs pass. The miniaudio documentation and vendor gates pass.
Edited-guide local file links and explicit anchors were checked separately. CLI and
helper help were inspected without opening audio devices or creating identities.

Full three-project documentation and contract gates still fail because the TLS
project contains additional files absent from the application's adopted index.
Their complete outputs are retained. They were not bypassed, and no dependency
pins or TLS README were changed. The initial miniaudio cross-package link failure
was repaired by using plain project navigation, preserving its self-contained gate.

Before/after text, hashes, exact commands and outcomes are recorded here. Comparison
with the previous runtime publication confirms only the named application docs and
reference contract data changed; native inputs and installed binaries are unchanged.
No runtime, Mac or physical-device test is claimed by this documentation revision.
Existing runtime evidence and distributed ZIPs remain historical and unchanged.
