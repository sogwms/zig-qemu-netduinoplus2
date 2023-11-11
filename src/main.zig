const std = @import("std");

const mcli = @import("cli/mcli.zig");

const uart = @import("uart.zig");
const putc = uart.putc;
const getc = uart.getc;
const puts = uart.puts;
const csm = @import("csm.zig");

fn csm_cb_complete(s: []const u8) void {
    puts("\r\n");
    puts(s);
    puts("\r\nmcli:~$ ");
}

pub fn main() void {
    puts("Hello World\r\n");

    var cli = mcli.new();

    var _reader = mcli.sreader_from_buffer("echo hello\r\n");

    var _writer = mcli.swriter_from_putc_without_ctx(putc);

    cli.call(_reader.reader(), _writer.writer(), _writer.writer());

    puts("\r\nmcli:~$ ");

    var mcsm = csm.new(puts, csm_cb_complete);
    while (true) {
        // putc('.');
        delay();
        if (getc()) |d| {
            // if (d == 'q') {
            //     break;
            // } else if (d == ascii.DEL) {
            //     // puts("\r\ndel\r\n");
            //     putc(ascii.BS);
            //     putc(' ');
            //     putc(ascii.BS);
            // } else if (d == ascii.ESC) {
            //     putc(ascii.CR);
            // }
            // putc(d);

            // putc_in_hex(d);

            mcsm.inputc(d);
        }
    }
}

fn delay() void {
    var i: u32 = 0;
    while (i < 100000) {
        i += 1;
    }
}
