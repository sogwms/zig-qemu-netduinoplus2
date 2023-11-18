// const chip = @import("reg/stm32f405_reg.zig");
// const reg = chip.devices.STM32F405.peripherals;

// uart1 only
const USART1_SR: *volatile u32 = @intToPtr(*volatile u32, 0x40011000);
const USART1_CR1: *volatile u32 = @intToPtr(*volatile u32, 0x4001100C);
const USART1_DR: *volatile u32 = @intToPtr(*volatile u32, 0x40011004);

pub fn init() !void {
    // Enable clock
    // reg.RCC.AHB1ENR.modify(.{ .GPIOAEN = 1 });
    // reg.RCC.APB2ENR.modify(.{ .USART1EN = 1 });

    // Set uart pin
    // try chip.pinmgr.pinmgr_set_pin_mux(try chip.pinid.pin_id_from_hrs("A02"), 0b0111);
    // try chip.pinmgr.pinmgr_set_pin_mux(try chip.pinid.pin_id_from_hrs("A03"), 0b0111);

    // Init uart (115200)
    // reg.USART1.CR1.modify(.{ .UE = 0 });
    //// reg.USART1.BRR.modify(.{ .DIV_Fraction = 12, .DIV_Mantissa = 22 });
    // reg.USART1.CR1.modify(.{ .UE = 1, .TE = 1, .RE = 1, .M = 0, .OVER8 = 0 });

    USART1_CR1.* = USART1_CR1.* | (1 << 13) | (1 << 2);

    // enable uart rx interrupt
    // reg.USART1.CR1.modify(.{ .RXNEIE = 1 });
}

pub fn putc(c: u8) void {
    // const uart = reg.USART1;

    // while (uart.SR.read().TXE == 0) {} // wait last transmit done
    // uart.DR.write_raw(c);
    USART1_DR.* = c;
}

pub fn getc_block() u8 {
    // wait rx ready
    while ((USART1_SR.* & (1 << 5)) == 0) {}
    return @as(u8, @truncate(u8, USART1_DR.*));
}

pub fn getc() ?u8 {
    // const uart = reg.USART1;

    // if (uart.SR.read().RXNE == 1) {
    //     return @as(u8, @truncate(u8, uart.DR.read().DR));
    // }
    return null;
}

pub fn puts(s: []const u8) void {
    for (s) |c| {
        putc(c);
    }
}
