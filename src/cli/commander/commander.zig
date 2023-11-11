const base = @import("../base/base.zig");
const std = @import("std");

const MAX_NUM_CMDS = 128;

// editor representation
const Commander = struct {
    cmd_list: [MAX_NUM_CMDS]base.Command = undefined,
    cmd_name_list: [MAX_NUM_CMDS][]const u8 = undefined,
    cmd_count: u8 = 0,

    const Self = @This();

    // call the module
    pub fn call(self: *Self, in: base.SReader, sout: base.SWriter, eout: base.SWriter) void {
        var buf: [128]u8 = undefined;
        var rsize = in.read(&buf, 16);
        _ = rsize;
        // std.debug.print("\r\n[debug-mcli/commander]: {s}\r\n", .{buf[0..rsize]});
        self.cmd_list[0].call(in, sout, eout);
    }

    // Add a new command to commander
    // return 'failed' if the command existed
    pub fn add_cmd(self: *Self, name: []const u8, cmd: base.Command) void {
        if (self.cmd_count == MAX_NUM_CMDS) {
            // std.debug.print("\r\n[debug-mcli/add-cmd]: the command's pool is full\r\n", .{});
            return;
        }

        self.cmd_list[self.cmd_count] = cmd;
        self.cmd_name_list[self.cmd_count] = name;
        self.cmd_count += 1;

        // std.debug.print("\r\n[debug-mcli/add-cmd]: {s}\r\n", .{name});
    }
    // Remove the command from commander
    pub fn rm_cmd(self: *Self, name: []const u8) void {
        _ = self;
        _ = name;
    }

    fn find_cmd_idx(self: *Self, name: []const u8) ?u8 {
        var idx = 0;
        while (idx < self.cmd_count) {
            if (str_is_equal(self.cmd_name_list[idx], name)) {
                return idx;
            }
            idx += 1;
        }
    }

    pub fn commander(self: *Self) base.Commander {
        return base.Commander.init(self);
    }
};

var gcommander: Commander = undefined;

pub fn new() base.Commander {
    var cmder: base.Commander = gcommander.commander();
    return cmder;
}

// TODO get the first 'token' (judge by space) and the rest from stream

/// return true if s1 and s2 are equal
fn str_is_equal(s1: []const u8, s2: []const u8) bool {
    if (s1.len != s2.len) {
        return false;
    }

    for (s1, 0..) |_, i| {
        if (s1[i] != s2[i]) {
            return false;
        }
    }

    return true;
}

fn is_char_space(c: u8) bool {
    return c == ' ';
}

fn parse_cmd_by_space(t: []const u8) []const u8 {
    var l: usize = t.len + 1;
    for (0..t.len) |i| {
        if (!is_char_space(t[i])) {
            l = i;
            break;
        }
    }

    var r = t.len;
    for ((l + 1)..t.len) |i| {
        if (is_char_space(t[i])) {
            r = i;
            break;
        }
    }

    if (l > t.len) {
        return undefined;
    }

    return t[l..r];

    // var r = t.len;
    // for (t, 0..) |v, i| {
    //     if (is_char_space(v)) {
    //         r = i;
    //         break;
    //     }
    // }

    // return t[0..r];
}

test "str_is_equal" {
    try std.testing.expectEqual(str_is_equal("hello", "hell0"), false);

    try std.testing.expectEqual(str_is_equal("hello", "hello"), true);

    try std.testing.expectEqual(str_is_equal("hello ", "hello "), true);
    try std.testing.expectEqual(str_is_equal("he llo", "he llo"), true);
}

test "parse_cmd_by_space" {
    try std.testing.expectEqualSlices(u8, "hello", parse_cmd_by_space("hello"));
    try std.testing.expectEqualSlices(u8, "hello", parse_cmd_by_space("   hello "));
}
