const c = @import("tls_quic").contract;
export fn typeCheck() void {
    const count: c.ByteCount = .{ .value = 3 };
    const level: c.EncryptionLevel = .handshake;
    _ = count;
    _ = level;
}
