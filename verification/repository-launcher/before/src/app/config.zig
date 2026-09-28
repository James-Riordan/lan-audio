//! Data-only operation profiles. Parsing/resolution opens no files or devices.
//! Returned slices borrow the parsed document; retain it for the entire operation.
const std = @import("std");
pub const maximum_bytes = 65536;
pub const Role = enum { send, receive };
pub const Capture = enum { system_output, process_tree, browser_tab };
pub const Layer = struct {
    role: ?Role = null,
    address: ?[]const u8 = null,
    ca: ?[]const u8 = null,
    cert: ?[]const u8 = null,
    key: ?[]const u8 = null,
    peer_fingerprint: ?[]const u8 = null,
    peer_name: ?[]const u8 = null,
    device: ?[]const u8 = null,
    port: ?u16 = null,
    buffer_ms: ?u32 = null,
    max_buffer_ms: ?u32 = null,
    seconds: ?u32 = null,
    reconnect: ?bool = null,
    capture: ?Capture = null,
};
pub const Profile = struct { name: []const u8, settings: Layer };
pub const Document = struct { schema: u32, defaults: Layer = .{}, profiles: []const Profile };
pub const Effective = struct {
    role: Role,
    address: []const u8,
    ca: []const u8,
    cert: []const u8,
    key: []const u8,
    peer_fingerprint: []const u8,
    peer_name: ?[]const u8 = null,
    device: ?[]const u8 = null,
    port: u16 = 46321,
    buffer_ms: u32 = 40,
    max_buffer_ms: u32 = 120,
    seconds: u32 = 0,
    reconnect: bool = true,
};

/// Bounds scanner work/depth before recursive decoding. Null has no reset meaning
/// in schema 1; omission inherits, and arrays replace (profiles do not inherit).
pub fn parse(allocator: std.mem.Allocator, bytes: []const u8) !std.json.Parsed(Document) {
    if (bytes.len > maximum_bytes) return error.ConfigTooLarge;
    var scanner = std.json.Scanner.initCompleteInput(allocator, bytes);
    defer scanner.deinit();
    var depth: usize = 0;
    while (true) {
        const token = try scanner.next();
        switch (token) {
            .object_begin, .array_begin => {
                depth += 1;
                if (depth > 8) return error.ConfigTooDeep;
            },
            .object_end, .array_end => depth -= 1,
            .null => return error.ConfigNullUnsupported,
            .end_of_document => break,
            else => {},
        }
    }
    // Zig's typed JSON decoder accepts some numeric strings. Schema 1 does not;
    // check the JSON token types before its checked integer narrowing.
    const tree = try std.json.parseFromSlice(std.json.Value, allocator, bytes, .{ .max_value_len = 4096 });
    defer tree.deinit();
    try checkTypes(tree.value);
    const parsed = try std.json.parseFromSlice(Document, allocator, bytes, .{ .max_value_len = 4096 });
    errdefer parsed.deinit();
    if (parsed.value.schema != 1) return error.UnsupportedConfigSchema;
    if (parsed.value.profiles.len == 0 or parsed.value.profiles.len > 32) return error.InvalidProfiles;
    try validateLayer(parsed.value.defaults);
    for (parsed.value.profiles, 0..) |profile, i| {
        if (profile.name.len == 0 or profile.name.len > 64) return error.InvalidProfileName;
        for (profile.name) |byte| if (!std.ascii.isAlphanumeric(byte) and byte != '-' and byte != '_') return error.InvalidProfileName;
        for (parsed.value.profiles[0..i]) |prior| if (std.mem.eql(u8, profile.name, prior.name)) return error.DuplicateProfile;
        try validateLayer(profile.settings);
    }
    return parsed;
}

fn checkTypes(value: std.json.Value) !void {
    switch (value) {
        .object => |object| {
            var fields = object.iterator();
            while (fields.next()) |entry| {
                const key = entry.key_ptr.*;
                inline for (.{ "schema", "port", "buffer_ms", "max_buffer_ms", "seconds" }) |numeric| {
                    if (std.mem.eql(u8, key, numeric) and entry.value_ptr.* != .integer) return error.InvalidConfigType;
                }
                try checkTypes(entry.value_ptr.*);
            }
        },
        .array => |array| for (array.items) |item| try checkTypes(item),
        else => {},
    }
}

fn validateLayer(layer: Layer) !void {
    inline for (.{ "address", "ca", "cert", "key", "peer_fingerprint", "peer_name", "device" }) |field| {
        if (@field(layer, field)) |value| {
            if (value.len == 0 or value.len > 4096 or !std.unicode.utf8ValidateSlice(value)) return error.InvalidConfigString;
            for (value) |byte| if (byte < 32 or byte == 127) return error.InvalidConfigString;
        }
    }
}

pub fn resolve(document: Document, name: []const u8) !Effective {
    if (document.schema != 1) return error.UnsupportedConfigSchema;
    var layer = document.defaults;
    const selected = for (document.profiles) |profile| {
        if (std.mem.eql(u8, profile.name, name)) break profile.settings;
    } else return error.ProfileNotFound;
    inline for (@typeInfo(Layer).@"struct".field_names) |name_| {
        if (@field(selected, name_)) |value| @field(layer, name_) = value;
    }
    try validateLayer(layer);
    const role = layer.role orelse return error.RequiredOptions;
    // The vocabulary reserves selection intent without pretending a backend
    // exists. Never broaden a requested subset into whole-output capture.
    if (layer.capture) |capture| {
        if (role != .send) return error.UnusedCaptureSelection;
        if (capture != .system_output) return error.UnsupportedCaptureSelection;
    }
    const result: Effective = .{
        .role = role,
        .address = layer.address orelse return error.RequiredOptions,
        .ca = layer.ca orelse return error.RequiredOptions,
        .cert = layer.cert orelse return error.RequiredOptions,
        .key = layer.key orelse return error.RequiredOptions,
        .peer_fingerprint = layer.peer_fingerprint orelse return error.RequiredOptions,
        .peer_name = layer.peer_name,
        .device = layer.device,
        .port = layer.port orelse 46321,
        .buffer_ms = layer.buffer_ms orelse 40,
        .max_buffer_ms = layer.max_buffer_ms orelse 120,
        .seconds = layer.seconds orelse 0,
        .reconnect = layer.reconnect orelse true,
    };
    try validate(result);
    return result;
}

pub fn validate(value: Effective) !void {
    try validateLayer(.{ .address = value.address, .ca = value.ca, .cert = value.cert, .key = value.key, .peer_fingerprint = value.peer_fingerprint, .peer_name = value.peer_name, .device = value.device });
    if ((value.role == .send) != (value.peer_name != null) or value.port == 0 or
        value.buffer_ms < 5 or value.buffer_ms > value.max_buffer_ms or value.max_buffer_ms > 240 or
        value.seconds > 86400 or (value.role == .receive and value.seconds != 0)) return error.InvalidOptions;
    if (value.peer_fingerprint.len != 64) return error.InvalidFingerprint;
    for (value.peer_fingerprint) |byte| if (!std.ascii.isHex(byte)) return error.InvalidFingerprint;
    // Literal-only endpoints: parsing here prevents a malformed address reaching
    // socket acquisition. Platform native parsing still revalidates at open.
    _ = std.Io.net.IpAddress.parse(value.address, value.port) catch return error.InvalidAddress;
}

test "profiles inherit fields deterministically and preserve false assignments" {
    const input =
        \\{"schema":1,"defaults":{"role":"send","ca":"ca.pem","cert":"identity.pem","key":"identity.key","peer_name":"receiver","peer_fingerprint":"aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa","buffer_ms":60,"reconnect":true},"profiles":[{"name":"home","settings":{"address":"192.168.1.2","buffer_ms":40,"reconnect":false}},{"name":"away","settings":{"address":"::1","buffer_ms":80}}]}
    ;
    const parsed = try parse(std.testing.allocator, input);
    defer parsed.deinit();
    const home = try resolve(parsed.value, "home");
    try std.testing.expectEqual(@as(u32, 40), home.buffer_ms);
    try std.testing.expect(!home.reconnect);
    try std.testing.expectEqualStrings("ca.pem", home.ca);
    try std.testing.expectEqual(@as(u32, 80), (try resolve(parsed.value, "away")).buffer_ms);
    try std.testing.expectEqualDeep(home, try resolve(parsed.value, "home"));
    try std.testing.expectError(error.ProfileNotFound, resolve(parsed.value, "missing"));
}

test "ambiguous and unsupported documents fail before resolution" {
    const cases = .{
        .{ error.DuplicateField, "{\"schema\":1,\"schema\":1,\"profiles\":[]}" },
        .{ error.UnknownField, "{\"schema\":1,\"typo\":true,\"profiles\":[]}" },
        .{ error.UnsupportedConfigSchema, "{\"schema\":2,\"profiles\":[]}" },
        .{ error.ConfigNullUnsupported, "{\"schema\":1,\"defaults\":null,\"profiles\":[]}" },
        .{ error.DuplicateProfile, "{\"schema\":1,\"profiles\":[{\"name\":\"a\",\"settings\":{}},{\"name\":\"a\",\"settings\":{}}]}" },
        .{ error.InvalidConfigString, "{\"schema\":1,\"profiles\":[{\"name\":\"a\",\"settings\":{\"key\":\"a\\u0000b\"}}]}" },
        .{ error.InvalidConfigType, "{\"schema\":\"1\",\"profiles\":[]}" },
        .{ error.InvalidConfigType, "{\"schema\":1,\"defaults\":{\"port\":46321.0},\"profiles\":[]}" },
    };
    inline for (cases) |case| try std.testing.expectError(case[0], parse(std.testing.allocator, case[1]));
}

test "resource bounds and selection policy cannot be bypassed by a profile" {
    const oversized = try std.testing.allocator.alloc(u8, maximum_bytes + 1);
    defer std.testing.allocator.free(oversized);
    @memset(oversized, ' ');
    try std.testing.expectError(error.ConfigTooLarge, parse(std.testing.allocator, oversized));
    try std.testing.expectError(error.ConfigTooDeep, parse(std.testing.allocator, "[[[[[[[[[0]]]]]]]]]"));
    const base: Layer = .{ .role = .send, .address = "127.0.0.1", .ca = "ca.pem", .cert = "c.pem", .key = "k.pem", .peer_name = "receiver", .peer_fingerprint = "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa" };
    const cases = .{
        .{ error.UnsupportedCaptureSelection, Layer{ .capture = .process_tree } },
        .{ error.UnsupportedCaptureSelection, Layer{ .capture = .browser_tab } },
        .{ error.InvalidOptions, Layer{ .port = 0 } },
        .{ error.InvalidOptions, Layer{ .buffer_ms = 4 } },
        .{ error.InvalidOptions, Layer{ .max_buffer_ms = 241 } },
        .{ error.InvalidOptions, Layer{ .buffer_ms = 121 } },
        .{ error.InvalidOptions, Layer{ .seconds = 86401 } },
        .{ error.InvalidAddress, Layer{ .address = "not-a-literal" } },
        .{ error.InvalidFingerprint, Layer{ .peer_fingerprint = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx" } },
    };
    inline for (cases) |case| {
        const profiles = [_]Profile{.{ .name = "test", .settings = case[1] }};
        try std.testing.expectError(case[0], resolve(.{ .schema = 1, .defaults = base, .profiles = &profiles }, "test"));
    }
}
