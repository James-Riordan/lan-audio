//! Project-owned reference kernel, not a separately promoted Zigadel library.
//! No I/O, allocator, clock, cryptography or worker threads are hidden here.
//! Hosts supply authenticated admission, serialization and media-clock ticks.
//! wire/Receiver retain v1 block semantics; wire_v2/Negotiation use source frames.
//! The source reading map is src/README.md; exports construct no runtime owners.
pub const Session = @import("session/session.zig").Session;
pub const Window = @import("media/playout_window.zig").Window;
pub const wire = @import("protocol/v1.zig");
pub const Format = @import("media/format.zig").Format;
pub const BlockAssembler = @import("media/block_assembler.zig").BlockAssembler;
pub const wire_v2 = @import("protocol/v2.zig");
pub const Negotiation = @import("protocol/negotiation.zig").Negotiation;
pub const Receiver = @import("session/receiver.zig").Receiver;
pub const FrameQueue = @import("audio/frame_queue.zig").FrameQueue;
pub const CallbackBridge = @import("audio/callback_bridge.zig").CallbackBridge;
