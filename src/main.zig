const uart = @import("uart.zig");
const putc = uart.putc;
const getc = uart.getc;
const puts = uart.puts;

const std = @import("std");

pub fn main() void {
    puts("Hello World\r\n");

    while (true) {
        putc('.');
        putc(uart.getc_block());
    }
}
