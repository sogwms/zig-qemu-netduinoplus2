const uart = @import("uart.zig");
const putc = uart.putc;
const getc = uart.getc;
const puts = uart.puts;

const std = @import("std");

pub fn main() void {
    puts("Hello World\r\n");

    while (true) {
        putc('.');
        delay();
        if (getc()) |d| {
            putc(d);
        }
    }
}

fn delay() void {
    var i: u32 = 0;
    while (i < 10000000) {
        i += 1;
    }
}
