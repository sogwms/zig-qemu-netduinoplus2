programFile=`ls zig-out/bin/*.elf | head -n 1`

arm-none-eabi-gdb ${programFile} -ex "target remote :1234"
