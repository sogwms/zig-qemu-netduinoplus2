//! Interface string-writer
//! Version 0.1.0
//! By vano
const SWriter = @This();

// the type erased pointer to the implementation
ptr: *anyopaque,
vtable: VTable,

// virtual function table
const VTable = struct {
    /// write string
    write: *const fn (ctx: *anyopaque, s: []const u8) u32,
};

/// write string
pub inline fn write(self: SWriter, s: []const u8) u32 {
    return self.vtable.write(self.ptr, s);
}

// This is new
pub fn init(ptr: anytype) SWriter {
    const T = @TypeOf(ptr);
    const typeInfo = @typeInfo(T);

    const gen = struct {
        pub fn write(pointer: *anyopaque, s: []const u8) u32 {
            const self: T = @ptrCast(@alignCast(pointer));
            return typeInfo.Pointer.child.write(self, s);
        }
    };

    return .{
        .ptr = ptr,
        .vtable = .{
            .write = gen.write,
        },
    };
}
