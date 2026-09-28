//! Test-only Windows loopback adapter over the reviewed TLS example C transport.
//! No configurable remote address; send/receive force short transfers. One owner
//! serializes Driver calls and polls against the original absolute deadline.
//! Does not implement product sockets, reconnection, identity or device control.
const tls = @import("tls");
pub extern fn demo_now() u64;
pub extern fn demo_name() [*:0]const u8;
extern fn demo_open() isize;
extern fn demo_close(socket: isize) void;
extern fn demo_send(socket: isize, bytes: [*]const u8, len: c_int) c_int;
extern fn demo_recv(socket: isize, bytes: [*]u8, len: c_int) c_int;
extern fn demo_poll(socket: isize, writing: c_int, timeout_ms: u32) c_int;

pub const Network = struct {
    socket: isize,
    pub fn open() !Network {
        const socket = demo_open();
        if (socket == -1) return error.SocketConnect;
        return .{ .socket = socket };
    }
    pub fn close(self: *Network) void {
        demo_close(self.socket);
    }
    pub fn send(context: *anyopaque, bytes: []const u8) error{TransportFailure}!?usize {
        const self: *Network = @ptrCast(@alignCast(context));
        const n = demo_send(self.socket, bytes.ptr, @intCast(bytes.len));
        if (n == -2) return null;
        if (n < 0) return error.TransportFailure;
        return @intCast(n);
    }
    pub fn recv(context: *anyopaque, bytes: []u8) error{TransportFailure}!?usize {
        const self: *Network = @ptrCast(@alignCast(context));
        const n = demo_recv(self.socket, bytes.ptr, @intCast(bytes.len));
        if (n == -2) return null;
        if (n < 0) return error.TransportFailure;
        return @intCast(n);
    }
    pub fn run(self: *Network, driver: *tls.Driver) !tls.host.Result {
        while (true) {
            const result = try driver.step(demo_now());
            switch (result) {
                .again => {},
                .wait_input, .wait_output => {
                    const now = demo_now();
                    if (now >= driver.deadline_ms) continue;
                    const timeout: u32 = @intCast(@min(25, driver.deadline_ms - now));
                    if (demo_poll(self.socket, @intFromBool(result == .wait_output), timeout) < 0) return error.SocketPoll;
                },
                else => return result,
            }
        }
    }
};
