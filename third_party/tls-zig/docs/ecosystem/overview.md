# QUIC and TLS within the JCR / Zigadel ecosystem

Status: revision-4 implementation design, informed by the user's ecosystem vision and inspected producer specifications. This does not add runtime integration or change installed tools. The maintained libraries remain reusable foundations; product, orchestration and workstation policy have their own owners.

## Ownership and composition

| Owner | Responsibility at this boundary | What QUIC/TLS consume or expose |
| --- | --- | --- |
| quic-zig | packet protection, CRYPTO custody, streams, recovery, flow control and path lifecycle | explicit datagram/time/entropy host seam; truthful supported transport capabilities |
| tls-zig | records Engine/Driver today; future recordless handshake owner, peer policy and traffic secrets | explicit configuration and borrowed/owned data contracts; no socket/provider substitution hidden in parsing |
| application / Zap | traffic policy, request meaning, authorization and application commit | connection events and authenticated peer observations; decides retries above transport |
| Hydra | orchestration, lifecycle and deployment wiring under qualified capabilities | injected host services and health/diagnostic outcomes; reusable protocol core does not acquire tenant/billing logic |
| MetaOS / Projectz / Workspacez | project identity, custody, tool selection and workstation integration | resolved roots/artifacts supplied by a host adapter; no hardcoded C:/Projects dependency in library code |
| Contextz | explicit selected-context observations | optional attribution metadata; context is neither authenticated peer identity nor permission |
| ZSON | structured evaluation, schemas, normalized plans and declared capability policy | optional host/build configuration adapter; library APIs still accept typed options |
| Updatez | update/check orchestration, version policy, candidate custody and repair reports | pinned build/backend identities and scoped check receipts; consumer owns adoption |
| Docz / Quartz | document language and retained-source editing / knowledge presentation | a future native documentation representation with tested anchor, link and provenance migration |

The JCR architecture separates source-import dependencies from runtime wiring and product policy. This handoff follows that boundary. No new package dependency is justified solely by sharing an ecosystem name. A CLI or SvelteKit UI can consume a host/application adapter; neither belongs inside cryptographic or packet-processing code without a concrete library requirement.

## Identity before location, without losing wire facts

Keep distinct types for logical project/service identity, source revision, content digest, physical artifact locator, network address, connection ID and authenticated peer identity. Moving a source tree can preserve its logical identity; changing a DNS name, credential or peer identity is a separate security/configuration event. A digest binds bytes, not the authority that supplied them.

The host resolves a logical service to an allowed endpoint and independent expected peer identity before construction. Packet routing still uses actual addresses/CIDs, and certificate validation still uses explicit identity/trust. A context selection or catalog relationship must never rewrite trust, authenticate a peer, grant access or validate a new network path. Path migration is subject to QUIC's own validation and amplification rules.

For local preparation, existing file paths remain the concrete source authority. A future MetaOS catalog can reference their project/revision identities without reorganizing the repository into one global namespace. Source movement needs path-resolution, package, consumer and evidence tests; directory decoupling is not permission to silently move referenced files.

## Adaptation is an explicit decision

Model a host capability as supported / unsupported / unknown, with a target identity and observation scope. Build-target declarations select compiled code; runtime observations establish whether that compiled capability can be used in the actual process. Neither a Windows build host nor a successful cross-compile proves Linux runtime behavior. Unknown is not success.

Hardware crypto acceleration may select an independently qualified implementation with equivalent semantics. Missing required TLS, trust validation, ALPN, QUIC or entropy must fail explicitly; no plaintext or weaker-authentication fallback. Optional performance tuning may fall back only where the policy permits and the functional implementation was compiled and tested.

## Where idempotence belongs

For maintenance, reconciling the same desired policy against the same observed state should not repeat completed installation/promotion effects. Rechecking can produce fresh evidence. For transport, retransmission preserves byte custody and protocol identity rules; it does not make an application mutation safe to repeat. Peer ACK, TLS authentication and successful request commit remain distinct facts. A retry token is not a universal request-idempotency token.

Minimal formal separation:

`host_context != peer_identity != application_authorization`

`desired_config + observed_capabilities + compiled_features -> admitted_options OR explicit_failure`

`same_maintenance_identity -> reconcile_existing_effects`; no corresponding rule permits automatic replay of an arbitrary application operation.

## Source observations and adoption

[Producer observations](producer-observations.json) record exact inspected document/source hashes and paths. They are dated observations, not new dependency pins or proof of producer tests rerun here. [Configuration](configuration-and-capabilities.md), [maintenance/observability](maintenance-and-observability.md) and [Docz migration](docz-migration.md) define the concrete integration requirements.

The [takeover guide](../roadmap/takeover.md) and package graph remain the implementation entry. Eleven additional acceptance obligations refine existing packages; none creates an empty ecosystem adapter or advertises an integrated feature.
