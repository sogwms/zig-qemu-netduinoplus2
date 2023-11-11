const base = @import("../base/base.zig");
// const csm = @import("csm.zig");

// editor representation
const Editor = struct {
    cb_complete: *const fn (ctx: *anyopaque, s: []const u8) void = undefined,
    cb_complete_ctx: *anyopaque,

    // TODO improve to use dynamic way
    buffer: [512]u8 = undefined,
    idx: u16 = 0,

    const Self = @This();

    // call the module
    pub fn call(self: *Self, in: base.SReader, sout: base.SWriter, eout: base.SWriter) void {
        _ = sout;
        _ = eout;

        if (self.cb_complete == undefined) {
            return;
        }

        // Syntax
        //  '\n' 是输入终止符（无特殊情况时）
        //  '\' 是 '\n' 抵消符，抵消终止作用
        //  ''

        var buf: [128]u8 = undefined;
        var rsize = in.read(&buf, 16);
        self.cb_complete(self.cb_complete_ctx, buf[0..rsize]);
    }

    // callback used to give the final text
    pub fn set_cb_complete(ctx: *anyopaque, cb: *const fn (ctx: *anyopaque, s: []const u8) void, cb_ctx: *anyopaque) void {
        const self: *Self = @ptrCast(@alignCast(ctx));
        self.cb_complete = cb;
        self.cb_complete_ctx = cb_ctx;
    }

    pub fn editor(self: *Self) base.Editor {
        return base.Editor.init(self);
    }
};

var geditor: Editor = undefined;

pub fn new() base.Editor {
    return geditor.editor();
}
