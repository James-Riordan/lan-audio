const c = @import("tls_quic").contract;
export fn typeCheck() void {
    const source: c.WallTimeSeconds = .{ .value = 1 };
    const invalid: c.MonotonicNs = source;
    _ = invalid;
}
