const base = @import("../base/base.zig");
const std = @import("std");

const Command = struct {
    const Self = @This();

    // call the module
    pub fn call(self: *Self, in: base.SReader, sout: base.SWriter, eout: base.SWriter) void {
        _ = self;
        _ = eout;
        var buf: [128]u8 = undefined;
        var rsize = in.read(&buf, 16);
        _ = sout.write("[echo-cmd]:");
        _ = sout.write(buf[0..rsize]);
        // std.debug.print("\r\ndebug-mcli[echo]: {s}\r\n", .{buf[0..rsize]});
    }

    pub fn command(self: *Self) base.Command {
        return base.Command.init(self);
    }
};

var cmd_echo: Command = undefined;

pub fn new() base.Command {
    return cmd_echo.command();
}
