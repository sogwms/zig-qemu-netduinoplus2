//! Interface of mcli-module
//! Version 0.0.1
//! By vano

pub const SReader = @import("sreader.zig");
pub const SWriter = @import("swriter.zig");

// Note: apparently, the caller can use vtable directly, here the xxx wrapper
// may be just giving more conveniences by replacing the call "x.xxx(x.ptr,...)" with "x.xxx(...)"
const Xer = @This();

// the type erased pointer to the implementation
ptr: *anyopaque,
vtable: *const VTable,

// virtual function table
pub const VTable = struct {
    // call the module
    call: *const fn (ctx: *anyopaque, in: SReader, sout: SWriter, eout: SWriter) void,
};

/// call module
pub inline fn call(self: Xer, in: SReader, sout: SWriter, eout: SWriter) void {
    return self.vtable.call(self.ptr, in, sout, eout);
}
