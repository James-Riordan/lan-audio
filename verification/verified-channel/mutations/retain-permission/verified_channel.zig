//! Serialized worker-side TLS/v2 connection. Never call from an audio callback.
//! Owns Driver; borrows a connected Socket and cancellation flag at stable addresses.
//! Credentials, reference name, wall time, generation and peer approval are explicit.
const std = @import("std");
const tls = @import("tls");
const net = @import("network_host");
const core = @import("lan_audio");
const policy = @import("peer_policy");
const admission = @import("channel_admission");
const wire = core.wire_v2;

pub const Config = struct {
    transport_role: tls.Role,
    local_role: policy.Role,
    generation: u64,
    expected_peer: policy.Fingerprint,
    ca_file: [:0]const u8,
    certificate_file: [:0]const u8,
    private_key_file: [:0]const u8,
    reference_identity: ?tls.Identity,
    wall_time_seconds: i64,
    now_ms: u64,
    handshake_timeout_ms: u32 = 10_000,
};
pub const Error = tls.host.Error || tls.PeerIdentityError || net.Error || admission.Error || wire.Error ||
    error{ ChannelClosed, UnexpectedCompletion, DataAfterEnd, ParserStalled };

/// Move before borrowing, then keep fixed. Calls and configuration changes are
/// serialized by the enclosing worker. Only the atomic flag is cross-thread.
pub const Connection = struct {
    driver: tls.Driver,
    socket: *net.Socket,
    channel: admission.Channel,
    canceled: ?*const std.atomic.Value(bool),
    parser: wire.Parser = .{},
    input: [2048]u8 = undefined,
    offset: usize = 0,
    used: usize = 0,

    pub fn init(socket: *net.Socket, config: Config, canceled: ?*const std.atomic.Value(bool)) Error!Connection {
        if (socket.state != .connected or socket.read_eof or socket.write_closed) return error.InvalidState;
        const channel = try admission.Channel.init(config.generation, config.local_role, config.expected_peer);
        if (canceled) |flag| if (flag.load(.acquire)) return error.Canceled;
        return .{
            .driver = try tls.Driver.init(.{
                .role = config.transport_role,
                .alpn = wire.alpn,
                .ca_file = config.ca_file,
                .certificate_file = config.certificate_file,
                .private_key_file = config.private_key_file,
                .peer = config.reference_identity,
                .require_client_certificate = config.transport_role == .server,
                .wall_time_seconds = config.wall_time_seconds,
                .now_ms = config.now_ms,
                .handshake_timeout_ms = config.handshake_timeout_ms,
            }, .{ .context = socket, .send = net.Socket.transportSend, .recv = net.Socket.transportReceive }, canceled),
            .socket = socket,
            .channel = channel,
            .canceled = canceled,
        };
    }

    /// Stops TLS borrowing before the enclosing owner closes the socket. Repeated
    /// calls are harmless. Does not close the socket or attest device quiescence.
    pub fn deinit(self: *Connection) void {
        self.driver.deinit();
        
    }

    fn current(self: *Connection, generation: u64) Error!void {
        if (generation != self.channel.generation) return error.StaleGeneration;
        if (self.channel.revoked) return error.Revoked;
        if (self.canceled) |flag| if (flag.load(.acquire)) {
            self.deinit();
            return error.Canceled;
        };
    }

    fn permitted(self: *Connection, generation: u64, revision: u64) Error!void {
        try self.current(generation); // A stale completion cannot revoke its replacement.
        errdefer self.deinit();
        const permit = self.channel.permit orelse return error.Unauthenticated;
        if (permit.policy_revision != revision) return error.AuthorizationChanged;
    }

    /// Drive one already-begun operation to completion with the original absolute
    /// deadline. No retry changes custody or extends the deadline. Dedicated worker
    /// only: socket waits are bounded/cancelable; TLS may allocate outside callbacks.
    fn run(self: *Connection, deadline: u64) Error!tls.host.Result {
        while (true) {
            const result = try self.driver.step(try net.nowMilliseconds());
            switch (result) {
                .again => {},
                .wait_input => try self.socket.wait(.input, deadline, self.canceled),
                .wait_output => try self.socket.wait(.output, deadline, self.canceled),
                else => return result,
            }
        }
    }

    /// Repeated handshake requests recheck the live binding without resetting the
    /// negotiated stream. TLS client/server role is independent of audio role.
    pub fn handshake(self: *Connection, generation: u64, rules: *const policy.Policy, deadline: u64) Error!admission.Authorization {
        try self.current(generation);
        errdefer self.deinit();
        if (self.channel.permit == null) {
            try self.driver.beginHandshake(try net.nowMilliseconds(), deadline);
            if (try self.run(deadline) != .complete) return error.UnexpectedCompletion;
        }
        return try self.refresh(generation, rules);
    }

    /// The only Evidence construction in this host: a copied digest from this
    /// Driver's live verified Engine, after exact-ALPN handshake. Both configs
    /// present certificates and servers require client verification. This proves
    /// local verification, not the remote application's approval of this client.
    pub fn refresh(self: *Connection, generation: u64, rules: *const policy.Policy) Error!admission.Authorization {
        try self.current(generation);
        errdefer self.deinit();
        const leaf = try self.driver.engine.verifiedPeerLeafSha256();
        return try self.channel.authorize(rules, .{
            .generation = generation,
            .mutually_authenticated = true,
            .verified_leaf = leaf,
            .alpn = wire.alpn,
        });
    }

    /// Exactly one encoded record, validated before TLS custody. beginWrite copies
    /// bytes, then the candidate frontier commits once. Partial I/O stays internal.
    /// Failure after copied custody is terminal; reconnect never reuses this stream.
    pub fn send(self: *Connection, generation: u64, revision: u64, bytes: []const u8, deadline: u64) Error!void {
        try self.permitted(generation, revision);
        errdefer self.deinit();
        var candidate = self.channel;
        try candidate.apply(generation, revision, .outgoing, try wire.parse(bytes));
        try self.driver.beginWrite(bytes, try net.nowMilliseconds(), deadline);
        self.channel = candidate;
        const result = try self.run(deadline);
        if (result != .complete or result.complete != bytes.len) return error.UnexpectedCompletion;
    }

    /// Borrowed message expires at next receive/deinit. Caller must finish/copy a
    /// downstream block before receiving again. Coalesced suffixes remain in input;
    /// partial records remain in parser. Admission precedes return to the worker.
    pub fn receive(self: *Connection, generation: u64, revision: u64, deadline: u64) Error!wire.Message {
        try self.permitted(generation, revision);
        errdefer self.deinit();
        while (true) {
            if (self.offset < self.used) {
                const fed = try self.parser.feed(self.input[self.offset..self.used]);
                if (fed.consumed == 0) return error.ParserStalled;
                self.offset += fed.consumed;
                if (fed.message) |message| {
                    try self.channel.apply(generation, revision, .incoming, message);
                    return message;
                }
            } else {
                try self.driver.beginRead(&self.input, try net.nowMilliseconds(), deadline);
                const result = try self.run(deadline);
                if (result == .closed) {
                    try self.parser.finish();
                    return error.ChannelClosed;
                }
                if (result != .complete or result.complete == 0) return error.UnexpectedCompletion;
                self.offset = 0;
                self.used = result.complete;
            }
        }
    }

    /// Enclosing receiver supplies actual downstream drain evidence. This method
    /// checks permission/phase only; it never invents a native callback fence.
    pub fn confirmDrained(self: *Connection, generation: u64, revision: u64) Error!void {
        try self.permitted(generation, revision);
        errdefer self.deinit();
        try self.channel.confirmDrained(generation, revision);
    }

    /// END/ACK completion precedes TLS close. Refuse buffered or later plaintext.
    /// Success also revokes permission; caller records completion before cleanup.
    pub fn finish(self: *Connection, generation: u64, revision: u64, deadline: u64) Error!void {
        try self.permitted(generation, revision);
        defer self.deinit();
        if (self.channel.gate.phase != .complete) return error.InvalidState;
        if (self.offset < self.used) return error.DataAfterEnd;
        try self.parser.finish();
        try self.driver.beginShutdown(try net.nowMilliseconds(), deadline);
        const result = try self.run(deadline);
        if (result == .plaintext_available) return error.DataAfterEnd;
        if (result != .closed) return error.UnexpectedCompletion;
    }

    pub fn revoke(self: *Connection, generation: u64) Error!void {
        if (generation != self.channel.generation) return error.StaleGeneration;
        self.deinit();
    }
};
