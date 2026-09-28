//! Independent-package consumption exercises build wiring and C linking, not just
//! a header import. It invokes no device APIs or operating-system audio permissions.
const std = @import("std");
const c = @import("miniaudio").c;
test "miniaudio dependency supplies the pinned PCM ABI" {
    try std.testing.expectEqual(@as(c_uint, 8), c.ma_get_bytes_per_frame(c.ma_format_f32, 2));
    try std.testing.expectEqual(@as(c_uint, 25), c.MA_VERSION_REVISION);
}
