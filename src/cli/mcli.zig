const std = @import("std");
const base = @import("base/base.zig");
pub usingnamespace @import("base/base.zig");
const editor = @import("editor/editor.zig");
const controller = @import("controller/controller.zig");
const commander = @import("commander/commander.zig");

// mcli representation
const Mcli = struct {
    editor: base.Editor = undefined,
    controller: base.Controller = undefined,

    _in: base.SReader = undefined,
    _sout: base.SWriter = undefined,

    const Self = @This();

    // call the module
    fn call(ctx: *anyopaque, in: base.SReader, sout: base.SWriter, eout: base.SWriter) void {
        const self: *Self = @ptrCast(@alignCast(ctx));

        self._in = in;
        self._sout = sout;
        self.editor.call(in, sout, eout);
    }

    pub fn mcli(self: *Self) base.Mcli {
        return .{
            .ptr = self,
            .vtable = &.{ .call = call },
        };
    }
};

fn editor_cb_complete(ctx: *anyopaque, s: []const u8) void {
    const self: *Mcli = @ptrCast(@alignCast(ctx));
    _ = self._sout.write("[debug-cb]:==>\r\n");
    _ = self._sout.write(s);
    _ = self._sout.write("[debug-cb]:<==\r\n");

    var reader = base.sreader_from_buffer(s);
    self.controller.call(reader.reader(), self._sout, self._sout);
}

var gmcli: Mcli = .{};

const cmd_echo = @import("./commands/cmd_echo.zig");

// create a new mcli
pub fn new() base.Mcli {
    var _editor = editor.new();
    _editor.set_cb_complete(editor_cb_complete, &gmcli);
    gmcli.editor = _editor;

    var _cmder = commander.new();
    _cmder.add_cmd("echo", cmd_echo.new());
    gmcli.controller = controller.new(_cmder);

    return gmcli.mcli();
}
