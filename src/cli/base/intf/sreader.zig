//! Interface string-reader
//! Version 0.1.0
//! By vano

// Note: apparently, the caller can use vtable directly, here the xxx wrapper
// may be just giving more conveniences by replacing the call "x.xxx(x.ptr,...)" with "x.xxx(...)"
const SReader = @This();

// the type erased pointer to the implementation
ptr: *anyopaque,
vtable: VTable,

// virtual function table
pub const VTable = struct {
    /// read string
    read: *const fn (ctx: *anyopaque, buf: [*]u8, size: u32) u32,
};

/// read string
pub inline fn read(self: SReader, buf: [*]u8, size: u32) u32 {
    return self.vtable.read(self.ptr, buf, size);
}

// This is new
pub fn init(ptr: anytype) SReader {
    const T = @TypeOf(ptr);
    const typeInfo = @typeInfo(T);

    const gen = struct {
        pub fn read(pointer: *anyopaque, buf: [*]u8, size: u32) u32 {
            const self: T = @ptrCast(@alignCast(pointer));
            return typeInfo.Pointer.child.read(self, buf, size);
        }
    };

    return .{
        .ptr = ptr,
        .vtable = .{
            .read = gen.read,
        },
    };
}
