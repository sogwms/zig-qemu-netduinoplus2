const builtin = @import("std").builtin;
const main = @import("main.zig");
const chip = @import("reg/stm32f405_reg.zig");
const reg = chip.devices.STM32F405.peripherals;

const uart = @import("uart.zig");
const putc = uart.putc;
const getc = uart.getc;
const puts = uart.puts;

// These symbols come from the linker script
extern var _data_loadaddr: u32;
extern var _data_start: u32;
extern var _data_end: u32;
extern var _bss_start: u32;
extern var _bss_end: u32;

export fn resetHandler() callconv(.C) void {
    // fill .bss with zeroes
    {
        const bss_start: [*]u8 = @ptrCast(&_bss_start);
        const bss_end: [*]u8 = @ptrCast(&_bss_end);
        const bss_len = @intFromPtr(bss_end) - @intFromPtr(bss_start);

        @memset(bss_start[0..bss_len], 0);
    }

    // load .data from flash
    {
        const data_start: [*]u8 = @ptrCast(&_data_start);
        const data_end: [*]u8 = @ptrCast(&_data_end);
        const data_len = @intFromPtr(data_end) - @intFromPtr(data_start);
        const data_src: [*]const u8 = @ptrCast(&_data_loadaddr);

        @memcpy(data_start[0..data_len], data_src[0..data_len]);
    }

    // Initialize clock, uart
    basic_init();

    // Call main
    main.main();

    unreachable;
}

fn basic_init() void {
    // Skip clock stuff on qemu
    // clock_init();

    // Ignore error handling
    _ = uart.init() catch {};

    debug_puts("Basic initializations done\r\n");
}

pub fn clock_init() void {
    // left empty
}

inline fn debug_puts(s: []const u8) void {
    puts(s);
}

// panic handler
pub fn panic(msg: []const u8, error_return_trace: ?*builtin.StackTrace, ret_addr: ?usize) noreturn {
    @setCold(true);
    _ = error_return_trace;
    _ = ret_addr;
    debug_puts("\r\n!KERNEL PANIC!\r\n");
    debug_puts(msg);
    while (true) {}
}

export fn interruptHandler() void {
    // TODO
    debug_puts("\r\nIrq handling has not yet been implemented!\r\n");
    while (true) {}
}
