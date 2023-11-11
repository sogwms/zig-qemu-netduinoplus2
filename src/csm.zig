// Module
// Input: TODO
// Output: TODO
// Design: CSM 分为前端和后端 'Front-Handler' 'Back-Handler', 两者的"接口"为 <k,v>. 前端将处理的结果规约为 <k,v>, 后端则负责处理(/响应) <k,v>

const std = @import("std");

// ? ANSI-es
const es = struct {
    // /// Backspace
    // const BS = 0x08;

    const output = struct {
        const DEL = "\x08 \x08";
        /// right 'ESC [ C'
        const RIGHT = "\x1B[C";
        /// left 'ESC [ D'
        const LEFT = "\x1B[D";
        /// clear screen
        const CLS = "\x1b[2J";

        const DEL2 = "\x1b[<1>P";
    };

    const ec = struct {
        const ESC = 0x1B;
        const DEL = 0x7F;

        /// Carriage return
        const CR = 0x0D;
        /// Line Feed
        const LF = 0x0A;

        /// ctrl-A
        const CTRL_A = 'a' - 0x60;
        /// ctrl-E
        const CTRL_E = 'e' - 0x60;
    };
};

// enum input
const EI = enum {
    PLAIN,
    DEL,
    UP,
    DOWN,
    RIGHT,
    LEFT,
    // CRLF or LF
    LINE,
};

// Character Stream Machine
const CSM = struct {
    frontHandler: FrontHandler,
    backHandler: BackHandler,
    const Self = @This();

    pub fn inputc(self: *Self, c: u8) void {
        self.frontHandler.inputc(c);
    }
};

pub fn new(dep_puts: *const fn (s: []const u8) void, cb_complete: *const fn (s: []const u8) void) CSM {
    var csm = CSM{
        .frontHandler = .{
            .dep_puts = dep_puts,
            .dep_handler = undefined,
        },
        .backHandler = .{
            .dep_puts = dep_puts,
            .cb_complete = cb_complete,
        },
    };

    csm.frontHandler.dep_handler = csm.backHandler;

    return csm;

    // return .{
    //     .frontHandler = .{
    //         .dep_puts = dep_puts,
    //         .dep_handler = backHandler.handler_intf(),
    //     },
    //     .backHandler = backHandler,
    // };
}

const FrontHandler = struct {
    sta: Sta = Sta.STA_DEFUATL,
    handler: BackHandler = undefined,

    // FHs
    fh_esc: FH_ESC = .{},

    // Dependencies
    // dep_handle: *const fn (ctx: *anyopaque, k: EI, v: u8) void,
    // dep_handle_ctx: *anyopaque,
    dep_handler: BackHandler,
    dep_puts: *const fn (s: []const u8) void,

    const Sta = enum {
        STA_DEFUATL,
        STA_FH_ESC,
    };

    const Self = @This();

    pub fn call_handle(self: *Self, k: EI, v: u8) void {
        self.dep_handler.handle(k, v);
    }

    pub fn call_puts(self: *Self, s: []const u8) void {
        self.dep_puts(s);
    }

    pub fn inputc(self: *Self, c: u8) void {
        // self.call_puts(&int2hstr(c));

        switch (self.sta) {
            // 此状态下根据输入的 c, 判断出需要转交的 FH, 或直接处理(单字符终结符)
            .STA_DEFUATL => {
                switch (c) {
                    es.ec.ESC => {
                        self.sta = Sta.STA_FH_ESC;
                    },
                    es.ec.DEL => {
                        self.call_handle(EI.DEL, 0);
                    },
                    es.ec.CR, es.ec.LF => {
                        self.call_handle(EI.LINE, 0);
                    },
                    // other normal characters
                    else => {
                        if (c >= 0x20 and c <= 0x7E) {
                            self.call_handle(EI.PLAIN, c);
                        } else if (c == es.ec.CTRL_E) {
                            self.call_puts("\r\nunsupported input CTRL_E\r\n");
                        } else if (c == es.ec.CTRL_A) {
                            self.call_puts("\r\nunsupported input CTRL_A\r\n");
                        } else {
                            self.call_puts("\r\nunkown input\r\n");
                            self.call_puts(&int2hstr(c));
                        }
                    },
                }
            },
            // FH_ESC
            .STA_FH_ESC => {
                var res = self.fh_esc.inputc(c);
                if (res != FHRESULT.NEND) {
                    self.sta = Sta.STA_DEFUATL;
                    if (res == FHRESULT.END_OK) {
                        var result = self.fh_esc.getres();
                        self.call_handle(result, 0);
                    }
                }
            },
        }
    }
};

// Front-Handler for 'ESC [ A|B|C|D'
// note: assume the first input is '['
const FH_ESC = struct {
    sta: Sta = Sta.DEFAULT,
    res: EI = undefined,
    // err: u8 = 0,

    const Sta = enum {
        DEFAULT,
        ABCD,
    };

    fn reset(self: *FH_ESC) void {
        self.sta = Sta.DEFAULT;
        // self.err = 0;
        // self.res = 0;
    }

    fn getres(self: *FH_ESC) EI {
        var res = self.res;
        self.reset();
        return res;
    }

    // fn geterr(self: *FH_ESC) u8 {
    //     _ = self;
    // }

    fn inputc(self: *FH_ESC, c: u8) FHRESULT {
        var ret = FHRESULT.NEND;
        switch (self.sta) {
            // expect '['
            .DEFAULT => {
                if (c != '[') {
                    self.reset();
                    ret = FHRESULT.END_ERR;
                }
                self.sta = Sta.ABCD;
            },
            .ABCD => {
                ret = FHRESULT.END_OK;
                switch (c) {
                    'A' => {
                        self.res = EI.UP;
                    },
                    'B' => {
                        self.res = EI.DOWN;
                    },
                    'C' => {
                        self.res = EI.RIGHT;
                    },
                    'D' => {
                        self.res = EI.LEFT;
                    },
                    else => {
                        ret = FHRESULT.END_ERR;
                    },
                }
            },
        }
        return ret;
    }
};

// TODO improve smell
// Front-Handler result
const FHRESULT = enum {
    NEND,
    END_OK,
    END_ERR,
};

// const HandlerIntf = struct {
//     ptr: *anyopaque,
//     handleFn: *const fn (ctx: *anyopaque, k: EI, v: u8) void,

//     const Self = @This();

//     // This is new
//     fn init(ptr: anytype) HandlerIntf {
//         const T = @TypeOf(ptr);
//         const typeInfo = @typeInfo(T);
//         const gen = struct {
//             pub fn handle(ctx: *anyopaque, k: EI, v: u8) void {
//                 const self: T = @ptrCast(@alignCast(ctx));
//                 return typeInfo.Pointer.child.handle(self, k, v);
//             }
//         };
//         return .{
//             .ptr = ptr,
//             .handleFn = gen.handle,
//         };
//     }

//     pub inline fn handle(self: Self, k: EI, v: u8) void {
//         return self.handleFn(self.ptr, k, v);
//     }
// };

const BackHandler = struct {
    buf: [128]u8 = undefined,
    buf_idx: u8 = 0,
    cur_idx: u8 = 0,

    // Dependencies
    cb_complete: *const fn (s: []const u8) void,
    dep_puts: *const fn (s: []const u8) void,

    const Self = @This();

    pub fn call_cb_complete(self: *Self, s: []const u8) void {
        self.cb_complete(s);
    }

    pub fn call_puts(self: *Self, s: []const u8) void {
        self.dep_puts(s);
    }
    fn _cputs(self: *Self, s: []const u8) void {
        self.call_puts("\n");
        self.call_puts(s);
        self.call_puts("\nmcli:~$ ");
    }

    fn reset(self: *Self) void {
        self.cur_idx = 0;
        self.buf_idx = 0;
    }

    pub fn handle(self: *Self, k: EI, v: u8) void {
        switch (k) {
            .DEL => {
                // TODO improve smell

                if (self.cur_idx > 0) {
                    self.call_puts(es.output.DEL);
                    self.buf_idx -= 1;
                    self.cur_idx -= 1;

                    // case mid
                    if (self.cur_idx != self.buf_idx) {
                        array_delete(&self.buf, self.buf_idx, self.cur_idx);

                        self.buf[self.buf_idx] = ' ';
                        self.call_puts(self.buf[self.cur_idx .. self.buf_idx + 1]);
                        var i = self.buf_idx - self.cur_idx + 1;
                        while (i > 0) {
                            self.call_puts(es.output.LEFT);
                            i -= 1;
                        }
                    }
                }
            },
            .PLAIN => {
                // TODO improve smell
                if (self.cur_idx == self.buf_idx) {
                    self.buf[self.buf_idx] = v;
                    var _c = [1]u8{v};
                    self.call_puts(&_c);
                } else {
                    array_insert(&self.buf, self.buf_idx, self.cur_idx, v);

                    self.call_puts(self.buf[self.cur_idx .. self.buf_idx + 1]);
                    var i = self.buf_idx - self.cur_idx;
                    while (i > 0) {
                        self.call_puts(es.output.LEFT);
                        i -= 1;
                    }
                }

                self.buf_idx += 1;
                self.cur_idx += 1;
            },
            .UP => {
                // self._cputs("Up");
            },
            .DOWN => {
                // self._cputs("Down");
            },
            .RIGHT => {
                if (self.cur_idx < self.buf_idx) {
                    self.cur_idx += 1;
                    self.call_puts(es.output.RIGHT);
                }
            },
            .LEFT => {
                if (self.cur_idx > 0) {
                    self.cur_idx -= 1;
                    self.call_puts(es.output.LEFT);
                }
            },
            .LINE => {
                // self._cputs(self.buf[0..self.buf_idx]);
                self.call_cb_complete(self.buf[0..self.buf_idx]);
                self.reset();
            },

            // else => {},
        }
    }

    // fn handler_intf(self: *Self) HandlerIntf {
    //     self.cur_idx = 0;
    //     self.buf_idx = 0;
    //     self.dep_puts("test");
    //     return HandlerIntf.init(self);
    // }
};

// pub var csm = CSM{};

// simple version without checking
fn array_insert(arr: []u8, len: u8, idx: u8, val: u8) void {
    var r = len;

    while (r > idx) {
        arr[r] = arr[r - 1];
        r -= 1;
    }
    arr[idx] = val;
}

// simple version without checking
// arr: the array
// len: array length
// idx: indicate the element to be removed
fn array_delete(arr: []u8, len: u8, idx: u8) void {
    var i = idx;

    while (i <= len - 1) {
        arr[i] = arr[i + 1];
        i += 1;
    }
}

test "insert" {
    var arr = [_]u8{ 1, 2, 3, 0 };

    array_insert(&arr, 3, 1, 4);
    std.debug.print("\r\narr:{any}\r\n", .{arr});
}

test "delete" {
    var arr = [_]u8{ 1, 2, 3, 0 };

    array_delete(&arr, 3, 1);
    std.debug.print("\r\narr:{any}\r\n", .{arr});
}

fn int2hstr(c: u8) [5]u8 {
    var buf = [_]u8{ '0', 'x', '.', '.', ' ' };
    buf[2] = oct2chex(c / 16);
    buf[3] = oct2chex(c % 16);
    return buf;
}

fn oct2chex(v: u8) u8 {
    if (v > 9) {
        return v - 10 + 'A';
    } else {
        return v + '0';
    }
}

test "int2hstr" {
    std.debug.print("\r\nint2hstr:{s}\r\n", .{int2hstr(1)});
}
