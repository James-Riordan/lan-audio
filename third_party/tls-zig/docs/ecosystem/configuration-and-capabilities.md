# Configuration and adaptive host capabilities

Status: proposed QUIC/TLS host integration using inspected ZSON contracts. Neither library currently imports ZSON for this integration. Keep direct typed configuration and the lean build working. An optional host/build adapter must be adopted and qualified explicitly.

## The actual ZSON execution boundary

The inspected ZSON build consumer evaluates configuration when the host build program runs and then emits target constants through build options. It is not a general comptime parser. Target compile-time branches can exclude modules based on those emitted constants. Optional dependency configuration must itself be conditional/lazy; a runtime boolean cannot remove an unconditional dependency or import.

ZSON separates explicit-layer environment resolution from schema-authoritative validated planning. For a new transport adapter, select one default authority. Prefer a validated normalized plan when hashes and native options must describe the same effective configuration; do not add unseen native defaults after hashing the plan. Explicit false, zero, null or an empty collection is not an instruction to fall back to a default.

Use documented environment precedence and whole-top-level-value replacement. Do not invent deep merge or an alternate scope/override policy. Runtime overrides are caller-authorized; the configuration document does not grant itself permission to change security policy. Typed decoding and schema validation occur before dependency selection, provider allocation or network work.

## Proposed field responsibility matrix

Names below are semantic fields to specify in the adapter schema, not accepted keys in a shipped quic-zig/tls-zig .zson file.

| Setting | Scope | Effect of change | Owner / guard |
| --- | --- | --- | --- |
| compiled transport/backend/suites | build | rebuild and requalify consumer | host build adapter; required feature absent fails before connection |
| target ABI / compiler / backend identity | build provenance | rebuild, native ABI/runtime checks | package/build tooling; no automatic SDK repin |
| selected environment/resource | plan identity | resolve, normalize and review effective differences | host; explicit selection from allowed catalog |
| expected peer identity / trust profile | runtime owner construction | new validated owner or reviewed credential rotation | application/TLS policy; no live mutation by ambient terminal context |
| required ALPN | runtime construction | new connection negotiation | application/TLS; exact opaque bytes and mismatch rejection |
| connection / stream / event capacities | mixed, classified per implementation | compile-time size change rebuilds; admitted runtime change may require restart | owning schema and budget contract; runtime is not automatically hot reload |
| idle / handshake deadlines | runtime construction | explicit policy update with checked units | connection/host; cannot extend an in-flight operation accidentally |
| diagnostic level / sink budget | runtime | bounded explicit reconfiguration if implemented | host; no secret logging toggle as a convenience default |
| credential locator or secret reference | runtime, sensitive | resolve through approved host credential mechanism | never embed secret bytes in build options, plans, logs or .zon |
| project/context attribution | observation metadata | update future diagnostic attribution | host; cannot alter peer verification or permissions |

Classify each field once in caller-owned scope policy. An unrecognized field, wrong numeric kind, overflow, unknown environment, disallowed override or scope reclassification fails before the side effect it could influence. Record effective-plan and schema identities separately; an equal effective value does not make a changed schema/provider/toolchain automatically compatible.

## Build and runtime admission

1. Resolve selected environment/resource from bounded explicit sources; normalize via the selected schema/default authority.
2. Validate typed options and security requirements, including capacity coupling and explicit units.
3. Bind build inputs, compiler, target, provider and selected feature set; configure only enabled dependencies.
4. Compile a capability manifest or equivalent typed constants with the artifact.
5. At construction, receive host observations for the actual target/process; check permissions, initialization, required provider/runtime identity and compiled presence.
6. Return admitted typed options or a stable explicit reason. Do not install packages, switch trust stores or weaken policy to manufacture success.

ZSON's inspected capability fixture concerns explicit candidates and synthetic acceleration. Reusing its general decision pattern for TLS is a proposal, not an assertion that its CPU fallback model already expresses transport security policy. A QUIC/TLS adapter must define security-preserving alternatives and test required-mode rejection.

## Required tests

T07-03 covers identical lean target imports/artifacts when a runtime-only setting changes, and proves a disabled optional dependency is not configured. T01-03 checks normalized/defaulted option identity and caller override authority. T09-03 checks declared-target versus actual observed/runtime artifact facts, unknown capability and missing compiled branch. T10-03/T11-03 separate credential/context changes from authenticated identity and authorization.

Native platform tests remain necessary. No configuration evaluator result establishes hardware availability, permitted runtime operation or deployment safety by itself.
