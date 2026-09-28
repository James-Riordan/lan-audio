# Project documentation

This project is a Windows-to-Mac LAN audio foundation under active development.
It does not yet provide a ready-to-use sender/receiver application. Pure v1 and v2
protocol code exists; production v2 TLS/device integration and native Mac execution
remain unfinished. See [product requirements](PRODUCT.md) for the actual user goal.

## Choose a reading path

| Need | Start here | Continue with |
| --- | --- | --- |
| Understand why the program works | [Engineering explanation](literate/README.md) | [Stream argument](literate/stream-argument.md), [proof ledger](literate/proof-ledger.md) |
| Understand directories and dependencies | [Module boundaries](architecture/modules.md) | [Populated/planned layout](implementation/layout.md), [source guide](../src/README.md), [dependencies](DEPENDENCIES.md) |
| Change sample transport | [Implemented v2 codec](protocol/v2.md) | [Negotiation](protocol/negotiation.md), [existing v1/TLS](TRANSPORT.md) |
| Assemble captured frames | [Block assembly](media/assembly.md) | [Independent v2 qualification](verification/v2-independent.md) |
| Compose the production runtime | [Completion sequence](implementation/completion-sequence.md) | [Runtime blueprint](implementation/runtime-blueprint.md), [receive/drain proof](design/receive-drain.md), [test obligations](verification/runtime-obligations.md) |
| Change native callbacks | [Callback contracts](CALLBACKS.md) | [Platform capabilities](architecture/platform-capabilities.md), [API reference](reference/api-contracts.md) |
| Review mathematical claims | [Kernel mathematics](MATHEMATICS.md) | [Runtime ownership](literate/runtime-argument.md), [quantitative design](literate/quantitative-design.md) |
| Find an individual file | [Per-file reference](reference/README.md) | The canonical source and its named tests |
| Implement the next part | [Implementation guide](implementation/START_HERE.md) | [Roadmap](implementation/roadmap.md), [decisions](implementation/decisions.md), selected work package |
| Maintain code and explanations | [Development workflow](development/workflow.md) | [Documentation standard](development/documentation.md) |
| Assess readiness | [Acceptance matrix](verification/acceptance-matrix.md) | [Scenarios](verification/scenarios.md), [verification rules](VERIFICATION.md), [current v2/assembly results](../verification/v2-independent/RESULTS.md) |

Descriptions marked proposed/planned are designs, not available commands/features.
Historical verification directories retain source-scoped results; use their recorded
hashes and limitations. Tables and file counts aid navigation, not correctness claims.
