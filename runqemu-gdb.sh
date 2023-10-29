programFile=`ls zig-out/bin/*.elf | head -n 1`

# this will start a gdb server(port:1234) and then you can use gdb to debug 
qemu-system-arm -M netduinoplus2 -nographic -serial mon:stdio -kernel ${programFile} -s -S
