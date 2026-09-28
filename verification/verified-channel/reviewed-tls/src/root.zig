//! Engineering contract (2026-09-26)
//! Public TLS records Engine, configuration validation and C-status translation.
//! File contract: docs/reference/files/src/root.zig.md
//! Ownership and invariant: Engine owns the backend handle; do not copy after initialization.
//! Config strings and opaque ALPN are copied by init. Required peer checks and ALPN must pass
//! before plaintext access. tick uses milliseconds and an absolute handshake deadline; certificate
//! time uses supplied Unix seconds. InvalidState is not the same as a fatal TLS error. Fatal-alert
//! drain can remain available.
//! Next implementation obligation: Keep the 0.1.5 configurable single-ALPN behavior. Add capability
//! reporting and explicit platform/build rejection before portability work. Keep QUIC recordless
//! mode separate from feedRecords. Improve aggregate backend initialization errors only with a
//! stable diagnostic contract.
//! Verification: tests/transport.zig

const std = @import("std");
const c = @import("backend.zig");
pub const host = @import("driver.zig");
pub const Driver = host.Driver;

pub const Error = error{ InvalidConfig, BackendInitialization, InvalidState, Canceled, DeadlineExceeded, TlsFailure, PeerAuthentication, AlpnMismatch };
/// Separate error set preserves the error vocabulary of existing operations.
pub const PeerIdentityError = Error || error{ PeerIdentityUnavailable, PeerIdentityExportFailed };
pub const Progress = enum { complete, need_input, need_output, closed, input_full, plaintext_available };
pub const Transfer = struct { count: usize, progress: Progress };
pub const Role = enum { client, server };
pub const Identity = union(enum) { dns: [:0]const u8, ip: [:0]const u8 };
pub const Config = struct {
    role: Role,
    /// Exactly one opaque ALPN identifier, copied at init; absence/mismatch fails.
    /// HTTP/1.1 remains the compatibility default. Length must be 1..255 bytes.
    alpn: []const u8 = "http/1.1",
    ca_file: ?[:0]const u8 = null,
    certificate_file: ?[:0]const u8 = null,
    private_key_file: ?[:0]const u8 = null,
    peer: ?Identity = null,
    require_client_certificate: bool = false,
    /// Unix seconds; frozen for this connection's certificate verification.
    wall_time_seconds: i64,
    /// Host monotonic clock. Call tick before each scheduling round.
    now_ms: u64,
    handshake_timeout_ms: u32 = 10_000,
};
pub const Diagnostics = struct { verification_code: c_long, openssl_reason: c_ulong, received_alert: ?u8 };

/// Move-only owning handle. Serialize all calls; do not copy after initialization.
/// Config strings are borrowed only during init. No sockets, DNS, timers, or retries.
pub const Engine = struct {
    handle: ?*c.tz_engine,
    last_ms: u64,
    deadline_ms: u64,
    authenticated: bool = false,
    terminal: ?Error = null,

    pub fn init(config: Config) Error!Engine {
        if (config.alpn.len == 0 or config.alpn.len > 255) return error.InvalidConfig;
        if (config.wall_time_seconds <= 0 or config.handshake_timeout_ms == 0) return error.InvalidConfig;
        const deadline = std.math.add(u64, config.now_ms, config.handshake_timeout_ms) catch return error.InvalidConfig;
        for ([_]?[:0]const u8{ config.ca_file, config.certificate_file, config.private_key_file }) |path| {
            if (path) |p| if (p.len == 0 or std.mem.indexOfScalar(u8, p, 0) != null) return error.InvalidConfig;
        }
        if ((config.certificate_file == null) != (config.private_key_file == null)) return error.InvalidConfig;
        if (config.role == .client) {
            if (config.peer == null or config.ca_file == null or config.require_client_certificate) return error.InvalidConfig;
        } else if (config.certificate_file == null or config.peer != null or
            (config.require_client_certificate and config.ca_file == null)) return error.InvalidConfig;
        var peer: ?[*:0]const u8 = null;
        var ip: c_int = 0;
        if (config.peer) |identity| {
            const value = switch (identity) {
                .dns => |v| v,
                .ip => |v| blk: {
                    ip = 1;
                    break :blk v;
                },
            };
            if (value.len == 0 or value.len > 253) return error.InvalidConfig;
            for (value) |ch| if (ch == 0 or ch > 127 or ch <= 32 or ch == '*') return error.InvalidConfig;
            if (ip == 0) {
                // Require an ASCII DNS reference identifier (IDNA conversion is host-owned).
                for (value) |ch| if (!std.ascii.isAlphanumeric(ch) and ch != '-' and ch != '.') return error.InvalidConfig;
                var labels = std.mem.splitScalar(u8, value, '.');
                while (labels.next()) |label| {
                    if (label.len == 0 or label.len > 63 or label[0] == '-' or label[label.len - 1] == '-') return error.InvalidConfig;
                }
            }
            peer = value.ptr;
        }
        const h = c.tz_new_with_alpn(@intFromBool(config.role == .server), ptr(config.ca_file), ptr(config.certificate_file), ptr(config.private_key_file), peer, ip, @intFromBool(config.require_client_certificate), config.wall_time_seconds, config.alpn.ptr, config.alpn.len) orelse return error.BackendInitialization;
        return .{ .handle = h, .last_ms = config.now_ms, .deadline_ms = deadline };
    }
    fn ptr(s: ?[:0]const u8) ?[*:0]const u8 {
        return if (s) |v| v.ptr else null;
    }
    fn live(self: *Engine) Error!*c.tz_engine {
        if (self.terminal) |err| return err;
        return self.handle orelse error.Canceled;
    }
    fn status(self: *Engine, code: c_int) Error!Progress {
        return switch (code) {
            0 => .complete,
            1 => .need_input,
            2 => .need_output,
            3 => .closed,
            4 => .input_full,
            5 => .plaintext_available,
            -4 => error.InvalidState,
            else => blk: {
                const err: Error = switch (code) {
                    -2 => error.PeerAuthentication,
                    -3 => error.AlpnMismatch,
                    else => error.TlsFailure,
                };
                self.terminal = err;
                self.authenticated = false;
                break :blk err;
            },
        };
    }
    pub fn tick(self: *Engine, now_ms: u64) Error!void {
        _ = try self.live();
        if (now_ms < self.last_ms) return error.InvalidState;
        self.last_ms = now_ms;
        if (!self.authenticated and now_ms >= self.deadline_ms) {
            self.cancel();
            self.terminal = error.DeadlineExceeded;
            return error.DeadlineExceeded;
        }
    }
    pub fn handshake(self: *Engine) Error!Progress {
        const p = try self.status(c.tz_handshake(try self.live()));
        if (p == .complete) self.authenticated = true;
        return p;
    }
    /// Copies at most 16 KiB and reports the exact accepted prefix. Empty input is not EOF.
    pub fn feedRecords(self: *Engine, bytes: []const u8) Error!Transfer {
        var count: usize = 0;
        const p = try self.status(c.tz_feed(try self.live(), bytes.ptr, bytes.len, &count));
        return .{ .count = count, .progress = p };
    }
    /// Draining is allowed after TLS failure so the host can send a generated alert.
    pub fn drainRecords(self: *Engine, bytes: []u8) Error!Transfer {
        const h = self.handle orelse return self.terminal orelse error.Canceled;
        var count: usize = 0;
        const p = try self.status(c.tz_drain(h, bytes.ptr, bytes.len, &count));
        return .{ .count = count, .progress = p };
    }
    pub fn readPlaintext(self: *Engine, bytes: []u8) Error!Transfer {
        var count: usize = 0;
        const p = try self.status(c.tz_read(try self.live(), bytes.ptr, bytes.len, &count));
        return .{ .count = count, .progress = p };
    }
    /// Copies one nonempty block <=16 KiB. Success means local custody, not delivery.
    /// Call flushPlaintext until complete, draining output whenever necessary.
    pub fn queuePlaintext(self: *Engine, bytes: []const u8) Error!void {
        _ = try self.status(c.tz_write(try self.live(), bytes.ptr, bytes.len));
    }
    pub fn flushPlaintext(self: *Engine) Error!Progress {
        return self.status(c.tz_flush(try self.live()));
    }
    /// Starts local close. On plaintext_available, readPlaintext before retrying.
    /// Pending peer data is preserved; only closed authenticates peer close_notify.
    pub fn shutdown(self: *Engine) Error!Progress {
        return self.status(c.tz_shutdown(try self.live()));
    }
    /// Signals raw transport EOF. Subsequent handshake/read must still authenticate closure.
    pub fn transportEof(self: *Engine) Error!void {
        _ = try self.status(c.tz_eof(try self.live()));
    }
    /// Returns an owned SHA-256 of the verified peer leaf certificate's DER.
    /// Requires local handshake completion and successful peer verification;
    /// a server must require a client certificate. New queries are denied after
    /// TLS failure, shutdown, EOF or cancellation. Previously copied values are
    /// caller-owned snapshots: bind them to your connection generation/policy.
    /// This is not an SPKI hash or proof of the remote application's acceptance.
    pub fn verifiedPeerLeafSha256(self: *const Engine) PeerIdentityError![32]u8 {
        if (self.terminal) |err| return err;
        const h = self.handle orelse return error.Canceled;
        if (!self.authenticated) return error.InvalidState;
        var digest: [32]u8 = undefined;
        return switch (c.tz_verified_peer_leaf_sha256(h, &digest, digest.len)) {
            0 => digest,
            -4 => error.PeerIdentityUnavailable,
            else => error.PeerIdentityExportFailed,
        };
    }
    pub fn diagnostics(self: *const Engine) ?Diagnostics {
        const h = self.handle orelse return null;
        const alert = c.tz_alert(h);
        return .{ .verification_code = c.tz_verify_error(h), .openssl_reason = c.tz_reason(h), .received_alert = if (alert < 0) null else @intCast(alert) };
    }
    pub fn cancel(self: *Engine) void {
        if (self.handle) |h| c.tz_free(h);
        self.handle = null;
        self.authenticated = false;
        if (self.terminal == null) self.terminal = error.Canceled;
    }
    pub fn deinit(self: *Engine) void {
        self.cancel();
    }
};

pub fn backendVersion() []const u8 {
    return std.mem.span(c.tz_version());
}
