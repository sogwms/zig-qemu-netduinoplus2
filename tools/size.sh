programFile=`ls zig-out/bin/*.elf | head -n 1`

arm-none-eabi-size.exe ${programFile}