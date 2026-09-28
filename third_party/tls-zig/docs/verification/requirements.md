# Component requirement and test traceability

Each stable ID names the complete existing component contract, with detailed invariants in its file card. A passing component suite is not a claim that all standard requirements have been enumerated or verified. Planned milestone acceptance remains in the roadmap.

| ID | Component contract | Tests | Status |
| --- | --- | --- | --- |
| T-ROOT | [src/root.zig](../reference/files/src/root.zig.md) | `tests/transport.zig` | Native suite passed; capability remains bounded. |
| T-DRIVER | [src/driver.zig](../reference/files/src/driver.zig.md) | `tests/driver.zig` | Native suite passed; capability remains bounded. |
| T-BACKEND | [src/backend.c](../reference/files/src/backend.c.md) | `tests/transport.zig`, `tests/driver.zig` | Native suite passed; capability remains bounded. |
| T-BACKEND | [src/backend.h](../reference/files/src/backend.h.md) | `tests/transport.zig` | Native suite passed; capability remains bounded. |
| T-BACKEND | [src/backend.zig](../reference/files/src/backend.zig.md) | `tests/transport.zig` | Native suite passed; capability remains bounded. |
