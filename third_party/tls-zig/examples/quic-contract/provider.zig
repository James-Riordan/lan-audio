//! Contract fixture, not a TLS implementation; capability observations are synthetic.
const c = @import("tls_quic").contract;
pub const available: c.Capabilities = .{ .recordless = true, .tls13 = true, .quic_v1 = true, .aes128gcm_sha256 = true, .runtime = .available };
pub const Provider = struct {
    calls: usize = 0,
    pub fn construct(self: *Provider, plan: c.Plan, caps: c.Capabilities) c.Error!void {
        try plan.verify(caps);
        self.calls += 1;
    }
    pub fn consume(self: *Provider, input: []const u8) c.Transfer {
        self.calls += 1;
        return .{ .accepted = .{ .value = @min(input.len, 2) }, .wait = .local_work };
    }
};
