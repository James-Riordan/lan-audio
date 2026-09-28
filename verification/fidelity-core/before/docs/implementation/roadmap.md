# Ordered implementation roadmap

Every row is planned product work unless marked otherwise. The documentation and
directory migration are complete only when the handoff checks pass; that status
does not complete any product gate below. Keep implementation receipts separate.

| Package | Depends on | Deliverable / exit milestone |
| --- | --- | --- |
| [WP01 Target builds](work-packages/01-target-builds.md) | current custody | Native Windows and Intel Mac library/host builds with private TLS runtimes |
| [WP02 Fidelity protocol](work-packages/02-fidelity-protocol.md) | current core | Versioned f32 transport, strict bounded negotiation and independent bit-exact tests |
| [WP03 Identity and endpoints](work-packages/03-identity-endpoints.md) | WP01 | Real peer authorization, explicit endpoints and no fixture shortcuts |
| [WP04 First sound](work-packages/04-first-sound.md) | WP01–03 | Continuous Windows capture → real LAN → Mac output with start/stop and bounded failure |
| [WP05 Timing and clocks](work-packages/05-timing-clocks.md) | WP02, WP04 | Priming, pacing, qualified drift correction and measured timing |
| [WP06 Network resilience](work-packages/06-network-resilience.md) | WP04–05, WP07 baseline metrics | Measured fault envelope and justified recovery/transport policy |
| [WP07 Observability](work-packages/07-observability.md) | starts with WP04; extended by WP05–06 | Bounded diagnostics and reproducible impairment/clock traces |
| [WP08 User experience](work-packages/08-user-experience.md) | WP03–05 | Usable connect/start/stop/recover flow over the same runtime |
| [WP09 Packaging](work-packages/09-packaging.md) | WP01, WP08 | Clean-machine Windows/Mac distribution with private runtime custody |
| [WP10 Qualification](work-packages/10-qualification.md) | WP01–09 | A1–A10 evidence and stated support envelope |

WP07 supplies initial metrics during WP04, so WP06 does not wait on a finished
observability product. WP02 and simulation can proceed while Mac access is pending.
Implement one working vertical slice; do not complete ten disconnected skeletons.

## Milestones a user can understand

**M0 Foundation:** existing kernels and local probes. **M1 First sound:** Windows
and Mac executables transmit actual captured audio with a documented setup.
**M2 Personal alpha:** sustained operation, drift correction, useful status and
recovery on the user's actual devices. **M3 Supported release:** clean installation,
secure pairing, documented fault envelope and all release obligations resolved.
Only recorded execution can advance these states. There is no percentage mapping.

## Validation rules

Each package includes exact existing/planned files, interface contract, positive
path, negative path, independent checks and rollback/cleanup. Before marking it
complete, record which acceptance IDs it satisfies, which it merely contributes
to, exact source and tool identity, and unresolved hardware limitations. If a new
file is added, add its contract/index entry and run both documentation gates.

No source-code work is considered done by adding TODOs, returning placeholder
success or removing a failing assertion. When assumptions change, rewrite the
affected contract and work package, not the historical evidence. Missing user facts
only block dependent work; continue independently useful implementation.
