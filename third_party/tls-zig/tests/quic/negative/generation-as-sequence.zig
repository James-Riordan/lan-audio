const c = @import("tls_quic").contract;
export fn typeCheck() void {
    const source: c.OwnerGeneration = .{ .value = 1 };
    const invalid: c.Sequence = source;
    _ = invalid;
}
