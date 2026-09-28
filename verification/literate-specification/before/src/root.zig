//! Project-owned reference kernel, not a separately promoted Zigadel library.
//! No I/O, allocator, clock, cryptography or worker threads are hidden here.
//! Hosts supply authenticated admission, serialization and media-clock ticks.
pub const Session = @import("session/session.zig").Session;
pub const Window = @import("media/playout_window.zig").Window;
pub const wire = @import("protocol/v1.zig");
pub const Receiver = @import("session/receiver.zig").Receiver;
pub const FrameQueue = @import("audio/frame_queue.zig").FrameQueue;
pub const CallbackBridge = @import("audio/callback_bridge.zig").CallbackBridge;
