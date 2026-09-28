//! Recordless TLS vocabulary and allocation-free configuration admission.
//! No network, filesystem, ambient defaults, native provider or records API.
//! Plan slices are borrowed and immutable until the constructing owner verifies
//! the plan and copies them. A digest detects drift; it is not authorization.
const std = @import("std");

pub const schema_version: u32 = 1;
pub const Error = error{
    UnavailableCapability,
    UnknownCapability,
    UnknownOption,
    UnauthorizedOverride,
    DuplicateOverride,
    InvalidPolicy,
    InvalidIdentity,
    InvalidAlpn,
    InvalidTime,
    InvalidCapacity,
    StalePlan,
    ProviderOverconsumption,
    OutOfGenerations,
};
pub const EncryptionLevel = enum(u8) { initial, handshake, application };
/// Relative to this endpoint, never relative to the sender of a callback.
pub const Direction = enum(u8) { read, write };
pub const CipherSuite = enum(u16) { aes128gcm_sha256 = 0x1301, _ };
pub const QuicVersion = enum(u32) { v1 = 1, _ };
pub const TlsVersion = enum(u16) { v1_3 = 0x0304, _ };
pub const ByteCount = struct { value: usize };
pub const DurationNs = struct { value: u64 };
pub const WallTimeSeconds = struct { value: i64 };
pub const MonotonicNs = struct {
    value: u64,
    /// Deadlines round toward earlier wakeup; no wall-time conversion exists.
    pub fn toMicrosEarly(self: MonotonicNs) u64 {
        return self.value / 1000;
    }
};
pub const Sequence = struct { value: u64 };
pub const OwnerGeneration = struct { value: u64 };
pub const OwnerId = struct {
    domain: *const anyopaque,
    generation: OwnerGeneration,
    pub fn eql(a: OwnerId, b: OwnerId) bool {
        return a.domain == b.domain and a.generation.value == b.generation.value;
    }
};
pub const EventId = struct {
    owner: OwnerId,
    sequence: Sequence,
    pub fn eql(a: EventId, b: EventId) bool {
        return OwnerId.eql(a.owner, b.owner) and a.sequence.value == b.sequence.value;
    }
};

var generations = std.atomic.Value(usize).init(0);
fn takeGeneration(counter: *std.atomic.Value(usize)) Error!OwnerGeneration {
    var previous = counter.load(.monotonic);
    while (true) {
        if (previous == std.math.maxInt(usize)) return error.OutOfGenerations;
        if (counter.cmpxchgWeak(previous, previous + 1, .monotonic, .monotonic)) |changed| {
            previous = changed;
        } else return .{ .value = previous + 1 };
    }
}
/// Fresh for this loaded module's lifetime. Domain distinguishes simultaneously
/// loaded copies; do not unload a module while any of its handles/tokens exist.
pub fn freshOwner() Error!OwnerId {
    return .{ .domain = &generations, .generation = try takeGeneration(&generations) };
}

pub const Availability = enum(u8) { unknown, unavailable, available };
pub const Capabilities = struct {
    recordless: bool = false,
    tls13: bool = false,
    quic_v1: bool = false,
    aes128gcm_sha256: bool = false,
    runtime: Availability = .unknown,
};
pub const Profile = struct {
    version: QuicVersion = .v1,
    tls: TlsVersion = .v1_3,
    suite: CipherSuite = .aes128gcm_sha256,
};
pub const Requirements = struct {
    early_data: bool = false,
    resumption: bool = false,
    custom_entropy: bool = false,
    /// No current adapter can enforce this; requesting it fails explicitly.
    provider_memory_limit: ?ByteCount = null,
};
pub const Credentials = struct { certificate_file: [:0]const u8, private_key_file: [:0]const u8 };
pub const Identity = union(enum) { dns: [:0]const u8, ip: [:0]const u8 };
pub const ClientAuthentication = union(enum) { none, required: [:0]const u8 };
pub const Policy = union(enum) {
    client: struct { trust_file: [:0]const u8, peer: Identity, credentials: ?Credentials = null },
    server: struct { credentials: Credentials, client_authentication: ClientAuthentication = .none },
};
pub const PeerAuthentication = enum { configured_server_policy, verified_server_identity, verified_client_certificate };

/// Wrapper storage units only. These do not bound provider heap or call duration.
pub const Limits = struct {
    /// Accepted input capacity per encryption level in the native Engine.
    /// Its three rings allocate 3 * input_bytes; this is not a provider heap cap.
    input_bytes: ByteCount = .{ .value = 16 * 1024 },
    event_slots: usize = 16,
    control_slots: usize = 8,
    event_payload_bytes: ByteCount = .{ .value = 4096 },
    peer_parameter_bytes: ByteCount = .{ .value = 4096 },
    pub fn validate(self: Limits) Error!void {
        if (self.input_bytes.value == 0 or self.control_slots == 0 or self.event_slots <= self.control_slots or
            self.event_payload_bytes.value < 32 or self.peer_parameter_bytes.value == 0 or
            self.peer_parameter_bytes.value > self.event_payload_bytes.value) return error.InvalidCapacity;
        _ = try self.payloadStorageBytes();
    }
    pub fn payloadStorageBytes(self: Limits) Error!ByteCount {
        return .{ .value = std.math.mul(usize, self.event_slots, self.event_payload_bytes.value) catch return error.InvalidCapacity };
    }
};
pub const Config = struct {
    policy: Policy,
    alpn: []const u8,
    local_parameters: []const u8,
    wall_time: WallTimeSeconds,
    now: MonotonicNs,
    timeout: DurationNs = .{ .value = 10_000_000_000 },
    profile: Profile = .{},
    requirements: Requirements = .{},
    limits: Limits = .{},
};
/// Whole-field replacement; no environment reads, deep merge, or zero fallback.
pub const Override = union(enum) {
    policy: Policy,
    alpn: []const u8,
    local_parameters: []const u8,
    timeout: DurationNs,
    profile: Profile,
    requirements: Requirements,
    limits: Limits,
    unknown,
};
pub const OverridePolicy = struct {
    policy: bool = false,
    alpn: bool = false,
    local_parameters: bool = false,
    timeout: bool = false,
    profile: bool = false,
    requirements: bool = false,
    limits: bool = false,
};
pub const Plan = struct {
    config: Config,
    deadline: MonotonicNs,
    schema: u32,
    fingerprint: [32]u8,
    /// Mandatory immediately before allocation/copy. Detects changed borrowed
    /// bytes, effective options, capability observations, schema and deadline.
    pub fn verify(self: Plan, caps: Capabilities) Error!void {
        const fresh = try normalize(self.config, &.{}, .{}, caps);
        if (self.schema != fresh.schema or self.deadline.value != fresh.deadline.value or
            !std.mem.eql(u8, &self.fingerprint, &fresh.fingerprint)) return error.StalePlan;
    }
};

fn pathValid(path: []const u8) bool {
    return path.len != 0 and std.mem.indexOfScalar(u8, path, 0) == null;
}
fn credentialsValid(value: Credentials) bool {
    return pathValid(value.certificate_file) and pathValid(value.private_key_file);
}
fn validateIdentity(identity: Identity) Error!void {
    const value = switch (identity) {
        .dns => |v| v,
        .ip => |v| v,
    };
    if (value.len == 0 or value.len > 253) return error.InvalidIdentity;
    for (value) |ch| if (ch <= 32 or ch > 127 or ch == '*') return error.InvalidIdentity;
    switch (identity) {
        .ip => {
            _ = std.Io.net.IpAddress.parse(value, 0) catch return error.InvalidIdentity;
        },
        .dns => {
            for (value) |ch| if (!std.ascii.isAlphanumeric(ch) and ch != '-' and ch != '.') return error.InvalidIdentity;
            var labels = std.mem.splitScalar(u8, value, '.');
            while (labels.next()) |label| {
                if (label.len == 0 or label.len > 63 or label[0] == '-' or label[label.len - 1] == '-') return error.InvalidIdentity;
            }
        },
    }
}
fn validate(cfg: Config, caps: Capabilities) Error!MonotonicNs {
    if (!caps.recordless or !caps.tls13 or !caps.quic_v1 or !caps.aes128gcm_sha256 or
        cfg.profile.version != .v1 or cfg.profile.tls != .v1_3 or cfg.profile.suite != .aes128gcm_sha256 or
        cfg.requirements.early_data or cfg.requirements.resumption or cfg.requirements.custom_entropy or
        cfg.requirements.provider_memory_limit != null) return error.UnavailableCapability;
    switch (caps.runtime) {
        .unknown => return error.UnknownCapability,
        .unavailable => return error.UnavailableCapability,
        .available => {},
    }
    if (cfg.alpn.len == 0 or cfg.alpn.len > 255) return error.InvalidAlpn;
    try cfg.limits.validate();
    if (cfg.local_parameters.len > cfg.limits.peer_parameter_bytes.value) return error.InvalidCapacity;
    if (cfg.wall_time.value <= 0 or cfg.timeout.value == 0) return error.InvalidTime;
    const deadline = std.math.add(u64, cfg.now.value, cfg.timeout.value) catch return error.InvalidTime;
    switch (cfg.policy) {
        .client => |policy| {
            if (!pathValid(policy.trust_file)) return error.InvalidPolicy;
            if (policy.credentials) |creds| if (!credentialsValid(creds)) return error.InvalidPolicy;
            try validateIdentity(policy.peer);
        },
        .server => |policy| {
            if (!credentialsValid(policy.credentials)) return error.InvalidPolicy;
            switch (policy.client_authentication) {
                .none => {},
                .required => |trust| if (!pathValid(trust)) return error.InvalidPolicy,
            }
        },
    }
    return .{ .value = deadline };
}

const Hash = struct {
    hash: std.crypto.hash.sha2.Sha256 = .init(.{}),
    fn number(self: *Hash, n: u64) void {
        var encoded: [8]u8 = undefined;
        std.mem.writeInt(u64, &encoded, n, .little);
        self.hash.update(&encoded);
    }
    fn bytes(self: *Hash, value: []const u8) void {
        self.number(value.len);
        self.hash.update(value);
    }
    fn credentials(self: *Hash, value: Credentials) void {
        self.bytes(value.certificate_file);
        self.bytes(value.private_key_file);
    }
};
fn fingerprint(cfg: Config, caps: Capabilities) [32]u8 {
    var h: Hash = .{};
    h.hash.update("tls-zig.recordless.plan\x00");
    h.number(schema_version);
    h.number(@backingInt(cfg.profile.version));
    h.number(@backingInt(cfg.profile.tls));
    h.number(@backingInt(cfg.profile.suite));
    switch (cfg.policy) {
        .client => |policy| {
            h.number(0);
            h.bytes(policy.trust_file);
            switch (policy.peer) {
                .dns => |v| {
                    h.number(0);
                    h.bytes(v);
                },
                .ip => |v| {
                    h.number(1);
                    h.bytes(v);
                },
            }
            h.number(@intFromBool(policy.credentials != null));
            if (policy.credentials) |creds| h.credentials(creds);
        },
        .server => |policy| {
            h.number(1);
            h.credentials(policy.credentials);
            switch (policy.client_authentication) {
                .none => h.number(0),
                .required => |trust| {
                    h.number(1);
                    h.bytes(trust);
                },
            }
        },
    }
    h.bytes(cfg.alpn);
    h.bytes(cfg.local_parameters);
    h.number(@intCast(cfg.wall_time.value));
    h.number(cfg.now.value);
    h.number(cfg.timeout.value);
    h.number(cfg.limits.input_bytes.value);
    h.number(cfg.limits.event_slots);
    h.number(cfg.limits.control_slots);
    h.number(cfg.limits.event_payload_bytes.value);
    h.number(cfg.limits.peer_parameter_bytes.value);
    h.number(@intFromBool(cfg.requirements.early_data));
    h.number(@intFromBool(cfg.requirements.resumption));
    h.number(@intFromBool(cfg.requirements.custom_entropy));
    h.number(@intFromBool(cfg.requirements.provider_memory_limit != null));
    if (cfg.requirements.provider_memory_limit) |limit| h.number(limit.value);
    h.number(@intFromBool(caps.recordless));
    h.number(@intFromBool(caps.tls13));
    h.number(@intFromBool(caps.quic_v1));
    h.number(@intFromBool(caps.aes128gcm_sha256));
    h.number(@backingInt(caps.runtime));
    return h.hash.finalResult();
}
/// The host supplies its selected environment defaults as base. Authorization is
/// caller-owned, checked before applying overrides. No allocation or provider call.
pub fn normalize(base: Config, overrides: []const Override, allowed: OverridePolicy, caps: Capabilities) Error!Plan {
    var cfg = base;
    var seen: u8 = 0;
    for (overrides) |override| {
        if (override == .unknown) return error.UnknownOption;
        const bit = @as(u8, 1) << @as(u3, @intCast(@backingInt(std.meta.activeTag(override))));
        if (seen & bit != 0) return error.DuplicateOverride;
        seen |= bit;
        switch (override) {
            inline else => |value, tag| {
                if (comptime tag != .unknown) {
                    if (!@field(allowed, @tagName(tag))) return error.UnauthorizedOverride;
                    @field(cfg, @tagName(tag)) = value;
                }
            },
        }
    }
    const deadline = try validate(cfg, caps);
    return .{ .config = cfg, .deadline = deadline, .schema = schema_version, .fingerprint = fingerprint(cfg, caps) };
}

pub const Wait = enum { progress, network_input, event_capacity, local_work, input_capacity };
pub const Transfer = struct {
    accepted: ByteCount,
    wait: Wait,
    /// A provider result is untrusted until checked against the offered slice.
    pub fn acceptedPrefix(self: Transfer, offered: []const u8) Error![]const u8 {
        if (self.accepted.value > offered.len) return error.ProviderOverconsumption;
        return offered[0..self.accepted.value];
    }
};
pub const Payload = union(enum) {
    crypto: struct { level: EncryptionLevel, bytes: []const u8 },
    secret: struct { level: EncryptionLevel, direction: Direction, suite: CipherSuite, bytes: *const [32]u8 },
    peer_parameters: []const u8,
    handshake_complete: PeerAuthentication,
    alert: u8,
};
/// Payload views expire on successful ack, cancel or deinit, not on append.
pub const Event = struct { id: EventId, payload: Payload };
pub const ConsumeError = error{ WouldBlock, Rejected };
pub const Consumer = struct {
    context: *anyopaque,
    /// Success asserts a completed independent copy/derivation/policy action.
    /// Failure must leave consumer side effects retry-safe. No queue reentry.
    accept: *const fn (*anyopaque, Event) ConsumeError!void,
};

test "owner generation exhaustion never wraps" {
    var counter = std.atomic.Value(usize).init(std.math.maxInt(usize) - 1);
    try std.testing.expectEqual(@as(u64, std.math.maxInt(usize)), (try takeGeneration(&counter)).value);
    try std.testing.expectError(error.OutOfGenerations, takeGeneration(&counter));
    try std.testing.expectEqual(std.math.maxInt(usize), counter.load(.monotonic));
}
