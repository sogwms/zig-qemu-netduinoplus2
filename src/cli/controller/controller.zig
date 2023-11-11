const base = @import("../base/base.zig");
const std = @import("std");

// editor representation
const Controller = struct {
    commander: base.Commander = undefined,

    const Self = @This();

    // call the module
    pub fn call(self: *Self, in: base.SReader, sout: base.SWriter, eout: base.SWriter) void {
        // std.debug.print("\r\n[debug-mcli/controller]: call\r\n", .{});

        self.commander.call(in, sout, eout);
    }

    pub fn editor(self: *Self) base.Controller {
        return base.Controller.init(self);
    }
};

var gcontroller: Controller = .{
    // .commander = commander.new(),
};

// TODO: solve many new with the same instance
pub fn new(commander: base.Commander) base.Controller {
    gcontroller.commander = commander;
    return gcontroller.editor();
}
