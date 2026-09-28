//! Project-owned reference kernel, not a separately promoted Zigadel library.
//! No I/O, allocator, clock, cryptography or worker threads are hidden here.
//! Hosts supply authenticated admission, serialization and media-clock ticks.
pub const Session = @import("session.zig").Session;
pub const Window = @import("window.zig").Window;
pub const wire = @import("wire.zig");
pub const Receiver = @import("receiver.zig").Receiver;
