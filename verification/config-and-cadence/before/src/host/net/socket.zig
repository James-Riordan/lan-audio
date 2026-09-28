//! Serialized, nonblocking TCP owner. No credentials, DNS, fixture policy or audio.
//! Keep at a stable address while transport callbacks borrow it. Only an external
//! atomic cancellation flag may be accessed by another thread; never cross-close.
const std = @import("std");
const c = @import("network_c");

pub const Family = enum { ipv4, ipv6 };
pub const Endpoint = struct { address: [:0]const u8, port: u16, scope_id: u32 = 0 };
pub const Interest = enum { input, output };
pub const Error = error{ InvalidState, InvalidEndpoint, EmptyBuffer, SystemFailure, CloseFailure, ClockFailure, ClockRegressed, Deadline, Canceled };

pub fn nowMilliseconds() Error!u64 {
    var value: u64 = undefined;
    if (c.la_net_now(&value) != c.LA_NET_OK) return error.ClockFailure;
    return value;
}

pub const Socket = struct {
    const Self = @This();
    native: c.la_net_socket = std.mem.zeroes(c.la_net_socket),
    state: enum { empty, open, connecting, connected, listening, failed, retired } = .empty,
    read_eof: bool = false,
    write_closed: bool = false,

    pub fn init(self: *Self, family: Family) Error!void {
        if (self.state != .empty) return error.InvalidState;
        self.native = std.mem.zeroes(c.la_net_socket);
        if (c.la_net_open(&self.native, if (family == .ipv4) 4 else 6) != c.LA_NET_OK) {
            if (self.native.close_error != 0) self.state = .retired;
            return error.SystemFailure;
        }
        self.read_eof = false;
        self.write_closed = false;
        self.state = .open;
    }

    fn endpointValid(self: *const Self, endpoint: Endpoint) bool {
        return endpoint.address.len > 0 and endpoint.address.len <= 45 and
            std.mem.indexOfScalar(u8, endpoint.address, 0) == null and
            (self.native.family == 6 or endpoint.scope_id == 0);
    }

    pub fn listen(self: *Self, endpoint: Endpoint, backlog: u16) Error!void {
        if (self.state != .open) return error.InvalidState;
        if (!self.endpointValid(endpoint) or backlog == 0 or backlog > 128) return error.InvalidEndpoint;
        switch (c.la_net_listen(&self.native, endpoint.address, endpoint.port, endpoint.scope_id, backlog)) {
            c.LA_NET_OK => {},
            c.LA_NET_BAD_ADDRESS => return error.InvalidEndpoint,
            else => return self.fail(),
        }
        self.state = .listening;
    }

    /// One connect attempt. False means pending, never connection success.
    pub fn connect(self: *Self, endpoint: Endpoint) Error!bool {
        if (self.state != .open) return error.InvalidState;
        if (!self.endpointValid(endpoint) or endpoint.port == 0) return error.InvalidEndpoint;
        return switch (c.la_net_connect(&self.native, endpoint.address, endpoint.port, endpoint.scope_id)) {
            c.LA_NET_OK => blk: {
                self.state = .connected;
                break :blk true;
            },
            c.LA_NET_AGAIN => blk: {
                self.state = .connecting;
                break :blk false;
            },
            c.LA_NET_BAD_ADDRESS => error.InvalidEndpoint,
            else => self.fail(),
        };
    }

    /// Poll once before reading SO_ERROR. Readiness alone is never success.
    pub fn finishConnect(self: *Self) Error!bool {
        if (self.state != .connecting) return error.InvalidState;
        switch (c.la_net_poll(&self.native, 1, 0)) {
            c.LA_NET_AGAIN => return false,
            c.LA_NET_OK => {},
            else => return self.fail(),
        }
        if (c.la_net_finish_connect(&self.native) != c.LA_NET_OK) return self.fail();
        self.state = .connected;
        return true;
    }

    /// Caller-owned empty destination. Accepted sockets own their runtime reference
    /// independently of the listener, so closing the listener cannot destroy them.
    pub fn accept(self: *Self, child: *Self) Error!bool {
        if (self.state != .listening or child.state != .empty or self == child) return error.InvalidState;
        child.native = std.mem.zeroes(c.la_net_socket);
        switch (c.la_net_accept(&self.native, &child.native)) {
            c.LA_NET_AGAIN => return false,
            c.LA_NET_OK => {},
            else => {
                if (child.native.close_error != 0) child.state = .retired;
                if (child.native.last_error != 0) self.native.last_error = child.native.last_error;
                return error.SystemFailure;
            },
        }
        child.read_eof = false;
        child.write_closed = false;
        child.state = .connected;
        return true;
    }

    fn fail(self: *Self) Error {
        self.state = .failed;
        return error.SystemFailure;
    }

    pub fn lastNativeError(self: *const Self) c_int {
        return self.native.last_error;
    }

    pub fn localPort(self: *Self) Error!u16 {
        if (self.state != .open and self.state != .connecting and self.state != .connected and self.state != .listening) return error.InvalidState;
        var port: u16 = undefined;
        if (c.la_net_port(&self.native, &port) != c.LA_NET_OK) return self.fail();
        return port;
    }

    /// Bounded syscall; null is would-block, positive count transfers a prefix.
    pub fn send(self: *Self, bytes: []const u8) Error!?usize {
        if (self.state != .connected or self.write_closed) return error.InvalidState;
        if (bytes.len == 0) return error.EmptyBuffer;
        var count: usize = 0;
        return switch (c.la_net_send(&self.native, bytes.ptr, bytes.len, &count)) {
            c.LA_NET_OK => count,
            c.LA_NET_AGAIN => null,
            else => self.fail(),
        };
    }

    /// Null is would-block; zero is read EOF. Read EOF does not close the write side.
    pub fn receive(self: *Self, bytes: []u8) Error!?usize {
        if (self.state != .connected) return error.InvalidState;
        if (bytes.len == 0) return error.EmptyBuffer;
        if (self.read_eof) return 0;
        var count: usize = 0;
        switch (c.la_net_recv(&self.native, bytes.ptr, bytes.len, &count)) {
            c.LA_NET_AGAIN => return null,
            c.LA_NET_OK => {},
            else => return self.fail(),
        }
        if (count == 0) self.read_eof = true;
        return count;
    }

    pub fn shutdownWrite(self: *Self) Error!void {
        if (self.state != .connected) return error.InvalidState;
        if (self.write_closed) return;
        if (c.la_net_shutdown_write(&self.native) != c.LA_NET_OK) return self.fail();
        self.write_closed = true;
    }

    /// Absolute monotonic deadline shared with the caller's operation. Cancellation
    /// is observed between waits of at most 10 ms; scheduling can add latency.
    /// Timeout/cancel do not close or transfer the descriptor. Its owner cleans up.
    pub fn wait(self: *Self, interest: Interest, deadline_ms: u64, canceled: ?*const std.atomic.Value(bool)) Error!void {
        if (self.state != .connecting and self.state != .connected and self.state != .listening) return error.InvalidState;
        if (interest == .output and self.write_closed) return error.InvalidState;
        var previous = try nowMilliseconds();
        while (true) {
            if (canceled) |flag| if (flag.load(.acquire)) return error.Canceled;
            const now = try nowMilliseconds();
            if (now < previous) return error.ClockRegressed;
            previous = now;
            if (now >= deadline_ms) return error.Deadline;
            const result = c.la_net_poll(&self.native, @intFromBool(interest == .output), @intCast(@min(deadline_ms - now, 10)));
            if (canceled) |flag| if (flag.load(.acquire)) return error.Canceled;
            const after = try nowMilliseconds();
            if (after < now) return error.ClockRegressed;
            previous = after;
            if (after >= deadline_ms) return error.Deadline;
            if (result == c.LA_NET_OK) return;
            if (result != c.LA_NET_AGAIN) return self.fail();
        }
    }

    /// Invoke once on the owner after every borrower finishes. A native close error
    /// is reported; the retired descriptor must not be blindly retried/reused.
    pub fn close(self: *Self) Error!void {
        if (self.state == .retired) return error.CloseFailure;
        const result = c.la_net_close(&self.native);
        if (result != c.LA_NET_OK) {
            self.state = .retired;
            return error.CloseFailure;
        }
        self.state = .empty;
    }

    // Signature-compatible with the reviewed TLS Transport, without importing TLS
    // or adopting its independently changing build/runtime in this host module.
    pub fn transportSend(context: *anyopaque, bytes: []const u8) error{TransportFailure}!?usize {
        const self: *Self = @ptrCast(@alignCast(context));
        return self.send(bytes) catch error.TransportFailure;
    }
    pub fn transportReceive(context: *anyopaque, bytes: []u8) error{TransportFailure}!?usize {
        const self: *Self = @ptrCast(@alignCast(context));
        return self.receive(bytes) catch error.TransportFailure;
    }
};
