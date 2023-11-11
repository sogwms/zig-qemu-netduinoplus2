//! Interface of mcli-editor
//! Version 0.1.0
//! By vano
//！Note: not good smell that duplications of xer.zig

const SReader = @import("sreader.zig");
const SWriter = @import("swriter.zig");

// Note: apparently, the caller can use vtable directly, here the xxx wrapper
// may be just giving more conveniences by replacing the call "x.xxx(x.ptr,...)" with "x.xxx(...)"
const Editor = @This();

// the type erased pointer to the implementation
ptr: *anyopaque,
vtable: VTable,

// virtual function table
pub const VTable = struct {
    // call the module
    call: *const fn (ctx: *anyopaque, in: SReader, sout: SWriter, eout: SWriter) void,
    // callback used to give the final text
    set_cb_complete: *const fn (ctx: *anyopaque, cb: *const fn (ctx: *anyopaque, s: []const u8) void, cb_ctx: *anyopaque) void,
};

/// call module
pub inline fn call(self: Editor, in: SReader, sout: SWriter, eout: SWriter) void {
    return self.vtable.call(self.ptr, in, sout, eout);
}

/// callback used to give the final text
pub inline fn set_cb_complete(self: Editor, cb: *const fn (ctx: *anyopaque, s: []const u8) void, cb_ctx: *anyopaque) void {
    return self.vtable.set_cb_complete(self.ptr, cb, cb_ctx);
}

// This is new
pub fn init(ptr: anytype) Editor {
    const T = @TypeOf(ptr);
    const typeInfo = @typeInfo(T);
    const methods = typeInfo.Pointer.child;

    const gen = struct {
        pub fn call(pointer: *anyopaque, in: SReader, sout: SWriter, eout: SWriter) void {
            const self: T = @ptrCast(@alignCast(pointer));
            return methods.call(self, in, sout, eout);
        }

        pub fn set_cb_complete(pointer: *anyopaque, cb: *const fn (ctx: *anyopaque, s: []const u8) void, cb_ctx: *anyopaque) void {
            const self: T = @ptrCast(@alignCast(pointer));
            return methods.set_cb_complete(self, cb, cb_ctx);
        }
    };

    return .{
        .ptr = ptr,
        .vtable = .{
            .call = gen.call,
            .set_cb_complete = gen.set_cb_complete,
        },
    };
}
