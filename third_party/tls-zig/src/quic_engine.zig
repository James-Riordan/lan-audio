//! Native recordless TLS owner. The separate tls_quic module remains SDK-free.
const implementation = @import("quic/engine.zig");
pub const Engine = implementation.Engine;
pub const Budget = implementation.Budget;
pub const Error = implementation.Error;
pub const capabilities = implementation.capabilities;
pub const contract = implementation.contract;
pub const TestHooks = implementation.TestHooks;
