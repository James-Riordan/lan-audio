# LAN Audio documentation

**Want to hear your PC through your Mac? Start with [setup](first-run.md).**
Windows capture and authenticated streaming are implemented. The Intel Mac build
and two-computer listening test are still unverified; iPhone playback is not ready.

## Use the application

| Task | Guide |
| --- | --- |
| Set up the computers and start sound | [First-time setup](first-run.md) |
| Install repeatedly or use a setup JSON file | [Desktop setup](runtime/desktop-setup.md) |
| Fix no sound, connection errors or choppiness | [Troubleshooting](first-run.md#troubleshooting) |
| Change devices, addresses or buffering | [Configuration and profiles](runtime/configuration.md) |
| Understand retries and their limits | [Network recovery](runtime/network-recovery.md) |
| Review tested behavior and remaining limits | [Latest runtime results](../verification/playout-demand/RESULTS.md) |

## Work on the code

Start with the [implementation guide](implementation/START_HERE.md) and
[development workflow](development/workflow.md). Then choose the topic you need.

| Topic | Start here |
| --- | --- |
| Product goals and completion criteria | [Product requirements](PRODUCT.md), [acceptance matrix](verification/acceptance-matrix.md) |
| How audio moves through the program | [Engineering explanation](literate/README.md), [live workers](runtime/live-workers.md) |
| Folder and dependency ownership | [Module boundaries](architecture/modules.md), [source guide](../src/README.md), [dependencies](DEPENDENCIES.md) |
| Audio records and negotiation | [v2 protocol](protocol/v2.md), [negotiation](protocol/negotiation.md), [block assembly](media/assembly.md) |
| Queues, callbacks and safe shutdown | [Callback contracts](CALLBACKS.md), [receive/drain](design/receive-drain.md), [lifecycle](design/lifecycle-transactions.md) |
| Timing and mathematical reasoning | [Mathematics](MATHEMATICS.md), [proof ledger](literate/proof-ledger.md) |
| A particular file or API | [Per-file reference](reference/README.md), [API contracts](reference/api-contracts.md) |
| Remaining implementation work | [Completion sequence](implementation/completion-sequence.md), [roadmap](implementation/roadmap.md) |
| Broader ecosystem and configuration design | [Integration boundaries](architecture/ecosystem-integration.md), [configuration design](design/configuration-resolution.md) |
| Tests and documentation maintenance | [Verification rules](VERIFICATION.md), [documentation standard](development/documentation.md) |

Designs marked *proposed* or *planned* are not available features. Verification
reports describe the sources, tools and scenarios they name; older reports remain
historical evidence. A passing component test does not establish production readiness.
