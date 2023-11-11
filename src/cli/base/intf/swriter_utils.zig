const SWriter = @import("swriter.zig");

/// Obj used for making a SWriter by buffer([]const u8)
const SwriterFromPutc = struct {
    ctx: *anyopaque,
    putc: *const fn (ctx: *anyopaque, c: u8) u32,

    const Self = @This();
    pub fn write(self: *Self, s: []const u8) u32 {
        for (s) |c| {
            self.putc(self.ctx, c);
        }

        return @as(u32, @truncate(s.len));
    }

    pub fn writer(self: *Self) SWriter {
        return SWriter.init(self);
    }
};

pub fn swriter_from_putc(ctx: *anyopaque, putc: *const fn (ctx: *anyopaque, c: u8) u32) SwriterFromPutc {
    return .{ .ctx = ctx, .putc = putc };
}

/// Obj used for making a SWriter by buffer([]const u8)
const SwriterFromPutcWithoutCtx = struct {
    putc: *const fn (c: u8) void,

    const Self = @This();
    pub fn write(self: *Self, s: []const u8) u32 {
        for (s) |c| {
            self.putc(c);
        }

        return @as(u32, @truncate(s.len));
    }

    pub fn writer(self: *Self) SWriter {
        return SWriter.init(self);
    }
};

pub fn swriter_from_putc_without_ctx(putc: *const fn (c: u8) void) SwriterFromPutcWithoutCtx {
    return .{ .putc = putc };
}
