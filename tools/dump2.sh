programFile=`ls zig-out/bin/*.elf | head -n 1`

arm-none-eabi-objdump.exe ${programFile} -h > objdump2.out