const c = @import("tls_quic").contract;
export fn typeCheck() void {
    const source: usize = 3;
    const invalid: c.ByteCount = source;
    _ = invalid;
}
