//! Low-level Zig access to pinned miniaudio 0.11.25 through `c`.
//!
//! This boundary preserves upstream result codes and ownership. It does not hide
//! pointers behind movable Zig values or turn C failures into unreachable states.
//! Initialized contexts/devices must remain at stable addresses until uninit.
//! Buffers passed to callbacks are borrowed only for that callback invocation.
//! Device control belongs to a non-callback owner; stop/uninit must quiesce callbacks
//! before their userdata or queues can be released. See docs/CONTRACT.md.
pub const c = @import("miniaudio_c");
