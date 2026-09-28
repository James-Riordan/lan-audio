# Existing and planned directory map — revision 3

Existing source paths remain stable. Planned leaves are design cards only; exact package dependencies are in the roadmap JSON. Documentation is indexed separately by artifact-register.json; SDK provenance has its own inventory.

```text
tls-zig/
  AGENTS.md [existing]
  CHECKPOINT.md [existing]
  HANDOFF-shutdown.md [existing]
  HANDOFF-tcp-consumer.md [existing]
  HOST-DRIVER.md [existing]
  README.md [existing]
  SOURCE-ORIGIN.json [existing]
  backend-lock.json [existing]
  bench/
    engine.zig [planned T14]
  build/
    backend.zig [planned T07]
  build.zig [existing]
  build.zig.zon [existing]
  evidence/
    build-recovery.md [existing]
    source-provenance.json [existing]
  examples/
    consumer/
      build.zig [existing]
      build.zig.zon [existing]
      main.zig [existing]
      socket.c [existing]
      socket_posix.c [planned T08]
    roundtrip.zig [existing]
  src/
    backend/
      quic.c [planned T04]
      quic.h [planned T05]
    backend.c [existing]
    backend.h [existing]
    backend.zig [existing]
    driver.zig [existing]
    policy/
      credentials.zig [planned T10]
      verification.zig [planned T11]
    quic/
      contract.zig [implemented T01]
      engine.zig [planned T02]
      events.zig [implemented T03]
    root.zig [existing]
  tests/
    abi.zig [planned T09]
    driver.zig [existing]
    fixtures/
      ca.pem [existing]
      client.key [existing]
      client.pem [existing]
      expired.key [existing]
      expired.pem [existing]
      other-ca.pem [existing]
      server.key [existing]
      server.pem [existing]
      wrong-purpose.key [existing]
      wrong-purpose.pem [existing]
    interop/
      matrix.py [planned T13]
    quic_contract.zig [planned T06]
    resource_limits.zig [planned T12]
    transport.zig [existing]
  tools/
    build-openssl.sh [existing]
    check-docs.py [existing]
    check-event-model.py [existing]
    check-models.py [existing]
    check-plan.py [existing]
    test-plan-lifecycle.py [existing]
    test-backend.py [existing T00 acceptance]
    fetch-openssl.py [existing]
    interop.py [existing]
    make_fixtures.py [existing]
    pin-backend.py [existing]
    probe-quic-tls.c [existing]
    probe-quic-pair.c [existing]
    probe-quic-pair.py [existing]
    probe-quic-tls.py [existing]
    qualify.ps1 [existing]
    tcp_interop.py [existing]
    tcp_server_interop.py [existing]
    tcp_upload_interop.py [existing]
    test-openssl.sh [existing]
    verify-backend.py [complete T00]
```

## Additional implemented core paths

- `src/quic.zig`: pure module export root.
- `tests/quic/contract.zig`, `tests/quic/events.zig`: native admission/custody tests.
- `tests/quic/negative/`: four intentional type errors and one positive compiler control.
- `examples/quic-contract/`: separate SDK-free package consumer and synthetic provider fixture.
- `tools/test-quic-types.py`, `tools/qualify-quic-core.py`: diagnostics-bound compile controls and separated native/cross-build evidence.

The planned `tests/quic_contract.zig` still owns T06 real-provider conformance. These core fixtures do not close it.
