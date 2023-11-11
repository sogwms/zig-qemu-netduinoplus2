//! Interface of mcli-controller
//! Version 0.0.1
//! By vano

const SReader = @import("sreader.zig");
const SWriter = @import("swriter.zig");
const Commander = @import("commander.zig");

// Note: apparently, the caller can use vtable directly, here the xxx wrapper
// may be just giving more conveniences by replacing the call "x.xxx(x.ptr,...)" with "x.xxx(...)"
const Xer = @This();

// the type erased pointer to the implementation
ptr: *anyopaque,
vtable: VTable,

// virtual function table
pub const VTable = struct {
    // call the module
    call: *const fn (ctx: *anyopaque, in: SReader, sout: SWriter, eout: SWriter) void,
};

/// call module
pub inline fn call(self: Xer, in: SReader, sout: SWriter, eout: SWriter) void {
    return self.vtable.call(self.ptr, in, sout, eout);
}

// This is new
pub fn init(ptr: anytype) Xer {
    const T = @TypeOf(ptr);
    const typeInfo = @typeInfo(T);
    const methods = typeInfo.Pointer.child;

    const gen = struct {
        pub fn call(pointer: *anyopaque, in: SReader, sout: SWriter, eout: SWriter) void {
            const self: T = @ptrCast(@alignCast(pointer));
            return methods.call(self, in, sout, eout);
        }
    };

    return .{
        .ptr = ptr,
        .vtable = .{
            .call = gen.call,
        },
    };
}
