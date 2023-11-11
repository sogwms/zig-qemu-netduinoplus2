const SReader = @import("sreader.zig");

/// Obj used for making a SReader by buffer([]const u8)
const SReaderFromBuffer = struct {
    buffer: []const u8,

    const Self = @This();

    pub fn read(self: *Self, buf: [*]u8, size: u32) u32 {
        _ = size;
        //TODO impl size
        @memcpy(buf, self.buffer);

        return @as(u32, @truncate(self.buffer.len));
    }

    pub fn reader(self: *Self) SReader {
        return SReader.init(self);
    }
};

pub fn sreader_from_buffer(buffer: []const u8) SReaderFromBuffer {
    return SReaderFromBuffer{ .buffer = buffer };
}
