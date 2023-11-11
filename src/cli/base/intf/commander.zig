//! Interface of mcli-commander
//! Version 0.0.1
//! By vano

const SReader = @import("sreader.zig");
const SWriter = @import("swriter.zig");
const Command = @import("command.zig");

// Note: apparently, the caller can use vtable directly, here the xxx wrapper
// may be just giving more conveniences by replacing the call "x.xxx(x.ptr,...)" with "x.xxx(...)"
const Xer = @This();

// the type erased pointer to the implementation
ptr: *anyopaque,
vtable: VTable,

// virtual function table
pub const VTable = struct {
    // Call the module
    call: *const fn (ctx: *anyopaque, in: SReader, sout: SWriter, eout: SWriter) void,
    // Add a new command to commander
    // return 'failed' if the command existed
    add_cmd: *const fn (ctx: *anyopaque, name: []const u8, cmd: Command) void,
    // Remove the command from commander
    rm_cmd: *const fn (ctx: *anyopaque, name: []const u8) void,
};

/// call module
pub inline fn call(self: Xer, in: SReader, sout: SWriter, eout: SWriter) void {
    return self.vtable.call(self.ptr, in, sout, eout);
}

/// call module
pub inline fn add_cmd(self: Xer, name: []const u8, cmd: Command) void {
    return self.vtable.add_cmd(self.ptr, name, cmd);
}

/// call module
pub inline fn rm_cmd(self: Xer, name: []const u8) void {
    return self.vtable.rm_cmd(self.ptr, name);
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

        pub fn add_cmd(pointer: *anyopaque, name: []const u8, cmd: Command) void {
            const self: T = @ptrCast(@alignCast(pointer));
            return methods.add_cmd(self, name, cmd);
        }

        pub fn rm_cmd(pointer: *anyopaque, name: []const u8) void {
            const self: T = @ptrCast(@alignCast(pointer));
            return methods.rm_cmd(self, name);
        }
    };

    return .{
        .ptr = ptr,
        .vtable = .{
            .call = gen.call,
            .add_cmd = gen.add_cmd,
            .rm_cmd = gen.rm_cmd,
        },
    };
}
