/* Define the entry point of the output file. */
ENTRY(_startup)

/* Define memory regions. */
MEMORY
{
  ROM (rx)  : ORIGIN = 0x08000000, LENGTH = 1024K
  RAM (rwx) : ORIGIN = 0x20000000, LENGTH = 128K
  CCMRAM (xrw) : ORIGIN = 0x10000000, LENGTH = 64K
}

/* Define sections. */
SECTIONS
{
  .text : {
    KEEP(*(.vector_table)); /* Vector table and pretect this section from removing (the optmization will remove unrefered code) */
    *(.text)  /* Program code */
    *(.text*)  /* Program code */
    *(.rodata)  /* Read-only data */
    *(.rodata*)  /* Read-only data */
  } >ROM

  _data_loadaddr = LOADADDR(.data);
  .data : {
    . = ALIGN(4);
    _data_start = .;
    *(.data)  /* Read-write non-zero initialized data */
    *(.data*)  /* Read-write non-zero initialized data */
    . = ALIGN(4);
    _data_end = .;
  } >RAM AT>ROM

  .bss : {
    . = ALIGN(4);
    _bss_start = .;
    *(.bss) /* Read-write zero initialized data */
    *(.bss*) /* Read-write zero initialized data */
    . = ALIGN(4);
    _bss_end = .;
  } > RAM 

  /* _stack_start = ADDR(.bss) + SIZEOF(.bss); */
  /* _stack_end = _stack_start + 0x1000; 64KB */
}

PROVIDE(_stack_end = ORIGIN(CCMRAM) + LENGTH(CCMRAM));
