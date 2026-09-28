//! Internal ABI declarations, checked against separately compiled C layout probes.
pub const Bytes = extern struct { data: ?[*]const u8, length: usize };
pub const Capabilities = extern struct { abi_version: u32, compiled_recordless: u32, runtime_available: u32, qualified_target: u32 };
pub const Config = extern struct {
    abi_version: u32,
    role: u32,
    identity_kind: u32,
    require_client_certificate: u32,
    wall_time_seconds: i64,
    trust_file: Bytes,
    certificate_file: Bytes,
    private_key_file: Bytes,
    identity: Bytes,
    alpn: Bytes,
    local_parameters: Bytes,
    peer_parameter_limit: usize,
};
pub const Callbacks = extern struct {
    abi_version: u32,
    context: ?*anyopaque,
    send: ?*const fn (?*anyopaque, u32, Bytes, *usize) callconv(.c) i32,
    receive: ?*const fn (?*anyopaque, u32, usize, *Bytes) callconv(.c) i32,
    release: ?*const fn (?*anyopaque, u32, Bytes) callconv(.c) i32,
    secret: ?*const fn (?*anyopaque, u32, u32, u32, Bytes) callconv(.c) i32,
    parameters: ?*const fn (?*anyopaque, Bytes) callconv(.c) i32,
    alert: ?*const fn (?*anyopaque, u32) callconv(.c) i32,
};
pub const Result = extern struct {
    wait: u32,
    tls_complete: u32,
    peer_authentication: u32,
    alert_code: u32,
    ssl_error: i32,
    callback_failed: u32,
    verify_error: i64,
    input_delivered: usize,
    output_accepted: usize,
    lease_bytes: usize,
};

pub const Provider = opaque {};
pub extern fn tlsq_query(u32, *Capabilities) callconv(.c) u32;
pub extern fn tlsq_validate(*const Config, *const Callbacks) callconv(.c) u32;
pub extern fn tlsq_create(*const Config, *const Callbacks, *?*Provider) callconv(.c) u32;
pub extern fn tlsq_step(*Provider, usize, usize, *Result) callconv(.c) u32;
pub extern fn tlsq_close(*Provider) callconv(.c) u32;
pub extern fn tlsq_destroy(*?*Provider) callconv(.c) u32;
