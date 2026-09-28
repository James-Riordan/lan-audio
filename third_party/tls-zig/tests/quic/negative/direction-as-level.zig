const c = @import("tls_quic").contract;
export fn typeCheck() void {
    const source: c.Direction = .read;
    const invalid: c.EncryptionLevel = source;
    _ = invalid;
}
